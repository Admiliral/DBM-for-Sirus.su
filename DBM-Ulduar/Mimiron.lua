local mod	= DBM:NewMod("Mimiron", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

mod:SetCreatureID(33432)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterCombat("yell", L.YellPull)
mod:RegisterCombat("yell", L.YellHardPull)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_AURA_REMOVED",
	"UNIT_SPELLCAST_CHANNEL_STOP",
	"UNIT_SPELLCAST_SUCCEEDED",
	"CHAT_MSG_LOOT",
	"SPELL_SUMMON"
)


local blastWarn					= mod:NewTargetAnnounce(312790, 4)
local shellWarn					= mod:NewTargetAnnounce(312788, 2)
local lootannounce				= mod:NewAnnounce("MagneticCore", 1)
local warnBombSpawn				= mod:NewAnnounce("WarnBombSpawn", 3)
local warnFrostBomb				= mod:NewSpellAnnounce(64623, 3)

local warnShockBlast			= mod:NewSpecialWarningRun(63631, "Melee", nil, nil, 4, 2)
local warnRocketStrike			= mod:NewSpecialWarningDodge(64402, nil, nil, nil, 2, 2)
local warnDarkGlare				= mod:NewSpecialWarning("WarningSpinUp", nil, nil, nil, 3, 2)
local warnPlasmaBlast			= mod:NewSpecialWarningDefensive(64529, nil, nil, nil, 1, 2)

local enrage 					= mod:NewBerserkTimer(900)
local timerHardmode				= mod:NewTimer(607, "TimerHardmode", 312812)
local timerP1toP2				= mod:NewTimer(43, "TimeToPhase2", nil, nil, 6)
local timerP2toP3				= mod:NewTimer(32, "TimeToPhase3", nil, nil, 6)
local timerP3toP4				= mod:NewTimer(25, "TimeToPhase4", nil, nil, 6)
local timerProximityMines		= mod:NewNextTimer(35, 63027, nil, nil, nil, 3)
local timerShockBlast			= mod:NewCastTimer(4, 312792, nil, nil, nil, 2)
local timerShockBlastCD			= mod:NewCDTimer(35, 312792, nil, nil, nil, 2)
local timerNextRockets		    = mod:NewNextTimer(20, 63041, nil, nil, nil, 3)
local timerSpinUp				= mod:NewCastTimer(4, 312794, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
local timerDarkGlareCast		= mod:NewCastTimer(10, 63293, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
local timerNextDarkGlare		= mod:NewNextTimer(41, 63293, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON) -- Лазерный обстрел P3Wx2
local timerNextShockblast		= mod:NewNextTimer(34, 312792, nil, nil, nil, 2)
local timerPlasmaBlastCD		= mod:NewCDTimer(30, 312790, nil, "Tank", 2, 5)
local timerShell				= mod:NewTargetTimer(6, 312788, nil, "Healer", 2, 5, nil, DBM_CORE_HEALER_ICON)
local timerFlameSuppressant		= mod:NewCastTimer(59, 312793, nil, nil, nil, 3)
local timerNextFlameSuppressant	= mod:NewNextTimer(10, 312793, nil, nil, nil, 3)
local timerNextFlames			= mod:NewNextTimer(27.5, 312803, nil, nil, nil, 3)
local timerNextFrostBomb        = mod:NewNextTimer(30, 64623, nil, nil, nil, 3, nil, DBM_CORE_HEROIC_ICON) --Ледяная бомба
local timerBombExplosion		= mod:NewCastTimer(15, 312804, nil, nil, nil, 3)



mod:AddSetIconOption("SetIconOnNapalm", 65026, false, false, {1, 2, 3, 4, 5, 6, 7})
mod:AddSetIconOption("SetIconOnPlasmaBlast", 64529, false, false, {8})
mod:AddRangeFrameOption("6")
mod:AddBoolOption("HealthFramePhase4", true)
mod:AddBoolOption("AutoChangeLootToFFA", true)
mod:AddBoolOption("RangeFrame")
mod:AddBoolOption("YellOnblastWarn", true)
mod:AddBoolOption("YellOnshellWarn", true)

mod.vb.hardmode = false
mod.vb.phase = 0
mod.vb.napalmShellIcon = 7
local spinningUp = DBM:GetSpellInfo(312794)
local lastSpinUp = 0
mod.vb.is_spinningUp = false
local napalmShellTargets = {}

local function warnNapalmShellTargets(self)
	shellWarn:Show(table.concat(napalmShellTargets, "<, >"))
	table.wipe(napalmShellTargets)
	self.vb.napalmShellIcon = 7
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 33432, "Mimiron")
	self.vb.hardmode = false
	enrage:Start(-delay)
	self.vb.phase = 0
	self.vb.is_spinningUp = false
	self.vb.napalmShellIcon = 7
	self:NextPhase()
	timerPlasmaBlastCD:Start(20-delay)
	timerShockBlastCD:Start(20.7-delay)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(10)
	end
end

function mod:OnCombatEnd()
	DBM:FireCustomEvent("DBM_EncounterEnd", 33432, "Mimiron", wipe)
	DBM.BossHealth:Hide()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:Flames()
	timerNextFlames:Start()
	self:ScheduleMethod(30, "Flames")
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(63811, 63801, 312807) then -- Bomb Bot
		warnBombSpawn:Show()
	end
end


function mod:UNIT_SPELLCAST_CHANNEL_STOP(unit, _, spellId)
	local spell = DBM:GetSpellInfo(spellId)--DO BETTER with log
	if spell == spinningUp and GetTime() - lastSpinUp < 3.9 then
		self.vb.is_spinningUp = false
		self:SendSync("SpinUpFail")
	end
end

function mod:CHAT_MSG_LOOT(msg)
	-- DBM:AddMsg(msg) --> Meridium receives loot: [Magnetic Core]
	local player, itemID = msg:match(L.LootMsg)
	if player and itemID and tonumber(itemID) == 46029 and self:IsInCombat() then
		player = DBM:GetUnitFullName(player)
		self:SendSync("LootMsg", player)
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(312792) then
		if self.vb.phase == 1 and self.Options.ShockBlastWarningInP1 or self.vb.phase == 4 and self.Options.ShockBlastWarningInP4 then
			warnShockBlast:Show()
		end
		warnShockBlast:Show()
		warnShockBlast:Play("runout")
		timerShockBlast:Start()
		timerNextShockblast:Start()

	elseif args:IsSpellID(312790, 312791) then -- plasma blast
		timerPlasmaBlastCD:Start()
		local tanking, status = UnitDetailedThreatSituation("player", "boss1")--Change boss unitID if it's not boss 1
		if tanking or (status == 3) then
			warnPlasmaBlast:Show()
			warnPlasmaBlast:Play("defensive")
		end
	elseif self.Options.YellOnblastWarn and args:IsPlayer() then
		SendChatMessage(L.YellblastWarn, "SAY")

	elseif args:IsSpellID(312793) then
		timerFlameSuppressant:Start()

	elseif args:IsSpellID(64623) then
		warnFrostBomb:Show()
		timerBombExplosion:Start()
		timerNextFrostBomb:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312435, 312788) and args:IsDestTypePlayer() then -- Napalm Shell
		napalmShellTargets[#napalmShellTargets + 1] = args.destName
		timerShell:Start()
		if self.Options.SetIconOnNapalm then
			self:SetIcon(args.destName, self.vb.napalmShellIcon, 6)
		end
		self.vb.napalmShellIcon = self.vb.napalmShellIcon - 1
		self:Unschedule(warnNapalmShellTargets)
		self:Schedule(0.3, warnNapalmShellTargets, self)
        if self.Options.YellOnshellWarn and args:IsPlayer() then
			SendChatMessage(L.YellshellWarn, "SAY")
		end
	elseif args:IsSpellID(312790, 312791) then -- Plasma Blast
		blastWarn:Show(args.destName)
		if self.Options.SetIconOnPlasmaBlast then
			self:SetIcon(args.destName, 8, 6)
		end
	end
end

local function show_warning_for_spinup(self)
	if self.vb.is_spinningUp then
		warnDarkGlare:Show()
		if mod.Options.PlaySoundOnDarkGlare then
			PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(312789, 63667, 63027) then				-- mines
		timerProximityMines:Start()

	elseif args:IsSpellID(312794, 312441) then			-- Spinning UP (before Dark Glare)
		self.vb.is_spinningUp = true
		timerSpinUp:Start()
		timerDarkGlareCast:Schedule(4)
		timerNextDarkGlare:Schedule(19)			-- 4 (cast spinup) + 15 sec (cast dark glare)
		DBM:Schedule(0.15, show_warning_for_spinup)	-- wait 0.15 and then announce it, otherwise it will sometimes fail
		lastSpinUp = GetTime()
	elseif args:IsSpellID(312793) then
		timerNextFlameSuppressant:Start()
	elseif args:IsSpellID(63041) then
		timerNextRockets:Start()
	end

end

function mod:NextPhase()
	self.vb.phase = self.vb.phase + 1
	if self.vb.phase == 1 then
		timerFlameSuppressant:Start()
		timerShockBlast:Start(30)
		if self.Options.HealthFrame then
			DBM.BossHealth:Clear()
			DBM.BossHealth:AddBoss(33432, L.MobPhase1)
		end

	elseif self.vb.phase == 2 then
		timerNextShockblast:Stop()
		timerProximityMines:Stop()
		timerFlameSuppressant:Stop()
		timerP1toP2:Start()
		timerNextDarkGlare:Start(85)
		if self.Options.HealthFrame then
			DBM.BossHealth:Clear()
			DBM.BossHealth:AddBoss(33651, L.MobPhase2)
		end
		if self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
		if self.vb.hardmode then
            timerNextFrostBomb:Start(114)
        end

	elseif self.vb.phase == 3 then
		timerDarkGlareCast:Cancel()
		timerNextDarkGlare:Cancel()
		timerNextFrostBomb:Cancel()
		timerP2toP3:Start()
		if self.Options.HealthFrame then
			DBM.BossHealth:Clear()
			DBM.BossHealth:AddBoss(33670, L.MobPhase3)
		end

	elseif self.vb.phase == 4 then
		timerP3toP4:Start()
		if self.vb.hardmode then
			timerNextFrostBomb:Start(32)
		end
		if self.Options.HealthFramePhase4 or self.Options.HealthFrame then
			DBM.BossHealth:Show(L.name)
			DBM.BossHealth:AddBoss(33670, L.MobPhase3)
			DBM.BossHealth:AddBoss(33651, L.MobPhase2)
			DBM.BossHealth:AddBoss(33432, L.MobPhase1)
		end
		if self.vb.hardmode then
			self:UnscheduleMethod("Flames")
			self:Flames()
            timerNextFrostBomb:Start(73)
        end
	end
end

do
	local count = 0
	local last = 0
	local lastPhaseChange = 0
	function mod:SPELL_AURA_REMOVED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if GetTime() - lastPhaseChange > 30 and (cid == 33432 or cid == 33651 or cid == 33670) then
			if args.timestamp == last then	-- all events in the same tick to detect the phases earlier (than the yell) and localization-independent
				count = count + 1
				if (mod:IsDifficulty("heroic10") and count > 4) or (mod:IsDifficulty("heroic25") and count > 9) then
					lastPhaseChange = GetTime()
					self:NextPhase()
				end
			else
				count = 1
			end
			last = args.timestamp
		elseif args:IsSpellID(312435, 312788) then -- Napalm Shell
			if self.Options.SetIconOnNapalm then
				self:SetIcon(args.destName, 0)
			end
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellPhase2 or msg:find(L.YellPhase2) then
		--DBM:AddMsg("ALPHA: yell detect phase2, syncing to clients")
		self:SendSync("Phase2")	-- untested alpha! (this will result in a wrong timer)

	elseif msg == L.YellPhase3 or msg:find(L.YellPhase3) then
		--DBM:AddMsg("ALPHA: yell detect phase3, syncing to clients")
		self:SendSync("Phase3")	-- untested alpha! (this will result in a wrong timer)

	elseif msg == L.YellPhase4 or msg:find(L.YellPhase4) then
		--DBM:AddMsg("ALPHA: yell detect phase3, syncing to clients")
		self:SendSync("Phase4") -- SPELL_AURA_REMOVED detection might fail in phase 3...there are simply not enough debuffs on him

	elseif msg == L.YellHardPull or msg:find(L.YellHardPull) then
		timerHardmode:Start()
		timerFlameSuppressant:Start()
		enrage:Stop()
		self.vb.hardmode = true
		timerNextFlames:Start(6.5)
		self:ScheduleMethod(6.5, "Flames")
	end
end


function mod:OnSync(event, args)
	if event == "SpinUpFail" then
		self.vb.is_spinningUp = false
		timerSpinUp:Cancel()
		timerDarkGlareCast:Cancel()
		timerNextDarkGlare:Cancel()
		warnDarkGlare:Cancel()
	elseif event == "Phase2" and self.vb.phase == 1 then -- alternate localized-dependent detection
		self:NextPhase()
	elseif event == "Phase3" and self.vb.phase == 2 then
		self:NextPhase()
	elseif event == "Phase4" and self.vb.phase == 3 then
		self:NextPhase()
	elseif event == "LootMsg" and args and self:AntiSpam(2, 1) then
		lootannounce:Show(args)
	end
end