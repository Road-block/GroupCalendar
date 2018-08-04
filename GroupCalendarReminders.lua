-- File to handle all the Reminder work

GroupCalendar.Reminders = nil

local GroupCalendar_cReminderIntervals = {0, 60, 300, 900, 1800, 3600}
local GroupCalendar_cNumReminderIntervals = table.getn(GroupCalendar_cReminderIntervals)

function GroupCalendar:SetReminderOption(pOption)
	if string.lower(pOption) == "off" then
		gGroupCalendar_Settings.DisableReminders = true
		GroupCalendar:NoteMessage("Reminders disabled")
	elseif string.lower(pOption) == "on" then
		gGroupCalendar_Settings.DisableReminders = nil
		GroupCalendar:NoteMessage("Reminders enabled")
		GroupCalendar_CalculateReminders()
	else
		GroupCalendar:ErrorMessage("GroupCalendar: Unknown reminder option, use 'on' or 'off'")
	end
end

function GroupCalendar:SetBirthdaysOption(pOption)
	if string.lower(pOption) == "off" then
		gGroupCalendar_Settings.DisableBirthdayReminders = true
		GroupCalendar:NoteMessage("Birthday reminders disabled")
	elseif string.lower(pOption) == "on" then
		gGroupCalendar_Settings.DisableBirthdayReminders = nil
		GroupCalendar:NoteMessage("Birthday reminders enabled")
		GroupCalendar_CalculateReminders()
	else
		GroupCalendar:ErrorMessage("GroupCalendar: Unknown birthday option, use 'on' or 'off'")
	end
end

function GroupCalendar_EventNeedsReminder(pEvent, pOwner, pCurrentDateTimeStamp)
	-- Don't remind for events they're not attending
	
	if GroupCalendar.Database.EventTypeUsesAttendance(pEvent.mType) then
		local vAttending = GroupCalendar.Database.PlayerIsAttendingEvent(pOwner, pEvent)
		
		if not vAttending
		or vAttending == "CONFIRMED_STANDBY"
		or vAttending == "REQUESTED_STANDBY"
		or vAttending == "CONFIRMED_MAYBE"
		or vAttending == "REQUESTED_MAYBE" then
			return false
		end
	end
	
	-- Don't remind for events which don't have a start time (birthdays and vacations)
	
	if not GroupCalendar.Database.EventTypeUsesTime(pEvent.mType) then
		return false
	end
	
	-- Don't remind if all reminders have been issued
	
	if pEvent.ReminderIndex == 0 then
		return false
	end
	
	-- Don't remind if the event has passed
	
	if pEvent.mDuration
	and GroupCalendar_GetTimeToEvent(pEvent, pCurrentDateTimeStamp) + pEvent.mDuration * 60 < 0 then
		return false
	end
	
	-- Don't remind for dungeon resets
	
	if GroupCalendar.Database.IsDungeonResetEventType(pEvent.mType) then
		return false
	end
	
	return true
end

function GroupCalendar_CalculateReminders()
	-- Gather up events
	
	local vCurrentDate, vCurrentTime = MCDateLib:GetServerDateTime()
	local vCurrentDateTimeStamp = vCurrentDate * 86400 + vCurrentTime * 60
	
	GroupCalendar.DeleteTable(GroupCalendar.Reminders, 1)
	
	GroupCalendar.Reminders = GroupCalendar.Database.GetCompiledSchedule(vCurrentDate - 1, true, true)
	GroupCalendar.Reminders = GroupCalendar.Database.GetCompiledSchedule(vCurrentDate, true, true, GroupCalendar.Reminders)
	GroupCalendar.Reminders = GroupCalendar.Database.GetCompiledSchedule(vCurrentDate + 1, true, true, GroupCalendar.Reminders)
	
	-- Strip out events which don't need reminders
	
	local vLastIndex = table.getn(GroupCalendar.Reminders)
	local vIndex = 1
	
	while vIndex <= vLastIndex do
		local vCompiledEvent = GroupCalendar.Reminders[vIndex]
		
		if not GroupCalendar_EventNeedsReminder(vCompiledEvent.mEvent, vCompiledEvent.mOwner, vCurrentDateTimeStamp) then
			table.remove(GroupCalendar.Reminders, vIndex)
			vLastIndex = vLastIndex - 1
		else
			if not vCompiledEvent.mEvent.ReminderIndex then
				vCompiledEvent.mEvent.ReminderIndex = GroupCalendar_cNumReminderIntervals
			end
			
			vIndex = vIndex + 1
		end
	end
	
	-- GroupCalendar_DumpReminders()
	
	-- Calculate the time to the first event
	
	GroupCalendar_DoReminders()
end

function GroupCalendar_GetCompiledEventReminderInterval(pCompiledEvent, pCurrentDateTimeStamp)
	local vTimeRemaining = GroupCalendar_GetTimeToEvent(pCompiledEvent.mEvent, pCurrentDateTimeStamp)
	local vReminderIntervalPassed = false
	
	while (vTimeRemaining - GroupCalendar_cReminderIntervals[pCompiledEvent.mEvent.ReminderIndex]) <= 0 do
		pCompiledEvent.mEvent.ReminderIndex = pCompiledEvent.mEvent.ReminderIndex - 1
		
		if pCompiledEvent.mEvent.ReminderIndex > 0 then
			vReminderIntervalPassed = true
			vTimeRemaining = GroupCalendar_GetTimeToEvent(pCompiledEvent.mEvent, pCurrentDateTimeStamp)
		else
			return nil, vTimeRemaining, vReminderIntervalPassed
		end
	end
	
	return vTimeRemaining - GroupCalendar_cReminderIntervals[pCompiledEvent.mEvent.ReminderIndex], vTimeRemaining, vReminderIntervalPassed
end

function GroupCalendar_DoReminders()
	local vCurrentDateTimeStamp = MCDateLib:GetServerDateTimeStamp()
	local vMinTimeRemaining = nil
	local vIndex = 1
	
	if not gGroupCalendar_Settings.DisableReminders then
		while vIndex <= table.getn(GroupCalendar.Reminders) do
			local vCompiledEvent = GroupCalendar.Reminders[vIndex]
			local vReminderTimeRemaining, vTimeRemaining, vReminderIntervalPassed = GroupCalendar_GetCompiledEventReminderInterval(vCompiledEvent, vCurrentDateTimeStamp)
			
			if vIndex == 1 then
				if vTimeRemaining <= 3600 then -- Show the icon for one hour before the event
					GroupCalendar.Calendar.ShowReminderIcon(GroupCalendar.GetEventTypeIconPath(vCompiledEvent.mEvent.mType))
				else
					GroupCalendar.Calendar.HideReminderIcon()
				end
			end
			
			if vReminderIntervalPassed then
				local vReminderTime = GroupCalendar_cReminderIntervals[vCompiledEvent.mEvent.ReminderIndex + 1]
				
				if vReminderTime == 0 then
					if vCompiledEvent.mEvent.mType == "Birth" then
						if not not gGroupCalendar_Settings.DisableBirthdayReminders then
							if vCompiledEvent.mEvent.mTitle then
								GroupCalendarMessages:AddMessage(GroupCalendar.Database.GetEventDisplayName(vCompiledEvent.mEvent))
							else
								GroupCalendarMessages:AddMessage(string.format(GroupCalendar_cHappyBirthdayFormat, vCompiledEvent.mOwner))
							end
						end
					elseif GroupCalendar.Database.IsResetEventType(vCompiledEvent.mEvent.mType) then
						GroupCalendarMessages:AddMessage(GroupCalendar.Database.GetEventDisplayName(vCompiledEvent.mEvent))
					elseif vTimeRemaining < -120 then
						GroupCalendarMessages:AddMessage(string.format(GroupCalendar_cAlreadyStartedFormat, GroupCalendar.Database.GetEventDisplayName(vCompiledEvent.mEvent)))
					else
						GroupCalendarMessages:AddMessage(string.format(GroupCalendar_cStartingNowFormat, GroupCalendar.Database.GetEventDisplayName(vCompiledEvent.mEvent)))
					end
				else
					local vMinutesRemaining = math.floor(vTimeRemaining / 60 + 0.5)
					local vFormat
					
					if GroupCalendar.Database.IsResetEventType(vCompiledEvent.mEvent.mType) then
						if vMinutesRemaining == 1 then
							vFormat = GroupCalendar_cAvailableMinuteFormat
						else
							vFormat = GroupCalendar_cAvailableMinutesFormat
						end
					else
						if vMinutesRemaining == 1 then
							vFormat = GroupCalendar_cStartsMinuteFormat
						else
							vFormat = GroupCalendar_cStartsMinutesFormat
						end
					end
					
					GroupCalendarMessages:AddMessage(string.format(vFormat, GroupCalendar.Database.GetEventDisplayName(vCompiledEvent.mEvent), vMinutesRemaining))
				end
			end

			if vReminderTimeRemaining then
				if not vMinTimeRemaining or vReminderTimeRemaining < vMinTimeRemaining then
					vMinTimeRemaining = vReminderTimeRemaining
				end
				
				if vCompiledEvent.mEvent.ReminderIndex == GroupCalendar_cNumReminderIntervals then
					break
				end
				
				vIndex = vIndex + 1
			else
				table.remove(GroupCalendar.Reminders, vIndex)
			end
		end -- while
	end
	
	--
	
	MCSchedulerLib:UnscheduleTask(GroupCalendar_DoReminders)
	
	if vMinTimeRemaining then
		MCSchedulerLib:ScheduleTask(vMinTimeRemaining, GroupCalendar_DoReminders, nil, "GroupCalendar_DoReminders")
	else
		GroupCalendar.Calendar.HideReminderIcon()
	end
end

function GroupCalendar_DumpReminders()
	GroupCalendar:DebugTable("Reminders", GroupCalendar.Reminders)
end

function GroupCalendar_GetTimeToEvent(pEvent, pCurrentDateTimeStamp)
	if not pOffset then
		pOffset = 0
	end
	
	local vEventDateTimeStamp = pEvent.mDate * 86400
	
	if pEvent.mTime then
		vEventDateTimeStamp = vEventDateTimeStamp + pEvent.mTime * 60
	end
	
	return vEventDateTimeStamp - pCurrentDateTimeStamp
end
