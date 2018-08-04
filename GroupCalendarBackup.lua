----------------------------------------
-- Dialogs
----------------------------------------

StaticPopupDialogs.CALENDAR_CONFIRM_DELETE_BACKUP =
{
	text = TEXT(GroupCalendar.cConfirmDeleteBackup),
	button1 = TEXT(CalendarEventEditor_cDelete),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar.Backup:DeleteBackup(StaticPopupDialogs.CALENDAR_CONFIRM_DELETE_BACKUP.PlayerName, StaticPopupDialogs.CALENDAR_CONFIRM_DELETE_BACKUP.Backup) end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

StaticPopupDialogs.CALENDAR_CONFIRM_RESTORE_BACKUP =
{
	text = TEXT(GroupCalendar.cConfirmRestoreBackup),
	button1 = TEXT(GroupCalendar.cRestoreBackup),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar.Backup:RestoreBackup(StaticPopupDialogs.CALENDAR_CONFIRM_RESTORE_BACKUP.PlayerName, StaticPopupDialogs.CALENDAR_CONFIRM_RESTORE_BACKUP.Backup) end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

StaticPopupDialogs.CALENDAR_CONFIRM_BACKUP_SUCCESS =
{
	text = TEXT(GroupCalendar.cBackupRestored),
	button1 = TEXT(OKAY),
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

----------------------------------------
GroupCalendar._Backup = {}
----------------------------------------

function GroupCalendar._Backup:BackupNow(pPlayerName)
	local vDatabase = GroupCalendar.Database.GetDatabase(pPlayerName)
	
	if not vDatabase then
		GroupCalendar:ErrorMessage("No database found for %s", pPlayerName)
		return
	end
	
	local vBackups = GroupCalendar.Database.GetBackups(pPlayerName)
	local vBackup = {}
	
	vBackup.DateTimeStamp = MCDateLib:GetLocalDateTimeStamp()
	vBackup.Database = GroupCalendar.DuplicateTable(vDatabase, true)
	
	table.insert(vBackups, vBackup)
	
	while table.getn(vBackups) > GroupCalendar.MaximumBackups do
		table.remove(vBackups, 1)
	end
	
	MCEventLib:DispatchEvent("GC_BACKUPS_CHANGED", pPlayerName)
end

function GroupCalendar._Backup:DeleteBackup(pPlayerName, pBackup)
	local vDatabase = GroupCalendar.Database.GetDatabase(pPlayerName)
	
	if not vDatabase then
		GroupCalendar:ErrorMessage("No database found for %s", pPlayerName)
		return
	end
	
	local vBackups = GroupCalendar.Database.GetBackups(pPlayerName)
	
	for vIndex, vBackup in ipairs(vBackups) do
		if vBackup == pBackup then
			table.remove(vBackups, vIndex)
			MCEventLib:DispatchEvent("GC_BACKUPS_CHANGED", pPlayerName)
			return
		end
	end
end

function GroupCalendar._Backup:RestoreBackup(pPlayerName, pBackup)
	local vDatabase = GroupCalendar.Database.GetDatabase(pPlayerName)
	
	if not vDatabase then
		GroupCalendar:ErrorMessage("No database found for %s", pPlayerName)
		return
	end
	
	GroupCalendar.DuplicateTable(pBackup.Database, true, vDatabase)
	
	GroupCalendar.Database.RebuildDatabase(vDatabase)
	GroupCalendar.Database.RebuildRSVPs(vDatabase)

	GroupCalendar_MajorDatabaseChange(vDatabase)
	
	StaticPopup_Show("CALENDAR_CONFIRM_BACKUP_SUCCESS")
end

----------------------------------------
GroupCalendar._BackupUI = {}
----------------------------------------

GroupCalendar._BackupUI.Widgets =
{
	"NoBackups",
	"CharacterMenu",
	"BackupNow",
	["Backup[]"] = {"Delete", "Restore", "TitleText"},
}

function GroupCalendar._BackupUI:Construct()
	self:SetScript("OnShow", function () this:OnShow() end)
	self:SetScript("OnHide", function () this:OnHide() end)
	
	self.Widgets.CharacterMenu.ChangedValueFunc = function (pMenuFrame, pValue) self:SetBackupInfo(pValue) end
end

function GroupCalendar._BackupUI:OnShow()
	MCEventLib:RegisterEvent("GC_BACKUPS_CHANGED", self.BackupsChanged, self, true)
	
	self:SetBackupInfo(GroupCalendar.PlayerName)
end

function GroupCalendar._BackupUI:OnHide()
	MCEventLib:UnregisterEvent("GC_BACKUPS_CHANGED", self.BackupsChanged, self)
end

function GroupCalendar._BackupUI:BackupsChanged(pPlayerName)
	GroupCalendar:TestMessage("BackupsChanged: %s", pPlayerName or "nil")
	
	if pPlayerName ~= self.PlayerName then
		GroupCalendar:TestMessage("   Not the selected player")
		return
	end
	
	self:SetBackupInfo(self.PlayerName)
end

function GroupCalendar._BackupUI:SetBackupInfo(pPlayerName)
	self.PlayerName = pPlayerName
	self.Database = GroupCalendar.Database.GetDatabase(pPlayerName)
	self.Backups = GroupCalendar.Database.GetBackups(pPlayerName)
	
	CalendarDropDown_SetSelectedValue(self.Widgets.CharacterMenu, pPlayerName)
	
	if not self.Backups or table.getn(self.Backups) == 0 then
		self.Widgets.NoBackups:Show()
		
		for vIndex, _ in ipairs(self.Widgets.Backup) do
			self:SetBackupItem(vIndex, nil)
		end
	else
		self.Widgets.NoBackups:Hide()
		
		for vIndex, _ in ipairs(self.Widgets.Backup) do
			self:SetBackupItem(vIndex, self.Backups[vIndex])
		end
	end
end

function GroupCalendar._BackupUI:GetBackupDateString(pBackup)
	local vDate, vTime = MCDateLib:GetDateTimeFromTimeStamp(pBackup.DateTimeStamp)
	return GroupCalendar.GetLongDateString(vDate).." "..GroupCalendar.GetShortTimeString(vTime)
end

function GroupCalendar._BackupUI:SetBackupItem(pIndex, pBackup)
	local vItem = self.Widgets.Backup[pIndex]
	
	if not pBackup then
		vItem.Backup = nil
		vItem:Hide()
	else
		vItem.Backup = pBackup
		local vDate, vTime = MCDateLib:GetDateTimeFromTimeStamp(pBackup.DateTimeStamp)
		vItem.TitleText:SetText(self:GetBackupDateString(pBackup))
		vItem:Show()
	end
end

function GroupCalendar._BackupUI:AskDeleteBackup(pBackup)
	StaticPopupDialogs.CALENDAR_CONFIRM_DELETE_BACKUP.PlayerName = self.PlayerName
	StaticPopupDialogs.CALENDAR_CONFIRM_DELETE_BACKUP.Backup = pBackup
	
	StaticPopup_Show("CALENDAR_CONFIRM_DELETE_BACKUP", self:GetBackupDateString(pBackup))
end

function GroupCalendar._BackupUI:AskRestoreBackup(pBackup)
	StaticPopupDialogs.CALENDAR_CONFIRM_RESTORE_BACKUP.PlayerName = self.PlayerName
	StaticPopupDialogs.CALENDAR_CONFIRM_RESTORE_BACKUP.Backup = pBackup
	
	StaticPopup_Show("CALENDAR_CONFIRM_RESTORE_BACKUP", self:GetBackupDateString(pBackup))
end
