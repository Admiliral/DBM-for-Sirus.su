local mod	= DBM:NewMod("Murozond", "DBM-BronzeSanctuary")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20211205212100")

mod:SetCreatureID(50612)
mod:RegisterCombat("combat", 50612)
mod:SetUsedIcons()



mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"UNIT_DIED",
	"SPELL_AURA_REMOVED",
	"UNIT_HEALTH"
)


--------------------------------------HM--------------------------------
local warnBredHM		        = mod:NewStackAnnounce(317252, 5, nil, "Tank")
local specWarnPerPhase      	= mod:NewSpecialWarning("PrePhase", 313122, nil, nil, 1, 6) -- Перефаза
local specwarnReflectSpells		= mod:NewSpecialWarningCast(317262, "-Healer", nil, nil, 3, 2) -- Отражение заклинаний
local specWarnTimeTrapGTFO	    = mod:NewSpecialWarningMove(317260, nil, nil, nil, 1, 2)


--local SummoningtheTimelessHM 	= mod:NewCDTimer(90, 313120, nil, nil, nil, 2) -- призыв аддов
local DistortionWaveHM 			= mod:NewCDTimer(40, 317253, nil, nil, nil, 5, nil, DBM_CORE_HEALER_ICON) -- Волна искажений
local timerReflectBuff			= mod:NewBuffActiveTimer(5, 317262, nil, nil, nil, 2) --отражение
local NewPrePhaseAnnounce		= mod:NewCDCountTimer(180, 313122, nil, nil, nil, 2)
local TimeTrapCD 				= mod:NewCDTimer(30, 317259, nil, nil, nil, 3) -- Ловушка времени
local BreathofInfinityHm 		= mod:NewCDTimer(15, 317252, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON) -- танк дабаф хм
local ReflectSpellsCD 			= mod:NewCDTimer(20, 317262, nil, "SpellCaster|-Healer", nil, 3, nil, DBM_CORE_DEADLY_ICON, nil, 1) -- Отражение заклинаний
local timerBredHM		    	= mod:NewTargetTimer(120, 313115, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local TerrifyingFutureHM 		= mod:NewCDTimer(40, 317255, nil, "Melee", nil, 2, nil, DBM_CORE_DEADLY_ICON, nil, 1) -- Мили Фир
local GibVremea				 	= mod:NewCDTimer(5, 317258, nil, nil, nil, 4, nil, DBM_CORE_HEALER_ICON) -- призыв аддов


---------------------------------------------ОБ---------------------------------



local warnBred		        = mod:NewStackAnnounce(313115, 5, nil, "Tank")
local warnPhase1	   		= mod:NewPhaseAnnounce(1, 2)
local warnPhase2Soon   		= mod:NewPrePhaseAnnounce(2, 2)
local warnPhase2     		= mod:NewPhaseAnnounce(2, 2)

local specwarnBelay      	= mod:NewSpecialWarning("BelayaSfera", 313129, nil, nil, 1, 6)
local specwarnCern    		= mod:NewSpecialWarning("Cernsfera", 313122, nil, nil, 1, 6)
local specwarnPerebejka    	= mod:NewSpecialWarning("Perebejkai", 313122, nil, nil, 1, 6)
local warnTerrifyingFuture 	= mod:NewSpecialWarningLookAwayi(313118, "Melee", nil, nil, 2, 2)

local EndofTime				= mod:NewCastTimer(10, 313122, nil, nil, nil, 2) --перефаза
local EndofTimeBuff			= mod:NewBuffActiveTimer(60, 313122, nil, nil, nil, 3)
local DistortionWave 		= mod:NewCDTimer(40, 313116, nil, nil, nil, 2) -- Волна искажений
local SummoningtheTimeless 	= mod:NewCDTimer(90, 313120, nil, nil, nil, 2) -- призыв аддов
local BreathofInfinity 		= mod:NewCDTimer(50, 313115, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON) -- танк дабаф
local timerBred		    	= mod:NewTargetTimer(60, 313115, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local TerrifyingFuture 		= mod:NewCDTimer(40, 313118, nil, "Melee", nil, 2, nil, DBM_CORE_DEADLY_ICON, nil, 1) -- Мили Фир

local warned_preP1 = false
local warned_preP2 = false


mod.vb.PreHuy = 0
mod.vb.FearMili = 0
mod:AddBoolOption("BossHealthFrame", true, "misc")
mod:AddBoolOption("AnnounceFails", true, "announce")
mod:AddBoolOption("GibVr", false)
local FearTargets	= {}

function mod:OnCombatStart(delay)
    DBM:FireCustomEvent("DBM_EncounterStart", 50612, "Murozond")
	self.vb.PreHuy = 0
	self.vb.FearMili = 0
	mod:SetStage(1)
	if mod:IsDifficulty("heroic25") then
		NewPrePhaseAnnounce:Start(nil, self.vb.PreHuy+1)
		SummoningtheTimeless:Start(10)
		ReflectSpellsCD:Start(24)
		TerrifyingFutureHM:Start()
		TimeTrapCD:Start(30)
		if self.Options.GibVr then
		GibVremea:Start()
		self:ScheduleMethod(5, "Vremea")
		end
	else
		DistortionWave:Start(20)
		SummoningtheTimeless:Start(35)
		BreathofInfinity:Start()
		TerrifyingFuture:Start()
	end
	if self.Options.BossHealthFrame then
		DBM.BossHealth:Show(L.name)
		DBM.BossHealth:AddBoss(50612, L.name)
	end
	table.wipe(FearTargets)
end

local FearFails = {}
local function FearFails1(e1, e2)
	return (FearTargets[e1] or 0) > (FearTargets[e2] or 0)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 50612, "Murozond", wipe)
	DBM.BossHealth:Clear()
	DistortionWave:Stop()
	SummoningtheTimeless:Stop()
	BreathofInfinity:Stop()
	TerrifyingFuture:Stop()
	warnTerrifyingFuture:Cancel()
	if self.Options.GibVr then
		GibVremea:Stop()
		self:UnscheduleMethod("Vremea")
	end
	if self.Options.AnnounceFails and DBM:GetRaidRank() >= 1 then
		local lFear = ""
		for k, v in pairs(FearTargets) do
			table.insert(FearFails, k)
		end
		table.sort(FearFails, FearFails1)
		for i, v in ipairs(FearFails) do
			lFear = lFear.." "..v.."("..(FearTargets[v] or "")..")"
		end
		SendChatMessage(L.Fear:format(lFear), "RAID")
		table.wipe(FearFails)
	end
end


function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 313116 then
		DistortionWave:Start()
	elseif spellId == 313120 then
		if mod:IsDifficulty("heroic25") then
			SummoningtheTimeless:Start(90)
		else
			SummoningtheTimeless:Start()
		end
	elseif spellId == 313118 then
		TerrifyingFuture:Start()
		warnTerrifyingFuture:Show()
	elseif spellId == 313122 and not warned_preP2 then
		self.vb.PreHuy = self.vb.PreHuy + 1
		EndofTime:Start()
		self:SetStage(2)
		warnPhase2:Show()
		warned_preP2 = true
		specwarnPerebejka:Schedule(19)
		self:ScheduleMethod(19, "Perebejka")
		if mod:IsDifficulty("heroic25") then
			specWarnPerPhase:Show()
			NewPrePhaseAnnounce:Stop()
			self:ScheduleMethod(0.1, "StopBossCastHM")
		else
			self:ScheduleMethod(0.1, "StopBossCast")
		end
	end
	-----------HM------------
	if spellId == 317252 then
		BreathofInfinityHm:Start()
	elseif spellId == 317253 then
		DistortionWaveHM:Start()
	elseif spellId == 317255 then
		TerrifyingFutureHM:Start()
		warnTerrifyingFuture:Show()
	elseif spellId == 317262 then
		specwarnReflectSpells:Show()
	end
end

function mod:Perebejka()
	if self.vb.phase == 2 then
		specwarnPerebejka:Schedule(15)
		self:ScheduleMethod(15, "Perebejka")
	end
end
function mod:Vremea()
	if self.Options.GibVr then
		GibVremea:Start()
		self:ScheduleMethod(5, "Vremea")
	end
end

function mod:StopBossCastHM()
	if SummoningtheTimeless:GetRemaining() then
		local elapsed, total = SummoningtheTimeless:GetTime()
		local extend = total-elapsed
		SummoningtheTimeless:Stop()
		SummoningtheTimeless:Update(0, 75+extend)
	end
	if ReflectSpellsCD:GetRemaining() then
		local elapsed, total = ReflectSpellsCD:GetTime()
		local extend = total-elapsed
		ReflectSpellsCD:Stop()
		ReflectSpellsCD:Update(0, 75+extend)
	end
	if TimeTrapCD:GetRemaining() then
		local elapsed, total = TimeTrapCD:GetTime()
		local extend = total-elapsed
		TimeTrapCD:Stop()
		TimeTrapCD:Update(0, 75+extend)
	end
	if BreathofInfinityHm:GetRemaining() then
		local elapsed, total = BreathofInfinityHm:GetTime()
		local extend = total-elapsed
		BreathofInfinityHm:Stop()
		BreathofInfinityHm:Update(0, 75+extend)
	end
	if TerrifyingFutureHM:GetRemaining() then
		local elapsed, total = TerrifyingFutureHM:GetTime()
		local extend = total-elapsed
		TerrifyingFutureHM:Stop()
		TerrifyingFutureHM:Update(0, 75+extend)
	end
end

function mod:StopBossCast()
	if SummoningtheTimeless:GetRemaining() then
		local elapsed, total = SummoningtheTimeless:GetTime()
		local extend = total-elapsed
		SummoningtheTimeless:Stop()
		SummoningtheTimeless:Update(0, 75+extend)
	end
	if DistortionWave:GetRemaining() then
		local elapsed, total = DistortionWave:GetTime()
		local extend = total-elapsed
		DistortionWave:Stop()
		DistortionWave:Update(0, 75+extend)
	end
	if BreathofInfinity:GetRemaining() then
		local elapsed, total = BreathofInfinity:GetTime()
		local extend = total-elapsed
		BreathofInfinity:Stop()
		BreathofInfinity:Update(0, 75+extend)
	end
	if TerrifyingFuture:GetRemaining() then
		local elapsed, total = TerrifyingFuture:GetTime()
		local extend = total-elapsed
		TerrifyingFuture:Stop()
		TerrifyingFuture:Update(0, 75+extend)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 313122 and args:IsPlayer() then
		EndofTimeBuff:Start()
	elseif spellId == 313115 then
        warnBred:Show(args.destName, args.amount or 1)
		timerBred:Start(args.destName)
	elseif spellId == 313129 and args:IsPlayer() then
		specwarnCern:Schedule(1)
	elseif spellId == 313130 and args:IsPlayer() then
		specwarnBelay:Schedule(1)
	end
	-------------HM----------------
	if spellId == 317262 then
		timerReflectBuff:Start()
	elseif spellId == 317260 then
		if args:IsPlayer() then
			specWarnTimeTrapGTFO:Show()
		end
	elseif spellId == 317252 then
        warnBredHM:Show(args.destName, args.amount or 1)
		timerBredHM:Start(args.destName)
	elseif self.Options.AnnounceFails and (spellId == 317256 or spellId == 313119) and DBM:GetRaidRank() >= 1 and DBM:GetRaidUnitId(args.destName) ~= "none" and args.destName then
		FearTargets[args.destName] = (FearTargets[args.destName] or 0) + 1
		SendChatMessage(L.FearOn:format(args.destName), "RAID")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 317259 then
		TimeTrapCD:Start()
	elseif spellId == 313122 then
		specwarnPerebejka:Start(9)
		self:ScheduleMethod(9, "Perebejka")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	local cid = self:GetCIDFromGUID(args.destGUID)
	if spellId == 313122 then
		if cid == 50612 and self.vb.phase == 2 then
			mod:SetStage(1)
			warned_preP1 = false
			warned_preP2 = false
			specwarnPerebejka:Cancel()
			self:UnscheduleMethod("Perebejka")
			warnPhase1:Show()-- 1 перефаза
		if mod:IsDifficulty("heroic25") then
			NewPrePhaseAnnounce:Start(nil, self.vb.PreHuy+1)
			end
		end
	end
	---------HM------------
	if spellId == 317262 then
		ReflectSpellsCD:Start()
	end
end

function mod:UNIT_HEALTH(uId)
		if self.vb.phase == 1 and not warned_preP1 and self:GetUnitCreatureId(uId) == 50612 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.78 then
			warned_preP1 = true
			warnPhase2Soon:Show()
		end
		if self.vb.phase == 1 and not warned_preP1 and self:GetUnitCreatureId(uId) == 50612 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.53 then
			warned_preP1 = true
			warnPhase2Soon:Show()
		end
		if self.vb.phase == 1 and not warned_preP1 and self:GetUnitCreatureId(uId) == 50612 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.28 then
			warned_preP1 = true
			warnPhase2Soon:Show()
		end
end
