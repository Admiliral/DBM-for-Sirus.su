local mod	= DBM:NewMod("Soccothrates", "DBM-Party-BC", 10)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(20886)
mod:SetZone()

mod:RegisterCombat("combat", 20886)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"SPELL_CAST_START"
)

local timerChargeCD		= mod:NewCDTimer(11, 35769)
local timerFelfireCD	= mod:NewCDTimer(60, 39006)

function mod:OnCombatStart(delay)
	timerChargeCD:Start()
	timerFelfireCD:Start(35)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(39006) then
		timerFelfireCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(36512) then
		timerChargeCD:Start()
	end
end
