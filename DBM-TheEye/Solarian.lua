local mod	= DBM:NewMod("Solarian", "DBM-TheEye", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))

mod:SetCreatureID(18805)
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(2, 6, 7, 8)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_TARGET",
	"SPELL_DISPEL",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED"
)

--------------------------нормал--------------------------

local warnWrathN		= mod:NewTargetAnnounce(42783, 4)
local warnAddsSoon		= mod:NewAnnounce("WarnAddsSoon", 3, 55342)

local specWarnWrathN	= mod:NewSpecialWarningRun(42783)

local timerAdds			= mod:NewTimer(60, "TimerAdds", 55342)
local timerPriestsN		= mod:NewTimer(14, "TimerPriests", 47788)
local timerWrathN		= mod:NewTargetTimer(6, 42783)
local timerNextWrathN	= mod:NewCDTimer(21, 42783)

--------------------------героик--------------------------

local warnHeal			= mod:NewSoonAnnounce(308561, 3) -- Высшее исцеление
local warnRing			= mod:NewSoonAnnounce(308563, 3) -- ослепляющее кольцо
local warnStar			= mod:NewSoonAnnounce(308565, 3) -- Звездное пламя
local warnHelp			= mod:NewSoonAnnounce(308559, 3) -- Призыв помощников
local warnWrathH		= mod:NewSoonAnnounce(308550, 3) -- Гнев звездочета
local warnGates			= mod:NewSoonAnnounce(308545, 3) -- Врата бездны - активация

local specWarnHeal		= mod:NewSpecialWarningSpell(308561)  -- Хил
local specWarnGates		= mod:NewSpecialWarningSpell(308545)  -- Врата
local specWarnRing		= mod:NewSpecialWarningSpell(308562)  -- Кольцо
local specWarnStar		= mod:NewSpecialWarningSpell(308565)  -- Звездное пламя
local specWarnHelp		= mod:NewSpecialWarningSpell(308559)  -- Послушники
local specWarnWrathH	= mod:NewSpecialWarningRun(308548) -- Гнев

local timerNextHeal		= mod:NewTimer(15, "TimerNextHeal", 308561)
local timerNextGates	= mod:NewTimer(44, "TimerNextGates", 308545)
local timerNextRing		= mod:NewTimer(18, "TimerNextRing", 308563)
local timerNextStar		= mod:NewTimer(12, "TimerNextStar", 308565)
local timerNextHelp		= mod:NewTimer(40, "TimerNextHelp", 308558)
local timerWrathH		= mod:NewTargetTimer(6, 308548)
local timerNextWrathH	= mod:NewCDTimer(43, 308548)

local priestsN = true
local priestsH = true
local provid = true


function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 18805, "High Astromancer Solarian")
	if mod:IsDifficulty("heroic25") then
		timerNextHelp:Start()
	    timerNextGates:Start(25)
	    timerNextWrathH:Start()
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
		specWarnRing:Show()
		warnRing:Schedule(0)
	elseif args:IsSpellID(308558) then -- послушники
		timerNextHelp:Start(75)
		specWarnHelp:Show()
		warnHelp:Schedule(0)
		priestsH = true
		provid	 = true
	elseif args:IsSpellID(308545) then -- врата
		timerNextGates:Start()
		specWarnGates:Show()
		warnGates:Schedule(0)
	elseif args:IsSpellID(308561) then -- хил
		timerNextHeal:Start()
		specWarnHeal:Show()
		warnHeal:Schedule(0)
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

function mod:PriestHIcon() -- хм
	if DBM:GetRaidRank() >= 1 then
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid"..i.."target") == L.PriestH then
				priestsH = false
				SetRaidTarget("raid"..i.."target", 2)
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
				SetRaidTarget("raid"..i.."target", 6)
				break
			end
		end
	end
end

function mod:UNIT_TARGET()
	if priestsN or priestsH then
		self:PriestHIcon()
	elseif provid then
	    self:ProvidIcon()
	end
end
