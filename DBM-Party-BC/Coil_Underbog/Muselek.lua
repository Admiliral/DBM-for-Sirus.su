local mod	= DBM:NewMod("Muselek", "DBM-Party-BC", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(17826)
mod:SetZone()

mod:RegisterCombat("combat", 17826)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS"
)


function mod:OnCombatStart(delay)

end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(34290) then
	end
end

