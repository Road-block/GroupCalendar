local MCDateLib_cVersion = 3

if not MCDateLib or MCDateLib.Version < MCDateLib_cVersion then
	if not MCDateLib then
		MCDateLib =
		{
			cDaysInMonth = {31, 28, 31, 30,  31,  30,  31,  31,  30,  31,  30,  31},
			cDaysToMonth = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365},
			cMinutesPerDay = 1440,
			cSecondsPerDay = 86400,
			ServerTimeZoneOffset = 0, -- Offset which, when added to the server time yields the local time
		}
	end
	
	MCDateLib.Version = MCDateLib_cVersion
	
	----------------------------------------
	-- Server date/time functions
	----------------------------------------

	function MCDateLib:GetServerTime()
		return self:ConvertHMToTime(GetGameTime())
	end

	function MCDateLib:GetServerDateTime()
		return self:GetServerDateTimeFromLocalDateTime(self:GetLocalDateTime())
	end

	function MCDateLib:GetServerDateTime60()
		return self:GetServerDateTime60FromLocalDateTime60(self:GetLocalDateTime60())
	end

	function MCDateLib:GetServerDateTimeStamp()
		local vDate, vTime = self:GetServerDateTime()
		
		return vDate * self.cSecondsPerDay + vTime * 60
	end

	----------------------------------------
	-- local date/time functions
	----------------------------------------

	function MCDateLib:GetLocalTime()
		local vDate = date("*t")
		
		return self:ConvertHMToTime(vDate.hour, vDate.min)
	end

	function MCDateLib:GetLocalDate()
		local vDate = date("*t")
		
		return self:ConvertMDYToDate(vDate.month, vDate.day, vDate.year)
	end

	function MCDateLib:GetLocalDateTime()
		local vDate = date("*t")
		
		return self:ConvertMDYToDate(vDate.month, vDate.day, vDate.year), self:ConvertHMToTime(vDate.hour, vDate.min)
	end

	function MCDateLib:GetLocalYMDHMS()
		local vDate = date("*t")
		
		return vDate.year, vDate.month, vDate.day, vDate.hour, vDate.min, vDate.sec
	end
	
	function MCDateLib:GetLocalDateTime60()
		local vDate = date("*t")
		
		return self:ConvertMDYToDate(vDate.month, vDate.day, vDate.year), self:ConvertHMSToTime60(vDate.hour, vDate.min, vDate.sec)
	end

	function MCDateLib:GetLocalDateTimeStamp()
		local vDate, vTime60 = self:GetLocalDateTime60()
		
		return vDate * self.cSecondsPerDay + vTime60
	end
	
	----------------------------------------
	-- UTC date/time functions
	----------------------------------------

	function MCDateLib:GetUTCTime()
		local vDate = date("!*t")
		
		return self:ConvertHMToTime(vDate.hour, vDate.min)
	end
	
	function MCDateLib:GetUTCDateTime()
		local vDate = date("!*t")
		
		return self:ConvertMDYToDate(vDate.month, vDate.day, vDate.year), self:ConvertHMToTime(vDate.hour, vDate.min)
	end

	function MCDateLib:GetUTCDateTime60()
		local vDate = date("!*t")
		
		return self:ConvertMDYToDate(vDate.month, vDate.day, vDate.year), self:ConvertHMSToTime60(vDate.hour, vDate.min, vDate.sec)
	end

	function MCDateLib:GetUTCDateTimeStamp()
		local vDate, vTime60 = self:GetUTCDateTime60()
		
		return vDate * self.cSecondsPerDay + vTime60
	end

	----------------------------------------
	-- Time zone conversions
	----------------------------------------
	
	function MCDateLib:GetLocalTimeFromServerTime(pServerTime)
		if not pServerTime then
			return nil
		end
		
		local vLocalTime = pServerTime + MCDateLib.ServerTimeZoneOffset

		if vLocalTime < 0 then
			vLocalTime = vLocalTime + self.cMinutesPerDay
		elseif vLocalTime >= self.cMinutesPerDay then
			vLocalTime = vLocalTime - self.cMinutesPerDay
		end
		
		return vLocalTime
	end

	function MCDateLib:GetServerTimeFromLocalTime(pLocalTime)
		local vServerTime = pLocalTime - MCDateLib.ServerTimeZoneOffset

		if vServerTime < 0 then
			vServerTime = vServerTime + self.cMinutesPerDay
		elseif vServerTime >= self.cMinutesPerDay then
			vServerTime = vServerTime - self.cMinutesPerDay
		end
		
		return vServerTime
	end

	function MCDateLib:GetLocalDateTimeFromServerDateTime(pServerDate, pServerTime)
		if not pServerTime then
			return pServerDate, nil
		end
		
		local vLocalTime = pServerTime + MCDateLib.ServerTimeZoneOffset
		local vLocalDate = pServerDate
		
		if vLocalTime < 0 then
			vLocalTime = vLocalTime + self.cMinutesPerDay
			vLocalDate = vLocalDate - 1
		elseif vLocalTime >= self.cMinutesPerDay then
			vLocalTime = vLocalTime - self.cMinutesPerDay
			vLocalDate = vLocalDate + 1
		end
		
		return vLocalDate, vLocalTime
	end

	function MCDateLib:GetServerDateTimeFromLocalDateTime(pLocalDate, pLocalTime)
		if not pLocalTime then
			return pLocalDate, nil
		end
		
		local vServerTime = pLocalTime - MCDateLib.ServerTimeZoneOffset
		local vServerDate = pLocalDate
		
		if vServerTime < 0 then
			vServerTime = vServerTime + self.cMinutesPerDay
			vServerDate = vServerDate - 1
		elseif vServerTime >= self.cMinutesPerDay then
			vServerTime = vServerTime - self.cMinutesPerDay
			vServerDate = vServerDate + 1
		end
		
		return vServerDate, vServerTime
	end

	function MCDateLib:GetServerDateTime60FromLocalDateTime60(pLocalDate, pLocalTime60)
		if not pLocalTime60 then
			return pLocalDate, nil
		end
		
		local vServerTime60 = pLocalTime60 - MCDateLib.ServerTimeZoneOffset * 60
		local vServerDate = pLocalDate
		
		if vServerTime60 < 0 then
			vServerTime60 = vServerTime60 + self.cSecondsPerDay
			vServerDate = vServerDate - 1
		elseif vServerTime60 >= self.cSecondsPerDay then
			vServerTime60 = vServerTime60 - self.cSecondsPerDay
			vServerDate = vServerDate + 1
		end
		
		return vServerDate, vServerTime60
	end

	function MCDateLib:AddOffsetToDateTime(pDate, pTime, pOffset)
		local vDateTime = pDate * self.cMinutesPerDay + pTime + pOffset
		
		return math.floor(vDateTime / self.cMinutesPerDay), math.mod(vDateTime, self.cMinutesPerDay)
	end

	function MCDateLib:AddOffsetToDateTime60(pDate, pTime60, pOffset60)
		local vDateTime60 = pDate *  self.cSecondsPerDay + pTime60 + pOffset60
		
		return math.floor(vDateTime60 / self.cSecondsPerDay), math.mod(vDateTime60, self.cSecondsPerDay)
	end

	function MCDateLib:GetServerDateTimeFromSecondsOffset(pSeconds)
		-- Calculate the local date and time of the reset (this is done in
		-- local date/time since it has a higher resolution)

		local vLocalDate, vLocalTime60 = MCDateLib:GetLocalDateTime60()
		
		vLocalDate, vLocalTime60 = MCDateLib:AddOffsetToDateTime60(vLocalDate, vLocalTime60, pSeconds)
		
		local vLocalTime = math.floor(vLocalTime60 / 60)

		-- Convert to server date/time

		return MCDateLib:GetServerDateTimeFromLocalDateTime(vLocalDate, vLocalTime)
	end

	----------------------------------------
	----------------------------------------
	
	function MCDateLib:GetDateTimeFromTimeStamp(pTimeStamp)
		return math.floor(pTimeStamp / self.cSecondsPerDay), math.floor(math.mod(pTimeStamp, self.cSecondsPerDay) / 60)
	end

	function MCDateLib:GetShortTimeString(pTime)
		if pTime == nil then
			return nil
		end
		
		if TwentyFourHourTime then
			local vHour, vMinute = self:ConvertTimeToHM(pTime)
			
			return format(TEXT(TIME_TWENTYFOURHOURS), vHour, vMinute)
		else
			local vHour, vMinute, vAMPM = self:ConvertTimeToHMAMPM(pTime)
			
			if vAMPM == 0 then
				return format(TEXT(TIME_TWELVEHOURAM), vHour, vMinute)
			else
				return format(TEXT(TIME_TWELVEHOURPM), vHour, vMinute)
			end
		end
	end

	function MCDateLib:ConvertTimeToHM(pTime)
		local vMinute = math.mod(pTime, 60)
		local vHour = (pTime - vMinute) / 60
		
		return vHour, vMinute
	end

	function MCDateLib:ConvertHMToTime(pHour, pMinute)
		return pHour * 60 + pMinute
	end

	function MCDateLib:ConvertHMSToTime60(pHour, pMinute, pSecond)
		return pHour * 3600 + pMinute * 60 + pSecond
	end

	function MCDateLib:ConvertTimeToHMAMPM(pTime)
		local vHour, vMinute = self:ConvertTimeToHM(pTime)
		local vAMPM
		
		if vHour < 12 then
			vAMPM = 0
			
			if vHour == 0 then
				vHour = 12
			end
		else
			vAMPM = 1

			if vHour > 12 then
				vHour = vHour - 12
			end
		end

		return vHour, vMinute, vAMPM
	end

	function MCDateLib:ConvertHMAMPMToTime(pHour, pMinute, pAMPM)
		local vHour
		
		if pAMPM == 0 then
			vHour = pHour
			if vHour == 12 then
				vHour = 0
			end
		else
			vHour = pHour + 12
			if vHour == 24 then
				vHour = 12
			end
		end
		
		return self:ConvertHMToTime(vHour, pMinute)
	end

	----------------------------------------
	-- Date/time string conversion
	----------------------------------------
	
	function MCDateLib:GetLongDateString(pDate, pIncludeDayOfWeek)
		local vFormat
		
		if pIncludeDayOfWeek then
			vFormat = MCDateLib.cLongDateFormatWithDayOfWeek
		else
			vFormat = MCDateLib.cLongDateFormat
		end
		
		return self:GetFormattedDateString(pDate, vFormat)
	end

	function MCDateLib:GetShortDateString(pDate, pIncludeDayOfWeek)
		return self:GetFormattedDateString(pDate, MCDateLib.cShortDateFormat)
	end

	function MCDateLib:FormatNamed(pFormat, pFields)
		return string.gsub(
						pFormat,
						"%$(%w+)", 
						function (pField)
							return pFields[pField]
						end)
	end

	function MCDateLib:GetFormattedDateString(pDate, pFormat)
		local vMonth, vDay, vYear = self:ConvertDateToMDY(pDate)
		
		local vDate =
				{
					dow = MCDateLib.cDayOfWeekNames[self:GetDayOfWeekFromDate(pDate) + 1],
					month = MCDateLib.cMonthNames[vMonth],
					monthNum = vMonth,
					day = vDay,
					year = vYear,
				}
		
		return self:FormatNamed(pFormat, vDate)
	end

	----------------------------------------
	-- Time zone estimation
	----------------------------------------
	
	function MCDateLib:CalculateTimeZoneOffset()
		local vServerTime = self:ConvertHMToTime(GetGameTime())
		local vLocalDate, vLocalTime = self:GetLocalDateTime()
		local vUTCDate, vUTCTime = self:GetUTCDateTime()
		
		local vLocalDateTime = vLocalDate * 1440 + vLocalTime
		local vUTCDateTime = vUTCDate * 1440 + vUTCTime
		
		local vLocalUTCDelta = self:RoundTimeOffsetToNearest30(vLocalDateTime - vUTCDateTime)
		local vLocalServerDelta = self:RoundTimeOffsetToNearest30(vLocalTime - vServerTime)
		local vServerUTCDelta = vLocalUTCDelta - vLocalServerDelta
		
		if vServerUTCDelta < (-12 * 60) then
			vServerUTCDelta = vServerUTCDelta + (24 * 60)
		elseif vServerUTCDelta > (12 * 60) then
			vServerUTCDelta = vServerUTCDelta - (24 * 60)
		end
		
		local vServerTimeZoneOffset = vLocalUTCDelta - vServerUTCDelta
		
		if vServerTimeZoneOffset ~= self.ServerTimeZoneOffset then
			self.ServerTimeZoneOffset = vServerTimeZoneOffset
			MCEventLib:DispatchEvent("SERVER_TIME_OFFSET_CHANGED")
		end
	end
	
	function MCDateLib:RoundTimeOffsetToNearest30(pOffset)
		local vNegativeOffset
		local vOffset
		
		if pOffset < 0 then
			vNegativeOffset = true
			vOffset = -pOffset
		else
			vNegativeOffset = false
			vOffset = pOffset
		end
		
		vOffset = vOffset - (math.mod(vOffset + 15, 30) - 15)
		
		if vNegativeOffset then
			return -vOffset
		else
			return vOffset
		end
	end

	----------------------------------------
	-- Date properties
	----------------------------------------
	
	function MCDateLib:GetDaysInMonth(pMonth, pYear)
		if pMonth == 2 and self:IsLeapYear(pYear) then
			return self.cDaysInMonth[pMonth] + 1
		else
			return self.cDaysInMonth[pMonth]
		end
	end

	function MCDateLib:GetDaysToMonth(pMonth, pYear)
		if pMonth > 2 and self:IsLeapYear(pYear) then
			return self.cDaysToMonth[pMonth] + 1
		elseif pMonth == 2 then
			return self.cDaysToMonth[pMonth]
		else
			return 0
		end
	end

	function MCDateLib:GetDaysInYear(pYear)
		if self:IsLeapYear(pYear) then
			return 366
		else
			return 365
		end
	end

	function MCDateLib:IsLeapYear(pYear)
		return (math.mod(pYear, 400) == 0)
		   or ((math.mod(pYear, 4) == 0) and (math.mod(pYear, 100) ~= 0))
	end

	function MCDateLib:GetDaysToDate(pMonth, pDay, pYear)
		local vDays
		
		vDays = self.cDaysToMonth[pMonth] + pDay - 1
		
		if self:IsLeapYear(pYear) and pMonth > 2 then
			vDays = vDays + 1
		end
		
		return vDays
	end

	function MCDateLib:ConvertMDYToDate(pMonth, pDay, pYear)
		local vDays = 0
		
		for vYear = 2000, pYear - 1 do
			vDays = vDays + self:GetDaysInYear(vYear)
		end
		
		return vDays + self:GetDaysToDate(pMonth, pDay, pYear)
	end

	function MCDateLib:ConvertDateToMDY(pDate)
		local vDays = pDate
		local vYear = 2000
		local vDaysInYear = self:GetDaysInYear(vYear)
		
		while vDays >= vDaysInYear do
			vDays = vDays - vDaysInYear

			vYear = vYear + 1
			vDaysInYear = self:GetDaysInYear(vYear)
		end
		
		local vIsLeapYear = self:IsLeapYear(vYear)
		
		for vMonth = 1, 12 do
			local vDaysInMonth = self.cDaysInMonth[vMonth]
			
			if vMonth == 2 and vIsLeapYear then
				vDaysInMonth = vDaysInMonth + 1
			end
			
			if vDays < vDaysInMonth then
				return vMonth, vDays + 1, vYear
			end
			
			vDays = vDays - vDaysInMonth
		end
		
		return 0, 0, 0
	end

	function MCDateLib:GetDayOfWeek(pMonth, pDay, pYear)
		local vDayOfWeek = 6 -- January 1, 2000 is a Saturday
		
		for vYear = 2000, pYear - 1 do
			if self:IsLeapYear(vYear) then
				vDayOfWeek = vDayOfWeek + 2
			else
				vDayOfWeek = vDayOfWeek + 1
			end
		end
		
		vDayOfWeek = vDayOfWeek + self:GetDaysToDate(pMonth, pDay, pYear)
		
		return math.mod(vDayOfWeek, 7)
	end

	function MCDateLib:GetDayOfWeekFromDate(pDate)
		return math.mod(pDate + 6, 7);  -- + 6 because January 1, 2000 is a Saturday
	end
end
