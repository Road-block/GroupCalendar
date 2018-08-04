GroupCalendar.Invites =
{
	Event = nil,
	Status = nil,
	Group = nil,
	Inviting = false,
	ChangedFunc = nil,
	ChangedFuncParam = nil,
	GroupChanged = false,
	MaxInvitesPerTimeSlice = 1,
	InvitationSliceInterval = 0.2,
}

GroupCalendar_cInviteStatusMessages =
{
	NeedSelection      = GroupCalendar_cInviteNeedSelectionStatus,
	Ready              = GroupCalendar_cInviteReadyStatus,
	InitialInvites     = GroupCalendar_cInviteInitialInvitesStatus,
	AwaitingAcceptance = GroupCalendar_cInviteAwaitingAcceptanceStatus,
	ConvertingToRaid   = GroupCalendar_cInviteConvertingToRaidStatus,
	Inviting           = GroupCalendar_cInviteInvitingStatus,
	Complete           = GroupCalendar_cInviteCompleteStatus,
	ReadyToRefill      = GroupCalendar_cInviteReadyToRefillStatus,
-- The "no more available" message is kind of useless, so for now
-- I'm just showing it as completed instead until I figure out a 
-- better use for that state
	NoMoreAvailable    = GroupCalendar_cInviteNoMoreAvailableStatus,
--	NoMoreAvailable    = GroupCalendar_cInviteCompleteStatus,
	RaidFull           = GroupCalendar_cRaidFull,
}

function GroupCalendar.Invites:BeginEvent(pDatabase, pEvent)
	-- Just return if it's still the same event
	
	if pEvent == self.Event then
		return
	end
	
	if self.Event then
		self:EndEvent(self.Event)
	end
	
	self.Database = pDatabase
	self.Event = pEvent
	self.Limits = pEvent.mLimits
	
	if not self.Limits then
		local vEventInfo = GroupCalendar.Database.GetEventInfoByID(pEvent.mType)
		
		if vEventInfo and vEventInfo.limits then
			self.Limits = vEventInfo.limits
		end
	end
	
	if self.Limits
	and not self.Limits.mPriorityOrder then
		if not GroupCalendar.PlayerSettings.AutoSelectPriorityOrder then
			GroupCalendar.PlayerSettings.AutoSelectPriorityOrder = "Date"
		end
		
		self.Limits.mPriorityOrder = GroupCalendar.PlayerSettings.AutoSelectPriorityOrder
	end
	
	self.Group = GroupCalendar.NewObject(GroupCalendar._AttendanceList)
	self.Group.NumJoinedMembers = 0
	self.Group.NumJoinedOrInvited = 0
	
	self.GroupChanged = true
	self.SortBy = "Date"
	self.GroupBy = "Role"
	
	self:UpdateGroup(self.Group)
	
	-- Determine the status
	
	self.MaximumAttendance = self:GetEventMaxAttendance(pEvent)
	
	if self.Group.NumJoinedOrInvited >= self.MaximumAttendance then
		self:SetStatus("Complete")
	else
		self:SetReadyStatus()
	end
	
	self:NotifyGroupChanged()
	
	MCEventLib:RegisterEvent("CHAT_MSG_SYSTEM", self.ChatMsgSystem, self)
end

function GroupCalendar.Invites:EndEvent(pEvent)
	if pEvent ~= self.Event then
		return
	end
	
	MCEventLib:UnregisterEvent("CHAT_MSG_SYSTEM", self.ChatMsgSystem)
	
	self:SetChangedFunc(nil, nil)
	
	self.Event = nil
	self.Status = nil
	self.Group = nil
end

function GroupCalendar.Invites:SetChangedFunc(pChangedFunc, pChangedFuncParam)
	self.ChangedFunc = pChangedFunc
	self.ChangedFuncParam = pChangedFuncParam
end

function GroupCalendar.Invites:EventChanged(pDatabase, pEvent)
	if pEvent ~= self.Event
	or not self.Group then
		return
	end
	
	self:UpdateGroup(self.Group)
	self:NotifyGroupChanged()
end

function GroupCalendar.Invites:SetReadyStatus()
	if self:HasSelection() then
		self:SetStatus("Ready")
	else
		self:SetStatus("NeedSelection")
	end
end

function GroupCalendar.Invites:SetStatus(pStatus)
	self.Status = pStatus
	self.GroupChanged = true
end

function GroupCalendar.Invites:NotifyGroupChanged()
	if self.GroupChanged then
		if self.ChangedFunc then
			self.ChangedFunc(self.ChangedFuncParam)
		end
		
		self.GroupChanged = false
	end
end

function GroupCalendar.Invites:Update(pElapsed)
	if not self.Inviting then
		MCSchedulerLib:UnscheduleTask(self.Update, self)
		return
	end
	
	self:InviteNow()
end

function GroupCalendar.Invites:PartyMembersChanged()
	if not self.Event then
		return
	end

	self:UpdateGroup(self.Group)
	
	self:NotifyGroupChanged()
end

function GroupCalendar.Invites:PartyLootMethodChanged()
	self.PartyFormed = true
end

local GroupCalendar_cAlreadyGroupedSysMsg = GroupCalendar.ConvertFormatStringToSearchPattern(ERR_ALREADY_IN_GROUP_S)
local GroupCalendar_cInviteDeclinedSysMsg = GroupCalendar.ConvertFormatStringToSearchPattern(ERR_DECLINE_GROUP_S)
local GroupCalendar_cNoSuchPlayerSysMsg = GroupCalendar.ConvertFormatStringToSearchPattern(ERR_CHAT_PLAYER_NOT_FOUND_S)

function GroupCalendar.Invites:ChatMsgSystem(pMessage)
	-- See if someone declined an invitation
	
	local vStartIndex, vEndIndex, vName = string.find(pMessage, GroupCalendar_cInviteDeclinedSysMsg)
	
	if vStartIndex then
		self:PlayerDeclinedInvitation(vName)
		return
	end
	
	-- See if they are already in a group
	
	vStartIndex, vEndIndex, vName = string.find(pMessage, GroupCalendar_cAlreadyGroupedSysMsg)
	
	if vStartIndex then
		self:PlayerAlreadyGrouped(vName)
		return
	end
	
	-- See if they're not online
	
	vStartIndex, vEndIndex, vName = string.find(pMessage, GroupCalendar_cNoSuchPlayerSysMsg)
	
	if vStartIndex then
		self:NoSuchPlayer(vName)
		return
	end
end

function GroupCalendar.Invites:GuildRosterChanged()
	if self.Group then
		self:UpdateGroup(self.Group)
	end
end

function GroupCalendar.Invites:UpdateGroup(pGroup)
	-- Add the attendance info
	
	self:MergeEventAttendance(pGroup, self.Event, true)
	
	-- First mark all the joined members as "Left"  and
	-- count the invited members. Also check their offline
	-- status using the guild roster
	
	local vGuildRoster = GroupCalendar.Network:GetGuildRosterCache()
	
	for vIndex, vPlayer in pairs(pGroup.Items) do
		if vPlayer.mGroupStatus == "Joined" then
			vPlayer.mGroupStatus = "Left"
		end
		
		if vGuildRoster then
			local vUpperName = strupper(vPlayer.mName)
			local vMemberInfo = vGuildRoster[vUpperName]
			
			if vMemberInfo then
				vPlayer.mOffline = not vMemberInfo.Online
			end
		end
	end
	
	-- Now scan the group and update everyone who's in
	
	local vNumRaidMembers = GetNumRaidMembers()
	
	if vNumRaidMembers > 0 then
		for vIndex = 1, vNumRaidMembers do
			local vName, vRank, vSubgroup, vLevel, vClass, vClassID, vZone, vOnline, vIsDead, vRole, vMasterLooter = GetRaidRosterInfo(vIndex)
			
			if vName then
				local vClassCode = GroupCalendar.Database.GetClassCodeByClassID(vClassID)
				local vPlayer = pGroup.Items[vName]
				
				if vPlayer then
					vPlayer.mRaidRank = vRank
					vPlayer.mZone = vZone
					vPlayer.mOffline = not vOnline
					vPlayer.mDead = vIsDead
					vPlayer.mGroupStatus = "Joined"
					vPlayer.mSelected = nil -- Deselect players as they join the group
				else
					vPlayer = 
					{
						mType = "Player",
						mName = vName,
						mRaidRank = vRank,
						mGroupNumber = vSubGroup,
						mLevel = vLevel,
						mClassCode = vClassCode,
						mRole = GroupCalendar.GetMemberDefaultRole(vName, vClassID),
						mZone = vZone,
						mOffline = not vOnline,
						mDead = vIsDead,
						mGroupStatus = "Joined",
					}
					
					pGroup.Items[vName] = vPlayer
				end
			end
		end
	else
		for vIndex = 0, MAX_PARTY_MEMBERS do
			local vUnitID = nil
			
			if vIndex == 0 then
				vUnitID = "player"
			elseif GetPartyMember(vIndex) then
				vUnitID = "party"..vIndex
			else
				vUnitID = nil
			end
			
			if vUnitID then
				local vName = UnitName(vUnitID)
				
				-- Map the party info to a raid rank
				
				local vRank = 0
				
				if GetNumPartyMembers() == 0
				or UnitIsPartyLeader(vUnitID) then
					vRank = 2
				end
				
				--
				
				local vClassCode = GroupCalendar.Database.GetClassCodeByClassID(GroupCalendar.UnitClassID(vUnitID))
				local vPlayer = pGroup.Items[vName]
				
				if vPlayer then
					vPlayer.mRaidRank = vRank
					vPlayer.mOffline = not UnitIsConnected(vUnitID)
					vPlayer.mDead = UnitIsDeadOrGhost(vUnitID)
					vPlayer.mGroupStatus = "Joined"
					vPlayer.mSelected = nil -- Deselect players as they join the group
				else
					vPlayer =
					{
						mType = "Player",
						mName = vName,
						mRaidRank = vRank,
						mGroupNumber = 1,
						mLevel = UnitLevel(vUnitID),
						mClassCode = vClassCode,
						mRole = GroupCalendar.GetMemberDefaultRole(vName, vClassID),
						--mZone = vZone,
						mOffline = not UnitIsConnected(vUnitID),
						mDead = UnitIsDeadOrGhost(vUnitID),
						mGroupStatus = "Joined",
					}
					
					pGroup.Items[vName] = vPlayer
				end
			end
		end
	end
	
	-- 
	
	self:SelectionChanged()
	self.GroupChanged = true
end

function GroupCalendar.Invites:SetGroupSortMode(pGroupBy, pSortBy)
	self.SortBy = pSortBy
	self.GroupBy = pGroupBy
	
	if self.Group then
		self:SortGroup(self.Group)
		self:NotifyGroupChanged()
	end
end

function GroupCalendar.Invites.GetGroupItemByClassCategory(pItem)
	if pItem.mStatus == "Y"
	or pItem.mGroupStatus == "Joined"
	or pItem.mGroupStatus == "Left"
	or pItem.mSelected then
		if pItem.mClassCode then
			return pItem.mClassCode
		else
			return "?"
		end
	end

	return GroupCalendar.GetRSVPClassCategory(pItem)
end

function GroupCalendar.Invites.GetGroupItemByRoleCategory(pItem)
	if pItem.mStatus == "Y"
	or pItem.mGroupStatus == "Joined"
	or pItem.mGroupStatus == "Left"
	or pItem.mSelected then
		if pItem.mRole then
			return pItem.mRole
		else
			return "?"
		end
	end

	return GroupCalendar.GetRSVPRoleCategory(pItem)
end

function GroupCalendar.Invites:SortGroup(pGroup)
	-- Sort into categories
	
	local vNumAttendees = pGroup.NumAttendees
	pGroup:SortIntoCategories(self:GetGroupItemCategory(self.GroupBy))
	pGroup.NumAttendees = vNumAttendees
	
	-- Sort the categories
	
	table.sort(pGroup.SortedCategories, GroupCalendar.Database.CompareClassCodes)
	
	-- Sort the attendance within each category
	
	for vCategory, vClassInfo in pairs(pGroup.Categories) do
		table.sort(vClassInfo.mAttendees, self:GetGroupItemCompare(self.SortBy))
	end

	self.GroupChanged = true
end

GroupCalendar_cGroupStatusOrder =
{
	Joined = 1,
	Invited = 2,
	Ready = 3,
	Grouped = 4,
	Standby = 5,
	Maybe = 6,
	Declined = 7,
	Offline = 8,
	Left = 9,
}

GroupCalendar_cGroupStatusMessages =
{
	Joined = GroupCalendar_cJoinedGroupStatus,
	Invited = GropuCalendar_cInvitedGroupStatus,
	Ready = GropuCalendar_cReadyGroupStatus,
	Grouped = GroupCalendar_cGroupedGroupStatus,
	Standby = GroupCalendar_cStandbyGroupStatus,
	Maybe = GroupCalendar_cMaybeGroupStatus,
	Declined = GroupCalendar_cDeclinedGroupStatus,
	Offline = GroupCalendar_cOfflineGroupStatus,
	Left = GroupCalendar_cLeftGroupStatus,
}

GroupCalendar_cRSVPStatusToGroupStatus = 
{
	Y = "Ready",
	S = "Standby",
	M = "Maybe",
}

function GroupCalendar.Invites.CompareGroupItems(pItem1, pItem2, pSecondaryCompareFunc)
	if not pItem1 then
		if not pItem2 then
			GroupCalendar:ErrorMessage("Invites.CompareGroupItems: pItem1 is nil")
		else
			GroupCalendar:ErrorMessage("Invites.CompareGroupItems: pItem2 is nil")
		end
		
		return false
	end
	
	if not pItem2 then
		GroupCalendar:ErrorMessage("Invites.CompareGroupItems: pItem2 is nil")
		return true
	end
	
	-- Compare by status first
	
	local vOrder1 = GroupCalendar_cGroupStatusOrder[pItem1.mGroupStatus]
	local vOrder2 = GroupCalendar_cGroupStatusOrder[pItem2.mGroupStatus]
	
	if not vOrder1 then
		GroupCalendar:ErrorMessage("Invites.CompareGroupItems: pItem1: Unknown status "..pItem1.mGroupStatus)
		
		if not vOrder2 then
			GroupCalendar:ErrorMessage("Invites.CompareGroupItems: pItem2: Unknown status "..pItem2.mGroupStatus)
		end
		
		return false
	end
	
	if not vOrder2 then
		GroupCalendar:ErrorMessage("Invites.CompareGroupItems: pItem2: Unknown status "..pItem2.mGroupStatus)
		return true
	end
	
	if vOrder1 ~= vOrder2 then
		return vOrder1 < vOrder2
	end
	
	-- Use the secondary comparison
	
	return pSecondaryCompareFunc(pItem1, pItem2)
end

function GroupCalendar.Invites.CompareGroupItemsByRank(pItem1, pItem2)
	return GroupCalendar.Invites.CompareGroupItems(pItem1, pItem2, GroupCalendar.Database.CompareRSVPsByRankAndDate)
end

function GroupCalendar.Invites.CompareGroupItemsByDate(pItem1, pItem2)
	return GroupCalendar.Invites.CompareGroupItems(pItem1, pItem2, GroupCalendar.Database.CompareRSVPsByDate)
end

function GroupCalendar.Invites.CompareGroupItemsByName(pItem1, pItem2)
	return GroupCalendar.Invites.CompareGroupItems(pItem1, pItem2, GroupCalendar.Database.CompareRSVPsByName)
end

function GroupCalendar.Invites.CompareGroupItemsByRole(pItem1, pItem2)
	return GroupCalendar.Invites.CompareGroupItems(pItem1, pItem2, GroupCalendar.Database.CompareRSVPsByRole)
end

function GroupCalendar.Invites.CompareGroupItemsByClass(pItem1, pItem2)
	return GroupCalendar.Invites.CompareGroupItems(pItem1, pItem2, GroupCalendar.Database.CompareRSVPsByClass)
end

function GroupCalendar.Invites:GetGroupItemCategory(pGroupBy)
	if pGroupBy == "Status" then
		return self.GetGroupItemByClassCategory
	elseif pGroupBy == "Role" then
		return self.GetGroupItemByRoleCategory
	elseif pGroupBy == "Class" then
		return self.GetGroupItemByClassCategory
	else
		GroupCalendar:DebugMessage("Unknown grouping method (%s) in GroupCalendar.Invites.GetGroupItemCategory", pGroupBy or "nil")
		GroupCalendar:DebugStack()
	end
end

function GroupCalendar.Invites:GetGroupItemCompare(pSortBy)
	if pSortBy == "Rank" then
		return self.CompareGroupItemsByRank
	elseif not pSortBy or pSortBy == "Date" then
		return self.CompareGroupItemsByDate
	elseif pSortBy == "Name" then
		return self.CompareGroupItemsByName
	else
		GroupCalendar:DebugMessage("Unknown sorting method (%s) in GetGroupItemCompare", pSortBy or "nil")
		GroupCalendar:DebugStack()
	end
end

function GroupCalendar.Invites:GetEventMaxAttendance(pEvent)
	if not pEvent.mLimits
	or not pEvent.mLimits.mMaxAttendance then
		return MAX_RAID_MEMBERS
	end
		
	return pEvent.mLimits.mMaxAttendance
end

function GroupCalendar.Invites:GetNextInvitee(pGroup)
	for vCategory, vCategoryInfo in pairs(pGroup.Categories) do
		for vIndex, vPlayer in ipairs(vCategoryInfo.mAttendees) do
			if vPlayer.mNeedsInvite then
				return vPlayer
			end
		end
	end
	
	return nil
end

function GroupCalendar.Invites:InviteNow()
	if not self.Event then
		if GroupCalendar.Debug.Invites then
			GroupCalendar:DebugMessage("Skipping invites: no event associated")
		end
		
		self.Inviting = false
		return
	end
	
	-- Get the maximum size for the group
	
	local vMaxPartyMembers
	
	self:SetStatus("Inviting")
	
	if GetNumRaidMembers() == 0 then
		vMaxPartyMembers = MAX_PARTY_MEMBERS + 1 -- +1 because Blizzard doesn't include the player in the MAX_PARTY_MEMBERS count
	else
		vMaxPartyMembers = MAX_RAID_MEMBERS
	end
	
	--
	
	if GroupCalendar.Debug.Invites then
		GroupCalendar:DebugMessage("Starting invites: MaxPartyMembers: %d", vMaxPartyMembers)
	end
	
	-- Count the number of outstanding invitations
	
	local vNumInvitesSent = 0
	
	for vExcessLooping = 1, 40 do
		-- Don't allow too many invitations in one burst in order to prevent
		-- Blizzard's spammer filters from kicking us offline
		
		if vNumInvitesSent >= self.MaxInvitesPerTimeSlice then
			if GroupCalendar.Debug.Invites then
				GroupCalendar:DebugMessage("Maximum invites per time slice reached")
			end
			
			return
		end
		
		if GroupCalendar.Debug.Invites then
			GroupCalendar:DebugMessage("NumJoinedOrInvited: %d", self.Group.NumJoinedOrInvited)
		end
		
		-- Get the next player to invite
		
		local vPlayer = self:GetNextInvitee(self.Group)
		
		-- Done if there are no more players to add
		
		if not vPlayer
		or self.Group.NumJoinedMembers >= self.MaximumAttendance then
			self:SetStatus("Complete")
			self.Inviting = false
			
			if GroupCalendar.Debug.Invites then
				GroupCalendar:DebugMessage("No more players to invite")
			end
			
			return
		end
		
		-- See if there's room for more
		
		if self.Group.NumJoinedOrInvited >= vMaxPartyMembers then
			if GetNumRaidMembers() == 0 then
				-- Convert to a raid
				
				if self.Group.NumJoinedMembers > 1
				and self.PartyFormed
				and self.MaximumAttendance > 5 then
					self:SetStatus("ConvertingToRaid")
					
					if GroupCalendar.Debug.Invites then
						GroupCalendar:DebugMessage("Converting to raid")
					end
					
					ConvertToRaid()
				
				-- Wait for at least one player to accept
				
				else
					self:SetStatus("AwaitingAcceptance")
					if GroupCalendar.Debug.Invites then
						GroupCalendar:DebugMessage("Waiting for players to accept")
					end
				end
			
			-- This state is only reached if the raid is full and the player
			-- tries to invite more
			
			else
				self:SetStatus("RaidFull")
				self.Inviting = false
			end
			
			return
		end
		
		-- Invite the player
		
		if GroupCalendar.Debug.Invites then
			GroupCalendar:DebugMessage("Inviting "..vPlayer.mName)
		end
		
		SendChatMessage(
				format(GroupCalendar_cInviteWhisperFormat, GroupCalendar.Database.GetEventDisplayName(self.Event)),
				"WHISPER",
				nil,
				vPlayer.mName)
		
		InviteUnit(vPlayer.mName)
		
		vPlayer.mGroupStatus = "Invited"
		vPlayer.mNeedsInvite = nil
		
		vNumInvitesSent = vNumInvitesSent + 1
		
		self.Group.NumJoinedOrInvited = self.Group.NumJoinedOrInvited + 1
		
		self.GroupChanged = true
	end -- for
	
	GroupCalendar:ErrorMessage("Internal Error: InviteNow() not terminating properly")
end

function GroupCalendar.Invites:MergeEventAttendance(pGroup, pEvent, pSortByClass)
	if not pEvent
	or not pEvent.mAttendance then
		return
	end
	
	for vAttendeeName, vRSVPString in pairs(pEvent.mAttendance) do
		local vRSVP = GroupCalendar.Database.UnpackEventRSVP(nil, vAttendeeName, pEvent.mID, vRSVPString)
		local vCategoryID = GroupCalendar.GetRSVPClassCategory(vRSVP)
		
		if vCategoryID
		and vCategoryID ~= "NO"
		and vCategoryID ~= "BANNED" then
			local vItem = pGroup.Items[vRSVP.mName]
			
			if not vItem then
				vRSVP.mType = "RSVP"
				vRSVP.mGroupStatus = GroupCalendar_cRSVPStatusToGroupStatus[vRSVP.mStatus]
				
				if vRSVP.mGroupStatus then
					pGroup.Items[vRSVP.mName] = vRSVP
				end
			else
				-- Just update the status and
				-- player info fields
				
				vItem.mStatus = vRSVP.mStatus
				vItem.mComment = vRSVP.mComment
				vItem.mGuild = vRSVP.mGuild
				vItem.mGuildRank = vRSVP.mGuildRank
				
				if vItem.mGroupStatus == "Standby"
				or vItem.mGroupStatus == "Ready"
				or vItem.mGroupStatus == "Maybe" then
					vItem.mGroupStatus = GroupCalendar_cRSVPStatusToGroupStatus[vRSVP.mStatus]
				end
			end
		end
	end
end

function GroupCalendar.Invites:InviteSelectedPlayers()
	-- Reset the SentInvite flag
	
	for vCategory, vCategoryInfo in pairs(self.Group.Categories) do
		for vIndex, vPlayer in ipairs(vCategoryInfo.mAttendees) do
			if vPlayer.mSelected then
				vPlayer.mNeedsInvite = true
			end
		end
	end
	
	-- Arm the trigger for when the party is actually
	-- formed (needed to make ConvertToRaid() work properly)
	
	if GetNumRaidMembers() ~= 0
	or GetNumPartyMembers() ~= 0 then
		self.PartyFormed = true
	else
		self.PartyFormed = false
	end
	
	-- Start inviting
	
	self.Inviting = true
	
	MCSchedulerLib:ScheduleUniqueRepeatingTask(self.InvitationSliceInterval, self.Update, self, nil, "GroupCalendar.Invites.Update")
	
	self:InviteNow()
	self:NotifyGroupChanged()
end

function GroupCalendar.Invites:HasSelection()
	for vPlayerName, vPlayer in pairs(self.Group.Items) do
		if vPlayer.mSelected then
			return true
		end
	end
	
	return false
end

function GroupCalendar.Invites:ClearSelection()
	for vPlayerName, vPlayer in pairs(self.Group.Items) do
		vPlayer.mSelected = nil
	end
	
	self:SelectionChanged()
end

function GroupCalendar.Invites:SetItemSelected(pItem, pSelected)
	if not pSelected then
		pSelected = nil
	end
	
	if pItem.mSelected == pSelected then
		return
	end
	
	pItem.mSelected = pSelected
	
	self:SelectionChanged()
	self:NotifyGroupChanged()
end

function GroupCalendar.Invites:SelectionChanged()
	local vNumSelected = 0
	local vNumJoined = 0
	local vNumAttendees = 0
	local vNumJoinedOrInvited = 0
	
	for vPlayerName, vPlayer in pairs(self.Group.Items) do
		if vPlayer.mGroupStatus == "Joined" then
			vNumJoined = vNumJoined + 1
			vNumJoinedOrInvited = vNumJoinedOrInvited + 1
			vNumAttendees = vNumAttendees + 1
		else
			if vPlayer.mSelected then
				vNumSelected = vNumSelected + 1
				vNumAttendees = vNumAttendees + 1
			end
			
			if vPlayer.mGroupStatus == "Invited" then
				vNumJoinedOrInvited = vNumJoinedOrInvited + 1
			end
		end
	end
	
	self.Group.NumAttendees =  vNumAttendees
	self.Group.NumJoinedMembers = vNumJoined
	self.Group.NumJoinedOrInvited = vNumJoinedOrInvited
	
	self.NumSelected = vNumSelected
	
	self:SortGroup(self.Group)
	self:SetReadyStatus()
end

function GroupCalendar.Invites:AutoSelectPlayers()
	if self.GroupBy == "Role" then
		CalendarRoleLimitsFrame:Open(self.Limits, GroupCalendar_cAutoSelectWindowTitle, true, function (...) GroupCalendar.Invites:AutoSelectFromLimits(unpack(arg)) end)
	else
		CalendarClassLimitsFrame:Open(self.Limits, GroupCalendar_cAutoSelectWindowTitle, true, function (...) GroupCalendar.Invites:AutoSelectFromLimits(unpack(arg)) end)
	end
end

function GroupCalendar.Invites:AutoSelectFromLimits(pLimits)
	self.Limits = pLimits
	GroupCalendar.PlayerSettings.AutoSelectPriorityOrder = pLimits.mPriorityOrder
	
	self:ClearSelection()
	
	--
	
	local vAvailableSlots = GroupCalendar.NewObject(GroupCalendar._AvailableSlots, self.Limits, tern(self.GroupBy == "Role", "ROLE", "CLASS"))
	
	-- Count existing players and accumulate the rest as prospective members
	
	local vProspects = {}
	
	for vCategory, vCategoryInfo in pairs(self.Group.Categories) do
		for vIndex, vPlayer in ipairs(vCategoryInfo.mAttendees) do
			if vPlayer.mGroupStatus == "Joined"
			or vPlayer.mGroupStatus == "Invited" then
				vAvailableSlots:AddPlayer(vPlayer.mClassCode, vPlayer.mRole)
			else
				table.insert(vProspects, vPlayer)
			end
		end
	end
	
	-- Sort the prospects by the selected priority
	
	table.sort(vProspects, self:GetGroupItemCompare(pLimits.mPriorityOrder))
	
	-- Add them
	
	for vIndex, vPlayer in ipairs(vProspects) do
		if vAvailableSlots:AddPlayer(vPlayer.mClassCode, vPlayer.mRole) then
			vPlayer.mSelected = true
		end
	end
	
	self:SelectionChanged()
	self:NotifyGroupChanged()
end

function GroupCalendar.Invites:PlayerDeclinedInvitation(pName)
	local vPlayer = self.Group:FindItem("mName", pName)
	
	if not vPlayer
	or not vPlayer.mGroupStatus == "Invited" then
		return
	end
	
	vPlayer.mGroupStatus = "Declined"
	
	self.GroupChanged = true
	self:NotifyGroupChanged()
end

function GroupCalendar.Invites:PlayerAlreadyGrouped(pName)
	local vPlayer = self.Group:FindItem("mName", pName)
	
	if not vPlayer then
		return
	end
	
	if vPlayer.mGroupStatus == "Invited" then
		SendChatMessage(GroupCalendar_cAlreadyGroupedWhisper, "WHISPER", nil, vPlayer.mName)
	end
	
	vPlayer.mGroupStatus = "Grouped"
	
	self.GroupChanged = true
	self:NotifyGroupChanged()
end

function GroupCalendar.Invites:NoSuchPlayer(pName)
	local vPlayer = self.Group:FindItem("mName", pName)
	
	if not vPlayer then
		return
	end
	
	vPlayer.mGroupStatus = "Offline"
	
	self.GroupChanged = true
	self:NotifyGroupChanged()
end

