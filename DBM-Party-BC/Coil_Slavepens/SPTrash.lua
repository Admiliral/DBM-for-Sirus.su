local mod	= DBM:NewMod("SPTrash", "DBM-Party-BC", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_SUCCESS"
)

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(32264) then
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(39382) then

	end
end
