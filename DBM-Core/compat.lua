if C_Timer and C_Timer._version == 2 then return end

local setmetatable = setmetatable
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
waitFrame:SetScript("OnUpdate", function (self, elapsed)
	local total = #waitTable
	local i = 1

	while i <= total do
		local data = waitTable[i]

		if data[2]._cancelled then
			tremove(waitTable, i)
			total = total - 1
		elseif data[1] > elapsed then
			data[1] = data[1] - elapsed
			i = i + 1
		else
			if not data[3] or data[2]._remainingIterations == 0 then
				tremove(waitTable, i)
			end

			data[2]._callback()

			total = total - 1
		end
	end

	if #waitTable == 0 then
		self:Hide()
	end
end)

local function AddDelayedCall(delay, func)
	tinsert(waitTable, {delay, func, true})
	waitFrame:Show()
end

_G.AddDelayedCall = AddDelayedCall

function C_Timer:NewTicker(duration, callback, iterations)
	local ticker = setmetatable({}, TickerMetatable)
	ticker._remainingIterations = iterations or -1
	ticker._duration = duration
	ticker._callback = function()
		callback(ticker)

		if ticker._remainingIterations > 0 then
			ticker._remainingIterations = ticker._remainingIterations - 1
		end
	end

	AddDelayedCall(ticker._duration, ticker)

	return ticker
end

function C_Timer:After(duration, callback)
	return C_Timer:NewTicker(duration, callback, 1)
end

function TickerPrototype:Cancel()
	self._cancelled = true
end