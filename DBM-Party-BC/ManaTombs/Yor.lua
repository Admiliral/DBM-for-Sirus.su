local mod	= DBM:NewMod("Yor", "DBM-Party-BC", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(22930)
mod:SetZone()

mod:RegisterCombat("combat", 22930)

mod:RegisterEvents(
	"SPELL_CAST_START"
)

local timerBreathCD = mod:NewCDTimer(7.5, 38361)

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(38361) then
		timerBreathCD:Start()
	end
end
