local mod	= DBM:NewMod("Mennu", "DBM-Party-BC", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(17941)
mod:SetZone()

mod:RegisterCombat("combat", 17941)

mod:RegisterEvents(
	"SPELL_DAMAGE",
	"SPELL_CAST_SUCCESS"
)

local timerLightning	= mod:NewCDTimer(7, 35010)
local timerTotem		= mod:NewCDTimer(10, 31985)

function mod:OnCombatStart(delay)
	timerLightning:Start(8)
	timerTotem:Start(20)
end

function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(35010) and args.sourceName == L.name then
		timerLightning:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(31981, 31983, 31985, 34980, 31991) and args.sourceName == L.name then
		timerTotem:Start()
	end
end
