local mod	= DBM:NewMod("Freya_Elders", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

-- passive mod to provide information for multiple fight (trash respawn)
mod:SetCreatureID(32914, 32915, 32913)
mod:RegisterCombat("combat", 32914, 32915, 32913)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"UNIT_DIED"
)

local specWarnImpale			= mod:NewSpecialWarningTaunt(312859, nil, nil, nil, 1, 2)
local specWarnFistofStone	= mod:NewSpecialWarningSpell(312853, "Tank", nil, nil, 4, 2)
local specWarnGroundTremor	= mod:NewSpecialWarningCast(312856, "SpellCaster")

local timerImpale			= mod:NewTargetTimer(20, 312859, nil, "Healer|Tank", nil, 5)
local timerStoneCD 		    = mod:NewCDTimer(71, 312853)
local timerCoreCD 		    = mod:NewCDTimer(39.6, 312842)

mod:AddBoolOption("PlaySoundOnFistOfStone", false)
mod:AddBoolOption("TrashRespawnTimer", true, "timer")

--
-- Trash: 33430 Guardian Lasher (flower)
-- 33355 (nymph)
-- 33354 (tree)
--
-- Elder Stonebark (ground tremor / fist of stone)
-- Elder Brightleaf (unstable sunbeam)
--
--Mob IDs:
-- Elder Ironbranch: 32913
-- Elder Brightleaf: 32915
-- Elder Stonebark: 32914
--
function mod:OnCombatStart(delay)
    timerStoneCD:Start(26)
	timerCoreCD:Start()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(62344, 300893, 312500, 312853) then 					-- Fists of Stone
		specWarnFistofStone:Show()
		specWarnFistofStone:Play("justrun")
	elseif args:IsSpellID(62325, 62932, 312489, 312503, 312842, 312856) then		-- Ground Tremor
		specWarnGroundTremor:Show()
		specWarnGroundTremor:Play("stopcast")
	elseif args:IsSpellID(312857) then
        timerCoreCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62310, 62928, 312506, 312859) then 			-- Impale
		if not args:IsPlayer() then
			specWarnImpale:Show(args.destName)
			specWarnImpale:Play("tauntboss")
		end
		timerImpale:Start(args.destName)
	end
end

function mod:UNIT_DIED(args)
	if self.Options.TrashRespawnTimer and not DBM.Bars:GetBar(L.TrashRespawnTimer) then
		local guid = tonumber(args.destGUID:sub(9, 12), 16)
		if guid == 33430 or guid == 33355 or guid == 33354 then		-- guardian lasher / nymph / tree
			DBM.Bars:CreateBar(7200, L.TrashRespawnTimer)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(62310, 62928, 312506, 312859) then 			-- Impale
		timerImpale:Stop(args.destName)
	end
end