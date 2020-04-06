local mod	= DBM:NewMod("Dalliah", "DBM-Party-BC", 10)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(20885)
mod:SetZone()

mod:RegisterCombat("combat", 20885)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED"
)

local timerGiftCD		= mod:NewCDTimer(20, 39009)
local timerWhirlCD		= mod:NewCDTimer(20, 36142)
local timerWaveCD		= mod:NewCDTimer(16, 39016)
local timerHealCD		= mod:NewCDTimer(20, 39013)

local warnGift  		= mod:NewTargetAnnounce(39009, 3)


function mod:OnCombatStart(delay)
	timerGiftCD:Start(3)
	timerWhirlCD:Start(8)
	timerWaveCD:Start(15)
	timerHealCD:Start(17)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(39016) then
		timerWaveCD:Start()
	elseif args:IsSpellID(39013) then
		timerHealCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(36142) then
		timerWhirlCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(39009) then
		timerGiftCD:Start()
		warnGift:Show(args.destName)
	end
end
