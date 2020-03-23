local mod	= DBM:NewMod("Huhuran", "DBM-AQ40", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 185 $"):sub(12, -3))
mod:SetCreatureID(15509)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"UNIT_HEALTH"
)

local warnSting			= mod:NewTargetAnnounce(26180, 2)
local warnAcid			= mod:NewAnnounce("WarnAcid", 3)
local warnBerserkSoon	= mod:NewSoonAnnounce(26068, 2)

local timerSting		= mod:NewBuffActiveTimer(12, 26180)
local timerStingCD		= mod:NewCDTimer(20, 26180)
local timerAcid			= mod:NewTargetTimer(30, 26050)

local specWarnAcid		= mod:NewSpecialWarningStack(26050, nil, 10)

local prewarn_berserk
local StingTargets = {}

function mod:OnCombatStart(delay)
	prewarn_berserk = false
	table.wipe(StingTargets)
end

local function warnStingTargets()
	warnSting:Show(table.concat(StingTargets, "<, >"))
	timerSting:Start()
	table.wipe(StingTargets)
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(26180) then
		StingTargets[#StingTargets + 1] = args.destName
		self:Unschedule(warnStingTargets)
		self:Schedule(0.3, warnStingTargets)
	elseif args:IsSpellID(26050) then
		warnAcid:Show(args.spellName, args.destName, args.amount or 1)
		timerAcid:Start(args.destName)
		if args:IsPlayer() and (args.amount or 1) >= 10 then
			specWarnAcid:Show()
		end
	end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(26180) then
		timerSting:Cancel()
	end
end

function mod:UNIT_HEALTH(uId)
	if UnitHealth(uId) / UnitHealthMax(uId) <= 0.35 and self:GetUnitCreatureId(uId) == 15509 and not prewarn_berserk then
		warnBerserkSoon:Show()
		prewarn_berserk = true
	end
end
		