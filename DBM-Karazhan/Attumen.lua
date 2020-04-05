local mod	= DBM:NewMod("Attumen", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 183 $"):sub(12, -3))
mod:SetCreatureID(15550, 34972, 34972)
mod:RegisterCombat("combat", 34972)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
    "SPELL_AURA_REMOVED",
	"CHAT_MSG_MONSTER_YELL",
    "SPELL_CAST_START",
    "UNIT_HEALTH"
)

local warnPhase2			= mod:NewPhaseAnnounce(2)
local warnPhase3			= mod:NewPhaseAnnounce(3)
local warningCurseSoon		= mod:NewSoonAnnounce(43127, 2)
local warningCurse			= mod:NewSpellAnnounce(43127, 3)

local timerCurseCD			= mod:NewNextTimer(31, 43127)

local timerInvCD            = mod:NewCDTimer(21, 305251)
local timerChargeCD         = mod:NewCDTimer(11, 305258)
local timerSufferingCD      = mod:NewCDTimer(21, 305259)
local timerCharge2CD        = mod:NewCDTimer(15, 305263)
local timerTrampCD          = mod:NewCDTimer(15, 305264)
local warnPhase2Soon        = mod:NewAnnounce("WarnPhase2Soon", 1)

local Phase	= 1
local lastCurse = 0
local phaseCounter = true

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 34972, "Attumen the Huntsman")
	Phase = 1
    phaseCounter = true
    if mod:IsDifficulty("heroic10") then
        timerInvCD:Start(20)
    end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 34972, "Attumen the Huntsman", wipe)
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(43127, 29833) and GetTime() - lastCurse > 5 then
		warningCurse:Show()
		timerCurseCD:Show()
		warningCurseSoon:Cancel()
		if Phase == 2 then
			timerCurseCD:Start(41)
			warningCurseSoon:Schedule(36)
		else
			timerCurseCD:Start()
			warningCurseSoon:Schedule(26)
		end
		lastCurse = GetTime()
    elseif args:IsSpellID(305265) then
        timerChargeCD:Start()
        timerSufferingCD:Start()
        timerInvCD:Cancel()
        warnPhase2:Show()
    end
end

function mod:SPELL_AURA_REMOVED(args)
    if args:IsSpellID(305265) then
        timerCharge2CD:Start()
        timerTrampCD:Start(20)
        warnPhase3:Show()
    end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(305258) then
        timerChargeCD:Start()
    elseif args:IsSpellID(305251) then
        timerInvCD:Start()
    elseif args:IsSpellID(305263) then
        timerCharge2CD:Start()
    elseif args:IsSpellID(305259) then
        timerSufferingCD:Start()
    end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.DBM_ATH_YELL_1 then
		Phase = 2
		warnPhase2:Show()
		warningCurseSoon:Cancel()
		timerCurseCD:Start(25)
	end
end

function mod:UNIT_HEALTH(uId)
	if (self:GetUnitCreatureId(uId) == 15550 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.52 and phaseCounter) then
		phaseCounter = false
		warnPhase2Soon:Show()
    end
end
