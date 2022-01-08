local mod	= DBM:NewMod("KaelThas", "DBM-TheEye")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210214160000")

mod:SetCreatureID(19622)
mod:RegisterCombat("yell", L.YellPhase1)
mod:SetUsedIcons(5, 6, 7, 8)
mod:AddBoolOption("RemoveWeaponOnMindControl", true)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_EMOTE",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"UNIT_TARGET",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS"
)

local warnPhase             = mod:NewAnnounce("WarnPhase", 1)
local warnNextAdd           = mod:NewAnnounce("WarnNextAdd", 2)
local warnTalaTarget        = mod:NewAnnounce("WarnTalaTarget", 4)
local warnConflagrateSoon   = mod:NewSoonAnnounce(37018, 2)
local warnConflagrate       = mod:NewTargetAnnounce(37018, 4)
local warnBombSoon          = mod:NewSoonAnnounce(37036, 2)
local warnBarrierSoon       = mod:NewSoonAnnounce(36815, 2)
local warnPhoenixSoon       = mod:NewSoonAnnounce(36723, 2)
local warnMCSoon            = mod:NewSoonAnnounce(36797, 2)
local warnMC                = mod:NewTargetAnnounce(36797, 3)
local warnGravitySoon       = mod:NewSoonAnnounce(35941, 2)

local specWarnTalaTarget    = mod:NewSpecialWarning("SpecWarnTalaTarget", nil, nil, nil, 1, 2)

local timerNextAdd          = mod:NewTimer(30, "TimerNextAdd", "Interface\\Icons\\Spell_Nature_WispSplode", nil, nil, 2)
local timerPhase3           = mod:NewTimer(123, "TimerPhase3", "Interface\\Icons\\Spell_Shadow_AnimateDead", nil, nil, 2)
local timerPhase4           = mod:NewTimer(180, "TimerPhase4", 34753, nil, nil, 2)
local timerTalaTarget       = mod:NewTimer(8.5, "TimerTalaTarget", "Interface\\Icons\\Spell_Fire_BurningSpeed")
local timerRoarCD           = mod:NewCDTimer(31, 40636, nil, nil, nil, 3)
local timerConflagrateCD    = mod:NewCDTimer(20, 37018, nil, nil, nil, 3)
local timerBombCD           = mod:NewCDTimer(25, 37036, nil, nil, nil, 3)
local timerFlameStrike      = mod:NewCDTimer(35, 36731, nil, nil, nil, 3)

local timerBarrierCD        = mod:NewCDTimer(70, 36815, nil, nil, nil, 3)
local timerPhoenixCD        = mod:NewCDTimer(60, 36723, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)
local timerMCCD             = mod:NewCDTimer(70, 36797, nil, nil, nil, 3)

local timerGravity          = mod:NewTimer(32.5, "TimerGravity", "Interface\\Icons\\Spell_Magic_FeatherFall", nil, nil, 4, nil, DBM_CORE_DEADLY_ICON, nil, 2, 5)
local timerGravityCD        = mod:NewCDTimer(90, 35941, nil, nil, nil, 4, nil, DBM_CORE_DEADLY_ICON, nil, 2, 4)

--------------------------хм------------------------

local warnFurious		= mod:NewStackAnnounce(308732, 2, nil, "Tank|Healer") -- яростный удар
local warnJustice		= mod:NewStackAnnounce(308741, 2, nil, "Tank|Healer") -- правосудие тьмы
local warnIsc			= mod:NewStackAnnounce(308756, 2, nil, "Tank|Healer") -- Искрящий
local warnShadow        = mod:NewSoonAnnounce(308742, 2) -- освященеи тенью (лужа)
local warnBombhm        = mod:NewTargetAnnounce(308750, 2) -- бомба
local warnVzriv         = mod:NewTargetAnnounce(308797, 2) -- лужа

local specWarnCata      = mod:NewSpecialWarningRun(308790, nil, nil, nil, 4, 2)
local specWarnVzriv     = mod:NewSpecialWarningRun(308797, nil, nil, nil, 3, 3)
local yellVzriv			= mod:NewYell(308797, nil, nil, nil, "YELL")

local timerFuriousCD    = mod:NewCDTimer(7, 308732, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerFurious		= mod:NewTargetTimer(30, 308732, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerJusticeCD    = mod:NewCDTimer(9, 308741, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerJustice		= mod:NewTargetTimer(30, 308741, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerIsc	    	= mod:NewTargetTimer(15, 308756, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerShadowCD		= mod:NewCDTimer(17, 308742, nil, nil, nil, 4)
local timerBombhmCD		= mod:NewCDTimer(35, 308749, nil, nil, nil, 1)
local timerCataCD		= mod:NewCDTimer(126, 308790, nil, nil, nil, 2)
local timerCataCast		= mod:NewCastTimer(8, 308790, nil, nil, nil, 2)
local timerVzrivCD		= mod:NewCDTimer(115, 308797, nil, nil, nil, 2)
local timerVzrivCast    = mod:NewCastTimer(5, 308797, nil, nil, nil, 2)
local timerGravityH     = mod:NewTimer(63, "TimerGravity", "Interface\\Icons\\Spell_Magic_FeatherFall", nil, nil, 6, nil, DBM_CORE_DEADLY_ICON)
local timerGravityHCD	= mod:NewCDTimer(150, 35941, nil, nil, nil, 6, nil, DBM_CORE_DEADLY_ICON)
--local timerBurningCD    = mod:NewCDTimer(8, 308741, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON)
--local timerBurning		= mod:NewTargetTimer(30, 308741, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON)



----------------------------------------------------

--local Kel = true


mod:AddSetIconOption("SetIconOnMC", 36797, true, true, {6, 7, 8})
mod:AddSetIconOption("VzrivIcon", 308742, true, true, {8})
mod:AddBoolOption("AnnounceVzriv", false)
mod:AddBoolOption("RangeFrame", true)
mod:AddBoolOption("RemoveShadowResistanceBuffs", true)

mod.vb.phase = 0
local BombhmTargets = {}
local VzrivTargets = {}
local VzrivIcon = 8
local dominateMindTargets = {}
local dominateMindIcon = 8
local mincControl = {}
local axe = true

function mod:AxeIcon()
	for i = 1, GetNumRaidMembers() do
		if UnitName("raid"..i.."target") == L.Axe then
			axe = false
			SetRaidTarget("raid"..i.."target", 8)
			break
		end
	end
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 19622, "Kael'thas Sunstrider")
	self.vb.phase = 1
	dominateMindIcon = 8
	axe = true
	warnPhase:Show(L.WarnPhase1)
	timerNextAdd:Start(L.NamesAdds["Thaladred"])
	table.wipe(dominateMindTargets)
	table.wipe(mincControl)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 19622, "Kael'thas Sunstrider", wipe)
	DBM.RangeCheck:Hide()
end

function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg:match(L.TalaTarget) then
		local target = msg:sub(29,-3) or "Unknown"
		warnTalaTarget:Show(target)
		timerTalaTarget:Start(target)
		if target == UnitName("player") then
			specWarnTalaTarget:Show()
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if mod:IsDifficulty("heroic25") then
		if msg == L.YellSang then
		    timerTalaTarget:Cancel()
		    warnNextAdd:Show(L.NamesAdds["Lord Sanguinar"])
		    timerNextAdd:Start(12.5, L.NamesAdds["Lord Sanguinar"])
		elseif msg == L.YellCaper then
			timerRoarCD:Cancel()
			warnNextAdd:Show(L.NamesAdds["Capernian"])
			timerNextAdd:Start(7, L.NamesAdds["Capernian"])
			DBM.RangeCheck:Show(10)
		elseif msg == L.YellTelon then
			DBM.RangeCheck:Hide()
			warnConflagrateSoon:Cancel()
			timerConflagrateCD:Cancel()
			warnNextAdd:Show(L.NamesAdds["Telonicus"])
			timerNextAdd:Start(8.4, L.NamesAdds["Telonicus"])
		elseif msg == L.YellPhase3  then
			self.vb.phase = 3
			warnPhase:Show(L.WarnPhase3)
			timerPhase4:Start()
			timerRoarCD:Start()
			warnBombSoon:Schedule(10)
			timerBombCD:Start(15)
			DBM.RangeCheck:Show(10)
		elseif msg == L.YellPhase4  then
			self.vb.phase = 4
			warnPhase:Show(L.WarnPhase4)
			timerPhase4:Cancel()
			DBM.RangeCheck:Hide()
		elseif msg == L.YellPhase5  then
			self.vb.phase = 5
			warnPhase:Show(L.WarnPhase5)
		end
	else
		if msg == L.YellSang then
		    timerTalaTarget:Cancel()
			warnNextAdd:Show(L.NamesAdds["Lord Sanguinar"])
			timerNextAdd:Start(12.5, L.NamesAdds["Lord Sanguinar"])
			timerRoarCD:Start(33)
		elseif msg == L.YellCaper then
			timerRoarCD:Cancel()
			warnNextAdd:Show(L.NamesAdds["Capernian"])
			timerNextAdd:Start(7, L.NamesAdds["Capernian"])
			DBM.RangeCheck:Show(10)
		elseif msg == L.YellTelon then
			DBM.RangeCheck:Hide()
			warnConflagrateSoon:Cancel()
			timerConflagrateCD:Cancel()
			warnNextAdd:Show(L.NamesAdds["Telonicus"])
			timerNextAdd:Start(8.4, L.NamesAdds["Telonicus"])
			warnBombSoon:Schedule(13)
			timerBombCD:Start(18)
		elseif msg == L.YellPhase2 then
			self.vb.phase = 2
			warnBombSoon:Cancel()
			timerBombCD:Cancel()
			warnPhase:Show(L.WarnPhase2)
			timerPhase3:Start()
		elseif msg == L.YellPhase3  then
			self.vb.phase = 3
			warnPhase:Show(L.WarnPhase3)
			timerPhase4:Start()
			timerRoarCD:Start()
			warnBombSoon:Schedule(10)
			timerBombCD:Start(15)
			DBM.RangeCheck:Show(10)
		elseif msg == L.YellPhase4  then
			self.vb.phase = 4
			if self.Options.RemoveShadowResistanceBuffs then
				mod:ScheduleMethod(0.1, "RemoveBuffs")
			end
			warnPhase:Show(L.WarnPhase4)
			timerPhase4:Cancel()
			timerRoarCD:Cancel()
			warnBombSoon:Cancel()
			timerBombCD:Cancel()
			warnConflagrateSoon:Cancel()
			timerConflagrateCD:Cancel()
			timerMCCD:Start(40)
			timerBarrierCD:Start(60)
			timerPhoenixCD:Start(50)
			warnBarrierSoon:Schedule(55)
			warnPhoenixSoon:Schedule(45)
			warnMCSoon:Schedule(35)
		elseif msg == L.YellPhase5  then
			self.vb.phase = 5
			warnPhase:Show(L.WarnPhase5)
			timerMCCD:Cancel()
			warnMCSoon:Cancel()
			timerGravityCD:Start()
			warnGravitySoon:Schedule(85)

		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(36797) then
		if args:IsPlayer() and self.Options.RemoveWeaponOnMindControl then
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
		dominateMindTargets[#dominateMindTargets + 1] = args.destName
		if self.Options.SetIconOnDominateMind then
			self:SetIcon(args.destName, dominateMindIcon, 12)
			dominateMindIcon = dominateMindIcon - 1
		end
--		self:Unschedule(showDominateMindWarning)
--		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("normal25") or (mod:IsDifficulty("heroic25") and #dominateMindTargets >= 3) then
--			showDominateMindWarning()
--		else
--			self:Schedule(0.9, showDominateMindWarning)
--		end

	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 40636 then
		timerRoarCD:Start()
	elseif spellId == 37036 then
		warnBombSoon:Schedule(20)
		timerBombCD:Start()
	elseif spellId == 35941 then
	    if mod:IsDifficulty("heroic25") then
			timerGravityH:Start()
			timerGravityHCD:Start()
			else
			timerGravity:Start()
			timerGravityCD:Start()
		    warnGravitySoon:Schedule(85)
		end
    elseif spellId == 308742 then --освящение тенью
	    timerShadowCD:Start()
		warnShadow:Schedule(0)
    elseif spellId == 308790 then --катаклизм
	    timerCataCD:Start()
		timerCataCast:Start()
	    specWarnCata:Show()
		DBM.RangeCheck:Show(40, GetRaidTargetIndex)
		self:ScheduleMethod(10, "Timer")
	end
end

function mod:Timer()
	DBM.RangeCheck:Hide()
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 37018 then
		warnConflagrate:Show(args.destName)
		warnConflagrateSoon:Cancel()
		warnConflagrateSoon:Schedule(16)
		timerConflagrateCD:Start()
	elseif spellId == 36723 then
		timerPhoenixCD:Start()
		warnPhoenixSoon:Schedule(55)
	elseif spellId == 36815 then
		timerBarrierCD:Start()
		warnBarrierSoon:Schedule(65)
	elseif spellId == 36731 then
		timerFlameStrike:Start()
	elseif spellId == 308797 then --ВЗРЫВ ТЬМЫ
		if args:IsPlayer() then
			specWarnVzriv:Show()
			yellVzriv:Yell()
		end
		timerVzrivCast:Start()
		timerVzrivCD:Start()
		warnVzriv:Show(args.destName)
		if self.Options.VzrivIcon then
			self:SetIcon(args.destName, 8, 10)
		end
		if mod.Options.AnnounceVzriv then
			if DBM:GetRaidRank() > 0 then
				SendChatMessage(L.Vzriv:format(VzrivIcon, args.destName), "RAID_WARNING")
			else
				SendChatMessage(L.Vzriv:format(VzrivIcon, args.destName), "RAID")
			end
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 36797 then
		timerMCCD:Start()
		warnMCSoon:Schedule(65)
		mincControl[#mincControl + 1] = args.destName
		if #mincControl >= 3 then
			warnMC:Show(table.concat(mincControl, "<, >"))
			if self.Options.SetIconOnMC then
				table.sort(mincControl, function(v1,v2) return DBM:GetRaidSubgroup(v1) < DBM:GetRaidSubgroup(v2) end)
				local MCIcons = 8
				for i, v in ipairs(mincControl) do
					self:SetIcon(v, MCIcons)
					MCIcons = MCIcons - 1
				end
			end
			table.wipe(mincControl)
		end
	elseif spellId == 308732 then --хм яростный удар
		warnFurious:Show(args.destName, args.amount or 1)
		timerFurious:Start(args.destName)
		timerFuriousCD:Start()
	elseif spellId == 308741 then --хм Правосудие тенью
		timerJusticeCD:Start()
        warnJustice:Show(args.destName, args.amount or 1)
		timerJustice:Start(args.destName)
	elseif spellId == 308749 then --бомба
		timerBombhmCD:Start()
		warnBombhm:Show(table.concat(BombhmTargets, "<, >"))
	elseif spellId == 308756 then --хм искрящий удар
		warnIsc:Show(args.destName, args.amount or 1)
		timerIsc:Start(args.destName)
	end
end




function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 36797 then
		self:SetIcon(args.destName, 0)
	elseif spellId == 308797 then
		self:SetIcon(args.destName, 0)
	elseif spellId == 34480 or spellId == 308969 or spellId == 308970 then --падение
		timerGravity:Stop()
		timerGravityH:Stop()
	end
end

function mod:UNIT_TARGET()
	if axe then
		self:AxeIcon()
	end
end

function mod:RemoveBuffs()
	CancelUnitBuff("player", (GetSpellInfo(48469)))		-- Mark of the Wild
	CancelUnitBuff("player", (GetSpellInfo(48470)))		-- Gift of the Wild
	CancelUnitBuff("player", (GetSpellInfo(48169)))		-- Shadow Protection
	CancelUnitBuff("player", (GetSpellInfo(48170)))		-- Prayer of Shadow Protection
end

--[[function mod:KelIcon()
	if DBM:GetRaidRank() >= 1 then
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid"..i.."target") == L.Kel then
				Kel = false
				SetRaidTarget("raid"..i.."target", 5)
				break
			end
		end
	end
end ]]

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED