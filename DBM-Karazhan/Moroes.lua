local mod	= DBM:NewMod("Moroes", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 183 $"):sub(12, -3))
mod:SetCreatureID(15687, 19875, 19874, 19872, 17007, 19876, 19873)--Moroes
--19875, 19874, 19872, 17007, 19876, 19873--all the adds, for future use
--mod:RegisterCombat("yell", L.DBM_MOROES_YELL_START)
mod:RegisterCombat("combat", 15687)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED"
)

-- local warningVanishSoon		= mod:NewSoonAnnounce(29448, 2)
-- local warningVanish			= mod:NewSpellAnnounce(29448, 3)
-- local warningGarrote		= mod:NewTargetAnnounce(37066, 4)
-- local warningGouge			= mod:NewTargetAnnounce(29425, 4)
-- local warningBlind			= mod:NewTargetAnnounce(34694, 3)
-- local warningMortalStrike	= mod:NewTargetAnnounce(29572, 2)
-- local warningManaBurn		= mod:NewCastAnnounce(29405, 3, nil, false)
-- local warningGreaterHeal	= mod:NewCastAnnounce(35096, 3, nil, false)
-- local warningHolyLight		= mod:NewCastAnnounce(29562, 3, nil, false)
-- 
-- local timerVanishCD			= mod:NewCDTimer(31, 29448)
-- local timerGouge			= mod:NewTargetTimer(6, 29425)
-- local timerBlind			= mod:NewTargetTimer(10, 34694)
-- local timerMortalStrike		= mod:NewTargetTimer(5, 29572)
-- 
-- local lastVanish = 0
-- 
-- function mod:OnCombatStart(delay)
-- 	timerVanishCD:Start(-delay)
-- 	warningVanishSoon:Schedule(31-delay)
-- 	lastVanish = 0
-- end
-- 
-- function mod:SPELL_CAST_START(args)
-- 	if args:IsSpellID(29405) then
-- 		warningManaBurn:Show()
-- 	elseif args:IsSpellID(35096) then
-- 		warningGreaterHeal:Show()
-- 	elseif args:IsSpellID(29562) then
-- 		warningHolyLight:Show()
-- 	end
-- end
-- 
-- function mod:SPELL_AURA_APPLIED(args)
-- 	if args:IsSpellID(29448) then
-- 		warningVanish:Show()
-- 		lastVanish = GetTime()
-- 	elseif args:IsSpellID(29425) then
-- 		warningGouge:Show(args.destName)
-- 		timerGouge:Show(args.destName)
-- 	elseif args:IsSpellID(34694) then
-- 		warningBlind:Show(args.destName)
-- 		timerBlind:Show(args.destName)
-- 	elseif args:IsSpellID(29572) then
-- 		warningMortalStrike:Show(args.destName)
-- 		timerMortalStrike:Show(args.destName)
-- 	elseif args:IsSpellID(37066) then
-- 		warningGarrote:Show(args.destName)
-- 		if (GetTime() - lastVanish) < 20 then--firing this event here instead, since he does garrote as soon as he comes out of vanish.
-- 			timerVanishCD:Start()
-- 			warningVanishSoon:Schedule(26)
-- 		end
-- 	end
-- end
-- 
-- function mod:SPELL_AURA_REMOVED(args)
-- 	if args:IsSpellID(34694) then
-- 		timerBlind:Cancel(args.destName)
-- 	end
-- end

local timerDanceCD			    = mod:NewCDTimer(20, 305472)
local specWarnDance             = mod:NewSpecialWarningRun(305472)
local timerPhase2				= mod:NewTimer(180, "Phase2", 40810)
local warnPhase2Soon		    = mod:NewAnnounce("WarnPhase2Soon", 2, 40810)
local warnDeathMark             = mod:NewAnnounce("WarnDeathMark", 4,305470)
local timerPierceCD             = mod:NewCDTimer(10, 305464)
local timerWoundCD              = mod:NewCDTimer(10, 305463)
local timerDeathMark            = mod:NewTargetTimer(10, 305470)
local timerDeathMarkCD			= mod:NewCDTimer(25, 305470)
local ora = true
local phase2 = false
function mod:resetOra()
    ora = true
end

function mod:phase2warn()
    phase2 = true
    warnPhase2Soon:Show()
    timerDeathMarkCD:Schedule(2)
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 15687, "Moroes")
    if mod:IsDifficulty("heroic10") then
	    self:PlaySound("ya_vas_ne_zval")
        phase2 = false
        timerDanceCD:Start()
        timerPhase2:Start()
        self:ScheduleMethod(178, "phase2warn")
    end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 15687, "Moroes", wipe)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(305464) and phase2 then
        self:PlaySound("taa")
        timerPierceCD:Start()
    elseif args:IsSpellID(305463) and phase2 then
        self:PlaySound("sha")
        timerWoundCD:Start()
    elseif args:IsSpellID(305472) then
        timerDanceCD:Start()
    end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(305470) then
        if args:IsPlayer() then 
             self:PlaySound("omaeva")       -- omae wa mou shindeiru... (анимэ "Кулак полярной звезды")  
        end
        warnDeathMark:Show(args.destName)
        timerDeathMark:Start(args.destName)
        timerDeathMarkCD:Start()
    elseif args:IsSpellID(305478) then 
        if args:IsPlayer() then 
            self:PlaySound("djeban","sexgay","cigan","hardbass","upkicks") --танец
        end
	elseif args:IsSpellID(305460) then
        if ora then
            self:PlaySound("ora", "muda", "atata")           -- ОРА-ОРА-ОРА-ОРА-ОРА-ОРА (JoJo)
            ora = false
            self:ScheduleMethod(5, "resetOra")
        end
    end
end
