local mod	= DBM:NewMod("Leotheras", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20201004021400")

mod:SetCreatureID(21215)
mod:RegisterCombat("combat", 21215)
mod:SetUsedIcons(4, 5, 6, 7, 8)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"UNIT_HEALTH",
	"SPELL_AURA_REMOVED"
)

-- local warnDemonSoon         = mod:NewAnnounce("WarnDemonSoon", 3, "Interface\\Icons\\Spell_Shadow_Metamorphosis")
-- local warnNormalSoon        = mod:NewAnnounce("WarnNormalSoon", 3, "Interface\\Icons\\INV_Weapon_ShortBlade_07")
local warnDemons            = mod:NewTargetAnnounce(37676, 4)

local specWarnDemon         = mod:NewSpecialWarningYou(37676)

local timerDemon            = mod:NewTimer(45, "TimerDemon", "Interface\\Icons\\Spell_Shadow_Metamorphosis")
local timerNormal           = mod:NewTimer(60, "TimerNormal", "Interface\\Icons\\INV_Weapon_ShortBlade_07")
local timerInnerDemons      = mod:NewTimer(32.5, "TimerInnerDemons", 11446)
local timerWhirlwind        = mod:NewCastTimer(12, 37640)
local timerWhirlwindCD      = mod:NewCDTimer(19, 37640)

local berserkTimer          = mod:NewBerserkTimer(600)


---------------------------------хм---------------------------------

local warnRass	           	= mod:NewStackAnnounce(310480, 5, nil, "Tank|Healer") -- Рассеченая душа
local warnKogti		        = mod:NewStackAnnounce(310502, 5, nil, "Tank|Healer") -- Когти
local warnNat    	        = mod:NewTargetAnnounce(310478, 3) -- Натиск
local warnChardg	     	= mod:NewTargetAnnounce(310481, 3) -- Рывок
local warnPepels  	     	= mod:NewTargetAnnounce(310514, 3) -- Испепеление
local warnKlei              = mod:NewTargetAnnounce(310496, 4) -- Клеймо
local warnMeta		        = mod:NewSpellAnnounce(310484, 3) --Мета
local warnPepel		        = mod:NewSpellAnnounce(310514, 3) --пепел
local warnVsp		        = mod:NewStackAnnounce(310521, 5) --Вспышка
local warnPhase2Soon   		= mod:NewPrePhaseAnnounce(2)
local warnPhase2     		= mod:NewPhaseAnnounce(2)


local specWarnChardg        = mod:NewSpecialWarningYou(310481, nil, nil, nil, 1, 2)
local specWarnKlei          = mod:NewSpecialWarningYou(310496, nil, nil, nil, 1, 2)
local specWarnObstrel       = mod:NewSpecialWarningRun(310510, nil, nil, nil, 2, 2)
local specWarnAnig          = mod:NewSpecialWarningDodge(310508, nil, nil, nil, 3, 2)
local specWarnVzg           = mod:NewSpecialWarningDodge(310516, nil, nil, nil, 3, 2)
local specWarnVost          = mod:NewSpecialWarningSoak(310503, nil, nil, nil, 1, 2)
local specWarnPechat        = mod:NewSpecialWarningSoak(310487, nil, nil, nil, 1, 2)
local specWarnPepel         = mod:NewSpecialWarningYou(310514, nil, nil, nil, 1, 4)

local timerRass	        	= mod:NewTargetTimer(40, 310480, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON) -- Рассеченая душа
local timerKogti	    	= mod:NewTargetTimer(40, 310502, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON) -- Когти
local timerVsp	    	    = mod:NewTargetTimer(60, 310521, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON) -- Когти
local timerKlei	    	    = mod:NewTargetTimer(30, 310496, nil, nil, nil, 3) -- Клеймо
local timerAnigCast	    	= mod:NewCastTimer(10, 310508, nil, nil, nil, 2) -- Аниг
local timerVzgCast	    	= mod:NewCastTimer(5, 310516, nil, nil, nil, 2) -- Взгляд
local timerChardgCast	   	= mod:NewCastTimer(3, 310481, nil, nil, nil, 3) -- Рывок
local timerMetaCast	     	= mod:NewCastTimer(3, 310484, nil, nil, nil, 3) -- Мета
local timerNatCast	     	= mod:NewCastTimer(3, 310478, nil, nil, nil, 3) -- Натиск
local timerPepelCast	   	= mod:NewCastTimer(3, 310514, nil, nil, nil, 3) -- Испепел


mod:AddSetIconOption("SetIconOnDemonTargets", 37676, true, true, {5, 6, 7, 8})
mod:AddSetIconOption("SetIconOnPepelTargets", 310514, true, true, {4, 5, 6, 7})
mod:AddSetIconOption("KleiIcon", 310496, true, true, {8})
mod:AddBoolOption("AnnounceKlei", false)
mod:AddBoolOption("AnnouncePepel", false)

mod.vb.phase = 0
local demonTargets = {}
local warned_preP1 = false
local warned_preP2 = false
local PepelTargets = {}
local KleiIcons = 8

do
	local function sort_by_group(v1, v2)
		return DBM:GetRaidSubgroup(UnitName(v1)) < DBM:GetRaidSubgroup(UnitName(v2))
	end
	function mod:SetPepelIcons()
		if DBM:GetRaidRank() >= 0 then
			table.sort(PepelTargets, sort_by_group)
			local PepelIcons = 7
			for i, v in ipairs(PepelTargets) do
				if mod.Options.AnnouncePepel then
					if DBM:GetRaidRank() > 0 then
						SendChatMessage(L.PepelIcon:format(PepelIcons, UnitName(v)), "RAID_WARNING")
					else
						SendChatMessage(L.PepelIcon:format(PepelIcons, UnitName(v)), "RAID")
					end
				end
				if self.Options.SetIconOnPepelTargets then
					self:SetIcon(UnitName(v), PepelIcons)
				end
				PepelIcons = PepelIcons - 1
			end
			if #PepelTargets >= 4 then
				warnPepels:Show(table.concat(PepelTargets, "<, >"))
				table.wipe(PepelTargets)
				PepelIcons = 7
			end
		end
	end
end

function mod:WarnDemons()
	warnDemons:Show(table.concat(demonTargets, "<, >"))
	if self.Options.SetIconOnDemonTargets then
		table.sort(demonTargets, function(v1,v2) return DBM:GetRaidSubgroup(v1) < DBM:GetRaidSubgroup(v2) end)
		local k = 8
		for i, v in ipairs(demonTargets) do
			self:SetIcon(v, k)
			k = k - 1
		end
	end
	table.wipe(demonTargets)
end

function mod:OnCombatStart()
	DBM:FireCustomEvent("DBM_EncounterStart", 21215, "Leotheras the Blind")
	table.wipe(demonTargets)
	self.vb.phase = 1
	if mod:IsDifficulty("heroic25") then
	else
		berserkTimer:Start()
		timerDemon:Start(60)
		timerWhirlwindCD:Start(18)
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 21215, "Leotheras the Blind", wipe)
end



function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(310481) then
	timerChardgCast:Start()
	warnChardg:Show(args.destName)
		if args:IsPlayer() then
			specWarnChardg:Show()
		end
	elseif args:IsSpellID(310484) then
	warnMeta:Show()
	timerMetaCast:Start()
	elseif args:IsSpellID(310478) then
	warnNat:Show(args.destName)
	timerNatCast:Start()
	elseif args:IsSpellID(310516) then
		specWarnVzg:Show()
		timerVzgCast:Start()
	end
end


function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(37640) then
		timerWhirlwind:Start()
		timerWhirlwindCD:Schedule(12)
	elseif args:IsSpellID(37676) then
		demonTargets[#demonTargets + 1] = args.destName
		if args:IsPlayer() then
			specWarnDemon:Show()
		end
		self:UnscheduleMethod("WarnDemons")
		self:ScheduleMethod(0.1, "WarnDemons")
	elseif args:IsSpellID(310480) then --хм Рассеченая душа
        warnRass:Show(args.destName, args.amount or 1)
		timerRass:Start(args.destName)
	elseif args:IsSpellID(310502) then --хм Когти скверны
        warnKogti:Show(args.destName, args.amount or 1)
		timerKogti:Start(args.destName)
	elseif args:IsSpellID(310521) then --хм Вспышка
		if (args.amount or 1) > 3 then
        warnVsp:Show(args.destName, args.amount or 1)
		timerVsp:Start(args.destName)
		end
	elseif args:IsSpellID(310496) then --хм Клеймо
		warnKlei:Show(args.destName)
		if self.Options.KleiIcon then
			self:SetIcon(args.destName, 8, 30)
			timerKlei:Start(args.destName)
		elseif args:IsPlayer() then
			specWarnKlei:Show()
		end
		if mod.Options.AnnounceKlei then
			if DBM:GetRaidRank() > 0 then
				SendChatMessage(L.Klei:format(KleiIcons, args.destName), "RAID_WARNING")
			else
				SendChatMessage(L.Klei:format(KleiIcons, args.destName), "RAID")
			end
		end
	elseif args:IsSpellID(310514) then
		PepelTargets[#PepelTargets + 1] = args.destName
		if args:IsPlayer() then
			specWarnPepel:Show()
		end
		self:ScheduleMethod(0.1, "SetPepelIcons")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(37676) then
		self:SetIcon(args.destName, 0)
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(37676) then
		timerInnerDemons:Start()
	elseif args:IsSpellID(310510) then
		specWarnObstrel:Show()
	elseif args:IsSpellID(310508) then
		specWarnAnig:Show()
		timerAnigCast:Start()
	elseif args:IsSpellID(310503) then
		specWarnVost:Show()
	elseif args:IsSpellID(310487) then
		specWarnPechat:Show()
	elseif args:IsSpellID(310521) then
		warnVsp:Show()
	elseif args:IsSpellID(310514) then
		timerPepelCast:Start(2)
		warnPepel:Show()
	end
end

function mod:UNIT_HEALTH(uId)
	if self.vb.phase == 1 and not warned_preP1 and self:GetUnitCreatureId(uId) == 21215 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.37 then
		warned_preP1 = true
		warnPhase2Soon:Show()
	end
	if self.vb.phase == 1 and not warned_preP2 and self:GetUnitCreatureId(uId) == 21215 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.35 then
		warned_preP2 = true
		self.vb.phase = 2
		warnPhase2:Show()
	end
end


function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellDemon then
		timerDemon:Cancel()
		timerWhirlwindCD:Cancel()
		timerDemon:Schedule(60)
		timerWhirlwindCD:Schedule(60)
		timerNormal:Start()
	elseif msg == L.YellShadow then
		timerDemon:Cancel()
		timerNormal:Cancel()
		timerWhirlwindCD:Start(22.5)
	end
end


mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED