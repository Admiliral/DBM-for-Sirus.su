local mod	= DBM:NewMod("Curator", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))
mod:SetCreatureID(34438,34436,34437)
--mod:SetCreatureID(15691)
--mod:RegisterCombat("yell", L.DBM_CURA_YELL_PULL)
mod:RegisterCombat("combat",34437)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
    "SPELL_AURA_REMOVED",
    "SPELL_CAST_START",
    "SPELL_INTERRUPT"
)

-- local warnEvoSoon		= mod:NewPreWarnAnnounce(30254, 10, 2)
-- local warnEvo			= mod:NewSpellAnnounce(30254, 3)
-- local warnArcaneInfusion= mod:NewSpellAnnounce(30403, 3)
--
-- local timerEvo			= mod:NewBuffActiveTimer(20, 30254)
-- local timerNextEvo		= mod:NewNextTimer(115, 30254)
--
-- local berserkTimer		= mod:NewBerserkTimer(720)
--
-- mod:AddBoolOption("RangeFrame", true)
--
-- function mod:OnCombatStart(delay)
-- 	berserkTimer:Start(-delay)
-- 	timerNextEvo:Start(109-delay)
-- 	warnEvoSoon:Schedule(99-delay)
-- 	if self.Options.RangeFrame then
-- 		DBM.RangeCheck:Show(10)
-- 	end
-- end
--
-- function mod:OnCombatEnd()
-- 	if self.Options.RangeFrame then
-- 		DBM.RangeCheck:Hide()
-- 	end
-- end
--
-- function mod:SPELL_AURA_APPLIED(args)
-- 	if args:IsSpellID(30403) then
-- 		warnArcaneInfusion:Show()
-- 	end
-- end
--
-- function mod:CHAT_MSG_MONSTER_YELL(msg)
-- 	if msg == L.DBM_CURA_YELL_OOM then
-- 		warnEvoSoon:Cancel()
-- 		warnEvo:Show()
-- 		timerNextEvo:Start()
-- 		timerEvo:Start()
-- 		warnEvoSoon:Schedule(95)
-- 	end
-- end

local timerAnnihilationCD        = mod:NewCDTimer(23, 305312)
local specWarnAnnihilationKick   = mod:NewSpecialWarning("Прерывание")
local timerCondCD                = mod:NewCDTimer(11, 305305)
local specWarnCond               = mod:NewSpecialWarningYou(305305)
local timerRunesCD               = mod:NewCDTimer(25, 305296)
local timerRunesBam              = mod:NewTimer(8, "TimerRunesBam", 305314)
local specWarnRunes              = mod:NewSpecialWarningRun(305296)
local warnUnstableTar            = mod:NewAnnounce("WarnUnstableTar", 3, 305309)

local unstableTargets = {}

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 34437, "The Curator")
    for i=1,3 do
        if UnitAura("boss".. i,"Деактивация", nil, "HARMFUL") == nil then
            if     i==3 then
                timerAnnihilationCD:Start()
                timerCondCD:Start()
            elseif i==1 then
                timerRunesCD:Start()
            end
        end
    end
    table.wipe(unstableTargets)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 34437, "The Curator", wipe)
	isinCombat = false
end

function mod:SPELL_AURA_REMOVED(args)
    if args:IsSpellID(305313) then
        for i=1,3 do
            if UnitAura("boss".. i,"Деактивация", nil, "HARMFUL") == nil then
                if     i==3 then
                    timerAnnihilationCD:Start()
                    timerCondCD:Start()
                elseif i==1 then
                    timerRunesCD:Start()
                end
            end
        end
    elseif args:IsSpellID(305309) then
        for i=1,10 do
            if UnitAura("raid".. i,"Нестабильная энергия") then
                unstableTargets[#unstableTargets + 1] =  UnitName("raid".. i)
            end
        end
        warnUnstableTar:Show(table.concat(unstableTargets, "<, >"))
        table.wipe(unstableTargets)
    end
end

function mod:SPELL_AURA_APPLIED(args)
    if args:IsSpellID(305305) then
        timerCondCD:Start()
        if args:IsPlayer() then
            specWarnCond:Show()
        end
    elseif args:IsSpellID(305309) then
        for i=1,10 do
            if UnitAura("raid".. i,"Нестабильная энергия") then
                unstableTargets[#unstableTargets + 1] =  UnitName("raid".. i)
            end
        end
        warnUnstableTar:Show(table.concat(unstableTargets, "<, >"))
        table.wipe(unstableTargets)
    end
end

function mod:SPELL_CAST_START(args)
    if args:IsSpellID(305296) then
        specWarnRunes:Show()
        timerRunesCD:Start()
        timerRunesBam:Start()
    elseif args:IsSpellID(305312) then
        timerAnnihilationCD:Start()
    end
end