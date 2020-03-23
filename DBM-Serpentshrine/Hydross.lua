local mod	= DBM:NewMod("Hydross", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))

mod:SetCreatureID(21216)
mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
    "SPELL_CAST_SUCCESS",
	"CHAT_MSG_MONSTER_YELL"
)

local warnMarkOfHydross     = mod:NewAnnounce("WarnMarkOfHydross", 3, 38215)
local warnMarkOfCorruption  = mod:NewAnnounce("WarnMarkOfCorruption", 3, 38219)
local warnWaterTomb         = mod:NewTargetAnnounce(38235, 3)
local warnVileSludge        = mod:NewTargetAnnounce(38246, 3)

local specWarnThreatReset   = mod:NewSpecialWarning("SpecWarnThreatReset", not (mod:IsTank() or mod:IsHealer()))

local timerMarkOfHydross    = mod:NewTimer(15, "TimerMarkOfHydross", 38215)
local timerMarkOfCorruption = mod:NewTimer(15, "TimerMarkOfCorruption", 38219)

local berserkTimer          = mod:NewBerserkTimer(600)

function mod:OnCombatStart()
	DBM:FireCustomEvent("DBM_EncounterStart", 21216, "Hydross the Unstable")
    berserkTimer:Start()
    timerMarkOfHydross:Start("10")
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 21216, "Hydross the Unstable", wipe)
end

function mod:SPELL_CAST_SUCCESS(args)
    if args:IsSpellID(38215) then
        warnMarkOfHydross:Show("10")
        timerMarkOfHydross:Start("25")
    elseif args:IsSpellID(38216) then
        warnMarkOfHydross:Show("25")
        timerMarkOfHydross:Start("50")
    elseif args:IsSpellID(38217) then
        warnMarkOfHydross:Show("50")
        timerMarkOfHydross:Start("100")
    elseif args:IsSpellID(38218) then
        warnMarkOfHydross:Show("100")
        timerMarkOfHydross:Start("250")
    elseif args:IsSpellID(38231) then
        warnMarkOfHydross:Show("250")
        timerMarkOfHydross:Start("500")
    elseif args:IsSpellID(40584) then
        warnMarkOfHydross:Show("500")
        timerMarkOfHydross:Start("500")
    elseif args:IsSpellID(38219) then
        warnMarkOfCorruption:Show("10")
        timerMarkOfCorruption:Start("25")
    elseif args:IsSpellID(38220) then
        warnMarkOfCorruption:Show("25")
        timerMarkOfCorruption:Start("50")
    elseif args:IsSpellID(38221) then
        warnMarkOfCorruption:Show("50")
        timerMarkOfCorruption:Start("100")
    elseif args:IsSpellID(38222) then
        warnMarkOfCorruption:Show("100")
        timerMarkOfCorruption:Start("250")
    elseif args:IsSpellID(38230) then
        warnMarkOfCorruption:Show("250")
        timerMarkOfCorruption:Start("500")
    elseif args:IsSpellID(40583) then
        warnMarkOfCorruption:Show("500")
        timerMarkOfCorruption:Start("500")
    elseif args:IsSpellID(38235) then
        warnWaterTomb:Show(args.destName)
    elseif args:IsSpellID(38246) then
        warnVileSludge:Show(args.destName)
    end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellPoison then
        timerMarkOfHydross:Cancel()
        timerMarkOfCorruption:Start("10")
        specWarnThreatReset:Show()
    elseif msg == L.YellWater then
        timerMarkOfCorruption:Cancel()
        timerMarkOfHydross:Start("10")
        specWarnThreatReset:Show()
    end
end
