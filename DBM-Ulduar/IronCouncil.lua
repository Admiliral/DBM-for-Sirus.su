local mod	= DBM:NewMod("IronCouncil", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210429163000")

mod:SetCreatureID(32927)
mod:RegisterCombat("combat", 32867, 32927, 32857)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_SUCCESS"
)

mod:AddBoolOption("HealthFrame", true)

mod:SetBossHealthInfo(
	32867, L.Steelbreaker,
	32927, L.RunemasterMolgeim,
	32857, L.StormcallerBrundir
)

local warnSupercharge			= mod:NewSpellAnnounce(312766, 3)

-- Stormcaller Brundir
-- High Voltage ... 63498
local warnChainlight			= mod:NewSpellAnnounce(312780, 2, nil, false, 2)
local timerOverload				= mod:NewCastTimer(6, 312782, nil, nil, nil, 2)
local timerLightningWhirl		= mod:NewCastTimer(5, 312784, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)
local specwarnLightningTendrils	= mod:NewSpecialWarningRun(312786, nil, nil, nil, 4, 2)
local timerLightningTendrils	= mod:NewBuffActiveTimer(27, 312786, nil, nil, nil, 6)
local specwarnOverload			= mod:NewSpecialWarningRun(312782, nil, nil, nil, 4, 2)
local specWarnLightningWhirl	= mod:NewSpecialWarningInterrupt(63483, "HasInterrupt", nil, nil, 1, 2)
mod:AddBoolOption("AlwaysWarnOnOverload", false, "announce")
--local specwarnStaticDisruption		= mod:NewSpecialWarningMoveAway(312770)
mod:AddBoolOption("PlaySoundOnOverload", true)
mod:AddBoolOption("PlaySoundLightningTendrils", true)

-- Steelbreaker
-- High Voltage ... don't know what to show here - 63498
local warnFusionPunch			= mod:NewSpellAnnounce(312769, 4)
local timerFusionPunchCast		= mod:NewCastTimer(3, 312769, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON..DBM_CORE_MAGIC_ICON)
local timerFusionPunchActive	= mod:NewTargetTimer(4,312769, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON..DBM_CORE_MAGIC_ICON)
local warnOverwhelmingPower		= mod:NewTargetAnnounce(312772, 2)
local timerOverwhelmingPower	= mod:NewTargetTimer(25, 312772, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON)
local warnStaticDisruption		= mod:NewTargetAnnounce(312770, 3)
local timerStaticDisruption		= mod:NewTargetAnnounce(30, 312770)
local specwarnFusionPunch       = mod:NewSpecialWarningDefensive(312769, mod:IsTank())
mod:AddSetIconOption("SetIconOnOverwhelmingPower", 61888, false, false, {8})
mod:AddSetIconOption("SetIconOnStaticDisruption", 63494, false, false, {1, 2, 3, 4, 5, 6, 7})

-- Runemaster Molgeim
-- Lightning Blast ... don't know, maybe 63491
local timerShieldofRunes		= mod:NewBuffActiveTimer(15, 312775)
local warnRuneofPower			= mod:NewTargetAnnounce(312776, 2) -- Руна мощи
local warnRuneofDeath			= mod:NewSpellAnnounce(312777, 2) -- Руна смерти
local warnShieldofRunes			= mod:NewSpellAnnounce(312774, 2) -- Руна щита
local warnRuneofSummoning		= mod:NewSpellAnnounce(312779, 3) --Руна призыва
local specwarnRuneofDeath		= mod:NewSpecialWarningMove(312777, nil, nil, nil, 1, 2)
local specWarnRuneofShields		= mod:NewSpecialWarningDispel(63967, "MagicDispeller", nil, nil, 1, 2)
local timerRuneofDeathDura		= mod:NewNextTimer(30, 312777, nil, nil, nil, 3)
local timerRuneofPower			= mod:NewCDTimer(30, 312776, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON)
local timerRuneofSummoning		= mod:NewCDTimer(24.1, 62273, nil, nil, nil, 1)


--[[local timerRuneofDeath			= mod:NewCDTimer(30, 312777)
local yellOverwhelmingPowerFades	= mod:NewFadesYell(312772)
local yellStaticDisruptionFades		= mod:NewFadesYell(312770)]]

mod:AddBoolOption("PlaySoundDeathRune", true, "announce")


local enrageTimer				= mod:NewBerserkTimer(900)

local disruptTargets = {}
mod.vb.disruptIcon = 7

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 32927, "IronCouncil")
	enrageTimer:Start(-delay)
	table.wipe(disruptTargets)
	mod.vb.disruptIcon = 7
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 32927, "IronCouncil", wipe)
	DBM.RangeCheck:Hide()
end

function mod:RuneTarget(targetname, uId)
	if not targetname then return end
		warnRuneofPower:Show(targetname)
end

local function warnStaticDisruptionTargets()
	warnStaticDisruption:Show(table.concat(disruptTargets, "<, >"))
	table.wipe(disruptTargets)
	diself.vb.disruptIcon = 7
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(312766, 312413) then -- Supercharge - Unleashes one last burst of energy as the caster dies, increasing all allies damage by 25% and granting them an additional ability.
		warnSupercharge:Show()
	elseif args:IsSpellID(312780, 312427) then	-- Цепная молния
		warnChainlight:Show()
	elseif args:IsSpellID(312784, 312783, 312430, 312431) then	-- Вихрь молний
		timerLightningWhirl:Start()
	elseif args:IsSpellID(312769, 312416) then	-- Энергетический удар
		warnFusionPunch:Show()
		timerFusionPunchCast:Start()
	elseif args:IsSpellID(312775, 312774, 312421, 312422) then		-- Рунический щит
		warnShieldofRunes:Show()
	elseif args:IsSpellID(312779, 312778, 312425, 312426) then			--	Руна призыва
		warnRuneofSummoning:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(312777, 312424) then		-- Руна смерти
		warnRuneofDeath:Show()
		timerRuneofDeathDura:Start()
	elseif args:IsSpellID(312423, 312776) then	-- Руна мощи
		self:ScheduleMethod(0.1, "RuneTarget", 0.1, 16, true, true)
		timerRuneofPower:Start()
	elseif args:IsSpellID(312782, 312781,312428,312429) then	-- Перегрузка
		timerOverload:Start()
		if self.Options.AlwaysWarnOnOverload or UnitName("target") == L.StormcallerBrundir then
			specwarnOverload:Show()
			specwarnOverload:Play("justrun")
			if self.Options.PlaySoundOnOverload then
				PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
			end
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312769, 312416) then		-- Энергетический удар
		timerFusionPunchActive:Start(args.destName)
	elseif args:IsSpellID(312424, 312777) then	-- Руна смерти - move away from it
		if args:IsPlayer() then
			specwarnRuneofDeath:Show()
			specwarnRuneofDeath:Play("runaway")
			if self.Options.PlaySoundDeathRune then
				PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
			end
		end
	elseif args:IsSpellID(312774, 312775, 312421, 312422) and not args:IsDestTypePlayer() then		-- Рунический щит
		timerShieldofRunes:Start()
		specWarnRuneofShields:Show(args.destName)
		specWarnRuneofShields:Play("dispelboss")
	elseif args:IsSpellID(312771, 312772, 312418, 312419) then	-- Переполняющая энергия
		warnOverwhelmingPower:Show(args.destName)
		if mod:IsDifficulty("heroic10") then
			timerOverwhelmingPower:Start(60, args.destName)
		else
			timerOverwhelmingPower:Start(35, args.destName)
		end

		if self.Options.SetIconOnOverwhelmingPower then
			if mod:IsDifficulty("heroic10") then
				self:SetIcon(args.destName, 8, 60) -- skull for 60 seconds (until meltdown)
			else
				self:SetIcon(args.destName, 8, 35) -- skull for 35 seconds (until meltdown)
			end
		end
	elseif args:IsSpellID(312786, 312785, 312432, 312433) then	-- Светящиеся придатки
		timerLightningTendrils:Start()
		specwarnLightningTendrils:Show()
		specwarnLightningTendrils:Play("justrun")
		if self.Options.PlaySoundLightningTendrils then
			PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
		end
	elseif args:IsSpellID(312770, 312417) then	-- Static Disruption (Hard Mode)
		disruptTargets[#disruptTargets + 1] = args.destName
		if self.Options.SetIconOnStaticDisruption and self.vb.disruptIcon > 0 then
			self:SetIcon(args.destName, self.vb.disruptIcon, 20)
			self.vb.disruptIcon = self.vb.disruptIcon - 1
		end
		self:Unschedule(warnStaticDisruptionTargets)
		self:Schedule(0.3, warnStaticDisruptionTargets)
	elseif args:IsSpellID(63483, 61915) then	-- LightningWhirl
		timerLightningWhirl:Start()
		if self:CheckInterruptFilter(args.destGUID, false, true) then
			specWarnLightningWhirl:Show(args.destName)
			specWarnLightningWhirl:Play("kickcast")
		end
	end
end