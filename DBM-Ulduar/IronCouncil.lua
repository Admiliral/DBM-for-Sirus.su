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
local warnChainlight			= mod:NewSpellAnnounce(312780, 1)
local timerOverload				= mod:NewCastTimer(6, 312782)
local timerLightningWhirl		= mod:NewCastTimer(5, 312784)
local specwarnLightningTendrils	= mod:NewSpecialWarningRun(312786)
local timerLightningTendrils	= mod:NewBuffActiveTimer(27, 312786)
local specwarnOverload			= mod:NewSpecialWarningRun(312782) 
local specwarnStaticDisruption		= mod:NewSpecialWarningMoveAway(312770)
mod:AddBoolOption("AlwaysWarnOnOverload", true, "announce")
mod:AddBoolOption("PlaySoundOnOverload", true)
mod:AddBoolOption("PlaySoundLightningTendrils", true)

-- Steelbreaker
-- High Voltage ... don't know what to show here - 63498
local warnFusionPunch			= mod:NewSpellAnnounce(312769, 4)
local timerFusionPunchCast		= mod:NewCastTimer(3, 312769)
local timerFusionPunchActive	= mod:NewTargetTimer(4,312769)
local warnOverwhelmingPower		= mod:NewTargetAnnounce(312772, 2)
local timerOverwhelmingPower	= mod:NewTargetTimer(25, 312772)
local warnStaticDisruption		= mod:NewTargetAnnounce(312770, 3) 
local timerStaticDisruption		= mod:NewTargetAnnounce(30, 312770) 
local specwarnFusionPunch       = mod:NewSpecialWarningDefensive(312769, mod:IsTank())
mod:AddBoolOption("SetIconOnOverwhelmingPower")
mod:AddBoolOption("SetIconOnStaticDisruption")

-- Runemaster Molgeim
-- Lightning Blast ... don't know, maybe 63491
local timerShieldofRunes		= mod:NewBuffActiveTimer(15, 312775)
local warnRuneofPower			= mod:NewTargetAnnounce(312776, 2) -- Руна мощи
local warnRuneofDeath			= mod:NewSpellAnnounce(312777, 2) -- Руна смерти
local warnShieldofRunes			= mod:NewSpellAnnounce(312774, 2) -- Руна щита
local warnRuneofSummoning		= mod:NewSpellAnnounce(312779, 3) --Руна призыва
local specwarnRuneofDeath		= mod:NewSpecialWarningMove(312777)
local timerRuneofDeathDura		= mod:NewNextTimer(30, 312777)
local timerRuneofPower			= mod:NewCDTimer(30, 312776)
local timerRuneofDeath			= mod:NewCDTimer(30, 312777)
local yellOverwhelmingPowerFades	= mod:NewFadesYell(312772)
local yellStaticDisruptionFades		= mod:NewFadesYell(312770)

mod:AddBoolOption("PlaySoundDeathRune", true, "announce")


local enrageTimer				= mod:NewBerserkTimer(900)

local disruptTargets = {}
local disruptIcon = 7

function mod:OnCombatStart(delay)
	enrageTimer:Start()
	table.wipe(disruptTargets)
	disruptIcon = 7
end

function mod:OnCombatEnd(wipe)
	DBM.RangeCheck:Hide()
end
function mod:RuneTarget()
	local targetname = self:GetBossTarget(32927)
	if not targetname then return end
		warnRuneofPower:Show(targetname)
end

local function warnStaticDisruptionTargets()
	warnStaticDisruption:Show(table.concat(disruptTargets, "<, >"))
	table.wipe(disruptTargets)
	disruptIcon = 7
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
		self:ScheduleMethod(0.1, "RuneTarget")
		timerRuneofPower:Start()
	elseif args:IsSpellID(312782, 312781,312428,312429) then	-- Перегрузка
		timerOverload:Start()
		if self.Options.AlwaysWarnOnOverload or UnitName("target") == L.StormcallerBrundir then
			specwarnOverload:Show()
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
			if self.Options.PlaySoundDeathRune then
				PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
			end
		end
	elseif args:IsSpellID(312774, 312775, 312421, 312422) and not args:IsDestTypePlayer() then		-- Рунический щит
		timerShieldofRunes:Start()		
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
		if self.Options.PlaySoundLightningTendrils then
			PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
		end
	elseif args:IsSpellID(312770, 312417) then	-- Static Disruption (Hard Mode)
		disruptTargets[#disruptTargets + 1] = args.destName
		if self.Options.SetIconOnStaticDisruption then 
			self:SetIcon(args.destName, disruptIcon, 20)
			disruptIcon = disruptIcon - 1
		end
		
		self:Unschedule(warnStaticDisruptionTargets)
		self:Schedule(0.3, warnStaticDisruptionTargets)
	end
end