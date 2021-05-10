local mod	= DBM:NewMod("GeneralVezax", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

mod:SetCreatureID(33271)
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(7, 8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS",
	"RAID_BOSS_EMOTE"
)

local warnShadowCrash			= mod:NewTargetAnnounce(312978, 4) -- Темное сокрушение
local warnLeechLife				= mod:NewTargetNoFilterAnnounce(312974, 3)
local warnSaroniteVapor			= mod:NewCountAnnounce(312983, 2)

local specWarnShadowCrash		= mod:NewSpecialWarningDodge(312978, nil, nil, nil, 1, 2)
local specWarnShadowCrashNear	= mod:NewSpecialWarningClose(312978, nil, nil, nil, 1, 2)
local yellShadowCrash			= mod:NewYell(312978)
local specWarnSurgeDarkness		= mod:NewSpecialWarningDefensive(312981, nil, nil, 2, 1, 2)
local specWarnLifeLeechYou		= mod:NewSpecialWarningMoveAway(312974, nil, nil, nil, 3, 2)
local yellLifeLeech				= mod:NewYell(312974)
local specWarnLifeLeechNear 	= mod:NewSpecialWarningClose(312974, nil, nil, 2, 1, 2)
local specWarnSearingFlames		= mod:NewSpecialWarningInterruptCount(312977, "HasInterrupt", nil, nil, 1, 2)-- ????????
--local specWarnAnimus			= mod:NewSpecialWarningSwitch("ej17651", nil, nil, nil, 1, 2)-- ????????????????

local timerEnrage				= mod:NewBerserkTimer(600)
local timerSearingFlamesCast	= mod:NewCastTimer(2, 312977)
local timerSurgeofDarkness		= mod:NewBuffActiveTimer(10, 312981, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerNextSurgeofDarkness	= mod:NewBuffActiveTimer(61.7, 312981, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerSaroniteVapors		= mod:NewNextCountTimer(30, 312985, nil, nil, nil, 5)
local timerShadowCrashCD		= mod:NewCDTimer(12, 312978, nil, "Ranged", nil, 3)
local timerLifeLeech			= mod:NewTargetTimer(10, 312974, nil, false, 2, 3)
local timerLifeLeechCD			= mod:NewCDTimer(36, 312974, nil, nil, nil, 3)
--local timerLeech				= mod:NewNextTimer(36, 312974)
--local timerCrashArrow           = mod:NewNextTimer(15,312978)
local timerHardmode				= mod:NewTimer(189, "hardmodeSpawn", nil, nil, nil, 1)



mod:AddSetIconOption("SetIconOnShadowCrash", 312978, true, false, {8})
mod:AddSetIconOption("SetIconOnLifeLeach", 312974, true, false, {7})
--mod:AddBoolOption("CrashArrow")


mod.vb.interruptCount = 0
mod.vb.vaporsCount = 0
--local animusName = DBM:EJ_GetSectionInfo(17651)

function mod:ShadowCrashTarget(targetname, uId)
	if not targetname then return end
	if self.Options.SetIconOnShadowCrash then
		self:SetIcon(targetname, 8, 5)
	end
	if targetname == UnitName("player") then
		specWarnShadowCrash:Show()
		specWarnShadowCrash:Play("runaway")
		yellShadowCrash:Yell()
	elseif targetname then
		if uId then
			local inRange = CheckInteractDistance(uId, 2)
			if inRange then
				specWarnShadowCrashNear:Show(targetname)
				specWarnShadowCrashNear:Play("runaway")
			end
		end
	else
		warnShadowCrash:Show(targetname)
	end
end


function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 33271, "GeneralVezax")
	self.vb.interruptCount = 0
	self.vb.vaporsCount = 0
	timerShadowCrashCD:Start(10.9-delay)
	timerLifeLeechCD:Start(16.9-delay)
	timerSaroniteVapors:Start(30-delay, 1)
	timerEnrage:Start(-delay)
	timerHardmode:Start(-delay)
	timerNextSurgeofDarkness:Start(-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33271, "GeneralVezax", wipe)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 312977 then	-- Searing Flames
		self.vb.interruptCount = self.vb.interruptCount + 1
		if self.vb.interruptCount == 4 then
			self.vb.interruptCount = 1
		end
		local kickCount = self.vb.interruptCount
		specWarnSearingFlames:Show(args.sourceName, kickCount)
		specWarnSearingFlames:Play("kick"..kickCount.."r")
	elseif args.spellId == 312981 then
		local tanking, status = UnitDetailedThreatSituation("player", "boss1")
		if tanking or (status == 3) then--Player is current target
			specWarnSurgeDarkness:Show()
			specWarnSurgeDarkness:Play("defensive")
		end
		timerNextSurgeofDarkness:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312981) then	-- Surge of Darkness
		timerSurgeofDarkness:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(312981) then
		timerSurgeofDarkness:Stop()
	end
end

--[[function mod:ShadowCrashTarget()
	local target = self:GetBossTarget(33271)
	if not target then return end
	if mod:LatencyCheck() then--Only send sync if you have low latency.
		self:SendSync("CrashOn", target)
	end
end]]


function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(312978) then		-- Shadow Crash
		self:BossTargetScanner(33271, "ShadowCrashTarget", 0.05, 20)
		timerShadowCrashCD:Start()
	elseif args:IsSpellID(312974) then	-- Mark of the Faceless
		if self.Options.SetIconOnLifeLeach then
			self:SetIcon(args.destName, 7, 10)
		end
		warnLeechLife:Show(args.destName)
		timerLifeLeech:Start(args.destName)
		--timerLeech:Start()
		if args:IsPlayer() then
			specWarnLifeLeechYou:Show()
			specWarnLifeLeechYou:Play("runout")
			yellLifeLeech:Yell()
		else
			local uId = DBM:GetRaidUnitId(args.destName)
			if uId then
				local inRange = CheckInteractDistance(uId, 2)
				if inRange then
					specWarnLifeLeechNear:Show(args.destName)
					specWarnLifeLeechNear:Play("runaway")
				else
					warnLeechLife:Show(args.destName)
				end
			end
		end
	elseif args.spellId == 63364 then ---????????
		--specWarnAnimus:Show()
		--specWarnAnimus:Play("bigmob")
	end
end

function mod:RAID_BOSS_EMOTE(emote)
	if emote == L.EmoteSaroniteVapors or emote:find(L.EmoteSaroniteVapors) then
		self.vb.vaporsCount = self.vb.vaporsCount + 1
		warnSaroniteVapor:Show(self.vb.vaporsCount)
		if self.vb.vaporsCount < 6 then
			timerSaroniteVapors:Start(nil, self.vb.vaporsCount+1)
		end
	end
end
