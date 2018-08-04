GroupCalendar.EventEditor = {}

GroupCalendar.EventEditor.ShowScheduleEditor = false
GroupCalendar.EventEditor.Active = false

GroupCalendar.EventEditor.Database = nil
GroupCalendar.EventEditor.Event = nil
GroupCalendar.EventEditor.IsNewEvent = false

GroupCalendar.EventEditor.PreviousEventType = nil

GroupCalendar.EventEditor.CurrentPanel = 1
GroupCalendar.EventEditor.UsingLocalTime = false
GroupCalendar.EventEditor.EventDate = nil
GroupCalendar.EventEditor.EventTime = nil
GroupCalendar.EventEditor.EventDateIsLocal = false

GroupCalendar.cNumAttendanceItems = 12
GroupCalendar.cNumAutoConfirmAttendanceItems = 11
GroupCalendar.cNumPlainAttendanceItems = 16
GroupCalendar.cAttendanceItemHeight = 16

GroupCalendar.EventEditor.cPanelFrames =
{
	"CalendarEventEditorEventFrame",
	"CalendarEventEditorAttendanceFrame",
}

StaticPopupDialogs.CONFIRM_CALENDAR_EVENT_DELETE =
{
	text = TEXT(CalendarEventEditor_cConfirmDeleteMsg),
	button1 = TEXT(CalendarEventEditor_cDelete),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar.EventEditor:DeleteEvent() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs.CONFIRM_CALENDAR_RSVP_DELETE =
{
	text = TEXT(GroupCalendar_cConfrimDeleteRSVP),
	button1 = TEXT(CalendarEventEditor_cDelete),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar.EventEditor:DeleteRSVP() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs.CONFIRM_CALENDAR_CLEAR_WHISPERS =
{
	text = TEXT(GroupCalendar_cConfirmClearWhispers),
	button1 = TEXT(GroupCalendar_cClear),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar.WhisperLog:Clear() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

function GroupCalendar.EventEditor:EditEvent(pDatabase, pEvent, pIsNewEvent)
	self.Database = pDatabase
	self.Event = pEvent
	self.IsNewEvent = pIsNewEvent
	self.UsingLocalTime = gGroupCalendar_Settings.ShowEventsInLocalTime
	CalendarEventEditorAttendance.NewClassLimits = nil
	
	CalendarEventEditorAttendance:SetEvent(pDatabase, pEvent)
	
	self.EventDateIsLocal = self.UsingLocalTime
	
	if pIsNewEvent then
		-- New events have their date in whatever time zone is
		-- selected for display
		
		self.EventDate = pEvent.mDate
		self.EventTime = pEvent.mTime
	else
		-- Existing events have their date in server time so
		-- convert to a local date if necessary
		
		if self.EventDateIsLocal then
			self.EventDate, self.EventTime = MCDateLib:GetLocalDateTimeFromServerDateTime(pEvent.mDate, pEvent.mTime)
		else
			self.EventDate = pEvent.mDate
			self.EventTime = pEvent.mTime
		end
	end
	
	if not self.EventDate then
		GroupCalendar:DebugMessage("Date not found")
		GroupCalendar:DebugTable("Event", pEvent)
	end
	
	CalendarEventEditorFrameSubTitle:SetText(GroupCalendar.GetLongDateString(self.EventDate))
	
	self:UpdateControlsFromEvent(pEvent)
	
	ShowUIPanel(CalendarEventEditorFrame)
	
	if pIsNewEvent then
		CalendarEventTitle:SetFocus()
		CalendarEventTitle:HighlightText()
	else
		CalendarEventTitle:HighlightText(0, 0)
	end
	
	self.ShowScheduleEditor = false
	self.Active = true
end

function GroupCalendar.EventEditor:MajorDatabaseChange()
	if not self.Active then return end
	
	self:EventChanged(self.Event) -- Force the attendance to update, can come from multiple sources so just always update
	
	if self.UsingLocalTime ~= gGroupCalendar_Settings.ShowEventsInLocalTime then
		self.UsingLocalTime = gGroupCalendar_Settings.ShowEventsInLocalTime
		
		self.EventTime = self:GetTimeControlValue(CalendarEventEditorTime)
		
		if self.UsingLocalTime then
			self.EventDate, self.EventTime = MCDateLib:GetLocalDateTimeFromServerDateTime(self.EventDate, self.EventTime)
		else
			self.EventDate, self.EventTime = MCDateLib:GetServerDateTimeFromLocalDateTime(self.EventDate, self.EventTime)
		end
		
		self:SetTimeControlValue(CalendarEventEditorTime, self.EventTime)
		if gGroupCalendar_Settings.ShowEventsInLocalTime then
			CalendarEventEditorTimeZone:SetText("local")
		else
			CalendarEventEditorTimeZone:SetText("server")
		end
	end
end

function GroupCalendar.EventEditor:EventChanged(pEvent)
	if pEvent == self.Event then
		CalendarEventEditorAttendance:EventChanged(self.Database, pEvent)
		
		-- Don't update the control values since that'll overwrite whatever
		-- is currently being set up
		-- self:UpdateControlsFromEvent(pEvent)
	end
end

function GroupCalendar.EventEditor:OnLoad()
	-- Tabs
	
	PanelTemplates_SetNumTabs(this, table.getn(self.cPanelFrames))
	CalendarEventEditorFrame.selectedTab = self.CurrentPanel
	PanelTemplates_UpdateTabs(this)
end

function GroupCalendar.EventEditor:OnShow()
	PlaySound("igCharacterInfoOpen")
	
	CalendarEventEditorEventTypeMenu.ChangedValueFunc = function () GroupCalendar.EventEditor:EventTypeChanged(CalendarEventEditorEventTypeMenu, UIDropDownMenu_GetSelectedValue(CalendarEventEditorEventTypeMenu)) end
	CalendarEventEditorAttendance.Widgets.MainView.AutoConfirm.Menu.ChangedValueFunc = function (...) GroupCalendar.EventEditor:SetAutoConfirmMode(unpack(arg)) end
	
	self:ShowPanel(1) -- Always switch to the event view when showing the window
end

function GroupCalendar.EventEditor:OnHide()
	PlaySound("igCharacterInfoClose")
	
	CalendarAddPlayer_Cancel() -- Force the dialog to close if it's open
	
	if not self.ShowScheduleEditor then
		self:SaveEvent()
		HideUIPanel(CalendarEditorFrame)
	end
	
	self.Database = nil
	self.Event = nil
	self.Active = false
end

function GroupCalendar.EventEditor:DoneEditing()
	if not self.Active then
		return
	end
	
	self:SaveEvent()
	self:CloseEditor(true)
end

function GroupCalendar.EventEditor:UpdateControlsFromEvent(pEvent, pExistingValuesOnly)
	if not pExistingValuesOnly
	or pEvent.mType then
		CalendarEventEditorEventTypeMenu:SetSelectedValue(pEvent.mType or "NONE")
	end

	if pEvent.mTitle and pEvent.mTitle ~= "" then
		CalendarEventTitle:SetText(GroupCalendar.UnescapeString(pEvent.mTitle))
	elseif not pExistingValuesOnly
	or pEvent.mType then
		local vEventName = GroupCalendar.Database.GetEventNameByID(pEvent.mType)
		
		if vEventName ~= nil then
			CalendarEventTitle:SetText(vEventName)
		else
			CalendarEventTitle:SetText("")
		end
	end
	
	if not pExistingValuesOnly
	or self.EventTime then
		self:SetTimeControlValue(CalendarEventEditorTime, self.EventTime)
	end
	
	if not pExistingValuesOnly
	or pEvent.mDuration then
		CalendarEventEditorDurationMenu:SetSelectedValue(pEvent.mDuration)
	end

	if pEvent.mDescription then
		CalendarEventDescription:SetText(GroupCalendar.UnescapeString(pEvent.mDescription))
	elseif not pExistingValuesOnly then
		CalendarEventDescription:SetText("")
	end

	if pEvent.mMinLevel then
		CalendarEventMinLevel:SetText(pEvent.mMinLevel)
	elseif not pExistingValuesOnly then
		CalendarEventMinLevel:SetText("")
	end

	if pEvent.mMaxLevel then
		CalendarEventMaxLevel:SetText(pEvent.mMaxLevel)
	elseif not pExistingValuesOnly then
		CalendarEventMaxLevel:SetText("")
	end
	
	-- Control logic for determining the actual confirmation type.  This logic is kind
	-- of complex due to having to work backwards from the actual stored values.
	
	-- TODO: Rework event confirmation mode to a single field.  Leave the existing booleans
	-- so that downgrading doesn't affect existing events, though new events will not have
	-- those and downgrading will cause existing events to show the default Automatic mode
	
	if pEvent.mManualConfirm then
		CalendarEventEditorAttendance.Widgets.MainView.AutoConfirm.Menu:SetSelectedValue("MAN")
	elseif pEvent.mClosed then
		CalendarEventEditorAttendance.Widgets.MainView.AutoConfirm.Menu:SetSelectedValue("CLOSED")
	elseif pEvent.mRoleConfirm then
		CalendarEventEditorAttendance.Widgets.MainView.AutoConfirm.Menu:SetSelectedValue("ROLE")
	else
		CalendarEventEditorAttendance.Widgets.MainView.AutoConfirm.Menu:SetSelectedValue("AUT")
	end
	
	if not pExistingValuesOnly
	or pEvent.mType then
		self.PreviousEventType = pEvent.mType
		self:SetEventType(pEvent.mType)
	end
	
	if self.Database.Guild
	and not GroupCalendar.Database.IsPrivateEventType(pEvent.mType) then
		CalendarEventEditorGuildOnly:SetChecked(pEvent.mGuild == self.Database.Guild)
		CalendarEventEditorGuildOnly:Show()
	else
		CalendarEventEditorGuildOnly:Hide()
	end
end

function GroupCalendar.EventEditor:SaveClassLimits(pLimits)
	CalendarEventEditorAttendance.NewClassLimits = pLimits
end

function GroupCalendar.EventEditor:GetDropdownEventType()
	vValue = UIDropDownMenu_GetSelectedValue(CalendarEventEditorEventTypeMenu)
	
	if vValue == "NONE" then
		return
	end
	
	return vValue
end

function GroupCalendar.EventEditor:UpdateEventFromControls(rEvent, rChangedFields)
	local vChanged = false
	local vValue
	
	-- Type
	
	vValue = self:GetDropdownEventType()
	
	if rEvent.mType ~= vValue then
		rEvent.mType = vValue
		rChangedFields.mType = {op = "UPD", val = vValue}
		vChanged = true
	end
	
	local vPrivate = GroupCalendar.Database.IsPrivateEventType(vValue)
	
	if rEvent.mPrivate ~= vPrivate then
		rEvent.mPrivate = vPrivate
		rChangedFields.mPrivate = {op = "UPD", val = vPrivate}
		vChanged = true
	end
	
	-- Title
	
	vValue = CalendarEventTitle:GetText()
	
	if vValue == GroupCalendar.Database.GetEventNameByID(rEvent.mType)
	or vValue == "" then
		vValue = nil
	else
		vValue = GroupCalendar.EscapeString(vValue)
	end
	
	if vValue and string.len(vValue) > GroupCalendar_cMaxFieldLength then
		vValue = string.sub(vValue, 1, GroupCalendar_cMaxFieldLength)
	end
	
	if rEvent.mTitle ~= vValue then
		rEvent.mTitle = vValue
		rChangedFields.mTitle = "UPD"
		vChanged = true
	end
	
	-- Time
	
	local vDate, vTime = nil, nil
	
	if GroupCalendar.Database.EventTypeUsesTime(rEvent.mType) then
		vDate, vTime = self.EventDate, self:GetTimeControlValue(CalendarEventEditorTime)
		
		if self.UsingLocalTime then
			vDate, vTime = MCDateLib:GetServerDateTimeFromLocalDateTime(vDate, vTime)
		end
	else
		vDate = self.EventDate
	end
	
	if rEvent.mDate ~= vDate then
		rEvent.mDate = vDate
		rChangedFields.mDate = "UPD"
		vChanged = true
	end
	
	if rEvent.mTime ~= vTime then
		rEvent.mTime = vTime
		rChangedFields.mTime = "UPD"
		vChanged = true
	end
	
	-- Duration
	
	if GroupCalendar.Database.EventTypeUsesTime(rEvent.mType) then
		vValue = UIDropDownMenu_GetSelectedValue(CalendarEventEditorDurationMenu)
	else
		vValue = nil
	end
	
	if vValue == 0 then
		vValue = nil
	end
	
	if rEvent.mDuration ~= vValue then
		rEvent.mDuration = vValue
		rChangedFields.mDuration = "UPD"
		vChanged = true
	end
	
	-- Description
	
	vValue = CalendarEventDescription:GetText()
	
	if vValue == "" then
		vValue = nil
	else
		vValue = GroupCalendar.EscapeString(vValue)
	end
	
	if vValue and string.len(vValue) > GroupCalendar_cMaxFieldLength then
		vValue = string.sub(vValue, 1, GroupCalendar_cMaxFieldLength)
	end
	
	if rEvent.mDescription ~= vValue then
		rEvent.mDescription = vValue
		rChangedFields.mDescription = "UPD"
		vChanged = true
	end
	
	-- MinLevel
	
	if GroupCalendar.Database.EventTypeUsesLevelLimits(rEvent.mType) then
		vValue = CalendarEventMinLevel:GetText()
	else
		vValue = nil
	end
	
	if vValue and vValue ~= "" then
		vValue = tonumber(vValue)
		
		if vValue == 0 then
			vValue = nil
		end
	else
		vValue = nil
	end
	
	if rEvent.mMinLevel ~= vValue then
		rEvent.mMinLevel = vValue
		rChangedFields.mMinLevel = "UPD"
		vChanged = true
	end
	
	-- MaxLevel
	
	if GroupCalendar.Database.EventTypeUsesTime(rEvent.mType) then
		vValue = CalendarEventMaxLevel:GetText()
	else
		vValue = nil
	end
	
	if vValue and vValue ~= "" then
		vValue = tonumber(vValue)
		
		if vValue == 0 then
			vValue = nil
		end
	else
		vValue = nil
	end
	
	if rEvent.mMaxLevel ~= vValue then
		rEvent.mMaxLevel = vValue
		rChangedFields.mMaxLevel = "UPD"
		vChanged = true
	end
	
	-- Automatic confirmations
	
	local vManualConfirm, vRoleConfirm, vClosedEvent
	
	if GroupCalendar.Database.IsQuestingEventType(rEvent.mType) then
		local vAutoConfirmValue = UIDropDownMenu_GetSelectedValue(CalendarEventEditorAttendance.Widgets.MainView.AutoConfirm.Menu)
		
		if vAutoConfirmValue == "CLOSED" then
			vClosedEvent = true
		elseif vAutoConfirmValue == "MAN" then
			vManualConfirm = true
		elseif vAutoConfirmValue == "ROLE" then
			vRoleConfirm = true
		end
	else
		-- Non-questing events are always auto-confirm (ie meetings)
		
		vManualConfirm = nil
	end
	
	if vClosedEvent ~= rEvent.mClosed then
		rEvent.mClosed = vClosedEvent
		rChangedFields.mClosed = {op = "UPD", val = vClosedEvent}
	end
	
	if vManualConfirm ~= rEvent.mManualConfirm then
		rEvent.mManualConfirm = vManualConfirm
		rChangedFields.mManualConfirm = {op = "UPD", val = vManualConfirm}
	end
	
	if vRoleConfirm ~= rEvent.mRoleConfirm then
		rEvent.mRoleConfirm = vRoleConfirm
		rChangedFields.mRoleConfirm = {op = "UPD", val = vRoleConfirm}
	end
	
	local vGuild = nil
	
	if CalendarEventEditorGuildOnly:GetChecked() then
		vGuild = self.Database.Guild
	end
	
	if vGuild ~= rEvent.mGuild then
		rEvent.mGuild = vGuild
		rChangedFields.mGuild = {op = "UPD", val = vGuild}
	end
	
	if GroupCalendar.Database.IsQuestingEventType(rEvent.mType) then
		if CalendarEventEditorAttendance.NewClassLimits
		and not GroupCalendar.LimitsAreEqual(rEvent.mLimits, CalendarEventEditorAttendance.NewClassLimits) then
			rEvent.mLimits = CalendarEventEditorAttendance.NewClassLimits
			rChangedFields.mLimits = {op = "UPD", val = rEvent.mLimits}
		end
	else
		-- No limits on non-questing event types (ie, meetings)
		
		if rEvent.mLimits then
			rEvent.mLimits = nil
			rChangedFields.mLimits = {op = "UPD", val = rEvent.mLimits}
		end
	end
	
	-- Done
	
	return vChanged
end

function GroupCalendar.EventEditor:SetEventType(pEventType)
	-- CalendarEventEditorEventTypeMenu:Show()
	-- CalendarEventTitle:Show()
	-- CalendarEventDescription:Show()
	
	CalendarDropDown_SetSelectedValue(CalendarEventEditorEventTypeMenu, pEventType or "NONE")
	
	local vTitleText = CalendarEventTitle:GetText()
	local vEventName = GroupCalendar.Database.GetEventNameByID(self.PreviousEventType)
	local vTitleWasEventName = vTitleText == vEventName or vTitleText == ""
	
	if GroupCalendar.Database.EventTypeUsesTime(pEventType) then
		CalendarEventEditorTime:Show()
		CalendarEventEditorDurationMenu:Show()
	else
		CalendarEventEditorTime:Hide()
		CalendarEventEditorDurationMenu:Hide()
	end
	
	if GroupCalendar.Database.EventTypeUsesLevelLimits(pEventType) then
		CalendarEventMinLevel:Show()
		CalendarEventMaxLevel:Show()
	else
		CalendarEventMinLevel:Hide()
		CalendarEventMaxLevel:Hide()
	end
	
	if GroupCalendar.Database.EventTypeUsesAttendance(pEventType) then
		CalendarEventEditorFrameTab2:Show()
		CalendarEventEditorSelfAttend:Show()
		CalendarEventEditorGuildOnly:Show()
	else
		CalendarEventEditorFrameTab2:Hide()
		CalendarEventEditorSelfAttend:Hide()
		CalendarEventEditorGuildOnly:Hide()
	end
	
	if vTitleWasEventName then
		CalendarEventTitle:SetText(GroupCalendar.Database.GetEventNameByID(pEventType) or "")
		CalendarEventTitle:SetFocus()
		CalendarEventTitle:HighlightText()
	end
	
	-- Update the sample icon
	
	CalendarEventEditorEventBackground:SetTexture(GroupCalendar.GetEventTypeIconPath(pEventType))
	if pEventType == "Birth" then
		CalendarEventEditorEventBackground:SetVertexColor(1, 1, 1, 0.4)
	else
		CalendarEventEditorEventBackground:SetVertexColor(1, 1, 1, 0.19)
	end

	--
	
	self.PreviousEventType = pEventType
end

function GroupCalendar.EventEditor:DeleteEvent()
	if not self.IsNewEvent then
		GroupCalendar.Database.DeleteEvent(self.Database, self.Event)
	end
	
	self:CloseEditor(true)
end

function GroupCalendar.EventEditor:DeleteRSVP()
	if not GroupCalendar.RSVPToDelete then
		return
	end
	
	GroupCalendar.RSVPToDelete.mStatus = "C"
	
	GroupCalendar.Database.AddEventRSVP(
			self.Database,
			self.Event,
			GroupCalendar.RSVPToDelete.mName,
			GroupCalendar.RSVPToDelete)
	
	GroupCalendar.RSVPToDelete = nil
end

function GroupCalendar.EventEditor:CloseEditor(pShowScheduleEditor)
	self.Active = false
	
	self.ShowScheduleEditor = pShowScheduleEditor
	HideUIPanel(CalendarEventEditorFrame)
end

function GroupCalendar.EventEditor:CopyTemplateFields(pFromEvent, rToEvent)
	rToEvent.mType = pFromEvent.mType
	rToEvent.mTitle = pFromEvent.mTitle
	rToEvent.mDescription = pFromEvent.mDescription
	rToEvent.mTime = pFromEvent.mTime
	rToEvent.mDuration = pFromEvent.mDuration
	rToEvent.mMinLevel = pFromEvent.mMinLevel
	rToEvent.mMaxLevel = pFromEvent.mMaxLevel
	
	rToEvent.mManualConfirm = pFromEvent.mManualConfirm
	rToEvent.mRoleConfirm = pFromEvent.mRoleConfirm
	rToEvent.mClosed = pFromEvent.mClosed
	rToEvent.mLimits = GroupCalendar.DuplicateTable(pFromEvent.mLimits)
	rToEvent.mGuild = pFromEvent.mGuild
end

function GroupCalendar.EventEditor:SaveEvent()
	-- Update the event
	
	local vChangedFields = {}
	
	self:UpdateEventFromControls(self.Event, vChangedFields)
	
	if GroupCalendar.ArrayIsEmpty(vChangedFields) then
		return
	end
	
	-- Save the event if it's new
	
	if self.IsNewEvent then
		if (self.Event.mTitle ~= nil and self.Event.mTitle ~= "")
		or self.Event.mType ~= nil then
			GroupCalendar.Database.AddEvent(self.Database, self.Event)
			
			-- If self-attend is selected add the RSVP
			
			if CalendarEventEditorSelfAttend:GetChecked() then
				self:SetSelfAttend(true, true)
			end
		end
	else
		GroupCalendar.Database.EventChanged(self.Database, self.Event, vChangedFields)
	end
	
	-- Save a template for the event
	
	if self.Event.mType
	and self.Event.mType ~= "Birth" then
		local vEventTemplate = {}
		
		self:CopyTemplateFields(self.Event, vEventTemplate)
		vEventTemplate.mSelfAttend = self:GetSelfAttend()
		
		GroupCalendar.SaveEventTemplate(vEventTemplate)
	end
end

function GroupCalendar.EventEditor:SetTimeControlValue(pFrame, pTime)
	if pTime == nil then
		return
	end
	
	local vFrameName = pFrame:GetName()
	
	local vHourFrame = getglobal(vFrameName.."Hour")
	local vMinuteFrame = getglobal(vFrameName.."Minute")
	local vAMPMFrame = getglobal(vFrameName.."AMPM")
	
	if TwentyFourHourTime then
		local vHour, vMinute = GroupCalendar.ConvertTimeToHM(pTime)
		
		CalendarDropDown_SetSelectedValue(vHourFrame, vHour)
		CalendarDropDown_SetSelectedValue(vMinuteFrame, vMinute)
		vAMPMFrame:Hide()
	else
		local vHour, vMinute, vAMPM = GroupCalendar.ConvertTimeToHMAMPM(pTime)
		
		CalendarDropDown_SetSelectedValue(vHourFrame, vHour)
		CalendarDropDown_SetSelectedValue(vMinuteFrame, vMinute)
		
		vAMPMFrame:Show()
		CalendarDropDown_SetSelectedValue(vAMPMFrame, vAMPM)
	end
end

function GroupCalendar.EventEditor:GetTimeControlValue(pFrame)
	local vFrameName = pFrame:GetName()
	
	local vHourFrame = getglobal(vFrameName.."Hour")
	local vMinuteFrame = getglobal(vFrameName.."Minute")
	local vAMPMFrame = getglobal(vFrameName.."AMPM")
	
	local vHour = UIDropDownMenu_GetSelectedValue(vHourFrame) or 0
	local vMinute = UIDropDownMenu_GetSelectedValue(vMinuteFrame) or 0
	
	if TwentyFourHourTime then
		return GroupCalendar.ConvertHMToTime(vHour, vMinute)
	else
		local vAMPM = UIDropDownMenu_GetSelectedValue(vAMPMFrame) or 0
		
		return GroupCalendar.ConvertHMAMPMToTime(vHour, vMinute, vAMPM)
	end
end

function GroupCalendar.EventEditor:LoadEventDefaults(pTemplate)
	-- Set the default limits for this dungeon (the template will
	-- override this if it's present)

	local vEventInfo = GroupCalendar.Database.GetEventInfoByID(self:GetDropdownEventType())
	
	if vEventInfo then
		if vEventInfo.limits then
			self.Event.mLimits = vEventInfo.limits
		end
		
		if vEventInfo.minLevel then	
			self.Event.mMinLevel = vEventInfo.minLevel
		end
	end
	
	-- Copy of template values
	
	local vTemplate = pTemplate
	
	if not vTemplate then
		vTemplate = GroupCalendar.FindEventTemplateByTitle(vEventInfo.name)
	end
	
	if vTemplate then
		self:CopyTemplateFields(vTemplate, self.Event)
		
		-- Convert the date/time to local
		
		if vTemplate.mTime and self.EventDateIsLocal then
			_, self.Event.mTime = MCDateLib:GetLocalDateTimeFromServerDateTime(self.Event.mDate, self.Event.mTime)
		end
		
		self.EventTime = self.Event.mTime
		
		self:UpdateControlsFromEvent(self.Event, true)
		
		if vTemplate.mSelfAttend then
			self:SetSelfAttend(vTemplate.mSelfAttend)
		end
	end
end

function GroupCalendar.EventEditor:EventTypeChanged(pMenuFrame, pValue)
	self:SetEventType(pValue)
	
	-- Set the templated field values if available
	
	if self.IsNewEvent then
		self:LoadEventDefaults()
	end
end

function GroupCalendar.EventEditor:SetAutoConfirmMode(pMenuFrame, pValue)
	pMenuFrame.AttendanceViewer:SetAutoConfirmMode(pValue)
end

function GroupCalendar.EventEditor:ShowPanel(pPanelIndex)
	CalendarAddPlayer_Cancel() -- Force the dialog to close if it's open
	
	if self.CurrentPanel > 0
	and self.CurrentPanel ~= pPanelIndex then
		self:HidePanel(self.CurrentPanel)
	end
	
	-- NOTE: Don't check for redundant calls since this function
	-- will be called to reset the field values as well as to 
	-- actuall show the panel when it's hidden
	
	self.CurrentPanel = pPanelIndex
	
	-- Update the control values
	
	if pPanelIndex == 1 then
		-- Event panel
		
		CalendarEventEditorSelfAttend:SetChecked(self:GetSelfAttend())
		CalendarEventEditorSelfAttendText:SetText(string.format(GroupCalendar_cSelfWillAttend, GroupCalendar.PlayerName))
		
		if self.Database.Guild then
			CalendarEventEditorGuildOnly:Show()
			CalendarEventEditorGuildOnlyText:SetText(string.format(GroupCalendar_cGuildOnly, self.Database.Guild))
		else
			CalendarEventEditorGuildOnly:Hide()
		end
		
	elseif pPanelIndex == 2 then
		-- Attendance panel
		
		if GroupCalendar.Database.IsQuestingEventType(self.PreviousEventType) then
			CalendarEventEditorAttendance:SetTotalsVisible(true, true)
		else
			CalendarEventEditorAttendance:SetTotalsVisible(false, false)
		end
	else
		GroupCalendar:DebugMessage("EventEditor:ShowPanel: Unknown index (%s)", pPanelIndex or "nil")
	end
	
	getglobal(self.cPanelFrames[pPanelIndex]):Show()
	
	PanelTemplates_SetTab(CalendarEventEditorFrame, pPanelIndex)
	
	self:Update()
end

function GroupCalendar.EventEditor:HidePanel(pFrameIndex)
	if self.CurrentPanel ~= pFrameIndex then
		return
	end
	
	getglobal(self.cPanelFrames[pFrameIndex]):Hide()
	self.CurrentPanel = 0
end

function GroupCalendar.EventEditor:Update()
	-- Event panel
	
	if self.CurrentPanel == 1 then
	
	-- Attendance panel
	
	elseif self.CurrentPanel == 2 then
		CalendarEventEditorAttendance:Update()
	end
end

GroupCalendar.cStatusCodeStrings =
{
	N = CalendarEventEditor_cNotAttending,
	Y = CalendarEventEditor_cConfirmed,
	D = CalendarEventEditor_cDeclined,
	S = CalendarEventEditor_cStandby,
	P = CalendarEventEditor_cPending,
	M = CalendarEventEditor_cMaybe,
	["-"] = CalendarEventEditor_cBanned,
}

function GroupCalendar.EventEditor:GetStatusString(pStatus)
	local vStatus1 = string.sub(pStatus, 1, 1)
	local vString = GroupCalendar.cStatusCodeStrings[vStatus1]
	
	if vString then	
		return vString
	else
		return format(CalendarEventEditor_cUnknownStatus, pStatus)
	end
end

function GroupCalendar.EventEditor:GetSelfAttend()
	return GroupCalendar.Database.FindEventRSVPString(self.Event, GroupCalendar.PlayerName) ~= nil
end

function GroupCalendar.EventEditor:SetSelfAttend(pWillAttend, pNewEventOverride)
	-- Don't do anything if it's a new event (it'll be handled during save)
	
	if self.IsNewEvent and not pNewEventOverride then
		return
	end
	
	-- Create or remove the RSVP request for the owner
	
	if pWillAttend then
		local vRSVP = GroupCalendar.Database.CreatePlayerRSVP(
								self.Database,
								self.Event,
								GroupCalendar.PlayerName,
								GroupCalendar.Database.GetRaceCodeByRaceID(GroupCalendar.UnitRaceID("PLAYER")),
								GroupCalendar.Database.GetClassCodeByClassID(GroupCalendar.UnitClassID("PLAYER")),
								GroupCalendar.PlayerLevel,
								GroupCalendar.GetPlayerDefaultRole(),
								"Y",
								nil,
								GroupCalendar.PlayerGuild,
								GroupCalendar.PlayerGuildRank,
								GroupCalendar.PlayerCharacters)
		
		GroupCalendar.Database.AddEventRSVP(
				self.Database,
				self.Event,
				GroupCalendar.PlayerName,
				vRSVP)
	else
		GroupCalendar.Database.RemoveEventRSVP(
				self.Database,
				self.Event,
				GroupCalendar.PlayerName)
	end
end

function GroupCalendar.EventEditor:AskDeleteEvent()
	-- If it's new just kill it without asking
	
	if self.IsNewEvent then
		self:DeleteEvent()
	else
		-- Update an event record so we can display a meaningful name
		
		local vChangedFields = {}
		local vEvent = {}
		
		self:UpdateEventFromControls(vEvent, vChangedFields)
		
		StaticPopup_Show("CONFIRM_CALENDAR_EVENT_DELETE", GroupCalendar.Database.GetEventDisplayName(vEvent))
	end
end

function GroupCalendar.EventEditor:AttendanceMenuItemSelected(pOwner, pValue)
	local vAttendanceItem = pOwner:GetParent()
	local vLineIndex = vAttendanceItem:GetID()
	local vAttendanceList = vAttendanceItem:GetParent()
	
	local vItem = vAttendanceList:GetIndexedItem(vLineIndex)
	
	if not vItem then
		GroupCalendar:ErrorMessage("Internal error: AttendanceMenuItemSelected couldn't get item for ID %s", vLineIndex or "nil")
		return
	end
	
	if pValue == "DELETE" then
		if vItem.mType == "Whisper" then
			GroupCalendar.WhisperLog:RemovePlayer(vItem.mName)
		else
			GroupCalendar.RSVPToDelete = vItem
			StaticPopup_Show("CONFIRM_CALENDAR_RSVP_DELETE", vItem.mName or "unknown")
		end
	elseif pValue == "ADD" then
		if vItem.mType == "Whisper" then
			CalendarAddPlayer_OpenWhisper(vItem.mName, vItem.mDate, vItem.mTime, vItem.mWhispers)
		end
	elseif pValue == "EDIT" then
		CalendarAddPlayer_EditRSVP(vItem)
	elseif pValue == "INVITE" then
		InviteByName(vItem.mName)
	else
		vItem.mStatus = pValue
		
		GroupCalendar.Database.AddEventRSVP(
				self.Database,
				self.Event,
				vItem.mName,
				vItem)
	end
end

function GroupCalendar.EventEditor:UpdateDescriptionCounter(pText)
	local vCurLength = string.len(GroupCalendar.EscapeString(pText))

	CalendarEventDescriptionLimit:SetText(vCurLength.."/"..GroupCalendar_cMaxFieldLength)

	-- Figure out the amount used in the description and color progress based on percentage
	
	local vPercentUsed = vCurLength / GroupCalendar_cMaxFieldLength
	
	if vPercentUsed <= 0.75 then
		CalendarEventDescriptionLimit:SetVertexColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif vCurLength < GroupCalendar_cMaxFieldLength then
		CalendarEventDescriptionLimit:SetVertexColor(0.9, 0.9, 0.05) -- Yellow
	else
		CalendarEventDescriptionLimit:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	end
end

----------------------------------------
-- WhisperLog
----------------------------------------

GroupCalendar.WhisperLog =
{
	mPlayers = {},
	mEvent = {}
}

function GroupCalendar.WhisperLog:AddWhisper(pPlayerName, pMessage)
	-- If no event is active then just ignore all whispers
	-- NOTE: Disabling this for now, it seems like it's better to have too
	-- many than too few whispers.  With this feature enabled, the organizer
	-- must remember to open the event before receiving whispers or else
	-- they'll be lost.  That can be a bit of a pain.
	
	--[[
	if not self.mEvent then
		return
	end
	]]
	
	-- Ignore whispers which appear to be data from other addons
	
	local vFirstChar = string.sub(pMessage, 1, 1)
	
	if vFirstChar == "<"
	or vFirstChar == "["
	or vFirstChar == "{"
	or vFirstChar == "!" then
		return
	end
	
	-- Filter if necessary
	
	if self.mWhisperFilterFunc
	and not self.mWhisperFilterFunc(self.mWhisperFilterParam, pPlayerName) then
		return
	end
	
	--
	
	local vPlayerLog = self.mPlayers[pPlayerName]
	
	if not vPlayerLog then
		vPlayerLog = {}
		
		vPlayerLog.mName = pPlayerName
		vPlayerLog.mDate, vPlayerLog.mTime = MCDateLib:GetServerDateTime60()
		vPlayerLog.mWhispers = {}
		
		self.mPlayers[pPlayerName] = vPlayerLog
	end
	
	local vLength = table.getn(vPlayerLog.mWhispers)
	
	if vLength > 3 then
		table.remove(vPlayerLog.mWhispers, 1)
		vLength = vLength - 1
	end
	
	vPlayerLog.mWhispers[vLength + 1] = pMessage

	-- Notify
	
	if self.mNotificationFunc then
		self.mNotificationFunc(self.mNotifcationParam)
	end
end

function GroupCalendar.WhisperLog:AskClear()
	StaticPopup_Show("CONFIRM_CALENDAR_CLEAR_WHISPERS")
end

function GroupCalendar.WhisperLog:Clear()
	self.mPlayers = {}
	
	if self.mNotificationFunc then
		self.mNotificationFunc(self.mNotifcationParam)
	end
end

function GroupCalendar.WhisperLog:GetPlayerWhispers(pEvent)
	if self.mEvent ~= pEvent then
		self.mEvent = pEvent
		self:Clear()
	end
	
	return self.mPlayers
end

function GroupCalendar.WhisperLog:SetNotificationFunc(pFunc, pParam)
	self.mNotificationFunc = pFunc
	self.mNotifcationParam = pParam
end

function GroupCalendar.WhisperLog:SetWhisperFilterFunc(pFunc, pParam)
	self.mWhisperFilterFunc = pFunc
	self.mWhisperFilterParam = pParam
end

function GroupCalendar.WhisperLog:RemovePlayer(pPlayerName)
	self.mPlayers[pPlayerName] = nil

	-- Notify
	
	if self.mNotificationFunc then
		self.mNotificationFunc(self.mNotifcationParam)
	end
end

function GroupCalendar.WhisperLog:GetNextWhisper(pPlayerName)
	-- Make an indexed list of the whispers
	
	local vWhispers = {}
	
	for vName, vWhisper in pairs(self.mPlayers) do
		table.insert(vWhispers, vWhisper)
	end
	
	-- Sort by time
	
	table.sort(vWhispers, GroupCalendar.Database.CompareRSVPsByDate)
	
	--
	
	local vLowerName = strlower(pPlayerName)
	local vUseNext = false
	
	for vIndex, vWhisper in ipairs(vWhispers) do
		if vUseNext then
			return vWhisper
		end
		
		if vLowerName == strlower(vWhisper.mName) then
			vUseNext = true
		end
	end
	
	return nil
end

----------------------------------------
-- AttendanceViewer
----------------------------------------

GroupCalendar.AttendanceViewer = {}

function GroupCalendar.AttendanceViewer.Initialize(pAttendanceViewer, pAllowEdits)
	GroupCalendar.InitializeFrame(pAttendanceViewer, GroupCalendar._AttendanceViewer)
	
	pAttendanceViewer:Construct()
	
	if pAllowEdits then
		pAttendanceViewer:SetCanEdit(true)
	end
end

function GroupCalendar.AttendanceViewer.OnVerticalScroll()
	this:GetParent():OnVerticalScroll()
end

function GroupCalendar.AttendanceViewer.ShowMessageTooltip(pOwner, pName, pMessages, pColor)
	if not pName then
		return
	end
	
	GameTooltip:SetOwner(pOwner, "ANCHOR_LEFT")
	GameTooltip:AddLine(pName)
	
	local vColor = {r = 1, g = 1, b = 1}
	
	if pColor then
		vColor = pColor
	end
	
	if type(pMessages) == "table" then
		for vIndex, vText in ipairs(pMessages) do
			GameTooltip:AddLine(vText, vColor.r, vColor.g, vColor.b, 1)
		end
	else
		GameTooltip:AddLine(pMessages, vColor.r, vColor.g, vColor.b, 1)
	end
	
	GameTooltip:Show()
end

----------------------------------------
-- _AttendanceViewer
----------------------------------------

GroupCalendar._AttendanceViewer =
{
	Widgets =
	{
		"ExpandAll",
		"GroupTab",
		"ExpandAllButton",
		"ScrollFrame",
		"ScrollbarTrench",
		"ViewMenu",
		
		MainView =
		{
			AutoConfirm =
			{
				"Menu",
				"Options",
			},
			
			"AddButton",
			
			ClassTotals =
			{
				PRIEST = {"Label"},
				PALADIN = {"Label"},
				MAGE = {"Label"},
				WARLOCK = {"Label"},
				WARRIOR = {"Label"},
				DRUID = {"Label"},
				ROGUE = {"Label"},
				SHAMAN = {"Label"},
				HUNTER = {"Label"}
			},
			
			RoleTotals =
			{
				MH = {"Label"},
				OH = {"Label"},
				MT = {"Label"},
				OT = {"Label"},
				RD = {"Label"},
				MD = {"Label"}
			},
			
			StatusTotals =
			{
				YES = {"Label"},
				NO = {"Label"},
				PENDING = {"Label"},
				QUEUED = {"Label"},
				BANNED = {"Label"},
				STANDBY = {"Label"},
			},
		},
		
		GroupView =
		{
		}
	}
}

function GroupCalendar._AttendanceViewer:Construct()
	self.NumItems = GroupCalendar.cNumAttendanceItems
	self.CollapsedCategories = {}
	self.ListSortMode = "Date"
	self.ListGroupMode = "Class"
	self.Panels =
	{
		{Tab = self.Widgets.ExpandAll, Panel = self.Widgets.MainView},
		{Tab = self.Widgets.GroupTab, Panel = self.Widgets.GroupView},
	}
	
	self.CurrentPanel = self.Widgets.MainView
	
	self:SetScript("OnShow", function () this:OnShow() end)
	self:SetScript("OnHide", function () this:OnHide() end)
	
	-- Set the text color for the class totals
	
	for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		local vCount = self.Widgets.MainView.ClassTotals[vClassInfo.color]
		local vColor = RAID_CLASS_COLORS[vClassInfo.color]
		
		vCount:SetTextColor(vColor.r, vColor.g, vColor.b)
		vCount.Label:SetTextColor(vColor.r, vColor.g, vColor.b)
	end
	
	-- Set the text color for the role totals
	
	for vRoleID, vRoleInfo in pairs(GroupCalendar.RoleInfoByID) do
		local vCount = self.Widgets.MainView.RoleTotals[vRoleID]
		local vColor = RAID_CLASS_COLORS[GroupCalendar.cRoleColorName[vRoleID]]
		
		vCount:SetTextColor(vColor.r, vColor.g, vColor.b)
		vCount.Label:SetTextColor(vColor.r, vColor.g, vColor.b)
	end
	
	self.Widgets.MainView.AutoConfirm.Menu.AttendanceViewer = self
	self.Widgets.MainView.AutoConfirm.Options.AttendanceViewer = self
	
	self:SetTotalsVisible(true, true)
end

function GroupCalendar._AttendanceViewer:AnyItemsCollapsed()
	if not self.CollapsedCategories then
		return false
	end
	
	-- Get the group
	
	local vGroup
	
	if self.CurrentPanel == self.Widgets.MainView then
		vGroup = self.EventListInfo.AttendanceCounts
	
	elseif self.CurrentPanel == self.Widgets.GroupView then
		vGroup = GroupCalendar.Invites.Group
	else
		GroupCalendar:ErrorMessage("AnyItemsCollapsed: Unknown view %s", self.CurrentPanel:GetName())
		return
	end
	
	--
	
	if not vGroup then
		return false
	end
	
	for vCategory, vCollapsed in pairs(self.CollapsedCategories) do
		if vCollapsed and vGroup.Categories[vCategory] then
			return true
		end
	end
	
	return false
end

function GroupCalendar._AttendanceViewer:FactionCheck()
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		if vClassInfo.faction then
			local vLabelItem = self.Widgets.MainView.ClassTotals[vClassInfo.color].Label
			local vItem = self.Widgets.MainView.ClassTotals[vClassInfo.color]
			if vClassInfo.faction == GroupCalendar.PlayerFactionGroup then
				vLabelItem:Show()
				vItem:Show()
			else
				vLabelItem:Hide()
				vItem:Hide()
			end
		end	
	end
end

function GroupCalendar._AttendanceViewer:OnShow()
	self:FactionCheck()
	self:ShowPanel(self.Widgets.MainView)	

	GroupCalendar.WhisperLog:SetNotificationFunc(self.UpdateWhispers, self)
	GroupCalendar.WhisperLog:SetWhisperFilterFunc(self.FilterWhispers, self)
end

function GroupCalendar._AttendanceViewer:OnHide()
	GroupCalendar.WhisperLog:SetNotificationFunc(nil, nil, nil)
	
	if GetNumPartyMembers() == 0
	and GetNumRaidMembers() == 0 then
		GroupCalendar.Invites:EndEvent(self.Event)
	else
		GroupCalendar.Invites:SetChangedFunc(nil, nil)
	end
end

function GroupCalendar._AttendanceViewer:SetEvent(pDatabase, pEvent)
	self.Database = pDatabase
	self.Event = pEvent
	self.Group = nil
	
	if self.Event.mRoleConfirm then
		self.ListGroupMode = "Role"
	else
		self.ListGroupMode = "Class"
	end
	
	self.ListSortMode = "Date"

	self.Widgets.ViewMenu.ListSortMode = self.ListSortMode
	self.Widgets.ViewMenu.ListGroupMode = self.ListGroupMode
	
	self.EventListInfo = {}
	self.CollapsedCategories = {}

	-- Update the auto confirm enable
	
	local vAutoConfirmMenu = self.Widgets.MainView.AutoConfirm.Menu
	local vAutoConfirmOptions = self.Widgets.MainView.AutoConfirm.Options
	
	if self.Event.mClosed then
		CalendarDropDown_SetSelectedValue(vAutoConfirmMenu, "CLOSED")
	elseif self.Event.mManualConfirm then
		CalendarDropDown_SetSelectedValue(vAutoConfirmMenu, "MAN")
	elseif self.Event.mRoleConfirm then
		CalendarDropDown_SetSelectedValue(vAutoConfirmMenu, "ROLE")
	else
		CalendarDropDown_SetSelectedValue(vAutoConfirmMenu, "AUT")
	end
	
	GroupCalendar.SetButtonEnable(vAutoConfirmOptions, not self.Event.mManualConfirm and not self.Event.mClosed)
	
	--
	
	self:UpdateAttendanceCounts()
end

function GroupCalendar._AttendanceViewer:SetGroup(pGroup)
	self.Group = pGroup
end

function GroupCalendar._AttendanceViewer:EventChanged(pDatabase, pEvent)
	self.Database = pDatabase
	self.Event = pEvent
	
	self:UpdateAttendanceCounts()
	GroupCalendar.Invites:EventChanged(pDatabase, pEvent)
	
	self:Update()
end

function GroupCalendar._AttendanceViewer:UpdateAttendanceCounts()
	local vHadWhispers = self.EventListInfo.AttendanceCounts
			           and self.EventListInfo.AttendanceCounts.Categories["WHISPERS"] ~= nil
	
	self.EventListInfo.AttendanceCounts =
			CalendarEvent_GetAttendanceList(
					self.Database,
					self.Event,
					self.ListGroupMode)
	
	-- Add in the recent whispers, but only if they're not in the attendance list
	-- and only if the event is editable
	
	if not vHadWhispers then
		self.CollapsedCategories["WHISPERS"] = true
	end
	
	local vAttendanceList = self.EventListInfo.AttendanceCounts
	local vGroupList = GroupCalendar.Invites.Group
	
	if self.mCanEdit then
		local vPlayerWhispers = GroupCalendar.WhisperLog:GetPlayerWhispers(self.Event)
		
		for vPlayerName, vWhispers in pairs(vPlayerWhispers) do
			vAttendanceList:AddWhisper(vPlayerName, vWhispers)
		end
	end
	
	CalendarEvent_SortAttendanceCounts(self.EventListInfo.AttendanceCounts, self.ListGroupMode, self.ListSortMode)
end

function GroupCalendar._AttendanceViewer:FilterWhispers(pPlayerName)
	local vAttendanceList = self.EventListInfo.AttendanceCounts
	
	if vAttendanceList.Items
	and vAttendanceList.Items[pPlayerName] then
		return false
	end
	
	if GroupCalendar.Invites.Group
	and GroupCalendar.Invites.Group.Items[pPlayerName] then
		return false
	end
	
	return true
end

function GroupCalendar._AttendanceViewer:UpdateWhispers()
	if not self.EventListInfo.AttendanceCounts:RemoveCategory("WHISPERS") then
		-- Collapse the category if this is the first one
		
		self.CollapsedCategories["WHISPERS"] = true
	end
	
	local vAttendanceList = self.EventListInfo.AttendanceCounts
	local vGroupList = GroupCalendar.Invites.Group
	
	local vPlayerWhispers = GroupCalendar.WhisperLog:GetPlayerWhispers(self.Event)
	
	for vPlayerName, vWhispers in pairs(vPlayerWhispers) do
		vAttendanceList:AddWhisper(vPlayerName, vWhispers)
	end
	
	CalendarEvent_SortAttendanceCounts(self.EventListInfo.AttendanceCounts, self.ListGroupMode, self.ListSortMode)
	
	self:Update()
end

function GroupCalendar._AttendanceViewer:SetCanEdit(pCanEdit)
	self.mCanEdit = pCanEdit
end

function GroupCalendar._AttendanceViewer:SetTotalsVisible(pShowTotals, pShowAutoConfirm)
	self.ShowTotals = pShowTotals
	self.ShowAutoConfirm = pShowAutoConfirm
	
	self:AdjustHeight()
end

function GroupCalendar._AttendanceViewer:AdjustHeight()
	local vClassTotals = self.Widgets.MainView.ClassTotals
	local vRoleTotals = self.Widgets.MainView.RoleTotals
	local vStatusTotals = self.Widgets.MainView.StatusTotals
	
	local vAutoConfirm = self.Widgets.MainView.AutoConfirm
	local vScrollFrame = self.Widgets.ScrollFrame
	local vScrollTrench = self.Widgets.ScrollbarTrench
	
	local vScrollFrameBaseHeight = 254
	local vScrollTrenchBaseHeight = 261
	
	if self.CurrentPanel == self.Widgets.GroupView
	or self.ShowTotals then
		local vFooterHeight
		local vCurTotals
		
		if self.ListGroupMode == "Role" then
			vClassTotals:Hide()
			vRoleTotals:Show()
			vStatusTotals:Hide()
			
			vCurTotals = vRoleTotals
		elseif self.ListGroupMode == "Status" then
			vClassTotals:Hide()
			vRoleTotals:Hide()
			vStatusTotals:Show()
			
			vCurTotals = vStatusTotals
		else
			vClassTotals:Show()
			vRoleTotals:Hide()
			vStatusTotals:Hide()
			
			vCurTotals = vClassTotals
		end
		
		if self.CurrentPanel ~= self.Widgets.GroupView
		and self.ShowAutoConfirm then
			vAutoConfirm:Show()
			self.NumItems = GroupCalendar.cNumAutoConfirmAttendanceItems
			vFooterHeight = vAutoConfirm:GetHeight() + vCurTotals:GetHeight()
		else
			vAutoConfirm:Hide()
			self.NumItems = GroupCalendar.cNumAttendanceItems
			vFooterHeight = vCurTotals:GetHeight()
		end
		
		vScrollFrame:SetHeight(vScrollFrameBaseHeight - vFooterHeight)
		vScrollTrench:SetHeight(vScrollTrenchBaseHeight - vFooterHeight)
	else
		vClassTotals:Hide()
		vRoleTotals:Hide()
		vStatusTotals:Hide()
		vAutoConfirm:Hide()
		self.NumItems = GroupCalendar.cNumPlainAttendanceItems
		vScrollFrame:SetHeight(vScrollFrameBaseHeight)
		vScrollTrench:SetHeight(vScrollTrenchBaseHeight)
	end
end

function GroupCalendar._AttendanceViewer:Update()
	if not self:IsVisible() then
		return
	end
	
	local vAttendanceListName = self:GetName()
	
	-- Update the view menu
	
	UIDropDownMenu_SetText(string.format(GroupCalendar_cViewMenuFormat, self.ListGroupMode, self.ListSortMode), self.Widgets.ViewMenu)
	
	if self.CurrentPanel == self.Widgets.MainView then
		-- Update the scroll frame
		
		local vTotalCount = 0
		
		if self.EventListInfo.AttendanceCounts then
			for vCategory, vClassAttendanceInfo in pairs(self.EventListInfo.AttendanceCounts.Categories) do
				vTotalCount = vTotalCount + 1
				
				if not self.CollapsedCategories[vCategory] then
					vTotalCount = vTotalCount + vClassAttendanceInfo.mCount
				end
			end
		end
		
		FauxScrollFrame_Update(
				getglobal(vAttendanceListName.."ScrollFrame"),
				vTotalCount,
				self.NumItems,
				GroupCalendar.cAttendanceItemHeight,
				nil, nil, nil,
				nil,
				293, 316)
		
		self:UpdateAttendanceList()
		
		-- Update the expand/collapse all button
		
		self:UpdateTotals()
		
		-- Show or hide the add button
		
		local vAddButton = self.Widgets.MainView.AddButton
		
		if self.mCanEdit then
			vAddButton:Show()
		else
			vAddButton:Hide()
		end
		
	elseif self.CurrentPanel == self.Widgets.GroupView then
		local vGroupViewName = vAttendanceListName.."GroupView"
		local vSelectionInfoText = getglobal(vGroupViewName.."SelectionInfo")
		local vStatusText = getglobal(vGroupViewName.."Status")
		local vStatusMessage = GroupCalendar_cInviteStatusMessages[GroupCalendar.Invites.Status]
		local vInviteButton = getglobal(vGroupViewName.."Invite")
		
		if vStatusMessage then
			vStatusText:SetText(vStatusMessage)
		elseif GroupCalendar.Invites.Status then
			vStatusText:SetText("Unknown "..GroupCalendar.Invites.Status)
		else
			vStatusText:SetText("Unknown (nil)")
		end
		
		local vNumSelected = GroupCalendar.Invites.NumSelected
		
		if not vNumSelected
		or vNumSelected == 0 then
			vSelectionInfoText:SetText(GroupCalendar_cNoSelection)
		elseif vNumSelected == 1 then
			vSelectionInfoText:SetText(GroupCalendar_cSingleSelection)
		else
			vSelectionInfoText:SetText(format(GroupCalendar_cMultiSelection, vNumSelected))
		end
		
		-- Update the scroll frame
		
		local vTotalCount = 0
		
		if self.EventListInfo.AttendanceCounts then
			for vCategory, vClassAttendanceInfo in pairs(GroupCalendar.Invites.Group.Categories) do
				vTotalCount = vTotalCount + 1
				
				if not self.CollapsedCategories[vCategory] then
					vTotalCount = vTotalCount + vClassAttendanceInfo.mCount
				end
			end
		end
		
		FauxScrollFrame_Update(
				getglobal(vAttendanceListName.."ScrollFrame"),
				vTotalCount,
				self.NumItems,
				GroupCalendar.cAttendanceItemHeight,
				nil, nil, nil,
				nil,
				293, 316)
		
		self:UpdateAttendanceList()
		
		-- Enable the invite button if the player is the raid or party leader
		-- or is not in a raid or pary
		
		local vEnableInvites = false
		local vInParty = GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0
		
		if not vInParty
		or IsPartyLeader()
		or IsRaidLeader()
		or IsRaidOfficer() then
			vEnableInvites = true
		end
		
		GroupCalendar.SetButtonEnable(vInviteButton, vEnableInvites)
	end
end

function GroupCalendar._AttendanceViewer:ToggleExpandAll()
	-- Get the group
	
	local vGroup
	
	if self.CurrentPanel == self.Widgets.MainView then
		vGroup = self.EventListInfo.AttendanceCounts
	
	elseif self.CurrentPanel == self.Widgets.GroupView then
		vGroup = GroupCalendar.Invites.Group
	
	else
		GroupCalendar:ErrorMessage("AttendanceViewer:ToggleExpandAll: Unknown view "..self.CurrentPanel:GetName())
		return
	end
	
	-- Just return if there are no attendance items to toggle
	
	if not self
	or not vGroup then
		return
	end
	
	if self:AnyItemsCollapsed() then
		-- Expand all
		
		self.CollapsedCategories = {}
	else
		-- Collapse all
		
		self.CollapsedCategories = {}
		
		for vCategory, vClassAttendanceInfo in pairs(vGroup.Categories) do
			self.CollapsedCategories[vCategory] = true
		end
	end
	
	self:Update()
end

function GroupCalendar._AttendanceViewer:UpdateTotals()
	if self.ListGroupMode == "Role" then
		self:UpdateRoleTotals()
	elseif self.ListGroupMode == "Status" then
		self:UpdateStatusTotals()
	else
		self:UpdateClassTotals()
	end
end

function GroupCalendar._AttendanceViewer:UpdateClassTotals()
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		local vClassTotal = 0
		local vStandbyTotal = 0
		
		if self.EventListInfo.AttendanceCounts then
			local vCategoryInfo = self.EventListInfo.AttendanceCounts.Categories[vClassCode]
			
			if vCategoryInfo then
				vClassTotal = vCategoryInfo.mCount
				vStandbyTotal = vCategoryInfo.mStandbyCount
			end
		end
		
		local vCountTextItem = self.Widgets.MainView.ClassTotals[vClassInfo.color]
		
		vCountTextItem:SetText(string.format(
				tern(vStandbyTotal > 0, GroupCalendar_cNumPlayersPlusStandbyFormat, GroupCalendar_cNumPlayersFormat),
				vClassTotal,
				vStandbyTotal))
		
		if vClassTotal == 0 then
			vCountTextItem:SetTextColor(0.9, 0.2, 0.2)
		else
			local vColor = RAID_CLASS_COLORS[vClassInfo.color]
			vCountTextItem:SetTextColor(vColor.r, vColor.g, vColor.b)
		end
	end
end

function GroupCalendar._AttendanceViewer:UpdateRoleTotals()
	for vRoleID, vRoleInfo in pairs(GroupCalendar.RoleInfoByID) do
		local vRoleTotal = 0
		local vStandbyTotal = 0
		
		if self.EventListInfo.AttendanceCounts then
			local vCategoryInfo = self.EventListInfo.AttendanceCounts.Categories[vRoleID]
			
			if vCategoryInfo then
				vRoleTotal = vCategoryInfo.mCount
				vStandbyTotal = vCategoryInfo.mStandbyCount
			end
		end
		
		local vCountTextItem = self.Widgets.MainView.RoleTotals[vRoleID]
		
		vCountTextItem:SetText(string.format(
				tern(vStandbyTotal > 0, GroupCalendar_cNumPlayersPlusStandbyFormat, GroupCalendar_cNumPlayersFormat),
				vRoleTotal,
				vStandbyTotal))
		
		if vRoleTotal == 0 then
			vCountTextItem:SetTextColor(0.9, 0.2, 0.2)
		else
			local vColor = RAID_CLASS_COLORS[GroupCalendar.cRoleColorName[vRoleID]]
			vCountTextItem:SetTextColor(vColor.r, vColor.g, vColor.b)
		end
	end
end

function GroupCalendar._AttendanceViewer:UpdateStatusTotals()
	for vStatusID, vStatusInfo in pairs(GroupCalendar.cAttendanceCategories) do
		local vStatusWidget = self.Widgets.MainView.StatusTotals[vStatusID]
		
		if vStatusWidget then
			local vStatusTotal = 0
			local vStandbyTotal = 0
			
			if self.EventListInfo.AttendanceCounts then
				local vCategoryInfo = self.EventListInfo.AttendanceCounts.Categories[vStatusID]
				
				if vCategoryInfo then
					vStatusTotal = vCategoryInfo.mCount
					vStandbyTotal = vCategoryInfo.mStandbyCount
				end
			end
			
			vStatusWidget:SetText(string.format(
					tern(vStandbyTotal > 0, GroupCalendar_cNumPlayersPlusStandbyFormat, GroupCalendar_cNumPlayersFormat),
					vStatusTotal,
					vStandbyTotal))
			
			if vStatusTotal == 0 then
				vStatusWidget:SetTextColor(0.9, 0.2, 0.2)
			else
				vStatusWidget:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			end
		end
	end
end

function GroupCalendar._AttendanceViewer:SetItem(
					pIndex,
					pItemInfo,
					pLeftFormat,
					pRightFormat,
					pShowMenu,
					pMenuValue,
					pColor,
					pOffline,
					pIconPath,
					pChecked,
					pTooltipName,
					pTooltipText,
					pTooltipTextColor)
	
	if type(pIndex) == "table" then
		GroupCalendar:DebugStack()
	end
	
	local vListName = self:GetName()
	local vItemName = vListName.."Item"..pIndex
	local vItem = getglobal(vItemName)
	local vItemHighlight = getglobal(vItemName.."Highlight")
	
	local vItemCategory = getglobal(vItemName.."Category")
	local vItemLeftText = getglobal(vItemName.."Name")
	local vItemRightText = getglobal(vItemName.."Status")
	local vItemMenu = getglobal(vItemName.."Menu")
	local vItemActionButton = getglobal(vItemName.."Action")
	
	--
	
	vItemCategory:Hide()
	vItemLeftText:Show()
	vItemRightText:Show()
	vItemActionButton:Hide()
	
	if pShowMenu then
		CalendarDropDown_SetSelectedValue2(vItemMenu, pMenuValue)
		vItemMenu:Show()
		vItemRightText:SetWidth(112)
	else
		vItemMenu:Hide()
		vItemRightText:SetWidth(130)
	end
	
	vItemLeftText:SetText(string.gsub(pLeftFormat, "%$(%w+)", function (pField) return pItemInfo[pField] end))
	vItemRightText:SetText(string.gsub(pRightFormat, "%$(%w+)", function (pField) return pItemInfo[pField] end))
	
	if pColor then
		if pOffline then
			vItemLeftText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		else
			vItemLeftText:SetTextColor(pColor.r, pColor.g, pColor.b)
		end
		
		vItemRightText:SetTextColor(pColor.r, pColor.g, pColor.b)
	else
		if pOffline then
			vItemLeftText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		else
			vItemLeftText:SetTextColor(1, 1, 1)
		end
		vItemRightText:SetTextColor(1, 1, 1)
	end
	
	if pChecked ~= nil then
		vItem.Checkable = true
		vItem:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
		vItem:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
		vItemHighlight:SetTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
		vItem:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		vItem:SetChecked(pChecked)
	else
		vItem.Checkable = false
		if pIconPath then
			vItem:SetNormalTexture(pIconPath)
		else
			vItem:SetNormalTexture("")
		end
		vItem:SetPushedTexture("")
		vItem:SetCheckedTexture("")
		vItemHighlight:SetTexture("")
		vItem:SetChecked(false)
	end
	
	vItem.IsCategoryItem = false
	vItem:Show()
	
	vItem.TooltipName = pTooltipName
	vItem.TooltipText = pTooltipText
	vItem.TooltipTextColor = pTooltipTextColor
	
	return vItem
end

function GroupCalendar._AttendanceViewer:SetItemToRSVP(pIndex, pCategory, pRSVP, pNameFormat, pShowRank)
	local vItemInfo =
	{
		name = pRSVP.mName,
		class = GroupCalendar.Database.GetClassByClassCode(pRSVP.mClassCode),
		race = GroupCalendar.Database.GetRaceByRaceCode(pRSVP.mRaceCode),
		level = tostring(pRSVP.mLevel),
		role = pRSVP.mRole,
		status = "",
	}
	
	-- Set the status
	
	local vShowStatusString = false
	
	if vShowStatusString then
		vItemInfo.status = self:GetStatusString(pRSVP.mStatus)
	elseif pShowRank then
		local vRank = GroupCalendar.Database.MapGuildRank(pRSVP.mGuild, pRSVP.mGuildRank)
		
		if vRank then
			vItemInfo.status = GuildControlGetRankName(vRank + 1)
		else
			vItemInfo.status = GroupCalendar_cUnknown
		end
	else
		local vDate, vTime = GroupCalendar.Database.GetRSVPOriginalDateTime(pRSVP)
		
		if vDate and vTime then
			vTime = vTime / 60 -- Convert from seconds to minutes
			
			if gGroupCalendar_Settings.ShowEventsInLocalTime then
				vDate, vTime = MCDateLib:GetLocalDateTimeFromServerDateTime(vDate, vTime)
			end
			
			local vShortDateString = GroupCalendar.GetShortDateString(vDate)
			local vShortTimeString = GroupCalendar.GetShortTimeString(vTime)
			
			vItemInfo.status = vShortDateString.." "..vShortTimeString
		end
	end
	
	local vColor = GroupCalendar.GetClassCodeColor(pRSVP.mClassCode)
	
	-- Get the icon path
	
	local vIconPath
	local vTooltipName = nil
	local vTooltipText = nil
	local vTooltipTextColor = nil
	
	if pRSVP.mComment and pRSVP.mComment ~= "" then
		vIconPath = "Interface\\Addons\\GroupCalendar\\Textures\\AttendanceNoteIcon"
		vTooltipName = pRSVP.mName
		vTooltipText = GroupCalendar.UnescapeString(pRSVP.mComment)
	elseif pRSVP.mType == "Whisper" then
		vIconPath = "Interface\\Addons\\GroupCalendar\\Textures\\AttendanceNoteIcon"
		
		vTooltipName = pRSVP.mName
		vTooltipText = pRSVP.mWhispers
		vTooltipTextColor = ChatTypeInfo["WHISPER"]
		vColor = vTooltipTextColor
	else
		vIconPath = ""
	end
	
	-- Set the item
	
	local vItem = self:SetItem(
							pIndex,
							vItemInfo,
							pNameFormat,
							"$status",
							self.mCanEdit,
							pRSVP.mStatus,
							vColor,
							false,
							vIconPath,
							nil,
							vTooltipName,
							vTooltipText,
							vTooltipTextColor)
	
	vItem.Item = pRSVP
end

function GroupCalendar._AttendanceViewer:SetItemToCategory(pIndex, pCategory, pActionFunc, pActionParam)
	local vItemName = self:GetName().."Item"..pIndex
	local vItem = getglobal(vItemName)
	
	local vItemHighlight = getglobal(vItemName.."Highlight")
	local vItemCategory = getglobal(vItemName.."Category")
	local vItemPlayerName = getglobal(vItemName.."Name")
	local vItemPlayerStatus = getglobal(vItemName.."Status")
	local vItemMenu = getglobal(vItemName.."Menu")
	local vItemActionButton = getglobal(vItemName.."Action")

	local vCategoryName
	
	if type(pCategory) == "number" then
		vCategoryName = GuildControlGetRankName(pCategory + 1)
	else
		vCategoryName = GroupCalendar.cAttendanceCategories[pCategory]
		
		if not vCategoryName then
			if self.ListGroupMode == "Role" then
				local vRoleInfo = GroupCalendar.RoleInfoByID[pCategory]
				
				if not vRoleInfo then
					vCategoryName = "Unknown role ("..(pCategory or "nil")..")"
				else
					vCategoryName = vRoleInfo.Name
				end
			else
				vCategoryName = GroupCalendar.Database.GetClassByClassCode(pCategory)
			end
		end
	end
	
	vItemCategory:SetText(vCategoryName)
	vItemCategory:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	vItemCategory:Show()
	vItemPlayerName:Hide()
	vItemPlayerStatus:Hide()
	
	if pActionFunc then
		vItemActionButton.ActionFunc = pActionFunc
		vItemActionButton.ActionParam = pActionParam
		vItemActionButton:Show()
	else
		vItemActionButton:Hide()
	end
	
	vItemMenu:Hide()
	vItemPlayerStatus:SetWidth(130)
	
	if self.CollapsedCategories[pCategory] then
		vItem:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
		vItem:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down")
	else
		vItem:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up") 
		vItem:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down")
	end
	
	vItemHighlight:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
	vItem:SetChecked(false)
	
	vItem.Item = nil
	vItem.IsCategoryItem = true
	vItem.Category = pCategory
	
	vItem.TooltipName = nil
	vItem.TooltipText = nil
	vItem.TooltipTextColor = nil
	
	vItem:Show()
end

function GroupCalendar._AttendanceViewer:HideUnusedAttendanceItems(pFirstItem)
	local vListName = self:GetName()
	
	for vIndex = pFirstItem, GroupCalendar.cNumPlainAttendanceItems - 1 do
		local vItemName = vListName.."Item"..vIndex
		getglobal(vItemName):Hide()
	end
end

function GroupCalendar._AttendanceViewer:UpdateAttendanceList()
	if self.CurrentPanel == self.Widgets.MainView then
		self:UpdateEventAttendance()
	
	elseif self.CurrentPanel == self.Widgets.GroupView then
		self:UpdateGroupAttendance()
	
	else
		GroupCalendar:ErrorMessage("Unknown attendance panel "..self.CurrentPanel:GetName())
	end
	
	local vExpandAllButton = self.Widgets.ExpandAllButton
	
	if self:AnyItemsCollapsed() then
		vExpandAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
	else
		vExpandAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
	end
end

function GroupCalendar._AttendanceViewer:UpdateGroupAttendance()
	self:UpdateAttendanceItems(GroupCalendar.Invites.Group, self.SetGroupItem)
end

function GroupCalendar._AttendanceViewer:UpdateEventAttendance()
	self:UpdateAttendanceItems(self.EventListInfo.AttendanceCounts, self.SetAttendanceItem)
end

function GroupCalendar._AttendanceViewer:SetGroupItem(pItemIndex, pCategory, pItem)
	local vItemInfo = {}
	local vToolTipName, vTooltipText
	local vIconPath
	
	vItemInfo.name = pItem.mName
	vItemInfo.status = GroupCalendar_cGroupStatusMessages[pItem.mGroupStatus]
	vItemInfo.class = GroupCalendar.Database.GetClassByClassCode(pItem.mClassCode)
	vItemInfo.race = GroupCalendar.Database.GetRaceByRaceCode(pItem.mRaceCode)
	vItemInfo.level = tostring(pItem.mLevel)
	vItemInfo.offline = pItem.mOffline
	
	-- Set the status
	
	local vStatusColumnFormat = ""
	
	if self.ListSortMode == "Rank" then
		local vRank = GroupCalendar.Database.MapGuildRank(pItem.mGuild, pItem.mGuildRank)
		
		if vRank then
			vItemInfo.rank = GuildControlGetRankName(vRank + 1)
		else
			vItemInfo.rank = GroupCalendar_cUnknown
		end
		
		vStatusColumnFormat = "$rank"
	elseif self.ListSortMode == "Date"
	or self.ListSortMode == "Name" then
		local vDate, vTime = GroupCalendar.Database.GetRSVPOriginalDateTime(pItem)
		
		if vDate and vTime then
			vTime = vTime / 60 -- Convert from seconds to minutes
			
			if gGroupCalendar_Settings.ShowEventsInLocalTime then
				vDate, vTime = MCDateLib:GetLocalDateTimeFromServerDateTime(vDate, vTime)
			end
			
			local vShortDateString = GroupCalendar.GetShortDateString(vDate)
			local vShortTimeString = GroupCalendar.GetShortTimeString(vTime)
			
			vItemInfo.date = vShortDateString.." "..vShortTimeString
			
			vStatusColumnFormat = "$date"
		end
	end
	
	local vNameColumnFormat
	
	if pCategory == "STANDBY" then
		vNameColumnFormat = GroupCalendar_cMeetingAttendanceNameFormat
	else
		vNameColumnFormat = GroupCalendar_cGroupAttendanceNameFormat
	end
	
	local vSelected
	
	if pItem.mGroupStatus ~= "Joined" then
		vSelected = pItem.mSelected == true
	end
	
	local vItem = self:SetItem(
							pItemIndex,
							vItemInfo,
							vNameColumnFormat,
							vStatusColumnFormat,
							false,
							false,
							GroupCalendar.GetClassCodeColor(pItem.mClassCode),
							pItem.mOffline,
							vIconPath,
							vSelected,
							vTooltipName,
							vTooltipText)
	
	vItem.Item = pItem
end

function GroupCalendar._AttendanceViewer:SetAttendanceItem(pItemIndex, pCategory, pItem)
	local vShowRank = self.ListSortMode == "Rank"
	
	if pItem.mType == "Whisper" then
		self:SetItemToRSVP(pItemIndex, pCategory, pItem, GroupCalendar_cMeetingAttendanceNameFormat, vShowRank)
	
	elseif self.ListGroupMode == "Class"
	or self.ListGroupMode == "" then
		local vNameFormat

		if pCategory ~= "STANDBY" then
			vNameFormat = GroupCalendar_cQuestAttendanceNameFormat
		else
			vNameFormat = GroupCalendar_cMeetingAttendanceNameFormat
		end
		
		self:SetItemToRSVP(pItemIndex, pCategory, pItem, vNameFormat, vShowRank)
	else
		self:SetItemToRSVP(pItemIndex, pCategory, pItem, GroupCalendar_cMeetingAttendanceNameFormat, vShowRank)
	end
end

function GroupCalendar._AttendanceViewer:UpdateAttendanceItems(pAttendanceCounts, pSetItemFunction)
	local vTotalAttendeesItem = getglobal(self:GetName().."Total")
	
	local vFirstItemIndex = FauxScrollFrame_GetOffset(getglobal(self:GetName().."ScrollFrame"))
	local vItemIndex = 0
	
	if not pAttendanceCounts then
		self:HideUnusedAttendanceItems(vItemIndex)
		vTotalAttendeesItem:SetText(string.format(GroupCalendar_cNumPlayersFormat, 0))
		return
	end
	
	if self.CurrentPanel ~= self.Widgets.GroupView
	and pAttendanceCounts.NumStandby
	and pAttendanceCounts.NumStandby > 0 then
		vTotalAttendeesItem:SetText(string.format(GroupCalendar_cTotalNumPlayersFormat, string.format(GroupCalendar_cNumPlayersPlusStandbyFormat, pAttendanceCounts.NumAttendees - pAttendanceCounts.NumStandby, pAttendanceCounts.NumStandby)))
	else
		vTotalAttendeesItem:SetText(string.format(GroupCalendar_cTotalNumPlayersFormat, string.format(GroupCalendar_cNumPlayersFormat, pAttendanceCounts.NumAttendees)))
	end
	
	for vIndex, vCategory in ipairs(pAttendanceCounts.SortedCategories) do
		local vClassAttendanceInfo = pAttendanceCounts.Categories[vCategory]
		
		if vFirstItemIndex == 0 then
			local vActionFunc = nil
			
			if vCategory == "WHISPERS" then
				vActionFunc = function (...) GroupCalendar.WhisperLog:AskClear(unpack(arg)) end
			end
			
			self:SetItemToCategory(vItemIndex, vCategory, vActionFunc, nil)
			
			vItemIndex = vItemIndex + 1
			
			if vItemIndex >= self.NumItems then
				self:HideUnusedAttendanceItems(vItemIndex)
				return
			end
		else
			vFirstItemIndex = vFirstItemIndex - 1
		end
		
		if not self.CollapsedCategories[vCategory] then
			if vFirstItemIndex >= vClassAttendanceInfo.mCount then
				vFirstItemIndex = vFirstItemIndex - vClassAttendanceInfo.mCount
			else
				for vIndex, vRSVP in ipairs(vClassAttendanceInfo.mAttendees) do
					if vFirstItemIndex == 0 then
						pSetItemFunction(self, vItemIndex, vCategory, vRSVP)
						
						vItemIndex = vItemIndex + 1
						
						if vItemIndex >= self.NumItems then
							self:HideUnusedAttendanceItems(vItemIndex)
							return
						end
					else
						vFirstItemIndex = vFirstItemIndex - 1
					end
				end
			end
		end
	end
	
	self:HideUnusedAttendanceItems(vItemIndex)
end

function GroupCalendar._AttendanceViewer:GetIndexedItem(pIndex)
	local vIndex = pIndex + FauxScrollFrame_GetOffset(getglobal(self:GetName().."ScrollFrame"))
	
	for vCategoryIndex, vCategory in ipairs(self.EventListInfo.AttendanceCounts.SortedCategories) do
		local vClassAttendanceInfo = self.EventListInfo.AttendanceCounts.Categories[vCategory]
		
		if vIndex == 0 then
			GroupCalendar:DebugMessage("AttendanceViewer:GetIndexedItem: Index specifies a header")
			return nil
		end
		
		GroupCalendar:DebugTable("    "..vCategory.." AttendanceInfo", vClassAttendanceInfo)
		
		vIndex = vIndex - 1
		
		if not self.CollapsedCategories[vCategory] then
			if vIndex < vClassAttendanceInfo.mCount then
				return vClassAttendanceInfo.mAttendees[vIndex + 1]
			end
			
			vIndex = vIndex - vClassAttendanceInfo.mCount
		else
			GroupCalendar:DebugMessage("    Category %s is collapsed", vCategory or "nil")
		end
	end
	
	GroupCalendar:DebugMessage("AttendanceViewer:GetIndexedItem: Index too high")
	GroupCalendar:DebugTable("    SortedCategories", self.EventListInfo.AttendanceCounts.SortedCategories)
	
	return nil
end

function GroupCalendar._AttendanceViewer:SetAutoConfirmMode(pMode)	
	GroupCalendar.SetButtonEnable(
			self.Widgets.MainView.AutoConfirm.Options,
			pMode == "ROLE" or pMode == "AUT")
end

function GroupCalendar._AttendanceViewer:OpenAutoConfirmOptions()
	local vAutConfirmMode = UIDropDownMenu_GetSelectedValue(self.Widgets.MainView.AutoConfirm.Menu)
	
	local vLimits = CalendarEventEditorAttendance.NewClassLimits
	
	if not vLimits then
		vLimits = self.Event.mLimits
	end
	
	if vAutConfirmMode == "ROLE" then
		CalendarRoleLimitsFrame:Open(vLimits, GroupCalendar_cRoleConfirmationTitle, false, function (...) GroupCalendar.EventEditor:SaveClassLimits(unpack(arg)) end)
	else
		CalendarClassLimitsFrame:Open(vLimits, GroupCalendar_cAutoConfirmationTitle, false, function (...) GroupCalendar.EventEditor:SaveClassLimits(unpack(arg)) end)
	end
end

function GroupCalendar._AttendanceViewer:OnVerticalScroll()
	self:Update()
end

function GroupCalendar._AttendanceViewer:Item_OnEnter(pItem)
	GroupCalendar.AttendanceViewer.ShowMessageTooltip(pItem, pItem.TooltipName, pItem.TooltipText, pItem.TooltipTextColor)
end

function GroupCalendar._AttendanceViewer:Item_OnLeave()
	GameTooltip:Hide()
end

function GroupCalendar._AttendanceViewer:Item_OnClick(pItem, pButton)
	if pItem.IsCategoryItem then
		if not self.CollapsedCategories[pItem.Category] then
			self.CollapsedCategories[pItem.Category] = true
		else
			self.CollapsedCategories[pItem.Category] = nil
		end
		
		self:Update()
		return
	end
	
	if not pItem.Checkable and pItem.SetChecked then
		pItem:SetChecked(false)
		return
	end
	
	if pItem.Item then
		if self.CurrentPanel == self.Widgets.GroupView then
			GroupCalendar.Invites:SetItemSelected(pItem.Item, not pItem.Item.mSelected)
		end
	end
end

function GroupCalendar._AttendanceViewer:DoListViewCommand(pCommand)
	if pCommand == "Class"
	or pCommand == "Role"
	or pCommand == "Status" then
		self.ListGroupMode = pCommand
	else
		self.ListSortMode = pCommand
	end
	
	self.Widgets.ViewMenu.ListSortMode = self.ListSortMode
	self.Widgets.ViewMenu.ListGroupMode = self.ListGroupMode
	
	self:EventChanged(self.Database, self.Event)
	GroupCalendar.Invites:SetGroupSortMode(self.ListGroupMode, self.ListSortMode)

	self:AdjustHeight() -- Update the frame for the new view
end

function GroupCalendar._AttendanceViewer:GroupListChanged()
	self:Update()
end

function GroupCalendar._AttendanceViewer:ShowPanel(pPanel)
	for _, vPanelInfo in ipairs(self.Panels) do
		if vPanelInfo.Panel == pPanel then
			vPanelInfo.Panel:Show()
			PanelTemplates_SelectTab(vPanelInfo.Tab)
			
			-- Handle panel-specific show code
			
			if pPanel == self.Widgets.GroupView then
				local vGroup = GroupCalendar.Invites:BeginEvent(self.Database, self.Event)
				
				self:SetGroup(vGroup)
				GroupCalendar.Invites:SetChangedFunc(self.GroupListChanged, self)
			end
		else
			if vPanelInfo.Panel == self.Widgets.GroupView then
				GroupCalendar.Invites:SetChangedFunc(nil, nil)
			end
			
			vPanelInfo.Panel:Hide()
			PanelTemplates_DeselectTab(vPanelInfo.Tab)
		end
	end
	
	self.CurrentPanel = pPanel
	
	self:AdjustHeight()
	self:Update()
end

----------------------------------------
-- CalendarAddPlayer
----------------------------------------

function CalendarAddPlayer_Open()
	CalendarAddPlayer_Reset()
	
	CalendarAddPlayerFrame:Show()
	CalendarAddPlayerFrameName:SetFocus()
end

function CalendarAddPlayer_Reset()
	CalendarAddPlayerFrame.IsWhisper = false
	CalendarAddPlayerFrame.Guild = nil
	
	CalendarAddPlayerFrameName:SetText("")
	CalendarAddPlayerFrameLevel:SetText("")
	CalendarDropDown_SetSelectedValue(CalendarAddPlayerFrameRankMenu, nil)
	CalendarDropDown_SetSelectedValue(CalendarAddPlayerFrameStatusMenu, "Y")
	CalendarDropDown_SetSelectedValue(CalendarAddPlayerFrameRoleMenu, "?")
	CalendarDropDown_SetSelectedValue(CalendarAddPlayerFrameClassMenu, "?")
	CalendarDropDown_SetSelectedValue(CalendarAddPlayerFrameRaceMenu, "?")
	CalendarAddPlayerFrameComment:SetText("")
	
	if IsInGuild() then
		CalendarAddPlayerFrameRankMenu:Show()
	else
		CalendarAddPlayerFrameRankMenu:Hide()
	end
	
	CalendarAddPlayerFrameDeleteButton:Hide()
	
	CalendarAddPlayerFrameWhisper:Hide()
	CalendarAddPlayerFrame:SetHeight(CalendarAddPlayerFrame.NormalHeight)
end

function CalendarAddPlayer_OpenWhisper(pName, pDate, pTime, pWhispers)
	CalendarAddPlayer_Reset()
	
	CalendarAddPlayerFrame.IsWhisper = true
	CalendarAddPlayerFrame.Name = pName
	CalendarAddPlayerFrame.Date = pDate
	CalendarAddPlayerFrame.Time = pTime
	CalendarAddPlayerFrame.Whispers = pWhispers
	
	CalendarAddPlayerFrameName:SetText(pName)
	CalendarAddPlayer_AutoCompletePlayerInfo()
	
	CalendarAddPlayerFrameDeleteButton:Show()
	
	CalendarAddPlayerFrameWhisper:Show()
	CalendarAddPlayerFrameWhisperRecent:SetText(pWhispers[table.getn(pWhispers)])
	
	if GroupCalendar.PlayerSettings.LastWhisperConfirmMessage then
		CalendarAddPlayerFrameWhisperReply:SetText(GroupCalendar.PlayerSettings.LastWhisperConfirmMessage)
	end
	
	if GroupCalendar.PlayerSettings.LastWhisperStatus then
		CalendarDropDown_SetSelectedValue(CalendarAddPlayerFrameStatusMenu, GroupCalendar.PlayerSettings.LastWhisperStatus)
	end
	
	local vColor = ChatTypeInfo["WHISPER"]
	
	CalendarAddPlayerFrameWhisperRecent:SetTextColor(vColor.r, vColor.g, vColor.b)
	CalendarAddPlayerFrameWhisperReply:SetTextColor(vColor.r, vColor.g, vColor.b)
	
	CalendarAddPlayerFrame:SetHeight(CalendarAddPlayerFrame.NormalHeight + CalendarAddPlayerFrameWhisper:GetHeight())
	
	CalendarAddPlayerFrame:Show()
	CalendarAddPlayerFrameName:SetFocus()
end

function CalendarAddPlayer_SaveNext()
	if CalendarAddPlayerFrame.IsWhisper then
		local vNextWhisper = GroupCalendar.WhisperLog:GetNextWhisper(CalendarAddPlayerFrame.Name)
		
		CalendarAddPlayer_Save()
		
		if vNextWhisper then
			CalendarAddPlayer_OpenWhisper(vNextWhisper.mName, vNextWhisper.mDate, vNextWhisper.mTime, vNextWhisper.mWhispers)
		else
			CalendarAddPlayer_Cancel()
		end
	else
		CalendarAddPlayer_Save()
		CalendarAddPlayer_Open()
	end
end

function CalendarAddPlayer_Delete()
	if not CalendarAddPlayerFrame.IsWhisper then
		return
	end
	
	local vNextWhisper = GroupCalendar.WhisperLog:GetNextWhisper(CalendarAddPlayerFrame.Name)
	
	GroupCalendar.WhisperLog:RemovePlayer(CalendarAddPlayerFrame.Name)
	
	if vNextWhisper then
		CalendarAddPlayer_OpenWhisper(vNextWhisper.mName, vNextWhisper.mDate, vNextWhisper.mTime, vNextWhisper.mWhispers)
	else
		CalendarAddPlayer_Cancel()
	end
end

function CalendarAddPlayer_EditRSVP(pRSVP)
	CalendarAddPlayer_Reset()
	
	CalendarAddPlayerFrame.RSVP = pRSVP
	CalendarAddPlayerFrameName:SetText(pRSVP.mName or "")
	CalendarAddPlayerFrameLevel:SetText(pRSVP.mLevel or "")
	CalendarDropDown_SetSelectedValue(CalendarAddPlayerFrameStatusMenu, pRSVP.mStatus)
	CalendarDropDown_SetSelectedValue(CalendarAddPlayerFrameRoleMenu, pRSVP.mRole)
	CalendarDropDown_SetSelectedValue(CalendarAddPlayerFrameClassMenu, pRSVP.mClassCode)
	CalendarDropDown_SetSelectedValue(CalendarAddPlayerFrameRaceMenu, pRSVP.mRaceCode)
	
	local vGuildRank = GroupCalendar.Database.MapGuildRank(pRSVP.mGuild, pRSVP.mGuildRank)
	
	CalendarDropDown_SetSelectedValue(CalendarAddPlayerFrameRankMenu, vGuildRank)
	
	if pRSVP.mComment then
		CalendarAddPlayerFrameComment:SetText(GroupCalendar.UnescapeString(pRSVP.mComment))
	end
	
	CalendarAddPlayerFrame:Show()
	CalendarAddPlayerFrameName:SetFocus()
end

function CalendarAddPlayer_Done()
	CalendarAddPlayer_Save()
	CalendarAddPlayerFrame:Hide()
end

function CalendarAddPlayer_Cancel()
	CalendarAddPlayerFrame:Hide()
end

function CalendarAddPlayer_Save()
	local vName = CalendarAddPlayerFrameName:GetText()
	
	if vName == "" then
		return
	end
	
	local vStatusCode = UIDropDownMenu_GetSelectedValue(CalendarAddPlayerFrameStatusMenu)
	local vRole = UIDropDownMenu_GetSelectedValue(CalendarAddPlayerFrameRoleMenu)
	local vClassCode = UIDropDownMenu_GetSelectedValue(CalendarAddPlayerFrameClassMenu)
	local vRaceCode = UIDropDownMenu_GetSelectedValue(CalendarAddPlayerFrameRaceMenu)
	local vLevel = tonumber(CalendarAddPlayerFrameLevel:GetText())
	local vComment = GroupCalendar.EscapeString(CalendarAddPlayerFrameComment:GetText())
	local vGuild = CalendarAddPlayerFrame.Guild
	local vGuildRank = UIDropDownMenu_GetSelectedValue(CalendarAddPlayerFrameRankMenu)
	
	if not vGuild then
		vGuild = GroupCalendar.PlayerGuild
	end
	
	if not vGuildRank then
		vGuild = nil
	end
	
	local vRSVP = GroupCalendar.Database.CreatePlayerRSVP(
							GroupCalendar.EventEditor.Database,
							GroupCalendar.EventEditor.Event,
							vName,
							vRaceCode,
							vClassCode,
							vLevel,
							vRole,
							vStatusCode,
							vComment,
							vGuild,
							vGuildRank,
							nil)
	
	if CalendarAddPlayerFrame.RSVP then
		-- if CalendarAddPlayerFrame.RSVP.mGuild then
		-- 	vRSVP.mGuild = CalendarAddPlayerFrame.RSVP.mGuild
		-- 	vRSVP.mGuildRank = CalendarAddPlayerFrame.RSVP.mGuildRank
		-- end
		
		vRSVP.mDate = CalendarAddPlayerFrame.RSVP.mDate
		vRSVP.mTime = CalendarAddPlayerFrame.RSVP.mTime
		vRSVP.mAlts = CalendarAddPlayerFrame.RSVP.mAlts
		
		-- Save the guild rank mapping
		
		GroupCalendar.Database.SetGuildRankMapping(
				CalendarAddPlayerFrame.RSVP.mGuild,
				CalendarAddPlayerFrame.RSVP.mGuildRank,
				vGuildRank)
	end
	
	--
	
	GroupCalendar.Database.AddEventRSVP(
			GroupCalendar.EventEditor.Database,
			GroupCalendar.EventEditor.Event,
			vName,
			vRSVP)
	
	if CalendarAddPlayerFrame.IsWhisper then
		GroupCalendar.WhisperLog:RemovePlayer(CalendarAddPlayerFrame.Name)
	end
	
	-- Send the reply /w if there is one
	
	if CalendarAddPlayerFrameWhisper:IsVisible() then
		local vReplyWhisper = CalendarAddPlayerFrameWhisperReply:GetText()
		
		if vReplyWhisper and vReplyWhisper ~= "" then
			GroupCalendar.PlayerSettings.LastWhisperConfirmMessage = vReplyWhisper
			SendChatMessage(vReplyWhisper, "WHISPER", nil, CalendarAddPlayerFrame.Name)
		end
		
		-- Remember what status was used
		
		GroupCalendar.PlayerSettings.LastWhisperStatus = UIDropDownMenu_GetSelectedValue(CalendarAddPlayerFrameStatusMenu)
		
		-- Remember what role was used for this class (to be implemented)
		
		GroupCalendar.PlayerSettings.LastWhisperRole = UIDropDownMenu_GetSelectedValue(CalendarAddPlayerFrameRoleMenu)
	end
	
	-- Remember the role setting
	
	local vDatabase = GroupCalendar.Database.GetDatabase(vName)
	
	if vDatabase then
		vDatabase.DefaultRole = vRole
	end
end

function CalendarAddPlayer_AutoCompletePlayerInfo()
	local vName = CalendarAddPlayerFrameName:GetText()
	local vUpperName = strupper(vName)
	
	local vGuildMemberIndex = GroupCalendar.Network:GetGuildMemberIndex(vName)
	
	if vGuildMemberIndex then
		local vMemberName, vRank, vRankIndex, vLevel, vClass, vZone, vNote, vOfficerNote, vOnline = GetGuildRosterInfo(vGuildMemberIndex)
		
		CalendarAddPlayerFrameName:SetText(vMemberName)
		CalendarAddPlayerFrameLevel:SetText(vLevel)
		CalendarAddPlayerFrameClassMenu:SetSelectedValue(GroupCalendar.Database.GetClassCodeByClass(vClass))
		-- CalendarAddPlayerFrameRaceMenu:SetSelectedValue(GroupCalendar.Database.GetRaceCodeByRace(vRace))
		CalendarAddPlayerFrameRankMenu:SetSelectedValue(vRankIndex)
		
		CalendarAddPlayerFrame.Guild = GroupCalendar.PlayerGuild
		
		CalendarAddPlayerFrameRoleMenu:SetSelectedValue(GroupCalendar.GetMemberDefaultRole(vMemberName))
		
		return true
	end
	
	local vNumFriends = GetNumFriends()
	
	for vFriendIndex = 1, vNumFriends do
		local vFriendName, vLevel, vClass, vArea, vConnected = GetFriendInfo(vFriendIndex)
		
		if strupper(vFriendName) == vUpperName then
			if vConnected then
				CalendarAddPlayerFrameName:SetText(vFriendName)
				CalendarAddPlayerFrameLevel:SetText(vLevel)
				CalendarAddPlayerFrameClassMenu:SetSelectedValue(GroupCalendar.Database.GetClassCodeByClass(vClass))
				-- CalendarAddPlayerFrameRaceMenuSetSelectedValue(GroupCalendar.Database.GetRaceCodeByRace(vRace))
			end
			
			CalendarAddPlayerFrameRoleMenu:SetSelectedValue(GroupCalendar.GetMemberDefaultRole(vFriendName, vClass))
		end
		
		return
	end
	
	return false
end

function CalendarAddPlayerWhisper_OnEnter()
	if not CalendarAddPlayerFrame.IsWhisper then
		return
	end
	
	GroupCalendar.AttendanceViewer.ShowMessageTooltip(
			this,
			CalendarAddPlayerFrame.Name,
			CalendarAddPlayerFrame.Whispers,
			ChatTypeInfo["WHISPER"])
end

function CalendarAddPlayerWhisper_OnLeave()
	GameTooltip:Hide()
end

function CalendarAddPlayerWhisper_Reply()
	local vName
	
	if CalendarAddPlayerFrame.Name then
		vName = CalendarAddPlayerFrame.Name
	else
		vName = CalendarAddPlayerFrameName:GetText()
	end

	if not vName or vName == "" then
		return
	end
	
	DEFAULT_CHAT_FRAME.editBox:SetAttribute("chatType", "WHISPER")
	DEFAULT_CHAT_FRAME.editBox:SetAttribute("tellTarget", vName)
	
	ChatEdit_UpdateHeader(DEFAULT_CHAT_FRAME.editBox)
	
	if not DEFAULT_CHAT_FRAME.editBox:IsVisible() then
		ChatFrame_OpenChat("", DEFAULT_CHAT_FRAME)
	end
end

function CalendarRoleClassLimitItem_SetClassName(pItem, pClassName)
	local vItemName = pItem:GetName()
	local vMinEditBox = getglobal(vItemName.."Min")
	
	local vColor = RAID_CLASS_COLORS[getglobal("GroupCalendar_c"..pClassName.."ClassColorName")]
	
	vMinEditBox:SetTextColor(vColor.r, vColor.g, vColor.b)
end

function CalendarScrollbarTrench_SizeChanged(pScrollbarTrench)
	local vScrollbarTrenchName = pScrollbarTrench:GetName()
	local vScrollbarTrenchMiddle = getglobal(vScrollbarTrenchName.."Middle")
	
	local vMiddleHeight= pScrollbarTrench:GetHeight() - 51
	vScrollbarTrenchMiddle:SetHeight(vMiddleHeight)
end

GroupCalendar.cAttendanceCategories =
{
	PENDING = GroupCalendar_cPendingApprovalCategory,
	YES = GroupCalendar_cAttendingCategory,
	STANDBY = GroupCalendar_cStandbyCategory,
	MAYBE = GroupCalendar_cMaybeCategory,
	NO = GroupCalendar_cNotAttendingCategory,
	QUEUED = GroupCalendar_cQueuedCategory,
	WHISPERS = GroupCalendar_cWhispersCategory,
	BANNED = GroupCalendar_cBannedCategory,
}

function GroupCalendar.GetClassCodeColor(pClassCode)
	if not pClassCode then
		return NORMAL_FONT_COLOR
	end
	
	local vClassInfo = GroupCalendar.ClassInfoByClassCode[pClassCode]
	
	if not vClassInfo then
		return NORMAL_FONT_COLOR
	end
	
	local vClassColorName = getglobal("GroupCalendar_c"..vClassInfo.element.."ClassColorName")
	
	return RAID_CLASS_COLORS[vClassColorName]
end

