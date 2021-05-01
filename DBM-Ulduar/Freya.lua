local mod	= DBM:NewMod("Freya", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

mod:SetCreatureID(32906)
mod:RegisterCombat("yell", L.YellPull)
mod:RegisterKill("yell", L.YellKill)
mod:SetUsedIcons(4, 5, 6, 7, 8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"UNIT_DIED",
	"CHAT_MSG_MONSTER_YELL"
)

-- Trash: 33430 Guardian Lasher (flower)
-- 33355 (nymph)
-- 33354 (tree)

--
-- Elder Stonebark (ground tremor / fist of stone)
-- Elder Brightleaf (unstable sunbeam)

local warnPhase2			= mod:NewPhaseAnnounce(2, 3)
local warnSimulKill			= mod:NewAnnounce("WarnSimulKill", 1)
local warnFury				= mod:NewTargetAnnounce(312881, 2)
local warnRoots				= mod:NewTargetAnnounce(312860, 2)

local specWarnLifebinder	= mod:NewSpecialWarningSwitch(62869, "Dps", nil, nil, 1, 2)
local specWarnFury			= mod:NewSpecialWarningMoveAway(312881, nil, nil, nil, 1, 2)
local yellFury				= mod:NewYell(312881)
local yellRoots				= mod:NewYell(312860)
local specWarnTremor		= mod:NewSpecialWarningCast(312856, "SpellCaster", nil, 2, 1, 2)	-- Hard mode
local specWarnBeam			= mod:NewSpecialWarningMove(312888, nil, nil, nil, 1, 2)	-- Hard mode


local enrage 				= mod:NewBerserkTimer(600)
local timerAlliesOfNature	= mod:NewNextTimer(60, 62678, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)
local timerSimulKill		= mod:NewTimer(12, "TimerSimulKill", nil, nil, nil, 5, DBM_CORE_DAMAGE_ICON)
local timerFury				= mod:NewTargetTimer(10, 312880, nil, nil, nil, 2)
local timerTremorCD 		= mod:NewCDTimer(28, 312842, nil, nil, nil, 2)
local timerMobCD 		    = mod:NewCDTimer(300, 312842, nil, nil, nil, 1)
local timerBoom 		    = mod:NewCDTimer(31, 312883, nil, nil, nil, 2)
local timerDarCD 		    = mod:NewCDTimer(26, 64185, nil, nil, nil, 2)
local timerLifebinderCD 	= mod:NewCDTimer(38.2, 62869, nil, nil, nil, 1)
local timerRootsCD 			= mod:NewCDTimer(29.6, 312856, nil, nil, nil, 3)


mod:AddSetIconOption("SetIconOnFury", 312881, false, false, {7, 8})
mod:AddSetIconOption("SetIconOnRoots", 312860, false, false, {6, 5, 4})
mod:AddBoolOption("HealthFrame", true)

--[[mod:AddBoolOption("PlaySoundOnFury")
mod:AddBoolOption("YellOnRoots", true, "announce")]]

local adds		= {}
--local rootedPlayers 	= {}
local killTime		= 0
mod.vb.iconId = 6
mod.vb.phase = 1
mod.vb.altIcon = true

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 32906, "Freya")
	self.vb.altIcon = true
	self.vb.iconId = 6
	self.vb.phase = 1
	enrage:Start()
	table.wipe(adds)
	timerAlliesOfNature:Start(10-delay)
	timerDarCD:Start()
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 32906, "Freya", wipe)
	DBM.BossHealth:Hide()
	if not wipe then
		if DBM.Bars:GetBar(L.TrashRespawnTimer) then
			DBM.Bars:CancelBar(L.TrashRespawnTimer)
		end
	end
end

--[[local function showRootWarning()
	warnRoots:Show(table.concat(rootedPlayers, "< >"))
	table.wipe(rootedPlayers)
end]]

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(62437, 62859, 312489, 312842) then
		specWarnTremor:Show()
		specWarnTremor:Play("stopcast")
		timerTremorCD:Start()
	elseif args:IsSpellID(312879) then
        timerMobCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(62678) then -- Summon Allies of Nature
		timerAlliesOfNature:Start()
	elseif args:IsSpellID(312883) then
		timerBoom:Start(8)
	elseif args:IsSpellID(62619) and self:GetUnitCreatureId(args.sourceName) == 33228 then -- Pheromones spell, cast by newly spawned Eonar's Gift second they spawn to allow melee to dps them while protector is up.
		specWarnLifebinder:Show()
		specWarnLifebinder:Play("targetchange")
		timerLifebinderCD:Start()
	elseif args:IsSpellID(63571, 62589, 312527, 312880) then -- Nature's Fury
		if self.Options.SetIconOnFury then
			self.vb.altIcon = not self.vb.altIcon	--Alternates between Skull and X
			self:SetIcon(args.destName, self.vb.altIcon and 7 or 8, 10)
		end
		if args:IsPlayer() then -- only cast on players; no need to check destFlags
			specWarnFury:Show()
			specWarnFury:Play("runout")
			yellFury:Yell()
			if self.Options.RangeFrame then
				DBM.RangeCheck:Show(8)
			end
		else
			warnFury:Show(args.destName)
		end
		timerFury:Start(args.destName)
	elseif args.spellId == 63601 then
			timerRootsCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62861, 62438, 312490, 312507, 312843, 312860) then
		warnRoots:CombinedShow(0.5, args.destName)
		if args:IsPlayer() then
			yellRoots:Yell()
		end
		self.vb.iconId = self.vb.iconId - 1
		if self.Options.SetIconOnRoots then
			self:SetIcon(args.destName, self.vb.iconId, 15)
		end
	elseif args:IsSpellID(62451, 62865, 312535, 312888) and args:IsPlayer() then
		specWarnBeam:Show()
		specWarnBeam:Play("runaway")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(62519, 312486, 312839) then
		warnPhase2:Show()
		timerBoom:Start()
		timerMobCD:Cancel()
		timerAlliesOfNature:Cancel()
	elseif args:IsSpellID(62861, 62438, 312490, 312507, 312843, 312860) then
		self:RemoveIcon(args.destName)
		mod.vb.iconId = mod.vb.iconId + 1
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.SpawnYell then
		timerAlliesOfNature:Start()
		if self.Options.HealthFrame then
			if not adds[33202] then DBM.BossHealth:AddBoss(33202, L.WaterSpirit) end -- ancient water spirit
			if not adds[32916] then DBM.BossHealth:AddBoss(32916, L.Snaplasher) end  -- snaplasher
			if not adds[32919] then DBM.BossHealth:AddBoss(32919, L.StormLasher) end -- storm lasher
		end
		adds[33202] = true
		adds[32916] = true
		adds[32919] = true
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 33202 or cid == 32916 or cid == 32919 then
		if self.Options.HealthFrame then
			DBM.BossHealth:RemoveBoss(cid)
		end
		if (GetTime() - killTime) > 20 then
			killTime = GetTime()
			timerSimulKill:Start()
			warnSimulKill:Show()
		end
		adds[cid] = nil
		local counter = 0
		for i, v in pairs(adds) do
			counter = counter + 1
		end
		if counter == 0 then
			timerSimulKill:Stop()
		end
	end
end