local mod	= DBM:NewMod("ValkTwins", "DBM-Coliseum")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501151800")
mod:SetCreatureID(34497, 34496)
mod:SetMinCombatTime(30)
mod:SetUsedIcons(5, 6, 7, 8)

mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_INTERRUPT"
)

local warnSpecial					= mod:NewAnnounce("WarnSpecialSpellSoon", 3)
local warnTouchDebuff				= mod:NewAnnounce("WarningTouchDebuff", 2, 66823)
local warnPoweroftheTwins			= mod:NewAnnounce("WarningPoweroftheTwins2", 4, nil, "Healer")

local specWarnSpecial				= mod:NewSpecialWarning("SpecWarnSpecial")--Change Color, No voice ideas for this
local specWarnSwitch				= mod:NewSpecialWarning("SpecWarnSwitchTarget", nil, nil, nil, 1, 2)
local specWarnKickNow 				= mod:NewSpecialWarning("SpecWarnKickNow", "HasInterrupt", nil, 2, 1, 2)
local specWarnPoweroftheTwins		= mod:NewSpecialWarningDefensive(65916, "Tank", nil, 2, 1, 2)
local specWarnEmpoweredDarkness		= mod:NewSpecialWarningYou(65724)--No voice ideas for this
local specWarnEmpoweredLight		= mod:NewSpecialWarningYou(65748)--No voice ideas for this

local enrageTimer					= mod:NewBerserkTimer(360)
local timerSpecial					= mod:NewTimer(45, "TimerSpecialSpell", "132866", nil, nil, 6)
local timerHeal						= mod:NewCastTimer(15, 65875, nil, nil, nil, 4, nil, DBM_CORE_L.INTERRUPT_ICON)
local timerLightTouch				= mod:NewTargetTimer(20, 65950, nil, false, 2, 3)
local timerDarkTouch				= mod:NewTargetTimer(20, 66001, nil, false, 2, 3)
local timerAchieve					= mod:NewAchievementTimer(180, 3815)

mod:AddBoolOption("SpecialWarnOnDebuff", false, "announce")
mod:AddBoolOption("SetIconOnDebuffTarget", false)
mod:AddInfoFrameOption(235117, true)

local lightEssence, darkEssence = DBM:GetSpellInfo(65686), DBM:GetSpellInfo(65684)
local debuffTargets					= {}
mod.vb.debuffIcon					= 8

local shieldHealth = {
	["heroic25"] = 1200000,
	["heroic10"] = 300000,
	["normal25"] = 700000,
	["normal10"] = 175000
}

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 34497, "ValkTwins")
	timerSpecial:Start(-delay)
	warnSpecial:Schedule(40-delay)
	timerAchieve:Start(-delay)
	if self:IsDifficulty("heroic10", "heroic25") then
		enrageTimer:Start(360-delay)
	else
		enrageTimer:Start(480-delay)
	end
	self.vb.debuffIcon = 8
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 34497, "ValkTwins", wipe)
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(66046, 67206, 67207, 67208) then 			-- Light Vortex
		local debuff = DBM:UnitDebuff("player", lightEssence)
		self:SpecialAbility(debuff)
	elseif args:IsSpellID(66058, 67182, 67183, 67184) then		-- Dark Vortex
		local debuff = DBM:UnitDebuff("player", darkEssence)
		self:SpecialAbility(debuff)
	elseif args:IsSpellID(65875, 67303, 67304, 67305) then 		-- Twin's Pact
		timerHeal:Start()
		self:SpecialAbility(true)
		if self:GetUnitCreatureId("target") == 34497 then
			specWarnSwitch:Show()
			specWarnSwitch:Play("changetarget")
		end
	elseif args:IsSpellID(65876, 67306, 67307, 67308) then		-- Light Pact
		timerHeal:Start()
		self:SpecialAbility(true)
		if self:GetUnitCreatureId("target") == 34496 then	-- if darkbane, then switch to lightbane
			specWarnSwitch:Show()
			specWarnSwitch:Play("changetarget")
		end
	end
end

function mod:SpecialAbility(debuff)
	if not debuff then
		specWarnSpecial:Show()
	end
	timerSpecial:Start()
	warnSpecial:Schedule(40)
end

local function resetDebuff(self)
	self.vb.debuffIcon = 8
end

function mod:warnDebuff()
	warnTouchDebuff:Show(table.concat(debuffTargets, "<, >"))
	table.wipe(debuffTargets)
	self:Unschedule(resetDebuff)
	self:Schedule(5, resetDebuff, self)
end

local function showPowerWarning(self, cid)
	local target = self:GetBossTarget(cid)
	if not target then return end
	if target == UnitName("player") then
		specWarnPoweroftheTwins:Show()
	else
		warnPoweroftheTwins:Show(target)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsPlayer() and args:IsSpellID(65724, 67213, 67214, 67215) then 		-- Empowered Darkness
		specWarnEmpoweredDarkness:Show()
	elseif args:IsPlayer() and args:IsSpellID(65748, 67216, 67217, 67218) then	-- Empowered Light
		specWarnEmpoweredLight:Show()
	elseif args:IsSpellID(65950, 67296, 67297, 67298) then	-- Touch of Light
		if args:IsPlayer() and self.Options.SpecialWarnOnDebuff then
			specWarnSpecial:Show()
		end
		timerLightTouch:Start(args.destName)
		if self.Options.SetIconOnDebuffTarget then
			self:SetIcon(args.destName, self.vb.debuffIcon, 15)
		end
		self.vb.debuffIcon = self.vb.debuffIcon - 1
		debuffTargets[#debuffTargets + 1] = args.destName
		self:UnscheduleMethod("warnDebuff")
		self:ScheduleMethod(0.9, "warnDebuff")
	elseif args:IsSpellID(66001, 67281, 67282, 67283) then	-- Touch of Darkness
		if args:IsPlayer() and self.Options.SpecialWarnOnDebuff then
			specWarnSpecial:Show()
		end
		timerDarkTouch:Start(args.destName)
		if self.Options.SetIconOnDebuffTarget then
			self:SetIcon(args.destName, self.vb.debuffIcon)
		end
		self.vb.debuffIcon = self.vb.debuffIcon - 1
		debuffTargets[#debuffTargets + 1] = args.destName
		self:UnscheduleMethod("warnDebuff")
		self:ScheduleMethod(0.75, "warnDebuff")
	elseif args:IsSpellID(67246, 65879, 65916, 67244) then	-- Power of the Twins
		self:Schedule(0.1, showPowerWarning, self, args:GetDestCreatureID())
	elseif args:IsSpellID(65874, 67256, 67257, 67258) then  -- Shield of Darkness/Lights
		DBM.InfoFrame:SetHeader(args.spellName)
		DBM.InfoFrame:Show(2, "enemyabsorb", nil, shieldHealth[(DBM:GetCurrentInstanceDifficulty())])--UnitGetTotalAbsorbs()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(65874, 67256, 67257, 67258) then			-- Shield of Darkness
		specWarnKickNow:Show()
		specWarnKickNow:Play("kickcast")
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	elseif args:IsSpellID(65950, 67296, 67297, 67298) then	-- Touch of Light
		timerLightTouch:Stop(args.destName)
		if self.Options.SetIconOnDebuffTarget then
			self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(66001, 67281, 67282, 67283) then	-- Touch of Darkness
		timerDarkTouch:Start(args.destName)
		if self.Options.SetIconOnDebuffTarget then
			self:SetIcon(args.destName, 0)
		end
	end
end

function mod:SPELL_INTERRUPT(args)
	if type(args.extraSpellId) == "number" and (args.extraSpellId == 65875 or args.extraSpellId == 67303 or args.extraSpellId == 67304 or args.extraSpellId == 67305 or args.extraSpellId == 65876 or args.extraSpellId == 67306 or args.extraSpellId == 67307 or args.extraSpellId == 67308) then
		timerHeal:Cancel()
	end
end