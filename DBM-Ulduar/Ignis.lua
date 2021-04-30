local mod	= DBM:NewMod("Ignis", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210429162000")


mod:SetCreatureID(33118)
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_SUCCESS"
)

local announceSlagPot			= mod:NewTargetAnnounce(312731, 3)

local warnFlameJetsCast			= mod:NewSpecialWarningCast(312727)

local enrage 					= mod:NewBerserkTimer(480)
local timerFlameJetsCast		= mod:NewCastTimer(2.7, 312727)
local timerFlameJetsCooldown	= mod:NewCDTimer(35, 312727)
local timerScorchCooldown		= mod:NewNextTimer(25, 312730)
local timerScorchCast			= mod:NewCastTimer(3, 312730)
local timerSlagPot				= mod:NewTargetTimer(10, 312731)
local timerAchieve				= mod:NewAchievementTimer(240, 2930, "TimerSpeedKill")


mod:AddBoolOption("SlagPotIcon")


function mod:OnCombatStart(delay)
	timerAchieve:Start()
	timerScorchCooldown:Start(12-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(312727, 312728) then		-- Flame Jets
		timerFlameJetsCast:Start()
		warnFlameJetsCast:Show()
		timerFlameJetsCooldown:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(312729, 312730) then	-- Scorch
		timerScorchCast:Start()
		timerScorchCooldown:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312732, 312731) then		-- Slag Pot
		announceSlagPot:Show(args.destName)
		timerSlagPot:Start(args.destName)
		if self.Options.SlagPotIcon then
			self:SetIcon(args.destName, 8, 10)
                end						
		
    end
end