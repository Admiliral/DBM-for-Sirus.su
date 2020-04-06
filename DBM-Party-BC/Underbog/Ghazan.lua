local mod	= DBM:NewMod("Ghazan", "DBM-Party-BC", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(18105)
mod:SetZone()

mod:RegisterCombat("combat", 18105)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS"
)

local timerSpitCD		= mod:NewCDTimer(8, 34290)
local timerBreathCD		= mod:NewCDTimer(6, 34268)
local timerSwipeCD		= mod:NewCDTimer(10, 38737)

function mod:OnCombatStart(delay)
	timerBreathCD:Start(2)
	timerSwipeCD:Start()
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(34290) then
		timerSpitCD:Start()
	elseif args:IsSpellID(34268) then
		timerBreathCD:Start()
	elseif args:IsSpellID(38737) then
		timerSwipeCD:Start()
	end
end

