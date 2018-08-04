-- TODO: Try requesting updates first then immediately send out current
--       version notices during sync.  This may lower the bandwidth needs
--       if the code is also modified to treat an RFU as an implicit NOU
--       such that pending NOUs could be eliminated when an RFU is received.

GroupCalendar.Network =
{
	Channel = nil,
	UserTrustCache = {},
	
	MessagePrefix0 = "GC4",
	MessagePrefix = "GC4/",
	
	ConfigPrefix0 = "GC3",
	ConfigPrefix = "GC3/",
	
	MinTrustedRank = nil,
	cMaxGuildInfoLength = 499,
	
	SafeMode = false,            -- Sets GC to never send updates (for testing when risk of corruption is high)
	
	EnableUpdates = false,		-- Don't allow the user to send updates to any databases
								-- until we're sure that his databases are up-to-date themselves
	EnableSelfUpdates = false,	-- Don't allow the user to send updates for their own databases
								-- until well after they're sure nobody has updates for them
	IncomingUpdates = {},
	
	SynchSucceeded = false,  -- Once successful, no need to repeat synch unless the player logs out or changes channels
	
	Delay =
	{
		-- Synch phase timing
		
		StartSynch = 0.5,
		ExternalUpdateRequest = 30,
		SynchVersionRequest = 1,
		SynchComplete = 120, -- Allow time for updates to arrive before we'll start advertising databases
		
		-- Debugging settings
		
		--StartSynch = 0.5,
		--ExternalUpdateRequest = 3,
		--SynchVersionRequest = 1,
		--SynchComplete = 10, -- Allow time for updates to arrive before we'll start advertising databases
		
		-- Response timing
		
		RFV = {Min = 3 * 60, Range = 5 * 60},
		VER = {Min = 5, Range = 30},
		RFU = {Min = 5, Range = 30},
		GUILD_RFU = {Min = 0, Range = 5},
		ALL_RFU = {Min = 0, Range = 5},  -- Use a shorter range since these generate far more traffic in response than they do to send out
		
		UPD_Owned = 0.1, -- IMPORTANT: This must not be zero since that could cause changes to be transmitted before they're fully generated
		UPD_Proxy = {Min = 10, Range = 30},
		UPD_Priority = {Min = 0.5, Range = 9},
		
		NOU_Proxy = {Min = 15, Range = 30},
		NOU_Owned = {Min = 1, Range = 9}, -- Just scatter these a bit so everyone doesn't land in the channel at once
		
		TIME = {Min = 0, Range = 20},
		
		-- Dead update detection
		
		DeadUpdateCheck = 60,
		DeadUpdateTimeout = 600, -- 10 minutes
		
		-- Request queue delay 1 - 5 seconds
		
		GuildUpdateAutoConfig = 2,
	}
}

----------------------------------------
-- Initialization
----------------------------------------

function GroupCalendar.Network:CalendarLoaded()
	if GroupCalendar.Debug.Init then
		GroupCalendar:DebugMessage("Network.CalendarLoaded")
	end
	
	self.MD5 = GroupCalendar.NewObject(GroupCalendar._MD5)
	self.MD5:Verify()
	
	-- Trigger a guild roster load so that it'll hopefully be
	-- ready by the time we need to start authenticating players
	
	self:LoadGuildRoster()
	
	-- Create the channel
	
	self.Channel = MCDataChannelLib:NewChannel(GroupCalendar.Network.MessagePrefix0, self.ChannelMessage, self)
	
	self:SetStatus("Starting")
	
	MCSchedulerLib:ScheduleUniqueTask(5, self.Initialize, self, "GroupCalendar.Network.Initialize")
end

function GroupCalendar.Network:Initialize()
	-- If the player is in a guild but the roster hasn't loaded yet
	-- then wait another five seconds and try again
	
	if IsInGuild()
	and (GetNumGuildMembers() == 0 or GetGuildInfoText() == nil) then
		if GroupCalendar.Debug.Init then
			GroupCalendar:DebugMessage("Reschedule network initialization (info not loaded yet)")
		end
		
		GuildRoster()
		MCSchedulerLib:ScheduleUniqueTask(5, self.Initialize, self, "GroupCalendar.Network.Initialize")
		return
	end
	
	if GroupCalendar.Debug.Init then
		GroupCalendar:DebugMessage("Initializing network")
	end
	
	self.Initialized = true
	
	self:PlayerGuildChanged()
	
	-- Go ahead and do manual channel configuration now, automatic
	-- config will be handled once the player guild gets set and
	-- the roster gets loaded
	
	if not GroupCalendar.PlayerSettings.Channel.AutoConfig
	and not GroupCalendar.PlayerSettings.Channel.GuildAdmin then
		if GroupCalendar.Debug.Init then
			GroupCalendar:DebugMessage("Initializing via manual configuration")
		end
		
		if GroupCalendar.PlayerSettings.Channel.Name then
			self:SetChannel(
					GroupCalendar.PlayerSettings.Channel.Name,
					GroupCalendar.PlayerSettings.Channel.Password)
			self:SetMinTrustedRank(GroupCalendar.PlayerSettings.Channel.MinTrustedRank)
		else
			self:SetStatus("Disconnected")
			GroupCalendar:NoteMessage("Channel is not set")
		end
	end
end

----------------------------------------
-- Channel management
----------------------------------------

function GroupCalendar.Network:SetChannel(pChannel, pPassword)
	if not pChannel then
		self:LeaveChannel()
		return
	end
	
	if string.upper(pChannel) ~= self.Channel.UpperName
	or pPassword ~= self.Channel.Password
	or not self.Channel.Open then
		if GroupCalendar.Debug.Channel then
			GroupCalendar:DebugMessage("Joining channel %s", pChannel)
		end
		
		self.SynchSucceeded = false
		
		self.Channel:OpenChannel(pChannel, pPassword)
	else
		self:SetStatus(tern(self.SynchSucceeded, "Connected", "Synching"))
	end
end

function GroupCalendar.Network:LeaveChannel()
	self:CancelAllTasks()
	self.Channel:CloseChannel()
end

function GroupCalendar.Network:SuspendChannel()
	self.Channel:CloseChannel()
	self:SetStatus("Suspended")
end

function GroupCalendar.Network:ResumeChannel()
	if self.ChannelStatus ~= "Suspended" then
		return
	end
	
	self.Channel:OpenChannel(self.ChannelName, self.ChannelPassword)
end

function GroupCalendar.Network:SetStatus(pStatus, pStatusMessage)
	self.ChannelStatus = pStatus
	self.ChannelStatusMessage = pStatusMessage
	self.ChannelStatusStartTime = GetTime()
	
	MCEventLib:DispatchEvent("GC_CHANNEL_UPDATE")
end

function GroupCalendar.Network:GetStatus()
	return self.ChannelStatus, self.ChannelStatusMessage, self.ChannelStatusStartTime
end

function GroupCalendar.Network:IsConnected()
	return self.ChannelStatus == "Connected" or self.ChannelStatus == "Synching"
end

function GroupCalendar.Network:ChannelMessage(pSender, pMessageType, pMessage)
	if pMessageType ==  "DATA" then
		if pSender ~= GroupCalendar.PlayerName then
			self:ChannelMessageReceived(pSender, pMessage)
		elseif string.sub(pMessage, 1, 1) == "!" then
			self:ChannelMessageReceived(pSender, string.sub(pMessage, 2))
		end
	elseif pSender == "#STATUS" then
		if GroupCalendar.Debug.Channel and pMessageType ~= "READY_TO_SEND" then
			GroupCalendar:DebugMessage("Channel status %s %s", pMessageType, pMessage or "")
		end
		
		if pMessageType == "DISCONNECTED" then
			self:LeftChannel()
		elseif pMessageType == "CONNECTED" then
			self:JoinedChannel()
		elseif pMessageType == "ERROR" then
			self:SetStatus("Error", pMessage)
		elseif pMessageType == "READY_TO_SEND" then
			self:ReadyToSend()
		end
	end
end

function GroupCalendar.Network:JoinedChannel()
	self.EnableUpdates = false
	self.EnableSelfUpdates = false
	
	-- Wait a moment after connecting to make sure the channel is really ready
	
	MCSchedulerLib:ScheduleUniqueTask(self.Delay.StartSynch, self.StartSynch, self, "GroupCalendar.Network:StartSynch")
end

function GroupCalendar.Network:LeftChannel()
	self:ResetQueues()
	self:SetStatus("Disconnected")
end

function GroupCalendar.Network:ReadyToSend()
	if GroupCalendar.Debug.ChannelRTS then
		GroupCalendar:DebugMessage("Ready to send")
	end
	
	self.ResponseQueue:ReadyToSend()
end

----------------------------------------
-- AutoConfig
----------------------------------------

function GroupCalendar.Network:ScheduleAutoConfig(pCheckDatabaseTrust)
	if self.Channel.Disconnected then
		return
	end
	
	if pCheckDatabaseTrust then
		self.AutoConfigCheckDatabaseTrust = true
	end
	
	MCSchedulerLib:RescheduleTask(self.Delay.GuildUpdateAutoConfig, self.DoAutoConfig, self, "GroupCalendar.Network.DoAutoConfig")
end

function GroupCalendar.Network:DoAutoConfig()
	local vConfigData = self:GetAutoConfigData()
	
	if not vConfigData then
		self:SetStatus("Error", GroupCalendar_cAutoConfigNotFound)
		return false
	end
	
	self:SetChannel(vConfigData.ChannelName, vConfigData.ChannelPassword)
	
	local vMinTrustedRank
	
	if vConfigData.UseGuildChannel then
		vMinTrustedRank = vConfigData.MinTrustedRank
	else
		vMinTrustedRank = nil
	end
	
	-- Update the trust settings
	
	if vMinTrustedRank ~= self.MinTrustedRank then
		self:SetMinTrustedRank(vMinTrustedRank)
	
	elseif self.AutoConfigCheckDatabaseTrust then
		self.AutoConfigCheckDatabaseTrust = false
		GroupCalendar.Database.CheckDatabaseTrust()
	end
	
	return true
end

function GroupCalendar.Network:PlayerGuildChanged()
	-- Just return if we're not initialized yet
	
	if not self.Initialized then
		GroupCalendar.Database.UpdateGuildRankCache()
		return
	end
	
	-- Update the guild in the database
	
	if GroupCalendar.UserDatabase then
		if GroupCalendar.UserDatabase.Guild ~= GroupCalendar.PlayerGuild then
			GroupCalendar.UserDatabase.Guild = GroupCalendar.PlayerGuild
			GroupCalendar.Database.RemoveLocalUser(GroupCalendar.PlayerName) -- Remove ourselves from all databases
			GroupCalendar.Database.LocalUsers = {[GroupCalendar.PlayerName] = true} -- Remove everyone else from our database
		end
	elseif not IsInGuild() then
		GroupCalendar.Database.RemoveLocalUser(GroupCalendar.PlayerName) -- Remove ourselves from all databases
		GroupCalendar.Database.LocalUsers = {[GroupCalendar.PlayerName] = true} -- Remove everyone else from our database
	end
	
	-- Clear the roster load flag
	
	self.SentLoadGuildRoster = false
	
	self:FlushCaches()
	
	-- If the player is unguilded then simply leave the data
	-- channel if it was auto-configured, flush any databases
	-- which are no longer trusted and exit
	
	if not IsInGuild() then
		if GroupCalendar.PlayerSettings.Channel.AutoConfig
		or GroupCalendar.PlayerSettings.Channel.GuildAdmin then
			self.Channel:CloseChannel()
		end
		
		GroupCalendar.Database.CheckDatabaseTrust()
		
		return
	end
	
	-- The player is in a new guild or has changed guilds, so
	-- schedule a roster update if necessary
	
	if GetNumGuildMembers() > 0 then
		if GroupCalendar.Debug.Init then
			GroupCalendar:DebugMessage("PlayerGuildChanged: Roster is already loaded, calling GuildRosterLoaded()")
		end
		
		self:GuildRosterLoaded()
	end
	
	-- Force the roster to reload or to start loading
	
	self:LoadGuildRosterTask()
end

function GroupCalendar.Network:GuildRosterChanged()
	self.PendingGuildInfoText = nil
	self.PendingGuildInfoTextExpires = nil
	
	self:GuildRosterLoaded()
end

function GroupCalendar.Network:GuildRosterLoaded()
	GroupCalendar.Database.UpdateGuildRankCache()
	
	self:FlushCaches()

	if GroupCalendar.PlayerSettings.Channel.AutoConfig
	or GroupCalendar.PlayerSettings.Channel.GuildAdmin then
		self:ScheduleAutoConfig(true)
	else
		self:ScheduleCheckDatabaseTrust()
	end
	
	-- Start sending notices now if we were waiting for a roster update
	
	if self.StartSynchOnRosterUpdate then
		self.StartSynchOnRosterUpdate = nil
		self:StartSynch()
	end
end

local GroupCalendar_cConfigPatternString = "\n?%["..GroupCalendar.Network.ConfigPrefix0.."[^%]]+%]"
local GroupCalendar_cConfigCaptureString = "%[("..GroupCalendar.Network.ConfigPrefix0.."[^%]]+)%]"

function GroupCalendar.Network:RemoveAutoConfigData()
	local vGuildInfoText = GetGuildInfoText()
	
	vGuildInfoText = string.gsub(vGuildInfoText, GroupCalendar_cConfigPatternString, "")
	
	SetGuildInfoText(vGuildInfoText)

	MCSchedulerLib:RescheduleTask(2, self.LoadGuildRosterTask, self, "GroupCalendar.Network.LoadGuildRosterTask")
end

function GroupCalendar.Network:GetGuildPublicNote(pMemberIndex)
	local vName, vRank, vRankIndex, vLevel, vClass, vZone, vNote, vOfficerNote, vOnline = GetGuildRosterInfo(pMemberIndex)
	
	return vName, vNote
end

function GroupCalendar.Network:GetAutoConfigData()
	local vText
	
	if self.PendingGuildInfoText and GetTime() < self.PendingGuildInfoTextExpires then
		if GroupCalendar.Debug.AutoConfig then
			GroupCalendar:DebugMessage("Using pending guild info")
		end
		
		vText = self.PendingGuildInfoText
	else
		vText = GetGuildInfoText()
	end
	
	local vStartIndex, vEndIndex, vConfigString = string.find(vText, GroupCalendar_cConfigCaptureString)
	
	if not vStartIndex then
		if GroupCalendar.Debug.AutoConfig then
			GroupCalendar:DebugMessage("Couldn't find auto config data in %s", vText or "nil")
		end
		
		return nil
	end
	
	local vConfigData = GroupCalendar.NewTable()
	local vCommand = self:ParseCommandString(vConfigString)
	
	local vChannel = nil
	local vPassword = nil
	local vMinTrustedRank = nil
	local vTrustGroup = nil
	
	while vCommand[1] ~= nil do
		local vOpcode = vCommand[1].opcode
		local vOperands = vCommand[1].operands
		
		table.remove(vCommand, 1)
		
		if vOpcode == "C" then
			if vOperands[1] == "GUILD" then
				vConfigData.UseGuildChannel = true
				vConfigData.ChannelName = "#GUILD"
				vConfigData.MinTrustedRank = tonumber(vOperands[2])
			else
				vConfigData.ChannelName = vOperands[1]
				vConfigData.ChannelPassword = vOperands[2]
			end
		end
		
		if vOpcode == "H" then
			local vMaxAge = tonumber(vOperands[1])
			
			if vMaxAge ~= GroupCalendar.MaximumEventAge then
				GroupCalendar_SetMaxEventAge(vMaxAge)
			end
		end
	end
	
	GroupCalendar.DeleteTable(vCommand)
	
	return vConfigData
end

function GroupCalendar.Network:SetAutoConfigData(pChannelName, pChannelPassword, pMinTrustedRank)
	-- Return if it can't be set or there's no channel info
	
	if not CanEditGuildInfo()
	or not pChannelName then
		return false
	end
	
	local vConfigString = "["..GroupCalendar.Network.ConfigPrefix.."C:"
	
	if pChannelName == "#GUILD" then
		if pMinTrustedRank then
			vConfigString = vConfigString.."GUILD,"..pMinTrustedRank
		else
			vConfigString = vConfigString.."GUILD"
		end
	else
		if pChannelName then
			vConfigString = vConfigString..pChannelName
		end
		
		if pChannelPassword then
			vConfigString = vConfigString..","..pChannelPassword
		end
	end
	
	vConfigString = vConfigString.."/H:"..GroupCalendar.MaximumEventAge.."]"
	
	-- Replace or append a new config string
	
	local vGuildInfoText = GetGuildInfoText()
	
	-- Remove the existing config string
	
	vGuildInfoText = string.gsub(vGuildInfoText, GroupCalendar_cConfigPatternString, "")
	
	-- Calculate the new length and strip excess if any
	
	local vNewLength = string.len(vGuildInfoText) + string.len(vConfigString) + 1
	
	if vNewLength > self.cMaxGuildInfoLength then
		local vExcessLength = vNewLength - self.cMaxGuildInfoLength

		vGuildInfoText = string.sub(vGuildInfoText, 1, -vExcessLength)
	end
	
	vGuildInfoText = vGuildInfoText.."\n"..vConfigString
	
	self.PendingGuildInfoText = vGuildInfoText
	self.PendingGuildInfoTextExpires = GetTime() + 60
	
	SetGuildInfoText(vGuildInfoText)
	
	MCSchedulerLib:RescheduleTask(0.1, self.LoadGuildRosterTask, self, "GroupCalendar.Network.LoadGuildRosterTask")

	return true
end

----------------------------------------
-- Trust
----------------------------------------

GroupCalendar.Network.GuildMemberRankCache = nil

function GroupCalendar.Network:FlushCaches()
	self.GuildMemberRankCache = GroupCalendar.DeleteTable(self.GuildMemberRankCache, 1)
	self.UserTrustCache = GroupCalendar.RecycleTable(self.UserTrustCache)
end

function GroupCalendar.Network:GetGuildRosterCache()
	if self.GuildMemberRankCache then
		return self.GuildMemberRankCache
	end
	
	-- Clear the cache
	
	self.GuildMemberRankCache = GroupCalendar.NewTable()
	
	-- Scan the roster and collect the info
	
	local vNumGuildMembers = GetNumGuildMembers(true)
	
	for vIndex = 1, vNumGuildMembers do
		local vName, vRank, vRankIndex, vLevel, vClass, vZone, vNote, vOfficerNote, vOnline = GetGuildRosterInfo(vIndex)
		
		if vName then -- Have to check for name in case a guild member gets booted while querying the roster
			local vMemberInfo = GroupCalendar.NewTable()
			
			vMemberInfo.Name = vName
			vMemberInfo.RankIndex = vRankIndex
			vMemberInfo.Level = vLevel
			vMemberInfo.Class = vClass
			vMemberInfo.Zone = vZone
			vMemberInfo.OfficerNote = vOfficerNote
			vMemberInfo.Online = vOnline
			vMemberInfo.Guild = GroupCalendar.PlayerGuild
			
			self.GuildMemberRankCache[strupper(vName)] = vMemberInfo
		end
	end
	
	-- Dump any cached trust info
	
	self.UserTrustCache = GroupCalendar.RecycleTable(self.UserTrustCache)
	
	return self.GuildMemberRankCache
end

GroupCalendar.Network.SentLoadGuildRoster = false

function GroupCalendar.Network:LoadGuildRosterTask()
	if IsInGuild() then
		GuildRoster()
	end
	
	-- Schedule another task to load the roster again
	-- in four minutes
	
	MCSchedulerLib:ScheduleUniqueTask(240, self.LoadGuildRosterTask, self, "GroupCalendar.Network:LoadGuildRosterTask")
end

function GroupCalendar.Network:LoadGuildRoster()
	if not IsInGuild()
	or GetNumGuildMembers() > 0
	or self.SentLoadGuildRoster then
		return
	end
	
	self.SentLoadGuildRoster = true
	
	if GroupCalendar.Debug.Init then
		GroupCalendar:DebugMessage("Network:LoadGuildRoster: Loading")
	end
	
	self:LoadGuildRosterTask()
end

function GroupCalendar.Network:GetGuildMemberInfo(pUserName)
	if not IsInGuild() then
		return
	end
	
	-- Build the roster
	
	if GetNumGuildMembers() == 0 then
		self:LoadGuildRoster()
		return -- have to return nil for now since we don't really know
	end
	
	-- Search for the member
	
	local vUpperUserName = strupper(pUserName)
	local vRosterCache = self:GetGuildRosterCache()
	local vMemberInfo = vRosterCache[vUpperUserName]
	
	return vRosterCache[vUpperUserName]
end

function GroupCalendar.Network:UserIsInSameGuild(pUserName)
	if not IsInGuild() then
		return false, nil
	end
	
	-- Build the roster
	
	if GetNumGuildMembers() == 0 then
		self:LoadGuildRoster()
		return false, nil -- have to return false for now since we don't really know
	end
	
	-- Search for the member
	
	local vUpperUserName = string.upper(pUserName)
	local vRosterCache = self:GetGuildRosterCache()
	local vMemberInfo = vRosterCache[vUpperUserName]
	
	if not vMemberInfo then
		return false, nil
	end
	
	return true, vMemberInfo.RankIndex
end

function GroupCalendar.Network:CheckPlayerGuild()
	local vPlayerGuild

	if IsInGuild() then
		vPlayerGuild, _, GroupCalendar.PlayerGuildRank = GetGuildInfo("player")
		
		-- Just return if the server is lagging and the guild info
		-- isn't available yet
		
		if not vPlayerGuild then
			return
		end
	else
		vPlayerGuild = nil
		GroupCalendar.PlayerGuildRank = nil
	end

	if GroupCalendar.PlayerGuild ~= vPlayerGuild then
		GroupCalendar.PlayerGuild = vPlayerGuild
		
		self:PlayerGuildChanged()
	end
end

function GroupCalendar.Network:SetMinTrustedRank(pMinRank)
	if self.MinTrustedRank ==  pMinRank then
		return
	end
	
	self.MinTrustedRank =  pMinRank
	
	MCEventLib:DispatchEvent("GC_CHANNEL_UPDATE")
	self:TrustSettingsChanged()
end

function GroupCalendar.Network:TrustSettingsChanged()
	self:FlushCaches()
	
	GroupCalendar.Database.CheckDatabaseTrust() -- Delete databases owned by players we no longer trust
	
	GroupCalendar:DebugTable("Network:TrustSettingsChanged: self.EnableUpdates", self.EnableUpdates)
	
	if self.EnableUpdates
	and not self.SafeMode then
		if not self.MinTrustedRank then
			self.ResponseQueue:QueueUniqueResponse(self._ALL_RFU, self.Delay.ALL_RFU)
			self:QueueAllRevisionNotices() -- Send out revision notices since trusted players may want to know now
		
		elseif GroupCalendar.PlayerGuild then
			self.ResponseQueue:QueueUniqueResponse(self._GUILD_RFU, self.Delay.GUILD_RFU, GroupCalendar.PlayerGuild, GroupCalendar.Network.MinTrustedRank)
			self:QueueGuildRevisionNotices(GroupCalendar.Network.MinTrustedRank) -- Send out revision notices since trusted players may want to know now
		end
	end
end

function GroupCalendar.Network:TrustCheckingAvailable()
	if not self.MinTrustedRank then
		return true
	end
	
	-- Doesn't matter if they're not in a guild
	
	if not IsInGuild() then
		return true
	end
	
	-- If trust is guild members only then verify that the roster has been loaded
	
	return GetNumGuildMembers() > 0
end

function GroupCalendar.Network:GetUserTrustLevel(pUserName)
	local vUserTrustInfo = self.UserTrustCache[pUserName]
	
	if not vUserTrustInfo then
		vUserTrustInfo = GroupCalendar.NewTable()
		vUserTrustInfo.mTrustLevel = self:CalcUserTrust(pUserName)
		self.UserTrustCache[pUserName] = vUserTrustInfo
	end
	
	return vUserTrustInfo.mTrustLevel
end

function GroupCalendar.Network:UserIsTrusted(pUserName, pDatabaseTag)
	if pDatabaseTag == "DB" then
		return self:GetUserTrustLevel(pUserName) == 2
	else
		return self:GetUserTrustLevel(pUserName) >= 1
	end
end

function GroupCalendar.Network:CalcUserTrust(pUserName)
	-- If the user is one of our own characters, then trust them completely
	
	local vDatabase = GroupCalendar.Database.GetDatabase(pUserName, false)
	
	if vDatabase
	and vDatabase.IsPlayerOwned then
		if GroupCalendar.Debug.Trust then
			GroupCalendar:DebugMessage("Network:CalcUserTrust: Implicit trust for %s", pUserName)
		end
		
		return 2
	end
	
	local vPlayerSecurity = GroupCalendar.PlayerSettings.Security.Player[pUserName]
	
	-- See if they're explicity forbidden
	
	if vPlayerSecurity ~= nil then
		if vPlayerSecurity == 1 then
			-- Trusted (obsolete -- just ignore)
		
		elseif vPlayerSecurity == 2 then
			-- Excluded
			
			if GroupCalendar.Debug.Trust then
				GroupCalendar:DebugMessage("Network:CalcUserTrust: %s explicity excluded", pUserName)
			end
			
			return 0
		else
			GroupCalendar:DebugMessage("Unknown player security setting of %s for %s", vPlayerSecurity, pUserName)
		end
	end
	
	-- Return true if we'll allow anyone in the channel
	
	if not self.MinTrustedRank then
		if GroupCalendar.Debug.Trust then
			GroupCalendar:DebugMessage("Network:CalcUserTrust: %s trusted (all trusted)", pUserName)
		end
		
		return 2
	end
	
	-- Return true if they're in the same guild and of sufficient rank
	
	if self.MinTrustedRank then
		local vIsInGuild, vGuildRank = self:UserIsInSameGuild(pUserName)
		
		if vIsInGuild then
			if vGuildRank <= self.MinTrustedRank then
				if GroupCalendar.Debug.Trust then
					GroupCalendar:DebugMessage("Network:CalcUserTrust: %s trusted (guild member)", pUserName)
				end
				
				return 2
			else
				if GroupCalendar.Debug.Trust then
					GroupCalendar:DebugMessage("Network:CalcUserTrust: %s partially trusted (guild member)", pUserName)
				end
				
				return 1
			end
		end
	end
	
	-- Failed all tests
	
	if GroupCalendar.Debug.Trust then
		GroupCalendar:DebugMessage("Network:CalcUserTrust: %s not trusted (all tests failed)", pUserName)
	end
	
	return 0
end

function GroupCalendar.Network:GetNumTrustedPlayers(pTrustSetting)
	local vNumPlayers = 0
	
	for vPlayerName, vPlayerSecurity in pairs(GroupCalendar.PlayerSettings.Security.Player) do
		if vPlayerSecurity == pTrustSetting then
			vNumPlayers = vNumPlayers + 1
		end
	end
	
	return vNumPlayers
end

function GroupCalendar.Network:GetIndexedTrustedPlayers(pTrustSetting, pIndex)
	local vPlayerIndex = 1
	
	for vPlayerName, vPlayerSecurity in pairs(GroupCalendar.PlayerSettings.Security.Player) do
		if vPlayerSecurity == pTrustSetting then
			if vPlayerIndex == pIndex then
				return vPlayerName
			end
			
			vPlayerIndex = vPlayerIndex + 1
		end
	end
	
	return nil
end

function GroupCalendar.Network:ScheduleCheckDatabaseTrust()
	MCSchedulerLib:ScheduleUniqueTask(60, GroupCalendar.Database.CheckDatabaseTrust, nil, "GroupCalendar.Database.CheckDatabaseTrust")
end

----------------------------------------
-- Synchronization
----------------------------------------

function GroupCalendar.Network:StartSynch()
	-- If trust isn't available yet just defer the notices
	
	if not self:TrustCheckingAvailable() then
		self.StartSynchOnRosterUpdate = true
		return
	end
	
	-- If synch has already been successful on this login, there's no need to repeat it
	
	self:SetStatus("Synching")
	
	if not self.SynchSucceeded then
		self:QueueOwnedRFUs(0) -- Immediately request updates for our own databases
		self:QueueAllRFV(self.Delay.SynchVersionRequest) -- Queue a version request from other players
		self:QueueExternalRFU(self.Delay.ExternalUpdateRequest) -- Request updates to all other databases after a delay
		MCSchedulerLib:RescheduleTask(self.Delay.SynchComplete, self.SynchComplete, self, "SynchComplete")
	else
		self:QueueAllRFV(self.Delay.SynchVersionRequest) -- Queue a version request from other players
		self:QueueExternalRFU(1) -- Request updates to all other databases after very short delay
		self:SynchComplete()
	end
end

function GroupCalendar.Network:SynchComplete()
	GroupCalendar:NoteMessage("Network synchronization completed")
	
	self.SynchSucceeded = true -- Once set this never gets cleared since as long as you're logged in GC can safely assume you aren't somewhere else making changes
	self.EnableUpdates = true
	self.EnableSelfUpdates = true

	self:SetStatus("Connected")
end

function GroupCalendar.Network:QueueOwnedRFUs(pDelay)
	if GroupCalendar.Debug.Synch then
		GroupCalendar:DebugMessage("Requesting self updates")
	end

	for vRealmName, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if GroupCalendar.Database.DatabaseIsVisible(vDatabase)
		and vDatabase.IsPlayerOwned then
			if GroupCalendar.Debug.Synch then
				GroupCalendar:DebugMessage("Requesting updates for %s", vDatabase.UserName)
			end
			
			self:QueueUpdateRequest(vDatabase, vDatabase.Changes, "DB", true, pDelay)
			self:QueueUpdateRequest(vDatabase, vDatabase.RSVPs, "RAT", true, pDelay)
		end
	end
end

function GroupCalendar.Network:QueueGuildRevisionNotices(pMinRank)
	for vRealmName, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if GroupCalendar.Database.DatabaseIsVisible(vDatabase) then
			local vIsInGuild, vGuildRank = GroupCalendar.Network:UserIsInSameGuild(vDatabase.UserName)
			
			if vIsInGuild then
				if not pMinRank or vGuildRank <= pMinRank then
					self.ResponseQueue:QueueNOU(vDatabase, "DB")
				end
				
				self.ResponseQueue:QueueNOU(vDatabase, "RAT")
			end
		end
	end
end

function GroupCalendar.Network:QueueAllRevisionNotices()
	for vRealmName, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if GroupCalendar.Database.DatabaseIsVisible(vDatabase) then
			self.ResponseQueue:QueueNOU(vDatabase, "DB")
			self.ResponseQueue:QueueNOU(vDatabase, "RAT")
		end
	end
end

function GroupCalendar.Network:QueueUpdateRequest(pDatabase, pChanges, pDatabaseTag, pHighPriority, pDelay)
	local vID, vRevision, vAuthRevision = GroupCalendar.Database.GetChangesID(pDatabase, pChanges)
	
	self.ResponseQueue:QueueRFU(pDatabase.UserName, pDatabaseTag, vID, vRevision, pHighPriority, pDelay)
end

function GroupCalendar.Network:QueueExternalRFU(pDelay)
	if GroupCalendar.Debug.Synch then
		GroupCalendar:DebugMessage("Requesting updates for other databases in %f seconds", pDelay)
	end
	
	if not self.MinTrustedRank then
		self.ResponseQueue:QueueUniqueResponse(self._ALL_RFU, pDelay or self.Delay.ALL_RFU)
	
	elseif GroupCalendar.PlayerGuild then
		self.ResponseQueue:QueueUniqueResponse(self._GUILD_RFU, pDelay or self.Delay._GUILD_RFU, GroupCalendar.PlayerGuild, self.MinTrustedRank)
	
	elseif GroupCalendar.Debug.Synch then
		GroupCalendar:NoteMessage("Couldn't request updates for other databases")
	end
end

function GroupCalendar.Network:QueueAllRFV(pDelay)
	local vDelay = pDelay or self.Delay.RFV
	
	if self.MinTrustedRank then
		self.ResponseQueue:QueueReplacementResponse(self._GUILD_RFV, vDelay)
	else
		self.ResponseQueue:QueueReplacementResponse(self._ALL_RFV, vDelay)
	end
end

----------------------------------------
-- ResponseQueue
----------------------------------------

GroupCalendar.Network.ResponseQueue = {}
GroupCalendar.Network.ResponseQueue.Responses = {}

function GroupCalendar.Network.ResponseQueue:Initialize()
	if GroupCalendar.Debug.ResponseQueue then
		GroupCalendar:DebugMessage("ResponseQueue:Initialize()")
	end
	
	self.Responses = GroupCalendar.RecycleTable(self.Responses)
	self.CurrentResponse = nil
end

function GroupCalendar.Network.ResponseQueue:ResetQueue()
	if GroupCalendar.Debug.ResponseQueue then
		GroupCalendar:DebugMessage("ResponseQueue:ResetQueue()")
	end
	
	GroupCalendar.EraseTable(self.Responses)
	self:EndCurrentResponse()
end

function GroupCalendar.Network.ResponseQueue:SetResponseDelay(pResponse, pDelay)
	if GroupCalendar.Debug.ResponseQueue then
		GroupCalendar:DebugMessage("ResponseQueue:SetResponseDelay(%s, %f)", pResponse._ClassID or "unknown", tern(type(pDelay) == "table", "table", pDelay))
	end
	
	-- Find the response
	
	local vResponseIndex
	
	for vIndex, vResponse in ipairs(self.Responses) do
		if vResponse == pResponse then
			vResponseIndex = vIndex
			break
		end
	end
	
	if not vResponseIndex then
		if GroupCalendar.Debug.ResponseQueue then
			GroupCalendar:DebugMessage("ResponseQueue:SetResponseDelay: Response not found")
		end
		return
	end
	
	-- Calculate the new start time
	
	local vTime = GetTime()
	local vStartTime 
	local vDelay
	
	if type(pDelay) == "table" then
		vDelay = pDelay.Min + math.random() * pDelay.Range
	elseif pDelay then
		vDelay = pDelay
	else
		GroupCalendar:ErrorMessage("ResponseQueue:SetResponseDelay: Delay not specified for response")
		GroupCalendar:DebugStack()
		
		vDelay = 0
	end
	
	vStartTime = vTime + vDelay
	
	if GroupCalendar.Debug.ResponseQueue then
		GroupCalendar:DebugMessage("ResponseQueue:SetResponseDelay: Delay is %f", vDelay)
	end
	
	if not self.NeedSorted then
		-- If the time is sooner, check to see if it's now earlier than its predecessor
		
		if vStartTime < pResponse.StartTime then
			if vResponseIndex > 1
			and vStartTime < self.Responses[vResponseIndex - 1].StartTime then
				self.NeedSorted = true
			end
			
		-- Otherwise see if it's later than its successor
		
		else
			if vResponseIndex < table.getn(self.Responses)
			and vStartTime > self.Responses[vResponseIndex + 1].StartTime then
				self.NeedSorted = true
			end
		end
	end
	
	pResponse.StartTime = vStartTime
	
	-- Kick the queue (will reset it's internal timer if necessary)
	
	self:BeginNextResponse()
end

function GroupCalendar.Network.ResponseQueue:QueueResponse(pMethodTable, pDelay, ...)
	if GroupCalendar.Debug.ResponseQueue then
		GroupCalendar:DebugMessage("ResponseQueue:QueueResponse(%s, %f)", pMethodTable._ClassID or "anonymous", pDelay or 0.0)
	end
	
	local vResponse = GroupCalendar.NewTable()
	
	vResponse._MethodTable = pMethodTable
	
	for vFunctionName, vFunction in pairs(pMethodTable) do
		vResponse[vFunctionName] = vFunction
	end
	
	local vTime = GetTime()
	
	if type(pDelay) == "table" then
		vResponse.StartTime = vTime + pDelay.Min + math.random() * pDelay.Range
	elseif pDelay then
		vResponse.StartTime = vTime + pDelay
	else
		GroupCalendar:ErrorMessage("Delay not specified for response")
		GroupCalendar:DebugStack()
		
		vResponse.StartTime = vTime
	end
	
	if vResponse.Construct then
		vResponse:Construct(unpack(arg))
	end
	
	-- Only need to sort if we're adding a response which starts
	-- earlier than existing responses
	
	if table.getn(self.Responses) > 0
	and vResponse.StartTime < self.Responses[table.getn(self.Responses)].StartTime then
		self.NeedSorted = true
	end
	
	if vResponse.ReadyToSend == nil then
		GroupCalendar:ErrorMessage("Internal error while responding to a request, please report this error.")
		GroupCalendar:ErrorMessage("Request was %s", GroupCalendar.Network.LastMessageReceived or "nil")
	else
		table.insert(self.Responses, vResponse)
	end
	
	self:BeginNextResponse()
	
	return vResponse
end

function GroupCalendar.Network.ResponseQueue:QueueReplacementResponse(pMethodTable, pDelay, ...)
	self:KillResponse(pMethodTable, unpack(arg))
	self:QueueResponse(pMethodTable, pDelay, unpack(arg))
end

function GroupCalendar.Network.ResponseQueue:QueueUniqueResponse(pMethodTable, pDelay, ...)
	if self:FindResponse(pMethodTable, unpack(arg)) then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("QueueUniqueResponse ignoring %s", pMethodTable._ClassID or "unknown class")
		end
		
		return
	end
	
	self:QueueResponse(pMethodTable, pDelay, unpack(arg))
end

function GroupCalendar.Network.ResponseQueue:FindResponse(pMethodTable, ...)
	for vIndex, vResponse in ipairs(self.Responses) do
		if vResponse._MethodTable == pMethodTable
		and (not vResponse.Compare or vResponse:Compare(unpack(arg)) == "EQUAL") then
			return vIndex, vResponse
		end
	end
end

function GroupCalendar.Network.ResponseQueue:FindUserResponse(pMethodTable, pUserName, pDatabaseTag, ...)
	for vIndex, vResponse in ipairs(self.Responses) do
		if vResponse._MethodTable == pMethodTable
		and vResponse.UserName == pUserName
		and vResponse.DatabaseTag == pDatabaseTag
		and (not vResponse.Compare or vResponse:Compare(pUserName, pDatabaseTag, unpack(arg)) == "EQUAL") then
			return vIndex, vResponse
		end
	end
end

function GroupCalendar.Network.ResponseQueue:KillResponse(pMethodTable, ...)
	while true do
		local vIndex, vResponse = self:FindResponse(pMethodTable, unpack(arg))
		
		if vIndex then
			GroupCalendar.DeleteTable(vResponse)
			table.remove(self.Responses, vIndex)
		elseif vResponse then
			self:EndCurrentResponse()
			self:BeginNextResponse()
		else
			return
		end
	end
end

function GroupCalendar.Network.ResponseQueue:BeginNextResponse()
	local vTime = GetTime()
	
	while true do
		-- If we're on a response already or there aren't any
		-- just return
		
		if self.CurrentResponse
		or table.getn(self.Responses) == 0 then
			return
		end
		
		-- Sort the response list if necessary
		
		if self.NeedSorted then
			table.sort(self.Responses, function (pResponse1, pResponse2)
				return pResponse1.StartTime < pResponse2.StartTime
			end)
			
			self.NeedSorted = nil
		end
		
		-- Get the next response
		
		local vNextResponse = self.Responses[1]
		local vNextResponseStart = vNextResponse.StartTime
		
		-- If it's too soon then schedule a delay and return
		
		if vTime < vNextResponseStart then
			local vNextTaskDelay = vNextResponseStart - vTime
			MCSchedulerLib:RescheduleTask(vNextTaskDelay, self.BeginNextResponse, self, "ResponseQueue.BeginNextResponse")
			return
		end
		
		-- If the next response requests a delay, reschedule it and continue
		-- with the one after it
		
		if vNextResponse.BeginResponse then
			local vStatus, vStatusParam = vNextResponse:BeginResponse()
			
			if vStatus == "DELAY" then
				vNextResponse.StartTime = vTime + vStatusParam
				self.NeedSorted = table.getn(self.Responses) > 1 and vNextResponse.StartTime > self.Responses[2].StartTime
				vNextResponse = nil
			elseif vStatus == "CANCEL" then
				table.remove(self.Responses, 1)
				vNextResponse = nil
			elseif vStatus then
				GroupCalendar:ErrorMessage("BeginResponse: Unknown result %s", vStatus)
			end
		end
		
		if vNextResponse then
			self.CurrentResponse = vNextResponse
			
			if GroupCalendar.Network.Channel:ReadyToSend() then
				self:ReadyToSend()
			end
		end
	end -- while true
end

function GroupCalendar.Network.ResponseQueue:CancelIndexedResponse(pIndex)
	if self.Responses[pIndex] == self.CurrentResponse then
		self:EndCurrentResponse()
	else
		table.remove(self.Responses, pIndex)
	end
end

function GroupCalendar.Network.ResponseQueue:EndCurrentResponse()
	if self.CurrentResponse
	and self.CurrentResponse.EndResponse then
		self.CurrentResponse:EndResponse()
	end
	
	self.CurrentResponse = GroupCalendar.DeleteTable(self.CurrentResponse)
	table.remove(self.Responses, 1)
end

function GroupCalendar.Network.ResponseQueue:ReadyToSend()
	if not self.CurrentResponse then
		self:BeginNextResponse()
		return
	end
	
	if self.CurrentResponse.ReadyToSend
	and self.CurrentResponse:ReadyToSend() == "CONTINUE" then
		return
	end
	
	self:EndCurrentResponse()
	self:BeginNextResponse()
end

----------------------------------------
-- ResponseQueue helpers
----------------------------------------

function GroupCalendar.Network.ResponseQueue:QueueNOU(pDatabase, pDatabaseTag, pDelay, pOwnedDelay)
	local vDelay = tern(pDatabase.IsPlayerOwned,
	                    tern(pOwnedDelay ~= nil, pOwnedDelay, GroupCalendar.Network.Delay.NOU_Owned),
	                    tern(pDelay ~= nil, pDelay, GroupCalendar.Network.Delay.NOU_Proxy))
	
	self:QueueUniqueResponse(GroupCalendar.Network._NOU, vDelay, pDatabase.UserName, pDatabaseTag)
end

function GroupCalendar.Network.ResponseQueue:QueueRFU(pUserName, pDatabaseTag, pDatabaseID, pRevision, pHighPriority, pDelay)
	if self:CancelInferiorRFU(GroupCalendar.PlayerName, pUserName, pDatabaseTag, pDatabaseID, pRevision) then
		return
	end
	
	self:QueueResponse(GroupCalendar.Network._RFU, pDelay or GroupCalendar.Network.Delay.RFU, pUserName, pDatabaseTag, pHighPriority)
end

function GroupCalendar.Network.ResponseQueue:CancelInferiorRFU(pSender, pUserName, pDatabaseTag, pDatabaseID, pFromRevision)
	local vIndex, vResponse = self:FindResponse(GroupCalendar.Network._RFU, pUserName, pDatabaseTag)
	
	if not vResponse then
		return false
	end
	
	-- Found a matching RFU, see which one is better
	
	if not vResponse:OurResponseIsBetter(pSender, pDatabaseID, pFromRevision) then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("CancelInferiorRFU: Canceling response for %s %s", pUserName, pDatabaseTag)
		end
		
		self:CancelIndexedResponse(vIndex)
		return false
	else
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("CancelInferiorRFU: Keeping response for %s %s", pUserName, pDatabaseTag)
		end
		
		return true -- Let the caller know we've got something better already
	end
end

function GroupCalendar.Network.ResponseQueue:CancelInferiorUPD(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pFromRevision)
	local vIndex, vResponse = self:FindResponse(GroupCalendar.Network._UPD, pUserName, pDatabaseTag)
	
	if not vResponse then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("CancelInferiorUPD: No existing response for %s %s", pUserName, pDatabaseTag)
		end
		
		return false
	end
	
	if not vResponse:OurResponseIsBetter(pSender, pUserName, pDatabaseTag, pDatabaseID, pFromRevision, pRevision) then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("CancelInferiorUPD: Canceling existing response for %s %s", pUserName, pDatabaseTag)
		end
		
		self:CancelIndexedResponse(vIndex)
		return false
	end
	
	if GroupCalendar.Debug.Updates then
		GroupCalendar:DebugMessage("CancelInferiorUPD: Canceling response for %s %s", pUserName, pDatabaseTag)
	end
	
	return true -- We've got something better
end

function GroupCalendar.Network.ResponseQueue:CancelInferiorNOU(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision)
	local vIndex, vResponse = self:FindResponse(GroupCalendar.Network._NOU, pUserName, pDatabaseTag)
	
	if not vResponse then
		return false
	end
	
	if not vResponse:OurResponseIsBetter(pSender, pDatabaseID, pRevision) then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("Canceling NOU response %s %s (theirs is better)", pDatabaseTag, pUserName)
		end
		
		self:CancelIndexedResponse(vIndex)
		return false
	end
	
	if GroupCalendar.Debug.Updates then
		GroupCalendar:DebugMessage("Keeping NOU request for %s %s (ours is better)", pDatabaseTag, pUserName)
	end
	
	return true
end

----------------------------------------
-- VER (Version)
----------------------------------------

GroupCalendar.Network._VER = {_ClassID = "Netowrk._VER"}

function GroupCalendar.Network._VER:ReadyToSend()
	GroupCalendar.Network.Channel:SendMessage("VER:"..GroupCalendar.VersionString..","..MCDateLib:GetUTCDateTimeStamp())
end

----------------------------------------
-- TIME (Time)
----------------------------------------

GroupCalendar.Network._TIME = {_ClassID = "Network._TIME"}

function GroupCalendar.Network._TIME:ReadyToSend()
	GroupCalendar.Network.Channel:SendMessage("TIME:"..MCDateLib:GetUTCDateTimeStamp())
end

----------------------------------------
-- NOU (Notification Of Update)
----------------------------------------

GroupCalendar.Network._NOU = {_ClassID = "Network._NOU"}

function GroupCalendar.Network._NOU:Construct(pUserName, pDatabaseTag)
	self.UserName = pUserName
	self.DatabaseTag = pDatabaseTag
end

function GroupCalendar.Network._NOU:Compare(pUserName, pDatabaseTag)
	if self.UserName == pUserName
	and self.DatabaseTag == pDatabaseTag then
		return "EQUAL"
	else
		return "NOT_EQUAL"
	end
end

function GroupCalendar.Network._NOU:BeginResponse()
	local vDatabase = GroupCalendar.Database.GetDatabase(self.UserName)
	
	if not vDatabase then
		return "CANCEL"
	end
	
	if vDatabase.IsPlayerOwned then
		if not GroupCalendar.Network.EnableSelfUpdates then
			return "DELAY", 5
		end
	else
		if not GroupCalendar.Network.EnableUpdates then
			return "DELAY", 15
		end
	end
end

function GroupCalendar.Network._NOU:ReadyToSend()
	local vDatabase = GroupCalendar.Database.GetDatabase(self.UserName)
	
	if not vDatabase then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("Can't send NOU for %s because the database doesn't exist", self.UserName)
		end
		
		return
	end
	
	local vChanges = GroupCalendar.Database.GetDatabaseChanges(vDatabase, self.DatabaseTag)

	if not vChanges then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("Can't send NOU for %s %s because the changes don't exist", self.UserName, self.DatabaseTag)
		end
		
		return
	end
	
	local vRevisionPath = CalendarChanges_GetRevisionPath(self.DatabaseTag, self.UserName, vChanges.ID, vChanges.Revision)
	
	GroupCalendar.Network.Channel:SendMessage(vRevisionPath..tern(CalendarChanges_IsEmpty(vChanges), "DEL", "NOU"))
end

function GroupCalendar.Network._NOU:OurResponseIsBetter(pSender, pDatabaseID, pRevision)
	local vDatabase = GroupCalendar.Database.GetDatabase(self.UserName)
	local vChanges = GroupCalendar.Database.GetDatabaseChanges(vDatabase, self.DatabaseTag)
	local vDatabaseID, vCurrentRevision, vAuthRevision = GroupCalendar.Database.GetChangesID(vDatabase, vChanges)
	
	if pSender and pSender == self.UserName then
		return false -- Owner wins
	elseif vDatabaseID > pDatabaseID then
		return true -- Ours is newer
	elseif vDatabaseID < pDatabaseID then
		return false -- Theirs is newer
	elseif vCurrentRevision > pRevision then
		return true -- Ours is newer
	elseif vCurrentRevision < pRevision then
		return false -- Theirs is newer
	else
		return false -- They're identical, so drop ours
	end
end

----------------------------------------
-- RFU (Request For Update)
----------------------------------------

GroupCalendar.Network._RFU = {_ClassID = "Network._RFU"}

function GroupCalendar.Network._RFU:Construct(pUserName, pDatabaseTag, pHighPriority)
	self.UserName = pUserName
	self.DatabaseTag = pDatabaseTag
	self.HighPriority = pHighPriority
end

function GroupCalendar.Network._RFU:Compare(pUserName, pDatabaseTag, pHighPriority)
	if self.UserName == pUserName
	and self.DatabaseTag == pDatabaseTag then
		-- HACK: Adjust the priority if it's elevated
		
		if pHighPriority then
			self.HighPriority = true
		end
		
		return "EQUAL"
	else
		return "NOT_EQUAL"
	end
end

function GroupCalendar.Network._RFU:ReadyToSend()
	local vDatabase = GroupCalendar.Database.GetDatabase(self.UserName)
	local vChanges = GroupCalendar.Database.GetDatabaseChanges(vDatabase, self.DatabaseTag)
	local vDatabaseID, vCurrentRevision, vAuthRevision = GroupCalendar.Database.GetChangesID(vDatabase, vChanges)
	
	local vRequestMessage = CalendarChanges_GetRevisionPath(self.DatabaseTag, self.UserName, vDatabaseID, vCurrentRevision, vAuthRevision).."RFU"

	if self.HighPriority then
		vRequestMessage = vRequestMessage..":H"
	end

	GroupCalendar.Network.Channel:SendMessage(vRequestMessage)
end

function GroupCalendar.Network._RFU:OurResponseIsBetter(pSender, pDatabaseID, pFromRevision)
	local vDatabase = GroupCalendar.Database.GetDatabase(self.UserName)
	local vChanges = GroupCalendar.Database.GetDatabaseChanges(vDatabase, self.DatabaseTag)
	local vDatabaseID, vCurrentRevision, vAuthRevision = GroupCalendar.Database.GetChangesID(vDatabase, vChanges)
	
	if pSender and pSender == self.UserName then
		return false -- Owner wins
	elseif pDatabaseID == nil then
		GroupCalendar:ErrorMessage("Internal error -- no database ID found in a request from %s", pSender)
		GroupCalendar:ErrorMessage("Request was %s", GroupCalendar.Network.LastMessageReceived or "nil")
		
		return true -- Shouldn't get here, but it has so handle it gracefully and get out
	elseif vDatabaseID > pDatabaseID then
		return true -- Theirs is out of date
	elseif vDatabaseID < pDatabaseID then
		return false -- Ours is out of date
	elseif vCurrentRevision > pFromRevision then
		return false -- Their request will cover anything we need
	elseif vCurrentRevision < pFromRevision then
		return true -- We need more than they're asking for
	else
		return false -- They're identical, so drop ours
	end
end

----------------------------------------
-- _ALL_RFU
----------------------------------------

GroupCalendar.Network._ALL_RFU = {_ClassID = "Network._ALL_RFU"}

function GroupCalendar.Network._ALL_RFU:ReadyToSend()
	GroupCalendar.Network.Channel:SendMessage("ALL/RFU")
	GroupCalendar.Network:QueueAllRevisionNotices()
end

----------------------------------------
-- _ALL_RFV
----------------------------------------

GroupCalendar.Network._ALL_RFV = {_ClassID = "Network._ALL_RFV"}

function GroupCalendar.Network._ALL_RFV:ReadyToSend()
	GroupCalendar.Network.Channel:SendMessage("ALL/RFV")
	GroupCalendar.Network._VER.ReadyToSend(self)
end

----------------------------------------
-- _GUILD_RFU
----------------------------------------

GroupCalendar.Network._GUILD_RFU = {_ClassID = "Network._GUILD_RFU"}

function GroupCalendar.Network._GUILD_RFU:Construct(pGuildName, pMinRank)
	self.GuildName = pGuildName
	self.MinRank = pMinRank
end

function GroupCalendar.Network._GUILD_RFU:ReadyToSend()
	GroupCalendar.Network.Channel:SendMessage("GLD:"..self.GuildName..","..self.MinRank.."/RFU")
	GroupCalendar.Network:QueueGuildRevisionNotices(self.MinRank)
end

----------------------------------------
-- _GUILD_RFV
----------------------------------------

GroupCalendar.Network._GUILD_RFV = {_ClassID = "Network._GUILD_RFV"}

function GroupCalendar.Network._GUILD_RFV:ReadyToSend()
	if not GroupCalendar.PlayerGuild then
		return
	end
	
	GroupCalendar.Network.Channel:SendMessage("GLD:"..GroupCalendar.PlayerGuild.."/RFV")
	GroupCalendar.Network._VER.ReadyToSend(self)
end

----------------------------------------
-- UPD (Update)
----------------------------------------

GroupCalendar.Network._UPD = {_ClassID = "Network._UPD"}

function GroupCalendar.Network._UPD:Construct(pUserName, pDatabaseTag, pDatabaseID, pFromRevision, pHighPriority)
	self.UserName = pUserName
	self.DatabaseTag = pDatabaseTag
	self.DatabaseID = pDatabaseID
	self.FromRevision = pFromRevision
	self.HighPriority = pHighPriority
	self.ResponseStarted = false
end

function GroupCalendar.Network._UPD:Compare(pUserName, pDatabaseTag, pDatabaseID, pFromRevision)
	if self.UserName ~= pUserName
	or self.DatabaseTag ~= pDatabaseTag then
		return "NOT_EQUAL"
	end
	
	if not pDatabaseID then
		return "EQUAL"
	end
	
	if pDatabaseID ~= self.DatabaseID then
		return "NOT_EQUAL"
	end
	
	if not pFromRevision then
		return "EQUAL"
	end
	
	if self.FromRevision ~= pFromRevision then	
		return "NOT_EQUAL"
	end
	
	return "EQUAL"
end

function GroupCalendar.Network._UPD:OurResponseIsBetter(pSender, pUserName, pDatabaseTag, pDatabaseID, pFromRevision, pToRevision)
	local vDatabase = GroupCalendar.Database.GetDatabase(self.UserName)
	local vChanges = GroupCalendar.Database.GetDatabaseChanges(vDatabase, self.DatabaseTag)
	
	if pSender == pUserName then
		return false -- Owner always wins
	elseif pDatabaseID > self.DatabaseID then
		return false -- Theirs is newer
	elseif pDatabaseID < self.DatabaseID then
		return true -- Ours is newer
	elseif pFromRevision < self.FromRevision then
		return false -- Theirs has more coverage
	elseif pFromRevision > self.FromRevision then
		return true -- Ours has more coverage
	elseif (not vChanges or pToRevision >= vChanges.Revision) then
		return false -- Theirs is more current
	else
		return true -- Ours is more current
	end
	
	return false
end

function GroupCalendar.Network._UPD:BeginResponse()
	self.ResponseStarted = true
	
	local vDatabase = GroupCalendar.Database.GetDatabase(self.UserName)
	
	if not self.HighPriority then
		if vDatabase.IsPlayerOwned then
			if not GroupCalendar.Network.EnableSelfUpdates then
				return "DELAY", 5
			end
		else
			if not GroupCalendar.Network.EnableUpdates then
				return "DELAY", 15
			end
		end
	end
	
	local vChanges = GroupCalendar.Database.GetDatabaseChanges(vDatabase, self.DatabaseTag)
	
	if not vChanges then
		return "CANCEL"
	end
	
	if vDatabase.IsPlayerOwned then
		CalendarChanges_LockdownCurrentChangeList(vChanges)
	end
	
	local vRevisionPath = CalendarChanges_GetRevisionPath(self.DatabaseTag, self.UserName, vChanges.ID, vChanges.Revision)
	
	if CalendarChanges_IsEmpty(vChanges) then
		GroupCalendar.Network.Channel:SendMessage(vRevisionPath.."DEL")
		return "CANCEL"
	end
	
	self.Queue = GroupCalendar.NewTable()
	
	table.insert(self.Queue, vRevisionPath.."UPD:"..self.FromRevision)
	
	if GroupCalendar.Debug.Updates then
		GroupCalendar:DebugMessage("Sending update for %s %s %d from %d", self.DatabaseTag, self.UserName, vChanges.ID, vChanges.Revision)
		GroupCalendar:DebugMessage("From revision %d to revision %d", self.FromRevision, vChanges.Revision)
	end
	
	GroupCalendar.Network.MD5:BeginDigest()
	for vRevision = self.FromRevision + 1, vChanges.Revision do
		local vRevisionPath, vRevisionPath2 = CalendarChanges_GetQuickRevisionPath(self.DatabaseTag, vRevision)
		local vChangeList = vChanges.ChangeList[vRevision]
		
		if vChangeList then
			vChangeList.IsOpen = nil -- Make sure IsOpen is cleared, a bug or crash may have caused it to remain open
			
			for vIndex, vChange in ipairs(vChangeList) do
				if vIndex == 1 then
					table.insert(self.Queue, vRevisionPath..vChange)
				else
					table.insert(self.Queue, vRevisionPath2..vChange)
				end
				
				GroupCalendar.Network.MD5:DigestString(vChange)
			end
		end
	end
	
	local vChecksum = GroupCalendar.Network.MD5:EndDigest()
	
	table.insert(self.Queue, CalendarChanges_GetQuickRevisionPath(self.DatabaseTag, vChanges.Revision).."END:"..self.FromRevision..","..vChecksum)
	self.QueueIndex = 0
end

function GroupCalendar.Network._UPD:EndResponse()
	-- Let the network know we're aborting
	
	if self.ResponseStarted then
		GroupCalendar.Network.Channel:SendMessage("RST")
	end
	
	self.Queue = GroupCalendar.DeleteTable(self.Queue)
end

function GroupCalendar.Network._UPD:ReadyToSend()
	self.QueueIndex = self.QueueIndex + 1
	GroupCalendar.Network.Channel:SendMessage(self.Queue[self.QueueIndex])
	
	if self.QueueIndex < table.getn(self.Queue) then
		return "CONTINUE"
	end
	
	self.ResponseStarted = nil -- So we know it finished successfully
end

----------------------------------------
-- Incoming messages
----------------------------------------

-- HACK: This code finds new senders and sets the faction field of their database
--       This should be removed eventually, but it will help fix up databases
--       prior to 4.0 which didn't include the faction information

GroupCalendar.Network.CheckedSenderFaction = {}

function GroupCalendar.Network:ChannelMessageReceived(pSender, pMessage)
	-- If the sender is new to us (this session), make sure his database
	-- has the faction sent correctly.  Do this before the trust check
	-- since the sender may be trusted by other toons on this same account
	-- so this will ensure the faction gets set correctly as quickly as possible
	
	if not GroupCalendar.Network.CheckedSenderFaction[pSender] then
		local vDatabase = GroupCalendar.Database.GetDatabase(pSender)
		
		if vDatabase then
			vDatabase.Faction = GroupCalendar.PlayerFactionGroup
		end
		
		GroupCalendar.Network.CheckedSenderFaction[pSender] = true
	end
	
	-- Just return if we don't trust them at all
	
	local vTrustLevel = self:GetUserTrustLevel(pSender)
	
	if vTrustLevel <= 0 then
		return
	end
	
	--
	
	local vCommand = self:ParseCommandString(pMessage)
	
	if not vCommand then
		if GroupCalendar.Debug.Errors then
			GroupCalendar:DebugMessage("ProcessCommandString: Couldn't parse ["..pSender.."]:"..pCommandString)
		end
		
		return
	end
	
	-- Check for dead updates
	
	local vTime = GetTime()
	
	if not self.NextDeadUpdateCheck
	or vTime >= self.NextDeadUpdateCheck then
		self:CheckDeadUpdates(vTime)
	end
	
	-- Decode the command
	
	self.LastMessageReceived = pMessage
	self:ProcessCommand(pSender, vTrustLevel, vCommand, vTime)
	self.LastMessageReceived = nil
	
	GroupCalendar.DeleteTable(vCommand)
	
	-- Rebuild any RSVP lists which now need it
	
	if GroupCalendar.Database.RebuildRSVPQueue then
		for vDatabase, _ in pairs(GroupCalendar.Database.RebuildRSVPQueue) do
			GroupCalendar.Database.RebuildRSVPs(vDatabase)
		end
		
		GroupCalendar.Database.RebuildRSVPQueue = nil
	end
end

----------------------------------------
GroupCalendar.Network.TopLevelCommands = {}
----------------------------------------

function GroupCalendar.Network.TopLevelCommands:GLD(pSender, pTrustLevel, pCommand, pOperands)
	self:KillSendersUpdates(pSender) -- Can't still be sending an update if he's sending this
	
	local vGuildName = pOperands[1]
	local vMinRank = tonumber(pOperands[2])
	
	-- Ignore guild commands if they're not directed at the player's guild
	-- or not at the player's rank
	
	if vGuildName ~= GroupCalendar.PlayerGuild then
		return
	end
	
	local vOpcode = pCommand[1].opcode
	local vOperands = pCommand[1].operands

	table.remove(pCommand, 1)
	
	if vOpcode == "RFU" then
		self.ResponseQueue:KillResponse(self._GUILD_RFU)
		self:QueueGuildRevisionNotices(vMinRank)
	elseif vOpcode == "RFV" then
		self.ResponseQueue:KillResponse(self._GUILD_RFV)
		self.ResponseQueue:QueueUniqueResponse(self._VER, self.Delay.VER)
	end
end

function GroupCalendar.Network.TopLevelCommands:ALL(pSender, pTrustLevel, pCommand, pOperands)
	self:KillSendersUpdates(pSender) -- Can't still be sending an update if he's sending this
	
	--
	
	local vOpcode = pCommand[1].opcode
	local vOperands = pCommand[1].operands
	
	table.remove(pCommand, 1)
	
	if vOpcode == "RFU" then
		self.ResponseQueue:KillResponse(self._ALL_RFU)
		self:QueueAllRevisionNotices()
	elseif vOpcode == "RFV" then
		self.ResponseQueue:KillResponse(self._ALL_RFV)
		self.ResponseQueue:QueueUniqueResponse(self._VER, self.Delay.VER)
	end
end

function GroupCalendar.Network.TopLevelCommands:VER(pSender, pTrustLevel, pCommand, pOperands)
	self:KillSendersUpdates(pSender) -- Can't still be sending an update if he's sending this
	
	local vDatabase = GroupCalendar.Database.GetDatabase(pSender, true)
	
	if not vDatabase then
		return
	end
	
	vDatabase.AddonVersion = pOperands[1]
	vDatabase.AddonVersionUpdated = MCDateLib:GetServerDateTimeStamp()
	vDatabase.Faction = GroupCalendar.PlayerFactionGroup
	
	local vTimeDateStamp = tonumber(pOperands[2])
	local vOurTimeDateStamp = MCDateLib:GetUTCDateTimeStamp()
	local vOurDifference = math.abs(vTimeDateStamp - vOurTimeDateStamp)
	
	if vOurDifference > 20 * 60 then
		-- Schedule a TIME notice to express our surprise
		
		self.ResponseQueue:QueueUniqueResponse(self._TIME, self.Delay.TIME)
		self.NumTimeSamplesReceived = 0
	end
	
	if vTimeDateStamp then
		GroupCalendar.Time:TimeSampleReceived(pSender, vTimeDateStamp)
	end
	
	GroupCalendar_VersionDataChanged()
end

function GroupCalendar.Network.TopLevelCommands:TIME(pSender, pTrustLevel, pCommand, pOperands)
	self:KillSendersUpdates(pSender) -- Can't still be sending an update if he's sending this
	
	if self.NumTimeSamplesReceived then
		self.NumTimeSamplesReceived = self.NumTimeSamplesReceived + 1
		
		if self.NumTimeSamplesReceived > 10 then
			self.ResponseQueue:KillResponse(self._TIME) -- Got plenty of samples now, don't bother
			self.NumTimeSamplesReceived = nil
		end
	end
	
	GroupCalendar.Time:TimeSampleReceived(pSender, tonumber(pOperands[1]))
end

function GroupCalendar.Network:HandleDBAndRATCommands(pDatabaseTag, pSender, pTrustLevel, pCommand, pOperands)
	local vUpdate = self:FindUpdate(pSender, nil, pDatabaseTag)
	local vUserName, vDatabaseID, vRevision, vAuthRevision = GroupCalendar.Network:UnpackUpdateRevision(vUpdate, pOperands)
	
	if not vUserName then
		return
	end
	
	if not vRevision then
		vRevision = 0
	end
	
	-- Untrusted users exit here
	
	if not self:UserIsTrusted(vUserName, pDatabaseTag) then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("Network:ProcessCommand: User %s is not trusted for %s command", vUserName, pDatabaseTag)
		end
		
		return
	end
	
	-- Process the command
	
	self:ProcessDatabaseCommand(pSender, vUserName, pDatabaseTag, vDatabaseID, vRevision, vAuthRevision, pCommand)
end

function GroupCalendar.Network.TopLevelCommands:RST(pSender, pTrustLevel, pCommand, pOperands)
	-- Sender is letting us know he's recovering from a fault (probably interrupted
	-- during an update).  Reset anything we're receiving from him
	
	self:KillSendersUpdates(pSender)
end

function GroupCalendar.Network.TopLevelCommands:DB(pSender, pTrustLevel, pCommand, pOperands)
	return self:HandleDBAndRATCommands("DB", pSender, pTrustLevel, pCommand, pOperands)
end

function GroupCalendar.Network.TopLevelCommands:RAT(pSender, pTrustLevel, pCommand, pOperands)
	return self:HandleDBAndRATCommands("RAT", pSender, pTrustLevel, pCommand, pOperands)
end

function GroupCalendar.Network:ProcessCommand(pSender, pTrustLevel, pCommand, pTime)
	local vOpcode = pCommand[1].opcode
	local vOperands = pCommand[1].operands
	
	table.remove(pCommand, 1)
	
	-- Find the command handler and call it
	
	local vHandler = self.TopLevelCommands[vOpcode]
	
	-- Unknown code
	
	if not vHandler then
		if GroupCalendar.Debug.Errors then
			GroupCalendar:DebugMessage("ProcessCommand: Unknown opcode %s", vOpcode)
		end
		
		return
	end
	
	-- 
	
	return vHandler(self, pSender, pTrustLevel, pCommand, vOperands)
end

function GroupCalendar.Network:ParseCommandString(pCommandString)
	-- Break the command into parts
	
	local vCommand = GroupCalendar.NewTable()
	
	for vOpcode, vOperands in string.gfind(pCommandString, "(%w+):?([^/]*)") do
		local vOperation = GroupCalendar.NewTable()
		
		vOperation.opcode = vOpcode
		vOperation.operandString = vOperands
		vOperation.operands = self:ParseParameterString(vOperands)
		
		table.insert(vCommand, vOperation)
	end
	
	return vCommand
end

function GroupCalendar.Network:ParseParameterString(pParameterString, pRecycleTable)
	if not pParameterString then
		return {}
	end
	
	local vParameters = GroupCalendar.NewTable()
	local vIndex = 0
	local vFound = true
	local vStartIndex = 1
	
	while vFound do
		local vEndIndex
		
		vFound, vEndIndex, vParameter = string.find(pParameterString, "([^,]*),", vStartIndex)
		
		vIndex = vIndex + 1
		
		if not vFound then
			vParameters[vIndex] = string.sub(pParameterString, vStartIndex)
			break
		end
		
		vParameters[vIndex] = vParameter
		vStartIndex = vEndIndex + 1
	end
	
	return vParameters
end

function GroupCalendar.Network:UnpackUpdateRevision(pUpdate, pOperands)
	local vUserName = pOperands[1]
	local vDatabaseID, vRevision, vAuthRevision
	
	-- If the sender is using wildcards, fetch the path from
	-- the update records
	
	if vUserName == "*" then
		if not pUpdate then
			return
		end
		
		vUserName = pUpdate.mUserName
		vDatabaseID = pUpdate.mDatabaseID
		vAuthRevision = tonumber(pOperands[3])
		
		if pOperands[2] == "*" then
			if not pUpdate.mLastRevision then
				if GroupCalendar.Debug.Updates then
					GroupCalendar:DebugMessage("Error: Used wildcard reversion but no previous revision is known")
				end
				
				return
			end
			
			vRevision = pUpdate.mLastRevision 
		else
			vRevision = tonumber(pOperands[2])
			pUpdate.mLastRevision = vRevision
		end
	else
		vDatabaseID = tonumber(pOperands[2])
		vAuthRevision = tonumber(pOperands[4])
		
		if pOperands[3] == "*" then
			if not pUpdate or not pUpdate.mLastRevision  then
				if GroupCalendar.Debug.Updates then
					GroupCalendar:DebugMessage("Error: Used wildcard reversion but no previous revision is known")
				end
				
				return
			end
			
			vRevision = pUpdate.mLastRevision 
		else
			vRevision = tonumber(pOperands[3])
			
			if pUpdate then
				pUpdate.mLastRevision = vRevision
			end
		end
	end
	
	return vUserName, vDatabaseID, vRevision, vAuthRevision
end

function GroupCalendar.Network:UpdateIsInteresting(pSender, pUserName, pChanges, pDatabaseID, pRevision, pAuthRevision)
	-- Unless it's an update coming directly from the owner, ignore updates
	-- where the ID is older than the one we already have
	
	if pSender ~= pUserName
	and pChanges
	and pDatabaseID < pChanges.ID then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("UpdateIsInteresting: Not interesting, theirs is older")
		end
		return false
	end
	
	-- If it's an update which matches our existing database ID
	-- then check to see if it should be ignored
	
	if pChanges and pChanges.ID == pDatabaseID then
		-- If it's the owner himself then ignore the update if it's not
		-- any newer than what we last got directly from the owner
		
		if pSender == pUserName then
			if not pChanges.AuthRevision then
				GroupCalendar:DebugMessage("AuthRevision is nil")
				GroupCalendar:DebugTable("    pChanges", pChanges)
				GroupCalendar:DebugStack("    ")
				GroupCalendar:DebugMark()
			end
			
			if pRevision <= pChanges.AuthRevision then
				if GroupCalendar.Debug.Updates then
					GroupCalendar:DebugMessage("UpdateIsInteresting: Not interesting, we've got that owner coverage")
				end
				return false
			end
		
		-- It's not he owner so ignore the update if it's no better
		-- than our existing revision
		
		else
			if pRevision <= pChanges.Revision then
				if GroupCalendar.Debug.Updates then
					GroupCalendar:DebugMessage("UpdateIsInteresting: Not interesting, their revision isn't newer")
				end
				return false
			end
		end
	end
	
	-- If it isn't our database ID or we have no changes at all, then we want it
	
	if GroupCalendar.Debug.Updates then
		GroupCalendar:DebugMessage("UpdateIsInteresting: Yes")
	end
	
	return true
end

----------------------------------------
GroupCalendar.Network.DatabaseCommands = {}
----------------------------------------

function GroupCalendar.Network:ProcessDatabaseCommand(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pAuthRevision, pCommand)
	local vCommand = table.remove(pCommand, 1)
	local vHandlerFunc = GroupCalendar.Network.DatabaseCommands[vCommand.opcode]
	
	if vHandlerFunc then
		return vHandlerFunc(self, pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pAuthRevision, vCommand.operands, pCommand)
	else
		GroupCalendar:DebugMessage("ProcessDatabaseCommand: Handler not found for %s", vCommand.opcode or "nil")
	end
	
	GroupCalendar.DeleteTable(vCommand)
end

function GroupCalendar.Network.DatabaseCommands:RFV(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pAuthRevision, pOperands, pCommand)
	-- If the sender is seen transmitting an RFV while he has a database update
	-- pending then it probably means he d/c'd.  Kill the database update in that
	-- case
	
	self:KillSendersUpdates(pSender)
	
	-- Ignore the request if it isn't directed to us
	
	if pUserName ~= GroupCalendar.PlayerName then
		return
	end
	
	self.ResponseQueue:QueueUniqueResponse(self._VER, self.Delay.VER)
end

function GroupCalendar.Network.DatabaseCommands:NOU(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pAuthRevision, pOperands, pCommand)
	-- If the sender is seen transmitting an NOU while he has a database update
	-- pending then it probably means he d/c'd.  Kill the database update in that
	-- case
	
	self:KillSendersUpdates(pSender)

	-- Fetch the database and change list
	
	local vDatabase, vLocalUser, vChanges, vIsPlayerOwned = GroupCalendar.Database.GetDatabaseChangesByName(pUserName, pDatabaseTag, false)
	
	if vDatabase and not vLocalUser then
		GroupCalendar.Database.AssumeDatabase(pUserName, pDatabaseTag)
	end
	
	-- If it isn't our database, cancel any inferior NOU responses which are queued up
	
	if not vIsPlayerOwned or pUserName ~= GroupCalendar.PlayerName then
		self.ResponseQueue:CancelInferiorNOU(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision)
	end
	
	-- Treat any NOUs for our own databases as RFUs instead
	
	if vIsPlayerOwned then
		return GroupCalendar.Network.DatabaseCommands.RFU(self, pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pAuthRevision, pOperands, pCommand)
	end
	
	-- If it isn't better than what we've got then ignore it
	
	if not self:UpdateIsInteresting(pSender, pUserName, vChanges, pDatabaseID, pRevision, pAuthRevision) then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("NOU: Ignoring notice becuase UpdateIsInteresting said so")
		end
		
		return
	end
	
	-- Request the update
	
	local vDatabaseID, vRevision
	
	if vChanges then
		vDatabaseID = vChanges.ID
		vRevision = vChanges.Revision
	else
		vDatabaseID = 0
		vRevision = 0
	end
	
	self.ResponseQueue:QueueRFU(pUserName, pDatabaseTag, vDatabaseID, vRevision)
end

function GroupCalendar.Network.DatabaseCommands:RFU(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pAuthRevision, pOperands, pCommand)
	-- If the sender is seen transmitting an RFU while he has a database update
	-- pending then it probably means he d/c'd.  Kill the old update when that happens

	self:KillSendersUpdates(pSender)
	
	-- Fetch the database and change list
	
	local vDatabase, vLocalUser, vChanges, vIsPlayerOwned = GroupCalendar.Database.GetDatabaseChangesByName(pUserName, pDatabaseTag, false)
	
	if vDatabase and not vLocalUser then
		GroupCalendar.Database.AssumeDatabase(pUserName, pDatabaseTag)
	end
	
	-- Cancel any NOUs which are covered
	
	local vIsThisPlayerOwned = vIsPlayerOwned and pUserName == GroupCalendar.PlayerName
	
	if not vIsThisPlayerOwned and pDatabaseID ~= 0 then
		self.ResponseQueue:CancelInferiorNOU(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision)
		self.ResponseQueue:CancelInferiorRFU(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision)
	end
	
	-- Ignore the request if it's for a database we're not supposed to be seeing
	-- or if we don't have any data for it
	
	if not vDatabase
	or not vChanges
	or not GroupCalendar.Database.DatabaseIsVisible(vDatabase) then
		return
	end
	
	-- Give the owner high-priority to help ensure that he can roam successfully
	
	local vHighPriority = pSender == pUserName or pOperands[1] == "H"
	
	self:ProcessChangesRFU(vChanges, pDatabaseTag, vIsThisPlayerOwned, vHighPriority, pUserName, pDatabaseID, pRevision, pAuthRevision)
end

function GroupCalendar.Network.DatabaseCommands:UPD(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pAuthRevision, pOperands, pCommand)
	-- If the sender is seen transmitting an UPD while he has a database update
	-- pending then it probably means he d/c'd.  Kill the database update in that
	-- case.  Pass in the user name we're getting an update for so that KillSendersUpdates
	-- doesn't request an update if it kills a request for this user.
	
	self:KillSendersUpdates(pSender, pUserName)

	local vDatabase, vLocalUser, vChanges, vIsPlayerOwned = GroupCalendar.Database.GetDatabaseChangesByName(pUserName, pDatabaseTag, false)
	
	if vDatabase and not vLocalUser then
		GroupCalendar.Database.AssumeDatabase(pUserName, pDatabaseTag)
	end
	
	local vIsThisPlayerOwned = vIsPlayerOwned and pUserName == GroupCalendar.PlayerName
	local vSinceRevision = tonumber(pOperands[1])
	
	if not vSinceRevision then
		GroupCalendar:DebugMessage("%s %s received from %s for %s with no SinceRevision", pDatabaseTag, "UPD", pSender, pUserName)
		GroupCalendar:DebugTable("Operands", pOperands)
		GroupCalendar:DebugTable("Command", pCommand)
		return
	end
	
	if vIsPlayerOwned then
		-- Treat an UPD as if it's also an RFU so that we can auto-correct any misunderstandings
		
		GroupCalendar.Network.DatabaseCommands.RFU(self, pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pAuthRevision, pOperands, pCommand)
	else
		-- If we're waiting to notify the network of the same update, cancel the request
		
		self.ResponseQueue:CancelInferiorNOU(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision)
		
		-- If we're waiting to request this same update, cancel the request
		
		self.ResponseQueue:CancelInferiorRFU(pSender, pUserName, pDatabaseTag, pDatabaseID, vSinceRevision)

		-- If we're waiting to send this same update, cancel the response
		
		self.ResponseQueue:CancelInferiorUPD(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, vSinceRevision)
	end
	
	-- If it isn't better than what we've got then ignore it
	
	if not self:UpdateIsInteresting(pSender, pUserName, vChanges, pDatabaseID, pRevision, pAuthRevision) then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("Ignoring update becuase UpdateIsInteresting said so")
		end
		return
	end
	
	-- Begin a database update
	
	self:BeginUpdate(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, vSinceRevision)
end

function GroupCalendar.Network.DatabaseCommands:EVT(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pAuthRevision, pOperands, pCommand)
	local vUpdate = self:FindUpdate(pSender, pUserName, pDatabaseTag, pDatabaseID)
	
	if not vUpdate then
		return
	end
	
	-- Bump the update time
	
	vUpdate.mLastMessageTime = GetTime()
	
	--
	
	local vChanges = vUpdate.mChanges[pRevision]
	
	if not vChanges then
		vChanges = GroupCalendar.NewTable()
		vUpdate.mChanges[pRevision] = vChanges
	end
	
	-- Reconstruct the change string
	
	local vChangeString = "EVT:"..table.concat(pOperands, ",")
	
	for vIndex, vCommand in ipairs(pCommand) do
		vChangeString = vChangeString.."/"..vCommand.opcode
	
		if vCommand.operandString and vCommand.operandString ~= "" then
			vChangeString = vChangeString..":"..vCommand.operandString
		end
	end
	
	table.insert(vChanges, vChangeString)
	
	vUpdate.mMD5:DigestString(vChangeString)
end

function GroupCalendar.Network.DatabaseCommands:END(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pAuthRevision, pOperands, pCommand)
	local vUpdate = self:FindUpdate(pSender, pUserName, pDatabaseTag, pDatabaseID, true)
	
	if not vUpdate then
		return
	end
	
	-- Sanity check: make sure the sinceRevision field matches the original UPD message
	
	local vSinceRevision = tonumber(pOperands[1])
	
	if vUpdate.mSinceRevision ~= vSinceRevision then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("Ignoring %s update for %s, %d since revision %d from %s: Closing revision was %d instead of %d", pDatabaseTag, pUserName, pRevision, vSinceRevision, pSender, vSinceRevision, vUpdate.mSinceRevision)
		end
		return
	end
	
	local vChecksum = vUpdate.mMD5:EndDigest()
	
	if pOperands[2] and pOperands[2] ~= vChecksum then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("EndUpdate: Rejecting %s update for %s, %d since revision %d from %s: Checksum failed", pDatabaseTag, pUserName, pRevision, vSinceRevision, pSender)
			GroupCalendar:DebugMessage("      Sender checksum: %s", pOperands[2])
			GroupCalendar:DebugMessage("      Receiver checksum: %s", vChecksum)
		end
		
		-- Ask for another copy since this one is damaged
		
		self.ResponseQueue:QueueRFU(pUserName, pDatabaseTag)
		return
	end
	
	-- The update was received successfully
	
	if GroupCalendar.Debug.Updates then
		GroupCalendar:DebugMessage("EndUpdate: Process %s update for %s, %d since revision %d from %s", pDatabaseTag, pUserName, pRevision, vSinceRevision, pSender)
	end
	
	local vDatabase = GroupCalendar.Database.GetDatabase(pUserName, true)
	local vChanges = GroupCalendar.Database.GetDatabaseChanges(vDatabase, pDatabaseTag)
	local vReconstruct = false
	
	if vDatabase.IsPlayerOwned then
		self:QueueSelfUpdate(pDatabaseTag, vUpdate)
		return
	end
	
	if pDatabaseTag == "DB" then
		GroupCalendar.Network:ProcessDatabaseUpdate(vUpdate, false)
		GroupCalendar.DeleteTable(vUpdate)
	
	elseif pDatabaseTag == "RAT" then
		GroupCalendar.Network:ProcessRSVPUpdate(vUpdate, false)
		GroupCalendar.DeleteTable(vUpdate)
	
	else
		GroupCalendar:ErrorMessage("Couldn't end update with tag %s", pDatabaseTag)
	end
end

function GroupCalendar.Network.DatabaseCommands:DEL(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pAuthRevision, pOperands, pCommands)
	-- If the sender is seen transmitting a DEL while he has a database update
	-- pending then it probably means he d/c'd.  Kill the database update in that
	-- case.
	
	self:KillSendersUpdates(pSender)
	
	-- If it isn't better than what we've got then ignore it
	
	local vDatabase, vLocalUser, vChanges, vIsPlayerOwned = GroupCalendar.Database.GetDatabaseChangesByName(pUserName, pDatabaseTag, false)
	
	if vDatabase and not vLocalUser then
		GroupCalendar.Database.AssumeDatabase(pUserName, pDatabaseTag)
	end
	
	local vIsThisPlayerOwned = vIsPlayerOwned and pUserName == GroupCalendar.PlayerName
	
	if not self:UpdateIsInteresting(pSender, pUserName, vChanges, pDatabaseID, pRevision, pAuthRevision) then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("DEL: Ignoring update becuase UpdateIsInteresting said so")
		end
		return
	end
	
	-- Delete the database
	
	if not vIsThisPlayerOwned then
		-- If we're waiting to request this same update, cancel the request
		
		self.ResponseQueue:CancelInferiorRFU(pSender, pUserName, pDatabaseTag, pDatabaseID, 0)

		-- If we're waiting to send this same update, cancel the response
		
		self.ResponseQueue:CancelInferiorUPD(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, 0)
	end
	
	self:DeleteDatabase(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision)
end

----------------------------------------
-- Incoming updates
----------------------------------------

function GroupCalendar.Network:CheckDeadUpdates(pTime)
	self:KillOldUpdates(self.IncomingUpdates, pTime)

	self.NextDeadUpdateCheck = pTime + self.Delay.DeadUpdateCheck
end

function GroupCalendar.Network:KillOldUpdates(pUpdates, pTime)
	for vSender, vUpdate in pairs(pUpdates) do
		if pTime >= vUpdate.mLastMessageTime + self.Delay.DeadUpdateTimeout then
			-- The update seems to have died, 
			
			if GroupCalendar.Debug.Updates then
				GroupCalendar:DebugMessage("KillOldUpdates: Killing dead update from %s", vSender)
			end
			
			pUpdates[vSender] = GroupCalendar.DeleteTable(pUpdates[vSender])
			
			-- Request another update
			
			self.ResponseQueue:QueueRFU(vUpdate.mUserName, vUpdate.mDatabaseTag)
		end
	end
end

----------------------------------------
-- 
----------------------------------------

function GroupCalendar.Network:CancelAllTasks()
	MCSchedulerLib:UnscheduleTask(self.StartSynch, self)
	MCSchedulerLib:UnscheduleTask(self.SynchComplete, self)
end

function GroupCalendar.Network:ProcessChangesRFU(pChanges, pDatabaseTag, pPlayerOwned, pHighPriority, pUserName, pDatabaseID, pRevision, pAuthRevision)
	-- Cancel a queued RFU for the same database if it's inferior
	
	self.ResponseQueue:CancelInferiorRFU(GroupCalendar.PlayerName, pUserName, pDatabaseTag, pDatabaseID, pRevision)
	
	-- Just bail out if we don't have the requested database
	
	if not pChanges then
		return
	end
	
	-- Create the request
	
	local vFromRevision
	local vForceUpdate = false
	
	if pChanges.ID ~= pDatabaseID then
		if pPlayerOwned
		or pChanges.ID > pDatabaseID then
			if GroupCalendar.Debug.Updates then
				GroupCalendar:DebugMessage("ProcessChangesRFU: Forcing update from 0 since their id is out of date")
			end
			
			vFromRevision = 0
			vForceUpdate = true
		else
			-- Requested database isn't available
			return
		end
	else
		if pPlayerOwned
		and pAuthRevision
		and pAuthRevision < pRevision then
			vFromRevision = pAuthRevision
		else
			vFromRevision = pRevision
		end
		
		if vFromRevision == pChanges.Revision then
			-- Update is already current
			return
		end
	end
	
	if GroupCalendar.Debug.Updates then
		GroupCalendar:DebugMessage("ProcessChangesRFU: Queuing update from revision %d", vFromRevision)
	end
	
	GroupCalendar.Network:QueueUPDResponse(pChanges, pDatabaseTag, pPlayerOwned, pUserName, pDatabaseID, vFromRevision, pHighPriority, vForceUpdate)
end

function GroupCalendar.Network:QueueUPDResponse(pChanges, pDatabaseTag, pPlayerOwned, pUserName, pDatabaseID, pFromRevision, pHighPriority, pForceUpdate)
	local vIndex, vResponse = self.ResponseQueue:FindResponse(self._UPD, pUserName, pDatabaseTag)
	
	-- If there's an existing response and it hasn't started transmission then
	-- just modify it if necessary
	
	if vResponse and not vResponse.ResponseStarted then
		if pDatabaseID ~= vResponse.DatabaseID then
			if pDatabaseID < vResponse.DatabaseID then
				vResponse.DatabaseID = pDatabaseID
			end
			
			vResponse.FromRevision = 0
		
		elseif pFromRevision < vResponse.FromRevision then
			if GroupCalendar.Debug.Updates then
				GroupCalendar:DebugMessage("Changing existing request for %s %s to revision %d", pUserName, pDatabaseTag, pFromRevision)
			end
			
			vResponse.FromRevision = pFromRevision
		end
		
		if pHighPriority then
			vResponse.HighPriority = true
			GroupCalendar.Network.ResponseQueue:SetResponseDelay(vResponse, self.Delay.UPD_Priority)
		end
		
		return
	end
	
	-- Can't send an UPD if we don't have the revisions requested
	
	if not pForceUpdate and pFromRevision >= pChanges.Revision then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("Can't send update for %s %s: Revisions from %d not available", pUserName, pDatabaseTag, pFromRevision)
		end
		
		return
	end
	
	-- Determine a delay
	
	local vDelay
	
	if pPlayerOwned then
		vDelay = self.Delay.UPD_Owned
	elseif pHighPriority then
		vDelay = self.Delay.UPD_Priority
	else
		vDelay = self.Delay.UPD_Proxy
	end
	
	vResponse = self.ResponseQueue:QueueResponse(self._UPD, vDelay, pUserName, pDatabaseTag, pChanges.ID, pFromRevision, pHighPriority)
end

-- Returns true if the first ID pair is newer than the second

function GroupCalendar.Network:DatabaseIsNewer(pDatabaseID1, pRevision1, pDatabaseID2, pRevision2)
	if pDatabaseID1 > pDatabaseID2 then
		return true
	elseif pDatabaseID1 < pDatabaseID2 then
		return false
	else
		return pRevision1 > pRevision2
	end
end

function GroupCalendar.Network:UpdateIsBetterThanOurs(pSender, pUserName, pDatabaseID, pRevision, pDatabase, pChanges)
	-- Updates for our own databases are always worse if
	-- we're on the toon
	
	if pDatabase.IsPlayerOwned and pUserName == GroupCalendar.PlayerName then
		return false
	end
	
	-- Updates from the owner are always better than ours
	-- as are updates when our list is empty
	
	if string.lower(pSender) == string.lower(pUserName)
	or not pChanges then
		return true
	end
	
	-- If the revision is higher than what we have it's better
	
	return self:DatabaseIsNewer(pDatabaseID, pRevision, pChanges.ID, pChanges.Revision)
end

function GroupCalendar.Network:DeleteDatabase(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision)
	-- Get the database
	
	local vDatabase, vLocalUser, vChanges, vIsPlayerOwned = GroupCalendar.Database.GetDatabaseChangesByName(pUserName, pDatabaseTag, false)
	
	-- Nothing to do if we don't even have the database or changes
	
	if not vDatabase or not vChanges then
		return
	end
	
	-- Bail out if our stuff is better
	
	if not self:UpdateIsBetterThanOurs(pSender, pUserName, pDatabaseID, pRevision, vDatabase, vChanges) then
		return
	end
	
	-- Empty the changelist and force the revision
	
	GroupCalendar.Database.PurgeDatabase(vDatabase, pDatabaseTag, pDatabaseID, pRevision)
end

function GroupCalendar.Network:BeginUpdate(pSender, pUserName, pDatabaseTag, pDatabaseID, pRevision, pSinceRevision)
	local vIsOwnerUpdate = string.lower(pSender) == string.lower(pUserName)
	
	-- If the same sender has a pending update already in progress, kill it
	
	self:KillSendersUpdates(pSender, pUserName)
	
	-- Ignore the update if it's for a database we're not supposed to be seeing
	
	local vDatabase = GroupCalendar.Database.GetDatabase(pUserName)
	
	if vDatabase and not GroupCalendar.Database.DatabaseIsVisible(vDatabase) then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("Ignoring update for %s from %s because the database is hidden from this character", pUserName, pSender)
		end
		
		return
	end
	
	--
	
	local vChanges = GroupCalendar.Database.GetDatabaseChanges(vDatabase, pDatabaseTag)
	local vChangesRevision = 0
	
	if vChanges then
		if vIsOwnerUpdate then
			vChangesRevision = vChanges.AuthRevision
		else
			vChangesRevision = vChanges.Revision
		end
	end
	
	-- Determine whether the update is interesting to us
	
	if self:ShouldIgnoreUpdate(vIsOwnerUpdate, pDatabaseID, pRevision, pSinceRevision, vChanges) then
		return
	end
	
	-- See if there's another update for the same database already in progress
	
	local vUpdate = self:FindUpdate(nil, pUserName, pDatabaseTag, nil)
	
	if vUpdate then
		if not self:ShouldCancelUpdate(vIsOwnerUpdate, vUpdate, pDatabaseID, pRevision) then
			return
		end
		
		self:CancelUpdate(pDatabaseTag, nil, pUserName, nil)
	end
	
	-- Determine if the database should be tossed out and re-fetched
	
	if self:ShouldPurgeDatabase(pIsOwnerUpdate, pDatabaseID, pRevision, vChanges) then
		GroupCalendar.Database.PurgeDatabase(vDatabase, pDatabaseTag, pDatabaseID)
		vChangesRevision = 0
	end
	
	-- If the incoming revision doesn't overlap or append what we've got
	-- then ignore it and request one which does
	
	if pSinceRevision > vChangesRevision then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("BeginUpdate: Requesting an earlier starting revision")
		end
		
		self.ResponseQueue:QueueRFU(pUserName, pDatabaseTag, pDatabaseID, vChangesRevision)
		return
	end
	
	if GroupCalendar.Debug.Updates then
		GroupCalendar:DebugMessage("Network:BeginUpdate: %s, %d since revision %d from %s", pUserName, pRevision, pSinceRevision, pSender)
	end

	-- Create the database update record
	
	vUpdate = GroupCalendar.NewTable()
	
	vUpdate.mSender = pSender
	vUpdate.mUserName = pUserName
	vUpdate.mDatabaseID = pDatabaseID
	vUpdate.mRevision = pRevision
	vUpdate.mSinceRevision = pSinceRevision
	vUpdate.mChanges = GroupCalendar.NewTable()
	vUpdate.mLastMessageTime = GetTime()
	vUpdate.mDatabaseTag = pDatabaseTag
	vUpdate.mMD5 = GroupCalendar.NewObject(GroupCalendar._MD5)
	vUpdate.mMD5:BeginDigest()
	
	self.IncomingUpdates[pSender] = vUpdate
end

function GroupCalendar.Network:ProcessDatabaseUpdate(pDatabaseUpdate, pForceReconstruct)
	local vIsOwnerUpdate = pDatabaseUpdate.mSender == pDatabaseUpdate.mUserName
	local vDatabase = GroupCalendar.Database.GetDatabase(pDatabaseUpdate.mUserName, true)
	local vDatabaseChanges = vDatabase.Changes
	local vReconstructDatabase = pForceReconstruct
	
	if GroupCalendar.Debug.Updates then
		GroupCalendar:DebugMessage("Processing database update")
	end
	
	if not vDatabaseChanges
	or vDatabaseChanges.ID ~= pDatabaseUpdate.mDatabaseID then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("    ID changing")
		end
		
		vDatabase.Changes = CalendarChanges_Erase(vDatabase.Changes, pDatabaseUpdate.mDatabaseID)
		vDatabaseChanges = vDatabase.Changes
		vReconstructDatabase = true
	else
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("    Keeping existing change list")
		end
	end
	
	for vRevision = pDatabaseUpdate.mSinceRevision + 1, pDatabaseUpdate.mRevision do
		local vChanges = pDatabaseUpdate.mChanges[vRevision]
		
		-- If the revision is newer than what we have, insert the new data
		
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("    Processing revision %d", vRevision)
		end
		
		if not vDatabaseChanges or vRevision > vDatabaseChanges.Revision then
			if GroupCalendar.Debug.Updates then
				GroupCalendar:DebugMessage("        New revision")
			end
			
			CalendarChanges_SetChangeList(vDatabaseChanges, vRevision, vChanges)
			
			if not vReconstructDatabase and vChanges then
				GroupCalendar.Database.ExecuteChangeList(vDatabase, vChanges, true)
			end
		
		-- If the revision overlaps what we have and the update is from
		-- the owner, then compare the data to make sure it's intact.  If
		-- it doesn't match then update the changes and flag the database
		-- for reconstruction
		
		elseif vIsOwnerUpdate then
			-- If we're not reconstructing then compare the owner's changes to what
			-- we've gotten before and see if they match.  Switch to reconstruction
			-- mode if there's a discrepancy
			
			if not vReconstructDatabase then
				if GroupCalendar.Debug.Updates then
					GroupCalendar:DebugMessage("        Owner update (not reconstructing)")
				end
				
				local vChangeList = CalendarChanges_GetChangeList(vDatabaseChanges, vRevision)
				
				if ((vChanges ~= nil) ~= (vChangeList ~= nil))
				or (vChangeList ~= nil and table.getn(vChangeList) ~= table.getn(vChanges)) then
					vReconstructDatabase = true
					
					if GroupCalendar.Debug.Updates then
						GroupCalendar:DebugMessage("Reconstructing "..vDatabase.UserName.." because changes for revision "..vRevision.." are different lengths")
					end
				elseif vChanges ~= nil then
					for vChangeIndex, vChange in ipairs(vChanges) do
						local vOldChange = vChangeList[vChangeIndex]
						
						if vOldChange ~= vChange then
							vReconstructDatabase = true
							
							if GroupCalendar.Debug.Updates then
								GroupCalendar:DebugMessage("Reconstructing "..vDatabase.UserName.." because change "..vChangeIndex.." for revision "..vRevision.." doesn't match")
								GroupCalendar:DebugMessage("Previously: "..vOldChange)
								GroupCalendar:DebugMessage("Now: "..vChange)
							end
							break
						end
					end
				end
			end
			
			-- Just copy the changes over if we're in re-construction mode
			
			if vReconstructDatabase then
				CalendarChanges_SetChangeList(vDatabaseChanges, vRevision, vChanges)
			end
		end
	end
	
	-- Make sure the current revision stamp matches the update
	
	vDatabaseChanges.Revision = pDatabaseUpdate.mRevision
	
	-- Update AuthRevision if the update came from the owner
	
	if vIsOwnerUpdate
	and pDatabaseUpdate.mSinceRevision <= vDatabaseChanges.AuthRevision then
		vDatabaseChanges.AuthRevision = pDatabaseUpdate.mRevision
	end
	
	if vReconstructDatabase then
		GroupCalendar.Database.ReconstructDatabase(vDatabase)
	else
		GroupCalendar_MajorDatabaseChange(vDatabase)
	end
end

function GroupCalendar.Network:ProcessRSVPUpdate(pRSVPUpdate, pForceReconstruct)
	if GroupCalendar.Debug.Updates then
		GroupCalendar:DebugMessage("Network:ProcessRSVPUpdate")
		GroupCalendar:DebugTable("    RSVPUpdate", pRSVPUpdate, 1)
	end
	
	local vIsOwnerUpdate = pRSVPUpdate.mSender == pRSVPUpdate.mUserName
	local vDatabase = GroupCalendar.Database.GetDatabase(pRSVPUpdate.mUserName, true)
	local vRSVPChanges = vDatabase.RSVPs
	
	if not vRSVPChanges
	or vRSVPChanges.ID ~= pRSVPUpdate.mDatabaseID then
		vDatabase.RSVPs = CalendarChanges_New(pRSVPUpdate.mDatabaseID)
		vRSVPChanges = vDatabase.RSVPs
	end

	for vRevision = pRSVPUpdate.mSinceRevision + 1, pRSVPUpdate.mRevision do
		local vChanges = pRSVPUpdate.mChanges[vRevision]

		-- If the revision is newer than what we have, insert the new data

		if vRevision > vRSVPChanges.Revision then
			CalendarChanges_SetChangeList(vRSVPChanges, vRevision, vChanges)
			CalendarChanges_Close(vRSVPChanges, vRevision)
		
			if vChanges then
				GroupCalendar.Database.ExecuteRSVPChangeList(vDatabase, vChanges, true)
			end
		elseif vIsOwnerUpdate and vRevision > vRSVPChanges.AuthRevision then
			if GroupCalendar.Debug.Updates then
				GroupCalendar:DebugMessage("ProcessRSVPUpdate: Ignoring owner update for "..vRevision..": Not implemented")
			end
		else
			if GroupCalendar.Debug.Updates then
				GroupCalendar:DebugMessage("ProcessRSVPUpdate: Ignoring revision "..vRevision..": Already exists")
			end
		end
	end

	vRSVPChanges.Revision = pRSVPUpdate.mRevision
	
	-- Update AuthRevision if the update came from the owner

	if vIsOwnerUpdate
	and pRSVPUpdate.mSinceRevision <= vRSVPChanges.AuthRevision then
		vRSVPChanges.AuthRevision = pRSVPUpdate.mRevision
	end
	
	if GroupCalendar.Debug.Updates then
		GroupCalendar:DebugMark()
	end
end

function GroupCalendar.Network:Reset()
	-- Disconnect
	
	self.Channel:CloseChannel()
	
	-- Reset self updates
	
	self:ResetSelfUpdates()
	
	self.EnableUpdates = false
	self.EnableSelfUpdates = false
	
	self:FlushCaches()
end

function GroupCalendar.Network:ResetQueues()
	GroupCalendar.EraseTable(self.IncomingUpdates)
	self.ResponseQueue:ResetQueue()
end

function GroupCalendar.Network:CancelUpdate(pSender, pUserName, pDatabaseTag, pDatabaseID)
	self:FindUpdate(pSender, pUserName, pDatabaseTag, pDatabaseID, true)
end

function GroupCalendar.Network:KillSendersUpdates(pSender, pDontRequestForUserName)
	local vUpdate = self:FindUpdate(pSender, nil, nil, nil, true)
	
	if not vUpdate or vUpdate.mUserName == pDontRequestForUserName then
		return
	end
	
	-- Ask for another copy
	
	self.ResponseQueue:QueueRFU(vUpdate.mUserName, vUpdate.mDatabaseTag)
end

function GroupCalendar.Network:ShouldIgnoreUpdate(pIsOwnerUpdate, pTheirDatabaseID, pTheirRevision, pTheirSinceRevision, pChanges)
	if pChanges == nil then
		return false
	end
	
	-- If the update is from the owner, only ignore it if the
	-- ID and revision both match
	
	if pIsOwnerUpdate then
		return pTheirDatabaseID == pChanges.ID and pTheirRevision == pChanges.AuthRevision
	end
	
	-- If the update is from a proxy, ignore it if their ID
	-- is older, or if their ID is the same but their revision
	-- is the same or older
	
	if pTheirDatabaseID < pChanges.ID then
		return true -- Ignore it, ours is newer
	elseif pTheirDatabaseID > pChanges.ID then
		return false -- Receive it, ours is older
	elseif pTheirRevision <= pChanges.Revision then
		return true -- Ignore it, ours is newer
	else
		return pTheirSinceRevision > pChanges.Revision -- Ignore it if it doesn't overlap our own
	end
end

function GroupCalendar.Network:ShouldCancelUpdate(pIsOwnerUpdate, pUpdate, pDatabaseID, pRevision)
	-- If the new update is from the owner or
	-- the old one isn't from the owner and is a higher revision,
	-- then cancel the old update
	
	if pIsOwnerUpdate
	or (pUpdate.mSender ~= pUpdate.mUserName
	  and self:DatabaseIsNewer(pUpdate.mDatabaseID, pUpdate.mRevision, pDatabaseID, pRevision)) then
		return true
	
	-- Otherwise cancel this one
	
	else
		return false
	end
end

function GroupCalendar.Network:ShouldPurgeDatabase(pIsOwnerUpdate, pDatabaseID, pRevision, pChanges)
	return pIsOwnerUpdate
	   and pChanges ~= nil
	   and (pDatabaseID ~= pChanges.ID or pRevision < pChanges.AuthRevision)
end

function GroupCalendar.Network:FindUpdate(pSender, pUserName, pDatabaseTag, pDatabaseID, pDelete)
	local vUpdate
	
	if pSender then
		vUpdate = self.IncomingUpdates[pSender]
		
		if not vUpdate then
			return
		end
		
		if (pUserName and vUpdate.mUserName ~= pUserName)
		or (pDatabaseTag and vUpdate.mDatabaseTag ~= pDatabaseTag)
		or (pDatabaseID and vUpdate.mDatabaseID ~= pDatabaseID) then
			return
		end
		
		if pDelete then
			if GroupCalendar.Debug.Updates then
				GroupCalendar:DebugMessage("FindUpdate: Killed update for %s from %s", vUpdate.mUserName, vUpdate.mSender)
			end
			
			self.IncomingUpdates[pSender] = nil
		end
		
		return vUpdate
	end
	
	-- Sender isn't specified, so search through all open updates for a match
	
	for vSender, vUpdate in pairs(self.IncomingUpdates) do
		if (pUserName == nil or vUpdate.mUserName == pUserName)
		and (pDatabaseID == nil or vUpdate.mDatabaseID == pDatabaseID)
		and (pDatabaseTag == nil or vUpdate.mDatabaseTag == pDatabaseTag) then
			if pDelete then
				if GroupCalendar.Debug.Updates then
					GroupCalendar:DebugMessage("Killed update for %s from %s", vUpdate.mUserName, vUpdate.mSender)
				end
				
				self.IncomingUpdates[vSender] = nil
			end
			
			return vUpdate
		end
	end
end

function GroupCalendar.Network:GetGuildMemberIndex(pPlayerName)
	local vUpperUserName = strupper(pPlayerName)
	local vNumGuildMembers = GetNumGuildMembers(true)
	
	for vIndex = 1, vNumGuildMembers do
		local vName = GetGuildRosterInfo(vIndex)
		
		if strupper(vName) == vUpperUserName then
			return vIndex
		end
	end
	
	return nil
end

----------------------------------------
-- Self updates
----------------------------------------

StaticPopupDialogs.CONFIRM_CALENDAR_SELF_UPDATE =
{
	text = TEXT(GroupCalendar_cConfirmSelfUpdateMsg),
	button1 = TEXT(GroupCalendar_cUpdate),
	button2 = TEXT(CalendarEventEditor_cDelete),
	OnAccept = function() GroupCalendar.Network:ProcessSelfUpdate() end,
	OnCancel = function() GroupCalendar.Network:RejectSelfUpdate() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 0,
	showAlert = 1,
}

StaticPopupDialogs.CONFIRM_CALENDAR_SELF_RSVP_UPDATE =
{
	text = TEXT(GroupCalendar_cConfirmSelfUpdateMsg),
	button1 = TEXT(GroupCalendar_cUpdate),
	button2 = TEXT(CalendarEventEditor_cDelete),
	OnAccept = function() GroupCalendar.Network:ProcessSelfRSVPUpdate() end,
	OnCancel = function() GroupCalendar.Network:RejectSelfRSVPUpdate() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 0,
	showAlert = 1,
}

GroupCalendar.Network.SelfUpdate =
{
	AskingUserName = nil,
	AskingType = nil,
	
	DidAsk = {},
	DidApprove = {},
	
	Updates =
	{
		DB = {},
		RAT = {},
	},
}

function GroupCalendar.Network:ResetSelfUpdates()
	if GroupCalendar.Debug.Roaming then
		GroupCalendar:DebugMessage(GREEN_FONT_COLOR_CODE.."ResetSelfUpdates")
	end
	
	self.SelfUpdate.AskingUserName = nil
	self.SelfUpdate.AskingType = nil
	
	GroupCalendar.EraseTable(self.DidAsk)
	GroupCalendar.EraseTable(self.DidApprove)
	GroupCalendar.EraseTable(self.Updates.DB)
	GroupCalendar.EraseTable(self.Updates.RAT)
end

function GroupCalendar.Network:CanSendSelfUpdates()
	return not self.SafeMode
	   and self.EnableSelfUpdates
	   and not self.SelfUpdate.AskingUserName
end

function GroupCalendar.Network:AskNextSelfUpdate()
	-- Nothing to do if we're already asking
	
	if self.SelfUpdate.AskingUserName then
		if GroupCalendar.Debug.Roaming then
			GroupCalendar:DebugMessage(GREEN_FONT_COLOR_CODE.."AskNextSelfUpdate: Already asking")
		end
		
		return
	end
	
	if GroupCalendar.Debug.Roaming then
		GroupCalendar:DebugMessage("AskNextSelfUpdate: Finding next request")
	end
	
	-- Find the next request
	
	for vUserName, vUpdate in pairs(self.SelfUpdate.Updates.DB) do
		-- Only ask once
		
		if self.SelfUpdate.DidAsk[vUserName] then
			if self.SelfUpdate.DidApprove[vUserName] then
				self:ProcessDatabaseUpdate(vUpdate, true)
			end
			self:CurrentSelfUpdateComplete()
		else
			self.SelfUpdate.AskingUserName = vUserName
			self.SelfUpdate.AskingType = "DB"
			
			if GroupCalendar.Debug.Roaming then
				GroupCalendar:DebugMessage("AskNextSelfUpdate: Found database update")
			end
			
			self.SelfUpdate.DidAsk[vUserName] = true
			
			StaticPopup_Show("CONFIRM_CALENDAR_SELF_UPDATE", GroupCalendar.FormatNamed(GroupCalendar_cConfirmSelfUpdateParamFormat, vUpdate))
		end
		
		return
	end
	
	for vUserName, vUpdate in pairs(self.SelfUpdate.Updates.RAT) do
		-- Only ask once
		
		if self.SelfUpdate.DidAsk[vUserName] then
			if self.SelfUpdate.DidApprove[vUserName] then
				self:ProcessRSVPUpdate(vUpdate, true)
			end
			self:CurrentSelfUpdateComplete()
		else
			self.SelfUpdate.AskingUserName = vUserName
			self.SelfUpdate.AskingType = "RAT"
			
			if GroupCalendar.Debug.Roaming then
				GroupCalendar:DebugMessage("AskNextSelfUpdate: Found attendance update")
			end
			
			self.SelfUpdate.DidAsk[vUserName] = true
			
			StaticPopup_Show("CONFIRM_CALENDAR_SELF_RSVP_UPDATE", GroupCalendar.FormatNamed(GroupCalendar_cConfirmSelfRSVPUpdateParamFormat, vUpdate))
		end
		
		return
	end
	
	-- No more self updates waiting

	if GroupCalendar.Debug.Roaming then
		GroupCalendar:DebugMessage("AskNextSelfUpdate: No more updates waiting")
	end
end

function GroupCalendar.Network:CurrentSelfUpdateComplete()
	if GroupCalendar.Debug.Roaming then
		GroupCalendar:DebugMessage(GREEN_FONT_COLOR_CODE.."CurrentSelfUpdateComplete")
	end
	
	if not self.SelfUpdate.AskingUserName then
		return
	end
	
	if self.SelfUpdate.AskingType == "DB" then
		self.SelfUpdate.Updates.DB[self.SelfUpdate.AskingUserName] = nil
	elseif self.SelfUpdate.AskingType == "RAT" then
		self.SelfUpdate.Updates.RAT[self.SelfUpdate.AskingUserName] = nil
	else
		GroupCalendar:ErrorMessage("Network:CurrentSelfUpdateComplete: Unknown type "..self.SelfUpdate.AskingType)
	end
	
	self.SelfUpdate.AskingUserName = nil
	self.SelfUpdate.AskingType = nil
	
	self:AskNextSelfUpdate()
end

function GroupCalendar.Network:QueueSelfUpdate(pDatabaseTag, pUpdate)
	-- A more recent offer is probably better, so overwrite any existing pending update
	
	self.SelfUpdate.Updates[pDatabaseTag][pUpdate.mUserName] = pUpdate
	self:AskNextSelfUpdate()
end

function GroupCalendar.Network:ProcessSelfUpdate()
	-- Mark updates for this name as approved to avoid further prompting
	
	if not self.SelfUpdate.DidApprove[self.SelfUpdate.AskingUserName] then
		self.SelfUpdate.DidApprove[self.SelfUpdate.AskingUserName] = true
		GroupCalendar.Backup:BackupNow(self.SelfUpdate.AskingUserName)
	end
	
	self:ProcessDatabaseUpdate(self.SelfUpdate.Updates.DB[self.SelfUpdate.AskingUserName], true)
	self:CurrentSelfUpdateComplete()
end

function GroupCalendar.Network:RejectSelfUpdate()
	local vDatabase = GroupCalendar.Database.GetDatabase(self.SelfUpdate.AskingUserName, true)
	
	if not vDatabase then
		return
	end
	
	local vDatabaseUpdate = self.SelfUpdate.Updates.DB[self.SelfUpdate.AskingUserName]
	
	-- Save this ID if it's the highest one seen, that way we'll be sure to generate one higher
	-- than it
	
	if not vDatabase.HighestKnownDatabaseID or vDatabaseUpdate.mDatabaseID > vDatabase.HighestKnownDatabaseID then
		vDatabase.HighestKnownDatabaseID = vDatabaseUpdate.mDatabaseID
	end
	
	GroupCalendar.Database.RebuildDatabase(vDatabase)
	
	self:CurrentSelfUpdateComplete()
end

function GroupCalendar.Network:ProcessSelfRSVPUpdate()
	-- Mark updates for this name as approved to avoid further prompting
	
	if not self.SelfUpdate.DidApprove[self.SelfUpdate.AskingUserName] then
		self.SelfUpdate.DidApprove[self.SelfUpdate.AskingUserName] = true
		GroupCalendar.Backup:BackupNow(self.SelfUpdate.AskingUserName)
	end
	
	self:ProcessRSVPUpdate(self.SelfUpdate.Updates.RAT[self.SelfUpdate.AskingUserName], true)
	self:CurrentSelfUpdateComplete()
end

function GroupCalendar.Network:RejectSelfRSVPUpdate()
	local vDatabase = GroupCalendar.Database.GetDatabase(self.SelfUpdate.AskingUserName, true)
	
	if not vDatabase then
		return
	end
	
	local vUpdate = self.SelfUpdate.Updates.RAT[self.SelfUpdate.AskingUserName]
	
	-- Save this ID if it's the highest one seen, that way we'll be sure to generate one higher
	-- than it
	
	if not vDatabase.HighestKnownRSVPID or vUpdate.mDatabaseID > vDatabase.HighestKnownRSVPID then
		vDatabase.HighestKnownRSVPID = vUpdate.mDatabaseID
	end
	
	GroupCalendar.Database.RebuildRSVPs(vDatabase)
	
	self:CurrentSelfUpdateComplete()
end

