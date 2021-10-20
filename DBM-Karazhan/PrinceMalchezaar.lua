local mod = DBM:NewMod("Prince", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210502220000")
mod:SetCreatureID(15690)
mod:RegisterCombat("combat", 15690)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"UNIT_HEALTH"
)

local warningNovaCast			= mod:NewCastAnnounce(30852, 3)
local timerNovaCD				= mod:NewCDTimer(12, 305425)
local timerFlameCD			    = mod:NewCDTimer(30, 305433)
local specWarnFlame			    = mod:NewSpecialWarningYou(305433)
local warnFlame                 = mod:NewTargetAnnounce(305433, 3)
local timerCurseCD			    = mod:NewCDTimer(30, 305435)

local timerIceSpikeCD			= mod:NewCDTimer(10, 305443)

local timerCallofDeadCD			= mod:NewCDTimer(10, 305447)
local warnCallofDead            = mod:NewTargetAnnounce(305447, 3)
local specWarnCallofDead	    = mod:NewSpecialWarningYou(305447)

local warnNextPhaseSoon         = mod:NewAnnounce("WarnNextPhaseSoon", 1)
local warnSound						= mod:NewSoundAnnounce()
mod.vb.phaseCounter = 1
local warnPorch              	= mod:NewTargetAnnounce(305429, 3)
local yellPorch					= mod:NewYell(305429, nil, nil, nil, "YELL")
local yellPorchFades			= mod:NewShortFadesYell(305429)

local flameTargets = {}
local PorchTargets = {}
mod.vb.PorchIcons = 8
mod:AddBoolOption("AnnouncePorch", false)

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 15690, "Prince Malchezaar")
	if mod:IsDifficulty("normal10") then
	elseif mod:IsDifficulty("heroic10") then
		self.vb.PorchIcons = 8
		timerCurseCD:Start(20)
		timerNovaCD:Start()
		self.vb.phaseCounter = 1
		table.wipe(flameTargets)
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 15690, "Prince Malchezaar", wipe)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(305425) then
		warningNovaCast:Show()
		timerNovaCD:Start()
	elseif args:IsSpellID(305443) then
		timerIceSpikeCD:Start()
	elseif args:IsSpellID(305447) then
		timerCallofDeadCD:Start()
		warnCallofDead:Show(args.destName)
		if args:IsPlayer() then
			specWarnCallofDead:Show()
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if args:IsSpellID(305433) then
		timerFlameCD:Start(self.vb.phaseCounter < 3 and 30 or 10)
		flameTargets[#flameTargets + 1] = args.destName
		if #flameTargets >=2 and self.vb.phaseCounter < 3 then
			warnFlame:Show(table.concat(flameTargets, "<, >"))
			table.wipe(flameTargets)
		elseif self.vb.phaseCounter >= 3 then
			warnFlame:Show(args.destName)
			table.wipe(flameTargets)
		end
		if args:IsPlayer() then
			specWarnFlame:Show()
			warnSound:Play("impruved")
		end
	elseif args:IsSpellID(305435) then
		timerCurseCD:Start(self.vb.phaseCounter == 2 and 30 or 20)
		if args:IsPlayer() then
			warnSound:Play("bomb_p")
		end
	elseif args:IsSpellID(305429) then
		PorchTargets[#PorchTargets + 1] = args.destName
		self:ScheduleMethod(0.1, "SetPorchIcons")
		if args:IsPlayer() then
			yellPorch:Yell()
			yellPorchFades:Countdown(spellId)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
    if args:IsSpellID(305435) and args:IsPlayer() then
        warnSound:Play("bomb_d")
	end
end


function mod:UNIT_HEALTH(uId)
	if self.vb.phaseCounter == 1 and self:GetUnitCreatureId(uId) == 15690 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.8 then
		self.vb.phaseCounter = self.vb.phaseCounter + 1
		warnNextPhaseSoon:Show("2")
		timerFlameCD:Start(20)
		timerCurseCD:Start(20)
	elseif self.vb.phaseCounter == 2 and self:GetUnitCreatureId(uId) == 15690 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.4 then
		self.vb.phaseCounter = self.vb.phaseCounter + 1
		warnNextPhaseSoon:Show(L.FlameWorld)
		timerCurseCD:Cancel()
		timerNovaCD:Cancel()
		timerFlameCD:Start(10)
	elseif self.vb.phaseCounter == 3 and self:GetUnitCreatureId(uId) == 15690 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.3 then
		self.vb.phaseCounter = self.vb.phaseCounter + 1
		warnNextPhaseSoon:Show(L.IceWorld)
		timerFlameCD:Cancel()
		timerIceSpikeCD:Start()
		timerCurseCD:Start(20)
	elseif self.vb.phaseCounter == 4 and self:GetUnitCreatureId(uId) == 15690 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.2 then
		self.vb.phaseCounter = self.vb.phaseCounter + 1
		warnNextPhaseSoon:Show(L.BlackForest)
		timerCurseCD:Cancel()
		timerIceSpikeCD:Cancel()
		timerCallofDeadCD:Start()
	elseif self.vb.phaseCounter == 5 and self:GetUnitCreatureId(uId) == 15690 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.1 then
		self.vb.phaseCounter = self.vb.phaseCounter + 1
		warnNextPhaseSoon:Show(L.LastPhase)
		timerCallofDeadCD:Cancel()
		timerFlameCD:Start()
	end

end


do
	local function sort_by_group(v1, v2)
		return DBM:GetRaidSubgroup(UnitName(v1)) < DBM:GetRaidSubgroup(UnitName(v2))
	end
	function mod:SetPorchIcons()
		table.sort(PorchTargets, sort_by_group)
		for i, v in ipairs(PorchTargets) do
			if mod.Options.AnnouncePorch then
				if DBM:GetRaidRank() > 0 then
					SendChatMessage(L.Porch:format(self.vb.PorchIcons, UnitName(v)), "RAID_WARNING")
				else
					SendChatMessage(L.Porch:format(self.vb.PorchIcons, UnitName(v)), "RAID")
				end
			end
			if self.Options.SetIconOnPorchTargets then
				self:SetIcon(UnitName(v), self.vb.PorchIcons, 10)
			end
			self.vb.PorchIcons = self.vb.PorchIcons - 1
		end
		if #PorchTargets <= 2 then
			warnPorch:Show(table.concat(PorchTargets, "<, >"))
			table.wipe(PorchTargets)
			self.vb.PorchIcons = 7
		end
	end
end

