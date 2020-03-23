local mod	= DBM:NewMod("Alar", "DBM-TheEye")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))

mod:SetCreatureID(19514)
mod:RegisterCombat("combat",19514)

mod:RegisterEvents(
    "SPELL_CAST_SUCCESS",
    "SPELL_CAST_START",
	"SPELL_AURA_APPLIED"
)

local warnPlatSoon         = mod:NewAnnounce("WarnPlatSoon", 3, 46599)
local warnFeatherSoon      = mod:NewSoonAnnounce(34229, 4)
local warnBombSoon         = mod:NewSoonAnnounce(35181, 3)
local warnBomb             = mod:NewTargetAnnounce(35181, 3)

local specWarnFeather      = mod:NewSpecialWarningSpell(34229, not mod:IsRanged())
local specWarnBomb         = mod:NewSpecialWarningYou(35181)
local specWarnPatch        = mod:NewSpecialWarningMove(35383)

local timerNextPlat        = mod:NewTimer(36, "TimerNextPlat", 46599)
local timerFeather         = mod:NewCastTimer(10, 34229)
local timerNextFeather     = mod:NewCDTimer(180, 34229)
local timerNextCharge      = mod:NewCDTimer(22, 35412)
local timerNextBomb        = mod:NewCDTimer(46, 35181)

local berserkTimer          = mod:NewBerserkTimer(1200)

function mod:Platform()
    timerNextPlat:Start()
    warnPlatSoon:Schedule(33)
    self:UnscheduleMethod("Platform")
    self:ScheduleMethod(36, "Platform")
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 19514, "Al'ar")
    berserkTimer:Start()
    timerNextPlat:Start(39)
    timerNextFeather:Start()
    warnPlatSoon:Schedule(36)
    warnFeatherSoon:Schedule(169)
    self:ScheduleMethod(39, "Platform")
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 19514, "Al'ar", wipe)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(34229) then
        timerFeather:Start()
        timerNextFeather:Start()
        timerNextPlat:Cancel()
        timerNextPlat:Schedule(10)
        self:UnscheduleMethod("Platform")
        self:ScheduleMethod(46, "Platform")
    elseif args:IsSpellID(35181) then
        warnBomb:Show(args.destName)
        timerNextBomb:Start()
        if args:IsPlayer() then
            specWarnBomb:Show()
        end
    end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(34342) then
        timerFeather:Cancel()
        timerNextFeather:Cancel()
        timerNextPlat:Cancel()
        self:UnscheduleMethod("Platform")
        warnPlatSoon:Cancel()
        warnFeatherSoon:Cancel()
        timerNextCharge:Start()
        timerNextBomb:Start()
        warnBombSoon:Schedule(43)
    end
end

function mod:SPELL_AURA_APPLIED(args)
    if args:IsSpellID(35383) and args:IsPlayer() then
        specWarnPatch:Show()
    end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
