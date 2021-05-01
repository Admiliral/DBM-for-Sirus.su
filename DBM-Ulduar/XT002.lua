local mod	= DBM:NewMod("XT002", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210429162400")
mod:SetCreatureID(33293)
mod:SetUsedIcons(7, 8)

mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_DAMAGE",
	"SPELL_MISSED"
)

local warnLightBomb					= mod:NewTargetAnnounce(312941, 3)
local warnGravityBomb				= mod:NewTargetAnnounce(312943, 3)

local specWarnLightBomb				= mod:NewSpecialWarningYou(312941, nil, nil, nil, 1, 2)
local specWarnGravityBomb			= mod:NewSpecialWarningYou(312943, nil, nil, nil, 1, 2)
local specWarnConsumption			= mod:NewSpecialWarningMove(312948, nil, nil, nil, 1, 2)									--Hard mode void zone dropped by Gravity Bomb
local yellGravityBomb				= mod:NewYell(312943)
local yellLightBomb					= mod:NewYell(312941)
local BerserkTimer					= mod:NewBerserkTimer(600)
local timerTympanicTantrum			= mod:NewBuffActiveTimer(8, 312939, nil, nil, nil, 5, nil, DBM_CORE_L_HEALER_ICON)
local timerTympanicTantrumCD		= mod:NewCDTimer(79, 312939, nil, nil, nil, 2, nil, DBM_CORE_L_HEALER_ICON)
local timerHeart					= mod:NewCastTimer(30, 312945, nil, nil, nil, 6, nil, DBM_CORE_L_DAMAGE_ICON)
local timerLightBomb				= mod:NewTargetTimer(9, 312941, nil, nil, nil, 3)
local timerGravityBomb				= mod:NewTargetTimer(9, 312943, nil, nil, nil, 3)
local timerAchieve					= mod:NewAchievementTimer(205, 2938)


mod:AddSetIconOption("SetIconOnLightBombTarget", 312941, true, true, {7})
mod:AddSetIconOption("SetIconOnGravityBombTarget", 312943, true, true, {8})

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 33293, "XT002")
	BerserkTimer:Start()
	timerAchieve:Start()
	if mod:IsDifficulty("heroic10") then 																--10
		DBM.RangeCheck:Show(10)
		timerTympanicTantrumCD:Start(35-delay)
	else
		DBM.RangeCheck:Show(10)																			--25
		timerTympanicTantrumCD:Start(50-delay)
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33293, "XT002", wipe)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(62776, 312586, 312939) then														-- Tympanic Tantrum (aoe damge + daze)
		timerTympanicTantrumCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62775, 312587, 312940) then							-- Tympanic Tantrum
		timerTympanicTantrum:Start()
	elseif args:IsSpellID(63018, 65121, 312588, 312941) then 											-- Ополяющий свет
		if args:IsPlayer() then
			specWarnLightBomb:Show()
			specWarnLightBomb:Play("runout")
			yellLightBomb:Yell()
		end
		if self.Options.SetIconOnLightBombTarget then
			self:SetIcon(args.destName, 7, 9)
		end
		warnLightBomb:Show(args.destName)
		timerLightBomb:Start(args.destName)
	elseif args:IsSpellID(63024, 64234, 312590, 312943) then											-- Gravity Bomb
		if args:IsPlayer() then
			specWarnGravityBomb:Show()
			specWarnGravityBomb:Play("runout")
			yellGravityBomb:Yell()
		end
		if self.Options.SetIconOnGravityBombTarget then
			self:SetIcon(args.destName, 8, 9)
		end
		warnGravityBomb:Show(args.destName)
		timerGravityBomb:Start(args.destName)
	elseif args:IsSpellID(312945) then
		timerHeart:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(63018, 65121, 312588, 312941) then 												-- Ополяющий свет
		if self.Options.SetIconOnLightBombTarget then
			self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(63024, 64234, 312590, 312943) then											-- Грави бомба
		if self.Options.SetIconOnGravityBombTarget then
			self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(312945) then
		timerHeart:Start()
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if (spellId == 312948 or spellId == 312949) and destGUID == UnitGUID("player") and self:AntiSpam() then
		specWarnConsumption:Show()
		specWarnConsumption:Play("runaway")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE