local mod = DBM:NewMod("Magtheridon", "DBM-Magtheridon");
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210130153000")

mod:SetCreatureID(17257)
mod:RegisterCombat("combat", 17257)
mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"UNIT_HEALTH"
)

local warningNovaCast               = mod:NewCastAnnounce(305129, 10) -- Вспышка скверны
local warnHandOfMagt			    = mod:NewSpellAnnounce(305131, 1) -- Печать
local warnDevastatingStrike		    = mod:NewSpellAnnounce(305134, 3, nil, "Tank|Healer") -- сокрушительный удар
local warnPhase2Soon   				= mod:NewPrePhaseAnnounce(2)
local warnPhase2     				= mod:NewPhaseAnnounce(2)

local specWarnNova                  = mod:NewSpecialWarningRun(305129, nil, nil, nil, 1, 2) -- Вспышка скверны
local specWarnHandOfMagt            = mod:NewSpecialWarningSpell(305131, nil, nil, nil, 1, 2) -- Печать
local specWarnDevastatingStrike	    = mod:NewSpecialWarningTarget(305134, "Tank", nil, nil, nil, 1, 2)


local timerNovaCD                   = mod:NewCDTimer(80, 305129, nil, nil, nil, 3) -- Кубы
local timerShakeCD                  = mod:NewCDTimer(50, 30572, nil, nil, nil, 3) -- Сотрясение
local timerShakeCast                = mod:NewCastTimer(50, 30572, nil, nil, nil, 3) -- Сотрясение
local timerHandOfMagtCD             = mod:NewCDTimer(20, 305131, nil, nil, nil, 3)
local timerDevastatingStrikeCD		= mod:NewCDTimer(30, 305134, nil, "Tank|Healer", nil, 1)
local timerShatteredArmor           = mod:NewTargetTimer(15, 305135, nil, "Tank|Healer", nil, 1)
local timerPull				        = mod:NewTimer(112, "Pull", 305131, nil, nil, 6) -- Пулл босса

local pullWarned = true
local warned_P1 = false
local warned_P2 = false
local cub = 1



local handTargets = {}
local targetShattered

mod.vb.phase = 0

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 17257, "Magtheridon")
	self.vb.phase = 1
	if mod:IsDifficulty("heroic25") or mod:IsDifficulty("heroic10") then
		timerNovaCD:Start()
		timerHandOfMagtCD:Start()
		timerDevastatingStrikeCD:Start()
	elseif mod:IsDifficulty("normal25") or mod:IsDifficulty("normal10") then
		timerNovaCD:Start(64)
	end
	cub = 2
	warned_P1 = false
	warned_P2 = false
	pullWarned = true
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 17257, "Magtheridon", wipe)
	cub = 1
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(305158, 305159, 305160) then
		warningNovaCast:Show()
		specWarnNova:Show(args.sourceName)
		timerDevastatingStrikeCD:Start()
		timerNovaCD:Start()
	elseif args:IsSpellID(305134) then
		targetShattered = self:GetBossTarget(17257)
		warnDevastatingStrike:Show(targetShattered)
		specWarnDevastatingStrike:Show(targetShattered)
		timerDevastatingStrikeCD:Start()
	elseif args:IsSpellID(30616) then
		specWarnNova:Show(args.sourceName)
		if cub == 2 then
			timerNovaCD:Start(76)
			cub = cub + 1
		elseif cub == 3 then
			timerNovaCD:Start(69)
			cub = cub + 1
		elseif cub == 4 then
			timerNovaCD:Start(70)
			cub = cub + 1
		end
	elseif args:IsSpellID(30510) then
		if pullWarned then
			timerPull:Start()
			pullWarned = false
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(30572) then
		timerShakeCD:Start()
		timerShakeCast:Start()
	elseif args:IsSpellID(305166) then
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
	if not warned_P1 and self:GetUnitCreatureId(uId) == 17257 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.53 and mod:IsDifficulty("heroic25") then
		warned_P1 = true
		warnPhase2Soon:Show()
	elseif not warned_P2 and self:GetUnitCreatureId(uId) == 17257 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.50 and mod:IsDifficulty("heroic25") then
		warned_P2 = true
		warnPhase2:Show()
		self.vb.phase = 2
	end
end

--[[function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellPhase2 then

	end
end]]