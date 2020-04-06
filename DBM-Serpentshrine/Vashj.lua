local mod	= DBM:NewMod("Vashj", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))

mod:SetCreatureID(21212)
mod:RegisterCombat("combat", 21212)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"UNIT_DIED",
	"UNIT_TARGET",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_LOOT"
)

local warnCore           = mod:NewAnnounce("WarnCore", 3, 38132)
local warnCharge         = mod:NewTargetAnnounce(38280, 4)
local warnPhase          = mod:NewAnnounce("WarnPhase", 1)
local warnElemental      = mod:NewAnnounce("WarnElemental", 4)

local specWarnCore       = mod:NewSpecialWarningYou(38132)
local specWarnCharge     = mod:NewSpecialWarningRun(38280)

local timerStrider       = mod:NewTimer(66, "Strider", "Interface\\Icons\\INV_Misc_Fish_13")
local timerElemental     = mod:NewTimer(53, "TaintedElemental", "Interface\\Icons\\Spell_Nature_ElementalShields")
local timerNaga          = mod:NewTimer(47.5, "Naga", "Interface\\Icons\\INV_Misc_MonsterHead_02")
local timerCharge        = mod:NewTargetTimer(20, 38280)

local ti = true


function mod:NextStrider()
	timerStrider:Start()
	self:UnscheduleMethod("NextStrider")
	self:ScheduleMethod(66, "NextStrider")
end

function mod:NextNaga()
	timerNaga:Start()
	self:UnscheduleMethod("NextNaga")
	self:ScheduleMethod(47.5, "NextNaga")
end

function mod:ElementalSoon()
	ti = true
	warnElemental:Show()
end

function mod:TaintedIcon()
	if DBM:GetRaidRank() >= 1 then
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid"..i.."target") == L.TaintedElemental then
				ti = false
				SetRaidTarget("raid"..i.."target", 8)
				break
			end
		end
	end
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 21212, "Lady Vashj")
	ti = true
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 21212, "Lady Vashj", wipe)
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(38132) then
		warnCore:Show(args.destName)
		if args:IsPlayer() then
			specWarnCore:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(38280) then
		warnCharge:Show(args.destName)
		timerCharge:Start(args.destName)
		if args:IsPlayer() then
			specWarnCharge:Show()
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellPhase2 then
		warnPhase:Show(2)
		timerStrider:Start()
		timerElemental:Start()
		timerNaga:Start()
		self:ScheduleMethod(66, "NextStrider")
		self:ScheduleMethod(47.5, "NextNaga")
		self:ScheduleMethod(48, "ElementalSoon")
	elseif msg == L.YellPhase3 then
		warnPhase:Show(3)
		timerStrider:Cancel()
		timerElemental:Cancel()
		timerNaga:Cancel()
		self:UnscheduleMethod("NextStrider")
		self:UnscheduleMethod("NextNaga")
	end
end

function mod:UNIT_DIED(args)
	if args.destName == L.TaintedElemental then
		timerElemental:Start()
		self:ScheduleMethod(48, "ElementalSoon")
	end
end

function mod:UNIT_TARGET()
	if ti then
		self:TaintedIcon()
	end
end

function mod:OnCombatEnd()
	self:UnscheduleMethod("NextStrider")
	self:UnscheduleMethod("NextNaga")
	self:UnscheduleMethod("ElementalSoon")
end
