local mod	= DBM:NewMod("TrashMobs", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))

mod:SetCreatureID(21251)
mod:RegisterCombat("combat", 21251)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"UNIT_DIED",
	"UNIT_TARGET",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_LOOT"
)


-- 90021