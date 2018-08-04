gDaysInMonth = {31, 28, 31, 30,  31,  30,  31,  31,  30,  31,  30,  31}
gDaysToMonth = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365}

GroupCalendar.Calendar = {}

GroupCalendar.Calendar.StartDayOfWeek = 0
GroupCalendar.Calendar.StartDate = 0
GroupCalendar.Calendar.EndDate = 0

GroupCalendar.Calendar.ActualDate = -1
GroupCalendar.Calendar.ActualDateIndex = -1

GroupCalendar.Calendar.SelectedDate = -1
GroupCalendar.Calendar.SelectedDateIndex = -1

GroupCalendar.cRoleColorName =
{
	MH = "PRIEST",
	OH = "PALADIN",
	MT = "WARRIOR",
	OT = "DRUID",
	RD = "MAGE",
	MD = "ROGUE",
}

gCalendarPlayerList_cNumVisibleEntries = 4
gCalendarPlayerList_cItemHeight = 15

GroupCalendar.cMinutesPerDay = 1440
GroupCalendar.cSecondsPerDay = GroupCalendar.cMinutesPerDay * 60

GroupCalendar.cDeformat =
{
	s = "(.-)",
	d = "(-?[%d]+)",
	f = "(-?[%d%.]+)",
	g = "(-?[%d%.]+)",
	["%"] = "%%",
}

function GroupCalendar.NewTable()
	if false and GroupCalendar.RecycledTables and table.getn(GroupCalendar.RecycledTables) > 0 then
		return table.remove(GroupCalendar.RecycledTables)
	else
		return {}
	end
end

function GroupCalendar.DeleteTable(pTable, pRecurseDepth)
	if not pTable then
		return
	end
	
	--
	
	if pRecurseDepth and pRecurseDepth > 0 then
		for vKey, vValue in pairs(pTable) do
			if type(vValue) == "table" then
				GroupCalendar.DeleteTable(vValue, pRecurseDepth - 1)
			end
			
			pTable[vKey] = nil
		end
	else
		GroupCalendar.EraseTable(pTable)
	end
	
	-- Recycling tables may be more memory-efficient, but it's also 
	-- very risky because if the table still has references then
	-- things will get ugly and it'll be hard to track down the cause.
	
	if false then
		if not GroupCalendar.RecycledTables then
			GroupCalendar.RecycledTables = {}
		end
		
		if table.getn(GroupCalendar.RecycledTables) < 100 then
			table.insert(GroupCalendar.RecycledTables, pTable)
		end
	end
end

function GroupCalendar.RecycleTable(pTable)
	if pTable then
		GroupCalendar.EraseTable(pTable)
		return pTable
	else
		return GroupCalendar.NewTable()
	end
end

function GroupCalendar.EraseTable(pTable)
	for vKey, _ in pairs(pTable) do
		pTable[vKey] = nil
	end
end

function GroupCalendar.DuplicateTable(pTable, pRecurse, pDestTable)
	if not pTable then
		return nil
	end
	
	local vTable
	
	if pDestTable then
		vTable = pDestTable
		
		if type(pDestTable) ~= "table" then
			GroupCalendar:DebugMessage("pDestTable is a %s", type(pDestTable))
			GroupCalendar:DebugStack()
			return
		end
	else
		vTable = {}
	end
	
	if pRecurse then
		for vKey, vValue in pairs(pTable) do
			if type(vValue) == "table" then
				vTable[vKey] = GroupCalendar.DuplicateTable(vValue, true)
			else
				vTable[vKey] = vValue
			end
		end
	else
		GroupCalendar.CopyTable(vTable, pTable)
	end
	
	return vTable
end

function GroupCalendar.CopyTable(pDestTable, pSourceTable)
	for vKey, vValue in pairs(pSourceTable) do
		pDestTable[vKey] = vValue
	end
end

function GroupCalendar.ReverseTable(pTable)
	local vTable = {}
	
	for vKey, vValue in pairs(pTable) do
		vTable[vValue] = vKey
	end
	
	return vTable
end

function GroupCalendar.NewObject(pMethodTable, ...)
	if not pMethodTable then
		GroupCalendar:ErrorMessage("NewObject called with nil method table")
		GroupCalendar:DebugStack()
	end
	
	local vObject = GroupCalendar.DuplicateTable(pMethodTable)
	
	if vObject.Construct then
		vObject:Construct(unpack(arg))
	end
	
	return vObject
end

function GroupCalendar:FormatItemList(pList)
	local vNumItems = table.getn(pList)
	
	if vNumItems == 0 then
		return ""
	elseif vNumItems == 1 then
		return string.format(self.cSingleItemFormat, pList[1])
	elseif vNumItems == 2 then
		return string.format(self.cTwoItemFormat, pList[1], pList[2])
	else
		local vStartIndex, vEndIndex, vPrefix, vRepeat, vSuffix = string.find(self.cMultiItemFormat, "(.*){{(.*)}}(.*)")
		local vResult
		local vParamIndex = 1
		
		if vPrefix and string.find(vPrefix, "%%") then
			vResult = string.format(vPrefix, pList[1])
			vParamIndex = 2
		else
			vResult = vPrefix or ""
		end
		
		if vRepeat then
			for vIndex = vParamIndex, vNumItems - 1 do
				vResult = vResult..string.format(vRepeat, pList[vIndex])
			end
		end
			
		if vSuffix then
			vResult = vResult..string.format(vSuffix, pList[vNumItems])
		end
		
		return vResult
	end
end

function GroupCalendar.InitializeFrame(pFrame, ...)
	local vNumClasses = arg.n
	
	for vIndex = 1, vNumClasses do
		local vTable = arg[vIndex]
		
		GroupCalendar.InitializeFrameFromTable(pFrame, vTable, pFrame._Name)
	end
	
	return pFrame
end

function GroupCalendar.InitializeFrameFromTable(pFrame, pTable, pFrameName, pUseFieldNameInPath)
	if not pFrameName and pFrame.GetName then
		pFrameName = pFrame:GetName()
	end
	
	if not pFrame then
		GroupCalendar:ErrorMessage("InitializeFrameFromTable: pFrame is nil")
		GroupCalendar:DebugStack()
		return
	end
	
	--
	
	for vSourceIndex, vSourceValue in pairs(pTable) do
		local vDestIndex, vDestValue
		local vSourceValueType = type(vSourceValue)
		
		-- Functions are copied straight over with the same name
		
		if vSourceValueType == "function" then
			vDestIndex = vSourceIndex
			vDestValue = vSourceValue
		
		-- Strings are appended to the object name and then the
		-- global with that name is retrieved.  If there's no
		-- global with that name then the string is copied as-is
		
		elseif vSourceValueType == "string" then
			vDestValue = getglobal(pFrameName..vSourceValue)
			
			if not vDestValue then
				GroupCalendar:NoteMessage("Global %s not found", pFrameName..vSourceValue)
				vDestValue = vSourceValue
				
				if type(vSourceIndex) == "number" then
					vDestIndex = table.getn(pFrame) + 1
				else
					vDestIndex = vSourceIndex
				end
				
			elseif type(vSourceIndex) == "number" then
				vDestIndex = vSourceValue
			else
				vDestIndex = vSourceIndex
			end
		
		-- Tables are treated as widget lists (maybe I
		-- should special case the name "Widgets" so that
		-- tables can also be class statics? have to search
		-- the code to ensure everything using tables
		-- are naming them Widgets)
		
		elseif vSourceValueType == "table" then
			vDestIndex = vSourceIndex
			vDestValue = getglobal(pFrameName..vSourceIndex)
			
			if not vDestValue then
				vDestValue = {}
			end
			
			local vObjectName
			
			if vSourceValue._Name then
				vObjectName = pFrameName..vSourceValue._Name
			elseif pUseFieldNameInPath then
				vObjectName = pFrameName..vSourceIndex
			else
				vObjectName = pFrameName
			end 
			
			GroupCalendar.InitializeFrameFromTable(vDestValue, vSourceValue, vObjectName, true)
		
		-- Everything else is copied as-is (booleans and numbers)
		
		else
			vDestValue = vSourceValue
			
			if type(vSourceIndex) == "number" then
				vDestIndex = table.getn(pFrame) + 1
			else
				vDestIndex = vSourceIndex
			end
		end
		
		pFrame[vDestIndex] = vDestValue
	end
end

function GroupCalendar:ConstructFrame(pFrame, pMethods, ...)
	for vKey, vValue in pairs(pMethods) do
		if vKey == "Widgets" and type(vValue) == "table" then
			if not pFrame.Widgets then
				pFrame.Widgets = {}
			end
			
			self:ConstructWidgets(pFrame.Widgets, pFrame:GetName(), vValue)
		else
			pFrame[vKey] = vValue
		end
	end
	
	if pMethods.Construct then
		pFrame:Construct(unpack(arg))
	end
	
	return pFrame
end

function GroupCalendar:ConstructWidgets(pTable, pNamePrefix, pWidgets)
	for vKey, vValue in pairs(pWidgets) do
		local vNamePrefix
		
		if pNamePrefix then
			vNamePrefix = pNamePrefix
		else
			vNamePrefix = pWidgets._Prefix
		end
		
		if not vNamePrefix then
			self:ErrorMessage("ConstructFrame: Can't initialize widgets for frame because there's no name prefix")
			self:DebugStack()
			return
		end
		
		local vWidgetName, vWidgetChildren
		
		if type(vKey) == "number" then
			vWidgetName = vValue
		else
			vWidgetName = vKey
			vWidgetChildren = vValue
		end
		
		if type(vWidgetName) == "string" and string.sub(vWidgetName, 1, 1) ~= "_" then
			local vIsArray
			
			if string.sub(vWidgetName, -2) == "[]" then
				vWidgetName = string.sub(vWidgetName, 1, -3)
				
				local vIndex = 1
				local vWidgetList = {}
				
				pTable[vWidgetName] = vWidgetList

				local vWidget = getglobal(vNamePrefix..vWidgetName..vIndex)
				
				while vWidget ~= nil do
					vWidgetList[vIndex] = vWidget
					
					if vWidgetChildren then
						self:ConstructWidgets(vWidget, vNamePrefix..vWidgetName..vIndex, vWidgetChildren)
					end
					
					-- Next
					
					vIndex = vIndex + 1
					vWidget = getglobal(vNamePrefix..vWidgetName..vIndex)
				end
			else
				local vWidget = getglobal(vNamePrefix..vWidgetName)
				
				if vWidget == nil then
					self:ErrorMessage("Couldn't find widget "..vNamePrefix..vWidgetName)
				else
					pTable[vWidgetName] = vWidget
				end
				
				if vWidgetChildren then
					self:ConstructWidgets(vWidget, vNamePrefix..vWidgetName, vWidgetChildren)
				end
			end
		end
	end
end

function GroupCalendar.MenuInitHook(...)
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)

	vFrame.OrigInitFunction(unpack(arg))
	vFrame:SetHeight(vFrame.OrigHeight)
end

function GroupCalendar.UIDropDownMenu_Initialize(pFrame, pInitFunction, ...)
	if not pFrame.OrigHeight then
		-- Remember the width and height
		
		pFrame.OrigHeight = pFrame:GetHeight()
		pFrame.OrigWidth = pFrame:GetWidth()
	end
	
	if pInitFunction ~= GroupCalendar.MenuInitHook then
		pFrame.OrigInitFunction = pInitFunction
	end
	
	UIDropDownMenu_Initialize(pFrame, GroupCalendar.MenuInitHook, unpack(arg))
	
	pFrame:SetHeight(pFrame.OrigHeight)
	pFrame:SetWidth(pFrame.OrigWidth)
	
	pFrame.SetSelectedValue = CalendarDropDown_SetSelectedValue
	pFrame.SetSelectedValue2 = CalendarDropDown_SetSelectedValue2
end

function GroupCalendar.ConvertFormatStringToSearchPattern(pFormat)
	return string.gsub(
			pFormat,
			"%%[%-%d%.]-([sdgf%%])",
			function (pFormatField) return GroupCalendar.cDeformat[pFormatField] end)
end

function GroupCalendar.SetCheckButtonEnable(pCheckButton, pEnabled)
	if pEnabled then
		pCheckButton:Enable()
		pCheckButton:SetAlpha(1.0)
		getglobal(pCheckButton:GetName().."Text"):SetAlpha(1.0)
	else
		pCheckButton:Disable()
		pCheckButton:SetAlpha(0.7)
		getglobal(pCheckButton:GetName().."Text"):SetAlpha(0.7)
	end
end

function GroupCalendar.SetEditBoxEnable(pEditBox, pEnabled)
	local vText = getglobal(pEditBox:GetName().."Text")
	
	if pEnabled then
		pEditBox:SetAlpha(1.0)
		if vText then
			vText:SetAlpha(1.0)
		end
		pEditBox:EnableKeyboard(true)
		pEditBox:EnableMouse(true)
		
		pEditBox.isDisabled = false
	else
		pEditBox:SetAlpha(0.7)
		if vText then
			vText:SetAlpha(0.7)
		end
		
		pEditBox:ClearFocus()
		pEditBox:EnableKeyboard(false)
		pEditBox:EnableMouse(false)

		pEditBox.isDisabled = true
	end
end

function GroupCalendar.SetDropDownEnable(pDropDown, pEnabled)
	if pEnabled then
		pDropDown:SetAlpha(1.0)
		getglobal(pDropDown:GetName().."Text"):SetAlpha(1.0)
		getglobal(pDropDown:GetName().."Button"):EnableMouse(true)
	else
		pDropDown:SetAlpha(0.7)
		getglobal(pDropDown:GetName().."Text"):SetAlpha(0.7)
		getglobal(pDropDown:GetName().."Button"):EnableMouse(false)
	end
end

function GroupCalendar.SetButtonEnable(pButton, pEnabled)
	if pEnabled then
		pButton:Enable()
		pButton:SetAlpha(1.0)
		pButton:EnableMouse(true)
		--getglobal(pButton:GetName().."Text"):SetAlpha(1.0)
	else
		pButton:Disable()
		pButton:SetAlpha(0.7)
		pButton:EnableMouse(false)
		--getglobal(pButton:GetName().."Text"):SetAlpha(0.7)
	end
end

function CalendarDropDown_SetSelectedValue2(pDropDown, pValue)
	pDropDown.selectedName = nil
	pDropDown.selectedID = nil
	pDropDown.selectedValue = pValue
end

function CalendarDropDown_SetSelectedValue(pDropDown, pValue)
	-- Just return if the value isn't changing
	
	if not pDropDown then
		GroupCalendar:DebugMessage("CalendarDropDown_SetSelectedValue: nil dropdown")
		GroupCalendar:DebugStack()
		return
	end
	
	if pDropDown.selectedValue == pValue then
		return
	end
	
	--
	
	if not getglobal(pDropDown:GetName().."Text") then	
		GroupCalendar:ErrorMessage("Menu %s is mssing a text field", pDropDown:GetName())
		GroupCalendar:DebugStack()
	end
	
	UIDropDownMenu_SetText("", pDropDown) -- Set to empty in case the selected value isn't there

	UIDROPDOWNMENU_OPEN_MENU = nil
	GroupCalendar.UIDropDownMenu_Initialize(pDropDown, pDropDown.initialize, nil, 1)
	UIDropDownMenu_SetSelectedValue(pDropDown, pValue)
	
	-- All done if the item text got set successfully
	
	local vItemText = UIDropDownMenu_GetText(pDropDown)
	
	if vItemText and vItemText ~= "" then
		return
	end
	
	-- Scan for submenus
	
	local vRootListFrameName = "DropDownList1"
	local vRootListFrame = getglobal(vRootListFrameName)
	local vRootNumItems = vRootListFrame.numButtons
	
	for vRootItemIndex = 1, vRootNumItems do
		local vItem = getglobal(vRootListFrameName.."Button"..vRootItemIndex)
		
		if vItem.hasArrow then
			local vSubMenuFrame = getglobal("DropDownList2")
			
			UIDROPDOWNMENU_OPEN_MENU = pDropDown:GetName()
			UIDROPDOWNMENU_MENU_VALUE = vItem.value
			UIDROPDOWNMENU_MENU_LEVEL = 2
			
			GroupCalendar.UIDropDownMenu_Initialize(pDropDown, pDropDown.initialize, nil, 2)
			UIDropDownMenu_SetSelectedValue(pDropDown, pValue)
			
			-- All done if the item text got set successfully
			
			local vItemText = UIDropDownMenu_GetText(pDropDown)
			
			if vItemText and vItemText ~= "" then
				return
			end
			
			-- Switch back to the root menu
			
			UIDROPDOWNMENU_OPEN_MENU = nil
			GroupCalendar.UIDropDownMenu_Initialize(pDropDown, pDropDown.initialize, nil, 1)
		end
	end
end

function GroupCalendar.GetShortTimeString(pTime)
	if pTime == nil then
		return nil
	end
	
	if TwentyFourHourTime then
		local vHour, vMinute = GroupCalendar.ConvertTimeToHM(pTime)
		
		return format(TEXT(TIME_TWENTYFOURHOURS), vHour, vMinute)
	else
		local vHour, vMinute, vAMPM = GroupCalendar.ConvertTimeToHMAMPM(pTime)
		
		if vAMPM == 0 then
			return format(TEXT(TIME_TWELVEHOURAM), vHour, vMinute)
		else
			return format(TEXT(TIME_TWELVEHOURPM), vHour, vMinute)
		end
	end
end

function GroupCalendar.ConvertTimeToHM(pTime)
	local vMinute = math.mod(pTime, 60)
	local vHour = (pTime - vMinute) / 60
	
	return vHour, vMinute
end

function GroupCalendar.ConvertHMToTime(pHour, pMinute)
	return pHour * 60 + pMinute
end

function GroupCalendar.ConvertHMSToTime60(pHour, pMinute, pSecond)
	return pHour * 3600 + pMinute * 60 + pSecond
end

function GroupCalendar.ConvertTimeToHMAMPM(pTime)
	local vHour, vMinute = GroupCalendar.ConvertTimeToHM(pTime)
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

function GroupCalendar.ConvertHMAMPMToTime(pHour, pMinute, pAMPM)
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
	
	return GroupCalendar.ConvertHMToTime(vHour, pMinute)
end

function GroupCalendar.GetLongDateString(pDate, pIncludeDayOfWeek)
	local vFormat
	
	if pIncludeDayOfWeek then
		vFormat = GroupCalendar_cLongDateFormatWithDayOfWeek
	else
		vFormat = GroupCalendar_cLongDateFormat
	end
	
	return GroupCalendar.GetFormattedDateString(pDate, vFormat)
end

function GroupCalendar.GetShortDateString(pDate, pIncludeDayOfWeek)
	return GroupCalendar.GetFormattedDateString(pDate, GroupCalendar_cShortDateFormat)
end

function GroupCalendar.FormatNamed(pFormat, pFields)
	return string.gsub(pFormat, "%$(%w+)", function(pField) return pFields[pField] end)
end

function GroupCalendar.GetFormattedDateString(pDate, pFormat)
	local vMonth, vDay, vYear = GroupCalendar.ConvertDateToMDY(pDate)
	
	local vDate =
			{
				dow = GroupCalendar_cDayOfWeekNames[GroupCalendar.GetDayOfWeekFromDate(pDate) + 1],
				month = GroupCalendar_cMonthNames[vMonth],
				monthNum = vMonth,
				day = vDay,
				year = vYear,
			}
	
	return GroupCalendar.FormatNamed(pFormat, vDate)
end

local GroupCalendar_cWeekdayLabelNames = {GroupCalendar_cSun, GroupCalendar_cMon, GroupCalendar_cTue, GroupCalendar_cWed, GroupCalendar_cThu, GroupCalendar_cFri, GroupCalendar_cSat}
local GroupCalendar_cWeekdayLabelNames2 = {GroupCalendar_cMon, GroupCalendar_cTue, GroupCalendar_cWed, GroupCalendar_cThu, GroupCalendar_cFri, GroupCalendar_cSat, GroupCalendar_cSun}

function GroupCalendar.Calendar:SetStartWeekOnMonday(pStartOnMonday)
	gGroupCalendar_Settings.StartOnMonday = pStartOnMonday
	
	-- Adjust weekday labels
	
	local vLabelNames
	
	if gGroupCalendar_Settings.StartOnMonday then
		vLabelNames = GroupCalendar_cWeekdayLabelNames2
	else
		vLabelNames = GroupCalendar_cWeekdayLabelNames
	end
	
	for vIndex = 0, 6 do
		local vLabel = getglobal("GroupCalendarCalendarFrameWeekdayLabel"..vIndex)
		vLabel:SetText(vLabelNames[vIndex + 1])
	end
	
	if GroupCalendarFrame:IsVisible() then
		self:SetDisplayDate(self.StartDate)
	end
end

function GroupCalendar.Calendar:SetDisplayDate(pStartDate)
	local vMonth, vDay, vYear = GroupCalendar.ConvertDateToMDY(pStartDate)
	local vDaysInMonth = GroupCalendar.GetDaysInMonth(vMonth, vYear)
	local vStartDayOfWeek = GroupCalendar.GetDayOfWeek(vMonth, 1, vYear)
	
	if gGroupCalendar_Settings.StartOnMonday then
		vStartDayOfWeek = vStartDayOfWeek - 1
		
		if vStartDayOfWeek < 0 then
			vStartDayOfWeek = 6
		end
	end
	
	GroupCalendar.SetCalendarRange(
			vStartDayOfWeek,
			vDaysInMonth,
			pStartDate)
	
	local vCalendarTitle = getglobal("GroupCalendarMonthYearText")
	
	vCalendarTitle:SetText(GroupCalendar_cMonthNames[vMonth].." "..vYear)

	GroupCalendar.Calendar.StartDate = pStartDate
	GroupCalendar.Calendar.EndDate = pStartDate + vDaysInMonth
	
	GroupCalendar.HiliteActualDate()
	GroupCalendar.HiliteSelectedDate()
	
	GroupCalendar.UpdateEventIcons()
end

function GroupCalendar.SetActualDate(pDate)
	GroupCalendar.Calendar.ActualDate= pDate
	GroupCalendar.HiliteActualDate()
end

function GroupCalendar.HiliteActualDate()
	local vDayButton
	
	if GroupCalendar.Calendar.ActualDateIndex >= 0 then
		vDayButton = getglobal("GroupCalendarDay"..GroupCalendar.Calendar.ActualDateIndex.."SlotIcon")
		vDayButton:SetTexture("Interface\\Buttons\\UI-EmptySlot-Disabled")
		GroupCalendar.Calendar.ActualDateIndex = -1
		
		GroupCalendarTodayHighlight:Hide()
	end
	
	if GroupCalendar.Calendar.ActualDate < GroupCalendar.Calendar.StartDate
	or GroupCalendar.Calendar.ActualDate >= GroupCalendar.Calendar.EndDate then
		return
	end
	
	GroupCalendar.Calendar.ActualDateIndex = GroupCalendar.Calendar.ActualDate - GroupCalendar.Calendar.StartDate + GroupCalendar.Calendar.StartDayOfWeek
	
	if GroupCalendar.Calendar.ActualDateIndex >= 0 then
		local vDayButtonName = "GroupCalendarDay"..GroupCalendar.Calendar.ActualDateIndex
		local vDayButtonIconName = vDayButtonName.."SlotIcon"
		
		vDayButton = getglobal(vDayButtonIconName)
		vDayButton:SetTexture("Interface\\Buttons\\UI-EmptySlot")
		
		GroupCalendarTodayHighlight:SetPoint("CENTER", vDayButtonName, "CENTER", 1, 0)
		GroupCalendarTodayHighlight:SetAlpha(0.1)
		GroupCalendarTodayHighlight:Show()
	end
end

function GroupCalendar.SetSelectedDate(pDate)
	GroupCalendar.NewEvents[pDate] = nil
	GroupCalendar.StopFlashingDateButton(pDate)
	
	GroupCalendar.Calendar.SelectedDate = pDate
	
	GroupCalendar.HiliteSelectedDate()
end

function GroupCalendar.ClearSelectedDate()
	GroupCalendar.Calendar.SelectedDate = -1
	GroupCalendar.HiliteSelectedDate()
end

function GroupCalendar.SetSelectedDateIndexWithToggle(pIndex)
	GroupCalendar_SelectDateWithToggle(
			GroupCalendar.Calendar.StartDate + pIndex - GroupCalendar.Calendar.StartDayOfWeek)
end

function GroupCalendar.SetSelectedDateIndex(pIndex)
	GroupCalendar_SelectDate(
			GroupCalendar.Calendar.StartDate + pIndex - GroupCalendar.Calendar.StartDayOfWeek)
end

function GroupCalendar.GetDayButtonByDate(pDate)
	if pDate < GroupCalendar.Calendar.StartDate
	or pDate >= GroupCalendar.Calendar.EndDate then
		return
	end
	
	local vDateIndex = pDate - GroupCalendar.Calendar.StartDate + GroupCalendar.Calendar.StartDayOfWeek
	
	return getglobal("GroupCalendarDay"..vDateIndex), vDateIndex
end

function GroupCalendar.StopFlashingDateButton(pDate)
	local vDayButton, vDateIndex = GroupCalendar.GetDayButtonByDate(pDate)
	
	if not vDayButton then
		return
	end
	
	local vDateHighlight = getglobal("GroupCalendarDay"..vDateIndex.."HighlightIcon")
	
	UIFrameFlashRemoveFrame(vDateHighlight)
	vDateHighlight:Hide()
end

function GroupCalendar.StartFlashingDateButton(pDate)
	local vDayButton, vDateIndex = GroupCalendar.GetDayButtonByDate(pDate)
	
	if not vDayButton then
		return
	end
	
	local vDateHighlight = getglobal("GroupCalendarDay"..vDateIndex.."HighlightIcon")
	
	UIFrameFlash(vDateHighlight, 0.5, 0.5, 60 * 60, false, 0, 0)
	vDateHighlight:Hide()
end

function GroupCalendar.HiliteSelectedDate()
	if GroupCalendar.Calendar.SelectedDateIndex >= 0 then
		vDayButton = getglobal("GroupCalendarDay"..GroupCalendar.Calendar.SelectedDateIndex)
		vDayButton:SetChecked(nil)
		GroupCalendar.Calendar.SelectedDateIndex = -1
	end
	
	local vDayButton, vDateIndex = GroupCalendar.GetDayButtonByDate(GroupCalendar.Calendar.SelectedDate)
	
	if not vDayButton then
		return
	end
	
	GroupCalendar.Calendar.SelectedDateIndex = vDateIndex
	vDayButton:SetChecked(true)
end

function GroupCalendar.GetEventTypeIconPath(pEventType)
	local vIconSuffix
	
	if GroupCalendar.Database.IsResetEventType(pEventType) then
		local vIsSystemIcon
		
		vIconSuffix, vIsSystemIcon = GroupCalendar.Database.GetResetEventLargeIconPath(pEventType)
		
		if not vIconSuffix then
			return ""
		end
		
		if vIsSystemIcon then
			return vIconSuffix
		end
	else
		if GroupCalendar.Database.GetEventNameByID(pEventType) then -- Don't attempt to show icons for event types we don't recognize
			vIconSuffix = pEventType
		else
			vIconSuffix = "Unknown"
		end
	end
	
	return "Interface\\AddOns\\GroupCalendar\\Textures\\Icon-"..vIconSuffix
end

function GroupCalendar.SetDateButtonSchedule(pDate, pCompiledSchedule, pCutoffServerDateTime)
	if pDate < GroupCalendar.Calendar.StartDate or pDate >= GroupCalendar.Calendar.EndDate then
		return
	end
	
	local vIndex = pDate - GroupCalendar.Calendar.StartDate + GroupCalendar.Calendar.StartDayOfWeek
	local vDayButton = getglobal("GroupCalendarDay"..vIndex)
	local vDayIcon = getglobal("GroupCalendarDay"..vIndex.."Icon")
	local vOverlayIcon = getglobal("GroupCalendarDay"..vIndex.."OverlayIcon")
	local vCircledDate = getglobal("GroupCalendarDay"..vIndex.."CircledDate")
	local vDogEarIcon = getglobal("GroupCalendarDay"..vIndex.."DogEarIcon")
	
	vOverlayIcon:Hide()
	
	if pCompiledSchedule then
		local vDayIconType = nil
		local vDayIconIsLowPriority = false
		local vUnqualifiedDayIconType = nil
		local vExpiredDayIconType = nil
		local vExpiredUnqualifiedDayIconType = nil
		local vResetEventType = nil
		local vExpiredResetEventType = nil
		
		local vShowBirthdayIcon = false
		local vHasAppointment = false
		local vAppointmentIsDimmed = false
		local vAppointmentIsConfirmed = false
		local vAppointmentIsStandby = false
		local vAppointmentIsMaybe = false
		local vGotDogEarEvent = false
		
		for vEventIndex, vCompiledEvent in ipairs(pCompiledSchedule) do
			local vPlayerIsQualified = GroupCalendar.Database.PlayerIsQualifiedForEvent(vCompiledEvent.mEvent, GroupCalendar.PlayerLevel)
			
			-- Determine if the event is expired
			
			local vEventIsExpired = false
			
			if pCutoffServerDateTime
			and vCompiledEvent.mEvent.mTime
			and vCompiledEvent.mEvent.mDuration then
				local vEventStartDateTime = vCompiledEvent.mEvent.mDate * GroupCalendar.cMinutesPerDay + vCompiledEvent.mEvent.mTime
				local vEventEndDateTime = vEventStartDateTime + vCompiledEvent.mEvent.mDuration
				
				vEventIsExpired = vEventEndDateTime <= pCutoffServerDateTime
			end
			
			-- Check for birthday events
			
			if vCompiledEvent.mEvent.mType == "Birth" then
				vShowBirthdayIcon = true
			
			-- Check for cooldown/reset events
			
			elseif GroupCalendar.Database.IsResetEventType(vCompiledEvent.mEvent.mType) then
			
				if vEventIsExpired then
					if not vExpiredResetEventType then
						vExpiredResetEventType = vCompiledEvent.mEvent.mType
					end
				else
					if not vResetEventType then
						vResetEventType = vCompiledEvent.mEvent.mType
					end
				end
				
			-- Check for ordinary events
				
			else
				local vIconPath = GroupCalendar.GetEventTypeIconPath(vCompiledEvent.mEvent.mType)
				
				if not vPlayerIsQualified then
					if vEventIsExpired then
						if not vExpiredUnqualifiedDayIconType then
							vExpiredUnqualifiedDayIconType = vIconPath
						end
					else
						if not vUnqualifiedDayIconType then
							vUnqualifiedDayIconType = vIconPath
						end
					end
				else
					if vEventIsExpired then
						if not vExpiredDayIconType then
							vExpiredDayIconType = vIconPath
						end
					else
						if not vDayIconType
						or vDayIconIsLowPriority then
							vDayIconType = vIconPath
							vDayIconIsLowPriority = not GroupCalendar.Database.EventTypeUsesTime(vCompiledEvent.mEvent.mType)
						end
					end
				end
			end -- else Birth
			
			if (not vHasAppointment
			or (vAppointmentIsDimmed and vPlayerIsQualified)) then
				local vAttending = GroupCalendar.Database.PlayerIsAttendingEvent(vCompiledEvent.mOwner, vCompiledEvent.mEvent)
				
				if vAttending then
					vHasAppointment = true
					vAppointmentIsConfirmed = vAttending == "CONFIRMED" or vAttending == "CONFIRMED_STANDBY" or vAttending == "CONFIRMED_MAYBE"
					vAppointmentIsStandby = vAttending == "CONFIRMED_STANDBY" or vAttending == "REQUESTED_STANDBY"
					vAppointmentIsMaybe = vAttending == "CONFIRMED_MAYBE" or vAttending == "REQUESTED_MAYBE"

					vAppointmentIsDimmed = not vPlayerIsQualified
				end
			end
		end -- for vEventIndex
		
		-- Update the day icon
		
		if vDayIconType then
			vDayIcon:SetTexture(vDayIconType)
			vDayIcon:SetAlpha(1.0)
			vDayIcon:Show()
		elseif vUnqualifiedDayIconType then
			vDayIcon:SetTexture(vUnqualifiedDayIconType)
			vDayIcon:SetAlpha(0.25)
			vDayIcon:Show()
		elseif vExpiredDayIconType then
			vDayIcon:SetTexture(vExpiredDayIconType)
			vDayIcon:SetAlpha(1.0)
			vDayIcon:Show()
		elseif vExpiredUnqualifiedDayIconType then
			vDayIcon:SetTexture(vExpiredUnqualifiedDayIconType)
			vDayIcon:SetAlpha(0.25)
			vDayIcon:Show()
		else
			vDayIcon:SetTexture(nil)
			vDayIcon:Hide()
		end
		
		-- Show or hide the birthday icon
		
		if vShowBirthdayIcon then
			vOverlayIcon:SetTexture(GroupCalendar.GetEventTypeIconPath("Birth"))
			vOverlayIcon:Show()
		else
			vOverlayIcon:Hide()
		end
		
		-- Circle the date if necessary
		
		if vHasAppointment then
			vCircledDate:Show()
			vCircledDate:SetAlpha(tern(vAppointmentIsDimmed, 0.4, 1.0))
			
			if vAppointmentIsStandby then
				vCircledDate:SetVertexColor(0.5, 0.5, 1)
			elseif vAppointmentIsMaybe then
				vCircledDate:SetVertexColor(0.8, 0.8, 0.8)
			elseif vAppointmentIsConfirmed then
				vCircledDate:SetVertexColor(0, 1, 0)
			else
				vCircledDate:SetVertexColor(1, 1, 0)
			end
		else
			vCircledDate:Hide()
		end
		
		-- Show the dog ear
		
		if vResetEventType
		or vExpiredResetEventType then
			if not vResetEventType then
				vResetEventType = vExpiredResetEventType
			end
			
			local vIconCoords = GroupCalendar.Database.GetResetIconCoords(vResetEventType)
			
			if vIconCoords then
				vDogEarIcon:SetTexCoord(vIconCoords.left, vIconCoords.right, vIconCoords.top, vIconCoords.bottom)
				vDogEarIcon:Show()
			else
				vDogEarIcon:Hide()
			end
		else
			vDogEarIcon:Hide()
		end
	else -- if pCompiledSchedule
		vDayIcon:SetTexture(nil)
		vDayIcon:Hide()
	end
	
	GroupCalendar.DeleteTable(vDayButton.Schedule, 1)
	vDayButton.Schedule = pCompiledSchedule
end

function GroupCalendar.GetCurrentCutoffDateTime()
	local vCurrentDate, vCurrentTime
	local vCurrentServerDateTime
	
	if gGroupCalendar_Settings.ShowEventsInLocalTime then
		local vServerDate, vServerTime
		
		vCurrentDate, vCurrentTime = MCDateLib:GetLocalDateTime()
		vServerDate, vServerTime = MCDateLib:GetServerDateTimeFromLocalDateTime(vCurrentDate, vCurrentTime)
		vCurrentServerDateTime = vServerDate * GroupCalendar.cMinutesPerDay + vServerTime
	else
		vCurrentDate, vCurrentTime = MCDateLib:GetServerDateTime()
		vCurrentServerDateTime = vCurrentDate * GroupCalendar.cMinutesPerDay + vCurrentTime
	end
	
	return vCurrentDate, vCurrentTime, vCurrentServerDateTime
end

function GroupCalendar.UpdateEventIcons()
	local vIndex = GroupCalendar.Calendar.StartDayOfWeek
	local vCurrentDate, vCurrentTime, vCurrentServerDateTime = GroupCalendar.GetCurrentCutoffDateTime()
	
	for vDate = GroupCalendar.Calendar.StartDate, GroupCalendar.Calendar.EndDate - 1 do
		local vCompiledSchedule = GroupCalendar.Database.GetCompiledSchedule(vDate, true)
		local vCutoffDateTime = nil
		
		if vDate == vCurrentDate then
			vCutoffDateTime = vCurrentServerDateTime
		end
		
		GroupCalendar.SetDateButtonSchedule(vDate, vCompiledSchedule, vCutoffDateTime)
		
		vIndex = vIndex + 1
	end
end

function GroupCalendar.ScheduleChanged(pDate, pSchedule)
	if not GroupCalendarFrame:IsVisible() then
		return
	end
	
	local vCompiledSchedule = GroupCalendar.Database.GetCompiledSchedule(pDate, true)
	local vCurrentDate, vCurrentTime, vCurrentServerDateTime = GroupCalendar.GetCurrentCutoffDateTime()
	local vCutoffDateTime = nil
	
	if pDate == vCurrentDate then
		vCutoffDateTime = vCurrentServerDateTime
	end
	
	GroupCalendar.SetDateButtonSchedule(pDate, vCompiledSchedule, vCutoffDateTime)
end

function GroupCalendar.Calendar.MajorDatabaseChange()
	if not GroupCalendarFrame:IsVisible() then
		return
	end
	
	GroupCalendar.UpdateEventIcons()
end

function GroupCalendar.NextMonth()
	local vMonth, vDay, vYear = GroupCalendar.ConvertDateToMDY(GroupCalendar.Calendar.StartDate)
	
	vMonth = vMonth + 1
	
	if vMonth == 13 then
		vMonth = 1
		vYear = vYear + 1
	end
	
	GroupCalendar.Calendar:SetDisplayDate(GroupCalendar.ConvertMDYToDate(vMonth, 1, vYear))
end

function GroupCalendar.PreviousMonth()
	local vMonth, vDay, vYear = GroupCalendar.ConvertDateToMDY(GroupCalendar.Calendar.StartDate)
	
	vMonth = vMonth - 1
	
	if vMonth == 0 then
		vMonth = 12
		vYear = vYear - 1
	end
	
	GroupCalendar.Calendar:SetDisplayDate(GroupCalendar.ConvertMDYToDate(vMonth, 1, vYear))
end

function GroupCalendar.Today()
	local vMonth, vDay, vYear = GroupCalendar.ConvertDateToMDY(GroupCalendar.Calendar.ActualDate)
	
	GroupCalendar.Calendar:SetDisplayDate(GroupCalendar.ConvertMDYToDate(vMonth, 1, vYear))
	GroupCalendar_SelectDateWithToggle(GroupCalendar.Calendar.ActualDate)
end

function GroupCalendar.SetCalendarRange(pStartDay, pNumDays, pStartDate)
	-- Hide days before the start day
	
	GroupCalendar.Calendar.StartDayOfWeek = pStartDay
	
	for vIndex = 0, pStartDay - 1 do
		local vDayButton = getglobal("GroupCalendarDay"..vIndex)
		vDayButton:Hide()
	end
	
	-- Set the text of the days
	
	for vIndex = pStartDay, pStartDay + pNumDays - 1 do
		local vDayNumber = vIndex - pStartDay + 1
		
		local vDayButton = getglobal("GroupCalendarDay"..vIndex)
		local vDayIcon = getglobal("GroupCalendarDay"..vIndex.."Icon")
		local vDayText = getglobal("GroupCalendarDay"..vIndex.."Name")
		
		vDayButton:Show()
		vDayText:SetText(vDayNumber)
		
		local vDate = pStartDate + (vIndex - pStartDay)
		local vDateHighlight = getglobal("GroupCalendarDay"..vIndex.."HighlightIcon")
		
		UIFrameFlashRemoveFrame(vDateHighlight)
		
		if GroupCalendar.NewEvents[vDate] then
			UIFrameFlash(vDateHighlight, 0.5, 0.5, 60 * 60, false, 0, 0)
		else
			vDateHighlight:Hide()
		end
	end
	
	-- Hide the days after the end day
	
	for vIndex = pStartDay + pNumDays, 36 do
		local vDayButton = getglobal("GroupCalendarDay"..vIndex)
		vDayButton:Hide()
	end
end

function GroupCalendar.GetDaysInMonth(pMonth, pYear)
	if pMonth == 2 and GroupCalendar.IsLeapYear(pYear) then
		return gDaysInMonth[pMonth] + 1
	else
		return gDaysInMonth[pMonth]
	end
end

function GroupCalendar.GetDaysToMonth(pMonth, pYear)
	if pMonth > 2 and GroupCalendar.IsLeapYear(pYear) then
		return gDaysToMonth[pMonth] + 1
	elseif pMonth == 2 then
		return gDaysToMonth[pMonth]
	else
		return 0
	end
end

function GroupCalendar.GetDaysInYear(pYear)
	if GroupCalendar.IsLeapYear(pYear) then
		return 366
	else
		return 365
	end
end

function GroupCalendar.IsLeapYear(pYear)
	return (math.mod(pYear, 400) == 0)
	   or ((math.mod(pYear, 4) == 0) and (math.mod(pYear, 100) ~= 0))
end

function GroupCalendar.GetDaysToDate(pMonth, pDay, pYear)
	local vDays
	
	vDays = gDaysToMonth[pMonth] + pDay - 1
	
	if GroupCalendar.IsLeapYear(pYear) and pMonth > 2 then
		vDays = vDays + 1
	end
	
	return vDays
end

function GroupCalendar.ConvertMDYToDate(pMonth, pDay, pYear)
	local vDays = 0
	
	for vYear = 2000, pYear - 1 do
		vDays = vDays + GroupCalendar.GetDaysInYear(vYear)
	end
	
	return vDays + GroupCalendar.GetDaysToDate(pMonth, pDay, pYear)
end

function GroupCalendar.ConvertDateToMDY(pDate)
	if not pDate then
		GroupCalendar:DebugMessage("ConvertDateToMDY: pDate is nil")
		GroupCalendar:DebugStack()
		return
	end
	
	local vDays = pDate
	local vYear = 2000
	local vDaysInYear = GroupCalendar.GetDaysInYear(vYear)
	
	while vDays >= vDaysInYear do
		vDays = vDays - vDaysInYear

		vYear = vYear + 1
		vDaysInYear = GroupCalendar.GetDaysInYear(vYear)
	end
	
	local vIsLeapYear = GroupCalendar.IsLeapYear(vYear)
	
	for vMonth = 1, 12 do
		local vDaysInMonth = gDaysInMonth[vMonth]
		
		if vMonth == 2 and vIsLeapYear then
			vDaysInMonth = vDaysInMonth + 1
		end
		
		if vDays < vDaysInMonth then
			return vMonth, vDays + 1, vYear
		end
		
		vDays = vDays - vDaysInMonth
	end
	
	-- error
	
	GroupCalendar:DebugMessage("ConvertDateToMDY failed: "..vDays.." unaccounted for in year "..vYear)

	return 0, 0, 0
end

function GroupCalendar.GetDayOfWeek(pMonth, pDay, pYear)
	local vDayOfWeek = 6 -- January 1, 2000 is a Saturday
	
	for vYear = 2000, pYear - 1 do
		if GroupCalendar.IsLeapYear(vYear) then
			vDayOfWeek = vDayOfWeek + 2
		else
			vDayOfWeek = vDayOfWeek + 1
		end
	end
	
	vDayOfWeek = vDayOfWeek + GroupCalendar.GetDaysToDate(pMonth, pDay, pYear)
	
	return math.mod(vDayOfWeek, 7)
end

function GroupCalendar.GetDayOfWeekFromDate(pDate)
	return math.mod(pDate + 6, 7)  -- + 6 because January 1, 2000 is a Saturday
end

function CalendarHourDropDown_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarHourDropDown_Initialize)
end

function CalendarMinuteDropDown_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarMinuteDropDown_Initialize)
end

function CalendarAMPMDropDown_OnLoad()
	if TwentyFourHourTime then
		this:Hide()
	else
		GroupCalendar.UIDropDownMenu_Initialize(this, CalendarAMPMDropDown_Initialize)
	end
end

function CalendarEventTypeDropDown_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarEventTypeDropDown_Initialize)
end

function CalendarConfigModeDropDown_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarConfigModeDropDown_Initialize)
end

function CalendarGuildRank_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarGuildRankDropDown_Initialize)
end

function CalendarRoleMenu_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarRoleDropDown_Initialize)
end

function CalendarPartySizeDropDown_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarPartySizeDropDown_Initialize)
end

function CalendarPriorityDropDown_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarPriorityDropDown_Initialize)
	--UIDropDownMenu_SetWidth(130)
end

function CalendarCharactersDropDown_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarCharactersDropDown_Initialize)
	-- UIDropDownMenu_Refresh(this)
end

function CalendarAttendanceDropDown_OnLoad()
	UIDropDownMenu_SetAnchor(-1, 4, this, "TOPLEFT", this:GetName(), "TOPRIGHT")
	UIDropDownMenu_Initialize(this, CalendarAttendanceDropDown_Initialize)
--	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarAttendanceDropDown_Initialize)
end

function CalendarClassDropDown_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarClassDropDown_Initialize)
end

function CalendarRaceDropDown_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarRaceDropDown_Initialize)
end

function CalendarStatusDropDown_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarStatusDropDown_Initialize)
end

function CalendarAutoConfirmDropDown_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarAutoConfirmDropDown_Initialize)
end

function CalendarAutoConfirmDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cManualConfirmationTitle, "MAN")
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cAutoConfirmationTitle, "AUT")
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cRoleConfirmationTitle, "ROLE")
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cClosedEventTitle, "CLOSED")
end

function CalendarHourDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	local vStartHour, vEndHour
	
	if TwentyFourHourTime then
		vStartHour = 0
		vEndHour = 23
	else
		vStartHour = 1
		vEndHour = 12
	end
	
	for vIndex = vStartHour, vEndHour do
		vItem = {}
		vItem.text = ""..vIndex
		vItem.value = vIndex
		vItem.owner = vFrame
		vItem.func = CalendarDropDown_OnClick
		UIDropDownMenu_AddButton(vItem)
	end
end

function CalendarMinuteDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	for vIndex = 0, 59, 5 do
		vItem = {}
		if vIndex < 10 then
			vItem.text = "0"..vIndex
		else
			vItem.text = ""..vIndex
		end
		
		vItem.value = vIndex
		vItem.owner = vFrame
		vItem.func = CalendarDropDown_OnClick
		
		UIDropDownMenu_AddButton(vItem)
	end
end

function CalendarAMPMDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	--
	
	local vItem = {}
	vItem.text = "AM"
	vItem.value = 0
	vItem.owner = vFrame
	vItem.func = CalendarDropDown_OnClick

	UIDropDownMenu_AddButton(vItem)
	
	--
	
	local vItem = {}
	vItem.text = "PM"
	vItem.value = 1
	vItem.owner = vFrame
	vItem.func = CalendarDropDown_OnClick

	UIDropDownMenu_AddButton(vItem)
end

function CalendarDurationDropDown_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, CalendarDurationDropDown_Initialize)
end

function CalendarDurationDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	--
	
	local vDurations = {15, 30, 60, 90, 120, 150, 180, 210, 240, 300, 360}

	for _, vDuration in ipairs(vDurations) do
		local vItem = {}

		local vMinutes = math.mod(vDuration, 60)
		local vHours = (vDuration - vMinutes) / 60

		if vHours == 0 then
			vItem.text = format(GroupCalendar_cPluralMinutesFormat, vMinutes)
		else
			if vMinutes ~= 0 then
				if vHours == 1 then
					vItem.text = format(GroupCalendar_cSingularHourPluralMinutes, vHours, vMinutes)
				else
					vItem.text = format(GroupCalendar_cPluralHourPluralMinutes, vHours, vMinutes)
				end
			else
				if vHours == 1 then
					vItem.text = format(GroupCalendar_cSingularHourFormat, vHours)
				elseif vHours > 0 then
					vItem.text = format(GroupCalendar_cPluralHourFormat, vHours)
				end
			end
		end
		
		vItem.value = vDuration
		vItem.owner = vFrame
		vItem.func = CalendarDropDown_OnClick

		UIDropDownMenu_AddButton(vItem)
	end
end

function GroupCalendar.AddDividerMenuItem()
	UIDropDownMenu_AddButton({text = " ", notCheckable = true, notClickable = true})
end

function GroupCalendar.AddCategoryMenuItem(pName)
	UIDropDownMenu_AddButton({text = pName, notCheckable = true, notClickable = true})
end

function GroupCalendar.AddMenuItem(pFrame, pName, pValue, pChecked, pLevel)
	UIDropDownMenu_AddButton({text = pName, value = pValue, owner = pFrame, checked = pChecked, func = CalendarDropDown_OnClick, textR = NORMAL_FONT_COLOR.r, textG = NORMAL_FONT_COLOR.g, textB = NORMAL_FONT_COLOR.b}, pLevel)
end

function GroupCalendar.AddMenuItem2(pFrame, pName, pValue, pChecked, pLevel)
	UIDropDownMenu_AddButton({text = pName, value = pValue, owner = pFrame, checked = pChecked, func = CalendarDropDown_OnClick2, textR = NORMAL_FONT_COLOR.r, textG = NORMAL_FONT_COLOR.g, textB = NORMAL_FONT_COLOR.b}, pLevel)
end

function CalendarEventTypeDropDown_AddEventGroupSubMenu(pFrame, pEventGroupName)
	local vEventTypes = GroupCalendar.EventTypes[pEventGroupName]
	
	local vItem = {}

	vItem.text = vEventTypes.Title
	vItem.owner = pFrame
	vItem.hasArrow = 1
	--vItem.notCheckable = 1
	vItem.value = pEventGroupName
	vItem.func = nil

	UIDropDownMenu_AddButton(vItem)
end

function CalendarEventTypeDropDown_AddEventTypes(pFrame, pEventGroupName, pMenuLevel)
	local vEventTypes = GroupCalendar.EventTypes[pEventGroupName]
	
	for vIndex, vEventItem in ipairs(vEventTypes.Events) do
		local vItem = {}

		vItem.text = vEventItem.name
		vItem.value = vEventItem.id
		vItem.owner = pFrame
		vItem.func = CalendarDropDown_OnClick

		UIDropDownMenu_AddButton(vItem, pMenuLevel)
	end
end

function CalendarEventTypeDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	if UIDROPDOWNMENU_MENU_LEVEL == 2 then
		CalendarEventTypeDropDown_AddEventTypes(vFrame, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL)
	else
		-- Populate the root menu items
		
		UIDropDownMenu_AddButton({text = GroupCalendar_cNone, value = "NONE", owner = vFrame, func = CalendarDropDown_OnClick, textR = HIGHLIGHT_FONT_COLOR.r, textG = HIGHLIGHT_FONT_COLOR.g, textB = HIGHLIGHT_FONT_COLOR.b})
		CalendarEventTypeDropDown_AddEventTypes(vFrame, "General")
		GroupCalendar.AddDividerMenuItem(vFrame)
		CalendarEventTypeDropDown_AddEventGroupSubMenu(vFrame, "Personal")
		CalendarEventTypeDropDown_AddEventGroupSubMenu(vFrame, "Raid")
		CalendarEventTypeDropDown_AddEventGroupSubMenu(vFrame, "Dungeon")
		CalendarEventTypeDropDown_AddEventGroupSubMenu(vFrame, "OutdoorRaids")
		CalendarEventTypeDropDown_AddEventGroupSubMenu(vFrame, "Battleground")
	end
end

function CalendarConfigModeDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	if not GroupCalendar.PlayerSettings then
		return
	end
	
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cAutoChannelConfig, "CONFIG_AUTO")
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cManualChannelConfig, "CONFIG_MANUAL")
	if IsInGuild() and CanEditGuildInfo() then
		GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cAdminChannelConfig, "CONFIG_ADMIN")
	end
end

function CalendarGuildRankDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	local vNumRanks = GuildControlGetNumRanks()
	
	for vIndex = 1, vNumRanks do
		local vRankName = GuildControlGetRankName(vIndex)
		local vItem = {}

		vItem.text = vRankName
		vItem.value = vIndex - 1
		vItem.owner = vFrame
		vItem.func = CalendarDropDown_OnClick

		UIDropDownMenu_AddButton(vItem)
	end
end

function CalendarRoleDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	UIDropDownMenu_AddButton(
	{
		text = GroupCalendar_cUnknown,
		value = "?",
		owner = vFrame,
		func = CalendarDropDown_OnClick
	})
	
	for vIndex = 1, table.getn(GroupCalendar.Roles) do
		local vRoleInfo = GroupCalendar.Roles[vIndex]
		
		if not vFrame.RoleLimits
		or not vFrame.RoleLimits[vRoleInfo.ID]
		or vFrame.RoleLimits[vRoleInfo.ID].mMax ~= 0 then
			UIDropDownMenu_AddButton(
			{
				text = vRoleInfo.Name,
				value = vRoleInfo.ID,
				owner = vFrame,
				func = CalendarDropDown_OnClick
			})
		end
	end
end

function CalendarPartySizeDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	local vSizes = {0, 5, 10, 15, 20, 25, 40}
	
	for vIndex, vSize in ipairs(vSizes) do
		local vText = vSize
		
		if vText == 0 then
			vText = GroupCalendar_cNoMaximum
		else
			vText = format(GroupCalendar_cPartySizeFormat, vSize)
		end
		
		UIDropDownMenu_AddButton({text = vText, value = vSize, owner = vFrame, func = CalendarDropDown_OnClick})
	end
end

function CalendarPriorityDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cPriorityDate, "Date")
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cPriorityRank, "Rank")
end

function CalendarCharactersDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	local vOwnedDatabases = GroupCalendar.Database.GetOwnedDatabases()
	
	for vIndex, vDatabase in ipairs(vOwnedDatabases) do
		local vItem = {}
		
		vItem.text = vDatabase.UserName
		vItem.value = vDatabase.UserName
		vItem.owner = vFrame
		vItem.func = CalendarDropDown_OnClick

		UIDropDownMenu_AddButton(vItem)
	end
end

function CalendarAttendanceDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	local vAttendanceItem = vFrame:GetParent()
	local vItem = vAttendanceItem.Item
	
	if vItem then
		if vItem.mType == "Whisper" then
			GroupCalendar.AddCategoryMenuItem(vItem.mName)
			GroupCalendar.AddMenuItem2(vFrame, GroupCalendar_cAddPlayerEllipses, "ADD")
			GroupCalendar.AddMenuItem2(vFrame, GroupCalendar_cRemove, "DELETE")
		else
			GroupCalendar.AddCategoryMenuItem(vItem.mName)
			GroupCalendar.AddMenuItem2(vFrame, GroupCalendar_cEditPlayer, "EDIT")
			GroupCalendar.AddMenuItem2(vFrame, GroupCalendar_cRemove, "DELETE")
			GroupCalendar.AddCategoryMenuItem(GroupCalendar_cStatus)
			GroupCalendar.AddMenuItem2(vFrame, GroupCalendar_cConfirmed, "Y")
			GroupCalendar.AddMenuItem2(vFrame, GroupCalendar_cStandby, "S")
			GroupCalendar.AddMenuItem2(vFrame, GroupCalendar_cDeclined, "N")
			GroupCalendar.AddMenuItem2(vFrame, GroupCalendar_cBanned, "-")
		end
	end
	
	vFrame:SetHeight(20)
end

function CalendarClassDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	local vItem = {}

	vItem.text = GroupCalendar_cUnknown
	vItem.value = "?"
	vItem.owner = vFrame
	vItem.func = CalendarDropDown_OnClick

	UIDropDownMenu_AddButton(vItem)
	
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		if not vClassInfo.faction
		or vClassInfo.faction == GroupCalendar.PlayerFactionGroup then
			local vItem = {}
			
			vItem.text = vClassInfo.maleName
			vItem.value = vClassCode
			vItem.owner = vFrame
			vItem.func = CalendarDropDown_OnClick

			UIDropDownMenu_AddButton(vItem)
		end
	end
end

function CalendarRaceDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	local vItem = {}

	vItem.text = GroupCalendar_cUnknown
	vItem.value = "?"
	vItem.owner = vFrame
	vItem.func = CalendarDropDown_OnClick

	UIDropDownMenu_AddButton(vItem)
	
	for vRaceCode, vRaceInfo in pairs(GroupCalendar.RaceNamesByRaceCode) do
		if vRaceInfo.faction == GroupCalendar.PlayerFactionGroup then
			local vItem = {}

			vItem.text = vRaceInfo.name
			vItem.value = vRaceCode
			vItem.owner = vFrame
			vItem.func = CalendarDropDown_OnClick

			UIDropDownMenu_AddButton(vItem)
		end
	end
end

function CalendarStatusDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	vItem = {text = GroupCalendar_cConfirmed, value = "Y", owner = vFrame, func = CalendarDropDown_OnClick}
	UIDropDownMenu_AddButton(vItem)
	
	vItem = {text = GroupCalendar_cStandby, value = "S", owner = vFrame, func = CalendarDropDown_OnClick}
	UIDropDownMenu_AddButton(vItem)
	
	vItem = {text = CalendarEventEditor_cNotAttending, value = "N", owner = vFrame, func = CalendarDropDown_OnClick}
	UIDropDownMenu_AddButton(vItem)
	
	vItem = {text = GroupCalendar_cBanned, value = "-", owner = vFrame, func = CalendarDropDown_OnClick}
	UIDropDownMenu_AddButton(vItem)
end

function GroupCalendarViewMenu_OnLoad()
	GroupCalendar.UIDropDownMenu_Initialize(this, GroupCalendarViewMenu_Initialize)
end

function GroupCalendarViewMenu_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	GroupCalendar.AddCategoryMenuItem(GroupCalendar_cViewGroupBy)
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cViewByRole, "Role", vFrame.ListGroupMode == "Role")
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cViewByClass, "Class", vFrame.ListGroupMode == "Class")
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cViewByStatus, "Status", vFrame.ListGroupMode == "Status")
	
	GroupCalendar.AddCategoryMenuItem(GroupCalendar_cViewSortBy)
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cViewByDate, "Date", vFrame.ListSortMode == "Date")
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cViewByRank, "Rank", vFrame.ListSortMode == "Rank")
	GroupCalendar.AddMenuItem(vFrame, GroupCalendar_cViewByName, "Name", vFrame.ListSortMode == "Name")
end

function CalendarDropDown_OnClick()
	CalendarDropDown_SetSelectedValue(this.owner, this.value)
	CalendarDropDown_OnClick2()
end

function CalendarDropDown_OnClick2()
	if this.owner.ChangedValueFunc then
		this.owner.ChangedValueFunc(this.owner, this.value)
	end
	
	CloseDropDownMenus()
end

function GroupCalendar.SetEditBoxAutoCompleteText(pEditBox, pText)
	local vEditBoxText = strupper(pEditBox:GetText())
	local vEditBoxTextLength = strlen(vEditBoxText)
	
	pEditBox:SetText(pText)
	pEditBox:HighlightText(vEditBoxTextLength, -1)
end

function GroupCalendar.AutoCompletePlayerName(pEditBox)
	if GroupCalendar.AutoCompleteFriend(pEditBox) then
		return true
	end
	
	return GroupCalendar.AutoCompleteGuildMember(pEditBox)
end

function GroupCalendar.AutoCompleteAlt(pEditBox)
	local vEditBoxText = string.upper(pEditBox:GetText())
	local vEditBoxTextLength = string.len(vEditBoxText)
	
	for _, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if vDatabase.IsPlayerOwned
		and vDatabase.Realm == GroupCalendar.RealmName
		and vDatabase.Faction == GroupCalendar.PlayerFactionGroup then
			if vEditBoxText == string.sub(string.upper(vDatabase.UserName), 1, vEditBoxTextLength) then
				GroupCalendar.SetEditBoxAutoCompleteText(pEditBox, vDatabase.UserName)
				return true
			end
		end
	end
	
	return false
end

function GroupCalendar.AutoCompleteFriend(pEditBox)
	local vNumFriends = GetNumFriends()
	
	if vNumFriends == 0 then
		return false
	end
	
	local vEditBoxText = strupper(pEditBox:GetText())
	local vEditBoxTextLength = strlen(vEditBoxText)
	
	for vIndex = 1, vNumFriends do
		local vName = GetFriendInfo(vIndex)
		
		if strfind(strupper(vName), "^"..vEditBoxText) then
			GroupCalendar.SetEditBoxAutoCompleteText(pEditBox, vName)
			return true
		end
	end
	
	return false
end

function GroupCalendar.AutoCompleteGuildMember(pEditBox)
	local vNumMembers = GetNumGuildMembers(true)
	
	if vNumMembers == 0 then
		return false
	end
	
	local vEditBoxText = strupper(pEditBox:GetText())
	local vEditBoxTextLength = strlen(vEditBoxText)
	
	for vIndex = 1, vNumMembers do
		local vName = GetGuildRosterInfo(vIndex)
		
		if strfind(strupper(vName), "^"..vEditBoxText) then
			GroupCalendar.SetEditBoxAutoCompleteText(pEditBox, vName)
			return true
		end
	end
	
	return false
end

function GroupCalendar.UpgradeEventTemplates()
	GroupCalendar.PlayerSettings.SavedTemplates = {}
	
	-- Copy over the old templates
	
	if GroupCalendar.PlayerSettings.EventTemplates then
		for vEventType, vTemplate in pairs(GroupCalendar.PlayerSettings.EventTemplates) do
			GroupCalendar.SaveEventTemplate(vTemplate)
		end
		
		GroupCalendar.PlayerSettings.EventTemplates = nil
	end
	
	--
	
	if GroupCalendar.PlayerSettings.EventTemplates2 then
		for vEventType, vTemplates in pairs(GroupCalendar.PlayerSettings.EventTemplates2) do
			for _, vTemplate in ipairs(vTemplates) do
				GroupCalendar.SaveEventTemplate(vTemplate)
			end
		end
		
		GroupCalendar.PlayerSettings.EventTemplates2 = nil
	end
end

function GroupCalendar.FindEventTemplateByTitle(pTitle)
	if not GroupCalendar.PlayerSettings.SavedTemplates then
		GroupCalendar.UpgradeEventTemplates()
	end
	
	local vUpperTitle = string.upper(pTitle)
	
	for vIndex, vTemplate in ipairs(GroupCalendar.PlayerSettings.SavedTemplates) do
		local vTemplateTitle = GroupCalendar.Database.GetEventDisplayName(vTemplate)
		local vTemplateUpperTitle = string.upper(vTemplateTitle)
		
		if vTemplateUpperTitle == vUpperTitle then
			return vTemplate, vIndex
		end
	end
end

function GroupCalendar.FindEventTemplateByPartialTitle(pTitle)
	if not GroupCalendar.PlayerSettings.SavedTemplates then
		GroupCalendar.UpgradeEventTemplates()
	end
	
	local vUpperTitle = string.upper(pTitle)
	local vUpperTitleLen = string.len(vUpperTitle)
	
	for vIndex, vTemplate in ipairs(GroupCalendar.PlayerSettings.SavedTemplates) do
		local vTemplateTitle = GroupCalendar.Database.GetEventDisplayName(vTemplate)
		local vTemplateUpperTitle = string.upper(vTemplateTitle)
		
		if string.sub(vTemplateUpperTitle, 1, vUpperTitleLen) == vUpperTitle then
			return vTemplate, vIndex
		end
	end
end

function GroupCalendar.SaveEventTemplate(pTemplate)
	if not GroupCalendar.PlayerSettings.SavedTemplates then
		GroupCalendar.UpgradeEventTemplates()
	end
	
	local vTitle = GroupCalendar.Database.GetEventDisplayName(pTemplate)
	
	local vOldTemplate, vOldIndex = GroupCalendar.FindEventTemplateByTitle(vTitle)
	
	if vOldTemplate then
		table.remove(GroupCalendar.PlayerSettings.SavedTemplates, vOldIndex)
	end
	
	table.insert(GroupCalendar.PlayerSettings.SavedTemplates, 1, pTemplate)

	while table.getn(GroupCalendar.PlayerSettings.SavedTemplates) > 20 do
		table.remove(GroupCalendar.PlayerSettings.SavedTemplates, table.getn(GroupCalendar.PlayerSettings.SavedTemplates))
	end
end

function GroupCalendar.AutoCompleteEventTitle(pEditBox)
	local vEditBoxText = pEditBox:GetText()
	local vUpperEditBoxText = string.upper(vEditBoxText)
	local vUpperEditBoxTextLen = string.len(vUpperEditBoxText)
	
	if not GroupCalendar.PlayerSettings.SavedTemplates then
		GroupCalendar.UpgradeEventTemplates()
	end
	
	local vTemplate = GroupCalendar.FindEventTemplateByPartialTitle(vEditBoxText)
	
	if vTemplate then
		GroupCalendar.SetEditBoxAutoCompleteText(pEditBox, GroupCalendar.Database.GetEventDisplayName(vTemplate))
		return nil, vTemplate
	end
	
	for vCategory, vCategoryInfo in pairs(GroupCalendar.EventTypes) do
		if vCategoryInfo.Title then -- Only player-choosable events have titles
			for _, vEvent in ipairs(vCategoryInfo.Events) do
				if string.sub(string.upper(vEvent.name), 1, vUpperEditBoxTextLen) == vUpperEditBoxText then
					GroupCalendar.SetEditBoxAutoCompleteText(pEditBox, vEvent.name)
					return vEvent.id
				end
			end
		end
	end
end
	
function GroupCalendar.InputFrameSizeChanged(pInputFrame)
	local vName = this:GetName()
	local vWidth = pInputFrame:GetWidth()
	local vHeight = pInputFrame:GetHeight()
	
	local vTopLeft = getglobal(vName.."TopLeft")
	local vTop = getglobal(vName.."Top")
	local vTopRight = getglobal(vName.."TopRight")

	local vLeft = getglobal(vName.."Left")
	local vCenter = getglobal(vName.."Center")
	local vRight = getglobal(vName.."Right")

	local vBottomLeft = getglobal(vName.."BottomLeft")
	local vBottom = getglobal(vName.."Bottom")
	local vBottomRight = getglobal(vName.."BottomRight")
	
	local vInnerWidth = vWidth - 12
	local vInnerHeight = vHeight - 12
	
	vTopLeft:SetWidth(6); vTopLeft:SetHeight(6)
	vTop:SetWidth(vInnerWidth); vTop:SetHeight(6)
	vTopRight:SetWidth(6); vTopRight:SetHeight(6)
	
	vLeft:SetWidth(6); vLeft:SetHeight(vInnerHeight)
	vCenter:SetWidth(vInnerWidth); vCenter:SetHeight(vInnerHeight)
	vRight:SetWidth(6); vRight:SetHeight(vInnerHeight)
		
	vBottomLeft:SetWidth(6); vBottomLeft:SetHeight(6)
	vBottom:SetWidth(vInnerWidth); vBottom:SetHeight(6)
	vBottomRight:SetWidth(6); vBottomRight:SetHeight(6)
end

function CalendarPlayerList_OnLoad()
	this.ItemFunction = CalendarPlayerList_NullItemFunction
	this.SelectedIndex = 0
end

function CalendarPlayerList_OnShow()
	CalendarPlayerList_Update(this)
end

function CalendarPlayerList_SetItemFunction(pPlayerListControl, pItemFunction)
	pPlayerListControl.ItemFunction = pItemFunction
end

function CalendarPlayerList_SetSelectionChangedFunction(pPlayerListControl, pSelectionChangedFunction)
	pPlayerListControl.SelectionChangedFunction = pSelectionChangedFunction
end

function CalendarPlayerList_SetColor(pPlayerListControl, pRed, pGreen, pBlue)
	local vControlName = pPlayerListControl:GetName()
	local vHighlightFrameTextureName = vControlName.."HighlightFrameTexture"
	local vHighlightFrameTexture = getglobal(vHighlightFrameTextureName)
	
	pPlayerListControl.r = pRed; pPlayerListControl.g = pGreen; pPlayerListControl.b = pBlue
	
	for vIndex = 0, gCalendarPlayerList_cNumVisibleEntries - 1 do
		CalendarPlayerList_SetIndexedItemFrameColor(pPlayerListControl, vIndex, pRed, pGreen, pBlue)
	end
	
	vHighlightFrameTexture:SetVertexColor(pRed, pGreen, pBlue)
end

function CalendarPlayerList_SetIndexedItemFrameColor(pPlayerListControl, pIndex, pRed, pGreen, pBlue)
	local vControlName = pPlayerListControl:GetName()
	local vItemFrameName = vControlName.."Item"..pIndex
	local vItemFrame = getglobal(vItemFrameName)
	local vTextItem = getglobal(vItemFrameName.."Text")
	
	vItemFrame.r = pRed
	vItemFrame.g = pGreen
	vItemFrame.b = pBlue
	
	vTextItem:SetTextColor(pRed, pGreen, pBlue)
end

gCalendarPlayerList_ActiveList = nil

function CalendarPlayerList_ScrollUpdate()
	CalendarPlayerList_Update(gCalendarPlayerList_ActiveList)
end

function CalendarPlayerList_Update(pPlayerListControl)
	local vControlName = pPlayerListControl:GetName()
	local vScrollFrame = getglobal(vControlName.."ScrollFrame")
	local vHighlightFrame = getglobal(vControlName.."HighlightFrame")
	
	local vNumItems = pPlayerListControl.ItemFunction(0)
	
	for vIndex = 0, gCalendarPlayerList_cNumVisibleEntries - 1 do
		local vItemName = vControlName.."Item"..vIndex
		local vItemFrame = getglobal(vItemName)
		
		if vIndex < vNumItems then
			vItemFrame:Show()
		else
			vItemFrame:Hide()
		end
	end

	FauxScrollFrame_Update(
			vScrollFrame,
			vNumItems,
			gCalendarPlayerList_cNumVisibleEntries,
			gCalendarPlayerList_cItemHeight,
			nil,
			nil,
			nil,
			vHighlightFrame,
			130,
			130)
	
	CalendarPlayerList_UpdateItems(pPlayerListControl)
end

function CalendarPlayerList_UpdateItems(pPlayerListControl)
	local vControlName = pPlayerListControl:GetName()
	local vScrollFrame = getglobal(vControlName.."ScrollFrame")
	local vFirstItemOffset = FauxScrollFrame_GetOffset(vScrollFrame)
	
	for vIndex = 0, gCalendarPlayerList_cNumVisibleEntries - 1 do
		local vItem = pPlayerListControl.ItemFunction(vIndex + vFirstItemOffset + 1)
		local vItemName = vControlName.."Item"..vIndex
		local vTextItem = getglobal(vItemName.."Text")
		
		vTextItem:SetText(vItem.Text)
	end
end

function CalendarPlayerList_NullItemFunction(pIndex)
	if pIndex == 0 then
		return 10
	end
	
	return
	{
		Text = "Null item "..pIndex,
	}
end

function CalendarPlayerListItem_OnClick(pItem, pButton)
	local vPlayerListControl = pItem:GetParent()
	
	local vControlName = vPlayerListControl:GetName()
	local vScrollFrame = getglobal(vControlName.."ScrollFrame")
	local vFirstItemOffset = FauxScrollFrame_GetOffset(vScrollFrame)
	
	local vPlayerIndex = pItem:GetID() + vFirstItemOffset + 1
	
	CalendarPlayerList_SelectIndexedPlayer(vPlayerListControl, vPlayerIndex)
end

function CalendarPlayerList_SelectIndexedPlayer(pPlayerListControl, pIndex)
	if not pPlayerListControl then
		GroupCalendar:DebugStack()
	end
	
	local vControlName = pPlayerListControl:GetName()
	local vScrollFrame = getglobal(vControlName.."ScrollFrame")
	local vHighlightFrame = getglobal(vControlName.."HighlightFrame")
	
	-- Remove the old highlighting
	
	if pPlayerListControl.SelectedIndex then
		local vItemFrameIndex = pPlayerListControl.SelectedIndex - FauxScrollFrame_GetOffset(vScrollFrame) - 1
		
		CalendarPlayerList_SetIndexedItemFrameColor(pPlayerListControl, vItemFrameIndex, pPlayerListControl.r, pPlayerListControl.g, pPlayerListControl.b)
	end
	
	-- Show the new highlighting
	
	if pIndex > 0 then
		local vItemFrameIndex = pIndex - FauxScrollFrame_GetOffset(vScrollFrame) - 1
		local vItemFrameName = vControlName.."Item"..vItemFrameIndex
		
		vHighlightFrame:SetPoint("TOPLEFT", vItemFrameName, "TOPLEFT", 5, 0)
		vHighlightFrame:Show()
		
		CalendarPlayerList_SetIndexedItemFrameColor(pPlayerListControl, vItemFrameIndex, 1, 1, 1)
		pPlayerListControl.SelectedIndex = pIndex
	else
		vHighlightFrame:Hide()
		pPlayerListControl.SelectedIndex = nil
	end
	
	if pPlayerListControl.SelectionChangedFunction then
		pPlayerListControl.SelectionChangedFunction(pIndex)
	end
end

function GroupCalendar.GetChangedFieldList(pOldTable, pNewTable)
	local vChangedFields = {}
	
	for vIndex, vNewValue in pairs(pNewTable) do
		local vOldValue = pOldTable[vIndex]
		
		if vOldValue == nil then -- New field
			vChangedFields[vIndex] = "NEW"
		elseif vOldValue ~= vNewValue then -- Changed field
			vChangedFields[vIndex] = "UPD"
		end
	end

	for vIndex, vOldValue in pairs(pOldTable) do
		local vNewValue = pNewTable[vIndex]
		
		if vNewValue == nil then -- Deleted field
			vChangedFields[vIndex] = "DEL"
		end
	end
	
	return vChangedFields
end

-- NOTE: If any regexp characters need to be escaped remember to code them properly
--       Currently those characters are ^$()%.[]*+-?

GroupCalendar.cEscapedCharsRegExp = "([,/:;&|\n])"

GroupCalendar.cUnescapeCharMap =
{
	c = ",",
	s = "/",
	cn = ":",
	sc = ";",
	a = "&",
	b = "|",
	n = "\n",
}

GroupCalendar.cEscapeCharMap = {} -- Generate the reverse map

for vEscapeCode, vChar in pairs(GroupCalendar.cUnescapeCharMap) do
	GroupCalendar.cEscapeCharMap[vChar] = "&"..vEscapeCode..";"
end

function GroupCalendar.EscapeString(pString)
	return string.gsub(pString, GroupCalendar.cEscapedCharsRegExp, function(pChar) return GroupCalendar.cEscapeCharMap[pChar] end)
end

function GroupCalendar.UnescapeString(pString)
	return string.gsub(pString, "&([^;]+);", function(pChar) return GroupCalendar.cUnescapeCharMap[pChar] end)
end

function GroupCalendar.ArrayIsEmpty(pArray)
	if not pArray then
		return true
	end
	
	return next(pArray) == nil
end

GroupCalendar.PrimaryTradeskills =
{
	Herbalism =
	{
		name = GroupCalendar_cHerbalismSkillName
	},
	
	Alchemy =
	{
		name = GroupCalendar_cAlchemySkillName,
		
		cooldownItems =
		{
			[GroupCalendar_cTransmuteMithrilToTruesilver] = "Alchemy",
			[GroupCalendar_cTransmuteIronToGold] = "Alchemy",
			[GroupCalendar_cTransmuteLifeToEarth] = "Alchemy",
			[GroupCalendar_cTransmuteWaterToUndeath] = "Alchemy",
			[GroupCalendar_cTransmuteWaterToAir] = "Alchemy",
			[GroupCalendar_cTransmuteUndeathToWater] = "Alchemy",
			[GroupCalendar_cTransmuteFireToEarth] = "Alchemy",
			[GroupCalendar_cTransmuteEarthToLife] = "Alchemy",
			[GroupCalendar_cTransmuteEarthToWater] = "Alchemy",
			[GroupCalendar_cTransmuteAirToFire] = "Alchemy",
			[GroupCalendar_cTransmuteArcanite] = "Alchemy",
		}
	},
	Enchanting =
	{
		name = GroupCalendar_cEnchantingSkillName
	},
	Engineering =
	{
		name = GroupCalendar_cEngineeringSkillName,
	},
	Leatherworking =
	{
		name = GroupCalendar_cLeatherworkingSkillName,
	},
	Blacksmithing =
	{
		name = GroupCalendar_cBlacksmithingSkillName,
	},
	Tailoring =
	{
		name = GroupCalendar_cTailoringSkillName,
		cooldownItems =
		{
			[GroupCalendar_cMooncloth] = "Tailoring",
		}
	},
	Mining =
	{
		name = GroupCalendar_cMiningSkillName
	},
	Skinning =
	{
		name = GroupCalendar_cSkinningSkillName
	},
}

function GroupCalendar.LookupTradeskillIDByName(pName)
	for vTradeskillID, vTradeskillInfo in pairs(GroupCalendar.PrimaryTradeskills) do
		if vTradeskillInfo.name == pName then
			return vTradeskillID
		end
	end
	
	return nil
end

----------------------------------------
GroupCalendar.CraftSkillAPI = {}
----------------------------------------

function GroupCalendar.CraftSkillAPI:GetSkillLine()
	local vName, vCurrentLevel, vMaxLevel = GetCraftDisplaySkillLine()
	
	return vName, vCurrentLevel, vMaxLevel
end

function GroupCalendar.CraftSkillAPI:GetNumSkills()
	return GetNumCrafts()
end

function GroupCalendar.CraftSkillAPI:GetSkillInfo(pIndex)
	local vCraftName, vCraftSubSpellName, vCraftType, vNumAvailable, vIsExpanded, vTrainingPointCost, vRequiredLevel = GetCraftInfo(pIndex)
	
	return vCraftName, vCraftType, vNumAvailable, vIsExpanded
end

function GroupCalendar.CraftSkillAPI:GetSkillCooldown(pIndex)
	return GetCraftCooldown(pIndex)
end

----------------------------------------
GroupCalendar.TradeSkillAPI = {}
----------------------------------------

function GroupCalendar.TradeSkillAPI:GetSkillLine()
	local vName, vCurrentLevel, vMaxLevel = GetTradeSkillLine()
	
	return vName, vCurrentLevel, vMaxLevel
end

function GroupCalendar.TradeSkillAPI:GetNumSkills()
	return GetNumTradeSkills()
end

function GroupCalendar.TradeSkillAPI:GetSkillInfo(pIndex)
	local vSkillName, vSkillType, vNumAvailable, vIsExpanded = GetTradeSkillInfo(pIndex)
	
	return vSkillName, vSkillType, vNumAvailable, vIsExpanded
end

function GroupCalendar.TradeSkillAPI:GetSkillCooldown(pIndex)
	return GetTradeSkillCooldown(pIndex)
end

----------------------------------------
----------------------------------------

function GroupCalendar.GetTradeskillCooldowns(pTradeskillID)
	local vCooldowns = GroupCalendar.GetSkillCooldowns(pTradeskillID, GroupCalendar.TradeSkillAPI)
	
	if vCooldowns then
		return vCooldowns
	end
	
	return GroupCalendar.GetSkillCooldowns(pTradeskillID, GroupCalendar.CraftSkillAPI)
end

function GroupCalendar.GetSkillCooldowns(pTradeskillID, pSkillAPI)
	local vNumSkills = pSkillAPI:GetNumSkills()
	local vCooldownItems = GroupCalendar.PrimaryTradeskills[pTradeskillID].cooldownItems
	
	if not vCooldownItems then
		return nil
	end
	
	local vCooldowns
	
	for vSkillIndex = 1, vNumSkills do
		local vSkillName, vSkillType, vNumAvailable, vIsExpanded = pSkillAPI:GetSkillInfo(vSkillIndex)
		local vCooldownID = vCooldownItems[vSkillName]
		
		if vCooldownID then
			if not vCooldowns then
				vCooldowns = {}
			end
			
			if not vCooldowns[vCooldownID] then
				local vCooldown = pSkillAPI:GetSkillCooldown(vSkillIndex)
				
				vCooldowns[vCooldownID] = vCooldown
			end
		end
	end
	
	return vCooldowns
end

function CalendarInputBox_OnLoad(pChildDepth)
	if not pChildDepth then
		pChildDepth = 0
	end
	
	local vParent = this:GetParent()
	
	for vDepthIndex = 1, pChildDepth do
		vParent = vParent:GetParent()
	end
	
	if vParent.lastEditBox then
		this.prevEditBox = vParent.lastEditBox
		this.nextEditBox = vParent.lastEditBox.nextEditBox
		
		this.prevEditBox.nextEditBox = this
		this.nextEditBox.prevEditBox = this
	else
		this.prevEditBox = this
		this.nextEditBox = this
	end

	vParent.lastEditBox = this
end

function CalendarInputBox_TabPressed()
	local vReverse = IsShiftKeyDown()
	local vEditBox = this
	
	for vIndex = 1, 50 do
		local vNextEditBox
			
		if vReverse then
			vNextEditBox = vEditBox.prevEditBox
		else
			vNextEditBox = vEditBox.nextEditBox
		end
		
		if vNextEditBox:IsVisible()
		and not vNextEditBox.isDisabled then
			vNextEditBox:SetFocus()
			return
		end
		
		vEditBox = vNextEditBox
	end
end

function GroupCalendarSidePanel_Show(pDesc)
	-- Hide an existing panel
	
	GroupCalendarSidePanel_Hide()
	
	-- Show the new state
	
	GroupCalendarSidePanel.Desc = pDesc
	
	GroupCalendarSidePanelTitle:SetText(GroupCalendarSidePanel.Desc.Title)
	GroupCalendarSidePanelButton:SetText(GroupCalendarSidePanel.Desc.ButtonTitle)
	
	GroupCalendarSidePanel:Show()
end

function GroupCalendarSidePanel_Hide()
	GroupCalendarSidePanel:Hide()
	
	GroupCalendarSidePanel.Desc = nil
end

function GroupCalendarSidePanel_OnHide()
	if GroupCalendarSidePanel.Desc.CloseFunc then
		GroupCalendarSidePanel.Desc.CloseFunc()
	end
end

function GroupCalendarSideList_Show(pDesc)
	GroupCalendarSidePanel_Show(pDesc)
	GroupCalendarSideList:Show()
	
	GroupCalendarSideList.Desc = pDesc
	
	GroupCalendarSideList.Desc.ListItems:Show()
	GroupCalendarSideList.Desc.ListItems:UpdateItems()
end

function GroupCalendarSideList_Hide()
	GroupCalendarSideList:Hide()
	
	if GroupCalendarSideList.Desc then
		GroupCalendarSideList.Desc.ListItems:Hide()
		GroupCalendarSideList.Desc = nil
	end
	
	GroupCalendarSidePanel_Hide()
end

function GroupCalendarSideList_OnVerticalScroll()
	GroupCalendarSideList.Desc.ListItems:UpdateItems()
end

function GroupCalendarSideList_GetFirstItem()
	return FauxScrollFrame_GetOffset(GroupCalendarSideListScrollFrame) + 1
end

function GroupCalendarSideList_SetNumItems(pNumItems)
	FauxScrollFrame_Update(
			GroupCalendarSideListScrollFrame,
			pNumItems,
			GroupCalendar.cNumPlainAttendanceItems,
			GroupCalendar.cAttendanceItemHeight,
			nil,
			nil,
			nil,
			nil,
			293, 316)
	
	-- Update visible items
	
	local vListName = GroupCalendarSideList.Desc.ListItems:GetName()
	local vLastItemIndex = pNumItems - 1
	
	if vLastItemIndex >= GroupCalendar.cNumPlainAttendanceItems then
		vLastItemIndex = GroupCalendar.cNumPlainAttendanceItems - 1
	end
	
	local vFirstItemIndex = GroupCalendarSideList_GetFirstItem()
	
	for vItemIndex = 0, vLastItemIndex do
		local vItemName = vListName.."Item"..vItemIndex
		local vItem = getglobal(vItemName)
		
		GroupCalendarSideList.Desc.ListItems:UpdateItem(vItemIndex + vFirstItemIndex, vItem, vItemName, vItemIndex)
		vItem:Show()
	end
	
	-- Hide unused items
	
	if pNumItems < GroupCalendar.cNumPlainAttendanceItems then
		for vIndex = pNumItems, GroupCalendar.cNumPlainAttendanceItems - 1 do
			local vItemName = vListName.."Item"..vIndex
			
			getglobal(vItemName):Hide()
		end
	end
end

local gCalendarDisplay_FlashingRemder =
{
	Enabled = false,
	OnDuration = 0.4,
	OffDuration = 0.2,
	FadeDuration = 0.5,
	FlashDuration = 60 * 60,
	ShowIcon = false,
	Icon = nil,
}

function GroupCalendar.Calendar.ShowReminderIcon(pIcon)
	if not pIcon then
		return
	end
	
	gCalendarDisplay_FlashingRemder.ShowIcon = true
	gCalendarDisplay_FlashingRemder.Icon = pIcon
	GroupCalendar.Calendar.UpdateReminderIcon()
end

function GroupCalendar.Calendar.HideReminderIcon()
	gCalendarDisplay_FlashingRemder.ShowIcon = false
	gCalendarDisplay_FlashingRemder.Icon = nil
	GroupCalendar.Calendar.UpdateReminderIcon()
end

function GroupCalendar.Calendar.StartFlashingReminder(pIcon)
	if pIcon then
		GroupCalendar.Calendar.ShowReminderIcon(pIcon)
	end
	
	gCalendarDisplay_FlashingRemder.Enabled = true
	GroupCalendar.Calendar.UpdateReminderIcon()
end

function GroupCalendar.Calendar.StopFlashingReminder()
	gCalendarDisplay_FlashingRemder.Enabled = false
	GroupCalendar.Calendar.UpdateReminderIcon()
end

function GroupCalendar.Calendar.UpdateReminderIcon()
	local vShowNotifyIcon = false
	
	if gCalendarDisplay_FlashingRemder.ShowIcon then
		GroupCalendarNotifyIconLeft:SetTexture(gCalendarDisplay_FlashingRemder.Icon)
		GroupCalendarNotifyIconMiddle:SetTexture(gCalendarDisplay_FlashingRemder.Icon)
		GroupCalendarNotifyIconRight:SetTexture(gCalendarDisplay_FlashingRemder.Icon)
		
		GroupCalendarNotifyIconLeft:Show()
		GroupCalendarNotifyIconMiddle:Show()
		GroupCalendarNotifyIconRight:Show()
		
		vShowNotifyIcon = true
	else
		GroupCalendarNotifyIconLeft:Hide()
		GroupCalendarNotifyIconMiddle:Hide()
		GroupCalendarNotifyIconRight:Hide()
	end
	
	if gCalendarDisplay_FlashingRemder.Enabled then
		GroupCalendarNotifyIconHighlight:Show()
		
		GroupCalendarNotifyIconHighlight:SetVertexColor(1, 0.6, 0.2)
		UIFrameFlashRemoveFrame(GroupCalendarNotifyIconHighlight)
		
		UIFrameFlash(
				GroupCalendarNotifyIconHighlight,
				gCalendarDisplay_FlashingRemder.FadeDuration,
				gCalendarDisplay_FlashingRemder.FadeDuration,
				gCalendarDisplay_FlashingRemder.FlashDuration,
				false,
				gCalendarDisplay_FlashingRemder.OffDuration,
				gCalendarDisplay_FlashingRemder.OnDuration)
		
		vShowNotifyIcon = true
	else
		UIFrameFlashRemoveFrame(GroupCalendarNotifyIconHighlight)
		GroupCalendarNotifyIconHighlight:Hide()
	end

	if vShowNotifyIcon then
		GroupCalendarNotifyIcon:Show()
	else
		GroupCalendarNotifyIcon:Hide()
	end
end

function GroupCalendar.GetUserSchedule(pUserName, pDate)
	local vSchedule = GroupCalendar.NewTable()
	
	vSchedule.Date = GroupCalendar.GetLongDateString(vDate, true)
	
	for vIndex, vCompiledEvent in ipairs(pDateButton.Schedule) do
		local vEventInfo = GroupCalendar.EventInfoByID[vCompiledEvent.mEvent.mType]
		local vLeftText, vRightText, vColor
		
		if vEventInfo and vEventInfo.allDay then
			vLeftText = vEventInfo.name
		else
			local vTime
			
			if gGroupCalendar_Settings.ShowEventsInLocalTime then
				vTime = MCDateLib:GetLocalTimeFromServerTime(vCompiledEvent.mEvent.mTime)
			else
				vTime = vCompiledEvent.mEvent.mTime
			end
			
			vLeftText = GroupCalendar.GetShortTimeString(vTime)
		end
		
		local vOwner
		
		if vCompiledEvent.mRealm ~= GroupCalendar.RealmName then
			vOwner = string.format(GroupCalendar_cForeignRealmFormat, vCompiledEvent.mOwner, vCompiledEvent.mRealm)
		else
			vOwner = vCompiledEvent.mOwner
		end
		
		vRightText = string.format(GroupCalendar_cTooltipScheduleItemFormat, GroupCalendar.Database.GetEventDisplayName(vCompiledEvent.mEvent), vOwner)
		
		local vAttending = GroupCalendar.Database.PlayerIsAttendingEvent(vCompiledEvent.mOwner, vCompiledEvent.mEvent)
		
		if vAttending then
			if vAttending == "CONFIRMED" then
				vColor = GREEN_FONT_COLOR
			elseif vAttending == "REQUESTED_STANDBY"or vAttending == "CONFIRMED_STANDBY" then
				vColor = {r=0.5,g=0.5,b=1}
			elseif vAttending == "CONFIRMED_MAYBE"or vAttending == "REQUESTED_MAYBE" then
				vColor = {r=0.8,g=0.8,b=0.8}
			else
				vColor = NORMAL_FONT_COLOR
			end
		else
			vColor = HIGHLIGHT_FONT_COLOR
		end
		
		GameTooltip:AddDoubleLine(vLeftText, vRightText, vColor.r, vColor.g, vColor.b, vColor.r, vColor.g, vColor.b)
	end
end

function GroupCalendar.ShowDateButtonTooltip(pDateButton)
	if not pDateButton.Schedule or table.getn(pDateButton.Schedule) == 0 then
		return
	end
	
	local vDate = GroupCalendar.Calendar.StartDate + pDateButton:GetID() - GroupCalendar.Calendar.StartDayOfWeek
	
	GameTooltip:SetOwner(pDateButton, "ANCHOR_RIGHT")
	GameTooltip:AddLine(GroupCalendar.GetLongDateString(vDate, true), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	GroupCalendar.AddTooltipSchedule(GameTooltip, pDateButton.Schedule)
	GameTooltip:Show()
end

function GroupCalendar.AddTooltipSchedule(pTooltip, pSchedule)
	for vIndex, vCompiledEvent in ipairs(pSchedule) do
		local vEventInfo = GroupCalendar.EventInfoByID[vCompiledEvent.mEvent.mType]
		local vLeftText, vRightText, vColor
		
		if vEventInfo and vEventInfo.allDay then
			vLeftText = vEventInfo.name
		else
			local vTime
			
			if gGroupCalendar_Settings.ShowEventsInLocalTime then
				vTime = MCDateLib:GetLocalTimeFromServerTime(vCompiledEvent.mEvent.mTime)
			else
				vTime = vCompiledEvent.mEvent.mTime
			end
			
			vLeftText = GroupCalendar.GetShortTimeString(vTime)
		end
		
		local vOwner
		
		if vCompiledEvent.mRealm ~= GroupCalendar.RealmName then
			vOwner = string.format(GroupCalendar_cForeignRealmFormat, vCompiledEvent.mOwner, vCompiledEvent.mRealm)
		else
			vOwner = vCompiledEvent.mOwner
		end
		
		vRightText = string.format(GroupCalendar_cTooltipScheduleItemFormat, GroupCalendar.Database.GetEventDisplayName(vCompiledEvent.mEvent), vOwner)
		
		local vAttending = GroupCalendar.Database.PlayerIsAttendingEvent(vCompiledEvent.mOwner, vCompiledEvent.mEvent)
		
		if vAttending then
			if vAttending == "CONFIRMED" then
				vColor = GREEN_FONT_COLOR
			elseif vAttending == "CONFIRMED_STANDBY" or vAttending == "REQUESTED_STANDBY" then
				vColor = "|cff8888ff"
			else
				vColor = NORMAL_FONT_COLOR
			end
		else
			vColor = HIGHLIGHT_FONT_COLOR
		end
		
		pTooltip:AddDoubleLine(vLeftText, vRightText, vColor.r, vColor.g, vColor.b, vColor.r, vColor.g, vColor.b)
	end
end

function GroupCalendar.UnitClassID(pUnitID)
	local vClass, vClassID = UnitClass(pUnitID)
	
	return vClassID
end

function GroupCalendar.UnitRaceID(pUnitID)
	local vRace, vRaceID = UnitRace(pUnitID)
	
	return vRaceID
end

----------------------------------------
GroupCalendar._Version = {}
----------------------------------------

GroupCalendar._Version.cBuildLevelByCode =
{
	d = 4,
	a = 3,
	b = 2,
	f = 1,
}

GroupCalendar._Version.cBuildCodeByLevel = GroupCalendar.ReverseTable(GroupCalendar._Version.cBuildLevelByCode)

function GroupCalendar._Version:FromString(pString)
	local _, _, vMajor, vMinor, vBugFix, vBuildLevelCode, vBuildNumber = string.find(pString, "[vV]?(%d+)%.(%d+)%.?(%d*)(%w?)(%d*)")
	local vBuildLevel
	
	vMajor = tonumber(vMajor)
	
	if not vMajor then
		vMajor = 0
	end
	
	vMinor = tonumber(vMinor)
	
	if not vMinor then
		vMinor = 0
	end
	
	vBugFix = tonumber(vBugFix)
	
	if not vBugFix then
		vBugFix = 0
	end
	
	if vBuildLevelCode == "" then
		vBuildLevel = 0
	else
		vBuildLevel = self.cBuildLevelByCode[vBuildLevelCode]
		
		if not vBuildLevel then
			vBuildLevel = 5
		end
	end
	
	vBuildNumber = tonumber(vBuildNumber)
	
	if not vBuildNumber then
		vBuildNumber = 0
	end
	
	self.Major = vMajor
	self.Minor = vMinor
	self.BugFix = vBugFix
	self.BuildLevel = vBuildLevel
	self.BuildNumber = vBuildNumber
end

function GroupCalendar._Version:LessThan(pVersion)
	if self.Major ~= pVersion.Major then
		return self.Major < pVersion.Major
	end
	
	if self.Minor ~= pVersion.Minor then
		return self.Minor < pVersion.Minor
	end
	
	if self.BugFix ~= pVersion.BugFix then
		return self.BugFix < pVersion.BugFix
	end
	
	if self.BuildLevel ~= pVersion.BuildLevel then
		return self.BuildLevel > pVersion.BuildLevel
	end
	
	if self.BuildNumber ~= pVersion.BuildNumber then
		return self.BuildNumber < pVersion.BuildNumber
	end
	
	return false
end

function GroupCalendar._Version:ToString()
	local vString = string.format("v%d.%d", self.Major, self.Minor)
	
	if self.BugFix > 0 then
		vString = vString.."."..self.BugFix
	end
	
	if self.BuildLevel > 0 then
		vString = string.format("%s%s%d", vString, GroupCalendar._Version.cBuildCodeByLevel[self.BuildLevel] or "?", self.BuildNumber)
	end
	
	return vString
end
