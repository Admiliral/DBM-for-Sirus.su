local mod	= DBM:NewMod("Watchkeeper", "DBM-Party-BC", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(17306)
mod:SetZone()

mod:RegisterCombat("combat", 17306)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED"
)

local timerWound		= mod:NewTimer(10, "TimerWound",  36814)
local timerChargeCD		= mod:NewCDTimer(7, 34645)

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(36814) then
		timerWound:Start("5%")
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args:IsSpellID(36814) then
		timerWound:Start(args.amount*5 .. "%")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(34645) then
		timerChargeCD:Start()
	end
end
