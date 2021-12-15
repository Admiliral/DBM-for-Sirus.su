if C_Timer and C_Timer._version == 2 then return end

local setmetatable = setmetatable
local type = type
local tinsert = table.insert
local tremove = table.remove

C_Timer = C_Timer or {}
C_Timer._version = 2

local TickerPrototype = {}
local TickerMetatable = {
	__index = TickerPrototype,
	__metatable = true
}

local waitTable = {}
local waitFrame = TimerFrame or CreateFrame("Frame", "TimerFrame", UIParent)
waitFrame:SetScript("OnUpdate", function(self, elapsed)
	local total = #waitTable
	local i = 1

	while i <= total do
		local ticker = waitTable[i]

		if ticker._cancelled then
			tremove(waitTable, i)
			total = total - 1
		elseif ticker._delay > elapsed then
			ticker._delay = ticker._delay - elapsed
			i = i + 1
		else
			ticker._callback(ticker)

			if ticker._remainingIterations == -1 then
				ticker._delay = ticker._duration
				i = i + 1
			elseif ticker._remainingIterations > 1 then
				ticker._remainingIterations = ticker._remainingIterations - 1
				ticker._delay = ticker._duration
				i = i + 1
			elseif ticker._remainingIterations == 1 then
				tremove(waitTable, i)
				total = total - 1
			end
		end
	end

	if #waitTable == 0 then
		self:Hide()
	end
end)

local function AddDelayedCall(ticker, oldTicker)
	if oldTicker and type(oldTicker) == "table" then
		ticker = oldTicker
	end

	tinsert(waitTable, ticker)
	waitFrame:Show()
end

_G.AddDelayedCall = AddDelayedCall

local function CreateTicker(duration, callback, iterations)
	local ticker = setmetatable({}, TickerMetatable)
	ticker._remainingIterations = iterations or -1
	ticker._duration = duration
	ticker._delay = duration
	ticker._callback = callback

	AddDelayedCall(ticker)

	return ticker
end

function C_Timer:After(duration, callback)
	return CreateTicker(duration, callback, 1)
end

function C_Timer:NewTimer(duration, callback)
	return CreateTicker(duration, callback, 1)
end

function C_Timer:NewTicker(duration, callback, iterations)
	return CreateTicker(duration, callback, iterations)
end

function TickerPrototype:Cancel()
	self._cancelled = true
end

local oldGetInstanceDifficulty = GetInstanceDifficulty
function GetInstanceDifficulty()
	local diff = oldGetInstanceDifficulty()
	if diff == 1 then
		local _, _, difficulty, _, maxPlayers = GetInstanceInfo()
		if difficulty == 1 and maxPlayers == 25 then
			diff = 2
		end
	end
	return diff
end

function IsInGroup()
	return GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0
end

function IsInRaid()
	return GetNumRaidMembers() > 0
end

function GetNumSubgroupMembers()
	return GetNumPartyMembers()
end

function GetNumGroupMembers()
	return IsInRaid() and GetNumRaidMembers() or GetNumPartyMembers()
end
