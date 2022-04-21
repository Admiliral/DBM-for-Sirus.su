local mod	= DBM:NewMod("NorthrendBeasts", "DBM-Coliseum")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501160500")
mod:SetCreatureID(34797)
mod:SetMinCombatTime(30)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterCombat("yell", L.CombatStart)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_DAMAGE",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_DIED"
)

-- Общее --

local timerCombatStart		= mod:NewCombatTimer(17.5) -- комбат пул
local timerNextBoss			= mod:NewTimer(190, "TimerNextBoss", 2457, nil, nil, 1) -- следующее мясо

-- Гормок --

local warnImpaleOn			= mod:NewTargetAnnounce(67478, 2, nil, "Tank|Healer") -- Прокалывание
local warnFireBomb			= mod:NewSpellAnnounce(66317, 3, nil, false)	-- Огненная бомба
local WarningSnobold		= mod:NewAnnounce("WarningSnobold", 4) -- Снобольд

local specWarnImpale3		= mod:NewSpecialWarningStack(66331, nil, 3, nil, nil, 1, 6) -- Прокалывание
local specWarnAnger3		= mod:NewSpecialWarningStack(66636, "Tank|Healer", 3, nil, nil, 1, 6) -- Вскипающий гнев на гормоке
local specWarnFireBomb		= mod:NewSpecialWarningMove(66317, nil, nil, nil, 1, 2)	-- Огненная бомба
local specWarnSilence		= mod:NewSpecialWarningSpell(66330, "SpellCaster", nil, nil, 1, 2) -- осторожно сало

local timerNextStomp		= mod:NewNextTimer(15, 66330, nil, nil, nil, 2)	-- Сотрясающий топот
local timerNextImpale		= mod:NewNextTimer(8.5, 67477, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)	-- Прокалывание
local timerRisingAnger      = mod:NewNextTimer(20.5, 66636, nil, nil, nil, 1)	-- Вскипающий гнев

-- Утробы --

local warnSlimePool			= mod:NewSpellAnnounce(67643, 2, nil, "Melee") -- Появление лужи (утробы)
local warnToxin				= mod:NewTargetAnnounce(66823, 3)	-- Паралитический токсин
local warnBile				= mod:NewTargetAnnounce(66869, 3) -- Горящая желчь
local warnEnrageWorm		= mod:NewSpellAnnounce(68335, 3)	-- червь в Исступление

local specWarnSlimePool		= mod:NewSpecialWarningMove(67640) -- выбеги с лужи додик
local specWarnToxin			= mod:NewSpecialWarningMoveTo(67620, nil, nil, nil, 1, 2)	-- Паралитический токсин на тебе
local specWarnBile			= mod:NewSpecialWarningYou(66869, nil, nil, nil, 1, 2) -- Горящая желчь на тебе

local timerSweepCD			= mod:NewCDTimer(21, 66794, nil, "Melee", nil, 3)	-- Сбивание(утроба)
local timerSlimePoolCD		= mod:NewCDTimer(12, 66883, nil, "Melee", nil, 3)	-- Лужа жижи(утроба)
local timerAcidicSpewCD		= mod:NewCDTimer(21, 66819, nil, "Tank", 2, 5, nil, DBM_CORE_TANK_ICON)	-- Кислотная рвота(утроба)
local timerMoltenSpewCD		= mod:NewCDTimer(21, 66820, nil, "Tank", 2, 5, nil, DBM_CORE_TANK_ICON)	-- Жгучая рвота(утроба)
local timerParalyticSprayCD	= mod:NewCDTimer(25, 66901, nil, nil, nil, 3)	-- Парализующие брызги(утроба)
local timerBurningSprayCD	= mod:NewCDTimer(25, 66902, nil, nil, nil, 3)	-- Горящие брызги(утроба)
local timerParalyticBiteCD	= mod:NewCDTimer(25, 66824, nil, "Melee", nil, 3)	-- Парализующий укус(утроба)
local timerBurningBiteCD	= mod:NewCDTimer(15, 66879, nil, "Melee", nil, 3)	-- Обжигающий укус(утроба)

local timerSubmerge			= mod:NewTimer(43, "TimerSubmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp", nil, nil, 6) -- закопка
local timerEmerge			= mod:NewTimer(5, "TimerEmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp", nil, nil, 6) -- появление

-- Ледяной рев --

local warnBreath			= mod:NewSpellAnnounce(67650, 2)	-- Арктическое дыхание
local warnRage				= mod:NewSpellAnnounce(67657, 3)	-- Кипящая ярость

local specWarnCharge		= mod:NewSpecialWarningRun(52311, nil, nil, nil, 4, 2)	-- чардж беги
local specWarnChargeNear	= mod:NewSpecialWarningClose(52311, nil, nil, nil, 3, 2) -- чардж рядом
local specWarnTranq			= mod:NewSpecialWarningDispel(66759, "RemoveEnrage", nil, nil, 1, 2) -- диспел бафа рева

local timerBreath			= mod:NewCDTimer(20, 67650, nil, nil, nil, 3)	-- Арктическое дыхание
local timerStaggeredDaze	= mod:NewBuffActiveTimer(15, 66758, nil, nil, nil, 5, nil, DBM_CORE_DAMAGE_ICON)	-- Глубокое потрясение(рев)
local timerNextCrash		= mod:NewCDTimer(50, 67662, nil, nil, nil, 2)	-- Могучее сокрушение(рев)

local enrageTimer			= mod:NewBerserkTimer(223) 		-- берса рева


mod:AddSetIconOption("SetIconOnChargeTarget", 52311) 		-- череп на цель чарджа
mod:AddSetIconOption("SetIconOnBileTarget", 66869, false)	-- Иконки на людей с Горящая желчь
mod:AddBoolOption("ClearIconsOnIceHowl", false)				-- Снимать все иконки перед Топотом
mod:AddBoolOption("IcehowlArrow")							-- Показывать стрелку, когда Ледяной Рев готовится сделать рывок на цель рядом с вами
mod:AddBoolOption("PingCharge")								-- Показать на миникарте место, куда попадает Ледяной Рев, если он избрал вас целью
mod:AddBoolOption("RangeFrame")								-- Показывать окно проверки дистанции в фазе 2

local bileTargets			= {}
local toxinTargets			= {}
local burnIcon				= 8
local phases				= {}
local DreadscaleActive		= true  	-- Is dreadscale moving?
local DreadscaleDead		= false
local AcidmawDead			= false
local dead					= 0
mod.vb.phase 				= 1

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 34797, "The Beasts of Northrend")
	table.wipe(bileTargets)
	table.wipe(toxinTargets)
	table.wipe(phases)
	burnIcon = 8
	DreadscaleActive = true
	DreadscaleDead = false
	AcidmawDead = false
	self.vb.phase = 1
	specWarnSilence:Schedule(37-delay)
	if self:IsDifficulty("heroic10", "heroic25") then
		timerNextBoss:Start(175 - delay)
		timerNextBoss:Schedule(170)
	end
	timerNextStomp:Start(26.5-delay)
	timerRisingAnger:Start(38-delay)
	timerCombatStart:Start(-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 34797, "The Beasts of Northrend", wipe)
	charge = 0
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:warnToxin()
	warnToxin:Show(table.concat(toxinTargets, "<, >"))
	table.wipe(toxinTargets)
end

function mod:warnBile()
	warnBile:Show(table.concat(bileTargets, "<, >"))
	table.wipe(bileTargets)
	burnIcon = 8
end

function mod:WormsEmerge()	-- Пока оставлю не тронутым, в будущем реворкну
	timerSubmerge:Show()
	if not AcidmawDead then
		if DreadscaleActive then
			timerSweepCD:Start(16)
			timerParalyticSprayCD:Start(22)
		else
			timerSubmerge:Stop()
			timerSlimePoolCD:Start(14)
			timerParalyticBiteCD:Start(5)
			timerAcidicSpewCD:Start(10)
		end
	end
	if not DreadscaleDead then
		if DreadscaleActive then
			timerSlimePoolCD:Start(14)
			timerMoltenSpewCD:Start(10)
			timerBurningBiteCD:Start(5)
		else
			timerSubmerge:Cancel()
			timerSweepCD:Start(16)
			timerBurningSprayCD:Start(17)
		end
	end
	self:ScheduleMethod(43, "WormsSubmerge")
end

function mod:WormsSubmerge()	-- Пока оставлю не тронутым, в будущем реворкну
	timerEmerge:Show()
	timerSweepCD:Cancel()
	timerSlimePoolCD:Cancel()
	timerMoltenSpewCD:Cancel()
	timerParalyticSprayCD:Cancel()
	timerBurningBiteCD:Cancel()
	timerAcidicSpewCD:Cancel()
	timerBurningSprayCD:Cancel()
	timerParalyticBiteCD:Cancel()
	DreadscaleActive = not DreadscaleActive
	self:ScheduleMethod(10, "WormsEmerge")
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(67477, 66331, 67478, 67479) then		-- Impale
		timerNextImpale:Start()
		warnImpaleOn:Show(args.destName)
	elseif args:IsSpellID(67657, 66759, 67658, 67659) then	-- Frothing Rage
		warnRage:Show()
		specWarnTranq:Show()
	elseif args:IsSpellID(66823, 67618, 67619, 67620) then	-- Paralytic Toxin
		self:UnscheduleMethod("warnToxin")
		toxinTargets[#toxinTargets + 1] = args.destName
		if args:IsPlayer() then
			specWarnToxin:Show()
		end
		mod:ScheduleMethod(0.2, "warnToxin")
	elseif args:IsSpellID(66869) then		-- Burning Bile
		self:UnscheduleMethod("warnBile")
		bileTargets[#bileTargets + 1] = args.destName
		if args:IsPlayer() then
			specWarnBile:Show()
		end
		if self.Options.SetIconOnBileTarget and burnIcon > 0 then
			self:SetIcon(args.destName, burnIcon, 15)
			burnIcon = burnIcon - 1
		end
		mod:ScheduleMethod(0.2, "warnBile")
	elseif args:IsSpellID(66758) then
		timerStaggeredDaze:Start()
	elseif args:IsSpellID(66636) then						-- Rising Anger
		WarningSnobold:Show()
		timerRisingAnger:Show()
	elseif args:IsSpellID(68335) then
		warnEnrageWorm:Show()
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args:IsSpellID(67477, 66331, 67478, 67479) then		-- Impale
		timerNextImpale:Start()
		warnImpaleOn:Show(args.destName)
		if (args.amount >= 3 and not self:IsDifficulty("heroic10", "heroic25") ) or ( args.amount >= 2 and self:IsDifficulty("heroic10", "heroic25") ) then
			if args:IsPlayer() then
				specWarnImpale3:Show(args.amount)
			end
		end
	elseif args:IsSpellID(66636) then						-- Rising Anger
		WarningSnobold:Show()
		if args.amount <= 3 then
			timerRisingAnger:Show()
		elseif args.amount >= 3 then
			specWarnAnger3:Show(args.amount)
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(66689, 67650, 67651, 67652) then			-- Arctic Breath
		timerBreath:Start()
		warnBreath:Show()
	elseif args:IsSpellID(66313) then							-- FireBomb (Impaler)
		warnFireBomb:Show()
	elseif args:IsSpellID(66330, 67647, 67648, 67649) then		-- Staggering Stomp
		timerNextStomp:Start()
		specWarnSilence:Schedule(19)							-- prewarn ~1,5 sec before next
	elseif args:IsSpellID(66794, 67644, 67645, 67646) then		-- Sweep stationary worm
		timerSweepCD:Start()
	elseif args:IsSpellID(66821) then							-- Molten spew
		timerMoltenSpewCD:Start()
	elseif args:IsSpellID(66818) then							-- Acidic Spew
		timerAcidicSpewCD:Start()
	elseif args:IsSpellID(66901, 67615, 67616, 67617) then		-- Paralytic Spray
		timerParalyticSprayCD:Start()
	elseif args:IsSpellID(66902, 67627, 67628, 67629) then		-- Burning Spray
		timerBurningSprayCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(67641, 66883, 67642, 67643) then			-- Slime Pool Cloud Spawn
		warnSlimePool:Show()
		timerSlimePoolCD:Show()
	elseif args:IsSpellID(66689, 67650, 67651, 67652) then		-- Arctic Breath
		timerBreath:Start()
		warnBreath:Show()
	elseif args:IsSpellID(66824, 67612, 67613, 67614) then		-- Paralytic Bite
		timerParalyticBiteCD:Start()
	elseif args:IsSpellID(66879, 67624, 67625, 67626) then		-- Burning Bite
		timerBurningBiteCD:Start()
	end
end

function mod:SPELL_DAMAGE(args)
	if args:IsPlayer() and (args:IsSpellID(66320, 67472, 67473, 67475) or args:IsSpellID(66317)) then	-- Fire Bomb (66317 is impact damage, not avoidable but leaving in because it still means earliest possible warning to move. Other 4 are tick damage from standing in it)
		specWarnFireBomb:Show()
	elseif args:IsPlayer() and args:IsSpellID(66881, 67638, 67639, 67640) then							-- Slime Pool
		specWarnSlimePool:Show()
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, _, _, _, target)
	if msg:match(L.Charge) or msg:find(L.Charge) then
		timerNextCrash:Start(45)
		timerBreath:Start(27)
		if self.Options.ClearIconsOnIceHowl then
			self:ClearIcons()
		end
		if target == UnitName("player") then
			specWarnCharge:Show()
			if self.Options.PingCharge then
				Minimap:PingLocation()
			end
		else
			local uId = DBM:GetRaidUnitId(target)
			if uId then
				local inRange = CheckInteractDistance(uId, 2)
				local x, y = GetPlayerMapPosition(uId)
				if x == 0 and y == 0 then
					SetMapToCurrentZone()
					x, y = GetPlayerMapPosition(uId)
				end
				if inRange then
					specWarnChargeNear:Show()
					if self.Options.IcehowlArrow then
						DBM.Arrow:ShowRunAway(x, y, 12, 5)
					end
				end
			end
		end
		if self.Options.SetIconOnChargeTarget then
			self:SetIcon(target, 8, 5)
		end
	end
	if msg:match(L.Rage) or msg:find(L.Rage) then
		if	timerBreath:GetRemaining() then
			local elapsed = timerBreath:GetTime()
			timerBreath:Stop()
			timerBreath:Update(0, 5 + elapsed)
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.CombatStart or msg:find(L.CombatStart) then
		timerCombatStart:Start()
	elseif msg == L.Phase2 or msg:find(L.Phase2) then
		self:ScheduleMethod(17, "WormsEmerge")
		timerNextBoss:Start(137)
		timerCombatStart:Start(11.5)
		self.vb.phase = 2
		if self.Options.RangeFrame then
			DBM.RangeCheck:Show(10)
		end
	elseif msg == L.Phase3 or msg:find(L.Phase3) then
		self.vb.phase = 3
		charge = 2
		if self:IsDifficulty("heroic10", "heroic25") then
			enrageTimer:Start()
			timerBreath:Start(29)
		end
		if self:IsDifficulty("normal10", "normal25") then
			timerBreath:Start(23)
		end
		self:UnscheduleMethod("WormsSubmerge")
		timerNextCrash:Start(35)
		timerNextBoss:Cancel()
		timerEmerge:Cancel()
		timerSubmerge:Cancel()
		if self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
	end
end

function mod:UNIT_DIED(args)
	if UnitName("player") then
		dead = dead + 1
	end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 34796 then
		specWarnSilence:Cancel()
		timerNextStomp:Stop()
		timerNextImpale:Stop()
		DBM.BossHealth:RemoveBoss(cid) -- remove Gormok from the health frame
	elseif cid == 35144 then
		AcidmawDead = true
		timerParalyticSprayCD:Cancel()
		timerParalyticBiteCD:Cancel()
		timerAcidicSpewCD:Cancel()
		if DreadscaleActive then
			timerSweepCD:Cancel()
		else
			timerSlimePoolCD:Cancel()
		end
		if DreadscaleDead then
			DBM.BossHealth:RemoveBoss(35144)
			DBM.BossHealth:RemoveBoss(34799)
		end
	elseif cid == 34799 then
		DreadscaleDead = true
		timerBurningSprayCD:Cancel()
		timerBurningBiteCD:Cancel()
		timerMoltenSpewCD:Cancel()
		if DreadscaleActive then
			timerSlimePoolCD:Cancel()
		else
			timerSweepCD:Cancel()
		end
		if AcidmawDead then
			DBM.BossHealth:RemoveBoss(35144)
			DBM.BossHealth:RemoveBoss(34799)
		end
	elseif cid == 34799 and cid == 35144 then
		timerEmerge:Cancel()
		timerSubmerge:Cancel()
	end
end

