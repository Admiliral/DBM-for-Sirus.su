local mod	= DBM:NewMod("Zluker", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))
mod:SetCreatureID(1)
mod:RegisterCombat("yell", L.YellZluker)

mod:RegisterEvents(
	"SPELL_CAST_START"
)

local timerMagicCD          = mod:NewCDTimer(45, 305535)

function mod:OnCombatStart(delay)
    timerMagicCD:Start()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(305535) then
        self:PlaySound("djeep")
        timerMagicCD:Start()
    end
end
