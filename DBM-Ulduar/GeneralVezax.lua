local mod	= DBM:NewMod("GeneralVezax", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(33271)
mod:SetUsedIcons(7, 8)
mod:SetHotfixNoticeRev(20210716000000)
mod:RegisterCombat("combat", 33271)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)

local warnShadowCrash			= mod:NewTargetAnnounce(312978, 4) -- Темное сокрушение
local warnLeechLife				= mod:NewTargetAnnounce(312974, 3)

local specWarnShadowCrash		= mod:NewSpecialWarning("SpecialWarningShadowCrash")
local specWarnShadowCrashNear	= mod:NewSpecialWarning("SpecialWarningShadowCrashNear")
local specWarnSurgeDarkness		= mod:NewSpecialWarningCast(312981, "Tank", nil, 2, 1, 2)
local specWarnLifeLeechYou		= mod:NewSpecialWarningYou(312974)
local specWarnLifeLeechNear 	= mod:NewSpecialWarning("SpecialWarningLLNear", false)

local timerEnrage				= mod:NewBerserkTimer(600)
local timerSearingFlamesCast	= mod:NewCastTimer(2, 312977)
local timerSurgeofDarkness		= mod:NewBuffActiveTimer(10, 312981, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerNextSurgeofDarkness	= mod:NewCDTimer(62, 312981, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerSaroniteVapors		= mod:NewNextCountTimer(30, 312983, nil, nil, nil, 5)
local timerLifeLeech			= mod:NewTargetTimer(10, 312974)
local timerLeech				= mod:NewNextTimer(36, 312974)
local timerCrashArrow           = mod:NewNextTimer(15,312978)
local timerHardmode				= mod:NewTimer(195, "hardmodeSpawn", nil, nil, nil, 1)
local yellLifeLeech				= mod:NewYell(312974)
local yellLifeLeechFades		=mod:NewShortFadesYell(312974)
local yellShadowCrash			= mod:NewShortYell(312978)

mod:AddBoolOption("YellOnShadowCrash", true, "announce")
mod:AddBoolOption("SetIconOnShadowCrash", true, false, {8})
mod:AddBoolOption("SetIconOnLifeLeach", true, false, {7})
mod:AddBoolOption("CrashArrow")
mod:AddBoolOption("BypassLatencyCheck", false)--Use old scan method without syncing or latency check (less reliable but not dependant on other DBM users in raid)


function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 33271, "GeneralVezax")
	timerEnrage:Start(-delay)
	timerHardmode:Start(-delay)
	timerNextSurgeofDarkness:Start(-delay)
	timerCrashArrow:Start(5)
	timerLeech:Start(-delay)
	timerSaroniteVapors:Start(30-delay, 1)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33271, "GeneralVezax", wipe)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 312977 or spellId == 62661 then	-- Searing Flames
		timerSearingFlamesCast:Start()
	elseif spellId == 312981 or spellId == 62662 then
		specWarnSurgeDarkness:Show()
		timerNextSurgeofDarkness:Start()
	end
end

function mod:SPELL_INTERRUPT(args)
	local spellId = args.spellId
	if spellId == 312977 or spellId == 62661 then
		timerSearingFlamesCast:Stop()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 312981 or spellId == 62662 then	-- Surge of Darkness
		timerSurgeofDarkness:Start()
	elseif spellId == 312974 or spellId == 63276 then
		if self.Options.SetIconOnLifeLeach then
			self:SetIcon(args.destName, 7, 10)
		end
		warnLeechLife:Show(args.destName)
		timerLifeLeech:Start(args.destName)
		timerLeech:Start()
		if args:IsPlayer() then
			specWarnLifeLeechYou:Show()
			yellLifeLeech:Yell()
			yellLifeLeechFades:Countdown(spellId)
		else
			local uId = DBM:GetRaidUnitId(args.destName)
			if uId then
				local inRange = CheckInteractDistance(uId, 2)
				if inRange then
					specWarnLifeLeechNear:Show(args.destName)
				end
			end
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 312981 or spellId == 62662 then
		timerSurgeofDarkness:Stop()
	elseif spellId == 312974 or spellId == 63276 then
		if self.Options.SetIconOnLifeLeach then
			self:SetIcon(args.destName, 0)
		end
		if args:IsPlayer() then
			if self.Options.RangeFrame then
				DBM.RangeCheck:Hide()
			end
		end
	end
end

function mod:ShadowCrashTarget()
	local target = self:GetBossTarget(33271)
	if not target then return end
	if mod:LatencyCheck() then--Only send sync if you have low latency.
		self:SendSync("CrashOn", target)
	end
end

function mod:OldShadowCrashTarget()
	local targetname = self:GetBossTarget()
	if not targetname then return end
	if self.Options.SetIconOnShadowCrash then
		self:SetIcon(targetname, 8, 10)
	end
	warnShadowCrash:Show(targetname)
	if targetname == UnitName("player") then
		specWarnShadowCrash:Show(targetname)
		yellShadowCrash:Yell()
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
				specWarnShadowCrashNear:Show()
				if self.Options.CrashArrow then
					DBM.Arrow:ShowRunAway(x, y, 15, 5)
				end
			end
		end
	end
end


function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 312978 or spellId == 62660 then		-- Shadow Crash
		if self.Options.BypassLatencyCheck then
			self:ScheduleMethod(0.1, "OldShadowCrashTarget")
		else
			self:ScheduleMethod(0.1, "ShadowCrashTarget")
		end
	elseif spellId == 312974 or spellId == 63276 then -- Mark of the Faceless
		if self.Options.SetIconOnLifeLeach then
			self:SetIcon(args.destName, 7, 10)
		end
		warnLeechLife:Show(args.destName)
		timerLifeLeech:Start(args.destName)
		timerLeech:Start()
		if args:IsPlayer() then
			specWarnLifeLeechYou:Show()
			yellLifeLeech:Yell()
			yellLifeLeechFades:Countdown(spellId)
		else
			local uId = DBM:GetRaidUnitId(args.destName)
			if uId then
				local inRange = CheckInteractDistance(uId, 2)
				if inRange then
					specWarnLifeLeechNear:Show(args.destName)
				end
			end
		end
	end
end

function mod:RAID_BOSS_EMOTE(emote)
	if emote == L.EmoteSaroniteVapors or emote:find(L.EmoteSaroniteVapors) then
		self.vb.vaporsCount = self.vb.vaporsCount + 1
		if self.vb.vaporsCount < 6 then
			timerSaroniteVapors:Start(nil, self.vb.vaporsCount+1)
		end
	end
end

function mod:OnSync(msg, target)
	if msg == "CrashOn" then
		timerCrashArrow:Start()
		if not self.Options.BypassLatencyCheck then
			warnShadowCrash:Show(target)
			if self.Options.SetIconOnShadowCrash then
				self:SetIcon(target, 8, 10)
			end
			if target == UnitName("player") then
				specWarnShadowCrash:Show()
				if self.Options.YellOnShadowCrash then
					SendChatMessage(L.YellCrash, "SAY")
					else
					SendChatMessage(L.YellCrash, "RAID")
				end
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
						specWarnShadowCrashNear:Show()
						if self.Options.CrashArrow then
							DBM.Arrow:ShowRunAway(x, y, 15, 5)
						end
					end
				end
			end
		end
	end
end