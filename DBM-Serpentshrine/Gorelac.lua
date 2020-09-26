local mod	= DBM:NewMod("Gorelac", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))

mod:SetCreatureID(121217)
mod:RegisterCombat("combat")
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(3, 4, 5, 6, 7, 8)


mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"UNIT_HEALTH",
	"CHAT_MSG_MONSTER_YELL"
)

----------хм-------------------



mod.vb.phase = 0



function mod:OnCombatStart()
	self.vb.phase = 1
	if mod:IsDifficulty("heroic25") then
	else
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 21216, "Hydross the Unstable", wipe)
end


function mod:SPELL_CAST_START(args)

end

function mod:SPELL_AURA_APPLIED(args)

end




function mod:SPELL_CAST_SUCCESS(args)

end

