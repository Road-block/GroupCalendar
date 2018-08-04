GroupCalendar.CoolDowns_cCooldownItemInfo =
{
	[15846] = {EventID = "Leatherworking"}, -- Salt Shaker
	[17716] = {EventID = "Snowmaster"}, -- Snowmaster 9000
}

function GroupCalendar.Cooldowns_ScheduleCheckItems()
	MCSchedulerLib:ScheduleUniqueTask(0.5, GroupCalendar.Cooldowns_CheckItems)
end

function GroupCalendar.Cooldowns_CheckItems()
	for vBagIndex = 0, NUM_BAG_SLOTS do
		local vNumBagSlots = GetContainerNumSlots(vBagIndex)
		
		for vBagSlotIndex = 1, vNumBagSlots do
			local vStart, vDuration, vEnable = GetContainerItemCooldown(vBagIndex, vBagSlotIndex)
			
			if vStart > 0 and vDuration > 0 and vEnable > 0 then
				GroupCalendar.Cooldowns_CheckItem(vBagIndex, vBagSlotIndex, vStart, vDuration)
			end
		end -- for vBagSlotIndex
	end -- for vBagIndex
end

function GroupCalendar.Cooldowns_CheckItem(pBagIndex, pBagSlotIndex, pStart, pDuration)
	local vItemLink = GetContainerItemLink(pBagIndex, pBagSlotIndex)

	if not vItemLink then
		return
	end
	
	local vStartIndex,
			vEndIndex,
			vLinkColor,
			vItemCode,
			vItemEnchantCode,
			vItemSuffixCode,
			vItemUniqueCode,
			vItemName = strfind(vItemLink, GroupCalendar_cItemLinkFormat)
	
	if not vStartIndex then
		return
	end
	
	vItemCode = tonumber(vItemCode)
	
	local vCooldownItemInfo = GroupCalendar.CoolDowns_cCooldownItemInfo[vItemCode]
	
	if not vCooldownItemInfo then
		return
	end
	
	vRemainingTime = pDuration - (GetTime() - pStart)
	
	if vRemainingTime <= 0 then
		return
	end
	
	if vRemainingTime > MCDateLib.cSecondsPerDay * 7 then
		-- GroupCalendar:ErrorMessage("Internal error: Cooldown is greater than 7 days for %s.  Please report this problem.", vItemName)
		return
	end
	
	GroupCalendar.Database.ScheduleTradeskillCooldownEvent(GroupCalendar.UserDatabase, vCooldownItemInfo.EventID, vRemainingTime)
end
