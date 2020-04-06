local mod	= DBM:NewMod("Broggok", "DBM-Party-BC", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(17380)
mod:SetZone()

mod:RegisterCombat("yell", L.yellPull)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS"
)

local timerPoisonCloud	= mod:NewCDTimer(20, 30916)
local timerPoisonBolt	= mod:NewCDTimer(5, 38459)

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(30916) then
		timerPoisonCloud:Start()
	elseif args:IsSpellID(38459) then
		timerPoisonBolt:Start()
	end
end
