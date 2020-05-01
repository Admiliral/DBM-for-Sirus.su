local mod	= DBM:NewMod("VoidReaver", "DBM-TheEye", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))

mod:SetCreatureID(19516)
mod:RegisterCombat("combat")
mod:SetUsedIcons(3, 4, 5, 6, 7, 8)
mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_REMOVED",
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_START"
)

local warnPhase1				= mod:NewAnnounce("Phase1", 2)  -- Спавн сфер
local warnPhase2				= mod:NewAnnounce("Phase2", 2)  -- Спавн сфер
local warnSpawnOrbs				= mod:NewAnnounce("SpawnOrbs", 2)  -- Спавн сфер
local warnKnockback				= mod:NewSoonAnnounce(308470, 2, nil, "Tank|Healer|RemoveEnrage")  -- тяжкий удар
local warnScope					= mod:NewSoonAnnounce(308984, 2, nil, "Tank|Healer|RemoveEnrage")  -- Сферы
local warnScope6				= mod:NewAnnounce("warnScope6", 2)  -- Отсчёт сфер
local warnScope7				= mod:NewAnnounce("warnScope7", 2)  -- Отсчёт сфер
local warnScope8				= mod:NewAnnounce("warnScope8", 2)  -- Отсчёт сфер
local warnScope9				= mod:NewAnnounce("warnScope9", 2)  -- Отсчёт сфер
local warnScope10				= mod:NewAnnounce("warnScope10", 2) -- Отсчёт сфер
local warnBah					= mod:NewAnnounce("Bah", 2)  -- Сферы

-----обычка-----
local timerNextPounding         = mod:NewCDTimer(14, 34162, nil, nil, nil, 1)
local timerNextKnockback        = mod:NewCDTimer(30, 25778, nil, "Healer", nil, 5, DBM_CORE_HEALER_ICON)
------героик------

local timerScope				= mod:NewBuffActiveTimer(10, 308469, nil, "Tank|RemoveEnrage", nil, 5, nil, DBM_CORE_ENRAGE_ICON, nil, 1, 5) -- Баф сферы

local timerKnockbackCD			= mod:NewCDTimer(7, 308470, nil, "Tank|RemoveEnrage", nil, 5, nil, DBM_CORE_TANK_ICON) -- тяжкий удар
local timerOrbCD				= mod:NewCDTimer(26, 308466, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
local timerLoadCD				= mod:NewCDTimer(60, 308465, nil, nil, nil, 1, nil, DBM_CORE_ENRAGE_ICON)
local timerReloadCD				= mod:NewCDTimer(60, 308474, nil, nil, nil, 2, nil, DBM_CORE_DAMAGE_ICON)

local timerKnockbackCast		= mod:NewCastTimer(2, 308470, nil, "Healer", nil, 5, DBM_CORE_HEALER_ICON) -- тяжкий удар

local berserkTimer				= mod:NewBerserkTimer(600)


mod:AddBoolOption("RangeFrame", true)


local beaconIconTargets	= {}

function mod:OnCombatStart(delay) ---- готово
	table.wipe(beaconIconTargets)
	DBM:FireCustomEvent("DBM_EncounterStart", 19516, "Void Reaver")
	if mod:IsDifficulty("heroic25") then
	    timerLoadCD:Start()
	    timerOrbCD:Start()
	    timerKnockbackCD:Start()
	     self:ScheduleMethod(23, "Playsound")
	else
		berserkTimer:Start()
		timerNextPounding:Start()
		timerNextKnockback:Start()
	end
end

function mod:OnCombatEnd(wipe) --- не трогать
	DBM:FireCustomEvent("DBM_EncounterEnd", 19516, "Void Reaver", wipe)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

----------------------об--------------------------------------

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(25778) then
		timerNextKnockback:Start()
	elseif args:IsSpellID(34162) then
		timerNextPounding:Start()
	end
end
-------------------------хм------------------------------------

do ---?????????
	local function sort_by_group(v1, v2)
		return DBM:GetRaidSubgroup(UnitName(v1)) < DBM:GetRaidSubgroup(UnitName(v2))
	end
	function mod:SetBeaconIcons()
		if DBM:GetRaidRank() > 0 then
			table.sort(beaconIconTargets, sort_by_group)
			local beaconIcons = 8
			for i, v in ipairs(beaconIconTargets) do
					SendChatMessage("Сферы на: ", L.BeaconIconSet:format(beaconIcons, UnitName(v)), GetNumRaidMembers() > 0 and "RAID_WARNING" or "RAID")
				self:SetIcon(UnitName(v), beaconIcons,20)
				beaconIcons = beaconIcons - 1
			end
			table.wipe(beaconIconTargets)
		end
	end
end

function mod:SPELL_CAST_START(args)  ------- спавн сфер  или это?
	if 	args:IsSpellID(308984) then
		timerOrbCD:Schedule(2)
--		timerOrbCast:Schedule(0)
		warnScope:Schedule(0)
		warnSpawnOrbs:Schedule(23)
	elseif args:IsSpellID(308470) then  -------- Тяжкий удар
		timerKnockbackCD:Start()
		timerKnockbackCast:Start()
		warnKnockback:Schedule(0)
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)

end
--]]

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(308465) then --- 1 фаза
		timerLoadCD:Start()
		timerOrbCD:Start()
		warnPhase1:Schedule(0)
	elseif args:IsSpellID(308473) then  --- 2 фаза
		timerReloadCD:Start()
		warnPhase2:Schedule(0)
	elseif args:IsSpellID(308467) then	------------?????????????---------------
		print(args.destName)
		table.insert(beaconIconTargets, DBM:GetRaidUnitId(args.destName))
		if (#beaconIconTargets >= 3)then
			self:SetBeaconIcons() --Сортируйте и стреляйте как можно раньше, когда у нас есть все цели.
		end
	elseif args:IsSpellID(308469) and args:IsPlayer() then	-- Отсчёт до взрыва сферы +-
		if args:IsPlayer() then
			timerScope:Start()
			warnScope6:Cancel()
			warnScope7:Cancel()
			warnScope8:Cancel()
			warnScope9:Cancel()
			warnScope10:Cancel()
		end
		warnScope6:Schedule(5)
		warnScope7:Schedule(7)
		warnScope8:Schedule(8)
		warnScope9:Schedule(9)
		warnScope10:Schedule(10)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(308469) and args:IsPlayer() then	------- ну типа понял
		if args:IsPlayer() then
		warnBah:Schedule(0)
		end
	end
end