local mod	= DBM:NewMod("Leotheras", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))

mod:SetCreatureID(21215)
mod:RegisterCombat("combat", 21215)
mod:SetUsedIcons(4, 5, 6, 7, 8)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
    "SPELL_AURA_REMOVED"
)

-- local warnDemonSoon         = mod:NewAnnounce("WarnDemonSoon", 3, "Interface\\Icons\\Spell_Shadow_Metamorphosis")
-- local warnNormalSoon        = mod:NewAnnounce("WarnNormalSoon", 3, "Interface\\Icons\\INV_Weapon_ShortBlade_07")
local warnDemons            = mod:NewTargetAnnounce(37676, 4)

local specWarnDemon         = mod:NewSpecialWarningYou(37676)

local timerDemon            = mod:NewTimer(45, "TimerDemon", "Interface\\Icons\\Spell_Shadow_Metamorphosis")
local timerNormal           = mod:NewTimer(60, "TimerNormal", "Interface\\Icons\\INV_Weapon_ShortBlade_07")
local timerInnerDemons      = mod:NewTimer(32.5, "TimerInnerDemons", 11446)
local timerWhirlwind        = mod:NewCastTimer(12, 37640)
local timerWhirlwindCD      = mod:NewCDTimer(19, 37640)

local berserkTimer          = mod:NewBerserkTimer(600)

mod:AddBoolOption("SetIconOnDemonTargets", true)

local demonTargets = {}

function mod:WarnDemons()
    warnDemons:Show(table.concat(demonTargets, "<, >"))
    if self.Options.SetIconOnDemonTargets then
        table.sort(demonTargets, function(v1,v2) return DBM:GetRaidSubgroup(v1) < DBM:GetRaidSubgroup(v2) end)
        local k = 8
        for i, v in ipairs(demonTargets) do
            self:SetIcon(v, k)
            k = k - 1
        end
    end
    table.wipe(demonTargets)
end

function mod:OnCombatStart()
	DBM:FireCustomEvent("DBM_EncounterStart", 21215, "Leotheras the Blind")
    table.wipe(demonTargets)
    berserkTimer:Start()
    timerDemon:Start(60)
    timerWhirlwindCD:Start(18)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 21215, "Leotheras the Blind", wipe)
end

function mod:SPELL_AURA_APPLIED(args)
    if args:IsSpellID(37640) then
        timerWhirlwind:Start()
        timerWhirlwindCD:Schedule(12)
    elseif args:IsSpellID(37676) then
        demonTargets[#demonTargets + 1] = args.destName
        if args:IsPlayer() then
            specWarnDemon:Show()
        end
        self:UnscheduleMethod("WarnDemons")
        self:ScheduleMethod(0.1, "WarnDemons")
    end
end

function mod:SPELL_AURA_REMOVED(args)
    if args:IsSpellID(37676) then
        self:SetIcon(args.destName, 0)
    end
end

function mod:SPELL_CAST_START(args)
    if args:IsSpellID(37676) then
        timerInnerDemons:Start()
    end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellDemon then
        timerDemon:Cancel()
        timerWhirlwindCD:Cancel()
        timerDemon:Schedule(60)
        timerWhirlwindCD:Schedule(60)
        timerNormal:Start()
    elseif msg == L.YellShadow then
        timerDemon:Cancel()
        timerNormal:Cancel()
        timerWhirlwindCD:Start(22.5)
    end
end
