local mod	= DBM:NewMod("FlameLeviathan", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

mod:SetCreatureID(33113)

mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
	"SPELL_AURA_REMOVED",
	"SPELL_AURA_APPLIED",
	"SPELL_SUMMON"
)

local warnHodirsFury		= mod:NewTargetAnnounce(312705)
local pursueTargetWarn		= mod:NewAnnounce("PursueWarn", 2, 62374)
local warnNextPursueSoon	= mod:NewAnnounce("warnNextPursueSoon", 3, 62374)

local warnSystemOverload	= mod:NewSpecialWarningSpell(62475)
local pursueSpecWarn		= mod:NewSpecialWarning("SpecialPursueWarnYou", nil, nil, 2, 4)
local warnWardofLife		= mod:NewSpecialWarning("warnWardofLife")

local timerSystemOverload	= mod:NewBuffActiveTimer(20, 62475, nil, nil, nil, 6)
local timerFlameVents		= mod:NewCastTimer(10, 312689, nil, nil, nil, 2)
local timerPursued			= mod:NewTargetTimer(30, 62374, nil, nil, nil, 3)

--local soundPursued = mod:NewSound(62374)

local guids = {}
local function buildGuidTable(self)
	table.wipe(guids)
	for uId in DBM:GetGroupMembers() do
		local name, server = GetUnitName(uId, true)
		local fullName = name .. (server and server ~= "" and ("-" .. server) or "")
		guids[UnitGUID(uId.."pet") or "none"] = fullName
	end
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 33113, "FlameLeviathan")
	buildGuidTable(self)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33113, "FlameLeviathan", wipe)
end

function mod:OnTimerRecovery()
	buildGuidTable(self)
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(62907, 312355, 312363, 312708, 312716) and self:AntiSpam(4) then		-- Ward of Life spawned (Creature id: 34275)
		warnWardofLife:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312689, 312690, 312336, 62396) then		-- Flame Vents
		timerFlameVents:Start()
	elseif args:IsSpellID(312339, 312692, 62475) then	-- Systems Shutdown / Overload
		timerSystemOverload:Start()
		warnSystemOverload:Show()
	elseif args:IsSpellID(62374) then	-- Pursued
		local target = guids[args.destGUID]
		warnNextPursueSoon:Schedule(25)
		timerPursued:Start(target)
		pursueTargetWarn:Show(target)
		if target then
			pursueTargetWarn:Show(target)
			if target == UnitName("player") then
				pursueSpecWarn:Show()
			end
		end
	elseif args:IsSpellID(312352, 312705, 62297) then		-- Hodir's Fury (Person is frozen)
		local target = guids[args.destGUID]
		if target then
			warnHodirsFury:Show(target)
		end
	end

end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(312690, 312689, 62396) then
		timerFlameVents:Stop()
	end
end