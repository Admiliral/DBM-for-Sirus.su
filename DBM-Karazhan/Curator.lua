local mod	= DBM:NewMod("Curator", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210502220000")
mod:SetCreatureID(34438,34436,34437)
--mod:SetCreatureID(15691)
--mod:RegisterCombat("yell", L.DBM_CURA_YELL_PULL)
mod:RegisterCombat("combat",34437)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_START",
	"SPELL_INTERRUPT"
)

-- local warnEvoSoon		= mod:NewPreWarnAnnounce(30254, 10, 2)
-- local warnEvo			= mod:NewSpellAnnounce(30254, 3)
-- local warnArcaneInfusion= mod:NewSpellAnnounce(30403, 3)
--
-- local timerEvo			= mod:NewBuffActiveTimer(20, 30254)
-- local timerNextEvo		= mod:NewNextTimer(115, 30254)
--
-- local berserkTimer		= mod:NewBerserkTimer(720)
--
-- mod:AddBoolOption("RangeFrame", true)
--
-- function mod:OnCombatStart(delay)
-- 	berserkTimer:Start(-delay)
-- 	timerNextEvo:Start(109-delay)
-- 	warnEvoSoon:Schedule(99-delay)
-- 	if self.Options.RangeFrame then
-- 		DBM.RangeCheck:Show(10)
-- 	end
-- end
--
-- function mod:OnCombatEnd()
-- 	if self.Options.RangeFrame then
-- 		DBM.RangeCheck:Hide()
-- 	end
-- end
--
-- function mod:SPELL_AURA_APPLIED(args)
-- 	if args:IsSpellID(30403) then
-- 		warnArcaneInfusion:Show()
-- 	end
-- end
--
-- function mod:CHAT_MSG_MONSTER_YELL(msg)
-- 	if msg == L.DBM_CURA_YELL_OOM then
-- 		warnEvoSoon:Cancel()
-- 		warnEvo:Show()
-- 		timerNextEvo:Start()
-- 		timerEvo:Start()
-- 		warnEvoSoon:Schedule(95)
-- 	end
-- end


local warnUnstableTar            = mod:NewAnnounce("WarnUnstableTar", 3, 305309)

local specWarnAnnihilationKick   = mod:NewSpecialWarning("Прерывание")
local specWarnCond               = mod:NewSpecialWarningYou(305305, nil, nil, nil, 1, 2)
local specWarnRunes              = mod:NewSpecialWarningRun(305296, nil, nil, nil, 1, 2)

local timerAnnihilationCD        = mod:NewCDTimer(23, 305312, nil, nil, nil, 2)
local timerCondCD                = mod:NewCDTimer(11, 305305, nil, nil, nil, 2)
local timerRunesCD               = mod:NewCDTimer(25, 305296, nil, nil, nil, 1)
local timerRunesBam              = mod:NewTimer(8, "TimerRunesBam", 305314, nil, nil, 2)

local warnSound						= mod:NewSoundAnnounce()

local unstableTargets = {}
mod.vb.ter = true
mod.vb.isinCombat = false


function mod:bombDefused()
    warnSound:Play("bomb_d")
end


function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 34437, "The Curator")
	for i=1,3 do
		if UnitAura("boss".. i,"Деактивация", nil, "HARMFUL") == nil then
			if     i==3 then
				timerAnnihilationCD:Start()
				timerCondCD:Start()
			elseif i==1 then
				timerRunesCD:Start()
			end
		end
	end
	self.vb.isinCombat = true
    self.vb.ter = true
	table.wipe(unstableTargets)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 34437, "The Curator", wipe)
	self.vb.isinCombat = false
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(305313) then
		if  self.vb.isinCombat then
			local name = {"tobecon","dramatic"}
			name  = name[math.random(#name)]
			warnSound:Play(name)
		end
		for i=1,3 do
			if UnitAura("boss".. i,"Деактивация", nil, "HARMFUL") == nil then
				if     i==3 then
					timerAnnihilationCD:Start()
					timerCondCD:Start()
				elseif i==1 then
					timerRunesCD:Start()
				end
			end
		end
	elseif args:IsSpellID(305309) then
		for i=1,10 do
			if UnitAura("raid".. i,"Нестабильная энергия") then
				unstableTargets[#unstableTargets + 1] =  UnitName("raid".. i)
			end
		end
		warnUnstableTar:Show(table.concat(unstableTargets, "<, >"))
		table.wipe(unstableTargets)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(305305) then
		timerCondCD:Start()
		if args:IsPlayer() then
			specWarnCond:Show()
		end
	elseif args:IsSpellID(305309) then
		for i=1,10 do
			if UnitAura("raid".. i,"Нестабильная энергия") then
				unstableTargets[#unstableTargets + 1] =  UnitName("raid".. i)
			end
		end
		warnUnstableTar:Show(table.concat(unstableTargets, "<, >"))
		table.wipe(unstableTargets)
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(305296) then
		self.vb.ter = true
		warnSound:Play("bomb_p")
        self:ScheduleMethod(6 ,"bombDefused")
		specWarnRunes:Show()
		timerRunesCD:Start()
		timerRunesBam:Start()
	elseif args:IsSpellID(305312) then
		warnSound:Play("optics_online")
		timerAnnihilationCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
    if args:IsSpellID(305298) then
        self:UnscheduleMethod("bombDefused")
        if self.vb.ter then
            warnSound:Play("terror_wins")
            self.vb.ter = false
        end
    end
end
