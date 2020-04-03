local mod	= DBM:NewMod("VoidReaver", "DBM-TheEye")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))

mod:SetCreatureID(19516)
mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
    "SPELL_CAST_SUCCESS"
)

local timerNextPounding     = mod:NewCDTimer(14, 34162)
local timerNextKnockback    = mod:NewCDTimer(30, 25778)

local berserkTimer          = mod:NewBerserkTimer(600)


function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 19516, "Void Reaver")
    berserkTimer:Start()
    timerNextPounding:Start()
    timerNextKnockback:Start()
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 19516, "Void Reaver", wipe)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(25778) then
        timerNextKnockback:Start()
    elseif args:IsSpellID(34162) then
        timerNextPounding:Start()
    end
end
