local mod	= DBM:NewMod("Putricide", "DBM-Icecrown", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200405141240")
mod:SetCreatureID(36678)
mod:RegisterCombat("yell", L.YellPull)
mod:SetMinSyncRevision(3860)
mod:SetUsedIcons(5, 6, 7, 8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REFRESH",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"UNIT_HEALTH"
)

local warnSlimePuddle				= mod:NewSpellAnnounce(70341, 2)
local warnUnstableExperimentSoon	= mod:NewSoonAnnounce(70351, 3)
local warnUnstableExperiment		= mod:NewSpellAnnounce(70351, 4)
local warnVolatileOozeAdhesive		= mod:NewTargetAnnounce(70447, 3)
local warnGaseousBloat				= mod:NewTargetAnnounce(70672, 3)
local warnPhase2Soon				= mod:NewPrePhaseAnnounce(2)
local warnTearGas					= mod:NewSpellAnnounce(71617, 2)		-- Phase transition normal
local warnVolatileExperiment		= mod:NewSpellAnnounce(72840, 4)		-- Phase transition heroic
local warnChokingGasBombSoon		= mod:NewPreWarnAnnounce(71255, 5, 3, nil, "Melee")
local warnChokingGasBomb			= mod:NewSpellAnnounce(71255, 3, nil, "Melee")		-- Phase 2 ability
local warnPhase3Soon				= mod:NewPrePhaseAnnounce(3)
local warnMutatedPlague				= mod:NewStackAnnounce(72451, 2, nil, "Tank|Healer") -- Phase 3 ability
local warnUnboundPlague				= mod:NewTargetAnnounce(72856, 3)			-- Heroic Ability

local specWarnVolatileOozeAdhesive	= mod:NewSpecialWarningYou(70447, nil, nil, nil, 1, 2)
local specWarnVolatileOozeAdhesiveT	= mod:NewSpecialWarningMoveTo(70447, nil, nil, nil, 1, 2)
local specWarnGaseousBloat			= mod:NewSpecialWarningRun(70672, nil, nil, nil, 4, 2)
local specWarnGaseousBloatOther		= mod:NewSpecialWarningTarget(70672, false)
local specWarnMalleableGoo			= mod:NewSpecialWarningYou(72295, nil, nil, nil, 1, 2)
local yellMalleableGoo				= mod:NewYell(72295)
local specWarnMalleableGooNear		= mod:NewSpecialWarningClose(72295, nil, nil, nil, 1, 2)
local specWarnChokingGasBomb		= mod:NewSpecialWarningMove(71255, "Tank", nil, nil, 1, 2)
local specWarnMalleableGooCast		= mod:NewSpecialWarningSpell(72295, false, nil, nil, 2, 2)
local specWarnOozeVariable			= mod:NewSpecialWarningYou(70352)		-- Heroic Ability
local specWarnGasVariable			= mod:NewSpecialWarningYou(70353)		-- Heroic Ability
local specWarnUnboundPlague			= mod:NewSpecialWarningYou(72856, nil, nil, nil, 1, 2)		-- Heroic Ability
local specWarnMutatedPlague         = mod:NewSpecialWarningStack(72451, "Tank|Healer", 4, nil, nil, 1, 6)
local yellUnboundPlague				= mod:NewYell(70911)

local timerGaseousBloat				= mod:NewTargetTimer(20, 70672, nil, nil, nil, 3)			-- Duration of debuff
local timerSlimePuddleCD			= mod:NewCDTimer(35, 70341, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON)				-- Approx
local timerUnstableExperimentCD		= mod:NewNextTimer(38, 70351, nil, nil, nil, 1, nil, DBM_CORE_DEADLY_ICON)			-- Used every 38 seconds exactly except after phase changes
local timerChokingGasBombCD			= mod:NewNextTimer(37.5, 71255, nil, nil, nil, 3)
local timerMalleableGooCD			= mod:NewCDTimer(25, 72295, nil, nil, nil, 3)
local timerTearGas					= mod:NewBuffFadesTimer(8, 71615, nil, nil, nil, 6)
local timerPotions					= mod:NewBuffActiveTimer(30, 73122, nil, nil, nil, 6)
local timerMutatedPlagueCD			= mod:NewCDTimer(10, 72451, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)				-- 10 to 11
local timerUnboundPlagueCD			= mod:NewNextTimer(60, 72856, nil, nil, nil, 3, nil, DBM_CORE_HEROIC_ICON)
local timerUnboundPlague			= mod:NewBuffActiveTimer(12, 72856, nil, nil, nil, 3)		-- Heroic Ability: we can't keep the debuff 60 seconds, so we have to switch at 12-15 seconds. Otherwise the debuff does to much damage!

-- buffs from "Drink Me"
local timerMutatedSlash				= mod:NewTargetTimer(20, 70542, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON)
local timerRegurgitatedOoze			= mod:NewTargetTimer(20, 70539, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON)

local berserkTimer					= mod:NewBerserkTimer(600)
mod:AddSetIconOption("OozeAdhesiveIcon", 70447, true, true, {8})
mod:AddSetIconOption("GaseousBloatIcon", 70672, true, true, {7})
mod:AddSetIconOption("MalleableGooIcon", 72295, true, true, {6})
mod:AddSetIconOption("UnboundPlagueIcon", 72856, true, true, {5})
mod:AddBoolOption("GooArrow")
mod:AddBoolOption("BypassLatencyCheck", false)--Use old scan method without syncing or latency check (less reliable but not dependant on other DBM users in raid)

mod.vb.warned_preP2 = false
mod.vb.warned_preP3 = false
mod.vb.phase = 0

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 36678, "Professor Putricide")
	berserkTimer:Start(-delay)
	timerSlimePuddleCD:Start(10-delay)
	timerUnstableExperimentCD:Start(30-delay)
	warnUnstableExperimentSoon:Schedule(25-delay)
	self.vb.warned_preP2 = false
	self.vb.warned_preP3 = false
	self.vb.phase = 1
	if self:IsDifficulty("heroic10", "heroic25") then
		timerUnboundPlagueCD:Start(10-delay)
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 36678, "Professor Putricide", wipe)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:MalleableGooTarget()
	local targetname = self:GetBossTarget(36678)
	if not targetname then return end
	if mod:LatencyCheck() then--Only send sync if you have low latency.
		self:SendSync("GooOn", targetname)
	end
end

function mod:OldMalleableGooTarget()
	local targetname = self:GetBossTarget(36678)
	if not targetname then return end
		if self.Options.MalleableGooIcon then
			self:SetIcon(targetname, 6, 10)
		end
	if targetname == UnitName("player") then
		specWarnMalleableGoo:Show()
		specWarnMalleableGoo:Play("targetyou")
		yellMalleableGoo:Yell()
	elseif targetname then
		local uId = DBM:GetRaidUnitId(targetname)
		if uId then
			local inRange = CheckInteractDistance(uId, 2)
			local x, y = GetPlayerMapPosition(uId)
			if x == 0 and y == 0 then
				SetMapToCurrentZone()
				x, y = GetPlayerMapPosition(uId)
			end
			if inRange then
				specWarnMalleableGooNear:Show(targetname)
				specWarnMalleableGooNear:Play("watchstep")
				if self.Options.GooArrow then
					DBM.Arrow:ShowRunAway(x, y, 10, 5)
				end
			end
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(70351, 71966, 71967, 71968) then
		warnUnstableExperimentSoon:Cancel()
		warnUnstableExperiment:Show()
		timerUnstableExperimentCD:Start()
		warnUnstableExperimentSoon:Schedule(33)
	elseif args:IsSpellID(71617) then				--Tear Gas, normal phase change trigger
		warnTearGas:Show()
		warnUnstableExperimentSoon:Cancel()
		warnChokingGasBombSoon:Cancel()
		timerUnstableExperimentCD:Cancel()
		timerMalleableGooCD:Cancel()
		timerSlimePuddleCD:Cancel()
		timerChokingGasBombCD:Cancel()
		timerUnboundPlagueCD:Cancel()
	elseif args:IsSpellID(72842, 72843) then		--Volatile Experiment (heroic phase change begin)
		warnVolatileExperiment:Show()
		warnUnstableExperimentSoon:Cancel()
		warnChokingGasBombSoon:Cancel()
		timerUnstableExperimentCD:Cancel()
		timerMalleableGooCD:Cancel()
		timerSlimePuddleCD:Cancel()
		timerChokingGasBombCD:Cancel()
		timerUnboundPlagueCD:Cancel()
	elseif args:IsSpellID(72851, 72852) then		--Create Concoction (Heroic phase change end)
		if self:IsDifficulty("heroic10", "heroic25") then
			self:ScheduleMethod(30, "NextPhase")	--May need slight tweaking +- a second or two
			timerPotions:Start()
		end
	elseif args:IsSpellID(73121, 73122) then		--Guzzle Potions (Heroic phase change end)
		if self:IsDifficulty("heroic10") then
			self:ScheduleMethod(30, "NextPhase")	--May need slight tweaking +- a second or two
			timerPotions:Start()
		elseif self:IsDifficulty("heroic25") then
			self:ScheduleMethod(20, "NextPhase")
			timerPotions:Start(20)
			timerMalleableGooCD:Start(20)
		end
	end
end

function mod:NextPhase()
	self.vb.phase = self.vb.phase + 1
	if self.vb.phase == 2 then
		timerUnstableExperimentCD:Start(5)
		timerSlimePuddleCD:Start(10)
--		timerMalleableGooCD:Start(5)
		if self:IsDifficulty("heroic10", "heroic25") then
			timerUnboundPlagueCD:Start(50)
			warnChokingGasBombSoon:Schedule(0)
			timerChokingGasBombCD:Start(5)
		else
			warnChokingGasBombSoon:Schedule(19)
			timerChokingGasBombCD:Start(24)
		end
	elseif self.vb.phase == 3 then
		timerSlimePuddleCD:Start(15)
		timerMalleableGooCD:Start(24)
		if self:IsDifficulty("heroic10", "heroic25") then
			timerUnboundPlagueCD:Start(50)
			timerChokingGasBombCD:Start(21)
			warnChokingGasBombSoon:Schedule(16)
		else
			timerChokingGasBombCD:Start(22)
			warnChokingGasBombSoon:Schedule(17)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(70341) and self:AntiSpam(5, 1) then
		warnSlimePuddle:Show()
		if self.vb.phase == 3 then
			timerSlimePuddleCD:Start(20)             --In phase 3 it's faster
		else
			timerSlimePuddleCD:Start()
		end
	elseif args:IsSpellID(71255) then
		warnChokingGasBomb:Show()
		specWarnChokingGasBomb:Show()
		timerChokingGasBombCD:Start()
		warnChokingGasBombSoon:Schedule(30.5)
	elseif args:IsSpellID(72855, 72856, 70911) then
		timerUnboundPlagueCD:Start()
	elseif args:IsSpellID(72615, 72295, 74280, 74281, 70852, 72296) then
		specWarnMalleableGooCast:Show()
		specWarnMalleableGooCast:Play("watchstep")
		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
			timerMalleableGooCD:Start(20)
		else
			timerMalleableGooCD:Start()
		end
		if self.Options.BypassLatencyCheck then
			self:ScheduleMethod(0.1, "OldMalleableGooTarget")
		else
			self:ScheduleMethod(0.1, "MalleableGooTarget")
		end
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L.EmoteMalleable then
		specWarnMalleableGooCast:Show()
		specWarnMalleableGooCast:Play("watchstep")
		timerMalleableGooCD:Start()
		if self.Options.BypassLatencyCheck then
			self:ScheduleMethod(0.1, "OldMalleableGooTarget")
		else
			self:ScheduleMethod(0.1, "MalleableGooTarget")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(70447, 72836, 72837, 72838) then     --Green Slime
		if args:IsPlayer() then
			specWarnVolatileOozeAdhesive:Show()
			specWarnVolatileOozeAdhesive:Play("helpsoak")
		elseif not self:IsTank() then
			specWarnVolatileOozeAdhesiveT:Show(args.destName)
			specWarnVolatileOozeAdhesiveT:Play("helpsoak")
		else
			warnVolatileOozeAdhesive:Show(args.destName)
		end
		if self.Options.OozeAdhesiveIcon then
			self:SetIcon(args.destName, 8, 8)
		end
	elseif args:IsSpellID(70672, 72455, 72832, 72833) then	--Red Slime
		specWarnGaseousBloatOther:Show(args.destName)
		timerGaseousBloat:Start(args.destName)
		if args:IsPlayer() then
			specWarnGaseousBloat:Show()
			specWarnGaseousBloat:Play("justrun")
			specWarnGaseousBloat:ScheduleVoice(1.5, "keepmove")
		else
			warnGaseousBloat:Show(args.destName)
		end
		if self.Options.GaseousBloatIcon then
			self:SetIcon(args.destName, 7)
		end
	elseif args:IsSpellID(71615, 71618) then	--71615 used in 10 and 25 normal, 71618?
		timerTearGas:Start()
	elseif args:IsSpellID(72451, 72463, 72671, 72672) then	-- Mutated Plague
		warnMutatedPlague:Show(args.destName, args.amount or 1)
		timerMutatedPlagueCD:Start()
	elseif args:IsSpellID(70542) then
		timerMutatedSlash:Show(args.destName)
	elseif args:IsSpellID(70539, 72457, 72875, 72876) then
		timerRegurgitatedOoze:Show(args.destName)
	elseif args:IsSpellID(70352, 74118) then	--Ooze Variable
		if args:IsPlayer() then
			specWarnOozeVariable:Show()
		end
	elseif args:IsSpellID(70353, 74119) then	-- Gas Variable
		if args:IsPlayer() then
			specWarnGasVariable:Show()
		end
	elseif args:IsSpellID(72855, 72856, 70911) then	 -- Unbound Plague
		if self.Options.UnboundPlagueIcon then
			self:SetIcon(args.destName, 5)
		end
		if args:IsPlayer() then
			specWarnUnboundPlague:Show()
			specWarnUnboundPlague:Play("targetyou")
			timerUnboundPlague:Start()
			yellUnboundPlague:Yell()
		else
			warnUnboundPlague:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args:IsSpellID(72451, 72463, 72671, 72672) then	-- Mutated Plague
		warnMutatedPlague:Show(args.destName, args.amount or 1)
		timerMutatedPlagueCD:Start()
		if args.amount >=4 then
			specWarnMutatedPlague:Show(args.amount)
		end
	elseif args:IsSpellID(70542) then
		timerMutatedSlash:Show(args.destName)
	end
end

function mod:SPELL_AURA_REFRESH(args)
	if args:IsSpellID(70539, 72457, 72875, 72876) then
		timerRegurgitatedOoze:Show(args.destName)
	elseif args:IsSpellID(70542) then
		timerMutatedSlash:Show(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(70447, 72836, 72837, 72838) then
		if self.Options.OozeAdhesiveIcon then
			self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(70672, 72455, 72832, 72833) then
		timerGaseousBloat:Cancel(args.destName)
		if self.Options.GaseousBloatIcon then
			self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(72855, 72856, 70911) then 						-- Unbound Plague
		timerUnboundPlague:Stop(args.destName)
		if self.Options.UnboundPlagueIcon then
			self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(71615) and self:AntiSpam(5, 2) then 	-- Tear Gas Removal
		self:NextPhase()
	elseif args:IsSpellID(70539, 72457, 72875, 72876) then
		timerRegurgitatedOoze:Cancel(args.destName)
	elseif args:IsSpellID(70542) then
		timerMutatedSlash:Cancel(args.destName)
	end
end

--values subject to tuning depending on dps and his health pool
function mod:UNIT_HEALTH(uId)
	if self.vb.phase == 1 and not self.vb.warned_preP2 and self:GetUnitCreatureId(uId) == 36678 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.83 then
		self.vb.warned_preP2 = true
		warnPhase2Soon:Show()
	elseif self.vb.phase == 2 and not self.vb.warned_preP3 and self:GetUnitCreatureId(uId) == 36678 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.38 then
		self.vb.warned_preP3 = true
		warnPhase3Soon:Show()
	end
end

function mod:OnSync(msg, target)
	if msg == "GooOn" then
		if not self.Options.BypassLatencyCheck then
			if self.Options.MalleableGooIcon then
				self:SetIcon(target, 6, 10)
			end
			if target == UnitName("player") then
				specWarnMalleableGoo:Show()
			elseif target then
				local uId = DBM:GetRaidUnitId(target)
				if uId then
					local inRange = CheckInteractDistance(uId, 2)
					local x, y = GetPlayerMapPosition(uId)
					if x == 0 and y == 0 then
						SetMapToCurrentZone()
						x, y = GetPlayerMapPosition(uId)
					end
					if inRange then
						specWarnMalleableGooNear:Show(target)
						specWarnMalleableGooNear:Play("watchstep")
						if self.Options.GooArrow then
							DBM.Arrow:ShowRunAway(x, y, 10, 5)
						end
					end
				end
			end
		end
	end
end
