local mod	= DBM:NewMod("Zereketh", "DBM-Party-BC", 10)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(20870)
mod:SetZone()

mod:RegisterCombat("combat", 20870)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED"
)

local timerRingCD	= mod:NewCDTimer(8, 39005)
local timerSeedCD	= mod:NewCDTimer(20, 39367)
local timerVoidCD	= mod:NewCDTimer(8, 36119)

local warnRing		= mod:NewSpellAnnounce(39005, 3)
local warnSeed		= mod:NewTargetAnnounce(39367, 3)
local warnVoid		= mod:NewTargetAnnounce(36119, 3)

local specWarnVoid	= mod:NewSpecialWarningMove(36119)

function mod:OnCombatStart(delay)
	timerRingCD:Start()
	timerSeedCD:Start()
	timerVoidCD:Start(20)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(39005) then
		timerRingCD:Start()
		warnRing:Show()
	elseif args:IsSpellID(39367) then
		timerSeedCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(36119) then
		timerVoidCD:Start()
		warnVoid:Show(args.destName)
		if args:IsPlayer() then
			specWarnVoid:Show()
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(39367) then
		warnSeed:Show(args.destName)
	end
end
