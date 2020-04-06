local mod	= DBM:NewMod("Quagmirran", "DBM-Party-BC", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(17942)
mod:SetZone()

mod:RegisterCombat("combat", 17942)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS"
)

local timerAcidSpray	= mod:NewCDTimer(22, 38153)
local timerPoisonBolt	= mod:NewCDTimer(24, 39340)
local timerUppercut		= mod:NewCDTimer(22, 32055)

function mod:OnCombatStart(delay)
	timerAcidSpray:Start(25)
	timerPoisonBolt:Start(33)
	timerUppercut:Start(20)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(38153) and args.sourceName == L.name then
		timerAcidSpray:Start()
	elseif args:IsSpellID(39340) then
		timerPoisonBolt:Start()
	elseif args:IsSpellID(32055) then
		timerUppercut:Start()
	end
end
