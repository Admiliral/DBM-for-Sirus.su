local mod	= DBM:NewMod("Hungarfen", "DBM-Party-BC", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(17770)
mod:SetZone()

mod:RegisterCombat("combat", 17770)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS"
)

local timerGayserCD		= mod:NewCDTimer(30, 38739)

function mod:OnCombatStart(delay)
	timerGayserCD:Start()
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(38739) then
		timerGayserCD:Start()
	end
end

