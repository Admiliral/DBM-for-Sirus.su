local mod	= DBM:NewMod("Attumen", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210502220000")
mod:SetCreatureID(15550, 34972, 34972)
mod:RegisterCombat("combat", 34972)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"UNIT_HEALTH"
)

------------------ОБ------------------

local warnPhase2			= mod:NewPhaseAnnounce(2)
local warnPhase3			= mod:NewPhaseAnnounce(3)
local warnPhase2Soon        = mod:NewPrePhaseAnnounce(2)

local warningCurseSoon		= mod:NewSoonAnnounce(43127, 2)
local warningCurse			= mod:NewSpellAnnounce(43127, 3)

local timerCurseCD			= mod:NewNextTimer(31, 43127, nil, nil, nil, 3)

------------------ХМ------------------

local specWarnMezair		= mod:NewSpecialWarningDodge(305258, nil, nil, nil, 2, 2)

local timerInvCD            = mod:NewCDTimer(21, 305251, nil, nil, nil, 3) -- Незримое присутствие
local timerChargeCD         = mod:NewCDTimer(11, 305258, nil, nil, nil, 2) -- Галоп фаза 2
local timerCharge2CD        = mod:NewCDTimer(15, 305263, nil, nil, nil, 2) -- Галоп фаза 3
local timerChargeCast       = mod:NewCastTimer(3, 305258, nil, nil, nil, 2) -- Галоп каст
local timerSufferingCD      = mod:NewCDTimer(21, 305259, nil, nil, nil, 3) -- Разделенные муки
local timerTrampCD          = mod:NewCDTimer(15, 305264, nil, nil, nil, 3) -- Могучий топот

local warnSound						= mod:NewSoundAnnounce()


mod.vb.phase = 0
mod.vb.lastCurse = 0
mod.vb.phaseCounter = true
mod.vb.cena = true

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 34972, "Attumen the Huntsman")
	self.vb.phase = 1
	self.vb.cena = true
	self.vb.phaseCounter = true
	if mod:IsDifficulty("heroic10") then
		timerInvCD:Start(20)
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 34972, "Attumen the Huntsman", wipe)
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(43127, 29833) and GetTime() - self.vb.lastCurse > 5 then -- Обычка
		warningCurse:Show()
		timerCurseCD:Show()
		warningCurseSoon:Cancel()
		if self.vb.phase == 2 then
			timerCurseCD:Start(41)
			warningCurseSoon:Schedule(36)
		else
			timerCurseCD:Start()
			warningCurseSoon:Schedule(26)
		end
		mod.vb.lastCurse = GetTime()
	elseif args:IsSpellID(305265) then -- ???????
		timerChargeCD:Start()
		timerSufferingCD:Start()
		timerInvCD:Cancel()
		warnPhase2:Show()
	end
end

function mod:SPELL_AURA_REMOVED(args) -- ???????
	if args:IsSpellID(305265) then
		timerCharge2CD:Start()
		timerTrampCD:Start(20)
		warnPhase3:Show()
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(305258) then -- галоп
		if self.vb.cena then
            warnSound:Play("jhoncena")
            self.vb.cena = false
        end
		timerChargeCD:Start()
		timerChargeCast:Start()
		specWarnMezair:Show()
	elseif args:IsSpellID(305263) then -- галоп2
		timerCharge2CD:Start()
		timerChargeCast:Start()
		specWarnMezair:Show()
		if self.vb.cena then
            warnSound:Play("jhoncena")
            self.vb.cena = false
        end
	elseif args:IsSpellID(305251) then -- незримое присутствие
		timerInvCD:Start()
	elseif args:IsSpellID(305259) then -- муки
		timerSufferingCD:Start()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.DBM_ATH_YELL_1 then -- 2 фаза
		self.vb.phase = 2
		warnPhase2:Show()
		warningCurseSoon:Cancel()
		timerCurseCD:Start(25)
	end
end

function mod:UNIT_HEALTH(uId)
	if (self:GetUnitCreatureId(uId) == 15550 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.52 and self.vb.phaseCounter) then -- фаза
		warnSound:Play("idisuda")
		self.vb.phaseCounter = false
		warnPhase2Soon:Show()
	end
end
