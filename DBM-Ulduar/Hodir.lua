local mod	= DBM:NewMod("Hodir", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 4154 $"):sub(12, -3))
mod:SetCreatureID(32845)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.YellKill)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_DAMAGE"
)

local warnStormCloud		= mod:NewTargetAnnounce(312831) --Грозовая туча

local warnFlashFreeze		= mod:NewSpecialWarningSpell(312818)
local specWarnBitingCold	= mod:NewSpecialWarningMove(312819, false)

mod:AddBoolOption("PlaySoundOnFlashFreeze", true, "announce")
mod:AddBoolOption("YellOnStormCloud", true, "announce")

local enrageTimer			= mod:NewBerserkTimer(475)
local timerFlashFreeze		= mod:NewCastTimer(9, 312818)
local timerFrozenBlows		= mod:NewBuffActiveTimer(20, 312816)
local timerFlashFrCD		= mod:NewCDTimer(50, 312818)
local timerAchieve			= mod:NewAchievementTimer(179, 3182, "TimerSpeedKill")

mod:AddBoolOption("SetIconOnStormCloud")

function mod:OnCombatStart(delay)
	enrageTimer:Start()
	timerAchieve:Start()
	timerFlashFrCD:Start(-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(312818,312465) then  --Ледяная вспышка
		timerFlashFreeze:Start()
		warnFlashFreeze:Show()
		timerFlashFrCD:Start()
		if self.Options.PlaySoundOnFlashFreeze then
			PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312817, 312816,312464,312463) then --Ледяные дуновения
		timerFrozenBlows:Start()
	elseif args:IsSpellID(312831, 312478) then -- Грозовая туча 
		warnStormCloud:Show(args.destName)
		if self.Options.YellOnStormCloud and args:IsPlayer() then
			SendChatMessage(L.YellCloud, "SAY")
		end
		if self.Options.SetIconOnStormCloud then 
			self:SetIcon(args.destName, 8, 6)
		end
	end
end

do 
	local lastbitingcold = 0
	function mod:SPELL_DAMAGE(args)
		if args:IsSpellID(312819, 312466) and args:IsPlayer() and time() - lastbitingcold > 4 then		-- Трескучий мороз
			specWarnBitingCold:Show()
			lastbitingcold = time()
		end
	end
end