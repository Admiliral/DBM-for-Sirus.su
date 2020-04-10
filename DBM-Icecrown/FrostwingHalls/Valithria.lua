local mod	= DBM:NewMod("Valithria", "DBM-Icecrown", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200405141240")
mod:SetCreatureID(36789)
--mod:SetUsedIcons(8)
mod:RegisterCombat("yell", L.YellPull)
mod:RegisterKill("yell", L.YellKill)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_DAMAGE",
	"SPELL_MISSED",
	"CHAT_MSG_MONSTER_YELL"
)

local warnCorrosion			= mod:NewStackAnnounce(70751, 2, nil, false)
local warnGutSpray			= mod:NewTargetAnnounce(71283, 3, nil, "Tank|Healer")
local warnManaVoid			= mod:NewSpellAnnounce(71741, 2, nil, "-Melee")
local warnSupression		= mod:NewSpellAnnounce(70588, 3)
local warnPortalSoon		= mod:NewSoonAnnounce(72483, 2, nil)
local warnPortal			= mod:NewSpellAnnounce(72483, 3, nil)
local warnPortalOpen		= mod:NewAnnounce("WarnPortalOpen", 4, 72483)

local specWarnGutSpray		= mod:NewSpecialWarningDefensive(70633, nil, nil, nil, 1, 2)
local specWarnLayWaste		= mod:NewSpecialWarningSpell(71730, nil, nil, nil, 2, 2)
local specWarnManaVoid		= mod:NewSpecialWarningMove(71741, nil, nil, nil, 1, 2)

local timerLayWaste			= mod:NewBuffActiveTimer(12, 69325, nil, nil, nil, 2)
local timerNextPortal		= mod:NewCDTimer(46.5, 72483, nil, nil, nil, 5, nil, DBM_CORE_HEALER_ICON)
local timerPortalsOpen		= mod:NewTimer(10, "TimerPortalsOpen", 72483, nil, nil, 6)
local timerPortalsClose		= mod:NewTimer(10, "TimerPortalsClose", 72483, nil, nil, 6)
local timerHealerBuff		= mod:NewBuffFadesTimer(40, 70873, nil, nil, nil, 5, nil, DBM_CORE_HEALER_ICON)
local timerGutSpray			= mod:NewTargetTimer(12, 71283, nil, "Tank|Healer", nil, 5)
local timerCorrosion		= mod:NewTargetTimer(6, 70751, nil, false, nil, 3)
local timerBlazingSkeleton	= mod:NewTimer(50, "TimerBlazingSkeleton", 17204, nil, nil, 1)
local timerAbom				= mod:NewTimer(25, "TimerAbom", 43392, nil, nil, 1) --Experimental

local berserkTimer			= mod:NewBerserkTimer(420)

--mod:AddBoolOption("SetIconOnBlazingSkeleton", true)

local GutSprayTargets = {}
local spamSupression = 0
local BlazingSkeletonTimer = 60
local AbomTimer = 60

local function warnGutSprayTargets()
	warnGutSpray:Show(table.concat(GutSprayTargets, "<, >"))
	table.wipe(GutSprayTargets)
end

function mod:StartBlazingSkeletonTimer()
	if BlazingSkeletonTimer >= 5 then--Keep it from dropping below 5
		timerBlazingSkeleton:Start(BlazingSkeletonTimer)
		self:ScheduleMethod(BlazingSkeletonTimer, "StartBlazingSkeletonTimer")
	end
	BlazingSkeletonTimer = BlazingSkeletonTimer - 5
end

function mod:StartAbomTimer()
	if AbomTimer >= 60 then--Keep it from dropping below 50
		timerAbom:Start(AbomTimer)
		self:ScheduleMethod(AbomTimer, "StartAbomTimer")
		AbomTimer = AbomTimer - 5
	else
		timerAbom:Start(AbomTimer)
		self:ScheduleMethod(AbomTimer, "StartAbomTimer")
	end
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 36789, "Valithria Dreamwalker")
	if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
		berserkTimer:Start(-delay)
	end
	timerNextPortal:Start()
	warnPortalSoon:Schedule(41)
	self:ScheduleMethod(46.5, "Portals")--This will never be perfect, since it's never same. 45-48sec variations
	BlazingSkeletonTimer = 60
	AbomTimer = 60
	self:ScheduleMethod(50-delay, "StartBlazingSkeletonTimer")
	self:ScheduleMethod(23.5-delay, "StartAbomTimer")
	timerBlazingSkeleton:Start(-delay)
	timerAbom:Start(23.5-delay)
	table.wipe(GutSprayTargets)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 36789, "Valithria Dreamwalker", wipe)
end

function mod:Portals()
	warnPortal:Show()
	warnPortalOpen:Cancel()
	timerPortalsOpen:Cancel()
	warnPortalSoon:Cancel()
	warnPortalOpen:Schedule(15)
	timerPortalsOpen:Start()
	timerPortalsClose:Schedule(15)
	warnPortalSoon:Schedule(41)
	timerNextPortal:Start()
	self:UnscheduleMethod("Portals")
	self:ScheduleMethod(46.5, "Portals")--This will never be perfect, since it's never same. 45-48sec variations
end

--[[function mod:SPELL_CAST_START(args)
	if args:IsSpellID(70754, 71748, 72023, 72024) then--Fireball (its the first spell Blazing SKeleton's cast upon spawning)
		if self.Options.SetIconOnBlazingSkeleton then
			SetRaidTarget(args.sourceGUID, 8)
		end
	end
end--]]

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(71741) then--Mana Void
		warnManaVoid:Show()
	elseif args:IsSpellID(70588) and GetTime() - spamSupression > 5 then--Supression
		warnSupression:Show(args.destName)
		spamSupression = GetTime()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(70633, 71283, 72025, 72026) and args:IsDestTypePlayer() then--Gut Spray
		GutSprayTargets[#GutSprayTargets + 1] = args.destName
		timerGutSpray:Start(args.destName)
		self:Unschedule(warnGutSprayTargets)
		self:Schedule(0.3, warnGutSprayTargets)
		if self:IsTank() then
			specWarnGutSpray:Show()
			specWarnGutSpray:Play("defensive")
		end
	elseif args:IsSpellID(70751, 71738, 72022, 72023) and args:IsDestTypePlayer() then--Corrosion
		warnCorrosion:Show(args.destName, args.amount or 1)
		timerCorrosion:Start(args.destName)
	elseif args:IsSpellID(69325, 71730) then--Lay Waste
		specWarnLayWaste:Show()
		specWarnLayWaste:Play("aesoon")
		timerLayWaste:Start()
	elseif args:IsSpellID(70873, 71941) then	--Emerald Vigor/Twisted Nightmares (portal healers)
		if args:IsPlayer() then
			timerHealerBuff:Start()
		end
	end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(70633, 71283, 72025, 72026) then--Gut Spray
		timerGutSpray:Cancel(args.destName)
	elseif args:IsSpellID(69325, 71730) then--Lay Waste
		timerLayWaste:Cancel()
	end
end

function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(71086, 71743, 72029, 72030) and args:IsPlayer() and self:AntiSpam(2, 2) then		-- Mana Void
		specWarnManaVoid:Show()
		specWarnManaVoid:Play("runaway")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L.YellPortals or msg:find(L.YellPortals)) and mod:LatencyCheck() then
		self:SendSync("NightmarePortal")
	end
end

function mod:OnSync(msg, arg)
	if msg == "NightmarePortal" and self:IsInCombat() then
		self:Portals()
	end
end
