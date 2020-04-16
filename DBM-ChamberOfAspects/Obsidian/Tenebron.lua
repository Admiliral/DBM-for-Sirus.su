local mod	= DBM:NewMod("Tenebron", "DBM-ChamberOfAspects", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200405141240")
mod:SetCreatureID(30452)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEvents(
    "SPELL_CAST_SUCCESS"
)
mod.onlyNormal = true

local warnShadowFissure		= mod:NewSpellAnnounce(59127, nil, nil, nil, nil, nil, 2)
local timerShadowFissure	= mod:NewCastTimer(5, 59128, nil, nil, nil, 3) --Cast timer until Void Blast. it's what happens when shadow fissure explodes.

function mod:SPELL_CAST_SUCCESS(args)
    if args:IsSpellID(57579, 59127) and self:IsInCombat() then
        warnShadowFissure:Show()
        timerShadowFissure:Start()
    end
end