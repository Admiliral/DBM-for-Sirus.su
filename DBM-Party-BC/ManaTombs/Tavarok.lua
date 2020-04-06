local mod	= DBM:NewMod("Tavarok", "DBM-Party-BC", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(18343)
mod:SetZone()

mod:RegisterCombat("combat", 18343)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS"
)

local timerEarthquakeCD		= mod:NewCDTimer(22, 33919)
local timerCageCD			= mod:NewCDTimer(25, 32361)
local timerCage				= mod:NewTargetTimer(2.3, 32361)
local warnCage				= mod:NewTargetAnnounce(32361, 3)

function mod:OnCombatStart(delay)
	timerEarthquakeCD:Start(10)
	timerCageCD:Start(17)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(33919) then
		timerEarthquakeCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(32361) then
		timerCageCD:Start()
		timerCage:Start(args.destName)
		warnCage:Show(args.destName)
	end
end
