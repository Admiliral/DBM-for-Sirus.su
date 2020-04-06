local mod	= DBM:NewMod("Shirrak", "DBM-Party-BC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2250 $"):sub(12, -3))
mod:SetCreatureID(18371)
mod:SetZone()

mod:RegisterCombat("combat", 18371)

mod:RegisterEvents(
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_SUCCESS"
)

local timerSuppressionCD		= mod:NewCDTimer(3.3, 32264)
local timerBiteCD		        = mod:NewCDTimer(10, 39382)
local timerFireCD		        = mod:NewCDTimer(15, 42075)
local timerAttractionCD	        = mod:NewCDTimer(30, 32265)
local specWarnFire          	= mod:NewSpecialWarningYou(42075)
local targetName

function mod:OnCombatStart(delay)
	timerSuppressionCD:Start()
	timerBiteCD:Start()
	timerAttractionCD:Start()
	timerFireCD:Start()
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(32264) then
		timerSuppressionCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(39382) then
		timerBiteCD:Start()
	elseif args:IsSpellID(32265) then
		timerAttractionCD:Start()
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, name)
	if name == L.name then
		targetName = msg:match("%w+")
		if msg:gsub(targetName, "") == L.EmoteFire then
			timerFireCD:Start()
			if targetName == UnitName("player") then
				specWarnFire:Show()
			end
		end
	end
end
