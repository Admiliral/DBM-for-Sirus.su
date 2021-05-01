local mod	= DBM:NewMod("Jaraxxus", "DBM-Coliseum")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501163300")
mod:SetCreatureID(34780)
mod:SetMinCombatTime(30)
mod:SetUsedIcons(7, 8)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_DAMAGE",
	"SPELL_MISSED",
	"CHAT_MSG_MONSTER_YELL"
)

local warnFelFireball			= mod:NewCastAnnounce(66532, 2)
local warnPortalSoon			= mod:NewSoonAnnounce(67900, 3)
local warnVolcanoSoon			= mod:NewSoonAnnounce(67901, 3)
local warnFlame					= mod:NewTargetAnnounce(68123, 4)
local warnFlesh					= mod:NewTargetAnnounce(66237, 4, nil, "Healer")

local specWarnFlame				= mod:NewSpecialWarningRun(67072, nil, nil, 2, 4, 2)
local specWarnFlameGTFO			= mod:NewSpecialWarningMove(67072, nil, nil, 2, 4, 2)
local specWarnFlesh				= mod:NewSpecialWarningYou(66237, nil, nil, nil, 1, 2)
local specWarnKiss				= mod:NewSpecialWarningCast(67907, "SpellCaster", nil, 2, 1, 2)
local specWarnNetherPower		= mod:NewSpecialWarningDispel(67009, "MagicDispeller", nil, nil, 1, 2)
local specWarnFelInferno		= mod:NewSpecialWarningMove(68718, nil, nil, nil, 1, 2)
local SpecWarnFelFireball		= mod:NewSpecialWarningInterrupt(66965, "HasInterrupt", nil, 2, 1, 2)
local SpecWarnFelFireballDispel	= mod:NewSpecialWarningDispel(66965, false, nil, 2, 1, 2)

local timerCombatStart			= mod:NewCombatTimer(90)--rollplay for first pull
local enrageTimer				= mod:NewBerserkTimer(600)
local timerFlame 				= mod:NewTargetTimer(8, 68123, nil, nil, nil, 3)--There are 8 debuff Ids. Since we detect first to warn, use an 8sec timer to cover duration of trigger spell and damage debuff.
local timerFlameCD				= mod:NewCDTimer(30, 68125, nil, nil, nil, 3)
local timerNetherPowerCD		= mod:NewCDTimer(42, 67009, nil, "MagicDispeller", nil, 5, nil, DBM_CORE_MAGIC_ICON)
local timerFlesh				= mod:NewTargetTimer(12, 67049, nil, "Healer", 2, 5, nil, DBM_CORE_HEALER_ICON)
local timerFleshCD				= mod:NewCDTimer(23, 67051, nil, "Healer", 2, 5, nil, DBM_CORE_HEALER_ICON)
local timerPortalCD				= mod:NewCDTimer(120, 67900, nil, nil, nil, 1)
local timerVolcanoCD			= mod:NewCDTimer(120, 67901, nil, nil, nil, 1)

mod:AddSetIconOption("LegionFlameIcon", 66197)
mod:AddSetIconOption("IncinerateFleshIcon", 66237)
mod:AddInfoFrameOption(66237, true)

mod.vb.fleshCount = 0

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 34780, "Lord Jaraxxus")
	self.vb.fleshCount = 0
	timerPortalCD:Start(20-delay)
	warnPortalSoon:Schedule(15-delay)
	timerVolcanoCD:Start(80-delay)
	warnVolcanoSoon:Schedule(75-delay)
	timerFleshCD:Start(14-delay)
	timerFlameCD:Start(20-delay)
	enrageTimer:Start(-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 34780, "Lord Jaraxxus", wipe)
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
		if (spellId == 66877 or spellId == 67070 or spellId == 67071 or spellId == 67072) and destGUID == UnitGUID("player") and self:AntiSpam(3, 1) then		-- Legion Flame
			specWarnFlameGTFO:Show()
			specWarnFlameGTFO:Play("runaway")
		elseif(spellId == 66496 or spellId == 68716 or spellId == 68717 or spellId == 68718) and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then	-- Fel Inferno
			specWarnFelInferno:Show()
		specWarnFelInferno:Play("runaway")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE


function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(67051, 67050, 67049, 66237) then			-- Incinerate Flesh
		self.vb.fleshCount = self.vb.fleshCount + 1
		timerFlesh:Start(args.destName)
		timerFleshCD:Start()
		if self.Options.IncinerateFleshIcon then
			self:SetIcon(args.destName, 8, 15)
		end
		if args:IsPlayer() then
			specWarnFlesh:Show()
			specWarnFlesh:Play("targetyou")
		else
			warnFlesh:Show(args.destName)
		end
		if self.Options.InfoFrame and not DBM.InfoFrame:IsShown() then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(6, "playerabsorb", args.spellName, select(16, DBM:UnitDebuff(args.destName, args.spellName)))
		end
	elseif args:IsSpellID(66197, 68123, 68124, 68125) then		-- Legion Flame ids 66199, 68126, 68127, 68128 (second debuff) do the actual damage. First 2 seconds are trigger debuff only.
		timerFlame:Start(args.destName)
		timerFlameCD:Start()
		if args:IsPlayer() then
			specWarnFlame:Show()
			specWarnFlame:Play("runout")
			specWarnFlame:SheduleVoice(1.5, "keepmove")
		end
		if self.Options.LegionFlameIcon then
			self:SetIcon(args.destName, 7, 8)
		end
	elseif args:IsSpellID(66334, 67905, 67906, 67907) and args:IsPlayer() then
		specWarnKiss:Show()
		specWarnKiss:Play("stopcast")
	elseif args:IsSpellID(66532, 66963, 66964, 66965) then		-- Fel Fireball (announce if tank gets debuff for dispel)
		warnFelFireball:Show()
		SpecWarnFelFireballDispel:Show(args.destName)
		SpecWarnFelFireballDispel:Play("helpdispel")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(67051, 67050, 67049, 66237) then			-- Incinerate Flesh
		self.vb.fleshCount = self.vb.fleshCount - 1
		if self.Options.InfoFrame and self.vb.fleshCount == 0 then
			DBM.InfoFrame:Hide()
		end
		timerFlesh:Stop(args.destName)
		if self.Options.IncinerateFleshIcon then
			self:RemoveIcon(args.destName)
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(66532, 66963, 66964, 66965)and self:CheckInterruptFilter(args.sourceGUID) then	-- Fel Fireball (track cast for interupt, only when targeted)
		SpecWarnFelFireball:Show(args.sourceName)
		SpecWarnFelFireball:Play("kickcast")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(67009) then								-- Nether Power
		specWarnNetherPower:Show(args.sourceName)
		specWarnNetherPower:Play("dispelboss")
		timerNetherPowerCD:Start()
	elseif args:IsSpellID(67901, 67902, 67903, 66258) then		-- Infernal Volcano
		timerVolcanoCD:Start()
		warnVolcanoSoon:Schedule(110)

	elseif args:IsSpellID(67900, 67899, 67898, 66269) then		-- Nether Portal
		timerPortalCD:Start()
		warnPortalSoon:Schedule(110)

	elseif args:IsSpellID(66197, 68123, 68124, 68125) then		-- Legion Flame
		warnFlame:Show(args.destName)
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.FirstPull or msg:find(L.FirstPull) then
		timerCombatStart:Start()
	end
end