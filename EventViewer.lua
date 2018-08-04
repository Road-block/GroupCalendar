GroupCalendar._EventViewer = {}

GroupCalendar._EventViewer.Widgets =
{
	EventFrame =
	{
		"Title",
		"DateTime",
		"Levels",
		"Desc",
		"CharacterMenu",
		RoleMenu = {"Title"},
		"Yes",
		"No",
		"Maybe",
		"Comment",
		"Status",
		"Background"
	},
	"AttendanceFrame",
	"AttendanceFrameList",
	"Parchment",
	"Tab1",
	"Tab2",
}

function GroupCalendar._EventViewer:Construct()
	self.ShowScheduleEditor = false
	self.Active = false

	self.Database = nil
	self.Event = nil
	self.SelectedPlayerDatabase = nil

	self.PanelFrames =
	{
		self.Widgets.EventFrame,
		self.Widgets.AttendanceFrame,
	}
	
	self.CurrentPanel = 1

	-- Tabs
	
	PanelTemplates_SetNumTabs(this, table.getn(self.PanelFrames))
	self.selectedTab = self.CurrentPanel
	PanelTemplates_UpdateTabs(this)
	
	self.Widgets.EventFrame.CharacterMenu.EventViewer = self
	self.Widgets.EventFrame.CharacterMenu.ChangedValueFunc = self.SelectedCharacterChanged
	self.Widgets.EventFrame.RoleMenu.Title:Hide()
end

function GroupCalendar._EventViewer:ViewEvent(pDatabase, pEvent)
	self.Database = pDatabase
	self.Event = pEvent
	self.SelectedPlayerDatabase = GroupCalendar.UserDatabase
	
	self.Widgets.AttendanceFrameList:SetEvent(pDatabase, pEvent)
	self:UpdateControlsFromEvent(self.Event, false)
	
	ShowUIPanel(self)
	
	CalendarEventTitle:SetFocus()
	CalendarEventTitle:HighlightText(0, 100)
	
	self.ShowScheduleEditor = false
	self.Active = true
end

function GroupCalendar._EventViewer:DoneViewing()
	if not self.Active then
		return
	end
	
	self:Close(true)
end

function GroupCalendar._EventViewer:ScheduleChanged(pDate)
	if self.Active and self.Event.mDate == pDate then
		self.Widgets.AttendanceFrameList:EventChanged(self.Database, self.Event)
		self:UpdateControlsFromEvent(self.Event, true)
	end
end

function GroupCalendar._EventViewer:MajorDatabaseChange()
	if not self.Active then return end
	
	self.Widgets.AttendanceFrameList:EventChanged(self.Database, self.Event)
	self:UpdateControlsFromEvent(self.Event, true)
end

function GroupCalendar._EventViewer:Save()
	-- Save attendance feedback
	
	if GroupCalendar.Database.EventTypeUsesAttendance(self.Event.mType)
	and GroupCalendar.Database.PlayerIsQualifiedForEvent(self.Event, self.SelectedPlayerDatabase.PlayerLevel) then
		local vPendingRSVP = GroupCalendar.Database.FindLastRSVPRequestData(self.SelectedPlayerDatabase, self.Database.UserName, self.Event.mID)
		local vEventRSVP = GroupCalendar.Database.FindEventRSVP(self.Database.UserName, self.Event, self.SelectedPlayerDatabase.UserName)
		local vChanged = false
		local vStatus
		local vComment
		
		if vEventRSVP and vEventRSVP.mStatus == "-" then
			return -- Don't do anything for a banned player
		end
		
		if not vPendingRSVP then
			if vEventRSVP then
				vStatus = vEventRSVP.mStatus
				vComment = vEventRSVP.mComment
				vRole = vEventRSVP.mRole
			else
				vStatus = nil
				vComment = ""
			end
		else
			vStatus = vPendingRSVP.mStatus
			vComment = vPendingRSVP.mComment
			vRole = vPendingRSVP.mRole
		end
		
		if not vComment then
			vComment = ""
		end
		
		if not vRole then
			vRole = "?"
		end
		
		-- Update the status
		
		local vNewStatus = self:GetStatusFromControls()
		
		if not vNewStatus and (vPendingRSVP or vEventRSVP) then
			vNewStatus = "C" -- Cancel the existing request
		end
		
		if vNewStatus ~= vStatus then
			vStatus = vNewStatus
			vChanged = true
		end
		
		-- Update the role
		
		if vNewStatus then
			local vNewRole = UIDropDownMenu_GetSelectedValue(self.Widgets.EventFrame.RoleMenu)
			
			if vRole ~= vNewRole then
				vRole = vNewRole
				vChanged = true
			end
		end
		
		-- Update the comment
		
		if vNewStatus then
			local vNewComment = GroupCalendar.EscapeString(self.Widgets.EventFrame.Comment:GetText())
			
			if vComment ~= vNewComment then
				vComment = vNewComment
				vChanged = true
			end
		end
		
		-- Add a new RSVP if it's changed
		
		if vChanged then
			local vRSVP = GroupCalendar.Database.CreatePlayerRSVP(
									self.Database,
									self.Event,
									self.SelectedPlayerDatabase.UserName,
									self.SelectedPlayerDatabase.PlayerRaceCode,
									self.SelectedPlayerDatabase.PlayerClassCode,
									self.SelectedPlayerDatabase.PlayerLevel,
									vRole,
									vStatus,
									vComment,
									GroupCalendar.PlayerGuild,
									GroupCalendar.PlayerGuildRank,
									GroupCalendar.PlayerCharacters)
			
			GroupCalendar.Database.AddRSVP(self.SelectedPlayerDatabase, vRSVP)
			
			-- Update the UI
			
			self.Widgets.AttendanceFrameList:EventChanged(self.Database, self.Event)
			self:UpdateControlsFromEvent(self.Event, false)
			
			-- Note the change in the chat window
			-- TODO: Turning this off for now, I don't think it'll be necessary with the
			-- new network code in GC4
						
			-- GroupCalendar:NoteMessage(GroupCalendar_cAttendanceNote, GroupCalendar.Database.GetEventDisplayName(self.Event))
		end
		
		-- Save the preferred role
		
		if vRole ~= "?" then
			self.SelectedPlayerDatabase.DefaultRole = vRole
		end
	end
end

function GroupCalendar._EventViewer:GetStatusFromControls()
	if self.Widgets.EventFrame.Yes:GetChecked() then
		return "Y"
	elseif self.Widgets.EventFrame.No:GetChecked() then
		return "N"
	elseif self.Widgets.EventFrame.Maybe:GetChecked() then
		return "S"
	end
end

function GroupCalendar._EventViewer:Close(pShowScheduleEditor)
	self.ShowScheduleEditor = pShowScheduleEditor
	HideUIPanel(self)
end

function GroupCalendar._EventViewer:OnShow()
	PlaySound("igCharacterInfoOpen")
	
	self:ShowPanel(1) -- Always switch to the event view when showing the window
end

function GroupCalendar._EventViewer:OnHide()
	PlaySound("igCharacterInfoClose")
	
	self:Save()
	
	if not self.ShowScheduleEditor then
		HideUIPanel(CalendarEditorFrame)
	end
	
	self.Database = nil
	self.Event = nil
	
	self.Active = false
end

function GroupCalendar._EventViewer.SelectedCharacterChanged(pMenuFrame, pValue)
	pMenuFrame.EventViewer.SelectedPlayerDatabase = GroupCalendar.Database.GetDatabase(pValue, false)
	GroupCalendar.EventViewer:UpdateControlsFromEvent(pMenuFrame.EventViewer.Event, false)
end

function GroupCalendar._EventViewer:UpdateControlsFromEvent(pEvent, pSkipAttendanceFields)
	-- Update the title
	
	self.Widgets.EventFrame.Title:SetText(GroupCalendar.Database.GetEventDisplayName(pEvent))
	
	-- Update the date and time
	
	local vDateTimeString
	
	if pEvent.mTime ~= nil then
		local vTime
		local vDate = pEvent.mDate
		
		if gGroupCalendar_Settings.ShowEventsInLocalTime then
			vDate, vTime = MCDateLib:GetLocalDateTimeFromServerDateTime(pEvent.mDate, pEvent.mTime)
		else
			vTime = pEvent.mTime
		end
		
		local vDateString = GroupCalendar.GetLongDateString(vDate)
		
		if pEvent.mDuration ~= nil
		and pEvent.mDuration ~= 0 then
			local vEndTime = math.mod(vTime + pEvent.mDuration, 1440)
			
			vDateTimeString = string.format(
								GroupCalendar_cTimeDateRangeFormat,
								vDateString,
								GroupCalendar.GetShortTimeString(vTime),
								GroupCalendar.GetShortTimeString(vEndTime))
		else
			vDateTimeString = string.format(
								GroupCalendar_cSingleTimeDateFormat,
								vDateString,
								GroupCalendar.GetShortTimeString(vTime))
		end
	else
		vDateTimeString = GroupCalendar.GetLongDateString(pEvent.mDate)
	end
	
	self.Widgets.EventFrame.DateTime:SetText(vDateTimeString)
	
	-- Update the level range
	
	if GroupCalendar.Database.EventTypeUsesLevelLimits(pEvent.mType) then
		if pEvent.mMinLevel ~= nil then
			if pEvent.mMaxLevel ~= nil then
				if pEvent.mMinLevel == pEvent.mMaxLevel then
					self.Widgets.EventFrame.Levels:SetText(string.format(CalendarEventViewer_cSingleLevel, pEvent.mMinLevel))
				else
					self.Widgets.EventFrame.Levels:SetText(string.format(CalendarEventViewer_cLevelRangeFormat, pEvent.mMinLevel, pEvent.mMaxLevel))
				end
			else
				if pEvent.mMinLevel == 60 then
					self.Widgets.EventFrame.Levels:SetText(string.format(CalendarEventViewer_cSingleLevel, pEvent.mMinLevel))
				else
					self.Widgets.EventFrame.Levels:SetText(string.format(CalendarEventViewer_cMinLevelFormat, pEvent.mMinLevel))
				end
			end
			
			self.Widgets.EventFrame.Levels:Show()
		else
			if pEvent.mMaxLevel ~= nil then
				self.Widgets.EventFrame.Levels:SetText(string.format(CalendarEventViewer_cMaxLevelFormat, pEvent.mMaxLevel))
			else
				self.Widgets.EventFrame.Levels:SetText(CalendarEventViewer_cAllLevels)
			end
			
			self.Widgets.EventFrame.Levels:Show()
		end
		
		if GroupCalendar.Database.PlayerIsQualifiedForEvent(self.Event, self.SelectedPlayerDatabase.PlayerLevel) then
			self.Widgets.EventFrame.Levels:SetTextColor(1.0, 0.82, 0)
		else
			self.Widgets.EventFrame.Levels:SetTextColor(1.0, 0.2, 0.2)
		end
	else
		self.Widgets.EventFrame.Levels:Hide()
	end
	
	-- Update the description
	
	if pEvent.mDescription then
		self.Widgets.EventFrame.Desc:SetText(GroupCalendar.UnescapeString(pEvent.mDescription))
		self.Widgets.EventFrame.Desc:Show()
	else
		self.Widgets.EventFrame.Desc:Hide()
	end
	
	-- Update the attendance
	
	if GroupCalendar.Database.EventTypeUsesAttendance(pEvent.mType) then
		local vIsAttending = false
		local vIsStandby = false
		local vIsNotAttending = false
		local vAttendanceComment = ""
		local vRole = GroupCalendar.GetMemberDefaultRole(self.SelectedPlayerDatabase.UserName)
		
		self:SetAttendanceVisible(true)
		
		if not pSkipAttendanceFields then
			self.Widgets.EventFrame.CharacterMenu:SetSelectedValue(self.SelectedPlayerDatabase.UserName)
		end
		
		if GroupCalendar.Database.PlayerIsQualifiedForEvent(self.Event, self.SelectedPlayerDatabase.PlayerLevel) then
			self:SetAttendanceEnabled(true)
			
			local vPendingRSVP = GroupCalendar.Database.FindLastRSVPRequestData(self.SelectedPlayerDatabase, self.Database.UserName, self.Event.mID)
			local vEventRSVP = GroupCalendar.Database.FindEventRSVP(self.Database.UserName, self.Event, self.SelectedPlayerDatabase.UserName)
			local vRSVP
			
			if (vEventRSVP and vEventRSVP.mStatus == "-")
			or not vPendingRSVP then
				vRSVP = vEventRSVP
			else
				vRSVP = vPendingRSVP
			end
			
			
			if vRSVP then
				vIsAttending = vRSVP.mStatus == "Y"
				vIsNotAttending = vRSVP.mStatus == "N"
				vIsStandby = vRSVP.mStatus == "S"
				
				if vRSVP.mComment then
					vAttendanceComment = GroupCalendar.UnescapeString(vRSVP.mComment)
				end
				
				if vRSVP.mRole and vRSVP.mRole ~= "?" then
					vRole = vRSVP.mRole
				end
			end
			
			self:SetResponseStatus(vPendingRSVP, vEventRSVP)
			
			if vEventRSVP and vEventRSVP.mStatus == "-" then
				self.Widgets.EventFrame.Yes:Hide()
				self.Widgets.EventFrame.No:Hide()
				self.Widgets.EventFrame.Maybe:Hide()
				self.Widgets.EventFrame.Comment:Hide()
				self.Widgets.EventFrame.CharacterMenu:Hide()
				self.Widgets.EventFrame.RoleMenu:Hide()
			else
				self.Widgets.EventFrame.Yes:Show()
				self.Widgets.EventFrame.No:Show()
				self.Widgets.EventFrame.Maybe:Show()
				self.Widgets.EventFrame.Comment:Show()
				self.Widgets.EventFrame.CharacterMenu:Show()
				self.Widgets.EventFrame.RoleMenu:Show()
				
				if pEvent.mLimits then
					self.Widgets.EventFrame.RoleMenu.RoleLimits = pEvent.mLimits.mRoleLimits
				else
					self.Widgets.EventFrame.RoleMenu.RoleLimits = nil
				end
			end
			
			--
			
			if pSkipAttendanceFields then
				local vNewStatus = self:GetStatusFromControls()
				
				if self.PreviousStatus == vNewStatus then
					self.Widgets.EventFrame.Yes:SetChecked(vIsAttending)
					self.Widgets.EventFrame.No:SetChecked(vIsNotAttending)
					self.Widgets.EventFrame.Maybe:SetChecked(vIsStandby)
					self.Widgets.EventFrame.RoleMenu:SetSelectedValue(vRole)
				end
			else
				self.Widgets.EventFrame.Yes:SetChecked(vIsAttending)
				self.Widgets.EventFrame.No:SetChecked(vIsNotAttending)
				self.Widgets.EventFrame.Maybe:SetChecked(vIsStandby)
				self.Widgets.EventFrame.RoleMenu:SetSelectedValue(vRole)
				
				self.Widgets.EventFrame.Comment:SetText(vAttendanceComment)
				self:UpdateCommentEnable()
			end
			
			if vRSVP then
				self.PreviousStatus = vRSVP.mStatus
			else
				self.PreviousStatus = nil
			end
		else
			self:SetAttendanceEnabled(false)
		end
	else
		self:SetAttendanceVisible(false)
	end
	
	if pEvent.mType ~= nil then
		self.Widgets.EventFrame.Background:SetTexture(GroupCalendar.GetEventTypeIconPath(pEvent.mType))
		if pEvent.mType == "Birth" then
			self.Widgets.EventFrame.Background:SetVertexColor(1, 1, 1, 0.8)
		else
			self.Widgets.EventFrame.Background:SetVertexColor(1, 1, 1, 0.19)
		end
	else
		self.Widgets.EventFrame.Background:SetTexture("")
	end
end

function GroupCalendar._EventViewer:UpdateCommentEnable()
	local vEnable = self.Widgets.EventFrame.Yes:GetChecked()
	               or self.Widgets.EventFrame.No:GetChecked()
	               or self.Widgets.EventFrame.Maybe:GetChecked()
	
	GroupCalendar.SetEditBoxEnable(self.Widgets.EventFrame.Comment, vEnable)
end

function GroupCalendar._EventViewer:SetAttendanceEnabled(pEnable)
	GroupCalendar.SetCheckButtonEnable(self.Widgets.EventFrame.Yes, pEnable)
	GroupCalendar.SetCheckButtonEnable(self.Widgets.EventFrame.No, pEnable)
	GroupCalendar.SetCheckButtonEnable(self.Widgets.EventFrame.Maybe, pEnable)
	GroupCalendar.SetEditBoxEnable(self.Widgets.EventFrame.Comment, pEnable)
	
	if pEnable then
		self.Widgets.EventFrame.Status:Show()
	else
		self.Widgets.EventFrame.Status:Hide()
	end
end

function GroupCalendar._EventViewer:SetAttendanceVisible(pVisible)
	if pVisible then
		self.Widgets.EventFrame.CharacterMenu:Show()
		self.Widgets.EventFrame.RoleMenu:Show()
		self.Widgets.EventFrame.Yes:Show()
		self.Widgets.EventFrame.No:Show()
		self.Widgets.EventFrame.Maybe:Show()
		self.Widgets.EventFrame.Comment:Show()
		self.Widgets.EventFrame.Status:Show()
		self.Widgets.Tab2:Show()
	else
		self.Widgets.EventFrame.CharacterMenu:Hide()
		self.Widgets.EventFrame.RoleMenu:Hide()
		self.Widgets.EventFrame.Yes:Hide()
		self.Widgets.EventFrame.No:Hide()
		self.Widgets.EventFrame.Maybe:Hide()
		self.Widgets.EventFrame.Comment:Hide()
		self.Widgets.EventFrame.Status:Hide()
		self.Widgets.Tab2:Hide()
	end
end

function GroupCalendar._EventViewer:CalculateResponseStatus(pPendingRSVP, pEventRSVP)
	if (pEventRSVP and pEventRSVP.mStatus == "-") then
		return 6 -- Banned
	elseif pPendingRSVP then
		return 2 -- Pending
	elseif pEventRSVP then
		if pEventRSVP.mStatus == "Y" then
			return 3
		elseif pEventRSVP.mStatus == "S" then
			return 4
		elseif pEventRSVP.mStatus == "N" then
			return 5
		end
	else
		return 1
	end
end

function GroupCalendar._EventViewer:SetResponseStatus(pPendingRSVP, pEventRSVP)
	local vStatus = self:CalculateResponseStatus(pPendingRSVP, pEventRSVP)
	
	self.Widgets.EventFrame.Status:SetText(CalendarEventViewer_cResponseMessage[vStatus])
end

function GroupCalendar._EventViewer:ShowPanel(pPanelIndex)
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

		self.Widgets.Parchment:Show()
		
	elseif pPanelIndex == 2 then
		-- Attendance panel
		
		self.Widgets.Parchment:Hide()
		
		if GroupCalendar.Database.IsQuestingEventType(self.Event.mType) then
			self.Widgets.AttendanceFrameList:SetTotalsVisible(true, false)
		else
			self.Widgets.AttendanceFrameList:SetTotalsVisible(false, false)
		end
	else
		GroupCalendar:DebugMessage("EventViewer:ShowPanel: Unknown index ("..pPanelIndex..")")
	end
	
	self.PanelFrames[pPanelIndex]:Show()
	
	PanelTemplates_SetTab(self, pPanelIndex)
end

function GroupCalendar._EventViewer:HidePanel(pFrameIndex)
	if self.CurrentPanel ~= pFrameIndex then
		return
	end
	
	self:Save()
	
	self.PanelFrames[pFrameIndex]:Hide()
	self.CurrentPanel = 0
end

