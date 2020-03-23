local mod	= DBM:NewMod("Keli'dan", "DBM-Party-BC", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 183 $"):sub(12, -3))
mod:SetCreatureID(17377, 17653)--Might need work.

mod:RegisterCombat("combat", 17377)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED"
)