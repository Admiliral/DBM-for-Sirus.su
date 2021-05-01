local mod	= DBM:NewMod("GunshipBattle", "DBM-Icecrown", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200405141240")
local addsIcon
if UnitFactionGroup("player") == "Alliance" then
	mod:RegisterCombat("yell", L.PullAlliance)
	mod:RegisterKill("yell", L.KillAlliance)
	mod:SetCreatureID(37187)	-- Orgrim's Hammer
	addsIcon = 23334
else
	mod:RegisterCombat("yell", L.PullHorde)
	mod:RegisterKill("yell", L.KillHorde)
	mod:SetCreatureID(37200)	-- The Skybreaker
	addsIcon = 23336
end
mod:SetMinCombatTime(50)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_START",
	"CHAT_MSG_MONSTER_YELL"
)

local warnBelowZero			= mod:NewSpellAnnounce(69705, 4)
local warnExperienced		= mod:NewTargetAnnounce(71188, 1, nil, false)		-- might be spammy
local warnVeteran			= mod:NewTargetAnnounce(71193, 2, nil, false)		-- might be spammy
local warnElite				= mod:NewTargetAnnounce(71195, 3, nil, false)		-- might be spammy
local warnBattleFury		= mod:NewStackAnnounce(72306, 2, nil, "Tank|Healer", 2)
local warnBladestorm		= mod:NewSpellAnnounce(69652, 3, nil, "Melee")
local warnWoundingStrike	= mod:NewTargetAnnounce(69651, 2)
local warnAddsSoon			= mod:NewAnnounce("WarnAddsSoon", 2, addsIcon)

local timerCombatStart		= mod:NewCombatTimer(45)
local timerBelowZeroCD		= mod:NewNextTimer(35, 69705, nil, nil, nil, 5)
local timerBattleFuryActive	= mod:NewBuffFadesTimer(17, 72306, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerAdds				= mod:NewTimer(60, "TimerAdds", addsIcon, nil, nil, 1)

mod:RemoveOption("HealthFrame")

function mod:Adds()
	timerAdds:Start()
	warnAddsSoon:Cancel()
	warnAddsSoon:Schedule(55)
	self:UnscheduleMethod("Adds")
	self:ScheduleMethod(60, "Adds")
end

function mod:OnCombatStart(delay)
	DBM.BossHealth:Clear()
	timerCombatStart:Start(-delay)
	if UnitFactionGroup("player") == "Alliance" then
		DBM:FireCustomEvent("DBM_EncounterStart", 37215, "Icecrown Gunship Battle")
		timerAdds:Start(62-delay)
		warnAddsSoon:Schedule(57)
		self:ScheduleMethod(62, "Adds")
		timerBelowZeroCD:Start(85-delay)
	else
		DBM:FireCustomEvent("DBM_EncounterStart", 37540, "Icecrown Gunship Battle")
		if mod:IsDifficulty("heroic10", "normal10") then
			timerBelowZeroCD:Start(85-delay)
		else
			timerBelowZeroCD:Start(80-delay)
		end
		timerAdds:Start(57-delay)
		warnAddsSoon:Schedule(52)
		self:ScheduleMethod(57, "Adds")
	end
end


function mod:OnCombatEnd(wipe)
	if UnitFactionGroup("player") == "Alliance" then
		DBM:FireCustomEvent("DBM_EncounterEnd", 37215, "Icecrown Gunship Battle", wipe)
	else
		DBM:FireCustomEvent("DBM_EncounterEnd", 37540, "Icecrown Gunship Battle", wipe)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(71195) then
		warnElite:Show(args.destName)
	elseif args:IsSpellID(71193) then
		warnVeteran:Show(args.destName)
	elseif args:IsSpellID(71188) then
		warnExperienced:Show(args.destName)
	elseif args:IsSpellID(69652) then
		warnBladestorm:Show()
	elseif args:IsSpellID(69651) then
		warnWoundingStrike:Show(args.destName)
	elseif args:IsSpellID(72306, 69638) and ((UnitFactionGroup("player") == "Alliance" and mod:GetCIDFromGUID(args.destGUID) == 36939) or (UnitFactionGroup("player") == "Horde" and mod:GetCIDFromGUID(args.destGUID) == 37200)) then
		timerBattleFuryActive:Start()		-- only a timer for 1st stack
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args:IsSpellID(72306, 69638) and ((UnitFactionGroup("player") == "Alliance" and mod:GetCIDFromGUID(args.destGUID) == 36939) or (UnitFactionGroup("player") == "Horde" and mod:GetCIDFromGUID(args.destGUID) == 37200)) then
		if args.amount % 10 == 0 or (args.amount >= 20 and args.amount % 5 == 0) then		-- warn every 10th stack and every 5th stack if more than 20
			warnBattleFury:Show(args.destName, args.amount or 1)
		end
		timerBattleFuryActive:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(69705) then
		timerBelowZeroCD:Start()
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(69705) then
		warnBelowZero:Show()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if ((msg == L.AddsAlliance or msg:find(L.AddsAlliance)) or (msg == L.AddsHorde or msg:find(L.AddsHorde))) and self:IsInCombat() then
		self:Adds()
	end
end
