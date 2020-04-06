local mod	= DBM:NewMod("Ikiss", "DBM-Party-BC", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(18473)
mod:SetZone()

mod:RegisterCombat("combat", 18473)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED"
)

local timerVolleyCD			= mod:NewCDTimer(11, 40424)
local timerExplosionCD		= mod:NewCDTimer(35, 40425)
local timerExplosion		= mod:NewTimer(6, "Explosion", 40425)
local specWarnSlow			= mod:NewSpecialWarningYou(35032)
local timerPolyCD			= mod:NewCDTimer(20, 43309)

function mod:OnCombatStart(delay)
	timerVolleyCD:Start(4)
	timerPolyCD:Start(7)
	timerExplosionCD:Start()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(43309) then
		timerPolyCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(40424) then
		timerVolleyCD:Start()
	elseif args:IsSpellID(38194) then
		timerExplosionCD:Start()
		timerExplosion:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(35032) and args:IsPlayer() then
		specWarnSlow:Show()
	end
end
