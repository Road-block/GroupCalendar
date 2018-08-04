----------------------------------------
-- _ClassLimitsDialog
----------------------------------------

GroupCalendar._ClassLimitsDialog = {}

GroupCalendar.CalendarClassLimitItemWidgets =
{
	"Background",
	"Label",
	"Separator",
	"Min",
	"Max",
}

GroupCalendar._ClassLimitsDialog.Widgets =
{
	"FrameHeader",
	"Title",
	"Description",
	"Priority",
	"PriorityValue",
	"MaxPartySize",
	MinPartySize = "MaxPartySizeMin",
	
	Priest = GroupCalendar.CalendarClassLimitItemWidgets,
	Druid = GroupCalendar.CalendarClassLimitItemWidgets,
	Paladin = GroupCalendar.CalendarClassLimitItemWidgets,
	Shaman = GroupCalendar.CalendarClassLimitItemWidgets,
	Warrior = GroupCalendar.CalendarClassLimitItemWidgets,
	Warlock = GroupCalendar.CalendarClassLimitItemWidgets,
	Mage = GroupCalendar.CalendarClassLimitItemWidgets,
	Rogue = GroupCalendar.CalendarClassLimitItemWidgets,
	Hunter = GroupCalendar.CalendarClassLimitItemWidgets,
}

function GroupCalendar._ClassLimitsDialog:Construct()
end

function GroupCalendar._ClassLimitsDialog:Open(pLimits, pTitle, pShowPriority, pSaveFunction)
	self.mSaveFunction = pSaveFunction
	self.Widgets.Title:SetText(pTitle)
	
	self:UpdateFields(pLimits)
	
	if pShowPriority then
		self.Widgets.Priority:Show()
	else
		self.Widgets.Priority:Hide()
	end
	
	self:Show()
end

function GroupCalendar._ClassLimitsDialog:Done()
	if self.mSaveFunction then
		self.mSaveFunction(self:GetLimits())
	end
	
	self:Hide()
end

function GroupCalendar._ClassLimitsDialog:Cancel()
	self:Hide()
end

function GroupCalendar._ClassLimitsDialog.SetClassName(pItem, pClassName)
	GroupCalendar.InitializeFrame(pItem, GroupCalendar.CalendarClassLimitItemWidgets)
	
	local vColor = RAID_CLASS_COLORS[getglobal("GroupCalendar_c"..pClassName.."ClassColorName")]
	
	pItem.Label:SetText(getglobal("GroupCalendar_c"..pClassName.."sLabel"))
	pItem.Label:SetTextColor(vColor.r, vColor.g, vColor.b)
	pItem.Background:SetTexture(vColor.r, vColor.g, vColor.b, 0.05)
	
	-- Make the dash between min and max the same color if it's present
	
	if pItem.Separator then
		pItem.Separator:SetTextColor(vColor.r, vColor.g, vColor.b)
	end
end

function GroupCalendar._ClassLimitsDialog:UpdateFields(pLimits)
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		local vClassLimit = nil
		
		if pLimits and pLimits.mClassLimits then
			vClassLimit = pLimits.mClassLimits[vClassCode]
		end
		
		local vMinValue, vMaxValue
		
		if vClassLimit and vClassLimit.mMin then
			vMinValue = vClassLimit.mMin
		else
			vMinValue = ""
		end
		
		if vClassLimit and vClassLimit.mMax then
			vMaxValue = vClassLimit.mMax
		else
			vMaxValue = ""
		end
		
		self.Widgets[vClassInfo.element].Min:SetText(vMinValue)
		self.Widgets[vClassInfo.element].Max:SetText(vMaxValue)
	end
	
	if pLimits and pLimits.mMaxAttendance then
		CalendarDropDown_SetSelectedValue(self.Widgets.MaxPartySize, pLimits.mMaxAttendance)
	else
		CalendarDropDown_SetSelectedValue(self.Widgets.MaxPartySize, 0)
	end

	if pLimits and pLimits.mPriorityOrder then
		CalendarDropDown_SetSelectedValue(self.Widgets.PriorityValue, pLimits.mPriorityOrder)
	else
		CalendarDropDown_SetSelectedValue(self.Widgets.PriorityValue, "Date")
	end
end

function GroupCalendar._ClassLimitsDialog:GetLimits()
	local vLimits = GroupCalendar.NewTable()
	
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		local vClassMin = tonumber(self.Widgets[vClassInfo.element].Min:GetText())
		local vClassMax = tonumber(self.Widgets[vClassInfo.element].Max:GetText())
		
		if vClassMin or vClassMax then
			if not vLimits.mClassLimits then
				vLimits.mClassLimits = {}
			end
			
			vLimits.mClassLimits[vClassCode] = {mMin = vClassMin, mMax = vClassMax}
		end
	end
	
	vLimits.mMaxAttendance = UIDropDownMenu_GetSelectedValue(self.Widgets.MaxPartySize)
	
	if vLimits.mMaxAttendance == 0 then
		vLimits.mMaxAttendance = nil
	end
	
	vLimits.mPriorityOrder = UIDropDownMenu_GetSelectedValue(self.Widgets.PriorityValue)
	
	if vLimits.mPriorityOrder == "Date" then
		vLimits.mPriorityOrder = nil
	end
	
	-- See if the mLimits field should just be removed altogether
	
	if GroupCalendar.ArrayIsEmpty(vLimits) then
		vLimits = GroupCalendar.DeleteTable(vLimits)
	end
	
	-- Done
	
	return vLimits
end

function GroupCalendar.LimitsAreEqual(pOldLimits, pNewLimits)
	if (pNewLimits == nil) ~= (pOldLimits == nil) then	
		return false
	end
	
	if not pNewLimits then
		return true
	end
	
	-- Not the same if max attendance changed
	
	if pNewLimits.mMaxAttendance ~= pOldLimits.mMaxAttendance then
		return false
	end
	
	-- Not the same if their limits modes don't match
	
	if ((pNewLimits.mClassLimits == nil) ~= (pOldLimits.mClassLimits == nil))
	or ((pNewLimits.mRoleLimits == nil) ~= (pOldLimits.mRoleLimits == nil)) then
		return false
	end
	
	if pNewLimits.mClassLimits then
		for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
			local vNewClassLimits = pNewLimits.mClassLimits[vClassCode]
			local vOldClassLimits = pOldLimits.mClassLimits[vClassCode]
			
			if (vNewClassLimits == nil) ~= (vOldClassLimits == nil) then
				return false
			end
			
			if vNewClassLimits then
				if vNewClassLimits.mMin ~= vOldClassLimits.mMin
				or vNewClassLimits.mMax ~= vOldClassLimits.mMax then
					return false
				end
			end
		end
	end
	
	if pNewLimits.mRoleLimits then
		for _, vRoleInfo in ipairs(GroupCalendar.Roles) do
			local vNewRoleLimits = pNewLimits.mRoleLimits[vRoleInfo.ID]
			local vOldRoleLimits = pOldLimits.mRoleLimits[vRoleInfo.ID]
			
			if (vNewRoleLimits == nil) ~= (vOldRoleLimits == nil) then
				return false
			end
			
			if vNewRoleLimits then
				if vNewRoleLimits.mMin ~= vOldRoleLimits.mMin
				or vNewRoleLimits.mMax ~= vOldRoleLimits.mMax
				or (vNewRoleLimits.mClass == nil) ~= (vOldRoleLimits.mClass == nil) then
					return false
				end
				
				if vNewRoleLimits.mClass then
					for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
						local vNewClassLimit = vNewRoleLimits.mClass[vClassInfo.color]
						local vOldClassLimit = vOldRoleLimits.mClass[vClassInfo.color]
						
						if vNewClassLimit ~= vOldClassLimit then
							return false
						end
					end
				end
			end
		end
	end
	
	-- Done, they're the same
	
	return true
end

function GroupCalendar._ClassLimitsDialog:FactionCheck()
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		if vClassInfo.faction then
			local vElement = self.Widgets[vClassInfo.element]
			if vClassInfo.faction == GroupCalendar.PlayerFactionGroup then
				vElement:Show()
			else
				vElement:Hide()
			end
		end		
	end
end

function GroupCalendar._ClassLimitsDialog:OnShow()
	self:FactionCheck()
	self:MinTotalChanged()
end

function GroupCalendar._ClassLimitsDialog:MinTotalChanged(pAutoConfirmFrame)
	local vMinTotal = nil
	
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		local vClassMin = tonumber(self.Widgets[vClassInfo.element].Min:GetText())
		
		if vClassMin then
			if not vMinTotal then
				vMinTotal = vClassMin
			else
				vMinTotal = vMinTotal + vClassMin
			end
		end
	end
	
	self.Widgets.MinPartySize:SetText(vMinTotal or GroupCalendar_cNoMinimum)
end

----------------------------------------
-- _RoleLimitsDialog
----------------------------------------

GroupCalendar._RoleLimitsDialog = {}

GroupCalendar.CalendarRoleClassLimitItemWidgets =
{
	"Background",
	"Background2",
	"Label",
	"Separator",
	"Min",
	"Max",
	
	PRIEST = {"Min", "MinLeft", "MinMiddle", "MinRight"},
	DRUID = {"Min", "MinLeft", "MinMiddle", "MinRight"},
	PALADIN = {"Min", "MinLeft", "MinMiddle", "MinRight"},
	SHAMAN = {"Min", "MinLeft", "MinMiddle", "MinRight"},
	MAGE = {"Min", "MinLeft", "MinMiddle", "MinRight"},
	HUNTER = {"Min", "MinLeft", "MinMiddle", "MinRight"},
	WARLOCK = {"Min", "MinLeft", "MinMiddle", "MinRight"},
	WARRIOR = {"Min", "MinLeft", "MinMiddle", "MinRight"},
	ROGUE = {"Min", "MinLeft", "MinMiddle", "MinRight"},
}

GroupCalendar._RoleLimitsDialog.Widgets =
{
	"FrameHeader",
	"Title",
	"Description",
	"Priority",
	"PriorityValue",
	"MaxPartySize",
	MinPartySize = "MaxPartySizeMin",
	"PRIESTLabel",
	"DRUIDLabel",
	"SHAMANLabel",
	"PALADINLabel",
	"WARLOCKLabel",
	"MAGELabel",
	"HUNTERLabel",
	"WARRIORLabel",
	"ROGUELabel",
	
	MH = GroupCalendar.CalendarRoleClassLimitItemWidgets,
	OH = GroupCalendar.CalendarRoleClassLimitItemWidgets,
	MT = GroupCalendar.CalendarRoleClassLimitItemWidgets,
	OT = GroupCalendar.CalendarRoleClassLimitItemWidgets,
	MD = GroupCalendar.CalendarRoleClassLimitItemWidgets,
	RD = GroupCalendar.CalendarRoleClassLimitItemWidgets,
}

function GroupCalendar._RoleLimitsDialog:Construct()
	-- Set the colors for each of the class limit column labels
	
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		local vLabelItem = self.Widgets[vClassInfo.color.."Label"]
		local vColor = RAID_CLASS_COLORS[vClassInfo.color]	

		if not vLabelItem then
			GroupCalendar:DebugMessage("Widget %s not found", vClassInfo.color)
			GroupCalendar:DebugTable("Widgets", self.Widgets)
			return
		end
		
		vLabelItem:SetTextColor(vColor.r, vColor.g, vColor.b)
	end
end

function GroupCalendar._RoleLimitsDialog:Open(pLimits, pTitle, pShowPriority, pSaveFunction)
	self.mShowPriority = pShowPriority
	self.mSaveFunction = pSaveFunction
	
	self.Widgets.Title:SetText(pTitle)
	self:UpdateFields(pLimits)

	if pShowPriority then
		self.Widgets.Priority:Show()
	else
		self.Widgets.Priority:Hide()
	end
	
	self:Show()
end

function GroupCalendar._RoleLimitsDialog:Done()
	if self.mSaveFunction then
		self.mSaveFunction(self:GetLimits())
	end
	
	self:Hide()
end

function GroupCalendar._RoleLimitsDialog:Cancel()
	self:Hide()
end

function GroupCalendar._RoleLimitsDialog.SetRoleName(pItem, pRoleID)
	GroupCalendar.InitializeFrame(pItem, GroupCalendar.CalendarRoleClassLimitItemWidgets)
	
	pItem.Label:SetText(getglobal("GroupCalendar_c"..pRoleID.."PluralLabel"))
	
	local vColor = RAID_CLASS_COLORS[GroupCalendar.cRoleColorName[pRoleID]]
	
	pItem.Label:SetTextColor(vColor.r, vColor.g, vColor.b)
	pItem.Separator:SetTextColor(vColor.r, vColor.g, vColor.b)
	pItem.Background:SetTexture(vColor.r, vColor.g, vColor.b, 0.07)
	pItem.Background2:SetTexture(vColor.r, vColor.g, vColor.b, 0.05)
	
	local vRoleInfo = GroupCalendar.RoleInfoByID[pRoleID]
	
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		local vClassItem = pItem[vClassInfo.color]
		local vColor = RAID_CLASS_COLORS[vClassInfo.color]
		
		if vRoleInfo.Classes[vClassCode] then
			vClassItem.MinLeft:SetVertexColor(vColor.r, vColor.g, vColor.b)
			vClassItem.MinMiddle:SetVertexColor(vColor.r, vColor.g, vColor.b)
			vClassItem.MinRight:SetVertexColor(vColor.r, vColor.g, vColor.b)
			
			vClassItem:Show()
		else
			vClassItem:Hide()
		end
	end
end

function GroupCalendar._RoleLimitsDialog:UpdateFields(pLimits)
	for _, vRoleInfo in ipairs(GroupCalendar.Roles) do
		local vRoleFrame = self.Widgets[vRoleInfo.ID]
		local vRoleLimits = nil
		
		if pLimits and pLimits.mRoleLimits then
			vRoleLimits = pLimits.mRoleLimits[vRoleInfo.ID]
		end
		
		local vMinValue, vMaxValue
		
		if vRoleLimits and vRoleLimits.mMin then
			vMinValue = vRoleLimits.mMin
		else
			vMinValue = ""
		end
		
		if vRoleLimits and vRoleLimits.mMax then
			vMaxValue = vRoleLimits.mMax
		else
			vMaxValue = ""
		end
		
		vRoleFrame.Min:SetText(vMinValue)
		vRoleFrame.Max:SetText(vMaxValue)
		
		for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
			local vValue
			
			if vRoleLimits and vRoleLimits.mClass and vRoleLimits.mClass[vClassInfo.color] then
				vValue = vRoleLimits.mClass[vClassInfo.color]
			else
				vValue = ""
			end
			
			vRoleFrame[vClassInfo.color].Min:SetText(vValue)
		end
	end
	
	if pLimits and pLimits.mMaxAttendance then
		CalendarDropDown_SetSelectedValue(self.Widgets.MaxPartySize, pLimits.mMaxAttendance)
	else
		CalendarDropDown_SetSelectedValue(self.Widgets.MaxPartySize, 0)
	end

	if pLimits and pLimits.mPriorityOrder then
		CalendarDropDown_SetSelectedValue(self.Widgets.PriorityValue, pLimits.mPriorityOrder)
	else
		CalendarDropDown_SetSelectedValue(self.Widgets.PriorityValue, "Date")
	end
end

function GroupCalendar._RoleLimitsDialog:GetLimits()
	local vLimits = GroupCalendar.NewTable()
	
	for _, vRoleInfo in ipairs(GroupCalendar.Roles) do
		local vRoleFrame = self.Widgets[vRoleInfo.ID]
		
		local vRoleMin = tonumber(vRoleFrame.Min:GetText())
		local vRoleMax = tonumber(vRoleFrame.Max:GetText())
		
		if vRoleMin or vRoleMax then
			local vRoleLimits = GroupCalendar.NewTable()
			
			vRoleLimits.mMin = vRoleMin
			vRoleLimits.mMax = vRoleMax
			
			for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
				local vValue
				
				if vRoleLimits and vRoleLimits.mClass and vRoleLimits.mClass[vClassInfo.color] then
					vValue = vRoleLimits.mClass[vClassInfo.color]
				else
					vValue = ""
				end
				
				local vClassMin = tonumber(vRoleFrame[vClassInfo.color].Min:GetText())
				
				if vClassMin then
					if not vRoleLimits.mClass then
						vRoleLimits.mClass = GroupCalendar.NewTable()
					end
					
					vRoleLimits.mClass[vClassInfo.color] = vClassMin
				end
			end
			
			if not vLimits.mRoleLimits then
				vLimits.mRoleLimits = GroupCalendar.NewTable()
			end
			
			vLimits.mRoleLimits[vRoleInfo.ID] = vRoleLimits
		end
	end
	
	vLimits.mMaxAttendance = UIDropDownMenu_GetSelectedValue(self.Widgets.MaxPartySize)
	
	if vLimits.mMaxAttendance == 0 then
		vLimits.mMaxAttendance = nil
	end
	
	vLimits.mPriorityOrder = UIDropDownMenu_GetSelectedValue(self.Widgets.PriorityValue)
	
	if vLimits.mPriorityOrder == "Date" then
		vLimits.mPriorityOrder = nil
	end
	
	-- See if the mLimits field should just be removed altogether
	
	if GroupCalendar.ArrayIsEmpty(vLimits) then
		vLimits = GroupCalendar.DeleteTable(vLimits)
	end
	
	-- Done
	
	return vLimits
end

function GroupCalendar._RoleLimitsDialog:FactionCheck()
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		if vClassInfo.faction then
			local vLabelItem = self.Widgets[vClassInfo.color.."Label"]
			if vClassInfo.faction == GroupCalendar.PlayerFactionGroup then
				vLabelItem:Show()
				for _, roleID in ipairs(vClassInfo.roles) do
					local vClassItem = self.Widgets[roleID][vClassInfo.color].Min
					vClassItem:Show()
				end
			else
				vLabelItem:Hide()
				for _, roleID in ipairs(vClassInfo.roles) do
					local vClassItem = self.Widgets[roleID][vClassInfo.color].Min
					vClassItem:Hide()
				end
			end
		end	
	end
end

function GroupCalendar._RoleLimitsDialog:OnShow()
	self:FactionCheck()
	self:MinTotalChanged()
end

function GroupCalendar._RoleLimitsDialog:MinTotalChanged()
	local vMinTotal = nil
	
	for _, vRoleInfo in ipairs(GroupCalendar.Roles) do
		local vRoleFrame = self.Widgets[vRoleInfo.ID]
		
		local vClassMin = tonumber(vRoleFrame.Min:GetText())
		
		if vClassMin then
			if not vMinTotal then
				vMinTotal = vClassMin
			else
				vMinTotal = vMinTotal + vClassMin
			end
		end
	end
	
	self.Widgets.MinPartySize:SetText(vMinTotal or GroupCalendar_cNoMinimum)
end

----------------------------------------
-- _AvailableSlots
----------------------------------------

GroupCalendar._AvailableSlots = {}

function GroupCalendar._AvailableSlots:Construct(pLimits, pLimitMode)
	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugMessage("_AvailableSlots:Construct: LimitMode=%s", pLimitMode or "nil")
		GroupCalendar:DebugTable("    pLimits", pLimits)
	end
	
	self.Limits = pLimits
	self.LimitMode = pLimitMode
	
	if pLimits then
		self.SlotLimits = tern(pLimitMode == "ROLE", pLimits.mRoleLimits, pLimits.mClassLimits)
	end
	
	self.SlotTotals = {}
	
	local vMinTotal = 0
	
	if self.SlotLimits then
		for vSlotID, vSlotLimit in pairs(self.SlotLimits) do
			local vSlotTotal = {}
			
			-- Set the class minimums and total them up
			
			local vTotalClassMin = 0
			
			if vSlotLimit.mClass then
				vSlotTotal.ClassMin = {}
				
				for vClassID, vClassMin in pairs(vSlotLimit.mClass) do
					vSlotTotal.ClassMin[vClassID] = vClassMin
					vTotalClassMin = vTotalClassMin + vClassMin
				end
			end
			
			-- The number of "general" slots for the category can't
			-- include the sub-category slots (class), so subtract
			-- those out
			
			if vSlotLimit.mMin then
				vSlotTotal.Available = vSlotLimit.mMin - vTotalClassMin -- Subtract the specialized mins from the general min
			else
				vSlotTotal.Available = 0
			end
			
			if vSlotTotal.Available < 0 then
				vSlotTotal.Available = 0
			end
			
			local vSlotMinTotal = vTotalClassMin + vSlotTotal.Available
			
			-- Make sure the max is at least the min
			
			if vSlotLimit.mMax and vSlotLimit.mMax < vSlotMinTotal then
				vSlotLimit.mMax = vSlotMinTotal
			end
			
			-- Calculate the available extra slots as max - min
			
			vSlotTotal.Extras = tern(vSlotLimit.mMax, vSlotLimit.mMax, pLimits.mMaxAttendance) - vSlotMinTotal
			
			if vSlotTotal.Extras < 0 then
				vSlotTotal.Extras = 0
			end
			
			-- Done with this slot
			
			vMinTotal = vMinTotal + vSlotMinTotal
			
			self.SlotTotals[vSlotID] = vSlotTotal
		end -- for vSlotID
	end
	
	if pLimits and pLimits.mMaxAttendance then
		self.TotalExtras = pLimits.mMaxAttendance - vMinTotal
		
		if self.TotalExtras < 0 then
			self.TotalExtras = 0
		end
	else
		self.TotalExtras = nil
	end
	
	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugTable("self", self)
		GroupCalendar:DebugMark()
	end
end

function GroupCalendar._AvailableSlots:AddEventAttendance(pDatabase, pEvent, pIgnorePlayerName)
	local vAttendanceList = CalendarEvent_GetAttendanceList(pDatabase, pEvent, self.LimitMode)
	
	for vCategoryID, vAttendanceInfo in pairs(vAttendanceList.Categories) do
		if vCategoryID ~= "NO"
		and vCategoryID ~= "STANDBY"
		and vCategoryID ~= "MAYBE"
		and vCategoryID ~= "BANNED" then
			for _, vAttendeeInfo in ipairs(vAttendanceInfo.mAttendees) do
				if vAttendeeInfo.mName ~= pIgnorePlayerName then
					self:AddPlayer(vAttendeeInfo.mClassCode, vAttendeeInfo.mRole)
				end
			end
		end
	end
end

function GroupCalendar._AvailableSlots:AddPlayer(pClassCode, pRole)
	local vSlotCode = tern(self.LimitMode == "ROLE", pRole, pClassCode)
	local vSlotTotal = self.SlotTotals[vSlotCode]
	
	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugMessage("_AvailableSlots:AddPlayer(%s, %s)", pClassCode or "nil", pRole or "nil")
		GroupCalendar:DebugStack()
	end
	
	if not vSlotTotal then
		if GroupCalendar.Debug.AutoConfirm then
			GroupCalendar:DebugMessage("    Rejecting player because no slot totals available for %s", vSlotCode)
		end
		
		return false
	end
	
	-- Try to fill a class-specific slot first
	
	if vSlotTotal.ClassMin then
		local vClassID = GroupCalendar.ClassInfoByClassCode[pClassCode].classID
		local vClassMin = vSlotTotal.ClassMin[vClassID]
		
		if vClassMin and vClassMin > 0 then
			vSlotTotal.ClassMin[vClassID] = vClassMin - 1
			
			if GroupCalendar.Debug.AutoConfirm then
				GroupCalendar:DebugMessage("    Accepted player in slot %s using reserved class %s space", vSlotCode, pClassCode)
			end
			
			return true
		end
	end
	
	-- Try to fill general slot
	
	if vSlotTotal.Available > 0 then
		vSlotTotal.Available = vSlotTotal.Available - 1
		
		if GroupCalendar.Debug.AutoConfirm then
			GroupCalendar:DebugMessage("    Accepted player in slot %s using reserved category space", vSlotCode)
		end
		
		return true
	end
	
	-- If there are no extra (floating) slots then they can't get in
	
	if self.TotalExtras and self.TotalExtras <= 0 then
		if GroupCalendar.Debug.AutoConfirm then
			GroupCalendar:DebugMessage("    Rejecting player because all extra slots are taken")
		end
		
		return false
	end
	
	-- Make sure there's space in their category
	
	if vSlotTotal.Extras and vSlotTotal.Extras <= 0 then
		if GroupCalendar.Debug.AutoConfirm then
			GroupCalendar:DebugMessage("    Rejecting player because all category extra slots are taken")
			GroupCalendar:DebugTable("    vSlotTotal", vSlotTotal)
		end
		
		return false
	end
	
	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugMessage("    Accepting player as an extra for slot %s", vSlotCode)
		GroupCalendar:DebugTable("        vSlotTotal", vSlotTotal)
	end
	
	if self.TotalExtras then
		self.TotalExtras = self.TotalExtras - 1
	end
	
	if vSlotTotal.Extras then
		vSlotTotal.Extras = vSlotTotal.Extras - 1
	end
	
	return true
end
