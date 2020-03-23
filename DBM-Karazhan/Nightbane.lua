local mod	= DBM:NewMod("Nightbane", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 176 $"):sub(12, -3))
mod:SetCreatureID(17225)
--mod:RegisterCombat("yell", L.DBM_NB_YELL_PULL)
mod:RegisterCombat("combat", 17225)
mod:SetUsedIcons(6, 7, 8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
    "SPELL_AURA_REMOVED",
	"CHAT_MSG_MONSTER_EMOTE",
    "UNIT_HEALTH"
)   

-- local warningBone			= mod:NewSpellAnnounce(37098, 3)
-- local warningFearSoon		= mod:NewSoonAnnounce(36922, 2)
-- local warningFear			= mod:NewSpellAnnounce(36922, 3)
-- local warningAsh			= mod:NewTargetAnnounce(30130, 2, nil, false)
-- local WarnAir				= mod:NewAnnounce("DBM_NB_AIR_WARN", 2, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
-- local WarnNBDown1			= mod:NewAnnounce("DBM_NB_DOWN_WARN", 2, nil, nil, false)
-- local WarnNBDown2			= mod:NewAnnounce("DBM_NB_DOWN_WARN2", 3, nil, nil, false)
-- 
-- local specWarnCharred		= mod:NewSpecialWarningMove(30129)
-- 
-- local timerNightbane		= mod:NewTimer(34, "timerNightbane", "Interface\\Icons\\Ability_Mount_Undeadhorse")
-- local timerAirPhase			= mod:NewTimer(57, "timerAirPhase", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
-- local timerFearCD			= mod:NewNextTimer(31.5, 36922)
-- local timerFear				= mod:NewCastTimer(1.5, 36922)
-- 
-- mod:AddBoolOption("PrewarnGroundPhase", true, "announce")
-- 
-- function mod:CHAT_MSG_MONSTER_EMOTE(msg)
-- 	if msg == L.DBM_NB_EMOTE_PULL then
-- 		timerNightbane:Start()
-- 	end
-- end
-- 
-- function mod:SPELL_CAST_START(args)
-- 	if args:IsSpellID(36922) then
-- 		warningFearSoon:Cancel()
-- 		warningFear:Show()
-- 		timerFear:Start()
-- 		timerFearCD:Start()
-- 		warningFearSoon:Schedule(29)
-- 	end
-- end
-- 
-- function mod:SPELL_CAST_SUCCESS(args)
-- 	if args:IsSpellID(37098) then
-- 		warningBone:Show()
-- 	end
-- end
-- 
-- function mod:SPELL_AURA_APPLIED(args)
-- 	if args:IsSpellID(30129) and args:IsPlayer() then
-- 		specWarnCharred:Show()
-- 	elseif args:IsSpellID(30130) then
-- 		warningAsh:Show(args.destName)
-- 	end
-- end
-- 
-- function mod:CHAT_MSG_MONSTER_YELL(msg)
-- 	if msg == L.DBM_NB_YELL_AIR then
-- 		WarnAir:Show()
-- 		timerAirPhase:Start()
-- 		if self.Options.PrewarnGroundPhase then
-- 			WarnNBDown1:Cancel()
-- 			WarnNBDown2:Cancel()
-- 			WarnNBDown1:Schedule(42)
-- 			WarnNBDown2:Schedule(52)
-- 		end
-- --[[	elseif msg == L.DBM_NB_YELL_GROUND or msg == L.DBM_NB_YELL_GROUND2 then
-- 		timerAirPhase:Update(43, 57)--this may not be needed--]]
-- 	end
-- end

local timerGrievingFireCD		= mod:NewCDTimer(13, 305375)
local timerConflCD			    = mod:NewCDTimer(30, 305377)
local specWarnPyromancer	    = mod:NewSpecialWarningYou(305382)
local warnPyromancer			= mod:NewTargetAnnounce(305382, 3)

local pyromancerTargets		= {}
local alivePyromancers      = 0
local groundPhase = 0
local conflCount = 0
local isPyroFirst = true
local isStart = true

mod:AddBoolOption("RemoveWeaponOnMindControl", true)
mod:AddBoolOption("SetIconOnPyromancer", true)
mod:AddBoolOption("AnnouncePyromancerIcons", true)

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 17225, "Nightbane")
    if mod:IsDifficulty("normal10") then
    elseif mod:IsDifficulty("heroic10") and isStart then
        timerGrievingFireCD:Start()
        timerConflCD:Start()
        table.wipe(pyromancerTargets)
        groundPhase = 0
        alivePyromancers = 0
        conflCount = 0
        isPyroFirst = true
        isStart = false
    end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 17225, "Nightbane", wipe)
end

function mod:SPELL_CAST_START(args)
    if args:IsSpellID(305375) then
        timerGrievingFireCD:Start()
    elseif args:IsSpellID(305377) then
	    self:PlaySound("orgasm", "AAAAA", "AAAA_lew")             -- AAAAAAAAAA!!!
        if conflCount <=1 then
            timerConflCD:Start()
            conflCount = conflCount + 1
        else
            conflCount = 0
        end
    elseif args:IsSpellID(305386) then
        if UnitAura("player", L.Pyromancer, nil, "HARMFUL") or UnitAura("player", L.Hypothermia, nil, "HARMFUL") and self.Options.RemoveWeaponOnMindControl then
            if self:IsWeaponDependent("player") then
                PickupInventoryItem(16)
                PutItemInBackpack()
                PickupInventoryItem(17)
                PutItemInBackpack()
            elseif select(2, UnitClass("player")) == "HUNTER" then
                PickupInventoryItem(18)
                PutItemInBackpack()
            end
        end
        table.wipe(pyromancerTargets)
        isPyroFirst = true
        groundPhase = 0
        alivePyromancers = 0
        conflCount = 0
    end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(305382) then
        if args:IsPlayer() then
		      self:PlaySound("welcome")      -- Welcome to the club buddy... *fucking slap*
            specWarnPyromancer:Show()
        end
        pyromancerTargets[#pyromancerTargets + 1] = args.destName
        if #pyromancerTargets >= 3 and isPyroFirst then
            warnPyromancer:Show(table.concat(pyromancerTargets, "<, >"))
            if self.Options.SetIconOnPyromancer then
                table.sort(pyromancerTargets, function(v1,v2) return DBM:GetRaidSubgroup(v1) < DBM:GetRaidSubgroup(v2) end)
                local pyroIcons = 8
                for i, v in ipairs(pyromancerTargets) do
                    if self.Options.AnnouncePyromancerIcons then
                        SendChatMessage(L.PyromancerIconSet:format(pyroIcons, v), "RAID")
                    end
                    self:SetIcon(v, pyroIcons)
                    pyroIcons = pyroIcons - 1
                end
            end
            isPyroFirst = false
        end
    elseif args:IsSpellID(305388) then
        alivePyromancers = alivePyromancers + 1
    end
end

function mod:SPELL_AURA_REMOVED(args)
    if args:IsSpellID(305388) then
        if groundPhase == alivePyromancers - 1 then
            timerGrievingFireCD:Start(35)
            timerConflCD:Start(54)
        else 
            groundPhase = groundPhase + 1
        end
    end
end
 function mod:CHAT_MSG_MONSTER_EMOTE(msg)
 	if msg == L.DBM_NB_EMOTE_PULL then
        isStart = true
        self:PlaySound("pike")           -- (ost "Крутое пике!" аКа "Деревня дураков, Каламбур")
 	end
 end
