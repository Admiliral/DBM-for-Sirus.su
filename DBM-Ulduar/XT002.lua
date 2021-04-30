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
	"SPELL_DAMAGE"
)

local warnLightBomb					= mod:NewTargetAnnounce(312941, 3)
local warnGravityBomb				= mod:NewTargetAnnounce(312943, 3)

local specWarnLightBomb				= mod:NewSpecialWarningYou(312941)
local specWarnGravityBomb			= mod:NewSpecialWarningYou(312943)
local specWarnConsumption			= mod:NewSpecialWarningMove(312948)									--Hard mode void zone dropped by Gravity Bomb

local BerserkTimer					= mod:NewBerserkTimer(600)
local timerTympanicTantrumCast		= mod:NewCastTimer(312939)
local timerTympanicTantrum			= mod:NewBuffActiveTimer(8, 312939)
local timerTympanicTantrumCD		= mod:NewCDTimer(79, 312939)
local timerHeart					= mod:NewCastTimer(30, 312945)
local timerLightBomb				= mod:NewTargetTimer(9, 312941)
local timerGravityBomb				= mod:NewTargetTimer(9, 312943)
local timerAchieve					= mod:NewAchievementTimer(205, 2938, "TimerSpeedKill")



mod:AddBoolOption("SetIconOnLightBombTarget", true)
mod:AddBoolOption("SetIconOnGravityBombTarget", true)
mod:AddBoolOption("YellOnGravityBomb",true, "announce")
mod:AddBoolOption("YellOnLightBomb",true, "announce")

function mod:OnCombatStart(delay)
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

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(62776, 312586, 312939) then														-- Tympanic Tantrum (aoe damge + daze)
		timerTympanicTantrumCast:Start()
		timerTympanicTantrumCD:Stop()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62775, 312587, 312940) and args.auraType == "DEBUFF" then							-- Tympanic Tantrum
		timerTympanicTantrumCD:Start()
		timerTympanicTantrum:Start()

	elseif args:IsSpellID(63018, 65121, 312588, 312941) then 											-- Ополяющий свет
		if args:IsPlayer() then
			specWarnLightBomb:Show()
			if self.Options.YellOnLightBomb  then
					SendChatMessage(L.YellLightBomb, "SAY")
			end
			--[[if mod.Options.AnnonceGravity then
				if DBM:GetRaidRank() > 0 then
					SendChatMessage(L.Gravity:format(SetIconOnLightBombTarget, args.destName), "RAID_WARNING")
				else
					SendChatMessage(L.Gravity:format(SetIconOnLightBombTarget, args.destName), "SAY")
				end
			end ]]
		end
		if self.Options.SetIconOnLightBombTarget then
			self:SetIcon(args.destName, 7, 9)
		end
		warnLightBomb:Show(args.destName)
		timerLightBomb:Start(args.destName)
	elseif args:IsSpellID(63024, 64234, 312590, 312943) then											-- Gravity Bomb
		if args:IsPlayer() then
			specWarnGravityBomb:Show()
			if self.Options.YellOnGravityBomb then
				
				SendChatMessage(L.YellGravityBomb, "SAY")
		end
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
	end
end

do 
	local lastConsumption = 0
	function mod:SPELL_DAMAGE(args)
		if args:IsSpellID(64208, 312948) and args:IsPlayer() and time() - lastConsumption > 2 then		-- Hard mode void zone
			specWarnConsumption:Show()
			lastConsumption = time()
		end
	end
end