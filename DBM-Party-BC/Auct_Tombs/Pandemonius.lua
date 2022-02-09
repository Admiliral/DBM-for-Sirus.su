local mod	= DBM:NewMod("Pandemonius", "DBM-Party-BC", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(18341)
mod:SetZone()

mod:RegisterCombat("combat", 18341)

mod:RegisterEvents(
	"SPELL_CAST_START"
)

local specWarnShell		= mod:NewSpecialWarningCast(38759)
local timerShellCD		= mod:NewCDTimer(20, 38759)
local timerBlastCD		= mod:NewCDTimer(20, 38760)
local firstBlast = true

function mod:blastreset()
	firstBlast = true
end

function mod:OnCombatStart(delay)
	timerBlastCD:Start()
	timerShellCD:Start()
	firstBlast = true
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(38760) and firstBlast then
		firstBlast = false
		timerBlastCD:Start()
		self:ScheduleMethod(10, "blastreset")
	elseif args:IsSpellID(38759) then
		specWarnShell:Show()
		timerShellCD:Start()
	end
end
