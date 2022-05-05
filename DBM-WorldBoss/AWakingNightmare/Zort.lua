local mod	= DBM:NewMod("Zort", "DBM-WorldBoss", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("20210501000000"):sub(12, -3))
mod:SetCreatureID(50702)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
    "SPELL_AURA_APPLIED_DOSE",
	"UNIT_TARGET",
    "SPELL_DAMAGE",
    "SPELL_PERIODIC_DAMAGE",
	"SPELL_AURA_REMOVED",
	"SPELL_INTERRUPT",
    "UNIT_HEALTH",
	"SWING_DAMAGE"
)


------------------------------------------ https://www.youtube.com/watch?v=dQw4w9WgXcQ ----------------------------------------------------