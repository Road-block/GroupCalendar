GroupCalendar.Time = {}

----------------------------------------
-- Time utilities
----------------------------------------

function GroupCalendar.Time.UpdateTimeTooltip()
	local vServerTime = GroupCalendar.ConvertHMToTime(GetGameTime())
	local vLocalDate = MCDateLib:GetLocalDate()
	
	local vServerTimeString = GroupCalendar.GetShortTimeString(vServerTime)
	local vLocalDateString = GroupCalendar.GetLongDateString(vLocalDate, true)

	GameTooltip:AddLine(vLocalDateString)
	GameTooltip:AddLine(vServerTimeString)
	
	if MCDateLib.ServerTimeZoneOffset ~= 0 then
		local vLocalTime = MCDateLib:GetLocalTimeFromServerTime(vServerTime)
		local vLocalTimeString = GroupCalendar.GetShortTimeString(vLocalTime)
		
		GameTooltip:AddLine(string.format(GroupCalendar_cLocalTimeNote, vLocalTimeString))
	end
	
	local vServerDate, vServerTime2 = MCDateLib:GetServerDateTime()
	
	local vCompiledSchedule = GroupCalendar.Database.GetCompiledSchedule(
			vServerDate,
			true, -- IncludePrivateEvents
			true) -- ForceServerDate
	
	GroupCalendar.AddTooltipSchedule(GameTooltip, vCompiledSchedule)
	
	GameTooltip:Show()
end

function GroupCalendar.Time.DebugDate(pDate)
	local vDateString = GroupCalendar.GetLongDateString(pDate, true)
	
	GroupCalendar:DebugMessage(vDateString)
end

function GroupCalendar.Time.DebugTimeStamp(pTimeStamp)
	local vDate, vTime = MCDateLib:GetDateTimeFromTimeStamp(pTimeStamp)
	
	local vDateString = GroupCalendar.GetLongDateString(vDate, true)
	local vTimeString = GroupCalendar.GetShortTimeString(vTime)
	
	GroupCalendar:DebugMessage(vDateString.." "..vTimeString)
end

----------------------------------------
-- _Clock
----------------------------------------

GroupCalendar._Clock = {}

GroupCalendar._Clock.Widgets =
{
	"Background",
	"MinuteHand",
	"HourHand",
	"Gloss",
}

function GroupCalendar._Clock:Construct()
	self:SetScript("OnShow", function () this:OnShow() end)
	self:SetScript("OnHide", function () this:OnHide() end)
end

function GroupCalendar._Clock:ShowDisplay()
	self.Widgets.Background:Show()
	self.Widgets.MinuteHand:Show()
	self.Widgets.HourHand:Show()
	self.Widgets.Gloss:Show()
	
	self:OnShow()
end

function GroupCalendar._Clock:HideDisplay()
	self.Widgets.Background:Hide()
	self.Widgets.MinuteHand:Hide()
	self.Widgets.HourHand:Hide()
	self.Widgets.Gloss:Hide()
	
	self:OnHide()
end

function GroupCalendar._Clock:OnShow()
	self:Update()
	
	MCSchedulerLib:ScheduleUniqueRepeatingTask(30, self.Update, self, nil, "GroupCalendar._Clock.Update")
	MCEventLib:RegisterEvent("GC_CLOCKS_CHANGED", self.Update, self)
end

function GroupCalendar._Clock:OnHide()
	MCSchedulerLib:UnscheduleTask(self.Update, self)
	MCEventLib:UnregisterEvent("GC_CLOCKS_CHANGED", self.Update, self)
end

function GroupCalendar._Clock:Update()
	local vTime = MCDateLib:GetServerTime()
	
	if gGroupCalendar_Settings.ClockMode == "local"
	or ((gGroupCalendar_Settings.ClockMode == nil or gGroupCalendar_Settings.ClockMode == "auto") and gGroupCalendar_Settings.ShowEventsInLocalTime) then
		vTime = MCDateLib:GetLocalTimeFromServerTime(vTime)
	end
	
	local vHour, vMinute = GroupCalendar.ConvertTimeToHM(vTime)
	local vHourAngle
	
	vHourAngle = (vHour + vMinute / 60) * 3.1415926535 / 6
	
	self:SetTextureAngle(self.Widgets.HourHand, vHourAngle)
	self:SetTextureAngle(self.Widgets.MinuteHand, vMinute * 3.1415926535 / 30)
end

function GroupCalendar._Clock:MatrixDotVector(pMatrix, pVector)
	local vResult = {}
	
	for vRow, vRowValues in ipairs(pMatrix) do
		local vTotal = 0
		
		for vColumn, vMatrixValue in ipairs(vRowValues) do
			vTotal = vTotal + vMatrixValue * (pVector[vColumn] or 1)
		end
		
		vResult[vRow] = vTotal
	end
	
	return vResult
end

function GroupCalendar._Clock:SetTextureAngle(pTexture, pAngle, pScaleX, pScaleY)
	-- Calculate the rotation transform
	
	local vCosAngle = math.cos(-pAngle)
	local vSinAngle = math.sin(-pAngle)
	
	local vTransform =
	{
		{vCosAngle, vSinAngle, 0.5}, -- Offset by 0.5 to make the coordinates 0.0 to 1.0 instead of -0.5 to 0.5
		{vSinAngle, -vCosAngle, 0.5},-- Same for the Y axis
	}
	
	-- Rotate the texture
	
	local vTopLeft = self:MatrixDotVector(vTransform, {-0.5, 0.5})
	local vTopRight = self:MatrixDotVector(vTransform, {0.5, 0.5})
	local vBottomLeft = self:MatrixDotVector(vTransform, {-0.5, -0.5})
	local vBottomRight = self:MatrixDotVector(vTransform, {0.5, -0.5})
	
	-- Set the texture
	
	pTexture:SetTexCoord(
			vTopLeft[1], vTopLeft[2],
			vBottomLeft[1], vBottomLeft[2],
			vTopRight[1], vTopRight[2],
			vBottomRight[1], vBottomRight[2])
end

----------------------------------------
-- Clock check
----------------------------------------

StaticPopupDialogs.GC_CLOCK_WARNING =
{
	text = TEXT(GroupCalendar_cClockNotSetWarning),
	button1 = TEXT(OKAY),
	OnAccept = function() end,
	OnCancel = function() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
}

GroupCalendar.Time.TimeStampHistory = {}

function GroupCalendar.Time:TimeSampleReceived(pSender, pTimeStamp)
	local vOurTimeStamp = MCDateLib:GetUTCDateTimeStamp()
	local vOurDifference = math.abs(pTimeStamp - vOurTimeStamp)
	
	if GroupCalendar.Debug.ClockCheck then
		GroupCalendar:DebugMessage("TimeSampleReceived: %s difference is %f", pSender, vOurDifference)
	end
	
	-- If they're already in the history just update their record
	
	for _, vTimeStampInfo in ipairs(self.TimeStampHistory) do
		if vTimeStampInfo.Sender == pSender then
			vTimeStampInfo.Difference = vOurDifference
			return
		end
	end
	
	--
	
	if table.getn(self.TimeStampHistory) >= 5 then
		table.remove(self.TimeStampHistory, 1)
		table.insert(self.TimeStampHistory, {Sender = pSender, Difference = vOurDifference})
		
		-- Find the greatest consensus
		
		local vBestNumAgreed = 0
		local vBestAgreedNames = {}
		local vBestAgreedDifference
		
		local vAgreedNames = {}
		
		for vTimeStampIndex, vTimeStampInfo in ipairs(self.TimeStampHistory) do
			local vNumAgreed = 1
			local vAgreedDifference = vTimeStampInfo.Difference
			
			if vBestAgreedNames == vAgreedNames then
				vAgreedNames = {vTimeStampInfo.Sender}
			else
				GroupCalendar.EraseTable(vAgreedNames)
				table.insert(vAgreedNames, vTimeStampInfo.Sender)
			end
			
			for vTimeStampIndex2 = vTimeStampIndex + 1, table.getn(self.TimeStampHistory) do
				local vTimeStampInfo2 = self.TimeStampHistory[vTimeStampIndex2]
				local vDifferenceDelta = math.abs(vTimeStampInfo.Difference - vTimeStampInfo2.Difference)
				
				-- If they're within 10 minutes of each other then they're in good agreement
				
				if vDifferenceDelta < 10 * 60 then
					table.insert(vAgreedNames, vTimeStampInfo2.Sender)
					vNumAgreed = vNumAgreed + 1
					vAgreedDifference = vAgreedDifference + 1
				end
			end
			
			if vNumAgreed > vBestNumAgreed then
				vBestNumAgreed = vNumAgreed
				vBestAgreedNames = vAgreedNames
				vBestAgreedDifference = vAgreedDifference / vNumAgreed
			end
		end
		
		--
		
		if GroupCalendar.Debug.ClockCheck then
			GroupCalendar:DebugMessage("TimeSampleReceived: %d samples agree that we're off by %.1f seconds", vBestNumAgreed, vBestAgreedDifference)
		end
		
		-- If at least three agreed and we're more than 20 minutes off from them
		-- then report a problem
		
		if vBestNumAgreed >= 3
		and vBestAgreedDifference > 20 * 60
		and not self.DidClockWarning then
			self.DidClockWarning = true
			StaticPopup_Show("GC_CLOCK_WARNING", GroupCalendar:FormatItemList(vBestAgreedNames))
		end
	else
		table.insert(self.TimeStampHistory, {Sender = pSender, Difference = vOurDifference})
	end
end

