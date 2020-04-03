local mod	= DBM:NewMod("Tidewalker", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))

mod:SetCreatureID(21213)
mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"SPELL_AURA_APPLIED"
)

local warnMurlocksSoon  = mod:NewAnnounce("WarnMurlocksSoon", 3, "Interface\\Icons\\INV_Misc_MonsterHead_02")
local warnGraves        = mod:NewTargetAnnounce(37850, 3)
local warnGlobes        = mod:NewAnnounce("WarnGlobes", 3)

local timerMurlocks     = mod:NewTimer(50, "TimerMurlocks", "Interface\\Icons\\INV_Misc_MonsterHead_02")
local timerGravesCD     = mod:NewCDTimer(30, 37850)

local berserkTimer      = mod:NewBerserkTimer(600)

local graveTargets = {}

function mod:AnnounceGraves()
    warnGraves:Show(table.concat(graveTargets, "<, >"))
    table.wipe(graveTargets)
end

function mod:OnCombatStart()
	DBM:FireCustomEvent("DBM_EncounterStart", 21213, "Morogrim Tidewalker")
    berserkTimer:Start()
    warnMurlocksSoon:Schedule(37)
    timerMurlocks:Start(42)
    timerGravesCD:Start()
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 21213, "Morogrim Tidewalker", wipe)
end

function mod:SPELL_AURA_APPLIED(args)
    if args:IsSpellID(37850, 38023, 38024, 38025, 38049) then
        graveTargets[#graveTargets + 1] = args.destName
    end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L.EmoteMurlocs then
        warnMurlocksSoon:Cancel()
        warnMurlocksSoon:Schedule(45)
        timerMurlocks:Start(50)
    elseif msg == L.EmoteGraves then
        timerGravesCD:Start()
        self:ScheduleMethod(0.2 , "AnnounceGraves")
    elseif msg == L.EmoteGlobes then
        warnGlobes:Show()
    end
end
