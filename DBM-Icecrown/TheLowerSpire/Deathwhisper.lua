local mod	= DBM:NewMod("Deathwhisper", "DBM-Icecrown", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200405141240")
mod:SetCreatureID(36855)
mod:SetUsedIcons(4, 5, 6, 7, 8)
mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_START",
	"SPELL_INTERRUPT",
	"SPELL_SUMMON",
	"SWING_DAMAGE",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_TARGET"
)

local warnAddsSoon					= mod:NewAnnounce("WarnAddsSoon", 2)
local warnDominateMind				= mod:NewTargetAnnounce(71289, 3)
local warnDeathDecay				= mod:NewSpellAnnounce(72108, 2)
local warnSummonSpirit				= mod:NewSpellAnnounce(71426, 2)
local warnReanimating				= mod:NewAnnounce("WarnReanimating", 3)
local warnDarkTransformation		= mod:NewSpellAnnounce(70900, 4)
local warnDarkEmpowerment			= mod:NewSpellAnnounce(70901, 4)
local warnPhase2					= mod:NewPhaseAnnounce(2, 1)
local warnTouchInsignificance		= mod:NewStackAnnounce(71204, 2, nil, "Tank|Healer")
local warnDarkMartyrdom				= mod:NewSpellAnnounce(72499, 4)
local warnSound						= mod:NewSoundAnnounce()

local specWarnCurseTorpor			= mod:NewSpecialWarningYou(71237, nil, nil, nil, 1, 2)
local specWarnDeathDecay			= mod:NewSpecialWarningMove(72108, nil, nil, nil, 1, 2)
local specWarnTouchInsignificance	= mod:NewSpecialWarningStack(71204, nil, 3, nil, nil, 1, 6)
local specWarnVampricMight			= mod:NewSpecialWarningDispel(70674, "MagicDispeller", nil, nil, 1, 2)
local specWarnDarkMartyrdom			= mod:NewSpecialWarningRun(72499, "Melee", nil, nil, 4, 2)
local specWarnFrostbolt				= mod:NewSpecialWarningInterrupt(72007, nil, nil, 2, 1, 2) -- TODO: HasInterrupt
local specWarnVengefulShade			= mod:NewSpecialWarning("SpecWarnVengefulShade", "-Tank")

local timerAdds						= mod:NewTimer(60, "TimerAdds", 61131, nil, nil, 1, DBM_CORE_TANK_ICON..DBM_CORE_DAMAGE_ICON)
local timerDominateMind				= mod:NewBuffActiveTimer(12, 71289)
local timerDominateMindCD			= mod:NewCDTimer(40, 71289, nil, nil, nil, 3)
local timerSummonSpiritCD			= mod:NewCDTimer(10, 71426, nil, false)
local timerFrostboltCast			= mod:NewCastTimer(4, 72007)
local timerTouchInsignificance		= mod:NewTargetTimer(30, 71204, nil, "Tank|Healer", nil, 5)

local berserkTimer					= mod:NewBerserkTimer(600)

mod:AddSetIconOption("SetIconOnDominateMind", 71289, true, true, {6})
mod:AddSetIconOption("SetIconOnDeformedFanatic", 70900, true, true, {5, 6, 7, 8})
mod:AddSetIconOption("SetIconOnEmpoweredAdherent", 70901, true, true, {5, 6, 7, 8})
mod:AddBoolOption("ShieldHealthFrame", true, "misc")
mod:AddBoolOption("RemoveWeaponOnMindControl", true)
mod:AddBoolOption("RemoveShadowResistanceBuffs", true)
mod:RemoveOption("HealthFrame")


local lastDD	= 0
local dominateMindTargets	= {}
local dominateMindIcon 	= 6
local deformedFanatic
local empoweredAdherent

function mod:RemoveBuffs()
	CancelUnitBuff("player", (GetSpellInfo(48469)))		-- Mark of the Wild
	CancelUnitBuff("player", (GetSpellInfo(48470)))		-- Gift of the Wild
	CancelUnitBuff("player", (GetSpellInfo(48169)))		-- Shadow Protection
	CancelUnitBuff("player", (GetSpellInfo(48170)))		-- Prayer of Shadow Protection
end

local function showDominateMindWarning()
	warnDominateMind:Show(table.concat(dominateMindTargets, "<, >"))
	timerDominateMind:Start()
	timerDominateMindCD:Start()
	table.wipe(dominateMindTargets)
	dominateMindIcon = 6
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 36855, "Lady Deathwhisper")
	if self.Options.ShieldHealthFrame then
		DBM.BossHealth:Show(L.name)
		DBM.BossHealth:AddBoss(36855, L.name)
		self:ScheduleMethod(0.5, "CreateShildHPFrame")
	end
	if self.Options.RemoveShadowResistanceBuffs then
		mod:ScheduleMethod(0.1, "RemoveBuffs")
	end
	berserkTimer:Start(-delay)
	timerAdds:Start(6)
	warnAddsSoon:Schedule(4)			-- 3sec pre-warning on start
	self:ScheduleMethod(6, "addsTimer")
	if not mod:IsDifficulty("normal10") then
		timerDominateMindCD:Start(30)		-- Sometimes 1 fails at the start, then the next will be applied 70 secs after start ?? :S
	end
	table.wipe(dominateMindTargets)
	dominateMindIcon = 6
	deformedFanatic = nil
	empoweredAdherent = nil
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 36855, "Lady Deathwhisper", wipe)
	DBM.BossHealth:Clear()
end

do	-- add the additional Shield Bar
	local last = 100
	local function getShieldPercent()
		local guid = UnitGUID("focus")
		if mod:GetCIDFromGUID(guid) == 36855 then
			last = math.floor(UnitMana("focus")/UnitManaMax("focus") * 100)
			return last
		end
		for i = 0, GetNumRaidMembers(), 1 do
			local unitId = ((i == 0) and "target") or "raid"..i.."target"
			guid = UnitGUID(unitId)
			if mod:GetCIDFromGUID(guid) == 36855 then
				last = math.floor(UnitMana(unitId)/UnitManaMax(unitId) * 100)
				return last
			end
		end
		return last
	end
	function mod:CreateShildHPFrame()
		DBM.BossHealth:AddBoss(getShieldPercent, L.ShieldPercent)
	end
end

function mod:addsTimer()
	timerAdds:Cancel()
	warnAddsSoon:Cancel()
	if mod:IsDifficulty("heroic10", "heroic25") then
		warnAddsSoon:Schedule(40)	-- 5 secs prewarning
		self:ScheduleMethod(45, "addsTimer")
		timerAdds:Start(45)
	else
		warnAddsSoon:Schedule(55)	-- 5 secs prewarning
		self:ScheduleMethod(60, "addsTimer")
		timerAdds:Start()
	end
end

function mod:TrySetTarget()
	if DBM:GetRaidRank() >= 1 then
		for i = 1, GetNumRaidMembers() do
			if UnitGUID("raid"..i.."target") == deformedFanatic then
				deformedFanatic = nil
				SetRaidTarget("raid"..i.."target", 8)
			elseif UnitGUID("raid"..i.."target") == empoweredAdherent then
				empoweredAdherent = nil
				SetRaidTarget("raid"..i.."target", 7)
			end
			if not (deformedFanatic or empoweredAdherent) then
				break
			end
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	--[[if args:IsSpellID(71289) then
		dominateMindTargets[#dominateMindTargets + 1] = args.destName
		if self.Options.SetIconOnDominateMind then
			self:SetIcon(args.destName, dominateMindIcon, 12)
			dominateMindIcon = dominateMindIcon - 1
		end
		self:Unschedule(showDominateMindWarning)
		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("normal25") or (mod:IsDifficulty("heroic25") and #dominateMindTargets >= 3) then
			showDominateMindWarning()
		else
			self:Schedule(0.9, showDominateMindWarning)
		end
	else]]
	if args:IsSpellID(71001, 72108, 72109, 72110) then
		if args:IsPlayer() then
			specWarnDeathDecay:Show()
			specWarnDeathDecay:Play("runaway")
		end
		if (GetTime() - lastDD > 5) then
			warnDeathDecay:Show()
			lastDD = GetTime()
		end
	elseif args:IsSpellID(71237) and args:IsPlayer() then
		specWarnCurseTorpor:Show()
		specWarnCurseTorpor:Play("targetyou")
	elseif args:IsSpellID(70674) and not args:IsDestTypePlayer() and (UnitName("target") == L.Fanatic1 or UnitName("target") == L.Fanatic2 or UnitName("target") == L.Fanatic3) then
		specWarnVampricMight:Show(args.destName)
		specWarnVampricMight:Play("helpdispel")
	elseif args:IsSpellID(71204) then
		warnTouchInsignificance:Show(args.destName, args.amount or 1)
		timerTouchInsignificance:Start(args.destName)
		if args:IsPlayer() and (args.amount or 1) >= 3 and (mod:IsDifficulty("normal10") or mod:IsDifficulty("normal25")) then
			specWarnTouchInsignificance:Show(args.amount)
			specWarnTouchInsignificance:Play("stackhigh")
		elseif args:IsPlayer() and (args.amount or 1) >= 5 and (mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25")) then
			specWarnTouchInsignificance:Show(args.amount)
			specWarnTouchInsignificance:Play("stackhigh")
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED


function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(71289) then
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
		self:Unschedule(showDominateMindWarning)
		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("normal25") or (mod:IsDifficulty("heroic25") and #dominateMindTargets >= 3) then
			showDominateMindWarning()
		else
			self:Schedule(0.9, showDominateMindWarning)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(70842) then
		warnPhase2:Show()
		timerAdds:Cancel()
		warnAddsSoon:Cancel()
		self:UnscheduleMethod("addsTimer")
		if mod:IsDifficulty("heroic10", "heroic25") then self:addsTimer() end
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(71420, 72007, 72501, 72502) then
		specWarnFrostbolt:Show(args.sourceName)
		specWarnFrostbolt:Play("kickcast")
		timerFrostboltCast:Start()
	elseif args:IsSpellID(70900) then
		warnDarkTransformation:Show()
		if self.Options.SetIconOnDeformedFanatic then
			deformedFanatic = args.sourceGUID
			self:TrySetTarget()
		end
	elseif args:IsSpellID(70901) then
		warnDarkEmpowerment:Show()
		if self.Options.SetIconOnEmpoweredAdherent then
			empoweredAdherent = args.sourceGUID
			self:TrySetTarget()
		end
	elseif args:IsSpellID(72499, 72500, 72497, 72496) then
		warnDarkMartyrdom:Show()
		specWarnDarkMartyrdom:Show()
		specWarnDarkMartyrdom:Play("justrun")
	end
end

function mod:SPELL_INTERRUPT(args)
	if type(args.extraSpellId) == "number" and (args.extraSpellId == 71420 or args.extraSpellId == 72007 or args.extraSpellId == 72501 or args.extraSpellId == 72502) then
		timerFrostboltCast:Cancel()
	end
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(71426) and self:AntiSpam(5, 1) then -- Summon Vengeful Shade
		warnSummonSpirit:Show()
		timerSummonSpiritCD:Start()
	end
end

function mod:SWING_DAMAGE(args)
	if args:IsPlayer() and args:GetSrcCreatureID() == 38222 then
		specWarnVengefulShade:Show()
	end
end

function mod:UNIT_TARGET()
	if empoweredAdherent or deformedFanatic then
		self:TrySetTarget()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellReanimatedFanatic or msg:find(L.YellReanimatedFanatic) then
		warnReanimating:Show()
	end
end
