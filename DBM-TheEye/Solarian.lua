local mod	= DBM:NewMod("Solarian", "DBM-TheEye", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20201012213000")

mod:SetCreatureID(18805)
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(2, 6, 7, 8)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_TARGET",
	"SPELL_DISPEL",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SWING_DAMAGE"
)

--------------------------нормал--------------------------

local warnWrathN		= mod:NewTargetAnnounce(42783, 4)
local warnAddsSoon		= mod:NewAnnounce("WarnAddsSoon", 3, 55342)

local specWarnWrathN	= mod:NewSpecialWarningRun(42783, nil, nil, nil, 1, 2)

local timerAdds			= mod:NewTimer(60, "TimerAdds", 55342, "RemoveEnrage", nil, 5, nil, DBM_CORE_ENRAGE_ICON)
local timerPriestsN		= mod:NewTimer(14, "TimerPriests", 47788)
local timerWrathN		= mod:NewTargetTimer(6, 42783, nil, "RemoveEnrage", nil, 5, nil, DBM_CORE_ENRAGE_ICON, nil, 1, 5)
local timerNextWrathN	= mod:NewCDTimer(21, 42783, nil, "RemoveEnrage", nil, 5, nil, DBM_CORE_ENRAGE_ICON)

--------------------------героик--------------------------

local warnHeal			= mod:NewSoonAnnounce(308561, 3) -- Высшее исцеление
local warnRing			= mod:NewSoonAnnounce(308563, 3) -- ослепляющее кольцо
local warnStar			= mod:NewSoonAnnounce(308565, 3) -- Звездное пламя
local warnHelp			= mod:NewSoonAnnounce(308559, 3) -- Призыв помощников
local warnWrathH		= mod:NewTargetAnnounce(308550, 4) -- Гнев звездочета
local warnKol    		= mod:NewTargetAnnounce(308563, 2) -- Кольцо
local warnGates			= mod:NewSoonAnnounce(308545, 3) -- Врата бездны - активация
local warnPhase2Soon   		= mod:NewPrePhaseAnnounce(2)
local warnPhase2     		= mod:NewPhaseAnnounce(2)

local specWarnHeal		= mod:NewSpecialWarningInterrupt(308561, nil, nil, nil, 1, 2)  -- Хил
local specWarnGates		= mod:NewSpecialWarningSoak(308545, nil, nil, nil, 1, 2)  -- Врата
local specWarnHelp		= mod:NewSpecialWarningAdds(308559, nil, nil, nil, 1, 2)  -- Послушники
local specWarnRing		= mod:NewSpecialWarningLookAway(308562, nil, nil, nil, 2, 2)  -- Кольцо
local specWarnStar		= mod:NewSpecialWarningDispel(308565, nil, nil, nil, 1, 2)  -- Звездное пламя
local specWarnWrathH	= mod:NewSpecialWarningRun(308548, nil, nil, nil, 1, 2) -- Гнев
local specWarnDebaf  	= mod:NewSpecialWarningRun(308544, nil, nil, nil, 3, 4) -- Дебаф 1я фаза
local specWarnFlashVoid = mod:NewSpecialWarningLookAway(308585, nil, nil, nil, 2, 2) -- фир 2 фаза

local timerNextHeal		= mod:NewTimer(15, "TimerNextHeal", 308561, "RemoveEnrage", nil, 1, DBM_CORE_INTERRUPT_ICON)
local timerNextGates	= mod:NewTimer(40, "TimerNextGates", 308545, "Tank|Healer", nil, 3, DBM_CORE_TANK_ICON)
local timerNextRing		= mod:NewTimer(18, "TimerNextRing", 308563, "RemoveEnrage", nil, 3, DBM_CORE_HEROIC_ICON)
local timerNextStar		= mod:NewTimer(12, "TimerNextStar", 308565, "Healer", nil, 5, DBM_CORE_HEALER_ICON)
local timerNextHelp		= mod:NewTimer(40, "TimerNextHelp", 308558, "Tank|Healer", nil, 3, DBM_CORE_TANK_ICON)
local timerWrathH		= mod:NewTargetTimer(6, 308548, nil, "RemoveEnrage", nil, 1, nil, DBM_CORE_ENRAGE_ICON, nil, 1, 5)
local timerNextWrathH	= mod:NewCDTimer(43, 308548, nil, "RemoveEnrage", nil, 1, nil, DBM_CORE_ENRAGE_ICON)
local timerFlashVoid    = mod:NewCDTimer(75, 308585, nil, "RemoveEnrage", nil, 6, nil, DBM_CORE_HEROIC_ICON)

local priestsN = true
local priestsH = true
local provid = true
local KolTargets = {}
local warned_preP1 = false
local warned_preP2 = false

mod:AddBoolOption("Zrec")

mod.vb.phase = 0

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 18805, "High Astromancer Solarian")
	if mod:IsDifficulty("heroic25") then
		timerNextHelp:Start()
	    timerNextGates:Start(20)
	    timerNextWrathH:Start()
		self.vb.phase = 1
	else
	    timerAdds:Start()
		warnAddsSoon:Schedule(52)
	end
end


function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 18805, "High Astromancer Solarian", wipe)
end

--------------------------нормал--------------------------

function mod:PriestNIcon()  --об
	if DBM:GetRaidRank() >= 1 then
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid"..i.."target") == L.PriestN then
				priestsN = false
				SetRaidTarget("raid"..i.."target", 6)
				break
			end
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellAdds then
		timerPriestsN:Start()
		timerNextWrathN:Start()
	elseif msg == L.YellPriests  then
		priestsN = true
		timerAdds:Start()
		warnAddsSoon:Schedule(52)
	end
end

function mod:UNIT_TARGET()
	if priestsN then
		self:PriestNIcon()
	end
end

--------------------------героик--------------------------

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(308562) then -- кольцо
		timerNextRing:Start(18)
		specWarnRing:Show(args.sourceName)
		warnRing:Schedule(0)
	elseif args:IsSpellID(308558) then -- послушники
		timerNextHelp:Schedule(80)
		specWarnHelp:Show(args.sourceName)
		warnHelp:Schedule(80)
		priestsH = true
		provid	 = true
	elseif args:IsSpellID(308545) and self.vb.phase == 1 then -- врата
        timerNextGates:Start()
        specWarnGates:Show()
		warnGates:Schedule(0)
	elseif args:IsSpellID(308545) and self.vb.phase == 2 then -- врата
        timerNextGates:Start(30)
		warnGates:Schedule(0)
	elseif args:IsSpellID(308561) then -- хил
		timerNextHeal:Start()
		specWarnHeal:Show(args.sourceName)
		warnHeal:Schedule(0)
	elseif args:IsSpellID(308585) then -- УЖАС
		specWarnFlashVoid:Show(args.sourceName)
		timerFlashVoid:Schedule(5)
	elseif args:IsSpellID(308576) then
		self.vb.phase = 2
		timerFlashVoid:Start()
		timerNextGates:Cancel()
		timerNextGates:Start(15)
		warnPhase2:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(308565) then -- пламя
		specWarnStar:Show()
		timerNextStar:Start()
		warnStar:Schedule(0)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(308548) then    -- хм
		timerNextWrathH:Start()
		warnWrathH:Show(args.destName)
		timerWrathH:Start(args.destName)
		self:SetIcon(args.destName, 8, 6)
		if args:IsPlayer() then
			specWarnWrathH:Show()
		end
	elseif args:IsSpellID(308544) and self.vb.phase == 1 then -- Стаки луча
		if args:IsPlayer() then
			specWarnDebaf:Show()
		end
	elseif args:IsSpellID(308563) then -- Ослепление
		KolTargets[#KolTargets + 1] = args.destName
		self:UnscheduleMethod("Kolzo")
		self:ScheduleMethod(0.1, "Kolzo")
	elseif args:IsSpellID(42783) then   -- об
		timerNextWrathN:Start()
		warnWrathN:Show(args.destName)
		timerWrathN:Start(args.destName)
		self:SetIcon(args.destName, 8, 6)
		if args:IsPlayer() then
			specWarnWrathN:Show()
		end
	end
end

function mod:Kolzo()
	warnKol:Show(table.concat(KolTargets, "<, >"))
	table.wipe(KolTargets)
end

function mod:PriestHIcon() -- хм
	if DBM:GetRaidRank() >= 1 then
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid"..i.."target") == L.PriestH then
				priestsH = false
				SetRaidTarget("raid"..i.."target", 6)
				break
			end
		end
	end
end

function mod:ProvidIcon()
	if DBM:GetRaidRank() >= 1 then
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid"..i.."target") == L.Provid then
				provid = false
				SetRaidTarget("raid"..i.."target", 7)
				break
			end
		end
	end
end

function mod:UNIT_TARGET()
	if priestsH then
		self:PriestHIcon()
	elseif provid then
	    self:ProvidIcon()
	end
end

function mod:SWING_DAMAGE(args)
	if args:GetDestCreatureID() == 3410  and args:IsSrcTypePlayer() then
		if args.sourceName ~= UnitName("player") then
			if self.Options.Zrec then
				DBM.Arrow:ShowRunTo(args.sourceName, 0, 0)
			end
		end
	end
end

function mod:UNIT_HEALTH(uId)
	if self.vb.phase == 1 and not warned_preP1 and self:GetUnitCreatureId(uId) == 18805 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.37 then
		warned_preP1 = true
		warnPhase2Soon:Show()
	end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED