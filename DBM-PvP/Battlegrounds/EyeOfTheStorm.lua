local mod	= DBM:NewMod("z541", "DBM-PvP", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200405141240")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA",
	"CHAT_MSG_BG_SYSTEM_HORDE",
	"CHAT_MSG_BG_SYSTEM_ALLIANCE",
	"CHAT_MSG_BG_SYSTEM_NEUTRAL",
	"UPDATE_WORLD_STATES"
)
mod:RemoveOption("HealthFrame")

local bgzone = false
local ResPerSec = {
	[0] = 0,
	[1] = 0.5,
	[2] = 1,
	[3] = 2.5,
	[4] = 5,
}

local allyColor = {r = 0, g = 0, b = 1}
local hordeColor = {r = 1, g = 0, b = 0}

mod:AddBoolOption("ShowPointFrame", true, nil, function()
	if mod.Options.ShowPointFrame and bgzone then
		mod:ShowEstimatedPoints()
	else
		mod:HideEstimatedPoints()
	end
end)

local startTimer = mod:NewTimer(60, "TimerStart")
local winTimer = mod:NewTimer(30, "TimerWin")
local flagTimer = mod:NewTimer(9, "TimerFlag", "Interface\\Icons\\INV_Banner_02")

local objectives = {
	[1] = 6,	-- Blood Elf
	[2] = 6,	-- Draenai
	[3] = 6,	-- Fel Reaver
	[4] = 6,	-- Mage
	[5] = 45	-- Flag
}

local function isFlag(id)
	return id == 45 or id == 44 or id ==43
end

local function isTower(id)
	return id == 6 or id == 10 or id == 11
end

local function getBasecount()
	local alliance = 0
	local horde = 0
	for k,v in pairs(objectives) do
		if v == 11 then
			alliance = alliance + 1
		elseif v == 10 then
			horde = horde + 1
		end
	end
	return alliance, horde
end

local function getScore()
	if not bgzone then
		return 0, 0
	end
	local allyScore	= tonumber(string.match((select(3, GetWorldStateUIInfo(2)) or ""), L.ScoreExpr)) or 0
	local hordeScore = tonumber(string.match((select(3, GetWorldStateUIInfo(3)) or ""), L.ScoreExpr)) or 0
	return allyScore, hordeScore
end


local getGametime
local updateGametime
do
	local gametime = 0
	function updateGametime()
		gametime = time()
	end
	function getGametime()
		local systime = GetBattlefieldInstanceRunTime()
		if systime > 0 then
			return systime / 1000
		else
			return time() - gametime
		end
	end
end

do
	local function initialize()
		if select(2, IsInInstance()) == "pvp" and GetRealZoneText() == L.ZoneName then
			bgzone = true
			updateGametime()
			for i = 1, GetNumMapLandmarks(), 1 do
				local name, _, textureIndex = GetMapLandmarkInfo(i)
				if name and textureIndex then
					if isTower(textureIndex) or isFlag(textureIndex) then
						objectives[i] = textureIndex
					end
				end
			end
			if mod.Options.ShowPointFrame then
				mod:ShowEstimatedPoints()
			end

		elseif bgzone then
			bgzone = false
			if mod.Options.ShowPointFrame then
				mod:HideEstimatedPoints()
			end
		end
	end
	mod.OnInitialize = initialize
	mod.ZONE_CHANGED_NEW_AREA = initialize
end

do
	local function checkForUpdates()
		if not bgzone then
			return
		end
		for i = 1, GetNumMapLandmarks() do
			local name, _, textureIndex = GetMapLandmarkInfo(i)
			if name and textureIndex then
				if isTower(textureIndex) or isFlag(textureIndex) then
					objectives[i] = textureIndex
				end
			end
		end
		mod:UPDATE_WORLD_STATES()
	end

	local function scheduleCheck(self)
		self:Schedule(1, checkForUpdates)
	end

	function mod:CHAT_MSG_BG_SYSTEM_ALLIANCE(arg1)
		if mod.Options.ShowPointFrame then
			if string.match(arg1, L.FlagTaken) then
				local name = string.match(arg1, L.FlagTaken)
				if name then
					self.AllyFlag = name
					self.HordeFlag = nil
					self:UpdateFlagDisplay()
				end

			elseif string.match(arg1, L.FlagDropped) then
				self.AllyFlag = nil
				self.HordeFlag = nil
				self:UpdateFlagDisplay()

			elseif string.match(arg1, L.FlagCaptured) then
				flagTimer:Start()
				self.AllyFlag = nil
				self.HordeFlag = nil
				self:UpdateFlagDisplay()
			end
		end
		scheduleCheck(self)
	end

	function mod:CHAT_MSG_BG_SYSTEM_HORDE(arg1)
		if mod.Options.ShowPointFrame then
			if string.match(arg1, L.FlagTaken) then
				local name = string.match(arg1, L.FlagTaken)
				if name then
					self.AllyFlag = nil
					self.HordeFlag = name
					self:UpdateFlagDisplay()
				end

			elseif string.match(arg1, L.FlagDropped) then
				self.AllyFlag = nil
				self.HordeFlag = nil
				self:UpdateFlagDisplay()

			elseif string.match(arg1, L.FlagCaptured) then
				flagTimer:Start()
				self.AllyFlag = nil
				self.HordeFlag = nil
				self:UpdateFlagDisplay()
			end
		end
		scheduleCheck(self)
	end

	function mod:CHAT_MSG_BG_SYSTEM_NEUTRAL(arg1)
		if not bgzone then
			return
		end

		if arg1 == L.BgStart60 then
			startTimer:Start()

	--[[	elseif arg1 == L.BgStart30  then
		startTimer:Update(30, 60)]]

		elseif string.match(arg1, L.FlagReset) then
			mod.AllyFlag = nil
			mod.HordeFlag = nil
			mod:UpdateFlagDisplay()
		end
		scheduleCheck(self)
	end
end

function mod:UPDATE_WORLD_STATES()
	if not bgzone then return end

	local last_alliance_bases, last_horde_bases = getBasecount()
	local last_alliance_score, last_horde_score = getScore()

	-- calculate new times
	local AllyTime = (1600 - last_alliance_score) / ResPerSec[last_alliance_bases]
	local HordeTime = (1600 - last_horde_score) / ResPerSec[last_horde_bases]

	if AllyTime > 5000 then AllyTime = 5000 end
	if HordeTime > 5000 then HordeTime = 5000 end

	if AllyTime == HordeTime then
		winTimer:Stop()
	elseif AllyTime > HordeTime then -- Horde wins
		winTimer:Update(getGametime(), getGametime()+HordeTime)
		winTimer:DisableEnlarge()
		local AllyPoints = math.floor((HordeTime * ResPerSec[last_alliance_bases]) + last_alliance_score)
		winTimer:UpdateName(L.WinBarText:format(AllyPoints, 1600))
		winTimer:SetColor(hordeColor)
	elseif HordeTime > AllyTime then -- Alliance wins
		winTimer:Update(getGametime(), getGametime() + AllyTime)
		winTimer:DisableEnlarge()
		local HordePoints = math.floor((HordeTime * ResPerSec[last_horde_bases]) + last_horde_score)
		winTimer:UpdateName(L.WinBarText:format(1600, HordePoints))
		winTimer:SetColor(allyColor)
	end
end

function mod:UpdateFlagDisplay()
	if self.ScoreFrame1Text and self.ScoreFrame2Text then

		local newText
		local oldText = self.ScoreFrame1Text:GetText()
		if self.AllyFlag then
			if not oldText or oldText == "" then
				newText = "Flag: "..self.AllyFlag
			else
				newText = string.gsub(oldText, "%((%d+)%).*", "%(%1%)  "..L.Flag..": "..self.AllyFlag)
			end
		elseif oldText and oldText ~= "" then
			newText = string.gsub(oldText, "%((%d+)%).*", "%(%1%)")
		end
		self.ScoreFrame1Text:SetText(newText)

		newText = nil
		oldText = self.ScoreFrame2Text:GetText()
		if self.HordeFlag then
			if not oldText or oldText == "" then
				newText = "Flag: "..self.HordeFlag
			else
				newText = string.gsub(oldText, "%((%d+)%).*", "%(%1%)  "..L.Flag..": "..self.HordeFlag)
			end
		elseif oldText and oldText ~= "" then
			newText = string.gsub(oldText, "%((%d+)%).*", "%(%1%)")
		end
		self.ScoreFrame2Text:SetText(newText)

	end
end

function mod:ShowEstimatedPoints()
	if AlwaysUpFrame1Text and AlwaysUpFrame2Text then
		if not self.ScoreFrame1 then
			self.ScoreFrame1 = CreateFrame("Frame", nil, AlwaysUpFrame1)
			self.ScoreFrame1:SetHeight(10)
			self.ScoreFrame1:SetWidth(200)
			self.ScoreFrame1:SetPoint("LEFT", "AlwaysUpFrame1Text", "RIGHT", 4, 0)
			self.ScoreFrame1Text = self.ScoreFrame1:CreateFontString(nil, nil, "GameFontNormalSmall")
			self.ScoreFrame1Text:SetAllPoints(self.ScoreFrame1)
			self.ScoreFrame1Text:SetJustifyH("LEFT")
		end
		if not self.ScoreFrame2 then
			self.ScoreFrame2 = CreateFrame("Frame", nil, AlwaysUpFrame2)
			self.ScoreFrame2:SetHeight(10)
			self.ScoreFrame2:SetWidth(200)
			self.ScoreFrame2:SetPoint("LEFT", "AlwaysUpFrame2Text", "RIGHT", 4, 0)
			self.ScoreFrame2Text= self.ScoreFrame2:CreateFontString(nil, nil, "GameFontNormalSmall")
			self.ScoreFrame2Text:SetAllPoints(self.ScoreFrame2)
			self.ScoreFrame2Text:SetJustifyH("LEFT")
		end
		self.ScoreFrame1Text:SetText("")
		self.ScoreFrame1:Show()
		self.ScoreFrame2Text:SetText("")
		self.ScoreFrame2:Show()
	end
end

function mod:HideEstimatedPoints()
	if self.ScoreFrame1 and self.ScoreFrame2 then
		self.ScoreFrame1:Hide()
		self.ScoreFrame1Text:SetText("")
		self.ScoreFrame2:Hide()
		self.ScoreFrame2Text:SetText("")
	end
end
