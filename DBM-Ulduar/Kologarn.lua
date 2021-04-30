local mod	= DBM:NewMod("Kologarn", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210429163700")

mod:SetCreatureID(32930)
mod:RegisterCombat("yell",L.YellPull)
mod:SetUsedIcons(5, 6, 7, 8)


mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"SPELL_DAMAGE",
	"CHAT_MSG_RAID_BOSS_WHISPER",
	"UNIT_DIED"
)

mod:SetBossHealthInfo(
	32930, L.Health_Body,
	32934, L.Health_Right_Arm,
	32933, L.Health_Left_Arm
)

local warnFocusedEyebeam		= mod:NewTargetAnnounce(312765, 3)
local warnGrip					= mod:NewTargetAnnounce(312757, 2)
local warnCrunchArmor			= mod:NewTargetAnnounce(312748, 2)

local specWarnCrunchArmor2		= mod:NewSpecialWarningStack(312748, false, 2)
local specWarnEyebeam			= mod:NewSpecialWarningYou(312765)

local timerCrunch10             = mod:NewTargetTimer(6, 312395)
local timerNextShockwave		= mod:NewCDTimer(18, 312752)
local timerRespawnLeftArm		= mod:NewTimer(48, "timerLeftArm")
local timerRespawnRightArm		= mod:NewTimer(48, "timerRightArm")
local timerTimeForDisarmed		= mod:NewTimer(10, "achievementDisarmed")	-- 10 HC / 12 nonHC



mod:AddBoolOption("HealthFrame", true)
mod:AddBoolOption("SetIconOnGripTarget", true)
mod:AddBoolOption("PlaySoundOnEyebeam", true)
mod:AddBoolOption("SetIconOnEyebeamTarget", true)
mod:AddBoolOption("YellOnGrip", true)

function mod:UNIT_DIED(args)
	if self:GetCIDFromGUID(args.destGUID) == 32934 then 		-- Правая рука
		timerRespawnRightArm:Start()
		if mod:IsDifficulty("heroic10") then
			timerTimeForDisarmed:Start(12)
		else
			timerTimeForDisarmed:Start()
		end
	elseif self:GetCIDFromGUID(args.destGUID) == 32933 then		-- Левая рука
		timerRespawnLeftArm:Start()
		if mod:IsDifficulty("heroic10") then
			timerTimeForDisarmed:Start(12)
		else
			timerTimeForDisarmed:Start()
		end
	end
end

function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(312399, 312752) and args:IsPlayer() then	-- Ударная волна
		timerNextShockwave:Start()
	elseif args:IsSpellID(312412, 312765) and args:IsPlayer() then --Сосредоточенный взгляд
		specWarnEyebeam:Show()
	end
end

function mod:CHAT_MSG_RAID_BOSS_WHISPER(msg)
	if msg:find(L.FocusedEyebeam) then
		self:SendSync("EyeBeamOn", UnitName("player"))
	end
end

function mod:OnSync(msg, target)
	if msg == "EyeBeamOn" then
		warnFocusedEyebeam:Show(target)
		if target == UnitName("player") then
			specWarnEyebeam:Show()
			if self.Options.PlaySoundOnEyebeam then
				PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav") 
			end
			
		end 
		if self.Options.SetIconOnEyebeamTarget then
			self:SetIcon(target, 5, 8) 
		end
	end
end

local gripTargets = {}
function mod:GripAnnounce()
	warnGrip:Show(table.concat(gripTargets, "<, >"))
	table.wipe(gripTargets)
end
function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312758,312757,312760,312407,312405,312404) then 	--Каменная хватка				 --Каменная хватка
		if self.Options.SetIconOnGripTarget then
			self:SetIcon(args.destName, 8 - #gripTargets, 10)
		end
		table.insert(gripTargets, args.destName)
		self:UnscheduleMethod("GripAnnounce")
		if #gripTargets >= 3 then
			self:GripAnnounce()
		else
			self:ScheduleMethod(0.2, "GripAnnounce")
		end
		if self.Options.YellOnGrip  and args:IsPlayer() then
			SendChatMessage(L.YellGrip , "SAY")
		end
	elseif args:IsSpellID(312748, 312395) then	-- Хруст доспеха
        warnCrunchArmor:Show(args.destName)
		if mod:IsDifficulty("heroic10") then
            timerCrunch10:Start(args.destName)  -- We track duration timer only in 10-man since it's only 6sec and tanks don't switch.
		end
    end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args:IsSpellID(312748) then		        -- Хруст доспеха (25-man only)
		warnCrunchArmor:Show(args.destName)
        if args.amount >= 2 then 
            if args:IsPlayer() then
                specWarnCrunchArmor2:Show(args.amount)
            end
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(312758,312757,312760,312407,312405,312404) then  -- Вопрос дохуя хваток
		self:SetIcon(args.destName, 0)
    end
end