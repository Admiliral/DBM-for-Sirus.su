local mod	= DBM:NewMod("Shaffar", "DBM-Party-BC", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(18344)
mod:SetZone()

mod:RegisterCombat("combat", 18344)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"SPELL_CAST_START"
)

local timerFireballCD		= mod:NewCDTimer(5, 32363)
local timerFrostboltCD		= mod:NewCDTimer(5, 32364)
local timerNovaCD			= mod:NewCDTimer(24, 32365)
local timerBlinkCD			= mod:NewCDTimer(24, 34605)
local timerEtherealOrb		= mod:NewTimer(10, "TimerEtherealOrb",  64465)
local timerEtherealSpawn	= mod:NewTimer(10, "TimerEtherealSpawn",  69960)

function mod:ethereal()
	timerEtherealOrb:Start()
	timerEtherealSpawn:Start()
	self:ScheduleMethod(10, "ethereal")
end
function mod:OnCombatStart(delay)
	timerFireballCD:Start()
	timerFrostboltCD:Start()
	timerNovaCD:Start(15)
	timerBlinkCD:Start(16)
	timerEtherealOrb:Start()
	timerEtherealSpawn:Start()
	self:ScheduleMethod(10, "ethereal")
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(36814) then
--		timerWound:Start(args.amount*5 .. "%")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(32365) then
		timerNovaCD:Start()
	elseif args:IsSpellID(34605) then
	end
end
