local mod	= DBM:NewMod("Jaina", "DBM-Icecrown", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 4413 $"):sub(12, -3))
mod:SetCreatureID(3392)
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(2, 3, 4, 5, 6, 7, 8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
    "CHAT_MSG_MONSTER_YELL"
)


local timerCombatStart		= mod:NewTimer(54, "TimerCombatStart", 2457)
local timerSummonElemenCD	= mod:NewCDTimer(25, 306454)
local timerArcaneStormCD	= mod:NewCDTimer(72, 306464)
local timerArcaneStorm 		= mod:NewCastTimer(10, 306464)
local timerUnstableMagicCD	= mod:NewCDTimer(24, 306468)
local timerRaysCD	        = mod:NewCDTimer(28, 306485)
local timerMeteorCD	        = mod:NewCDTimer(30, 306491)
local timerFirewhirlCD	    = mod:NewCDTimer(65, 306495)
local timerCollapse 		= mod:NewCastTimer(20, 306500)
local timerIceWrathCD       = mod:NewCDTimer(180, 306545)
local timerFreezing 		= mod:NewTimer(6, "TimerFreezing", 306523)

local warnNextPhase         = mod:NewAnnounce("WarnNextPhase", 1)
local warnUnstableMagicSoon = mod:NewSoonAnnounce(306468, 2)
local warnArcaneStormSoon   = mod:NewSoonAnnounce(306464, 2)
local warnIceWrath          = mod:NewSoonAnnounce(306549, 4)
local warnFirewhirl         = mod:NewSpellAnnounce(306495, 2)
local warnExplosiveFlame	= mod:NewTargetAnnounce(306487, 4)
local warnWildFlame         = mod:NewTargetAnnounce(306502, 4)
local warnVengefulIce       = mod:NewTargetAnnounce(306535, 4)
local warnIceMark           = mod:NewTargetAnnounce(306523, 4)

local specWarnArcaneStorm   = mod:NewSpecialWarningRun(306464)
local specWarnUnstableMagic = mod:NewSpecialWarningSpell(306468)
local specWarnRays          = mod:NewSpecialWarningSpell(306485)
local specWarnExplosive     = mod:NewSpecialWarningRun(306487)
local specWarnWildFlame     = mod:NewSpecialWarningMove(306502)
local specWarnWildFlameNear = mod:NewSpecialWarning("SpecWarnWildFlameNear", 306545)
local specWarnVengefulIce   = mod:NewSpecialWarningMove(306535)
local specWarnIceWrath      = mod:NewSpecialWarning("SpecWarnIceWrath")
local specWarnIceMark       = mod:NewSpecialWarningRun(306523)
local specWarnIceRush       = mod:NewSpecialWarningMove(306531, mod:IsMelee())
local specWarnIceSpears     = mod:NewSpecialWarningSpell(306537, mod:IsRanged())

local berserkTimer			= mod:NewBerserkTimer(1802)

mod:AddBoolOption("SetIconOnExplosiveTargets", true)
mod:AddBoolOption("RangeFrame")
    
mod.vb.phase = 1
local explosiveTargets = {}
local explosiveIcons = 8 
local wildFlameTargets = {}
local vengerfulIceTargets = {}
local iceMarkTargets = {}
            
function mod:OnCombat()
	self.vb.phase = 1
    explosiveIcons = 8
    wildFlameIcons = 8
    berserkTimer:Start()
    timerSummonElemenCD:Start(27)
    timerArcaneStormCD:Start(74)
    timerUnstableMagicCD:Start(26)
    warnArcaneStormSoon:Schedule(71)
    warnUnstableMagicSoon:Schedule(23)
    if self.Options.RangeFrame then
        DBM.RangeCheck:Show(10)
	end
end

function mod:WildFlame()
    warnWildFlame:Show(table.concat(wildFlameTargets, "<, >"))
    table.wipe(wildFlameTargets)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(306464) then
        specWarnArcaneStorm:Show() -- Шторм
        self:ScheduleMethod(0, "PlaySound", "omaeva") -- ,БЕГИ СУКА БЕГИ
    elseif args:IsSpellID(306468) then
        specWarnUnstableMagic:Show()
        timerUnstableMagicCD:Start()
        warnUnstableMagicSoon:Schedule(21)
    elseif args:IsSpellID(306454) then
        timerSummonElemenCD:Start()
    elseif args:IsSpellID(306483) then  -- Phase 2
        warnNextPhase:Show(2 .. ": " .. args.spellName)
        self.vb.phase = 2
        timerArcaneStormCD:Cancel()
        timerUnstableMagicCD:Cancel()
        warnArcaneStormSoon:Cancel()
        warnUnstableMagicSoon:Cancel()
        timerRaysCD:Start(17)
        timerMeteorCD:Start(29)
        timerFirewhirlCD:Start(60)
    elseif args:IsSpellID(306485) then
        timerRaysCD:Start()
        specWarnRays:Show()
        self:ScheduleMethod(2, "PlaySound", "misha") -- лучи
    elseif args:IsSpellID(306491) then
        timerMeteorCD:Start() -- Метеор
        self:ScheduleMethod(4, "PlaySound", "suffer_bitch") -- САФФА БИЧ!
    elseif args:IsSpellID(306531) then
        specWarnIceRush:Show() -- Натиск
        self:ScheduleMethod(0, "PlaySound", "fear2") -- Беги
    elseif args:IsSpellID(306545) then  -- Dome phase
        specWarnIceWrath:Show()
    end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(306464) then
        timerArcaneStorm:Start()
        timerSummonElemenCD:Start(11)
    elseif args:IsSpellID(306495) then
        timerFirewhirlCD:Schedule(20)
        timerCollapse:Start()
        warnFirewhirl:Show()
        if timerRaysCD:GetTime() > 0 then 
            timerRaysCD:Update(select(1, timerRaysCD:GetTime()), select(2, timerRaysCD:GetTime()) + 20) 
        else 
            timerRaysCD:Start(20)
        end
        if timerMeteorCD:GetTime() > 0 then 
            timerMeteorCD:Update(select(1, timerMeteorCD:GetTime()), select(2, timerMeteorCD:GetTime()) + 20) 
        else 
            timerMeteorCD:Start(20)
        end
    elseif args:IsSpellID(306487) then
        explosiveTargets[#explosiveTargets + 1] = args.destName
        if args:IsPlayer() then
            specWarnExplosive:Show()
        self:ScheduleMethod(0, "PlaySound", "fear2") -- ,БЕГИ СУКА БЕГИ
        end
        if self.Options.SetIconOnExplosiveTargets then
			self:SetIcon(args.destName, explosiveIcons, 6)
			explosiveIcons = explosiveIcons - 1
		end
		if #explosiveTargets >= 6 then
            warnExplosiveFlame:Show(table.concat(explosiveTargets, "<, >"))
            table.wipe(explosiveTargets)
            explosiveIcons = 8
		end
    elseif args:IsSpellID(306502) then -- дикое пламя
        if args:IsPlayer() then
            specWarnWildFlame:Show()
			self:ScheduleMethod(0, "PlaySound", "fear2") -- ,БЕГИ СУКА БЕГИ
        else
            local uId = DBM:GetRaidUnitId(args.destName)
            if uId then
                local inRange = CheckInteractDistance(uId, 3)
                local x, y = GetPlayerMapPosition(uId)
                if x == 0 and y == 0 then
                    SetMapToCurrentZone()
                    x, y = GetPlayerMapPosition(uId)
                end
                if inRange then
                    specWarnWildFlameNear:Show()
                end
            end
        end
        wildFlameTargets[#wildFlameTargets + 1] = args.destName
        self:UnscheduleMethod("WildFlame")
        self:ScheduleMethod(0.1, "WildFlame")
    elseif args:IsSpellID(306535) then
        vengerfulIceTargets[#vengerfulIceTargets + 1] = args.destName
        if args:IsPlayer() then
            specWarnVengefulIce:Show()
        end
        if #vengerfulIceTargets >= 2 then
            warnVengefulIce:Show(table.concat(vengerfulIceTargets, "<, >"))
            table.wipe(vengerfulIceTargets)
        end
    elseif args:IsSpellID(306523, 306524) then
        iceMarkTargets[#iceMarkTargets + 1] = args.destName
        if args:IsPlayer() then
            specWarnIceMark:Show()
        end
        if #iceMarkTargets >= 6 then
            warnIceMark:Show(table.concat(iceMarkTargets, "<, >"))
            table.wipe(iceMarkTargets)
        end
        timerFreezing:Start()
    end
end

function mod:SPELL_CAST_SUCCESS(args)
    if args:IsSpellID(306516) then  -- Phase 3
        warnNextPhase:Show(3 .. ": " .. L.blackIce)
        self.vb.phase = 3
        timerRaysCD:Cancel()
        timerMeteorCD:Cancel()
        timerFirewhirlCD:Cancel()
        timerIceWrathCD:Start(135)
        NewCDTimer(120, 306545)
    end
end

function mod:SPELL_AURA_REMOVED(args)
    if args:IsSpellID(306464) then
        timerArcaneStormCD:Start()
        warnArcaneStormSoon:Schedule(68)
	elseif args:IsSpellID(306549) then
        timerIceWrathCD:Start()
    end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellStart then
        self:ScheduleMethod(54, "OnCombat")
		timerCombatStart:Start()
	end
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 3392, "Lady Jaina Proudmoore")
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 3392, "Lady Jaina Proudmoore", wipe)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end
