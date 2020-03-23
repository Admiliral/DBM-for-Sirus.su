local mod	= DBM:NewMod("Solarian", "DBM-TheEye")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))

mod:SetCreatureID(18805)
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(7, 8)

mod:RegisterEvents(
    "CHAT_MSG_MONSTER_YELL",
    "UNIT_TARGET",
	"SPELL_AURA_APPLIED"
)

local warnWrath         = mod:NewTargetAnnounce(42783, 4)
local warnAddsSoon      = mod:NewAnnounce("WarnAddsSoon", 3, 55342)

local specWarnWrath     = mod:NewSpecialWarningRun(42783)

local timerAdds         = mod:NewTimer(60, "TimerAdds", 55342)
local timerPriests      = mod:NewTimer(14, "TimerPriests", 47788)
local timerWrath	 	= mod:NewTargetTimer(6, 42783)
local timerNextWrath    = mod:NewCDTimer(21, 42783)

local priests = true

function mod:PriestIcon()
    if DBM:GetRaidRank() >= 1 then
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid"..i.."target") == L.Priest then
				priests = false
				SetRaidTarget("raid"..i.."target", 8)
                break
			end
		end
	end
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 18805, "High Astromancer Solarian")
    timerAdds:Start()
    warnAddsSoon:Schedule(52)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 18805, "High Astromancer Solarian", wipe)
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellAdds then
		timerPriests:Start()
        timerNextWrath:Start()
    elseif msg == L.YellPriests  then
        priests = true
        timerAdds:Start()
        warnAddsSoon:Schedule(52)
    end
end

function mod:SPELL_AURA_APPLIED(args)
    if args:IsSpellID(42783) then
        timerNextWrath:Start()
        warnWrath:Show(args.destName)
        timerWrath:Start(args.destName)
        self:SetIcon(args.destName, 7, 6)
        if args:IsPlayer() then
            specWarnWrath:Show()
        end
    end
end

function mod:UNIT_TARGET()
	if priests then
		self:PriestIcon()
	end
end
