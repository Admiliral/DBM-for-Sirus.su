local mod	= DBM:NewMod("Thorim", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")
mod:SetCreatureID(32865)
mod:SetUsedIcons(8)

mod:RegisterCombat("yell", L.YellPhase1)
mod:RegisterKill("yell", L.YellKill)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_SUCCESS",
	"SPELL_DAMAGE"
)

local warnPhase2				= mod:NewPhaseAnnounce(2, 1)
local warnStormhammer			= mod:NewTargetAnnounce(312890, 2)
local warnLightningCharge		= mod:NewSpellAnnounce(312897, 2)
local warnUnbalancingStrike		= mod:NewTargetAnnounce(312898, 4)	-- nice blizzard, very new stuff, hmm or not? ^^ aq40 4tw :)
local warningBomb				= mod:NewTargetAnnounce(312911, 4)
local warnChainlightning        = mod:NewTargetAnnounce(312895, 4)
local specWarnOrb				= mod:NewSpecialWarningMove(312892)
local specWarnUnbalancingStrikeSelf	= mod:NewSpecialWarningDefensive(312898, nil, nil, nil, 1, 2)
local specWarnUnbalancingStrike	= mod:NewSpecialWarningTaunt(312898, nil, nil, nil, 1, 2)


mod:AddBoolOption("AnnounceFails", false, "announce")

local enrageTimer				= mod:NewBerserkTimer(369)
local timerStormhammer			= mod:NewCastTimer(16, 312889, nil, nil, nil, 3)
local timerChainlightning       = mod:NewCDTimer(16, 312895, nil, nil, nil, 3)
local timerLightningCharge	 	= mod:NewCDTimer(16, 312897, nil, nil, nil, 3)
local timerUnbalancingStrike	= mod:NewCastTimer(25.6, 312898, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerHardmode				= mod:NewTimer(181, "TimerHardmode", 312898)

mod:AddBoolOption("RangeFrame")
mod:AddBoolOption("YellOnUnbalancingStrike", true)

local lastcharge = {}

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 32865, "Thorim")
	enrageTimer:Start()
	timerHardmode:Start()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(10)
	end
	table.wipe(lastcharge)
end

local sortedFailsC = {}
local function sortFails1C(e1, e2)
	return (lastcharge[e1] or 0) > (lastcharge[e2] or 0)
end

function mod:OnCombatEnd()
	DBM:FireCustomEvent("DBM_EncounterEnd", 32865, "Thorim", wipe)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
	if self.Options.AnnounceFails and DBM:GetRaidRank() >= 1 then
		local lcharge = ""
		for k, v in pairs(lastcharge) do
			table.insert(sortedFailsC, k)
		end
		table.sort(sortedFailsC, sortFails1C)
		for i, v in ipairs(sortedFailsC) do
			lcharge = lcharge.." "..v.."("..(lastcharge[v] or "")..")"
		end
		SendChatMessage(L.Charge:format(lcharge), "RAID")
		table.wipe(sortedFailsC)
	end
end


function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312889, 312536, 62042) then 					-- Storm Hammer
		warnStormhammer:Show(args.destName)
	elseif args:IsSpellID(312898, 312545) then				-- Unbalancing Strike
		warnUnbalancingStrike:Show()
		if args:IsPlayer() then
			specWarnUnbalancingStrikeSelf:Show()
			specWarnUnbalancingStrikeSelf:Play("defensive")
		else
			specWarnUnbalancingStrike:Show(args.destName)
			specWarnUnbalancingStrike:Play("tauntboss")
		end
	elseif args:IsSpellID(312911, 312910, 312558, 312557) then	-- Runic Detonation
		self:SetIcon(args.destName, 8, 5)
		warningBomb:Show(args.destName)
	elseif args:IsSpellID(312895, 312542) then
		self:SetIcon(args.destName, 8)
		warnChainlightning:Show(args.destName)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(312889, 312536, 62042) then 		-- Storm Hammer
		timerStormhammer:Schedule(2)
	elseif args:IsSpellID(312897, 312896) then   	-- Lightning Charge
		warnLightningCharge:Show()
		timerLightningCharge:Start()
	elseif args:IsSpellID(312898, 312545) then	-- Unbalancing Strike
		timerUnbalancingStrike:Start()
	elseif args:IsSpellID(312895, 312542) then
		timerChainlightning:Start()

	end
end


function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellPhase2 and mod:LatencyCheck() then		-- Bossfight (tank and spank)
		self:SendSync("Phase2")
	end
end

local spam = 0
function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(312892, 312539) then -- Lightning Shock
		if bit.band(args.destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0
		and bit.band(args.destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0
		and GetTime() - spam > 5 then
			spam = GetTime()
			specWarnOrb:Show()
		end
	elseif self.Options.AnnounceFails and args:IsSpellID(312897) and DBM:GetRaidRank() >= 1 and DBM:GetRaidUnitId(args.destName) ~= "none" and args.destName then
		lastcharge[args.destName] = (lastcharge[args.destName] or 0) + 1
		SendChatMessage(L.ChargeOn:format(args.destName), "RAID")
	end
end

function mod:OnSync(event, arg)
	if event == "Phase2" then
		warnPhase2:Show()
		enrageTimer:Stop()
		timerHardmode:Stop()
		enrageTimer:Start(300)
	end
end