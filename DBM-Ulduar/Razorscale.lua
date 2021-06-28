local mod	= DBM:NewMod("Razorscale", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501002800")

mod:SetCreatureID(33186)
mod:RegisterCombat("yell", L.YellAir)
mod:SetUsedIcons(8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_MISSED",
	"SPELL_DAMAGE",
	"CHAT_MSG_MONSTER_YELL",
	"RAID_BOSS_EMOTE",
	"UNIT_SPELLCAST_SUCCEEDED"
)
						-- Острокрылая--

local warnTurretsReadySoon			= mod:NewAnnounce("warnTurretsReadySoon", 1, 48642)
local warnTurretsReady				= mod:NewAnnounce("warnTurretsReady", 3, 48642)
local warnFlame						= mod:NewTargetAnnounce(64733, 2, nil, false)
local warnFuseArmor					= mod:NewStackAnnounce(64771, 2, nil, "Tank")

local specWarnDevouringFlame		= mod:NewSpecialWarningMove(64733, nil, nil, nil, 1, 2)
local specWarnDevouringFlameYou		= mod:NewSpecialWarningYou(64733, false, nil, nil, 1, 2)
local specWarnDevouringFlameNear	= mod:NewSpecialWarningClose(64733, false, nil, nil, 1, 2)
local yellDevouringFlame			= mod:NewYell(64733)
local specWarnFuseArmor				= mod:NewSpecialWarningStack(64771, nil, 2, nil, nil, 1, 6)
local specWarnFuseArmorOther		= mod:NewSpecialWarningTaunt(64771, nil, nil, nil, 1, 2)

local enrageTimer					= mod:NewBerserkTimer(900)
local timerDeepBreathCooldown		= mod:NewCDTimer(21, 64021, nil, nil, nil, 5)
local timerDeepBreathCast			= mod:NewCastTimer(2.5, 64021)
local timerTurret1					= mod:NewTimer(53, "timerTurret1", 48642, nil, nil, 5)
local timerTurret2					= mod:NewTimer(73, "timerTurret2", 48642, nil, nil, 5)
local timerTurret3					= mod:NewTimer(93, "timerTurret3", 48642, nil, nil, 5)
local timerTurret4					= mod:NewTimer(113, "timerTurret4", 48642, nil, nil, 5)
local timerGrounded                 = mod:NewTimer(35, "timerGrounded", nil, nil, nil, 6)
local timerFuseArmorCD				= mod:NewCDTimer(12.1, 64771, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)

local combattime = 0
local castFlames
function mod:FlameTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnDevouringFlameYou:Show()
		specWarnDevouringFlameYou:Play("targetyou")
		yellDevouringFlame:Yell()
	elseif targetname then
		if uId then
			local inRange = CheckInteractDistance(uId, 2)
			if inRange then
				specWarnDevouringFlameNear:Show(targetname)
				specWarnDevouringFlameNear:Play("runaway")
			end
		end
	else
		warnFlame:Show(targetname)
	end
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 33186, "Razorscale")
	enrageTimer:Start()
	combattime = GetTime()
	if mod:IsDifficulty("heroic10") then
		warnTurretsReadySoon:Schedule(53-delay)
		warnTurretsReady:Schedule(73-delay)
		timerTurret1:Start(-delay)
		timerTurret2:Start(-delay)
	else
		warnTurretsReadySoon:Schedule(93-delay)
		warnTurretsReady:Schedule(113-delay)
		timerTurret1:Start(-delay) -- 53sec
		timerTurret2:Start(-delay) -- +20
		timerTurret3:Start(-delay) -- +20
		timerTurret4:Start(-delay) -- +20
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33186, "Razorscale", wipe)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(63317, 64021) then	-- deep breath
		timerDeepBreathCast:Start()
		timerDeepBreathCooldown:Start()
	elseif args:IsSpellID(63236) then
		local target = self:GetBossTarget(self.creatureId)
		if target then
			self:CastFlame(target)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 64771 then
		local amount = args.amount or 1
        if amount >= 2 then
            if args:IsPlayer() then
                specWarnFuseArmor:Show(args.amount)
                specWarnFuseArmor:Play("stackhigh")
            else
				local _, _, _, _, _, expireTime = DBM:UnitDebuff("player", args.spellName)
				local remaining
				if expireTime then
					remaining = expireTime-GetTime()
				end
				if not UnitIsDeadOrGhost("player") and (not remaining or remaining and remaining < 12) then
					specWarnFuseArmorOther:Show(args.destName)
					specWarnFuseArmorOther:Play("tauntboss")
				else
					warnFuseArmor:Show(args.destName, amount)
				end
			end
		else
			warnFuseArmor:Show(args.destName, amount)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if (spellId == 64733 or spellId == 64704) and destGUID == UnitGUID("player") and self:AntiSpam() and not self:IsTrivial() then
		specWarnDevouringFlame:Show()
		specWarnDevouringFlame:Play("runaway")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:RAID_BOSS_EMOTE(emote)
	if emote == L.EmotePhase2 or emote:find(L.EmotePhase2) then
		-- phase2
		timerTurret1:Stop()
		timerTurret2:Stop()
		timerTurret3:Stop()
		timerTurret4:Stop()
		timerGrounded:Stop()
		timerFuseArmorCD:Start(15)
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg, mob)
	if (msg == L.YellAir or msg == L.YellAir2) and GetTime() - combattime > 30 then
		warnTurretsReadySoon:Schedule(93)
		warnTurretsReady:Schedule(113)
		timerTurret1:Start()
		timerTurret2:Start()
		timerTurret3:Start()
		timerTurret4:Start()
	elseif msg == L.YellGround then
		timerGrounded:Start()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 64821 then--Fuse Armor
		timerFuseArmorCD:Start()
	end
end
