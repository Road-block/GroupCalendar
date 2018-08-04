GroupCalendar_cTitle = string.format(GroupCalendar_cTitle, GroupCalendar.VersionString)

GroupCalendar.cContributors = {"Dridzt", "AJ Henderson", "Aquaflare7", "Arrath", "ShadowsBane", "Ryhawk", "ObiChad", "Maqjav"}
GroupCalendar.cFriendsAndFamily = {"Brian", "Dave", "Glenn", "Leah", "Mark", "Gian", "Jerry", "The Mighty Pol", "Forge"}
GroupCalendar.cTranslators = {"AndyAska (CN, TW)", "Displace (TW)", "Palyr (DE)", "Dania (DE)", "OweH (DE)", "AvernaMan (DE)", "Macniel (DE)", "Kisanth (FR)", "Nico806 (FR)", "Ekhurr (FR)", "Marutak (ES)", "Marosth (ES)"}
GroupCalendar.cTesters = {"Dridzt", "<Frozen Clover>", "Lothsahn", "bhartsfield", "Renegade777", "dj-jason", "Livak", "RavenPrime", "Eilaurowen", "CurtisTheGreat", "Amethy"}

GroupCalendar_cAuthor = string.format(GroupCalendar.cAuthor, GroupCalendar:FormatItemList(GroupCalendar.cContributors))
GroupCalendar_cTestersNames = GroupCalendar:FormatItemList(GroupCalendar.cTesters)
GroupCalendar_cSpecialThanksNames = GroupCalendar:FormatItemList(GroupCalendar.cFriendsAndFamily)
GroupCalendar_cTranslationCredit = string.format(GroupCalendar.cTranslationCredit, GroupCalendar:FormatItemList(GroupCalendar.cTranslators))

GroupCalendar_cBackupTitle = GroupCalendar.cBackupTitle
GroupCalendar_cNoBackups = GroupCalendar.cNoBackups
GroupCalendar_cBackupNow = GroupCalendar.cBackupNow
GroupCalendar_cRestoreBackup = GroupCalendar.cRestoreBackup

GroupCalendar_cMaxFieldLength = 200

local GroupCalendar_cSettingsFormat = 3
local GroupCalendar_cObfuscatedPassword = "******"

GroupCalendar_cItemLinkFormat = "|(%x+)|Hitem:(-?%d+):(-?%d+):(-?%d+):(-?%d+)|h%[([^%]]+)%]|h|r"

gGroupCalendar_Settings =
{
	Format = GroupCalendar_cSettingsFormat,
	Debug = false,
	ShowEventsInLocalTime = false,
	PlayerSettings = {},
	RealmSettings = {},
	DebugSettings = {},
	TwentyFourHourTime = GroupCalendar_cDefaultTimeFormat == 24,
	StartOnMonday = GroupCalendar_cDefaultStartDay == "Mon",
}

GroupCalendar.Debug = {}
GroupCalendar.Debug.Errors = false -- Internal error notifications (best to always leave this on)
GroupCalendar.Debug.Init = false -- Events related to first-time initialization
GroupCalendar.Debug.Channel = false -- Events related to channel management
GroupCalendar.Debug.ChannelRTS = false -- ReadyToSend events
GroupCalendar.Debug.Synch = false -- Events related to the synch phase
GroupCalendar.Debug.Trust = false -- Trust checking and caching
GroupCalendar.Debug.Updates = false -- Incoming update requests and responses
GroupCalendar.Debug.Changes = false -- Change list generation and processing
GroupCalendar.Debug.AutoConfirm = false -- Automatic confirmation
GroupCalendar.Debug.AutoConfig = false -- Automatic configuration
GroupCalendar.Debug.ResponseQueue = false -- ResponseQueue
GroupCalendar.Debug.ClockCheck = false -- Clock verification
GroupCalendar.Debug.Reconstruct = false -- Forced rebuilds (owner updates correcting proxied updates)
GroupCalendar.Debug.Roaming = false -- Updates to owned databases during the synch period
GroupCalendar.Debug.LocalUsers = false -- Database visibility within a channel

GroupCalendar.PlayerSettings = nil
GroupCalendar.RealmSettings = nil

GroupCalendar.PlayerName = nil
GroupCalendar.PlayerGuild = nil
GroupCalendar.PlayerLevel = nil
GroupCalendar.PlayerFactionGroup = nil
GroupCalendar.PlayerGuildRank = nil
GroupCalendar.RealmName = GetRealmName()
GroupCalendar.NewEvents = {}

GroupCalendar.ActiveDialog = nil

-- Panel Setup --

GroupCalendar.PANEL_NULL = 0
GroupCalendar.PANEL_CALENDAR = 1
GroupCalendar.PANEL_SETUP = 2
GroupCalendar.PANEL_BACKUP = 3
GroupCalendar.PANEL_ABOUT = 4

GroupCalendar.PanelFrames =
{
	"GroupCalendarCalendarFrame",
	"GroupCalendarSetupFrame",
	"GroupCalendarBackupFrame",
	"GroupCalendarAboutFrame",
}

GroupCalendar.CurrentPanel = GroupCalendar.PANEL_CALENDAR

StaticPopupDialogs.GROUPCALENDAR_CANT_RELOADUI =
{
	text = TEXT(GroupCalendar.cCantReloadUI),
	button1 = TEXT(OKAY),
	OnAccept = function() end,
	OnCancel = function() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
}

-- Panel Details End --

function GroupCalendar:OnLoad()
	-- Makes sure they're not upgrading with a reloadui when there are new files
	
	if not GroupCalendar._Whisper
	or not GroupCalendar._Backup then
		GroupCalendar:ErrorMessage(GroupCalendar.cCantReloadUI)
		StaticPopup_Show("GROUPCALENDAR_CANT_RELOADUI")
		
		SlashCmdList.CALENDAR = function (...) GroupCalendar:ErrorMessage(GroupCalendar.cCantReloadUI) end
		SLASH_CALENDAR1 = "/calendar"
		
		SlashCmdList.CAL = SlashCmdList.CALENDAR
		SLASH_CAL1 = "/cal"
		
		return
	end
	
	self.Loaded = true
	
	self.Backup = self.NewObject(self._Backup)
	self.BackupUI = self:ConstructFrame(GroupCalendarBackupFrame, self._BackupUI)

	--
	
	if false then
		MCSchedulerLib:ScheduleRepeatingTask(3, GroupCalendar_UpdateAddonUsage, nil, nil, "GroupCalendar_UpdateAddonUsage")
	end
	
	self.PlayerName = UnitName("player")
	self.PlayerLevel = UnitLevel("player")
	
	tinsert(UISpecialFrames, "GroupCalendarFrame")
	UIPanelWindows.GroupCalendarFrame = {area = "left", pushable = 5, whileDead = 1}
	
	-- Register events
	
	MCEventLib:RegisterEvent("VARIABLES_LOADED", self.VariablesLoaded, self)
	MCEventLib:RegisterEvent("PLAYER_ENTERING_WORLD", self.PlayerEnteringWorld, self)
	
	-- For updating auto-config settings and guild trust
	-- values
	
	MCEventLib:RegisterEvent("GUILD_ROSTER_UPDATE", GroupCalendar_GuildRosterUpdate)
	MCEventLib:RegisterEvent("PLAYER_GUILD_UPDATE", GroupCalendar_PlayerGuildUpdate)
	
	-- For updating the enabled events when the players
	-- level changes
	
	MCEventLib:RegisterEvent("PLAYER_LEVEL_UP", GroupCalendar_PlayerLevelUp)
	
	-- For monitoring the status of the chat channel
	
	MCEventLib:RegisterEvent("CHAT_MSG_WHISPER", GroupCalendar_ChatMsgWhisper)
	MCEventLib:RegisterEvent("GC_CHANNEL_UPDATE", GroupCalendar_ChannelChanged)
	
	-- For suspending/resuming the chat channel during logout
	
	-- MCEventLib:RegisterEvent("PLAYER_CAMPING", self.Network.SuspendChannel, self.Network)
	-- MCEventLib:RegisterEvent("PLAYER_QUITING", self.Network.SuspendChannel, self.Network)
	-- MCEventLib:RegisterEvent("LOGOUT_CANCEL", self.Network.ResumeChannel, self.Network)
	
	-- For monitoring tradeskill cooldowns
	
	MCEventLib:RegisterEvent("TRADE_SKILL_UPDATE", self.Database.UpdateCurrentTradeskillCooldown)
	MCEventLib:RegisterEvent("TRADE_SKILL_SHOW", self.Database.UpdateCurrentTradeskillCooldown)
	
	MCEventLib:RegisterEvent("CRAFT_UPDATE", self.Database.UpdateCurrentCraftCooldown)
	MCEventLib:RegisterEvent("CRAFT_SHOW", self.Database.UpdateCurrentCraftCooldown)
	
	MCEventLib:RegisterEvent("BAG_UPDATE_COOLDOWN", self.Cooldowns_ScheduleCheckItems)
	MCEventLib:RegisterEvent("BAG_UPDATE", self.Cooldowns_ScheduleCheckItems)
	MCEventLib:RegisterEvent("UPDATE_INSTANCE_INFO", self.Database.ScheduleSavedInstanceEvents)
	
	-- For managing group invites
	
	MCEventLib:RegisterEvent("PARTY_MEMBERS_CHANGED", self.Invites.PartyMembersChanged, self.Invites)
	MCEventLib:RegisterEvent("RAID_ROSTER_UPDATE", self.Invites.PartyMembersChanged, self.Invites)
	MCEventLib:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", self.Invites.PartyLootMethodChanged, self.Invites)
	
	--
	
	MCEventLib:RegisterEvent("SERVER_TIME_OFFSET_CHANGED", self.TimeZoneChanged, self)
	
	-- For dragging the window
	
	this:RegisterForDrag("LeftButton")
	
	-- Tabs
	
	PanelTemplates_SetNumTabs(this, table.getn(self.PanelFrames))
	GroupCalendarFrame.selectedTab = self.CurrentPanel
	PanelTemplates_UpdateTabs(this)
	
	-- Initialize the minimap clock
	
	GroupCalendarButton:SetFrameLevel(GroupCalendarButton:GetFrameLevel() + 3)
	GroupCalendarButtonHighlight:SetVertexColor(0.1, 0.35, 0.75)
	
	GroupCalendar.InitializeFrame(GroupCalendarButton, GroupCalendar._Clock)
	GroupCalendarButton:Construct()
	
	GroupCalendarTODFrame:Show()
	
	-- Install the slash commands
	
	SlashCmdList.CALENDAR = function (...) GroupCalendar:ExecuteCommand(unpack(arg)) end
	SLASH_CALENDAR1 = "/calendar"
	
	SlashCmdList.CAL = SlashCmdList.CALENDAR
	SLASH_CAL1 = "/cal"
	
	-- Done initializing
	
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(GroupCalendar_cLoadMessage, 0.8, 0.8, 0.2)
	end
end

function GroupCalendar:SelfTest()
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		if vClassInfo.classID == nil
		or vClassInfo.femaleName == nil
		or vClassInfo.maleName == nil
		or vClassInfo.color == nil
		or vClassInfo.element == nil
		or vClassInfo.roles == nil
		or vClassInfo.talentRoles == nil
		or vClassInfo.defaultRole == nil then
			GroupCalendar:ErrorMessage("Self-test failed: Class info is missing data for class code %s", vClassCode)
		end
	end
end

function GroupCalendar:VariablesLoaded()
	GroupCalendar:SelfTest()
	
	self.MinimumEventDate = MCDateLib:GetLocalDate() - self.MaximumEventAge
	
	if gGroupCalendar_Settings.TwentyFourHourTime ~= nil then
		if gGroupCalendar_Settings.TwentyFourHourTime then
			TwentyFourHourTime = 1
		else
			TwentyFourHourTime = nil
		end
	end
	
	self.PlayerFactionGroup = UnitFactionGroup("player")
	
	self.Database.SetUserName(self.PlayerName)
	self.Database.PlayerLevelChanged(self.PlayerLevel)
	self.Network:CheckPlayerGuild()
	
	self.Database.Initialize()
	
	self.Network:CalendarLoaded()
	
	self.Calendar:SetStartWeekOnMonday(gGroupCalendar_Settings.StartOnMonday)
	
	if gGroupCalendar_Settings.DisableClock then
		GroupCalendarButton:HideDisplay()
	else
		GroupCalendarButton:ShowDisplay()
	end
	
	if gGroupCalendar_Settings.EnableAltMail then
		GroupCalendar:InstallAltMail()
	end
end

function GroupCalendar:OnShow()
	PlaySound("igCharacterInfoOpen")
	
	GroupCalendar.Calendar.StopFlashingReminder()
	
	local vYear, vMonth, vDay, vHour, vMinute = MCDateLib:GetLocalYMDHMS()
	local vMonthStartDate = self.ConvertMDYToDate(vMonth, 1, vYear)
	
	-- Update the guild roster
	
	if IsInGuild() and GetNumGuildMembers() == 0 then
		GuildRoster()
	end
	
	self.Calendar:SetDisplayDate(vMonthStartDate)
	self.SetActualDate(vMonthStartDate + vDay - 1)
	self:ShowPanel(self.PANEL_CALENDAR) -- Always switch  back to the Calendar view when showing the window
	
	GroupCalendarUseServerTime:SetChecked(not gGroupCalendar_Settings.ShowEventsInLocalTime)
	
	--
	
	local vLatestVersion = GroupCalendar_GetLatestVersionInfo()
	
	if vLatestVersion then
		GroupCalendarCalendarFrameNewerVersionMessage:SetText(string.format(GroupCalendar.cNewerVersionMessage, vLatestVersion:ToString()))
	else
		GroupCalendarCalendarFrameNewerVersionMessage:SetText("")
	end
end

function GroupCalendar:OnHide()
	PlaySound("igCharacterInfoClose")
	self.EventEditor:DoneEditing()
	self.EventViewer:DoneViewing()
	CalendarEditor_Close()
	GroupCalendarDatabasesList_Close()
	
	self.NewEvents = {}
end

function GroupCalendar:PlayerEnteringWorld(pEvent)
	GroupCalendar.PlayerLevel = UnitLevel("player")
	GroupCalendar.PlayerFactionGroup = UnitFactionGroup("player")
	GroupCalendar.PlayerSettings = GroupCalendar_GetPlayerSettings(GroupCalendar.PlayerName, GetRealmName())
	GroupCalendar.RealmSettings = GroupCalendar_GetRealmSettings(GetRealmName())
	GroupCalendar.Database.PlayerLevelChanged(GroupCalendar.PlayerLevel)
	
	if not GroupCalendar.PlayerSettings.SavedTemplates then
		GroupCalendar.UpgradeEventTemplates()
	end
	
	MCDateLib:CalculateTimeZoneOffset()
	
	MCSchedulerLib:ScheduleUniqueTask(10, GroupCalendar_MajorDatabaseChange, nil, "GroupCalendar_MajorDatabaseChange")
	MCSchedulerLib:ScheduleUniqueTask(30, GroupCalendar_CalculateReminders, nil, "GroupCalendar_CalculateReminders")
	
	-- TEMPORARY HACK: Attempt to update the faction data for friends
	
	MCSchedulerLib:ScheduleUniqueTask(15, GroupCalendar.Database.UpdateFriendListFaction, nil, "GroupCalendar.Database.UpdateFriendListFaction")
end

function GroupCalendar:TimeZoneChanged()
	if MCDateLib.ServerTimeZoneOffset == 0 then
		GroupCalendarUseServerTime:Hide()
	else
		GroupCalendarUseServerTime:Show()
	end
	
	MCEventLib:DispatchEvent("GC_CLOCKS_CHANGED")
end

function GroupCalendar_ChatMsgWhisper(pEvent)
	GroupCalendar.WhisperLog:AddWhisper(arg2, arg1)
end

function GroupCalendar_GuildRosterUpdate(pEvent)
	-- Ignore the update if we're not initialized yet

	if not GroupCalendar.Network.Initialized then
		return
	end

	GroupCalendar.Network:GuildRosterChanged()
	GroupCalendar.Invites:GuildRosterChanged()
end

function GroupCalendar_PlayerGuildUpdate(pEvent)
	GroupCalendar.Network:CheckPlayerGuild()

	-- Ignore the update if we're not initialized yet
	
	if not GroupCalendar.Network.Initialized then
		return
	end
	
	GroupCalendar_UpdateEnabledControls()
end

function GroupCalendar_PlayerLevelUp(pEvent)
	GroupCalendar.PlayerLevel = tonumber(arg1)
	GroupCalendar.Database.PlayerLevelChanged(GroupCalendar.PlayerLevel)
	GroupCalendar_MajorDatabaseChange(nil)
end

function GroupCalendar_UpdateEnabledControls()
	if GroupCalendarFrame.selectedTab == GroupCalendar.PANEL_CALENDAR then
		-- Update the calendar display
		
	elseif GroupCalendarFrame.selectedTab == GroupCalendar.PANEL_SETUP then
		local vAutoConfig, vGuildAdmin = GroupCalendar_GetUIConfigMode()
		local vAllowManualChanges = not vAutoConfig or vGuildAdmin
		
		GroupCalendar.SetCheckButtonEnable(GroupCalendarUseGuildChannel, vAllowManualChanges)
		
		if GroupCalendarUseGuildChannel:GetChecked() then
			GroupCalendar.SetDropDownEnable(GroupCalendarTrustMinRank, vAllowManualChanges)
			if not UIDropDownMenu_GetSelectedValue(GroupCalendarTrustMinRank) then
				CalendarDropDown_SetSelectedValue(GroupCalendarTrustMinRank, 1)
			end
		else
			GroupCalendar.SetDropDownEnable(GroupCalendarTrustMinRank, false)
		end
		
		GroupCalendar.SetCheckButtonEnable(GroupCalendarUseSharedChannel, vAllowManualChanges)
		
		GroupCalendar.SetEditBoxEnable(GroupCalendarChannelName, vAllowManualChanges and not GroupCalendarUseGuildChannel:GetChecked())
		GroupCalendar.SetEditBoxEnable(GroupCalendarChannelPassword, vAllowManualChanges and not GroupCalendarUseGuildChannel:GetChecked())
		
		GroupCalendar_UpdateChannelStatus()
	
	elseif GroupCalendarFrame.selectedTab == GroupCalendar.PANEL_BACKUP then
		-- Update the backup frame
	
	elseif GroupCalendarFrame.selectedTab == GroupCalendar.PANEL_ABOUT then
		-- Update the about frame
		
	end
end

function GroupCalendar_SetUseGuildChannel(pUseGuildChannel)
	GroupCalendarUseGuildChannel:SetChecked(pUseGuildChannel)
	GroupCalendarUseSharedChannel:SetChecked(not pUseGuildChannel)
	
	GroupCalendar_UpdateEnabledControls()
end

function GroupCalendar_ConfigModeChanged()
	GroupCalendar_UpdateEnabledControls()
end

function GroupCalendar_GetUIConfigMode()
	local vAdmin = UIDropDownMenu_GetSelectedValue(CalendarConfigModeMenu) == "CONFIG_ADMIN"
	local vAutoConfig = vAdmin or UIDropDownMenu_GetSelectedValue(CalendarConfigModeMenu) == "CONFIG_AUTO"
	
	return vAutoConfig, vAdmin
end

function GroupCalendar_GetUIChannelInfo()
	local vChannelName, vChannelPassword, vMinTrustedRank

	if GroupCalendarUseGuildChannel:GetChecked() then
		vChannelName = "#GUILD"
		vMinTrustedRank = UIDropDownMenu_GetSelectedValue(GroupCalendarTrustMinRank)
		
		if not vMinTrustedRank then
			vMinTrustedRank = 1
		end
	else
		vChannelName = GroupCalendarChannelName:GetText()
		
		if vChannelName == "" then
			vChannelName = nil
		end
		
		vChannelPassword = GroupCalendarChannelPassword:GetText()
		
		if vChannelPassword == "" then
			vChannelPassword = nil
		end
	end
	
	return vChannelName, vChannelPassword, vMinTrustedRank
end

function GroupCalendar_SavePanel(pIndex)
	if pIndex == GroupCalendar.PANEL_SETUP then
		local vAutoConfig, vGuildAdmin = GroupCalendar_GetUIConfigMode()
		local vOrigPassword = GroupCalendar.PlayerSettings.Channel.Password
		
		GroupCalendar.PlayerSettings.Channel.AutoConfig = vAutoConfig
		GroupCalendar.PlayerSettings.Channel.GuildAdmin = vGuildAdmin
		
		GroupCalendar.PlayerSettings.Channel.Name = nil
		GroupCalendar.PlayerSettings.Channel.Password = nil
		GroupCalendar.PlayerSettings.Channel.MinTrustedRank = nil
		
		if not vAutoConfig or vGuildAdmin then
			-- Manual config and guild admin modes fetch the settings
			
			local vChannelName, vChannelPassword, vMinTrustedRank = GroupCalendar_GetUIChannelInfo()
			
			if vGuildAdmin then
				GroupCalendar.Network:SetAutoConfigData(vChannelName, vChannelPassword, vMinTrustedRank)
			else
				GroupCalendar.PlayerSettings.Channel.Name = vChannelName
				GroupCalendar.PlayerSettings.Channel.Password = vChannelPassword
				GroupCalendar.PlayerSettings.Channel.MinTrustedRank = vMinTrustedRank
			end
			
			GroupCalendar.Network:SetChannel(vChannelName, vChannelPassword)
			GroupCalendar.Network:SetMinTrustedRank(vMinTrustedRank)
		else
			-- Auto-config just schedule an update
			
			GroupCalendar.Network:ScheduleAutoConfig(0.5)
		end
	
	elseif pIndex == GroupCalendar.PANEL_BACKUP then
		-- Nothing to save for backup
		
	elseif pIndex == GroupCalendar.PANEL_ABOUT then
		-- About panel
		
	end
	
	GroupCalendar_UpdateEnabledControls()
end

function GroupCalendar_ChannelPanelHasChanges()
	-- No changes if the panel isn't shown
	
	if not GroupCalendarFrame:IsVisible()
	or GroupCalendarFrame.selectedTab ~= GroupCalendar.PANEL_SETUP then
		return false
	end
	
	--
	
	local vAutoConfig, vGuildAdmin = GroupCalendar_GetUIConfigMode()
	
	if (vAutoConfig ~= GroupCalendar.PlayerSettings.Channel.AutoConfig)
	or (vGuildAdmin ~= GroupCalendar.PlayerSettings.Channel.GuildAdmin) then
		if GroupCalendar.Debug.ChannelConfig then
			GroupCalendar:DebugMessage("GroupCalendar_ChannelPanelHasChanges: Config mode changed")
		end
		
		return true
	end
	
	if not vAutoConfig or vGuildAdmin then
		local vChannelInfo = GroupCalendar_GetCurrentChannelInfo()
		local vChannelName, vChannelPassword, vMinTrustedRank = GroupCalendar_GetUIChannelInfo()
		
		if vChannelInfo.Name ~= vChannelName
		or vChannelInfo.Password ~= vChannelPassword
		or vChannelInfo.MinTrustedRank ~= vMinTrustedRank then
			if GroupCalendar.Debug.ChannelConfig then
				if vChannelInfo.Name ~= vChannelName then
					GroupCalendar:DebugMessage("GroupCalendar_ChannelPanelHasChanges: Name changed")
				end
				
				if vChannelInfo.Password ~= vChannelPassword then
					GroupCalendar:DebugMessage("GroupCalendar_ChannelPanelHasChanges: Password changed")
				end
				
				if vChannelInfo.MinTrustedRank ~= vMinTrustedRank then
					GroupCalendar:DebugMessage("GroupCalendar_ChannelPanelHasChanges: MinTrustedRank changed")
				end
			end
			return true
		end
	end
	
	return false
end

function GroupCalendar_UpdateChannelInfo(pChannelInfo)
	if pChannelInfo.Name == "#GUILD" then
		CalendarDropDown_SetSelectedValue(GroupCalendarTrustMinRank, pChannelInfo.MinTrustedRank)
	else
		CalendarDropDown_SetSelectedValue(GroupCalendarTrustMinRank, nil)
	end
	
	if GroupCalendar.PlayerSettings.Channel.AutoConfig
	and not GroupCalendar.PlayerSettings.Channel.GuildAdmin then
		if pChannelInfo.Password then
			GroupCalendarChannelPassword:SetText(GroupCalendar_cObfuscatedPassword)
		else
			GroupCalendarChannelPassword:SetText("")
		end
	else
		if pChannelInfo.Password then
			GroupCalendarChannelPassword:SetText(pChannelInfo.Password)
		else
			GroupCalendarChannelPassword:SetText("")
		end
	end
	
	if pChannelInfo.Name ~= nil
	and pChannelInfo.Name ~= "#GUILD" then
		GroupCalendarChannelName:SetText(pChannelInfo.Name)
	else
		GroupCalendarChannelName:SetText("")
	end
	
	GroupCalendar_UpdateChannelStatus()
end

function GroupCalendar_GetCurrentChannelInfo()
	local vChannelName, vChannelPassword, vMinTrustedRank

	if GroupCalendar.PlayerSettings.Channel.AutoConfig
	or GroupCalendar.PlayerSettings.Channel.GuildAdmin then
		local vAutoConfigData = GroupCalendar.Network:GetAutoConfigData()
		
		if vAutoConfigData then
			vChannelName = vAutoConfigData.ChannelName
			vChannelPassword = vAutoConfigData.ChannelPassword
			vMinTrustedRank = vAutoConfigData.MinTrustedRank
		end
	else
		vChannelName = GroupCalendar.PlayerSettings.Channel.Name
		vChannelPassword = GroupCalendar.PlayerSettings.Channel.Password
		vMinTrustedRank = GroupCalendar.PlayerSettings.Channel.MinTrustedRank
	end
	
	return {Name = vChannelName, Password = vChannelPassword, MinTrustedRank = vMinTrustedRank}
end

function GroupCalendar:UpdateChannelSetupFields()
	if GroupCalendar.PlayerSettings.Channel.GuildAdmin then
		CalendarDropDown_SetSelectedValue(CalendarConfigModeMenu, "CONFIG_ADMIN")
	elseif GroupCalendar.PlayerSettings.Channel.AutoConfig then
		CalendarDropDown_SetSelectedValue(CalendarConfigModeMenu, "CONFIG_AUTO")
	else
		CalendarDropDown_SetSelectedValue(CalendarConfigModeMenu, "CONFIG_MANUAL")
	end
	
	--
	
	local vChannelInfo = GroupCalendar_GetCurrentChannelInfo()
	local vUseGuildChannel = (IsInGuild() and vChannelInfo.Name == nil) or vChannelInfo.Name == "#GUILD"
	
	GroupCalendar:DebugTable("    vChannelInfo", vChannelInfo)
	
	GroupCalendarUseGuildChannel:SetChecked(vUseGuildChannel)
	GroupCalendarUseSharedChannel:SetChecked(not vUseGuildChannel)
	
	GroupCalendar_UpdateChannelInfo(vChannelInfo)
end

function GroupCalendar:ShowPanel(pPanelIndex)
	if GroupCalendar.CurrentPanel > 0
	and GroupCalendar.CurrentPanel ~= pPanelIndex then
		GroupCalendar_HidePanel(GroupCalendar.CurrentPanel)
	end
	
	-- NOTE: Don't check for redundant calls since this function
	-- will be called to reset the field values as well as to 
	-- actuall show the panel when it's hidden
	
	GroupCalendar.CurrentPanel = pPanelIndex
	
	-- Hide the event editor/viewer if the calendar panel is being hidden
	
	if pPanelIndex ~= GroupCalendar.PANEL_CALENDAR then
		GroupCalendar.EventEditor:DoneEditing()
		GroupCalendar.EventViewer:DoneViewing()
		CalendarEditor_Close()
	end
	
	if pPanelIndex ~= GroupCalendar.PANEL_ABOUT then
		GroupCalendarDatabasesList_Close()
	end

	-- Update the control values
	
	if pPanelIndex == GroupCalendar.PANEL_CALENDAR then
		-- Calendar display
		
	elseif pPanelIndex == GroupCalendar.PANEL_SETUP then
		-- Channel panel
		
		CalendarConfigModeMenu.ChangedValueFunc = GroupCalendar_ConfigModeChanged
		
		self:UpdateChannelSetupFields()
		
		CalendarPlayerList_SetItemFunction(CalendarExcludedPlayersList, GroupCalendar_GetIndexedExcludedPlayer)
		CalendarPlayerList_SetSelectionChangedFunction(CalendarExcludedPlayersList, GroupCalendar_ExcludedPlayerSelected)

	elseif pPanelIndex == GroupCalendar.PANEL_BACKUP then
		-- Backup panel
		
		GroupCalendar.BackupUI:SetBackupInfo(self.PlayerName, GroupCalendar.UserDatabase.Backups)
		
	elseif pPanelIndex == GroupCalendar.PANEL_ABOUT then
		-- About panel
		
	end
	
	GroupCalendar_UpdateEnabledControls()
	
	getglobal(GroupCalendar.PanelFrames[pPanelIndex]):Show()
	
	PanelTemplates_SetTab(GroupCalendarFrame, pPanelIndex)
end

function GroupCalendar_GetLatestVersionInfo()
	-- Scan the databases to find the newest version

	-- If it's newer than ours then put up a message, otherwise
	-- clear the message

	local vVersionList = GroupCalendar_GetUserVersionsList()
	local vVersion = GroupCalendar.NewObject(GroupCalendar._Version)
	local vOurVersion = GroupCalendar.NewObject(GroupCalendar._Version)
	local vLatestVersion = GroupCalendar.NewObject(GroupCalendar._Version)
	local vCheckBetas = vLatestVersion.BuildLevel ~= 0
	
	vOurVersion:FromString(GroupCalendar.VersionString)
	vLatestVersion:FromString(GroupCalendar.VersionString)
	
	for _, vVersionInfo in ipairs(vVersionList) do
		vVersion:FromString(vVersionInfo.Version)
		
		if (vCheckBetas or vVersion.BuildLevel == 0)
		and vLatestVersion:LessThan(vVersion) then
			vLatestVersion = vVersion
			vVersion = GroupCalendar.NewObject(GroupCalendar._Version)
		end
	end
	
	if vOurVersion:LessThan(vLatestVersion) then
		return vLatestVersion
	else
		return nil
	end
end

function GroupCalendar_HidePanel(pFrameIndex)
	if GroupCalendar.CurrentPanel ~= pFrameIndex then
		return
	end
	
	GroupCalendar_SavePanel(pFrameIndex)
	
	getglobal(GroupCalendar.PanelFrames[pFrameIndex]):Hide()
	GroupCalendar.CurrentPanel = GroupCalendar.PANEL_NULL
end

function GroupCalendar_UpdateChannelStatus()
	local vChannelStatus, vStatusMessage, vStartTime = GroupCalendar.Network:GetStatus()
	local vStatusText = GroupCalendar_cChannelStatus[vChannelStatus]
	
	if not vStatusText then
		GroupCalendar:ErrorMessage("Unknown status "..(vChannelStatus or ""))
	end
	
	if vChannelStatus == "Synching" then
		local vSecondsRemaining = GroupCalendar.Network.Delay.SynchComplete - (GetTime() - vStartTime)
		local vMinutesRemaining = math.floor(vSecondsRemaining / 60)
		
		vSecondsRemaining = vSecondsRemaining - vMinutesRemaining * 60
		
		vStatusMessage = string.format(GroupCalendar_cTimeRemainingFormat, vMinutesRemaining, vSecondsRemaining)
		
		MCSchedulerLib:ScheduleUniqueTask(0.5, GroupCalendar_UpdateChannelStatus, nil, "GroupCalendar_UpdateChannelStatus")
	else
		MCSchedulerLib:UnscheduleTask(GroupCalendar_UpdateChannelStatus)
	end
	
	GroupCalendarChannelStatus:SetText(string.format(vStatusText.mText, vStatusMessage))
	GroupCalendarChannelStatus:SetTextColor(vStatusText.mColor.r, vStatusText.mColor.g, vStatusText.mColor.b)
	
	if GroupCalendar_ChannelPanelHasChanges() then
		GroupCalendarConnectChannelButton:SetText(GroupCalendar_cApplyChannelChanges)
		GroupCalendar.SetButtonEnable(GroupCalendarConnectChannelButton, true)
	
	elseif GroupCalendar.Network:IsConnected() then
		GroupCalendar.SetButtonEnable(GroupCalendarConnectChannelButton, true)
		GroupCalendarConnectChannelButton:SetText(GroupCalendar_cDisconnectChannel)
	
	elseif vChannelStatus == "Disconnected" or vChannelStatus == "Error" then
		GroupCalendar.SetButtonEnable(GroupCalendarConnectChannelButton, true)
		GroupCalendarConnectChannelButton:SetText(GroupCalendar_cConnectChannel)
	
	else
		GroupCalendar.SetButtonEnable(GroupCalendarConnectChannelButton, false)
	end
end

function GroupCalendar_FixPlayerName(pName)
	if pName == nil
	or pName == "" then
		return nil
	end
	
	local vFirstChar = string.sub(pName, 1, 1)
	
	if (vFirstChar >= "a" and vFirstChar <= "z")
	or (vFirstChar >= "A" and vFirstChar <= "Z") then
		return string.upper(vFirstChar)..string.lower(string.sub(pName, 2))
	else
		return pName
	end
end

function GroupCalendar_AddExcludedPlayer(pPlayerName)
	local vPlayerName = GroupCalendar_FixPlayerName(pPlayerName)

	if vPlayerName == nil then
		return
	end
	
	GroupCalendar.PlayerSettings.Security.Player[vPlayerName] = 2
	GroupCalendar_UpdateTrustedPlayerList()
	GroupCalendar.Network:TrustSettingsChanged()
end

function GroupCalendar_RemoveTrustedPlayer(pPlayerName)
	local vPlayerName = GroupCalendar_FixPlayerName(pPlayerName)

	if vPlayerName == nil then
		return
	end
	
	GroupCalendar.PlayerSettings.Security.Player[vPlayerName] = nil
	
	GroupCalendar_UpdateTrustedPlayerList()
	
	CalendarPlayerList_SelectIndexedPlayer(CalendarExcludedPlayersList, 0)
	
	GroupCalendar.Network:TrustSettingsChanged()
end

function GroupCalendar_UpdateTrustedPlayerList()
	CalendarPlayerList_Update(CalendarExcludedPlayersList)
end

function GroupCalendar_GetIndexedTrustedPlayer(pIndex)
	if pIndex == 0 then
		return GroupCalendar.Network:GetNumTrustedPlayers(1)
	end
	
	return
	{
		Text = GroupCalendar.Network:GetIndexedTrustedPlayers(1, pIndex)
	}
end

function GroupCalendar_GetIndexedExcludedPlayer(pIndex)
	if pIndex == 0 then
		return GroupCalendar.Network:GetNumTrustedPlayers(2)
	end
	
	return
	{
		Text = GroupCalendar.Network:GetIndexedTrustedPlayers(2, pIndex)
	}
end

function GroupCalendar_TrustedPlayerSelected(pIndex)
	if pIndex == 0 then
		return
	end
	
	CalendarPlayerList_SelectIndexedPlayer(CalendarExcludedPlayersList, 0)
	
	local vName = GroupCalendar.Network:GetIndexedTrustedPlayers(1, pIndex)
	
	if vName then
		CalendarTrustedPlayerName:SetText(vName)
		CalendarTrustedPlayerName:HighlightText()
		CalendarTrustedPlayerName:SetFocus()
	end
end

function GroupCalendar_ExcludedPlayerSelected(pIndex)
	if pIndex == 0 then
		return
	end
	
	local vName = GroupCalendar.Network:GetIndexedTrustedPlayers(2, pIndex)
	
	if vName then
		CalendarTrustedPlayerName:SetText(vName)
		CalendarTrustedPlayerName:HighlightText()
		CalendarTrustedPlayerName:SetFocus()
	end
end

function GroupCalendar_SelectDateWithToggle(pDate)
	if CalendarEditor_IsOpen()
	and gCalendarEditor_SelectedDate == pDate then
		CalendarEditor_Close()
	else
		GroupCalendar_SelectDate(pDate)
	end
end

function GroupCalendar_SelectDate(pDate)
	GroupCalendar.SetSelectedDate(pDate)
	
	local vCompiledSchedule = GroupCalendar.Database.GetCompiledSchedule(pDate, true)
	
	CalendarEditor_SetCompiledSchedule(pDate, vCompiledSchedule)
end

function GroupCalendar_EditorClosed()
	GroupCalendar.ClearSelectedDate()
end

function GroupCalendar_EventChanged(pDatabase, pEvent, pChangedFields)
	GroupCalendar_ScheduleChanged(pDatabase, pEvent.mDate)
	GroupCalendar.EventEditor:EventChanged(pEvent)
end

function GroupCalendar_ScheduleChanged(pDatabase, pDate)
	GroupCalendar_ScheduleChanged2(pDatabase, pDate)
	
	if gGroupCalendar_Settings.ShowEventsInLocalTime then
		if MCDateLib.ServerTimeZoneOffset < 0 then
			GroupCalendar_ScheduleChanged2(pDatabase, pDate - 1)
		elseif MCDateLib.ServerTimeZoneOffset > 0 then
			GroupCalendar_ScheduleChanged2(pDatabase, pDate + 1)
		end
	end
end

function GroupCalendar_ScheduleChanged2(pDatabase, pDate)
	local vSchedule = pDatabase.Events[pDate]
	
	CalendarEditor_ScheduleChanged(pDate, pSchedule)
	GroupCalendar.ScheduleChanged(pDate, pSchedule)
	GroupCalendar.EventViewer:ScheduleChanged(pDate)
	
	local vCurrentDate, vCurrentTime = MCDateLib:GetServerDateTime()
	
	if pDate == vCurrentDate or pDate == vCurrentDate + 1 or pDate == vCurrentDate - 1 then
		MCSchedulerLib:ScheduleUniqueTask(5, GroupCalendar_CalculateReminders, nil, "GroupCalendar_CalculateReminders")
	end
end

function GroupCalendar_AddedNewEvent(pDatabase, pEvent)
	GroupCalendar.NewEvents[pEvent.mDate] = true
	
	if GroupCalendarFrame:IsVisible() then
		GroupCalendar.StartFlashingDateButton(pEvent.mDate)
	else
		GroupCalendar.Calendar.StartFlashingReminder()
	end
end

function GroupCalendar_MajorDatabaseChange(pDatabase)
	MCSchedulerLib:ScheduleUniqueTask(1, GroupCalendar_MajorDatabaseChange2)
end

function GroupCalendar_MajorDatabaseChange2()
	GroupCalendar.Whisper.CurrentDate = nil -- Dump the event summary cache
	
	CalendarEditor_MajorDatabaseChange()
	GroupCalendar.EventViewer:MajorDatabaseChange()
	GroupCalendar.EventEditor:MajorDatabaseChange()
	GroupCalendar.Calendar.MajorDatabaseChange()
end

function GroupCalendar_StartMoving()
	if not GroupCalendar.PlayerSettings.UI.LockWindow then
		GroupCalendarFrame:StartMoving()
	end
end

function GroupCalendar_GetPlayerSettings(pPlayerName, pRealmName)
	if gGroupCalendar_Settings.Format < 2 then
		-- First migrate all player settings to the PlayerSettings and RealmSettings arrays
		
		local vPlayerSettings = {}
		local vRealmSettings = {}
		
		for vRealmPlayer, vSettings in pairs(gGroupCalendar_Settings) do
			if type(vSettings) == "table" then
				if string.find(vRealmPlayer, "_") then
					vPlayerSettings[vRealmPlayer] = vSettings
				else
					vRealmSettings[vRealmPlayer] = vSettings
				end
				
				gGroupCalendar_Settings[vRealmPlayer] = nil
			end
		end
		
		gGroupCalendar_Settings.PlayerSettings = vPlayerSettings
		gGroupCalendar_Settings.RealmSettings = vRealmSettings
		
		for vRealmPlayer, vSettings in pairs(gGroupCalendar_Settings.PlayerSettings) do
			if vSettings.Channel.AutoConfig then
				vSettings.Channel.GuildAdmin = false
				vSettings.Channel.Name = nil
				vSettings.Channel.Password = nil
				vSettings.Channel.AutoConfigPlayer = nil
			elseif vSettings.Channel.AutoConfigPlayer then
				vSettings.Channel.GuildAdmin = IsInGuild() and CanEditGuildInfo()
				vSettings.Channel.AutoConfig = IsInGuild() and not CanEditGuildInfo()

				if vSettings.Security.MinTrustedRank then
					vSettings.Channel.UseGuildChannel = true
					vSettings.Channel.Name = nil
					vSettings.Channel.Password = nil
				else
					vSettings.Channel.UseGuildChannel = false
				end
				
				vSettings.Channel.AutoConfigPlayer = nil
			else
				vSettings.Channel.GuildAdmin = false
				
				if vSettings.Security.MinTrustedRank then
					vSettings.Channel.UseGuildChannel = true
				else
					vSettings.Channel.UseGuildChannel = false
				end
			end
			
			vSettings.Security.TrustAnyone = nil
			vSettings.Security.TrustGuildies = nil
		end -- for
		
		gGroupCalendar_Settings.Format = 2
	end
	
	--
	
	local vSettings = gGroupCalendar_Settings.PlayerSettings[pRealmName.."_"..pPlayerName]
	
	if vSettings == nil then
		vSettings =
		{
			Security =
			{
				MinTrustedRank = 1,
				Player = {},
			},
			
			Channel =
			{
				AutoConfig = IsInGuild() and not CanEditGuildInfo(),
				GuildAdmin = IsInGuild() and CanEditGuildInfo(),
				UseGuildChannel = IsInGuild(),
				Name = nil,
				Password = nil,
			},
			
			UI =
			{
				LockWindow = false,
			},
		}
		
		gGroupCalendar_Settings.PlayerSettings[pRealmName.."_"..pPlayerName] = vSettings
	end
	
	return vSettings
end

function GroupCalendar_GetRealmSettings(pRealmName)
	local vSettings = gGroupCalendar_Settings.RealmSettings[pRealmName]
	
	if vSettings == nil then
		vSettings = {}
		gGroupCalendar_Settings.RealmSettings[pRealmName] = vSettings
	end
	
	return vSettings
end

function GroupCalendar_ChannelChanged()
	if GroupCalendarFrame:IsVisible()
	and GroupCalendar.CurrentPanel == GroupCalendar.PANEL_SETUP then
		local vAutoConfig, vGuildAdmin = GroupCalendar_GetUIConfigMode()
		
		if vAutoConfig or vGuildAdmin then
			GroupCalendar:ShowPanel(GroupCalendar.CurrentPanel)
		end
		
		GroupCalendar_UpdateChannelStatus()
	end
end

function GroupCalendar_ToggleChannelConnection()
	local vChannelStatus = GroupCalendar.Network:GetStatus()
	
	if vChannelStatus == "Initializing" then
		return
	end
	
	if GroupCalendar_ChannelPanelHasChanges()
	or not GroupCalendar.Network:IsConnected() then
		GroupCalendar_SavePanel(GroupCalendar.CurrentPanel)
	else
		GroupCalendar.Network.Channel.Disconnected = true
		GroupCalendar.Network:LeaveChannel()
	end
end

function GroupCalendar.ToggleCalendarDisplay()
	if GroupCalendarFrame:IsVisible() then
		HideUIPanel(GroupCalendarFrame)
	else
		ShowUIPanel(GroupCalendarFrame)
	end
end

function GroupCalendar.BeginModalDialog(pDialogFrame)
	if GroupCalendar.ActiveDialog then
		GroupCalendar.EndModalDialog(GroupCalendar.ActiveDialog)
	end
	
	GroupCalendar.ActiveDialog = pDialogFrame
end

function GroupCalendar.EndModalDialog(pDialogFrame)
	if pDialogFrame ~= GroupCalendar.ActiveDialog then
		return
	end
	
	GroupCalendar.ActiveDialog = nil
	
	pDialogFrame:Hide()
end

function GroupCalendar:ExecuteCommand(pCommandString)
	local vStartIndex, vEndIndex, vCommand, vParameter = string.find(pCommandString, "([^%s]+) ?(.*)")
	
	local vCommandTable =
	{
		["help"] = {func = self.ShowCommandHelp},
		["versions"] = {func = self.DumpUserVersions},
		["reset"] = {func = self.AskReset},
		["kill"] = {func = self.AskKillUserDatabase},
		["mon"] = {func = self.SetMondayWeek},
		["sun"] = {func = self.SetSundayWeek},
		["12h"] = {func = self.Set12Hour},
		["24h"] = {func = self.Set24Hour},
		["clock"] = {func = self.SetClockOption},
		["reminder"] = {func = self.SetReminderOption},
		["birthdays"] = {func = self.SetBirthdaysOption},
		["history"] = {func = self.HistoryCommand},
		["show"] = {func = function () ShowUIPanel(GroupCalendarFrame) end},
		["hide"] = {func = function () HideUIPanel(GroupCalendarFrame) end},
		["data"] = {func = function(self, pData) self.Network.Channel:SendMessage(pData) end},
		["summary"] = {func = self.ShowEventSummary},
		["altmail"] = {func = self.SetAltMail},
	}
	
	local vCommandInfo = vCommandTable[strlower(vCommand or "help")]
	
	if not vCommandInfo then
		self:ShowCommandHelp()
		return
	end
	
	vCommandInfo.func(self, vParameter)
end

function GroupCalendar:ShowCommandHelp()
	GroupCalendar:NoteMessage("Group Calendar Commands")
	GroupCalendar:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/cal show"..NORMAL_FONT_COLOR_CODE.." Shows Group Calendar")
	GroupCalendar:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/cal [sun|mon]"..NORMAL_FONT_COLOR_CODE.." Sets the starting day of the week")
	GroupCalendar:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/cal [12h|24h]"..NORMAL_FONT_COLOR_CODE.." Sets WoW to use 12h or 24h times")
	GroupCalendar:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/cal clock [off|on|local|server]"..NORMAL_FONT_COLOR_CODE.." Sets the display mode for the minimap clock")
	GroupCalendar:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/cal reminder [on|off]"..NORMAL_FONT_COLOR_CODE.." Enables or disables all event and cooldown reminders")
	GroupCalendar:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/cal birthdays [on|off]"..NORMAL_FONT_COLOR_CODE.." Enables or disables birthday reminders")
	GroupCalendar:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/cal reset [realm|all]"..NORMAL_FONT_COLOR_CODE.." Resets your calendar for all characters on the current realm.  Use the REALM switch to reset your calendars on the current realm or use ALL to reset your calendars on all realms.")
	GroupCalendar:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/cal history days"..NORMAL_FONT_COLOR_CODE.." Sets the maximum number of days to keep old events")
	GroupCalendar:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/cal versions"..NORMAL_FONT_COLOR_CODE.." Displays the last known versions of GroupCalendar each user was running")
	GroupCalendar:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/cal kill playerName"..NORMAL_FONT_COLOR_CODE.." Deletes all events for the player from the calendar (guild officers only)")
	GroupCalendar:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/cal summary [guild]"..NORMAL_FONT_COLOR_CODE.." Shows a summary of upcoming events, optionally sending them to the guild channel")
	GroupCalendar:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/cal help"..NORMAL_FONT_COLOR_CODE.." Shows this list of commands")
end

function GroupCalendar_GetUserVersionsList()
	local vVersions = {}
	
	for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if GroupCalendar.Database.DatabaseIsVisible(vDatabase)
		and not vDatabase.IsPlayerOwned then
			if vDatabase.AddonVersion then
				table.insert(vVersions, {UserName = vDatabase.UserName, Version = vDatabase.AddonVersion, Updated = vDatabase.AddonVersionUpdated})
			else
				-- Just ignore unknown versions
				-- table.insert(vVersions, {UserName = vDatabase.UserName, Version = "Unknown"})
			end
		end
	end
	
	table.sort(vVersions, GroupCalendar_CompareUserNameFields)
	
	return vVersions
end

function GroupCalendar:DumpUserVersions()
	local vVersions = GroupCalendar_GetUserVersionsList()
	
	for _, vVersion in pairs(vVersions) do
		self:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE..vVersion.UserName..NORMAL_FONT_COLOR_CODE..": "..vVersion.Version)
	end
end

StaticPopupDialogs.CALENDAR_CONFIRM_RESET =
{
	text = TEXT(GroupCalendar_cConfirmResetMsg),
	button1 = TEXT(GroupCalendar_cReset),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar:Reset(GroupCalendar.ResetMode) end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

StaticPopupDialogs.CALENDAR_CONFIRM_RESET_REALM =
{
	text = TEXT(GroupCalendar_cConfirmResetRealmMsg),
	button1 = TEXT(GroupCalendar_cReset),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar:Reset(GroupCalendar.ResetMode) end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

StaticPopupDialogs.CALENDAR_CONFIRM_RESET_ALL =
{
	text = TEXT(GroupCalendar_cConfirmResetAllMsg),
	button1 = TEXT(GroupCalendar_cReset),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar:Reset(GroupCalendar.ResetMode) end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

function GroupCalendar:AskReset(pParam)
	self.ResetMode = pParam
	
	if string.upper(pParam) == "ALL" then
		StaticPopup_Show("CALENDAR_CONFIRM_RESET_ALL")
	
	elseif string.upper(pParam) == "REALM" then
		StaticPopup_Show("CALENDAR_CONFIRM_RESET_REALM", self.RealmName)
	
	else
		self.ResetMode = "PLAYER"
		StaticPopup_Show("CALENDAR_CONFIRM_RESET", self.PlayerName)
	end
end

function GroupCalendar:ResetAll()
	self.Network:Reset()
	
	-- Wipe the database
	
	gGroupCalendar_Database =
	{
		Format = GroupCalendar.Database.cFormat,
		Databases = {},
	}
	
	-- Reinitialize
	
	self:VariablesLoaded()
end

function GroupCalendar:Reset(pResetMode)
	-- Remove all non-player databases and
	-- empty the player databases
	
	for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if vDatabase.IsPlayerOwned then
			if pResetMode == "ALL"
			or (pResetMode == "REALM" and vDatabase.Realm == self.RealmName)
			or (pResetMode == "PLAYER" and vDatabase.UserName == self.PlayerName) then
				local vDatabaseID = MCDateLib:GetUTCDateTimeStamp()
				
				self.Database.PurgeDatabase(vDatabase, "DB", vDatabaseID)
				self.Database.PurgeDatabase(vDatabase, "RAT", vDatabaseID)
				self.Network.ResponseQueue:QueueNOU(vDatabase, "DB", 0, 0)
				self.Network.ResponseQueue:QueueNOU(vDatabase, "RAT", 0, 0)

				self.Network.ResponseQueue:QueueNOU(vDatabase, "DB", 0, 0)
				self.Network.ResponseQueue:QueueNOU(vDatabase, "RAT", 0, 0)
			end
		else
			if pResetMode == "ALL"
			or (pResetMode == "REALM" and vDatabase.Realm == self.RealmName) then
				gGroupCalendar_Database.Databases[vRealmUser] = nil
				GroupCalendar_MajorDatabaseChange(vDatabase)
			elseif pResetMode == "PLAYER"
			and vDatabase.Realm == self.RealmName then
				self.Database.DeleteDatabase(vDatabase) -- This only removes the database from this player
			end
		end
	end
	
	self.Network:QueueExternalRFU()
end

StaticPopupDialogs.CALENDAR_CONFIRM_KILL =
{
	text = TEXT(GroupCalendar_cConfirmKillMsg),
	button1 = TEXT(GroupCalendar_cKill),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar_KillUserDatabase() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

GroupCalendar.KillDatabaseUserName = nil

function GroupCalendar:AskKillUserDatabase(pUserName)
	if not pUserName then
		GroupCalendar:ErrorMessage(GroupCalendar_cUserNameExpected)
		return
	end
	
	if IsInGuild() and not CanEditOfficerNote() then
		GroupCalendar:ErrorMessage(GroupCalendar_cNotAnOfficerError)
		return
	end
	
	local vUserName = GroupCalendar.Database.FixUserName(pUserName)
	
	if GroupCalendar.Network:UserIsInSameGuild(vUserName) then
		GroupCalendar:ErrorMessage(format(GroupCalendar_cCantKillGuildieError, vUserName))
		return
	end
	
	local vDatabase = GroupCalendar.Database.GetDatabase(vUserName)
	
	if not vDatabase then
		GroupCalendar:ErrorMessage(format(GroupCalendar_cDatabaseNotFoundError, vUserName))
		return
	end
	
	if IsInGuild() then
		GroupCalendar.KillDatabaseUserName = vUserName
		StaticPopup_Show("CALENDAR_CONFIRM_KILL", vUserName)
	else
		GroupCalendar.Database.DeleteDatabaseByName(vUserName)
	end
end

function GroupCalendar_KillUserDatabase()
	local vDatabase = GroupCalendar.Database.GetDatabase(GroupCalendar.KillDatabaseUserName)
	
	if not vDatabase then
		return
	end
	
	if not vDatabase.IsPlayerOwned then
		-- Only allowed within a guild
		
		if not IsInGuild() then
			return
		end
		
		if not CanEditOfficerNote() then
			return
		end
	end
	
	-- Purge the events
	
	local vDatabaseID = MCDateLib:GetUTCDateTimeStamp()
	
	if vDatabase.Changes and vDatabaseID < vDatabase.Changes.ID  then
		vDatabaseID = vDatabase.Changes.ID + 1
	end
	
	GroupCalendar.Database.PurgeDatabase(vDatabase, "DB", vDatabaseID)
	GroupCalendar.Network.ResponseQueue:QueueNOU(vDatabase, "DB", 0, 0)
	
	-- Purge the RSVPs
	
	if vDatabase.RSVPs then
		local vDatabaseID = MCDateLib:GetUTCDateTimeStamp()
		
		if vDatabaseID < vDatabase.RSVPs.ID  then
			vDatabaseID = vDatabase.RSVPs.ID + 1
		end
		
		GroupCalendar.Database.PurgeDatabase(vDatabase, "RAT", vDatabaseID)
		GroupCalendar.Network.ResponseQueue:QueueNOU(vDatabase, "RAT", 0, 0)
	end
end

function GroupCalendar_CompareUserNameFields(pValue1, pValue2)
	return pValue1.UserName < pValue2.UserName
end

function GroupCalendar.Time.SetUseServerDateTime(pUseServerDateTime)
	gGroupCalendar_Settings.ShowEventsInLocalTime = not pUseServerDateTime
	
	GroupCalendarUseServerTime:SetChecked(pUseServerDateTime)
	
	GroupCalendar_MajorDatabaseChange(nil) -- Force the display to update
	
	MCEventLib:DispatchEvent("GC_CLOCKS_CHANGED") -- Make the clocks update
end

function GroupCalendar:SetMondayWeek()
	GroupCalendar.Calendar:SetStartWeekOnMonday(true)
end

function GroupCalendar:SetSundayWeek()
	GroupCalendar.Calendar:SetStartWeekOnMonday(nil)
end

function GroupCalendar:Set12Hour()
	gGroupCalendar_Settings.TwentyFourHourTime = false
	TwentyFourHourTime = nil
	MCEventLib:DispatchEvent("GC_CLOCKS_CHANGED") -- Make the clocks update
end

function GroupCalendar:Set24Hour()
	gGroupCalendar_Settings.TwentyFourHourTime = true
	TwentyFourHourTime = 1
	MCEventLib:DispatchEvent("GC_CLOCKS_CHANGED") -- Make the clocks update
end

----------------------------------------
-- DatabaseList
----------------------------------------

function GroupCalendarDatabasesList_Open()
	local vDesc =
	{
		Title = CalendarDatabases_cTitle,
		CloseFunc = GroupCalendarDatabasesList_Close,
		ButtonTitle = CalendarDatabases_cRefresh,
		ButtonDescription = CalendarDatabases_cRefreshDescription,
		ButtonFunc = GroupCalendarDatabasesList_Refresh,
		ListItems = GroupCalendarDatabasesList,
	}
	
	GroupCalendarDatabasesList.UpdateItems = GroupCalendarDatabasesList_UpdateItems
	GroupCalendarDatabasesList.UpdateItem = GroupCalendarDatabasesList_UpdateItem
	
	GroupCalendarDatabasesList.Versions = GroupCalendar_GetUserVersionsList()
	GroupCalendarSideList_Show(vDesc)
end

function GroupCalendarDatabasesList_Close()
	GroupCalendarSideList_Hide()
end

function GroupCalendarDatabasesList_Refresh()
	GroupCalendar.Network:QueueAllRFV(0)
end

function GroupCalendarDatabasesList_UpdateItems(pListItems)
	GroupCalendarSideList_SetNumItems(table.getn(GroupCalendarDatabasesList.Versions))
	GroupCalendarDatabasesListTotal:SetText(string.format(GroupCalendar.cDatabasesTotalFormat, table.getn(GroupCalendarDatabasesList.Versions)))
end

function GroupCalendarDatabasesList_UpdateItem(pListItems, pIndex, pItem, pItemName, pItemIndex)
	local vLabelText = getglobal(pItemName.."Label")
	local vValueText = getglobal(pItemName.."Value")
	local vVersionInfo = pListItems.Versions[pIndex]
	
	vLabelText:SetText(vVersionInfo.UserName)
	vValueText:SetText(string.format(GroupCalendar_cShortVersionFormat, vVersionInfo.Version))
	
	pItem.VersionInfo = vVersionInfo
	pItem.UpdateTooltip = GroupCalendarDatabasesList_UpdateTooltip
end

function GroupCalendarDatabasesList_UpdateTooltip(pItem)
	GameTooltip:SetOwner(pItem, "ANCHOR_RIGHT")
	GameTooltip:AddLine(pItem.VersionInfo.UserName)
	
	GameTooltip:AddLine(string.format(GroupCalendar_cVersionFormat, pItem.VersionInfo.Version), 1, 1, 1, 1)
	
	if pItem.VersionInfo.Updated then
		local vLocalDate, vLocalTime = MCDateLib:GetDateTimeFromTimeStamp(pItem.VersionInfo.Updated)
		
		GameTooltip:AddLine(string.format(GroupCalendar_cVersionUpdatedFormat, GroupCalendar.GetLongDateString(vLocalDate), GroupCalendar.GetShortTimeString(vLocalTime)), 1, 1, 1, 1)
	else
		GameTooltip:AddLine(GroupCalendar_cVersionUpdatedUnknown, 1, 1, 1, 1)
	end
	
	GameTooltip:Show()
end

function GroupCalendar_VersionDataChanged()
	if GroupCalendarDatabasesList:IsShown() then
		GroupCalendarDatabasesList.Versions = GroupCalendar_GetUserVersionsList()
		GroupCalendarDatabasesList:UpdateItems()
	end
end

function GroupCalendar_ToggleVersionsFrame()
	if GroupCalendarDatabasesList:IsShown() then
		GroupCalendarDatabasesList_Close()
	else
		GroupCalendarDatabasesList_Open()
	end
end

local GroupCalendar_cClockOptions =
{
	["hide"] = {DisableClock = true},
	["show"] = {DisableClock = false, ClockMode = "auto"},
	["local"] = {DisableClock = false, ClockMode = "local"},
	["server"] = {DisableClock = false, ClockMode = "server"},
	
	-- These commands are aliased versions
	
	["auto"] = {DisableClock = false, ClockMode = "auto"},
	["off"] = {DisableClock = true},
	["on"] = {DisableClock = false, ClockMode = "auto"},
}

function GroupCalendar:SetClockOption(pOption)
	local vOption = GroupCalendar_cClockOptions[string.lower(pOption)]
	
	if not vOption then
		GroupCalendar:ErrorMessage(GroupCalendar_cUnknownClockOption)
		return
	end
	
	GroupCalendar.CopyTable(gGroupCalendar_Settings, vOption)
	
	if gGroupCalendar_Settings.DisableClock then
		GroupCalendarButton:HideDisplay()
	else
		GroupCalendarButton:ShowDisplay()
	end
end

function GroupCalendar:HistoryCommand(pOption)
	local vAge = tonumber(pOption)
	
	if not vAge or vAge < 1 or vAge > 60 then
		GroupCalendar:ErrorMessage(GroupCalendar_cBadAgeValue)
		return
	end
	
	if GroupCalendar_SetMaxEventAge(vAge) then
		-- Force the auto config data to update if this player is
		-- a guild admin
		
		if GroupCalendar.PlayerSettings.Channel.GuildAdmin then
			GroupCalendar.Network:SetAutoConfigData(GroupCalendar_GetUIChannelInfo())
		end
	end
	
	GroupCalendar:NoteMessage("Maximum event age is now %d days", vAge)
end

function GroupCalendar:ShowEventSummary(pOption)
	local vPlayerName
	
	if string.lower(pOption) == "guild" then
		vPlayerName = "_GUILD"
	end
	
	GroupCalendar.Whisper.Commands.SUMMARY(GroupCalendar.Whisper, vPlayerName)
end

function GroupCalendar_SetMaxEventAge(pAge)
	if pAge == GroupCalendar.MaximumEventAge then
		return false
	end
	
	GroupCalendar.MaximumEventAge = pAge
	GroupCalendar.MinimumEventDate = MCDateLib:GetLocalDate() - GroupCalendar.MaximumEventAge
	
	for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		GroupCalendar.Database.DeleteOldEvents(vDatabase)
	end
	
	GroupCalendar_MajorDatabaseChange(nil)
	return true
end

function GroupCalendar_UpdateAddonUsage()
	UpdateAddOnCPUUsage()
	UpdateAddOnMemoryUsage()
	
	local vMillisecondsUsed = GetAddOnCPUUsage("GroupCalendar")
	local vMilliseconds = GetScriptCPUUsage()
	local vTotalBytesUsed = GetAddOnMemoryUsage("GroupCalendar") * 1024
	
	if not GroupCalendar.Profile then
		GroupCalendar.Profile =
		{
			TotalMillisecondsUsed = 0,
			TotalMilliseconds = 0,
			TotalBytesUsed = vTotalBytesUsed,
		}
	end
	
	local vBytesUsed = vTotalBytesUsed - GroupCalendar.Profile.TotalBytesUsed
	local vPercentUsed = 0
	
	if vMilliseconds > 0 then
		vPercentUsed = 100 * vMillisecondsUsed / vMilliseconds
	end
	
	local vTotalPercentUsed = 0
	
	if GroupCalendar.Profile.TotalMilliseconds > 0 then
		vTotalPercentUsed = 100 * GroupCalendar.Profile.TotalMillisecondsUsed / GroupCalendar.Profile.TotalMilliseconds
	end
	
	GroupCalendar:DebugMessage(
			"CPU: %.1f%% Total CPU: %.1f%% Memory: %.2fKB Memory change: %.2fKB",
			vPercentUsed,
			vTotalPercentUsed,
			vTotalBytesUsed / 1024,
			vBytesUsed / 1024)
	
	GroupCalendar.Profile.TotalMillisecondsUsed = GroupCalendar.Profile.TotalMillisecondsUsed + vMillisecondsUsed
	GroupCalendar.Profile.TotalMilliseconds = GroupCalendar.Profile.TotalMilliseconds + vMilliseconds
	GroupCalendar.Profile.TotalBytesUsed = vTotalBytesUsed
end

function GroupCalendar.GetPlayerDefaultRole()
	if GroupCalendar.UserDatabase.DefaultRole then
		return GroupCalendar.UserDatabase.DefaultRole
	end
	
	-- Figure out which talent tree has the most points
	
	local vDominantTreeIndex
	local vDominantTreePoints
	
	for vIndex = 1, GetNumTalentTabs() do
		local _, _, vPoints = GetTalentTabInfo(vIndex)
		
		if not vDominantTreeIndex
		or vDominantTreePoints then
			vDominantTreeIndex = vIndex
			vDominantTreePoints = vPoints
		end
	end
	
	local vClassCode = GroupCalendar.Database.GetClassCodeByClassID(GroupCalendar.UnitClassID("player"))
	local vClassInfo = GroupCalendar.ClassInfoByClassCode[vClassCode]
	
	if vClassInfo.talentRoles[vDominantTreeIndex] then
		return vClassInfo.talentRoles[vDominantTreeIndex]
	else
		return vClassInfo.defaultRole
	end
end

function GroupCalendar.GetMemberDefaultRole(pUserName, pClassID)
	if pUserName == GroupCalendar.PlayerName then
		return GroupCalendar.GetPlayerDefaultRole()
	end
	
	local vDatabase = GroupCalendar.Database.GetDatabase(pUserName)
	
	if vDatabase and vDatabase.DefaultRole then
		return vDatabase.DefaultRole
	end
	
	local vMemberInfo = GroupCalendar.Network:GetGuildMemberInfo(pUserName)
	
	if vMemberInfo then
		local vClassCode = GroupCalendar.Database.GetClassCodeByClass(vMemberInfo.Class)
		
		if vClassCode then
			local vClassInfo = GroupCalendar.ClassInfoByClassCode[vClassCode]
			
			if vClassInfo then
				return vClassInfo.defaultRole
			end
		end
	end
	
	if pClassID then
		local vClassInfo = GroupCalendar.ClassInfoByClassCode[pClassID]
		
		if vClassInfo then
			return vClassInfo.defaultRole
		end
	end
end

function GroupCalendar:SetAltMail(pOption)
	if string.lower(pOption) == "on" then
		gGroupCalendar_Settings.EnableAltMail = true
		self:InstallAltMail()
	elseif string.lower(pOption) == "off" then
		gGroupCalendar_Settings.EnableAltMail = false
		self:UninstallAltMail()
	end
end

function GroupCalendar:InstallAltMail()
	if self.Orig_SendeeAutocomplete then
		return
	end
	
	self.Orig_SendeeAutocomplete = SendMailFrame_SendeeAutocomplete
	SendMailFrame_SendeeAutocomplete = GroupCalendar.SendeeAutocomplete
end

function GroupCalendar:UninstallAltMail()
	if not self.Orig_SendeeAutocomplete then
		return
	end
	
	SendMailFrame_SendeeAutocomplete = self.Orig_SendeeAutocomplete
	self.Orig_SendeeAutocomplete = nil
end

function GroupCalendar.SendeeAutocomplete(...)
	if GroupCalendar.AutoCompleteAlt(this) then
		return
	end
	
	return GroupCalendar.Orig_SendeeAutocomplete(unpack(arg))
end
