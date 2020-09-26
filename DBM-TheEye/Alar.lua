local mod	= DBM:NewMod("Alar", "DBM-TheEye", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))

mod:SetCreatureID(19514)
mod:RegisterCombat("combat", 19514)
mod:SetUsedIcons(3, 4, 5, 6, 7, 8)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"SPELL_DISPEL",
	"SPELL_SUMMON",
	"SPELL_DAMAGE",
	"UNIT_TARGET",
	"UNIT_HEALTH",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_RAID_BOSS_WHISPER",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"SWING_DAMAGE",
	"SWING_MISSED"
)

-- Normal
local warnPlatSoon				= mod:NewAnnounce("WarnPlatSoon", 3, 46599)
local warnFeatherSoon			= mod:NewSoonAnnounce(34229, 4)
local warnBombSoon				= mod:NewSoonAnnounce(35181, 3)
local warnBomb					= mod:NewTargetAnnounce(35181, 3)

--local specWarnFeather			= mod:NewSpecialWarningSpell(34229, not mod:IsRanged())
local specWarnBomb				= mod:NewSpecialWarningYou(35181)
local specWarnPatch				= mod:NewSpecialWarningMove(35383)

local timerNextPlat				= mod:NewTimer(33, "TimerNextPlat", 46599)
local timerFeather				= mod:NewCastTimer(10, 34229)
local timerNextFeather			= mod:NewCDTimer(180, 34229)
local timerNextCharge			= mod:NewCDTimer(22, 35412)
local timerNextBomb				= mod:NewCDTimer(46, 35181)

local berserkTimerN				= mod:NewBerserkTimer(1200)

-- Heroic
local warnNextPhase				= mod:NewAnnounce("Фаза", 1) -- перефаза
local warnFireSign			    = mod:NewAnnounce("WarnFireSign", 2) -- Знак огня
local warnPhoenixScream2		= mod:NewAnnounce("WarnPhoenixScream2", 2) -- Крик феникса
local warnPhoenixScream1		= mod:NewAnnounce("WarnPhoenixScream1", 2) -- Крик феникса
local warnPhoenixScream0		= mod:NewAnnounce("WarnPhoenixScream0", 2) -- Крик феникса
local warnSupernova				= mod:NewAnnounce("WarnSupernova", 2, 308636, false) -- предупреждение о стаках суперновой

local specWarnPhase2Soon		= mod:NewSpecialWarning("WarnPhase2Soon", 1) -- Вторая фаза
local specWarnPhase2			= mod:NewSpecialWarning("WarnPhase2", 1) -- Вторая фаза
local specWarnFlamefall			= mod:NewSpecialWarningSpell(308987, nil, nil, nil, 1, 2) -- Падение пламени
local specWarnAnimated			= mod:NewSpecialWarningSpell(308633, nil, nil, nil, 1, 2) -- Ожившее плямя
local specWarnFireSign			= mod:NewSpecialWarningSpell(308638, nil, nil, nil, 1, 2) -- Знак огня
local specWarnPhoenixScream     = mod:NewSpecialWarningSpell(308671, nil, nil, nil, 1, 2)  -- Крик феникса

--local specWarnSupernova		= mod:NewSpecialWarningStack(308636, nil, 3) -- Сверхновая
local specWarnFeather			= mod:NewSpecialWarning("SpecWarnFeather") -- Перо на вас
local specWarnFeatherNear		= mod:NewSpecialWarning("SpecWarnFeatherNear") -- Перо около вас

local timerAnimatedCD			= mod:NewCDTimer(70, 308633, nil, "Healer", nil, 5, nil, DBM_CORE_HEALER_ICON) -- Ожившее плямя
local timerFireSignCD			= mod:NewCDTimer(39, 308638, nil, "Healer", nil, 5, nil, DBM_CORE_HEALER_ICON) -- Знак огня
local timerFlamefallCD			= mod:NewCDTimer(31, 308987, nil, nil, nil, 1, nil, DBM_CORE_DEADLY_ICON) -- Перезарядка перьев
local timerPhoenixScreamCD		= mod:NewCDTimer(20, 308671, nil, nil, nil, 1, nil, DBM_CORE_HEROIC_ICON) -- Крик феникса
local timerSupernova			= mod:NewBuffActiveTimer(5, 308636, nil, nil, nil, 1, nil, DBM_CORE_DEADLY_ICON) -- таймер суперновой


local timerAnimatedCast			= mod:NewCastTimer(2, 308633, nil, nil, nil, 2) -- Ожившее плямя
local timerFireSignCast			= mod:NewCastTimer(1, 308638, nil, nil, nil, 2) -- Знак огня
local timerFlamefallCast		= mod:NewCastTimer(5, 308987, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON, nil, 1, 5) -- Каст перьев
local timerPhase2Cast			= mod:NewCastTimer(20, 308640, nil, nil, nil, 1, nil, DBM_CORE_DEADLY_ICON) -- Перефаза
-- 2 фаза --
local timerPhoenixScreamCast	= mod:NewCastTimer(2, 308671, nil, nil, nil, 6, nil, DBM_CORE_HEROIC_ICON) -- Крик феникса
local timerScatteringCast		= mod:NewCastTimer(20, 308663) -- Знак феникса: рассеяность
local timerWeaknessCast			= mod:NewCastTimer(20, 308664) -- Знак феникса: слабость
local timerFuryCast				= mod:NewCastTimer(20, 308665) -- Знак феникса: ярость
local timerFatigueCast			= mod:NewCastTimer(20, 308667) -- Знак феникса: усталость

local berserkTimerH				= mod:NewBerserkTimer(444)
local berserkTimerH2			= mod:NewBerserkTimer(500)


mod:AddBoolOption("FeatherIcon")
mod:AddBoolOption("YellOnFeather", true, "announce")
mod:AddBoolOption("FeatherArrow")

mod.vb.phase = 0

local warned_preP1 = false
local LKTank

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 19514, "Al'ar")

	self.vb.phase = 1
	if mod:IsDifficulty("heroic25") then
		timerAnimatedCD:Start()
		timerFireSignCD:Start()
		timerFlamefallCD:Start()
	    berserkTimerH:Start()
	    warned_preP1 = false
	else
		berserkTimerN:Start()
		timerNextPlat:Start(39)
		timerNextFeather:Start()
		warnPlatSoon:Schedule(36)
		warnFeatherSoon:Schedule(169)
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 19514, "Al'ar", wipe)
end

function mod:Platform()
	timerNextPlat:Start()
	warnPlatSoon:Schedule(33)
	self:UnscheduleMethod("Platform")
	self:ScheduleMethod(36, "Platform")
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
	elseif args:IsSpellID(308640) then  -- Phase 2
		timerPhase2Cast:Start()
		specWarnPhase2:Show()
		berserkTimerH:Cancel()
		berserkTimerH2:Start()
		self.vb.phase = 2
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
	elseif args:IsSpellID(46599) then -- Знак огня
		timerNextPlat:Start(33)
	elseif args:IsSpellID(308638) then -- Знак огня
		specWarnFireSign:Show()
		timerFireSignCD:Start()
		timerFireSignCast:Start()
	elseif args:IsSpellID(308987) then -- Падение пламени
		specWarnFlamefall:Show()
		timerFlamefallCD:Start()
	    timerFlamefallCast:Start()
	elseif args:IsSpellID(308633) then -- Ожившее плямя
		specWarnAnimated:Show()
		timerAnimatedCD:Start()
		timerAnimatedCast:Start()
	------- 2 фаза ---------
	elseif args:IsSpellID(308671) then -- Крик феникса
	    timerPhoenixScreamCast:Start()
		timerPhoenixScreamCD:Start()
		specWarnPhoenixScream:Show()
		warnPhoenixScream2:Schedule(0)
		warnPhoenixScream1:Schedule(1)
		warnPhoenixScream0:Schedule(2)
	elseif args:IsSpellID(308663) then -- Знак феникса: Рассеяность
		timerScatteringCast:Start()
	elseif args:IsSpellID(308664) then -- Знак феникса: Слабость
		timerWeaknessCast:Start()
	elseif args:IsSpellID(308665) then -- Знак феникса: Ярость
		timerFuryCast:Start()
	elseif args:IsSpellID(308667) then -- Знак феникса: Усталость
		timerFatigueCast:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(35383) and args:IsPlayer() then
		specWarnPatch:Show()
	elseif args:IsSpellID(308636) then	--Instability (casters)
		if args:IsPlayer() then
			warnSupernova:Show(args.amount or 1)
		end
		timerSupernova:Start()
	end
end

function mod:UNIT_HEALTH(uId)
	if not warned_preP1 and self:GetUnitCreatureId(uId) == 19514 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.07 then
		warned_preP1 = true
		specWarnPhase2Soon:Show()
	end
end

---------------------------перья--------------------





mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED