local mod = DBM:NewMod("Magtheridon", "DBM-Magtheridon");
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 183 $"):sub(12, -3))
mod:SetCreatureID(17257)

mod:RegisterCombat("combat", 17257)
mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"UNIT_HEALTH"
)

local warningNovaCast               = mod:NewCastAnnounce(305129, 10)
local warnHandOfMagt			    = mod:NewAnnounce("WarnHandOfMagt", 1)
local warnDevastatingStrike		    = mod:NewSpellAnnounce(305134, 3, nil, "Tank|Healer")
local warnPhase2soon			    = mod:NewAnnounce("WarnPhase2soon", 1)

local specWarnNova                  = mod:NewSpecialWarningRun(305129, nil, nil, nil, 1, 2)
local specWarnHandOfMagt            = mod:NewSpecialWarning("WarnHandOfMagt", nil, nil, nil, 1, 2)
local specWarnDevastatingStrike	    = mod:NewSpecialWarningTarget(305134, "Tank", nil, nil, nil, 1, 2)

local timerNovaNormalCD             = mod:NewCDTimer(70, 306166, nil, nil, nil, 3) -- Обычка
local timerNovaCD                   = mod:NewCDTimer(80, 3051296, nil, nil, nil, 3)
local timerHandOfMagtCD             = mod:NewCDTimer(20, 3051316, nil, nil, nil, 3)
local timerDevastatingStrikeCD		= mod:NewCDTimer(30, 305134, nil, "Tank|Healer", nil, 1)
local timerShatteredArmor           = mod:NewTargetTimer(15, 305135, nil, "Tank|Healer", nil, 1)
local timerPull				        = mod:NewTimer(112, "Pull", 305131, nil, nil, 6)

local pullWarned = true
local warned_P2 = false

mod:AddBoolOption("WarnPhase2soon",true)

local handTargets = {}
local targetShattered

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 17257, "Magtheridon")
	if mod:IsDifficulty("heroic25") or mod:IsDifficulty("heroic10") then
		timerNovaCD:Start()
		timerHandOfMagtCD:Start()
		timerDevastatingStrikeCD:Start()
	elseif mod:IsDifficulty("normal25") or mod:IsDifficulty("normal10") then
		timerNovaNormalCD:Start()
	end
	warned_P2 = false
	pullWarned = true
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 17257, "Magtheridon", wipe)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(305158, 305159, 305160) then
		warningNovaCast:Show()
		timerNovaCD:Start()
		specWarnNova:Show(args.sourceName)
		timerDevastatingStrikeCD:Start()
	elseif args:IsSpellID(305134) then
		targetShattered = self:GetBossTarget(17257)
		warnDevastatingStrike:Show(targetShattered)
		specwarnDevastatingStrike:Show(targetShattered)
		timerDevastatingStrikeCD:Start()
	elseif args:IsSpellID(30616) then
		specWarnNova:Show(args.sourceName)
		timerNovaNormalCD:Start()
	elseif args:IsSpellID(30510) then
		if pullWarned then
			timerPull:Start()
			pullWarned = false
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(305166) then
		handTargets[#handTargets + 1] = args.destName
		if #handTargets >= 3 then
			warnHandOfMagt:Show(table.concat(handTargets, ">, <"))
			table.wipe(handTargets)
		end
		timerHandOfMagtCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(305131) and args:IsPlayer() then
		specWarnHandOfMagt:Show()
	elseif args:IsSpellID(305135) then
		timerShatteredArmor:Start(args.destName)
	end
end

function mod:UNIT_HEALTH(uId)
	if not warned_P2 and self:GetUnitCreatureId(uId) == 17257 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.53 and mod:IsDifficulty("heroic25") and self.Options.WarnPhase2soon then
		warned_P2 = true
		warnPhase2soon:Show()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellPhase2 then
		timerNovaNormalCD:Start()
	end
end