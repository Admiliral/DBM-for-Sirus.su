local mod	= DBM:NewMod("Fathomlord", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210130153000")

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

local timerPhaseCast        = mod:NewCastTimer(65, 309292, nil, nil, nil, 6) -- Скользящий натиск
local timerStrelaCast		= mod:NewCastTimer(6, 309253, nil, nil, nil, 3) -- Стрела катаклизма
local timerStrelaCD			= mod:NewCDTimer(43, 309253, nil, nil, nil, 3) -- Стрела катаклизма
-----------Шарккис-----------
local warnSvaz              = mod:NewTargetAnnounce(309262, 3) -- Пламенная связь
local warnPust		        = mod:NewStackAnnounce(309277, 5, nil, "Tank") -- Опустошающее пламя

local specWarnSvaz          = mod:NewSpecialWarningMoveAway(309262, nil, nil, nil, 1, 3) -- Пламенная свзяь


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
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(38236) then -- Обычка
		timerSpitfireCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(309000) then

	elseif args:IsSpellID(309262) then -- Пламенная связь
		SvazTargets[#SvazTargets + 1] = args.destName
		if args:IsPlayer() then
			specWarnSvaz:Show()
		end
		self:ScheduleMethod(0.1, "SetSvazIcons")
	end
end




mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED