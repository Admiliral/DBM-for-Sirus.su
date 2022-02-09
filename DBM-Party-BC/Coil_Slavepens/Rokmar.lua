local mod	= DBM:NewMod("Rokmar", "DBM-Party-BC", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(17991)
mod:SetZone()

mod:RegisterCombat("combat", 17991)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED"
)

local timerWoundCD		= mod:NewCDTimer(10, 38801)
local timerSpitCD		= mod:NewCDTimer(14, 35008)
local specWarnWound		= mod:NewSpecialWarningTarget(38801, "Tank|Healer")
local specWarnSpit		= mod:NewSpecialWarningInterrupt(35008)

function mod:OnCombatStart(delay)
	timerSpitCD:Start()
	timerWoundCD:Start()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(35008) then
		timerSpitCD:Start()
		specWarnSpit:Show(args.sourceName)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(38801) then
		timerWoundCD:Start()
		specWarnWound:Show(args.destName)
	end
end

