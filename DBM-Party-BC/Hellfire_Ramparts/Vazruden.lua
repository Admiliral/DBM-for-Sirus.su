local mod	= DBM:NewMod("Vazruden", "DBM-Party-BC", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(17307, 17537, 17536)
mod:SetZone()

mod:RegisterCombat("combat", 17537)

mod:RegisterEvents(
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS"
)

local timerScreamCD		= mod:NewCDTimer(21, 22686)
local timerFireCD		= mod:NewCDTimer(12, 36921)
local warnScreamKick	= mod:NewSpecialWarningInterrupt(22686)

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(22686) then
		timerScreamCD:Start()
		warnScreamKick:Show(args.sourceName)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(36921) then
		timerFireCD:Start()
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L.EmoteNazan then
		timerFireCD:Start()
		timerScreamCD:Start(5)
	end
end
