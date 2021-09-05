local mod	= DBM:NewMod("Ignis", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501002000")


mod:SetCreatureID(33118)
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_REMOVED"
)

local announceSlagPot			= mod:NewTargetAnnounce(312731, 3)
local announceConstruct			= mod:NewCountAnnounce(62488, 2)

local warnFlameJetsCast			= mod:NewSpecialWarningCast(312727, "SpellCaster", nil, nil, 2, 2)
local warnFlameBrittle			= mod:NewSpecialWarningSwitch(62382, "Dps", nil, nil, 2, 2)

local timerFlameJetsCast		= mod:NewCastTimer(2.7, 312727)
local timerActivateConstruct	= mod:NewCDTimer(30, 62488, nil, nil, nil, 1)
local timerScorchCooldown		= mod:NewNextTimer(31, 312730, nil, nil, nil, 5)
local timerFlameJetsCooldown	= mod:NewCDCountTimer(35, 312727, nil, nil, nil, 2)
local timerScorchCast			= mod:NewCastTimer(3, 312730, nil, nil, nil, 5)
local timerSlagPot				= mod:NewTargetTimer(10, 312731, nil, nil, nil, 3)
local timerAchieve				= mod:NewAchievementTimer(240, 2930)

mod.vb.FlameCount = 0
mod.vb.ConstructCount = 0
mod:AddSetIconOption("SlagPotIcon", 312731, false, false, {8})


function mod:OnCombatStart(delay)
	self.vb.ConstructCount = 0
	self.vb.FlameCount = 0
	DBM:FireCustomEvent("DBM_EncounterStart", 33118, "Ignis")
	timerAchieve:Start()
	timerScorchCooldown:Start(12-delay)
	timerActivateConstruct:Start(11-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33118, "Ignis", wipe)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 312727 or spellId == 312728 or spellId == 62680 or spellId == 63472 then		-- Flame Jets
		self.vb.FlameCount = self.vb.FlameCount + 1
		timerFlameJetsCast:Start()
		warnFlameJetsCast:Show()
		warnFlameJetsCast:Play("stopcast")
		timerFlameJetsCooldown:Start(nil, self.vb.FlameCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 312729 or spellId == 312730 or spellId == 62548 or spellId == 63474 then	-- Scorch
		timerScorchCast:Start()
		timerScorchCooldown:Start()
	elseif spellId == 62488 then
		self.vb.ConstructCount = self.vb.ConstructCount + 1
		announceConstruct:Show(self.vb.ConstructCount)
		if self.vb.ConstructCount < 20 then
			timerActivateConstruct:Start(nil, self.vb.ConstructCount)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 312732 or spellId == 312731 or spellId == 62717 or spellId == 63477 then		-- Slag Pot
		announceSlagPot:Show(args.destName)
		timerSlagPot:Start(args.destName)
		if self.Options.SlagPotIcon then
			self:SetIcon(args.destName, 8, 10)
        end
	elseif spellId == 62382 and self:AntiSpam(5, 1) then
		warnFlameBrittle:Show()
		warnFlameBrittle:Play("killmob")
    end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 312732 or spellId == 312731 or spellId == 62717 or spellId == 63477 then		-- Slag Pot
		if self.Options.SlagPotIcon then
			self:SetIcon(args.destName, 0)
		end
	end
end