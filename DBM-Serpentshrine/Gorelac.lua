local mod	= DBM:NewMod("Gorelac", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210625173900")

mod:SetCreatureID(55681)
mod:RegisterCombat("combat", 55681)
mod:SetUsedIcons(8, 7)


mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"UNIT_DIED",
	"UNIT_TARGET",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_LOOT",
	"SWING_DAMAGE"
)



local warnStrongBeat	      = mod:NewStackAnnounce(310548, 1, nil, "Tank")  --Клешня
local warnPoisonous	          = mod:NewSpellAnnounce(310549, 1)   --Ядовитая рвота
local warnMassiveShell	      = mod:NewTargetAnnounce(310560, 1)  --Обстрел
local warnPowerfulShot	      = mod:NewSpellAnnounce(310564, 2)   --Мощный выстрел
local warnCallGuardians	      = mod:NewSpellAnnounce(310557, 1)   --Вызов треша
local warnParalysis	          = mod:NewSpellAnnounce(310555, 2)   --Паралич
local warnCallGuardiansSoon   = mod:NewPreWarnAnnounce(310557, 5, 1)  --Вызов треша

local specwarnCallGuardians   = mod:NewSpecialWarningSwitch(310557, "Dps", nil, nil, 1, 2)  --Треш
local specWarnShrillScreech   = mod:NewSpecialWarning("specWarnShrillScreech", "HasInterrupt")
local specWarnRippingThorn    = mod:NewSpecialWarningStack(310546, nil, 7, nil, nil, 1, 6)
local specWarnPoisonousBlood  = mod:NewSpecialWarningStack(310547, nil, 7, nil, nil, 1, 6)
local specWarnPoisonous	      = mod:NewSpecialWarningYou(310549, nil, nil, nil, 1, 2)  --Рвота
local specWarnStrongBeat      = mod:NewSpecialWarningYou(310548, nil, nil, nil, 1, 2)  --Клешня

local timerParalysis	      = mod:NewBuffFadesTimer(10, 310555, nil, nil, nil, 7, nil, DBM_CORE_MAGIC_ICON)
local timerPoisonous	      = mod:NewBuffFadesTimer(30, 310549, nil, "Tank|Healer", nil, 5, nil)
local timerParalysisCD        = mod:NewCDTimer(20, 310555, nil, nil, nil, 7, nil, DBM_CORE_MAGIC_ICON)
local timerPoisonousCD	      = mod:NewCDTimer(25, 310549, nil, nil, nil, 3, nil, DBM_CORE_TANK_ICON)
local timerStrongBeatCD	      = mod:NewCDTimer(25, 310548, nil, nil, nil, 3, nil, DBM_CORE_TANK_ICON)
local timerCallGuardiansCD    = mod:NewNextTimer(45, 310557, nil, nil, nil, 1, nil, DBM_CORE_DEADLY_ICON)
local timerStrongBeat         = mod:NewBuffFadesTimer(30, 310548, nil, "Tank|Healer", nil, 5, nil)
local timerRippingThorn       = mod:NewBuffFadesTimer(12, 310546, nil, nil, nil, 5)
local timerPoisonousBlood     = mod:NewBuffFadesTimer(6, 310547, nil, nil, nil, 5)

local enrageTimer	          = mod:NewBerserkTimer(750)
local YellPowerfulShot			=mod:NewYell(310565)
local YellMassiveShell			=mod:NewYell(310563)

mod:AddSetIconOption("SetIconOnPowerfulShotTarget", 310564, true, false, {8})
mod:AddSetIconOption("SetIconOnMassiveShellTarget", 310560, true, false, {7})

mod.vb.phase = 0


function mod:OnCombatStart(delay)
        DBM:FireCustomEvent("DBM_EncounterStart", 55681, "Gorelac")
        enrageTimer:Start(-delay)
        timerCallGuardiansCD:Start(45-delay)
        warnCallGuardiansSoon:Schedule(40-delay)
end

function mod:OnCombatEnd(wipe)
	    DBM:FireCustomEvent("DBM_EncounterEnd", 55681, "Gorelac", wipe)
end


function mod:SPELL_CAST_START(args)
        if args:IsSpellID(310566) then                        --Пронзительный визг
		    specWarnShrillScreech:Show()
            specWarnShrillScreech:Play("kickcast")
        elseif args:IsSpellID(310549) then                    --Рвота
            warnPoisonous:Show()
            timerPoisonousCD:Start()
        elseif args:IsSpellID(310564, 310565) then            --Мощный выстрел
		    warnPowerfulShot:Show(args.destName)
                if self.Options.SetIconOnPowerfulShotTarget then
			        self:SetIcon(args.destName, 8, 10)
                end
                if args:IsPlayer() then
					YellPowerfulShot:Yell()
                end
        elseif args:IsSpellID(310560, 310561, 310562, 310563) then         --Обстрел
		    warnMassiveShell:Show()
                if self.Options.SetIconOnMassiveShellTarget then
			        self:SetIcon(args.destName, 7, 10)
                end
                if args:IsPlayer() then
					YellMassiveShell:Yell()
                end
        elseif args:IsSpellID(310557, 310558, 310559) then            --Призыв охранителей
            warnCallGuardians:Show()
		    specwarnCallGuardians:Show()
            specwarnCallGuardians:Play("killmob")
            timerCallGuardiansCD:Start()
            warnCallGuardiansSoon:Schedule(40)
    end
end

function mod:SPELL_AURA_APPLIED(args)
        if args:IsSpellID(310546) then	  --Шип
		    timerRippingThorn:Start()
		if (args.amount) >= 12 and args:IsPlayer() then
			specWarnRippingThorn:Show(args.amount)
			specWarnRippingThorn:Play("stackhigh")
        end

        elseif args:IsSpellID(310547) then	--Кровь
		    timerPoisonousBlood:Start()
		if (args.amount) >= 12 and args:IsPlayer() then
			specWarnPoisonousBlood:Show(args.amount)
			specWarnPoisonousBlood:Play("stackhigh")
        end

        elseif args:IsSpellID(310548) then		--Клешня
            warnStrongBeat:Show(args.destName, args.amount or 1)
        if args:IsPlayer() then
            specWarnStrongBeat:Show()
            timerStrongBeat:Start(args.destName)
        end

        elseif args:IsSpellID(310555) then		--Паралич
            warnParalysis:Show()
            timerParalysis:Start()
            timerParalysisCD:Start()

        elseif args:IsSpellID(310549) then		--Рвота
            timerPoisonous:Start(args.destName)
            specWarnPoisonous:Show()
    end
end

function mod:SPELL_CAST_SUCCESS(args)
        if args:IsSpellID(310548) then                 --Клешня
            timerStrongBeatCD:Start()
    end
end

function mod:SPELL_AURA_REMOVED(args)
        if args:IsSpellID(310564) then     --Мощный выстрел
            if self.Options.SetIconOnPowerfulShotTarget then
			    self:SetIcon(args.destName, 0)
		end
        elseif args:IsSpellID(310549) then     --Рвота
            if args:IsPlayer() then
                timerPoisonous:Cancel()
		end
        elseif args:IsSpellID(310548) then     --Клешня
            if args:IsPlayer() then
                timerStrongBeat:Cancel()
		end
        elseif args:IsSpellID(310555) then     --Паралич
            if args:IsPlayer() then
                timerParalysis:Cancel()
		end
        elseif args:IsSpellID(310560) then     --Обстрел
            if self.Options.SetIconOnMassiveShellTarget then
			    self:SetIcon(args.destName, 0)
		end
        elseif args:IsSpellID(310547) then	--Кровь
		    if args:IsPlayer() then
			    timerPoisonousBlood:Cancel()
        end
        elseif args:IsSpellID(310546) then	--Шип
		    if args:IsPlayer() then
			    timerRippingThorn:Cancel()
		end
    end
end