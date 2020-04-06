local mod	= DBM:NewMod("BlackStalker", "DBM-Party-BC", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(17882)
mod:SetZone()

mod:RegisterCombat("combat", 17882)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED"
)

local timerLightningCD       = mod:NewCDTimer(14, 31717)
local timerChargeCD	         = mod:NewCDTimer(10, 31715)
local timerCharge            = mod:NewTargetTimer(12, 31715)
local specWarnCharge         = mod:NewSpecialWarningYou(31715)
local iconCharge = 8

function mod:OnCombatStart(delay)
	timerLightningCD:Start()
	timerChargeCD:Start()
	iconCharge = 8
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(31717) then
		timerLightningCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(31715) then
		timerChargeCD:Start()
		timerCharge:Start(args.destName)
		self:SetIcon(args.destName, iconCharge, 12)
		iconCharge = (iconCharge - 1) < 7 and 8 or iconCharge - 1
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(31715) and args:IsPlayer() then
		specWarnCharge:Show()
	end
end
