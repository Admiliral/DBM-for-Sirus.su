local mod	= DBM:NewMod("Fathomlord", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20201004021400")

mod:SetCreatureID(21214)
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(4, 5, 6, 7, 8)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_EMOTE",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_HEALTH"
)


local warnNovaSoon       = mod:NewSoonAnnounce(38445, 3)   -- Огненная звезда
local specWarnNova       = mod:NewSpecialWarningSpell(38445)  -- Огненная звезда

local timerNovaCD        = mod:NewCDTimer(26, 38445, nil, nil, nil, 2)
local timerSpitfireCD    = mod:NewCDTimer(60, 38236, nil, nil, nil, 2)

local berserkTimer          = mod:NewBerserkTimer(600)

------------------------ХМ-------------------------

local warnPhase2Soon		= mod:NewPrePhaseAnnounce(2)
local warnPhase2    		= mod:NewPhaseAnnounce(2)
local warnStrela            = mod:NewTargetAnnounce(309253, 3) -- Стрела катаклизма
local warnKaraTarget        = mod:NewAnnounce("WarnKaraTarget", 4)


local specWarnKaraTarget    = mod:NewSpecialWarning("SpecWarnKaraTarget", nil, nil, nil, 1, 2)

local timerKaraTarget       = mod:NewTimer(8.5, "TimerKaraTarget", "Interface\\Icons\\Spell_Fire_BurningSpeed")
local timerPhaseCast        = mod:NewCastTimer(65, 309292, nil, nil, nil, 6) -- Скользящий натиск
local timerStrelaCast		= mod:NewCastTimer(6, 309253, nil, nil, nil, 3) -- Стрела катаклизма
local timerStrelaCD			= mod:NewCDTimer(43, 309253, nil, nil, nil, 3) -- Стрела катаклизма

-----------Карибдис-----------
local warnZalp              = mod:NewSpellAnnounce(309305, 2) -- Залп стрел
local warnGnevSoon          = mod:NewSoonAnnounce(309281, 2) -- Гнев прилива
local warnKop	            = mod:NewSpellAnnounce(309286, 3) -- Водяное копье
-----------Волнис-----------
local warnOko               = mod:NewSpellAnnounce(309258, 2) -- Око шторма
local warnByr               = mod:NewTargetAnnounce(309270, 3) -- Неистовство бури
local warnStorm             = mod:NewSpellAnnounce(309272, 2) -- Порыв шторма
-----------Шарккис-----------
local warnSvaz              = mod:NewTargetAnnounce(309262, 3) -- Пламенная связь
local warnPust		        = mod:NewStackAnnounce(309277, 5, nil, "Tank") -- Опустошающее пламя

-----------Карибдис-----------
local specWarnVis			= mod:NewSpecialWarningInterrupt(309256, nil, nil, 1, 1, 2) -- Исцеление (возможно надо ебнуть фалс по умолчанию)
local specWarnGnev          = mod:NewSpecialWarningMove(309281, "Melee", nil, nil, 3, 2) -- Гнев прилива
-----------Волнис-----------
local specWarnOko           = mod:NewSpecialWarningStopMove(309258, nil, nil, nil, 3) -- Око шторма
-----------Шарккис-----------
local specWarnSvaz          = mod:NewSpecialWarningMoveAway(309262, nil, nil, nil, 1, 3) -- Пламенная свзяь

-----------Карибдис-----------
local timerVisCD			= mod:NewCDTimer(29, 309256, nil, nil, nil, 4) -- Исцеление
local timerVisCast			= mod:NewCastTimer(1, 309256, nil, nil, nil, 4) -- Исцеление
local timerZalpCD			= mod:NewCDTimer(12, 309305, nil, nil, nil, 2) -- Залп стрел
local timerGnevCD			= mod:NewCDTimer(19, 309281, nil, nil, nil, 2) -- Гнев прилива
local timerGnevCast			= mod:NewCastTimer(2, 309281, nil, nil, nil, 2) -- Гнев прилива
local timerKopCD			= mod:NewCDTimer(3, 309286, nil, nil, nil, 3) -- Водяное копье
-----------Волнис-----------
local timerOkoCD			= mod:NewCDTimer(16, 309258, nil, nil, nil, 2) -- Око шторма
local timerOkoCast			= mod:NewCastTimer(8, 309258, nil, nil, nil, 2) -- Око шторма
local timerByrCast			= mod:NewCastTimer(10, 309270, nil, nil, nil, 3) -- Неистовство бури
local timerStormCD			= mod:NewCDTimer(9, 309272, nil, nil, nil, 2) -- Порыв шторма
-----------Шарккис-----------
local timerSvazCD			= mod:NewCDTimer(25, 309262, nil, nil, nil, 3) -- Пламенная связь
local timerPustCD			= mod:NewCDTimer(5, 309277, nil, "Tank", nil, 5) -- Опустошающее пламя
local timerPust	        	= mod:NewTargetTimer(60, 309277, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON) -- Опустошающее пламя

mod:AddSetIconOption("SetIconOnSvazTargets", 309261, true, true, {5, 6, 7})
mod:AddBoolOption("AnnounceSvaz", false)

mod.vb.phase = 0
local SvazTargets = {}
local CastKop = 1
local SvazIcons = 7
local warned_preP1 = false
local warned_preP2 = false
local warned_P1 = false
local warned_P2 = false

do
	local function sort_by_group(v1, v2)
		return DBM:GetRaidSubgroup(UnitName(v1)) < DBM:GetRaidSubgroup(UnitName(v2))
	end
	function mod:SetSvazIcons()
		table.sort(SvazTargets, sort_by_group)
		for i, v in ipairs(SvazTargets) do
			if mod.Options.AnnounceSvaz then
				if DBM:GetRaidRank() > 0 then
					SendChatMessage(L.SvazIcon:format(SvazIcons, UnitName(v)), "RAID_WARNING")
				else
					SendChatMessage(L.SvazIcon:format(SvazIcons, UnitName(v)), "RAID")
				end
			end
			if self.Options.SetIconOnSvazTargets then
				self:SetIcon(UnitName(v), SvazIcons, 10)
			end
			SvazIcons = SvazIcons - 1
		end
		if #SvazTargets >= 3 then
			warnSvaz:Show(table.concat(SvazTargets, "<, >"))
			table.wipe(SvazTargets)
			SvazIcons = 7
		end
	end
end



function mod:OnCombatStart()
	DBM:FireCustomEvent("DBM_EncounterStart", 21214, "Fathom-Lord Karathress")
	if mod:IsDifficulty("heroic25") then
		self.vb.phase = 1
		berserkTimer:Start()
		local warned_preP1 = false
		local warned_preP2 = false
		local warned_P1 = false
		local warned_P2 = false
	else -- Обычка
		berserkTimer:Start()
		timerNovaCD:Start()
		timerSpitfireCD:Start()
		warnNovaSoon:Show(23)
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 21214, "Fathom-Lord Karathress", wipe)
end

--[[function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg:match(L.KaraTarget) then
		local target = msg:sub(29,-3) or "Unknown"
		warnKaraTarget:Show(target)
		timerKaraTarget:Start(target)
		if target == UnitName("player") then
			specWarnKaraTarget:Show()
		end
	end
end]]

function mod:UNIT_HEALTH(uId)
	if mod:IsDifficulty("heroic25") then
		if self.vb.phase == 1 and not warned_preP1 and self:GetUnitCreatureId(uId) == 21214 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.43 then
			warned_preP1 = true
			warnPhase2Soon:Show()
		end
		if self.vb.phase == 1 and not warned_P1 and self:GetUnitCreatureId(uId) == 21214 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.40 then
			warned_P1 = true
			warnPhase2:Show()
			timerPhaseCast:Start()
			self.vb.phase = 2
		end
		if self.vb.phase == 2 and not warned_preP2 and self:GetUnitCreatureId(uId) == 21214 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.18 then
			warned_preP2 = true
			warnPhase2Soon:Show()
		end
		if self.vb.phase == 2 and not warned_P2 and self:GetUnitCreatureId(uId) == 21214 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.15 then
			warned_P2 = true
			warnPhase2:Show()
			timerPhaseCast:Start()
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(38445) then -- Обычка
		warnNovaSoon:Show(23)
		specWarnNova:Show()
		timerNovaCD:Start()
	elseif args:IsSpellID(309253) then -- Стрела катаклизма
		warnStrela:Show(args.sourceName)
		timerStrelaCD:Start()
		timerStrelaCast:Start()
-----------Карибдис-----------
	elseif args:IsSpellID(309256) then -- Исцеление
		specWarnVis:Show(args.sourceName)
		timerVisCD:Start()
		timerVisCast:Start()
	elseif args:IsSpellID(309281) then -- Гнев прилива
		specWarnGnev:Show()
		warnGnevSoon:Show(17)
		timerGnevCD:Start()
		timerGnevCast:Start()
	elseif args:IsSpellID(309286) then -- Водяное копье
		if CastKop < 3 then
			warnKop:Show()
			timerKopCD:Start()
			CastKop = CastKop + 1
		else
			warnKop:Show()
			timerKopCD:Start(6)
			CastKop = 1
		end
-----------Волнис-----------
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(38236) then -- Обычка
		timerSpitfireCD:Start()
-----------Карибдис-----------
	elseif args:IsSpellID(309305) then -- Залп стрел
		warnZalp:Show(17)
		timerZalpCD:Start()
-----------Волнис-----------
	elseif args:IsSpellID(309258) then -- Око шторма
		warnOko:Show()
		timerOkoCD:Start()
	elseif args:IsSpellID(309270) then -- Неистовство бури
		warnByr:Show(args.destName)
		timerByrCast:Start()
	elseif args:IsSpellID(309272) then -- Порыв шторма
		warnStorm:Show()
		timerStormCD:Start()
-----------Шарккис-----------
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(309000) then
-----------Карибдис-----------

-----------Волнис-----------
	elseif args:IsSpellID(309258) then -- Око шторма
		if args:IsPlayer() then
			specWarnOko:Show()
			timerOkoCast:Start()
		end
-----------Шарккис-----------
	elseif args:IsSpellID(309262) then -- Пламенная связь
		SvazTargets[#SvazTargets + 1] = args.destName
		if args:IsPlayer() then
			specWarnSvaz:Show()
		end
		timerSvazCD:Start()
		self:ScheduleMethod(0.1, "SetSvazIcons")
	elseif args:IsSpellID(309277) then -- Опустошающее пламя
		timerPustCD:Start()
		warnPust:Show(args.destName, args.amount or 1)
		timerPust:Start(args.destName)
	end
end




mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED