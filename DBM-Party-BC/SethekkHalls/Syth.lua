local mod	= DBM:NewMod("Syth", "DBM-Party-BC", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(18472)
mod:SetZone()

mod:RegisterCombat("combat", 18472)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"CHAT_MSG_MONSTER_YELL"
)

local timerFroshShockCD = mod:NewCDTimer(10, 21401)


function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(21401) then
		timerFroshShockCD:Start()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.yellSummon then
		timerFroshShockCD:Start()
	end
end
