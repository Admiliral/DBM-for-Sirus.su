local mod		= DBM:NewMod("z611", "DBM-PvP", 2)
local L			= mod:GetLocalizedStrings()

mod:SetRevision("20200405141240")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA",
	"CHAT_MSG_BG_SYSTEM_NEUTRAL",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)

local poi = {}

local allyColor = {r = 0, g = 0, b = 1}
local hordeColor = {r = 1, g = 0, b = 0}

local bgzone = false
function mod:OnInitialize()
	if select(2, IsInInstance()) == "pvp" and GetCurrentMapAreaID() == 611 then
		bgzone = true
		for i = 1, GetNumMapLandmarks(), 1 do
			local name, _, textureIndex = GetMapLandmarkInfo(i)
			if name and textureIndex then
				poi[i] = textureIndex
			end
		end
	elseif bgzone then
		bgzone = false
	end
end

function mod:ZONE_CHANGED_NEW_AREA()
	self:ScheduleMethod(1, "OnInitialize")
end

local function checkForUpdates()
	if not bgzone then return end
	for k,v in pairs(poi) do
		local name, _, textureIndex = GetMapLandmarkInfo(k)
		if name and textureIndex then
			poi[k] = textureIndex
		end
	end
end

local function scheduleCheck(self)
	self:Schedule(1, checkForUpdates)
end

function mod:CHAT_MSG_BG_SYSTEM_NEUTRAL(msg)
	if not bgzone then return end
	scheduleCheck(self)
end