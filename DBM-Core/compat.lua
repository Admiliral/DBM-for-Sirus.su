if not C_Timer then
	C_Timer = {}

	local TickerPrototype = {}
	local TickerMetatable = {
		__index = TickerPrototype,
		__metatable = true
	}

	local waitTable = {}
	local waitFrame = CreateFrame("Frame", "TimerFrame", UIParent)
	waitFrame:SetScript("OnUpdate", function (self, elapse)
		local count = #waitTable
		local i = 1
		while(i <= count) do
			local waitRecord = tremove(waitTable, i)
			local d = tremove(waitRecord, 1)
			local t = tremove(waitRecord, 1)
			if t._cancelled then
				count = count - 1
				return
			end
			if(d > elapse) then
				tinsert(waitTable, i, {d - elapse, t})
				i = i + 1
			else
				count = count - 1
				t._callback()
			end
		end
	end)

	function C_Timer:NewTicker(duration, callback, iterations)
		local ticker = setmetatable({}, TickerMetatable)
		ticker._remainingIterations = iterations
		ticker._duration = duration
		ticker._callback = function()
			callback(ticker)
			if ( ticker._remainingIterations ) then
				ticker._remainingIterations = ticker._remainingIterations - 1
			end
			if ( not ticker._remainingIterations or ticker._remainingIterations > 0 ) then
				AddDelayedCall(ticker._duration, ticker)
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

	function AddDelayedCall(delay, func)
		tinsert(waitTable,{delay,func})
	end
end