local mod	= DBM:NewMod("Auriaya", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

mod:SetCreatureID(33515)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_DAMAGE",
	"UNIT_DIED"
)

local warnSwarm 		= mod:NewTargetAnnounce(312956, 2)
local warnFearSoon	 	= mod:NewSoonAnnounce(312955, 1)
local warnCatDied 		= mod:NewAnnounce("WarnCatDied", 3, 312972)
local warnCatDiedOne	= mod:NewAnnounce("WarnCatDiedOne", 3, 312972)

local specWarnFear 			= mod:NewSpellAnnounce(312955, nil, nil, nil, 2, 2)
local specWarnBlast		= mod:NewSpecialWarningInterrupt(64389, "HasInterrupt", nil, 2, 1, 2)
local specWarnVoid 		= mod:NewSpecialWarningMove(312971, nil, nil, nil, 1, 2)
local specWarnSonic			= mod:NewSpellAnnounce(312954, nil, nil, nil, 2, 2)
local specWarnCat			= mod:NewSpecialWarningAddsCustom(312972, nil, nil, nil, 2, 2)

local enrageTimer		= mod:NewBerserkTimer(600)
local timerDefender 	= mod:NewTimer(35, "timerDefender", 64455, nil, nil, 1)
local timerFear			= mod:NewCastTimer(312955, nil, nil, nil, 2)
local timerNextFear 	= mod:NewNextTimer(35.5, 312955, nil, nil, nil, 4)
local timerNextSwarm 	= mod:NewNextTimer(36, 312956, nil, nil, nil, 1)
local timerNextSonic 	= mod:NewNextTimer(27, 312954, nil, nil, nil, 2)
local timerSonic		= mod:NewCastTimer(312954, nil, nil, nil, 2)

mod:AddBoolOption("HealthFrame", true)

--local isFeared			= false
mod.vb.catLives = 9
mod.vb.DefenderCount = 0
function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 33515, "Auriaya")
	self.vb.DefenderCount = 0
	self.vb.catLives = 9
	enrageTimer:Start(-delay)
	timerNextFear:Start(40-delay)
	timerNextSonic:Start(60-delay)
	timerDefender:Start(60-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33515, "Auriaya", wipe)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(64678, 64389, 312600, 312953) then -- Sentinel Blast
		specWarnBlast:Show(args.sourceName)
		specWarnBlast:Play("kickcast")
	elseif args:IsSpellID(64386, 312602, 312955) then -- Terrifying Screech
		timerFear:Start()
		timerNextFear:Schedule(2)
		warnFearSoon:Schedule(34)
		specWarnFear:Show()
		specWarnFear:Play("fearsoon")
	elseif args:IsSpellID(64688, 64422, 312601, 312954) then --Sonic Screech
		timerSonic:Start()
		timerNextSonic:Start()
		specWarnSonic:Show()
		specWarnSonic:Play("gathershare")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(64396, 312603, 312956) then -- Guardian Swarm
		warnSwarm:Show(args.destName)
		timerNextSwarm:Start()
	elseif args:IsSpellID(64455, 312619, 312972) then -- Feral Essence
		specWarnCat:Show(args.destName)
		DBM.BossHealth:AddBoss(34035, L.Defender:format(9))
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 34035 then
		self.vb.catLives = self.vb.catLives - 1
		if self.vb.catLives > 0 then
			if self.vb.catLives == 1 then
				warnCatDiedOne:Show()
				timerDefender:Start()
			else
				warnCatDied:Show(self.vb.catLives)
				timerDefender:Start(nil, self.vb.DefenderCount+1)
			end
			if self.Options.HealthFrame then
				DBM.BossHealth:RemoveBoss(34035)
				DBM.BossHealth:AddBoss(34035, L.Defender:format(self.vb.catLives))
			end
		else
			if self.Options.HealthFrame then
				DBM.BossHealth:RemoveBoss(34035)
			end
		end
	end
end

function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(64459, 64675, 312610, 312963) and args:IsPlayer() then -- Feral Defender Void Zone
		specWarnVoid:Show()
		specWarnVoid:Play("runaway")
	end
end

mod.SPELL_MISSED = mod.SPELL_DAMAGE