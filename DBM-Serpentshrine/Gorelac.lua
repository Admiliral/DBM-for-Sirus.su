local mod	= DBM:NewMod("Gorelac", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20201208235000")

mod:SetCreatureID(55681)
mod:RegisterCombat("combat", 55681)
mod:SetUsedIcons(3, 4, 5, 6, 7, 8)


mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"UNIT_DIED",
	"UNIT_TARGET",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_LOOT",
	"SWING_DAMAGE"
)


local berserkTimer          = mod:NewBerserkTimer(1200)



mod.vb.phase = 0



function mod:OnCombatStart()
	self.vb.phase = 1
	berserkTimer:Start()
	DBM:FireCustomEvent("DBM_EncounterStart", 55681, "Gorelac")
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 55681, "Gorelac", wipe)
end


function mod:SPELL_CAST_START(args)

end

function mod:SPELL_AURA_APPLIED(args)

end




function mod:SPELL_CAST_SUCCESS(args)

end

