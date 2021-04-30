local mod	= DBM:NewMod("YoggSaron", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210425232323")

mod:SetCreatureID(33288)
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(6, 7, 8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_SUMMON",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_AURA_REMOVED_DOSE",
	"UNIT_HEALTH"
)


local warnMadness 					= mod:NewCastAnnounce(313003, 2)
local warnFervorCast 				= mod:NewCastAnnounce(312989, 3)
local warnSqueeze					= mod:NewTargetAnnounce(313031, 3)
local warnFervor					= mod:NewTargetAnnounce(312989, 4)
local warnDeafeningRoarSoon			= mod:NewPreWarnAnnounce(313000, 5, 3)
local warnGuardianSpawned 			= mod:NewAnnounce("WarningGuardianSpawned", 3, 62979)
local warnCrusherTentacleSpawned	= mod:NewAnnounce("WarningCrusherTentacleSpawned", 2)
local warnP2 						= mod:NewPhaseAnnounce(2, 2)
local warnP3 						= mod:NewPhaseAnnounce(3, 2)
local warnSanity 					= mod:NewAnnounce("WarningSanity", 3, 63050)
local warnBrainLink 				= mod:NewTargetAnnounce(312995, 3)
local warnBrainPortalSoon			= mod:NewAnnounce("WarnBrainPortalSoon", 2)
local warnEmpowerSoon				= mod:NewSoonAnnounce(313014, 4)

local specWarnGuardianLow 			= mod:NewSpecialWarning("SpecWarnGuardianLow", false)
local specWarnBrainLink 			= mod:NewSpecialWarningYou(312995)
local specWarnSanity 				= mod:NewSpecialWarning("SpecWarnSanity")
local specWarnMadnessOutNow			= mod:NewSpecialWarning("SpecWarnMadnessOutNow")
local specWarnBrainPortalSoon		= mod:NewSpecialWarning("specWarnBrainPortalSoon", false)
local specWarnDeafeningRoar			= mod:NewSpecialWarningSpell(313000)
local specWarnFervor				= mod:NewSpecialWarningYou(312989)
local specWarnFervorCast			= mod:NewSpecialWarning("SpecWarnFervorCast", mod:IsMelee())
local specWarnMaladyNear			= mod:NewSpecialWarning("SpecWarnMaladyNear", true)

mod:AddBoolOption("WarningSqueeze", true, "announce")

local enrageTimer					= mod:NewBerserkTimer(900)
local timerFervor					= mod:NewTargetTimer(15, 312989)
local brainportal					= mod:NewTimer(20, "NextPortal")
local timerLunaricGaze				= mod:NewCastTimer(4, 312002)
local timerNextLunaricGaze			= mod:NewCDTimer(8.5, 312002)
local timerEmpower					= mod:NewCDTimer(46, 64465)
local timerEmpowerDuration			= mod:NewBuffActiveTimer(10, 64465)
local timerMadness 					= mod:NewCastTimer(60, 313003)
local timerCastDeafeningRoar		= mod:NewCastTimer(2.3, 313000)
local timerNextDeafeningRoar		= mod:NewNextTimer(30, 313000)
local timerAchieve					= mod:NewAchievementTimer(420, 3012, "TimerSpeedKill")

mod:AddBoolOption("ShowSaraHealth")
mod:AddBoolOption("SetIconOnFearTarget")
mod:AddBoolOption("SetIconOnFervorTarget")
mod:AddBoolOption("SetIconOnBrainLinkTarget")
mod:AddBoolOption("MaladyArrow")
mod:AddBoolOption("YellOnDeathCoil", true)

local phase							= 1
local targetWarningsShown			= {}
local brainLinkTargets = {}
local brainLinkIcon = 7
local Guardians = 0

function mod:OnCombatStart(delay)
	Guardians = 0
	phase = 1
	enrageTimer:Start()
	timerAchieve:Start()
	if self.Options.ShowSaraHealth and not self.Options.HealthFrame then
		DBM.BossHealth:Show(L.name)
	end
	if self.Options.ShowSaraHealth then
		DBM.BossHealth:AddBoss(33134, L.Sara)
	end
	table.wipe(targetWarningsShown)
	table.wipe(brainLinkTargets)
end

function mod:FervorTarget()
	local targetname = self:GetBossTarget(33134)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnFervorCast:Show()
	end
end

function mod:warnBrainLink()
	warnBrainLink:Show(table.concat(brainLinkTargets, "<, >"))
	table.wipe(brainLinkTargets)
	brainLinkIcon = 7
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(313003) then	-- Induce Madness
		timerMadness:Start()
		warnMadness:Show()
		brainportal:Schedule(60)
		warnBrainPortalSoon:Schedule(78)
		specWarnBrainPortalSoon:Schedule(78)
		specWarnMadnessOutNow:Schedule(55)
	elseif args:IsSpellID(313000) then		--Deafening Roar
		timerNextDeafeningRoar:Start()
		warnDeafeningRoarSoon:Schedule(55)
		timerCastDeafeningRoar:Start()
		specWarnDeafeningRoar:Show()
	elseif args:IsSpellID(312989) then		--Sara's Fervor
		self:ScheduleMethod(0.1, "FervorTarget")
		warnFervorCast:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(64144) and self:GetUnitCreatureId(args.sourceGUID) == 33966 then 
		warnCrusherTentacleSpawned:Show()
	end
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(62979) then
		Guardians = Guardians + 1
		warnGuardianSpawned:Show(Guardians)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312995) then		-- Brain Link
		self:UnscheduleMethod("warnBrainLink")
		brainLinkTargets[#brainLinkTargets + 1] = args.destName
		if self.Options.SetIconOnBrainLinkTarget then
			self:SetIcon(args.destName, brainLinkIcon, 30)
			brainLinkIcon = brainLinkIcon - 1
		end
		if args:IsPlayer() then
			specWarnBrainLink:Show()
		end
		mod:ScheduleMethod(0.2, "warnBrainLink")
	elseif args:IsSpellID(63830, 63881, 312993, 313029) then   -- Malady of the Mind (Death Coil) 
		if self.Options.SetIconOnFearTarget then
			self:SetIcon(args.destName, 8, 30) 
		end
		if self.Options.YellOnDeathCoil and args:IsPlayer() then
			SendChatMessage(L.YellDeathCoil, "SAY")
	end
		local uId = DBM:GetRaidUnitId(args.destName) 
		if uId then 
			local inRange = CheckInteractDistance(uId, 2)
			local x, y = GetPlayerMapPosition(uId)
			if x == 0 and y == 0 then
				SetMapToCurrentZone()
				x, y = GetPlayerMapPosition(uId)
			end
			if inRange then 
				specWarnMaladyNear:Show(args.destName)
				if self.Options.MaladyArrow then
					DBM.Arrow:ShowRunAway(x, y, 12, 5)
				end
			end 
		end 
	elseif args:IsSpellID(64126, 313031) then	-- Squeeze		
		warnSqueeze:Show(args.destName)
		if args:IsPlayer() and self.Options.WarningSqueeze then			
			SendChatMessage(L.WarningYellSqueeze, "SAY")			
		end	
	elseif args:IsSpellID(312989) then	-- Sara's Fervor
		warnFervor:Show(args.destName)
		timerFervor:Start(args.destName)
		if self.Options.SetIconOnFervorTarget then
			self:SetIcon(args.destName, 7, 15)
		end
		if args:IsPlayer() then 
			specWarnFervor:Show()
		end
	elseif args:IsSpellID(63894) then	-- Shadowy Barrier of Yogg-Saron (this is happens when p2 starts)
		phase = 2
		brainportal:Start(60)
		warnBrainPortalSoon:Schedule(57)
		specWarnBrainPortalSoon:Schedule(57)
		warnP2:Show()
		if self.Options.ShowSaraHealth then
			DBM.BossHealth:RemoveBoss(33134)
			if not self.Options.HealthFrame then
				DBM.BossHealth:Hide()
			end
		end
	elseif args:IsSpellID(313028, 312002) then	-- Lunatic Gaze (reduces sanity)
		timerLunaricGaze:Start()
	elseif args:IsSpellID(64465) then
		timerEmpower:Start()
		timerEmpowerDuration:Start()
		warnEmpowerSoon:Schedule(40)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(63894) then		-- Shadowy Barrier removed from Yogg-Saron (start p3)
		if mod:LatencyCheck() then
			self:SendSync("Phase3")			-- Sync this because you don't get it in your combat log if you are in brain room.
		end
	elseif args:IsSpellID(313028, 312002) then	-- Lunatic Gaze
		timerNextLunaricGaze:Start()
	end
end

function mod:SPELL_AURA_REMOVED_DOSE(args)
	if args:IsSpellID(63050) and args.destGUID == UnitGUID("player") then
		if args.amount == 50 then
			warnSanity:Show(args.amount)
		elseif args.amount == 25 or args.amount == 15 or args.amount == 5 then
			warnSanity:Show(args.amount)
			specWarnSanity:Show(args.amount)
		end
	end
end

function mod:UNIT_HEALTH(uId)
	if phase == 1 and uId == "target" and self:GetUnitCreatureId(uId) == 33136 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.3 and not targetWarningsShown[UnitGUID(uId)] then
		targetWarningsShown[UnitGUID(uId)] = true
		specWarnGuardianLow:Show()
	end
end

function mod:OnSync(msg)
	if msg == "Phase3" then
		warnP3:Show()
		phase = 3
		brainportal:Stop()
        timerEmpower:Start()
        warnEmpowerSoon:Schedule(40)	
		warnBrainPortalSoon:Cancel()
		timerNextDeafeningRoar:Start(30)
		warnDeafeningRoarSoon:Schedule(25)
	end
end