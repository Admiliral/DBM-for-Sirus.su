local mod	= DBM:NewMod("Omor", "DBM-Party-BC", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(17308)
mod:SetUsedIcons(6, 7, 8)
mod:SetZone()

mod:RegisterCombat("combat", 17308)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_START"
)

local timerTreach			= mod:NewTargetTimer(15, 37566)
local specWarnKickTreach	= mod:NewSpecialWarningInterrupt(37566)
local specWarnTreach		= mod:NewSpecialWarningYou(37566)
local timerWall				= mod:NewTargetTimer(10, 31901)
local iconsTreach = 8

function mod:OnCombatStart(delay)
	iconsTreach = 8
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(37566) then
		timerTreach:Start(args.destName)
		specWarnTreach:Show()
		self:SetIcon(args.destName, iconsTreach, 15)
		iconsTreach = iconsTreach - 1
		if iconsTreach < 6 then iconsTreach = 8 end
	elseif args:IsSpellID(31901) then
		timerWall:Show(L.name)
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(37566) then
		specWarnKickTreach:Show(args.sourceName)
	end
end
