local mod	= DBM:NewMod("Kelidan", "DBM-Party-BC", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(17377)
mod:SetZone()

mod:RegisterCombat("combat", 17377)

mod:RegisterEvents(
	"SPELL_AURA_REMOVED",
	"SPELL_AURA_APPLIED"
)

local timerCircleCD		= mod:NewCDTimer(28, 30940)
local timerExplosion	= mod:NewTimer(5, "Explosion", 37371)

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(30935) then
		timerCircleCD:Start(15)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(30940) then
		timerCircleCD:Start()
		timerExplosion:Start()
	end
end

