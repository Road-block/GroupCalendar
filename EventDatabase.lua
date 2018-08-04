GroupCalendar.Database = {}

GroupCalendar.Database.cFormat = 19

gGroupCalendar_Database =
{
	Format = GroupCalendar.Database.cFormat,
	Databases = {},
}

GroupCalendar.UserDatabase = nil

GroupCalendar.MaximumEventAge = 14
GroupCalendar.MinimumEventDate = nil

GroupCalendar.MaximumBackups = 8

GroupCalendar.PlayerCharacters = {}

GroupCalendar.Limits40 =
{
	mClassLimits =
	{
		P = {mMin = 4, mMax = 6},
		R = {mMin = 4, mMax = 6},
		D = {mMin = 4, mMax = 6},
		W = {mMin = 4, mMax = 6},
		H = {mMin = 4, mMax = 6},
		K = {mMin = 4, mMax = 6},
		M = {mMin = 4, mMax = 6},
		L = {mMin = 4, mMax = 6},
		S = {mMin = 4, mMax = 6},
	},
	
	mRoleLimits =
	{
		MH = {mMin = 6, mMax = 12},
		OH = {mMin = 0, mMax = 3},
		MT = {mMin = 3, mMax = 8},
		OT = {mMin = 0, mMax = 2},
		RD = {mMin = 0, mMax = 27},
		MD = {mMin = 0, mMax = 27},
	},
	
	mMaxAttendance = 40,
}

GroupCalendar.Limits25 =
{
	mClassLimits =
	{
		P = {mMin = 2, mMax = 4},
		R = {mMin = 2, mMax = 4},
		D = {mMin = 2, mMax = 4},
		W = {mMin = 2, mMax = 4},
		H = {mMin = 2, mMax = 4},
		K = {mMin = 2, mMax = 4},
		M = {mMin = 2, mMax = 4},
		L = {mMin = 2, mMax = 4},
		S = {mMin = 2, mMax = 4},
	},
	
	mRoleLimits =
	{
		MH = {mMin = 4, mMax = 7},
		OH = {mMin = 0, mMax = 2},
		MT = {mMin = 2, mMax = 4},
		OT = {mMin = 0, mMax = 1},
		RD = {mMin = 0, mMax = 15},
		MD = {mMin = 0, mMax = 15},
	},
	
	mMaxAttendance = 25,
}

GroupCalendar.Limits20 =
{
	mClassLimits =
	{
		P = {mMin = 2, mMax = 3},
		R = {mMin = 2, mMax = 3},
		D = {mMin = 2, mMax = 3},
		W = {mMin = 2, mMax = 3},
		H = {mMin = 2, mMax = 3},
		K = {mMin = 2, mMax = 3},
		M = {mMin = 2, mMax = 3},
		L = {mMin = 2, mMax = 3},
		S = {mMin = 2, mMax = 3},
	},
	
	mRoleLimits =
	{
		MH = {mMin = 3, mMax = 6},
		OH = {mMin = 0, mMax = 1},
		MT = {mMin = 2, mMax = 4},
		OT = {mMin = 0, mMax = 1},
		RD = {mMin = 0, mMax = 14},
		MD = {mMin = 0, mMax = 14},
	},
	
	mMaxAttendance = 20,
}

GroupCalendar.Limits15 =
{
	mClassLimits =
	{
		P = {mMin = 1, mMax = 3},
		R = {mMin = 1, mMax = 3},
		D = {mMin = 1, mMax = 3},
		W = {mMin = 1, mMax = 3},
		H = {mMin = 1, mMax = 3},
		K = {mMin = 1, mMax = 3},
		M = {mMin = 1, mMax = 3},
		L = {mMin = 1, mMax = 3},
		S = {mMin = 1, mMax = 3},
	},
	
	mRoleLimits =
	{
		MH = {mMin = 2, mMax = 4},
		OH = {mMin = 0, mMax = 1},
		MT = {mMin = 1, mMax = 3},
		OT = {mMin = 0, mMax = 1},
		RD = {mMin = 0, mMax = 13},
		MD = {mMin = 0, mMax = 13},
	},
	
	mMaxAttendance = 15,
}

GroupCalendar.Limits10 =
{
	mClassLimits =
	{
		P = {mMin = 1, mMax = 2},
		R = {mMin = 1, mMax = 2},
		D = {mMin = 1, mMax = 2},
		W = {mMin = 1, mMax = 2},
		H = {mMin = 1, mMax = 2},
		K = {mMin = 1, mMax = 2},
		M = {mMin = 1, mMax = 2},
		L = {mMin = 1, mMax = 2},
		S = {mMin = 1, mMax = 2},
	},
	
	mRoleLimits =
	{
		MH = {mMin = 1, mMax = 3},
		OH = {mMin = 0, mMax = 1},
		MT = {mMin = 1, mMax = 2},
		OT = {mMin = 0, mMax = 1},
		RD = {mMin = 0, mMax = 7},
		MD = {mMin = 0, mMax = 7},
	},
	
	mMaxAttendance = 10,
}

GroupCalendar.Limits5 =
{
	mClassLimits =
	{
		P = {mMax = 1},
		R = {mMax = 1},
		D = {mMax = 1},
		W = {mMax = 1},
		H = {mMax = 1},
		K = {mMax = 1},
		M = {mMax = 1},
		L = {mMax = 1},
		S = {mMax = 1},
	},
	
	mRoleLimits =
	{
		MH = {mMax = 1},
		OH = {mMax = 1},
		MT = {mMax = 1},
		OT = {mMax = 1},
		RD = {mMax = 1},
		MD = {mMax = 1},
	},
	
	mMaxAttendance = 5,
}

GroupCalendar.EventInfoByID =
{
	Birth = {name = GroupCalendar_cBirthdayEventName, allDay = true, noAttendance = true, notQuesting = true},
	Doctor = {name = GroupCalendar_cDoctorEventName, noAttendance = true, notQuesting = true, isPrivate = true},
	Dentist = {name = GroupCalendar_cDentistEventName, noAttendance = true, notQuesting = true, isPrivate = true},
	Vacation = {name = GroupCalendar_cVacationEventName, allDay = true, noAttendance = true, notQuesting = true, isPrivate = true},
	Meet = {name = GroupCalendar_cMeetingEventName, notQuesting = true},
	Other = {name = GroupCalendar_cOtherEventName, allDay = false, noAttendance = true, notQuesting = true, isPrivate = true},
	Holiday = {name = GroupCalendar_cHolidayEventName, allDay = true, noAttendance = true, notQuesting = true},
}

GroupCalendar.EventTypes =
{
	General =
	{
		Title = GroupCalendar_cGeneralEventGroup,
		MenuHint = "FLAT",
		Events =
		{
			{id="Meet", name=GroupCalendar_cMeetingEventName},
			{id="Birth", name=GroupCalendar_cBirthdayEventName},
			{id="RP", name=GroupCalendar_cRoleplayEventName},
			{id="Holiday", name=GroupCalendar_cHolidayEventName},
		},
	},
	
	Personal =
	{
		Title = GroupCalendar_cPersonalEventGroup,
		MenuHint = "FLAT",
		Events =
		{
			{id="Dentist", name=GroupCalendar_cDentistEventName},
			{id="Doctor", name=GroupCalendar_cDoctorEventName},
			{id="Vacation", name=GroupCalendar_cVacationEventName},
			{id="Other", name=GroupCalendar_cOtherEventName},
		},
	},
	
	Raid =
	{
		Title = GroupCalendar_cRaidEventGroup,
		MenuHint = "FLAT",
		Events =
		{
			{id="AQT",          name = GroupCalendar_cAQTEventName,             limits = GroupCalendar.Limits40, minLevel = 60},
			{id="AQR",       name = GroupCalendar_cAQREventName,       limits = GroupCalendar.Limits20, minLevel = 60},
			{id="BWL",          name = GroupCalendar_cBWLEventName,             limits = GroupCalendar.Limits40, minLevel = 60},
			{id="MC",           name = GroupCalendar_cMCEventName,              limits = GroupCalendar.Limits40, minLevel = 60},
			{id="Onyxia",       name = GroupCalendar_cOnyxiaEventName,          limits = GroupCalendar.Limits40, minLevel = 60},
			{id="ZG",        name = GroupCalendar_cZGEventName,        limits = GroupCalendar.Limits20, minLevel = 60},
			{id="UBRS",      name = GroupCalendar_cUBRSEventName,      limits = GroupCalendar.Limits15, minLevel = 55},
			{id="Naxx",      name = GroupCalendar_cNaxxEventName,      limits = GroupCalendar.Limits40, minLevel = 60},
		}
	},
	
	Dungeon =
	{
		Title = GroupCalendar_cDungeonEventGroup,
		MenuHint = "FLAT",
		Events =
		{
			{id="Scholo",    name = GroupCalendar_cScholoEventName,         limits = GroupCalendar.Limits5},
			{id="DM",        name = GroupCalendar_cDMEventName,             limits = GroupCalendar.Limits5},
			{id="Strath",    name = GroupCalendar_cStrathEventName,         limits = GroupCalendar.Limits5},
			{id="LBRS",      name = GroupCalendar_cLBRSEventName,           limits = GroupCalendar.Limits5},
			{id="BRD",       name = GroupCalendar_cBRDEventName,            limits = GroupCalendar.Limits5},
			{id="ST",        name = GroupCalendar_cSTEventName,             limits = GroupCalendar.Limits5},
			{id="ZF",        name = GroupCalendar_cZFEventName,             limits = GroupCalendar.Limits5},
			{id="Mara",      name = GroupCalendar_cMaraEventName,           limits = GroupCalendar.Limits5},
			{id="Uld",       name = GroupCalendar_cUldEventName,            limits = GroupCalendar.Limits5},
			{id="RFD",       name = GroupCalendar_cRFDEventName,            limits = GroupCalendar.Limits5},
			{id="SM",        name = GroupCalendar_cSMEventName,             limits = GroupCalendar.Limits5},
			{id="RFK",       name = GroupCalendar_cRFKEventName,            limits = GroupCalendar.Limits5},
			{id="Gnomer",    name = GroupCalendar_cGnomerEventName,         limits = GroupCalendar.Limits5},
			{id="BFD",       name = GroupCalendar_cBFDEventName,            limits = GroupCalendar.Limits5},
			{id="Stockades", name = GroupCalendar_cStockadesEventName,      limits = GroupCalendar.Limits5},
			{id="SFK",       name = GroupCalendar_cSFKEventName,            limits = GroupCalendar.Limits5},
			{id="WC",        name = GroupCalendar_cWCEventName,             limits = GroupCalendar.Limits5},
			{id="Deadmines", name = GroupCalendar_cDeadminesEventName,      limits = GroupCalendar.Limits5},
			{id="RFC",       name = GroupCalendar_cRFCEventName,            limits = GroupCalendar.Limits5},
		},
	},
    
	OutdoorRaids = 
	{
		Title = GroupCalendar_cOutdoorRaidEventGroup,
		MenuHint = "Flat",
		Events =
		{
			{id="Kazzak", name=GroupCalendar_cLordKazzakEventName},
			{id="Azuregos", name=GroupCalendar_cAzuregosEventName},
			{id="4Dragons", name=GroupCalendar_c4DragonsEventName},
		},
	},
	
	Battleground =
	{
		Title = GroupCalendar_cBattlegroundEventGroup,
		MenuHint = "HIER",
		Events =
		{
			{id="PvP",       name=GroupCalendar_cPvPEventName},
			{id="AV",        name=GroupCalendar_cAVEventName},
			{id="AB",        name=GroupCalendar_cABEventName},
			{id="WSG",       name=GroupCalendar_cWSGEventName},
		},
	},
	
	Reset =
	{
		Title = nil,
		Events =
		{
			{id="RSOny", name=GroupCalendar_cOnyxiaResetEventName}, -- Onyxia reset
			{id="RSMC", name=GroupCalendar_cMCResetEventName}, -- MC reset
			{id="RSBWL", name=GroupCalendar_cBWLResetEventName}, -- BWL reset
			{id="RSZG", name=GroupCalendar_cZGResetEventName}, -- ZG reset
			{id="RSAQT", name=GroupCalendar_cAQTResetEventName}, -- AQT reset
			{id="RSAQR", name=GroupCalendar_cAQRResetEventName}, -- AQR reset
			{id="RSNaxx", name=GroupCalendar_cNaxxResetEventName}, -- Naxxramas reset
			{id="RSXmut", name=GroupCalendar_cTransmuteCooldownEventName}, -- Transmute
			{id="RSSalt", name=GroupCalendar_cSaltShakerCooldownEventName}, -- Salt shaker
			{id="RSSnow", name=GroupCalendar_cSnowmasterCooldownEventName}, -- Snowmaster 9000
			{id="RSMoon", name=GroupCalendar_cMoonclothCooldownEventName}, -- Mooncloth
		},
		
		ResetEventInfo =
		{
			RSZG = {eventID="ZG", left = 0.0, top = 0.25, right = 0.25, bottom = 0.5, isDungeon = true, name=GroupCalendar_cRaidInfoZGName, largeIcon="ZG", frequency=3},
			RSOny = {eventID = "Onyxia", left = 0.25, top = 0.25, right = 0.5, bottom = 0.5, isDungeon = true, name=GroupCalendar_cRaidInfoOnyxiaName, largeIcon="Onyxia", frequency=5},
			RSMC = {eventID = "MC", left = 0.5, top = 0.25, right = 0.75, bottom = 0.5, isDungeon = true, name=GroupCalendar_cRaidInfoMCName, largeIcon="MC", frequency=7},
			RSBWL = {eventID = "BWL", left = 0.75, top = 0.25, right = 1.0, bottom = 0.5, isDungeon = true, name=GroupCalendar_cRaidInfoBWLName, largeIcon="BWL", frequency=7},
			RSAQT = {eventID = "AQT", left = 0.0, top = 0.5, right = 0.25, bottom = 0.75, isDungeon = true, name=GroupCalendar_cRaidInfoAQTName, largeIcon="AQT", frequency=7},
			RSAQR = {eventID = "AQR", left = 0.25, top = 0.5, right = 0.5, bottom = 0.75, isDungeon = true, name=GroupCalendar_cRaidInfoAQRName, largeIcon="AQR", frequency=3},
			RSNaxx = {eventID = "Naxx", left = 0.5, top = 0.5, right = 0.75, bottom = 0.75, isDungeon = true, name=GroupCalendar_cRaidInfoNaxxName, largeIcon="Naxx", frequency=7},
			RSXmut = {left = 0.50, top = 0, right = 0.75, bottom = 0.25, isTradeskill = true, id="Alchemy", largeSysIcon="Interface\\Icons\\Trade_Alchemy"},
			RSSalt = {left = 0.25, top = 0, right = 0.5, bottom = 0.25, isTradeskill = true, id="Leatherworking", largeSysIcon="Interface\\Icons\\Trade_Leatherworking"},
			RSSnow = {left = 0.75, top = 0, right = 1.0, bottom = 0.25, isTradeskill = true, id="Snowmaster", largeSysIcon="Interface\\Icons\\Spell_Frost_WindWalkOn"},
			RSMoon = {left = 0, top = 0, right = 0.25, bottom = 0.25, isTradeskill = true, id="Tailoring", largeSysIcon="Interface\\Icons\\Trade_Tailoring"},
		},
	},
}

GroupCalendar.ClassInfoByClassCode =
{
	D =
	{
		classID = "DRUID",
		femaleName = GroupCalendar_cFemaleDruidClassName,
		maleName = GroupCalendar_cMaleDruidClassName,
		color = GroupCalendar_cDruidClassColorName,
		element = "Druid",
		roles = {"MH", "OH", "MT", "OT", "MD", "RD"},
		talentRoles = {"RD", "MD", "MH"}, -- Balance, Feral, Restoration
		defaultRole = "MD",
	},
	H =
	{
		classID = "HUNTER",
		femaleName = GroupCalendar_cFemaleHunterClassName,
		maleName = GroupCalendar_cMaleHunterClassName,
		color = GroupCalendar_cHunterClassColorName,
		element = "Hunter",
		roles = {"RD"},
		talentRoles = {"RD", "RD", "RD"}, -- Beast mastery, Marksmanship, Survival
		defaultRole = "RD",
	},
	M =
	{
		classID = "MAGE",
		femaleName = GroupCalendar_cFemaleMageClassName,
		maleName = GroupCalendar_cMaleMageClassName,
		color = GroupCalendar_cMageClassColorName,
		element = "Mage",
		roles = {"RD"},
		talentRoles = {"RD", "RD", "RD"}, -- Frost, Arcane, Fire
		defaultRole = "RD",
	},
	L =
	{
		classID = "PALADIN",
		femaleName = GroupCalendar_cFemalePaladinClassName,
		maleName = GroupCalendar_cMalePaladinClassName,
		color = GroupCalendar_cPaladinClassColorName,
		element = "Paladin",
		roles = {"MH", "OH", "MT", "OT", "MD"},
		talentRoles = {"MH", "OT", "MD"}, -- Holy, Protection, Retribution
		defaultRole = "MH",
		faction = "Alliance",
	},
	P =
	{
		classID = "PRIEST",
		femaleName = GroupCalendar_cFemalePriestClassName,
		maleName = GroupCalendar_cMalePriestClassName,
		color = GroupCalendar_cPriestClassColorName,
		element = "Priest",
		roles = {"MH", "OH", "RD"},
		talentRoles = {"OH", "MH", "RD"}, -- Discipline, Holy, Shadow
		defaultRole = "MH",
	},
	R =
	{
		classID = "ROGUE",
		femaleName = GroupCalendar_cFemaleRogueClassName,
		maleName = GroupCalendar_cMaleRogueClassName,
		color = GroupCalendar_cRogueClassColorName,
		element = "Rogue",
		roles = {"MD"},
		talentRoles = {"MD", "MD", "MD"}, -- Assassination, Combat, Subtlety
		defaultRole = "MD",
	},
	S =
	{
		classID = "SHAMAN",
		femaleName = GroupCalendar_cFemaleShamanClassName,
		maleName = GroupCalendar_cMaleShamanClassName,
		color = GroupCalendar_cShamanClassColorName,
		element = "Shaman",
		roles = {"MH", "OH", "MD", "RD"},
		talentRoles = {"RD", "MD", "MH"}, -- Elemental, Enhancement, Restoration
		defaultRole = "MH",
		faction = "Horde",
	},
	K =
	{
		classID = "WARLOCK",
		femaleName = GroupCalendar_cFemaleWarlockClassName,
		maleName = GroupCalendar_cMaleWarlockClassName,
		color = GroupCalendar_cWarlockClassColorName,
		element = "Warlock",
		roles = {"RD"},
		talentRoles = {"RD", "RD", "RD"}, -- Affliction, Demonology, Destruction
		defaultRole = "RD",
	},
	W =
	{
		classID = "WARRIOR",
		femaleName = GroupCalendar_cFemaleWarriorClassName,
		maleName = GroupCalendar_cMaleWarriorClassName,
		color = GroupCalendar_cWarriorClassColorName,
		element = "Warrior",
		roles = {"MT", "OT", "MD"},
		talentRoles = {"MD", "MD", "MT"}, -- Arms, Fury, Protection
		defaultRole = "MT",
	},
}

GroupCalendar.ClassCodeByClassID = {}

for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
	GroupCalendar.ClassCodeByClassID[vClassInfo.color] = vClassCode
end

GroupCalendar.Roles =
{
	{ID = "MH", Name = GroupCalendar_cMHRole},
	{ID = "MT", Name = GroupCalendar_cMTRole},
	{ID = "OH", Name = GroupCalendar_cOHRole},
	{ID = "OT", Name = GroupCalendar_cOTRole},
	{ID = "RD", Name = GroupCalendar_cRDRole},
	{ID = "MD", Name = GroupCalendar_cMDRole},
}

-- RoleInfoByID

GroupCalendar.RoleInfoByID = {}

for vRoleIndex, vRoleInfo in pairs(GroupCalendar.Roles) do
	vRoleInfo.SortOrder = vRoleIndex
	vRoleInfo.Classes = {}
	GroupCalendar.RoleInfoByID[vRoleInfo.ID] = vRoleInfo
end

-- Add the class list to the role infos

for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
	for _, vRoleID in pairs(vClassInfo.roles) do
		GroupCalendar.RoleInfoByID[vRoleID].Classes[vClassCode] = true
	end
end

GroupCalendar.RaceNamesByRaceCode =
{
	D = {name = GroupCalendar_cDwarfRaceName,    id = "Dwarf",     faction="Alliance"},
	G = {name = GroupCalendar_cGnomeRaceName,    id = "Gnome",     faction="Alliance"},
	H = {name = GroupCalendar_cHumanRaceName,    id = "Human",     faction="Alliance"},
	N = {name = GroupCalendar_cNightElfRaceName, id = "NightElf",  faction="Alliance"},
	
	O = {name = GroupCalendar_cOrcRaceName,      id = "Orc",       faction="Horde"},
	T = {name = GroupCalendar_cTaurenRaceName,   id = "Tauren",    faction="Horde"},
	R = {name = GroupCalendar_cTrollRaceName,    id = "Troll",     faction="Horde"},
	U = {name = GroupCalendar_cUndeadRaceName,   id = "Scourge",   faction="Horde"},
}

GroupCalendar.RaceCodeByRaceID = {}

for vRaceCode, vRaceInfo in pairs(GroupCalendar.RaceNamesByRaceCode) do
	GroupCalendar.RaceCodeByRaceID[vRaceInfo.id] = vRaceCode
end

GroupCalendar.RaceCodeByRace = {}

for vRaceCode, vRaceInfo in pairs(GroupCalendar.RaceNamesByRaceCode) do
	GroupCalendar.RaceCodeByRace[vRaceInfo.name] = vRaceCode
end

function GroupCalendar.Database.DatabaseIsLocallyVisible(pDatabase)
	if GroupCalendar.Database.DatabaseIsVisible(pDatabase) then
		return true
	end
	
	return pDatabase.IsPlayerOwned
end

function GroupCalendar.Database.DatabaseIsVisible(pDatabase)
	-- If we're not in the same realm or faction as
	-- the database then don't show it
	
	if pDatabase.Realm ~= GroupCalendar.RealmName then
		return false, "Different realm"
	end
	
	if not pDatabase.Faction then
		if not GroupCalendar.Network:UserIsInSameGuild(pDatabase.UserName) then
			return false, "Unknown faction"
		end
		
		pDatabase.Faction = GroupCalendar.PlayerFactionGroup
	
	elseif pDatabase.Faction ~= GroupCalendar.PlayerFactionGroup then
		--GroupCalendar:TestMessage("Database for %s isn't visible because of faction or realm", pDatabase.UserName)
		return false, "Wrong faction"
	end
	
	-- If we're not in the database's local users list yet then don't show it
	
	if not pDatabase.LocalUsers
	or not pDatabase.LocalUsers[GroupCalendar.PlayerName] then
		--GroupCalendar:TestMessage("Database for %s isn't visible because this character hasn't seen it offered", pDatabase.UserName)
		return false, "Not visible to this character"
	end
	
	-- If the current config is the guild data channel and
	-- the database isn't someone in the guild then don't show it
	
	if GroupCalendar.Network.MinTrustedRank
	and not GroupCalendar.Network:UserIsInSameGuild(pDatabase.UserName) then
		--GroupCalendar:TestMessage("Database for %s isn't visible because it isn't from this guild", pDatabase.UserName)
		return false, "Not in the guild"
	end
	
	-- They passed the gauntlet, let 'em through
	
	--GroupCalendar:TestMessage("Database for %s is visible", pDatabase.UserName)
	return true
end

function GroupCalendar.Database.EventIsVisible(pEvent)
	if pEvent.mPrivate then
		return false
	end
	
	if not pEvent.mGuild then
		return true
	end
	
	if pEvent.mGuild ~= GroupCalendar.PlayerGuild then
		return false
	end
	
	if not pEvent.mMinGuildRank then
		return true
	end
	
	return GroupCalendar.PlayerGuildRank <= pEvent.mMinGuildRank
end

function GroupCalendar.Database.EventIsVisibleToPlayerInfo(pEvent, pPlayerInfo)
	if pEvent.mPrivate then
		return false
	end
	
	if not pEvent.mGuild or not pPlayerInfo then
		return true
	end
	
	if pEvent.mGuild ~= pPlayerInfo.Guild then
		return false
	end
	
	if not pEvent.mMinGuildRank then
		return true
	end
	
	return GroupCalendar.RankIndex <= pEvent.mMinGuildRank
end

function GroupCalendar.Database.EventIsLocallyVisible(pDatabase, pEvent)
	if GroupCalendar.Database.EventIsVisible(pEvent) then
		return true
	end
	
	return pDatabase.IsPlayerOwned
end

function GroupCalendar.Database.FixUserName(pUserName)
	local vUserName = strlower(pUserName)
	
	for vUserRealm, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if vDatabase.Realm == GroupCalendar.RealmName then
			if strlower(vDatabase.UserName) == vUserName then
				return vDatabase.UserName
			end
		end
	end
	
	return pUserName
end

function GroupCalendar.Database.GetDatabase(pUserName, pCreate, pRealmName, pCaseInsensitive)
	if not pUserName then
		GroupCalendar:ErrorMessage("GetDatabase: User name is nil")
		if GroupCalendar.Network.LastMessageReceived then
			GroupCalendar:ErrorMessage("While rocessing request %s", GroupCalendar.Network.LastMessageReceived)
		end
		GroupCalendar:ErrorStack()
		return
	end
	
	if not pRealmName then
		pRealmName = GroupCalendar.RealmName
	end
	
	local vDatabasePath = pRealmName.."_"..pUserName
	local vDatabase
	
	if pCaseInsensitive then
		vDatabasePath = string.lower(vDatabasePath)
		
		for vDatabasePath2, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if string.lower(vDatabasePath2) == vDatabasePath then
				return vDatabase
			end
		end
		
		return -- Return so that we won't create one
	else
		vDatabase = gGroupCalendar_Database.Databases[vDatabasePath]
	end
	
	if not vDatabase then
		if pCreate then
			vDatabase = {}
			
			vDatabase.UserName = pUserName
			vDatabase.IsPlayerOwned = pUserName == GroupCalendar.PlayerName
			vDatabase.CurrentEventID = 0
			vDatabase.Realm = pRealmName
			vDatabase.Faction = GroupCalendar.PlayerFactionGroup
			vDatabase.Events = {}
			vDatabase.Changes = nil
			vDatabase.RSVPs = nil
			vDatabase.LocalUsers = {}
			
			if vDatabase.IsPlayerOwned
			or GroupCalendar.Network:UserIsInSameGuild(pUserName) then
				vDatabase.Guild = GroupCalendar.PlayerGuild
			else
				vDatabase.Guild = nil
			end
			
			gGroupCalendar_Database.Databases[pRealmName.."_"..pUserName] = vDatabase
			
			if vDatabase.IsPlayerOwned then
				GroupCalendar.PlayerCharacters[GroupCalendar.PlayerName] = true
			end
		else
			return nil
		end
	end
	
	-- Update the faction code
	
	if pUserName == GroupCalendar.PlayerName then
		if not vDatabase.Guild then
			vDatabase.Guild = GroupCalendar.PlayerGuild
		end
		
		if not vDatabase.Faction then
			vDatabase.Faction = GroupCalendar.PlayerFactionGroup
		end
	end
	
	if vDatabase
	and not vDatabase.IsPlayerOwned
	and pUserName == GroupCalendar.PlayerName then
		vDatabase.IsPlayerOwned = true
	end
	
	if pCreate
	and (not vDatabase.LocalUsers or not vDatabase.LocalUsers[GroupCalendar.PlayerName]) then
		if not vDatabase.LocalUsers then
			vDatabase.LocalUsers = {}
		end
		
		vDatabase.LocalUsers[GroupCalendar.PlayerName] = true
	end
	
	return vDatabase, vDatabase.LocalUsers ~= nil and vDatabase.LocalUsers[GroupCalendar.PlayerName]
end

function GroupCalendar.Database.GetBackups(pUserName, pRealmName)
	if not pRealmName then
		pRealmName = GroupCalendar.RealmName
	end
	
	local vDatabasePath = pRealmName.."_"..pUserName
	local vBackups = gGroupCalendar_Database.Backups[vDatabasePath]
	
	if not vBackups then
		vBackups = {}
		gGroupCalendar_Database.Backups[vDatabasePath] = vBackups
	end
	
	return vBackups
end

function GroupCalendar.Database.GetDatabaseChangesByName(pUserName, pDatabaseTag, pCreate)
	local vDatabase, vLocalUser = GroupCalendar.Database.GetDatabase(pUserName, pCreate)
	
	if not vDatabase then
		return
	end
	
	return vDatabase, vLocalUser, GroupCalendar.Database.GetDatabaseChanges(vDatabase, pDatabaseTag)
end

function GroupCalendar.Database.GetDatabaseChanges(pDatabase, pDatabaseTag)
	if not pDatabase then
		return
	elseif pDatabaseTag == "DB" then
		return pDatabase.Changes, pDatabase.IsPlayerOwned
	elseif pDatabaseTag == "RAT" then
		return pDatabase.RSVPs, pDatabase.IsPlayerOwned
	else
		GroupCalendar:ErrorMessage("GroupCalendar: Unknown database change type %s", pDatabaseTag or "nil")
		GroupCalendar:DebugStack()
		return
	end
end

function GroupCalendar.Database.GetChangesID(pDatabase, pChanges)
	if not pChanges then
		return 0, 0, 0
	end
	
	local vAuthRevision
	
	if pDatabase.IsPlayerOwned then
		vAuthRevision = pChanges.Revision
	else
		vAuthRevision = pChanges.AuthRevision
	end
	
	return pChanges.ID, pChanges.Revision, vAuthRevision
end

function GroupCalendar.Database.GetOwnedDatabases()
	local vOwnedDatabases = {}
	
	for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if GroupCalendar.Database.DatabaseIsVisible(vDatabase)
		and vDatabase.IsPlayerOwned
		and vDatabase.PlayerLevel then -- Skip databases which haven't been visited since this version
			table.insert(vOwnedDatabases, vDatabase)
		end
	end
	
	return vOwnedDatabases
end

function GroupCalendar.Database.AssumeDatabase(pUserName, pDatabaseTag)
	local vDatabase = gGroupCalendar_Database.Databases[GroupCalendar.RealmName.."_"..pUserName]
	
	if not vDatabase then
		return
	end
	
	if not vDatabase.LocalUsers[GroupCalendar.PlayerName] then
		if GroupCalendar.Debug.LocalUsers then
			GroupCalendar:DebugMessage("%s events are now visible to %s", pUserName, GroupCalendar.PlayerName)
		end
		
		vDatabase.LocalUsers[GroupCalendar.PlayerName] = true
		GroupCalendar_MajorDatabaseChange(vDatabase)
	end
	
	return vDatabase, GroupCalendar.Database.GetDatabaseChanges(vDatabase, pDatabaseTag)
end

function GroupCalendar.Database.DeleteDatabaseByName(pUserName)
	local vDatabase = gGroupCalendar_Database.Databases[GroupCalendar.RealmName.."_"..pUserName]
	
	if not vDatabase then
		return
	end
	
	GroupCalendar.Database.DeleteDatabase(vDatabase)
end

function GroupCalendar.Database.RemoveLocalUser(pPlayerName)
	for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if vDatabase.Realm == GroupCalendar.RealmName
		and vDatabase.LocalUsers
		and vDatabase.LocalUsers[pPlayerName] then
			GroupCalendar.Database.DeleteDatabase(vDatabase, pPlayerName)
		end
	end
end

function GroupCalendar.Database.DeleteDatabase(pDatabase, pPlayerName)
	if not pPlayerName then
		pPlayerName = GroupCalendar.PlayerName
	end
	
	if pDatabase.LocalUsers then
		if GroupCalendar.Debug.LocalUsers then
			GroupCalendar:DebugMessage("Database for %s is no longer visible to %s", pDatabase.UserName, pPlayerName)
		end
		
		pDatabase.LocalUsers[pPlayerName] = nil
	end
	
	if not pDatabase.IsPlayerOwned
	and GroupCalendar.ArrayIsEmpty(pDatabase.LocalUsers) then
		gGroupCalendar_Database.Databases[pDatabase.Realm.."_"..pDatabase.UserName] = nil
	end
	
	GroupCalendar_MajorDatabaseChange(pDatabase)
end

function GroupCalendar.Database.DeleteDatabaseEvents(pDatabase)
	if not pDatabase.Changes then
		return
	end
	
	GroupCalendar.EraseTable(pDatabase.Events)
	pDatabase.Changes = nil
	
	GroupCalendar.Database.RemoveAllRSVPsForDatabase(pDatabase, true)
	
	GroupCalendar_MajorDatabaseChange(pDatabase)
end

function GroupCalendar.Database.GetChanges(pDatabase)
	local vChanges = pDatabase.Changes
	
	if not vChanges then
		vChanges = CalendarChanges_New(nil, pDatabase.HighestKnownDatabaseID)
		pDatabase.HighestKnownDatabaseID = vChanges.ID;
		pDatabase.Changes = vChanges
	end
	
	return vChanges
end

function GroupCalendar.Database.SetUserName(pUserName)
	GroupCalendar.UserDatabase = GroupCalendar.Database.GetDatabase(GroupCalendar.PlayerName, true)
	
	GroupCalendar.UserDatabase.PlayerRaceCode = GroupCalendar.Database.GetRaceCodeByRaceID(GroupCalendar.UnitRaceID("PLAYER"))
	GroupCalendar.UserDatabase.PlayerClassCode = GroupCalendar.Database.GetClassCodeByClassID(GroupCalendar.UnitClassID("PLAYER"))
end

function GroupCalendar.Database.NewEvent(pDatabase, pDate)
	local vEvent = {}
	
	vEvent.mType = nil
	vEvent.mTitle = nil
	
	vEvent.mTime = 1140
	vEvent.mDate = pDate
	vEvent.mDuration = 120
	
	vEvent.mDescription = nil
	
	vEvent.mMinLevel = 0
	vEvent.mAttendance = nil
	vEvent.mGuild = nil
	vEvent.mGuildRank = nil
	
	vEvent.mPrivate = nil
	
	vEvent.mManualConfirm = false
	vEvent.mRoleConfirm = true
	vEvent.mClosed = false
	
	vEvent.mAttendanceMode = "ROLE"
	
	vEvent.mLimits = nil
	
	pDatabase.CurrentEventID = pDatabase.CurrentEventID + 1
	vEvent.mID = pDatabase.CurrentEventID
	
	return vEvent
end

function GroupCalendar.Database.AddEvent(pDatabase, pEvent, pSilent)
	local vSchedule = pDatabase.Events[pEvent.mDate]
	
	if vSchedule == nil then
		vSchedule = {}
		pDatabase.Events[pEvent.mDate] = vSchedule
	end
	
	if pEvent.mID > pDatabase.CurrentEventID then
		pDatabase.CurrentEventID =  pEvent.mID
	end
	
	-- append the event
	
	table.insert(vSchedule, pEvent)
	
	if not pSilent then
		GroupCalendar.Database.EventAdded(pDatabase, pEvent)
	end
end

function GroupCalendar.Database.GetDateSchedule(pDate)
	return GroupCalendar.UserDatabase.Events[pDate]
end

function GroupCalendar.Database.GetCompiledSchedule(pDate, pIncludePrivateEvents, pForceServerTime, pMergeSchedule)
	local vCompiledSchedule
	
	if pMergeSchedule then
		vCompiledSchedule = pMergeSchedule
	else
		vCompiledSchedule = GroupCalendar.NewTable()
	end
	
	if not pForceServerTime and gGroupCalendar_Settings.ShowEventsInLocalTime then
		local vDate2 = nil
		
		if MCDateLib.ServerTimeZoneOffset < 0 then
			vDate2 = pDate + 1
		elseif MCDateLib.ServerTimeZoneOffset > 0 then
			vDate2 = pDate - 1
		end
		
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if GroupCalendar.Database.DatabaseIsLocallyVisible(vDatabase) then
				for vDateIndex = 1, 2 do
					local vDate
					
					if vDateIndex == 1 then
						vDate = pDate
					elseif vDate2 then
						vDate = vDate2
					else
						break
					end
					
					local vSchedule = vDatabase.Events[vDate]
					
					if vSchedule then
						for vIndex, vEvent in ipairs(vSchedule) do
							if (pIncludePrivateEvents and GroupCalendar.Database.EventIsLocallyVisible(vDatabase, vEvent))
							or (not pIncludePrivateEvents and GroupCalendar.Database.EventIsVisible(vEvent)) then
								-- Calculate the local date/time and see if it's still the right date
								
								local vLocalDate, vLocalTime = MCDateLib:GetLocalDateTimeFromServerDateTime(vDate, vEvent.mTime)
								
								if vLocalDate == pDate then
									local vCompiledEvent = GroupCalendar.NewTable()
									
									vCompiledEvent.mOwner = vDatabase.UserName
									vCompiledEvent.mRealm = vDatabase.Realm
									vCompiledEvent.mEvent = vEvent
									
									table.insert(vCompiledSchedule, vCompiledEvent)
								end
							end
						end
					end
				end
			end
		end
	else
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if GroupCalendar.Database.DatabaseIsLocallyVisible(vDatabase) then
				local vSchedule = vDatabase.Events[pDate]
				
				if vSchedule then
					for vIndex, vEvent in ipairs(vSchedule) do
						if (pIncludePrivateEvents and GroupCalendar.Database.EventIsLocallyVisible(vDatabase, vEvent))
						or (not pIncludePrivateEvents and GroupCalendar.Database.EventIsVisible(vEvent)) then
							local vCompiledEvent = GroupCalendar.NewTable()
							
							vCompiledEvent.mOwner = vDatabase.UserName
							vCompiledEvent.mRealm = vDatabase.Realm
							vCompiledEvent.mEvent = vEvent
							
							table.insert(vCompiledSchedule, vCompiledEvent)
						end
					end
				end
			end
		end
	end
	
	table.sort(vCompiledSchedule, GroupCalendar.Database.CompareCompiledEvents)
	
	return vCompiledSchedule
end

function GroupCalendar.Database.CompareCompiledEvents(pCompiledEvent1, pCompiledEvent2)
	return GroupCalendar.Database.CompareEvents(pCompiledEvent1.mEvent, pCompiledEvent2.mEvent)
end

function GroupCalendar.Database.GetEventDisplayName(pEvent)
	if pEvent.mTitle and pEvent.mTitle ~= "" then
		return GroupCalendar.UnescapeString(pEvent.mTitle)
	else
		local vName = GroupCalendar.Database.GetEventNameByID(pEvent.mType)
		
		if vName ~= nil then
			return vName
		elseif pEvent.mType ~= nil then
			return string.format(GroupCalendar_cUnknownEventType, pEvent.mType)
		else
			return "Untitled"
		end
	end
end

function GroupCalendar.Database.CompareEvents(pEvent1, pEvent2)
	--[[
	-- If either event has nil for a time (all day event) then
	-- sort based on time or display name
	
	if not pEvent1.mTime or not pEvent2.mTime then
		if pEvent1.mTime == pEvent2.mTime then
			return GroupCalendar.Database.GetEventDisplayName(pEvent1) < GroupCalendar.Database.GetEventDisplayName(pEvent2)
		elseif pEvent1.mTime == nil then
			return true
		else
			return false
		end
	]]--
	-- Otherwise compare dates first
	
	if not pEvent2 or not pEvent2.mDate then
		return true
	end
	
	if not pEvent1 or not pEvent1.mDate then
		return false
	end
	
	if pEvent1.mDate < pEvent2.mDate then
		return true
	end
	
	if pEvent1.mDate > pEvent2.mDate then
		return false
	end
	
	-- Dates are the same, compare times
	
	if pEvent1.mTime == pEvent2.mTime then
		return GroupCalendar.Database.GetEventDisplayName(pEvent1) < GroupCalendar.Database.GetEventDisplayName(pEvent2)
	end
	
	local vTime1 = pEvent1.mTime or 0
	local vTime2 = pEvent2.mTime or 0
	
	return vTime1 < vTime2
end

function GroupCalendar.Database.GetEventIndex(pSchedule, pEvent)
	for vIndex, vEvent in ipairs(pSchedule) do
		if vEvent == pEvent then
			return vIndex
		end
	end
	
	return 0
end

function GroupCalendar.Database.ScheduleIsEmpty(pSchedule)
	return next(pSchedule) == nil
end

function GroupCalendar.Database.FindEventByID(pDatabase, pEventID)
	for vDate, vSchedule in pairs(pDatabase.Events) do
		for vEventIndex, vEvent in ipairs(vSchedule) do
			if vEvent.mID == pEventID then
				return vEvent, vDate
			end
		end
	end
	
	return nil
end

function GroupCalendar.Database.DeleteEvent(pDatabase, pEvent, pSilent)
	return GroupCalendar.Database.DeleteEventFromDate(pDatabase, pEvent.mDate, pEvent, pSilent)
end

function GroupCalendar.Database.DeleteEventFromDate(pDatabase, pDate, pEvent, pSilent)
	-- Get the event's schedule
	
	local vSchedule = pDatabase.Events[pDate]
	
	if vSchedule == nil then
		return false
	end
	
	-- Find the event index
	
	local vEventIndex = GroupCalendar.Database.GetEventIndex(vSchedule, pEvent)
	
	if vEventIndex == 0 then
		return false
	end
	
	-- Notify that the event is being removed
	
	if not pSilent
	and pDatabase.IsPlayerOwned then
		GroupCalendar.Database.RemovingEvent(pDatabase, pEvent)
	end
	
	-- Remove any pending attendance for the event
	
	GroupCalendar.Database.RemoveAllRSVPsForEvent(pDatabase, pEvent, true)
	
	-- Remove the event
	
	table.remove(vSchedule, vEventIndex)
	
	if GroupCalendar.Database.ScheduleIsEmpty(vSchedule) then
		pDatabase.Events[pDate] = nil
		vSchedule = nil
	end
	
	-- Notify that the schedule changed
	
	GroupCalendar_ScheduleChanged(pDatabase, pDate)
	
	return true
end

function GroupCalendar.Database.RemovingEvent(pDatabase, pEvent)
	-- Don't record private events in the change history
	
	if pEvent.mPrivate then
		return
	end
	
	-- Remove any references to the event from the change history
	
	GroupCalendar.Database.RemoveEventChanges(pDatabase, pEvent)
	
	-- Insert a delete event
	
	local vChangeList = GroupCalendar.Database.GetNewChangeList(pDatabase, "DB")
	
	table.insert(vChangeList, GroupCalendar.Database.GetEventPath(pEvent).."DEL")
end

function GroupCalendar.Database.GetEventInfoByID(pID)
	for vGroupID, vEventGroup in pairs(GroupCalendar.EventTypes) do
		for vIndex, vEventInfo in ipairs(vEventGroup.Events) do
			if vEventInfo.id == pID then
				return vEventInfo
			end
		end
	end
	
	return nil
end

function GroupCalendar.Database.GetEventNameByID(pID)
	local vEventInfo = GroupCalendar.Database.GetEventInfoByID(pID)
	
	if not vEventInfo then
		return nil
	end
	
	return vEventInfo.name
end

function GroupCalendar.Database.EventAdded(pDatabase, pEvent)
	-- Append a change record if it's not a private event
	
	if not pEvent.mPrivate then
		local vChangeList, vRevisionChanged = GroupCalendar.Database.GetNewChangeList(pDatabase, "DB")
		
		GroupCalendar.Database.AppendNewEvent(vChangeList, pEvent, GroupCalendar.Database.GetEventPath(pEvent))
	end
	
	-- Notify the calendar
	
	GroupCalendar_ScheduleChanged(pDatabase, pEvent.mDate)
end

function GroupCalendar.Database.EventChanged(pDatabase, pEvent, pChangedFields)
	-- If the date changed then move the event to the appropriate slot
	
	if pChangedFields and pChangedFields.mDate then
		local vEvent, vDate = GroupCalendar.Database.FindEventByID(pDatabase, pEvent.mID)
		
		if vDate ~= pEvent.mDate then
			GroupCalendar.Database.DeleteEventFromDate(pDatabase, vDate, pEvent, true)
			GroupCalendar.Database.AddEvent(pDatabase, pEvent, true)
		end
	end
	
	-- Update pending attendance based on event contents
	
	if pChangedFields and pChangedFields.mAttendance then
		if pChangedFields.mAttendance.op == "UPD" then
			for vAttendeeName, vRSVPString in pairs(pChangedFields.mAttendance.val) do
				local vDatabase = GroupCalendar.Database.GetDatabase(vAttendeeName, false)
				
				if vDatabase and vDatabase.IsPlayerOwned then
					local vRSVP = GroupCalendar.Database.UnpackEventRSVP(pDatabase.UserName, vAttendeeName, pEvent.mID, vRSVPString)
					GroupCalendar.Database.RemoveOlderRSVP(vDatabase, vRSVP)
				end
			end
		else
			if GroupCalendar.Debug.Changes then
				GroupCalendar:DebugMessage("Database.EventChanged: Attendance op "..pChangedFields.mAttendance.op.." not recognized")
				GroupCalendar:DebugTable("Database.EventChanged: ", pChangedFields)
			end
		end
	end
	
	-- Update the changelist
	
	GroupCalendar.Database.RecordEventChanges(pDatabase, pEvent, pChangedFields)
	
	-- Notify the calendar
	
	GroupCalendar_EventChanged(pDatabase, pEvent, pChangedFields)
end

function GroupCalendar.Database.RecordEventChanges(pDatabase, pEvent, pChangedFields)
	-- Don't record private events in the change history
	
	if pEvent.mPrivate then
		GroupCalendar:DebugMessage("Network:EventChanged: Ignoring private event")
		return
	end
	
	-- Append a change record for the event
	
	local vChangeList = GroupCalendar.Database.GetNewChangeList(pDatabase, "DB")
	
	GroupCalendar.Database.AppendEventUpdate(
			vChangeList,
			pEvent,
			GroupCalendar.Database.GetEventPath(pEvent),
			pChangedFields)
end

StaticPopupDialogs.CALENDAR_SYNCH_WARNING =
{
	text = TEXT(GroupCalendar_cChangesDelayedMessage),
	button1 = TEXT(OKAY),
	OnAccept = function() end,
	OnCancel = function() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
}

function GroupCalendar.Database.GetNewChangeList(pDatabase, pDatabaseTag)
	local vChanges
	
	if pDatabaseTag == "RAT" then
		vChanges = GroupCalendar.Database.GetRSVPs(pDatabase)
	else
		vChanges = GroupCalendar.Database.GetChanges(pDatabase)
	end
	
	local vChangeList, vRevisionChanged = CalendarChanges_GetNewChangeList(vChanges)
	
	if vRevisionChanged and pDatabase.IsPlayerOwned
	and GroupCalendar.Database.DatabaseIsVisible(pDatabase) then
		-- Schedule a response with the new changes (it'll be delayed automatically
		-- if we're still in the synch period)
		
		GroupCalendar.Network:ProcessChangesRFU(vChanges, pDatabaseTag, true, false, pDatabase.UserName, vChanges.ID, vChanges.Revision - 1, vChanges.Revision - 1)
		
		if not GroupCalendar.Network:CanSendSelfUpdates()
		and not GroupCalendar.DidSynchWarning then
			GroupCalendar.DidSynchWarning = true
			StaticPopup_Show("CALENDAR_SYNCH_WARNING")
		end
	end
	
	return vChangeList
end

function GroupCalendar.Database.GetRSVPRevisionPath(pUserName, pDatabaseID, pRevision, pAuthRevision)
	return CalendarChanges_GetRevisionPath("RAT", pUserName, pDatabaseID, pRevision, pAuthRevision)
end

function GroupCalendar.Database.GetEventPath(pEvent)
	return "EVT:"..pEvent.mID.."/"
end

function GroupCalendar.Database.GenerateEventChangeString(pOpcode, pEvent, pEventPath)
	local vChange
	
	-- Basic fields: type, date, time, duration, minLevel, maxLevel

	vChange = pEventPath..pOpcode..":"
	
	if pEvent.mType ~= nil then
		vChange = vChange..pEvent.mType..","
	else
		vChange = vChange..","
	end

	if pEvent.mDate ~= nil then
		vChange = vChange..pEvent.mDate..","
	else
		vChange = vChange..","
	end

	if pEvent.mTime ~= nil then
		vChange = vChange..pEvent.mTime..","
	else
		vChange = vChange..","
	end

	if pEvent.mDuration ~= nil then
		vChange = vChange..pEvent.mDuration..","
	else
		vChange = vChange..","
	end

	if pEvent.mMinLevel ~= nil then
		vChange = vChange..pEvent.mMinLevel..","
	else
		vChange = vChange..","
	end

	if pEvent.mMaxLevel ~= nil then
		vChange = vChange..pEvent.mMaxLevel
	end
	
	return vChange
end

function GroupCalendar.Database.AutoConfirmToString(pEvent)
	if pEvent.mClosed then
		return "CNF:CLOSED"
	elseif pEvent.mManualConfirm then
		return "CNF:MAN"
	elseif pEvent.mLimits then
		local vConfConfigString = "CNF:AUT"
		
		if pEvent.mRoleConfirm then
			vConfConfigString = "CNF:ROLE"
		else
			vConfConfigString = "CNF:AUT"
		end
		
		if pEvent.mLimits.mMaxAttendance then
			vConfConfigString = vConfConfigString.."/MAX:"..pEvent.mLimits.mMaxAttendance
		end
		
		if pEvent.mRoleConfirm then
			if pEvent.mLimits.mRoleLimits then
				for vRoleCode, vRoleLimit in pairs(pEvent.mLimits.mRoleLimits) do
					vConfConfigString = vConfConfigString.."/"..vRoleCode..":"
					
					if vRoleLimit.mMin then
						vConfConfigString = vConfConfigString..vRoleLimit.mMin
					end
					
					if vRoleLimit.mMax then
						vConfConfigString = vConfConfigString..","..vRoleLimit.mMax
					end
					
					if vRoleLimit.mClass then
						for vClassID, vClassLimit in pairs(vRoleLimit.mClass) do
							local vClassCode = GroupCalendar.ClassCodeByClassID[vClassID]
							
							vConfConfigString = vConfConfigString..","..vClassCode..vClassLimit
						end
					end
				end
			end
		else
			if pEvent.mLimits.mClassLimits then
				for vClassCode, vClassLimit in pairs(pEvent.mLimits.mClassLimits) do
					vConfConfigString = vConfConfigString.."/"..vClassCode..":"
					
					if vClassLimit.mMin then
						vConfConfigString = vConfConfigString..vClassLimit.mMin
					end
					
					if vClassLimit.mMax then
						vConfConfigString = vConfConfigString..","..vClassLimit.mMax
					end
				end
			end
		end
		
		return vConfConfigString
	end
end

function GroupCalendar.Database.AppendNewEvent(pChangeList, pEvent, pEventPath)
	-- Basic fields: type, date, time, duration, minLevel, maxLevel
	
	table.insert(pChangeList, GroupCalendar.Database.GenerateEventChangeString("NEW", pEvent, pEventPath))
	
	-- Title
	
	if pEvent.mTitle then
		table.insert(pChangeList, pEventPath.."TIT:"..pEvent.mTitle)
	end

	if pEvent.mDescription ~= nil then
		table.insert(pChangeList, pEventPath.."DSC:"..pEvent.mDescription)
	end
	
	if pEvent.mGuild then
		local vChangeDesc = "GLD:"..pEvent.mGuild
		
		if pEvent.mMinGuildRank then
			vChangeDesc = vChangeDesc..","..pEvent.mMinGuildRank
		end
		
		table.insert(pChangeList, pEventPath..vChangeDesc)
	end
	
	local vChangeString = GroupCalendar.Database.AutoConfirmToString(pEvent)
	
	if vChangeString then
		table.insert(pChangeList, pEventPath..vChangeString)
	end

	-- Add attendance info
	
	if pEvent.mAttendance then
		for vAttendeeName, vAttendance in pairs(pEvent.mAttendance) do
			table.insert(pChangeList, pEventPath.."ATT:"..vAttendeeName..","..vAttendance)
		end
	end
	
	table.insert(pChangeList, pEventPath.."END")
end

function GroupCalendar.Database.AppendEventUpdate(pChangeList, pEvent, pEventPath, pChangedFields)
	local vUsingWrapper = false
	
	if GroupCalendar.Debug.Changes then
		GroupCalendar:DebugMark()
		GroupCalendar:DebugMessage("Database.AppendEventUpdate: Path is %s", pEventPath)
		GroupCalendar:DebugTable("pChangedFields", pChangedFields)
	end
	
	-- Basic fields: type, date, time, duration, minLevel, maxLevel
	
	-- See if fields sent in the NEW or UPD wrapper are being changed.  If so, the
	-- wrapper needs to be sent, otherwise it can be omitted to save bandwidth
	
	if pChangedFields.mType
	or pChangedFields.mDate
	or pChangedFields.mTime
	or pChangedFields.mDuration
	or pChangedFields.mMinLevel
	or pChangedFields.mMaxLevel then
		if GroupCalendar.Debug.Updates then
			GroupCalendar:DebugMessage("Database.AppendEventUpdate: Using wrapper")
		end
		
		table.insert(pChangeList, GroupCalendar.Database.GenerateEventChangeString("UPD", pEvent, pEventPath))
		vUsingWrapper = true
	end

	-- Title
	
	if pChangedFields.mTitle ~= nil then
		table.insert(pChangeList, pEventPath.."TIT:"..(pEvent.mTitle or ""))
	end
	
	if pChangedFields.mDescription ~= nil then
		table.insert(pChangeList, pEventPath.."DSC:"..(pEvent.mDescription or ""))
	end
	
	if pChangedFields.mGuild
	or pChangedFields.mMinGuildRank then
		local vChangeDesc = "GLD:"
		
		if pEvent.mGuild then
			vChangeDesc = vChangeDesc..pEvent.mGuild
			
			if pEvent.mMinGuildRank then
				vChangeDesc = vChangeDesc..","..pEvent.mMinGuildRank
			end
		end
		
		table.insert(pChangeList, pEventPath..vChangeDesc)
	end
	
	if pChangedFields.mClosed ~= nil
	or pChangedFields.mManualConfirm ~= nil
	or pChangedFields.mRoleConfirm ~= nil
	or pChangedFields.mLimits ~= nil then
		local vChangeString = GroupCalendar.Database.AutoConfirmToString(pEvent)
		
		if vChangeString then
			table.insert(pChangeList, pEventPath..vChangeString)
		end
	end

	if pChangedFields.mAttendance ~= nil then
		if pChangedFields.mAttendance.op == "UPD" then
			for vAttendeeName, vEventRSVPString in pairs(pChangedFields.mAttendance.val) do
				local vAttendeeRSVPString = pEvent.mAttendance[vAttendeeName]
				local vAttendeePath = pEventPath.."ATT:"..vAttendeeName
				
				if not vAttendeeRSVPString then
					table.insert(pChangeList, vAttendeePath)
				else
					table.insert(pChangeList, vAttendeePath..","..vAttendeeRSVPString)
				end
			end
		else
			GroupCalendar:DebugMessage("Database.AppendEventUpdate: Unknown attendance opcode "..pChangedFields.mAttendance.op)
		end
	end
	
	if vUsingWrapper then
		table.insert(pChangeList, pEventPath.."END")
	end
	
	if GroupCalendar.Debug.Changes then
		GroupCalendar:DebugTable("pChangeList", pChangeList)
		GroupCalendar:DebugMark()
	end
end

function GroupCalendar.Database.RemoveEventChanges(pDatabase, pEvent)
	-- Nothing to do if there are no changes
	
	if not pDatabase.Changes then
		return
	end
	
	-- Remove all prior occurances for this event
	
	for vRevision, vChangeList in pairs(pDatabase.Changes.ChangeList) do
		local vEventPath = GroupCalendar.Database.GetEventPath(pEvent)
		local vPathLength = string.len(vEventPath)
		
		local vNumChanges = table.getn(vChangeList)
		local vChangeIndex = 1
		
		while vChangeIndex <= vNumChanges do
			vChange = vChangeList[vChangeIndex]
			
			if vChange ~= nil
			and string.sub(vChange, 1, vPathLength) == vEventPath then
				table.remove(vChangeList, vIndex)
				vNumChanges = vNumChanges - 1
			else
				vChangeIndex = vChangeIndex + 1
			end
		end
		
		if vNumChanges == 0 then
			pDatabase.Changes.ChangeList[vRevision] = nil
		end
	end
end

function GroupCalendar.Database.RebuildPlayerDatabases()
	for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if vDatabase.IsPlayerOwned
		and vDatabase.Realm == GroupCalendar.RealmName then
			GroupCalendar.Database.RebuildDatabase(vDatabase)
			GroupCalendar.Database.RebuildRSVPs(vDatabase)
		end
	end -- for vRealmUser, vDatabase
end

----------------------------------------
-- GroupCalendar.Database.CalculateHighestUsedEventID
--     Calculates the highest event ID in use by the database
----------------------------------------

function GroupCalendar.Database.CalculateHighestUsedEventID(pDatabase)
	local vHighestID = nil
	
	for vDate, vSchedule in pairs(pDatabase.Events) do
		for vEventIndex, vEvent in ipairs(vSchedule) do
			if not vHighestID
			or vHighestID < vEvent.mID then
				vHighestID = vEvent.mID
			end
		end -- for vEventIndex, vEvent
	end -- for vDate, vSchedule
end

----------------------------------------
-- GroupCalendar.Database.RepairEventIDs
--     Scans the database an ensures that every event has
--     a unique ID
----------------------------------------

function GroupCalendar.Database.RepairEventIDs(pDatabase)
	local vHighestID = GroupCalendar.Database.CalculateHighestUsedEventID(pDatabase)
	
	-- Just return if there are no events
	
	if not vHighestID then
		return
	end
	
	-- Adjust the highest ID if it is lower than current ID
	
	if vHighestID > pDatabase.CurrentEventID then
		pDatabase.CurrentEventID = vCurrentID
	end
	
	-- Start making a map of used event IDs and
	-- use up the next ID if a collision is detected
	
	local vUsedIDs = GroupCalendar.NewTable()
	
	for vDate, vSchedule in pairs(pDatabase.Events) do
		for vEventIndex, vEvent in ipairs(vSchedule) do
			if not vUsedIDs[vEvent.mID] then
				vUsedIDs[vEvent.mID] = true
			else
				-- Collision
				
				pDatabase.CurrentEventID = pDatabase.CurrentEventID + 1
				vEvent.mID = pDatabase.CurrentEventID
			end
		end -- for vEventIndex, vEvent
	end -- for vDate, vSchedule
	
	GroupCalendar.DeleteTable(vUsedIDs)
end

----------------------------------------
-- GroupCalendar.Database.RebuildDatabase
--     Builds a new change history from the existing events
----------------------------------------

function GroupCalendar.Database.RebuildDatabase(pDatabase)
	-- Repair event IDs
	
	GroupCalendar.Database.RepairEventIDs(pDatabase)
	
	-- Clear the revisions
	
	pDatabase.Changes = nil
	pDatabase.Changes = GroupCalendar.Database.GetChanges(pDatabase)
	
	-- Start a new change list
	
	local vChangeList = nil
	
	-- Add each event to the revision
	
	for vDate, vSchedule in pairs(pDatabase.Events) do
		for vEventIndex, vEvent in ipairs(vSchedule) do
			if not vEvent.mPrivate then
				if not vChangeList then
					vChangeList = GroupCalendar.Database.GetNewChangeList(pDatabase, "DB")
				end
				
				GroupCalendar.Database.AppendNewEvent(
						vChangeList,
						vEvent,
						GroupCalendar.Database.GetEventPath(vEvent))
			end
		end
	end
	
	if GroupCalendar.Database.DatabaseIsVisible(pDatabase) then
		GroupCalendar.Network.ResponseQueue:QueueNOU(pDatabase, "DB", 0, 0)
	end
	
	-- Compact the RSVP list and notify that they're updated
	
	GroupCalendar.Database.RebuildRSVPs(pDatabase)
	
	-- Notify the calendar that there was a major change
	
	GroupCalendar_MajorDatabaseChange(pDatabase)
end

function GroupCalendar.Database.RebuildRSVPs(pDatabase)
	if pDatabase.RSVPs then
		CalendarChanges_Compact(pDatabase.RSVPs, pDatabase.HighestKnownRSVPID)
		pDatabase.HighestKnownRSVPID = pDatabase.RSVPs.ID
		
		local vServerDate, vServerTime60 = MCDateLib:GetServerDateTime60()
		
		local vChanges = pDatabase.RSVPs.ChangeList[1] -- There can be only one
		
		if vChanges then
			for vIndex, vRSVPString in ipairs(vChanges) do
				local vRSVP = GroupCalendar.Database.UnpackRSVPRequest(vRSVPString, pDatabase.UserName)
				
				if vRSVP.mDate < vServerDate
				or (vRSVP.mDate == vServerDate and vRSVP.mTime < vServerTime60) then
					vRSVP.mDate = vServerDate
					vRSVP.mTime = vServerTime60
				else
					vRSVP.mTime = vRSVP.mTime + 1
					
					if vRSVP.mTime >= 86400 then
						vRSVP.mTime = vRSVP.mTime - 86400
						vRSVP.mDate = vRSVP.mDate + 1
					end
				end
				
				vChanges[vIndex] = GroupCalendar.Database.PackRSVPRequest(vRSVP)
			end
		end
	end
	
	if GroupCalendar.Database.DatabaseIsVisible(pDatabase) then
		GroupCalendar.Network.ResponseQueue:QueueNOU(pDatabase, "RAT", 0, 0)
	end
end

----------------------------------------
-- GroupCalendar.Database.ReconstructDatabase
--     Reconstructs the event records by re-playing the
--     change history
----------------------------------------

function GroupCalendar.Database.ReconstructDatabase(pDatabase)
	-- Clear the events
	
	pDatabase.Events = {}
	
	-- Execute each change
	
	if pDatabase.Changes then
		for vRevision = 1, pDatabase.Changes.Revision do
			local vChangeList = pDatabase.Changes.ChangeList[vRevision]
			
			if GroupCalendar.Debug.Reconstruct then
				GroupCalendar:DebugMessage("Database.ReconstructDatabase: Reconstructing revision "..vRevision.." in "..pDatabase.UserName)
				GroupCalendar:DebugTable("    ChangeList", vChangeList)
			end
			
			GroupCalendar.Database.ExecuteChangeList(pDatabase, vChangeList, false)
		end
	end
	
	GroupCalendar_MajorDatabaseChange(pDatabase)
end

function GroupCalendar.Database.FixDescriptionLimits(pDatabase)
	if pDatabase.Changes then
		for vRevision = 1, pDatabase.Changes.Revision do
			local vChangeList = pDatabase.Changes.ChangeList[vRevision]
			
			if vChangeList then
				for vIndex, vString in ipairs(vChangeList) do
					if string.len(vString) > 200 then
						vChangeList[vIndex] = string.sub(vString, 1, 200)
					end
				end
			end
		end
	end
end

function GroupCalendar.Database.ReprocessAllRSVPs(pDatabase)
	local vRSVPs = pDatabase.RSVPs
	
	if not vRSVPs then	
		return
	end

	for vRevision = 1, vRSVPs.Revision do
		local vChangeList = vRSVPs.ChangeList[vRevision]
		
		GroupCalendar.Database.ExecuteRSVPChangeList(pDatabase, vChangeList, false)
	end
end

function GroupCalendar.Database.ExecuteRSVPChangeList(pDatabase, pChangeList, pNotifyChanges)
	if not pChangeList then
		return
	end
	
	pChangeList.IsOpen = nil -- Make sure IsOpen is cleared, a bug may have caused it to remain open
	
	local vIndex = 1
	local vNumChanges = table.getn(pChangeList)
	
	while vIndex <= vNumChanges do
		local vChange = pChangeList[vIndex]
		
		if vChange then
			local vCommands = GroupCalendar.Network:ParseCommandString(vChange)
			
			if not vCommands then
				GroupCalendar:DebugMessage("Invalid change entry found in RSVPs for "..pDatabase.UserName)
				return
			end
			
			local vOpcode = vCommands[1].opcode
			local vOperands = vCommands[1].operands
			
			table.remove(vCommands, 1)
			
			if vOpcode == "EVT" then
				local vRSVP = GroupCalendar.Database.UnpackRSVPFieldArray(vOperands, pDatabase.UserName)
				
				if GroupCalendar.Database.ProcessRSVP(vRSVP) then
					-- Processing the RSVP may have removed it from the list already so
					-- update the length and see if the request is still there.  Remove
					-- it if it is
					
					vNumChanges = table.getn(pChangeList)
					
					if vIndex <= vNumChanges
					and vChange == pChangeList[vIndex] then
						table.remove(pChangeList, vIndex)
					end
					
					-- Bump the index back so that it ends up staying the same after the
					-- increment later in the loop
					
					vIndex = vIndex - 1
				end
			elseif GroupCalendar.Debug.Errors then
				GroupCalendar:DebugMessage("Unknown RSVP opcode "..vOpcode)
			end
		end
		
		vIndex = vIndex + 1
	end
end

function GroupCalendar.Database.ExecuteChangeList(pDatabase, pChangeList, pNotifyChanges)
	if not pChangeList then
		return
	end
	
	local vEvent = nil
	local vNewEvent = false
	local vQuickEvent = false
	local vEventDateChanged = false
	
	pChangeList.IsOpen = nil -- Make sure IsOpen is cleared, a bug may have caused it to remain open
	
	for vIndex, vChange in ipairs(pChangeList) do
		local vCommands = GroupCalendar.Network:ParseCommandString(vChange)
		
		if not vCommands then
			GroupCalendar:DebugMessage("Invalid change entry found in database for "..pDatabase.UserName)
			return
		end
		
		local vOpcode = vCommands[1].opcode
		local vOperands = vCommands[1].operands
		
		table.remove(vCommands, 1)
		
		if vOpcode == "EVT" then
			local vEventID = tonumber(vOperands[1])
			local vEvtOpcode = vCommands[1].opcode
			local vEvtOperands = vCommands[1].operands
			
			table.remove(vCommands, 1)
		
			if vEvtOpcode == "NEW" then
				if vEvent and GroupCalendar.Debug.Errors then
					GroupCalendar:DebugMessage("Starting new event while previous event is still open in database for "..pDatabase.UserName)
				end
				
				if not GroupCalendar.Database.FindEventByID(pDatabase, vEventID) then
					local vDate = tonumber(vEvtOperands[2])
					
					-- Create the event record if the event isn't too old
					
					if vDate >= GroupCalendar.MinimumEventDate then
						vEvent = {}
						vNewEvent = true
						
						vEvent.mID = vEventID
						vEvent.mType = vEvtOperands[1]
						vEvent.mDate = tonumber(vEvtOperands[2])
						vEvent.mTime = tonumber(vEvtOperands[3])
						vEvent.mDuration = tonumber(vEvtOperands[4])
						vEvent.mMinLevel = tonumber(vEvtOperands[5])
						vEvent.mMaxLevel = tonumber(vEvtOperands[6])
						
						GroupCalendar.Database.AddEvent(pDatabase, vEvent, true)
					end
				elseif GroupCalendar.Debug.Errors then
					GroupCalendar:ErrorMessage("Event "..vEventID.." already exists in database for "..pDatabase.UserName)
					GroupCalendar:DebugStack()
					GroupCalendar:DebugMark()
				end
				
			elseif vEvtOpcode == "UPD" then
				if vEvent and GroupCalendar.Debug.Errors then
					GroupCalendar:DebugMessage("Updating event while previous event is still open in database for "..pDatabase.UserName)
				end
				
				vEvent = GroupCalendar.Database.FindEventByID(pDatabase, vEventID)
				
				if vEvent then
					local vDate = vEvent.mDate
					
					vEvent.mID = vEventID
					vEvent.mType = vEvtOperands[1]
					vEvent.mDate = tonumber(vEvtOperands[2])
					vEvent.mTime = tonumber(vEvtOperands[3])
					vEvent.mDuration = tonumber(vEvtOperands[4])
					vEvent.mMinLevel = tonumber(vEvtOperands[5])
					vEvent.mMaxLevel = tonumber(vEvtOperands[6])
					
					vNewEvent = false
					vEventDateChanged = vEvent.mDate ~= vDate
				elseif GroupCalendar.Debug.Errors then
					GroupCalendar:DebugMessage("Event "..vEventID.." not found in database for "..pDatabase.UserName)
				end
			
			elseif vEvtOpcode == "TIT" then
				if not vEvent then
					vEvent = GroupCalendar.Database.FindEventByID(pDatabase, vEventID)
					vQuickEvent = true
				end
				
				if vEvent then
					vEvent.mTitle = vEvtOperands[1]
				elseif GroupCalendar.Debug.Errors then
					GroupCalendar:DebugMessage("Event "..vEventID.." not found in database for "..pDatabase.UserName)
				end
				
			elseif vEvtOpcode == "DSC" then
				if not vEvent then
					vEvent = GroupCalendar.Database.FindEventByID(pDatabase, vEventID)
					vQuickEvent = true
				end
				
				if vEvent then
					vEvent.mDescription = vEvtOperands[1]
				elseif GroupCalendar.Debug.Errors then
					GroupCalendar:DebugMessage("Event "..vEventID.." not found in database for "..pDatabase.UserName)
				end
			
			elseif vEvtOpcode == "GLD" then
				if not vEvent then
					vEvent = GroupCalendar.Database.FindEventByID(pDatabase, vEventID)
					vQuickEvent = true
				end
				
				if vEvent then
					vEvent.mGuild = vEvtOperands[1]
					vEvent.mMinGuildRank = tonumber(vEvtOperands[2])
					
				elseif GroupCalendar.Debug.Errors then
					GroupCalendar:DebugMessage("Event "..vEventID.." not found in database for "..pDatabase.UserName)
				end
				
			elseif vEvtOpcode == "CNF" then
				if not vEvent then
					vEvent = GroupCalendar.Database.FindEventByID(pDatabase, vEventID)
					vQuickEvent = true
				end
				
				if vEvent then
					if vEvtOperands[1] == "CLOSED" then
						vEvent.mClosed = true
						vEvent.mManualConfirm = nil
						vEvent.mRoleConfirm = nil
					
					elseif vEvtOperands[1] == "MAN" then
						vEvent.mClosed = nil
						vEvent.mManualConfirm = true
						vEvent.mRoleConfirm = nil
					
					elseif vEvtOperands[1] == "AUT" then
						vEvent.mClosed = nil
						vEvent.mManualConfirm = nil
						vEvent.mRoleConfirm = nil
						
						vEvent.mLimits = {mClassLimits = {}}
						
						while table.getn(vCommands) > 0 do
							local vCNFOpcode = vCommands[1].opcode
							local vCNFOperands = vCommands[1].operands
							
							table.remove(vCommands, 1)
							
							if vCNFOpcode == "MAX" then
								vEvent.mLimits.mMaxAttendance = tonumber(vCNFOperands[1])
							else
								local vMin = tonumber(vCNFOperands[1])
								local vMax = tonumber(vCNFOperands[2])
								
								vEvent.mLimits.mClassLimits[vCNFOpcode] = {mMin = vMin, mMax = vMax}
							end
						end
					elseif vEvtOperands[1] == "ROLE" then
						vEvent.mClosed = nil
						vEvent.mManualConfirm = nil
						vEvent.mRoleConfirm = true
						
						vEvent.mLimits = {mRoleLimits = {}}
						
						while table.getn(vCommands) > 0 do
							local vCNFOpcode = vCommands[1].opcode
							local vCNFOperands = vCommands[1].operands
							
							table.remove(vCommands, 1)
							
							if vCNFOpcode == "MAX" then
								vEvent.mLimits.mMaxAttendance = tonumber(vCNFOperands[1])
							else
								local vMin = tonumber(vCNFOperands[1])
								local vMax = tonumber(vCNFOperands[2])
								local vRoleLimit = {mMin = vMin, mMax = vMax}
								local vNumClassLimits = table.getn(vCNFOperands) - 2
								
								if vNumClassLimits > 0 then
									vRoleLimit.mClass = {}
									
									for vIndex = 3, table.getn(vCNFOperands) do
										local vClassLimit = vCNFOperands[vIndex]
										local vClassCode = string.sub(vClassLimit, 1, 1)
										local vClassLimit = tonumber(string.sub(vClassLimit, 2))
										
										vRoleLimit.mClass[GroupCalendar.ClassInfoByClassCode[vClassCode].color] = vClassLimit
									end
								end
								
								vEvent.mLimits.mRoleLimits[vCNFOpcode] = vRoleLimit
							end
						end
						
					elseif GroupCalendar.Debug.Errors then
						GroupCalendar:DebugMessage("Unknown event configuration "..vEvtOperands[1]) 
					end
				
				-- Didn't find the specified event
				
				elseif GroupCalendar.Debug.Errors then
					GroupCalendar:DebugMessage("Event "..vEventID.." not found in database for "..pDatabase.UserName)
				end
		
			elseif vEvtOpcode == "ATT" then
				if not vEvent then
					vEvent = GroupCalendar.Database.FindEventByID(pDatabase, vEventID)
					vQuickEvent = true
				end
				
				if vEvent then
					local vAttendeeName = vEvtOperands[1]
					
					if not vEvent.mAttendance then
						vEvent.mAttendance = {}
					end
					
					-- Add/update their attendance
					
					local vNumOperands = table.getn(vEvtOperands)
					local vAttendanceString = nil
					
					if vNumOperands > 1 then
						for vOperandIndex = 2, vNumOperands do
							local vOperand = vEvtOperands[vOperandIndex]
							
							if vAttendanceString == nil then
								vAttendanceString = ""
							else
								vAttendanceString = vAttendanceString..","
							end
							
							if vOperand then
								vAttendanceString = vAttendanceString..vOperand
							end
						end
						
					end
					
					vEvent.mAttendance[vAttendeeName] = vAttendanceString
				
					-- Remove any older (or same) RSVP for this person
					
					local vRSVP = GroupCalendar.Database.UnpackEventRSVP(pDatabase.UserName, vAttendeeName, vEventID, vAttendanceString)
					
					GroupCalendar.Database.RemoveOldAttendeeRSVP(vAttendeeName, pDatabase.UserName, vEventID, vRSVP)
					
				-- Didn't find the specified event
				
				elseif GroupCalendar.Debug.Errors then
					GroupCalendar:DebugMessage("Event "..vEventID.." not found in database for "..pDatabase.UserName)
				end

			elseif vEvtOpcode == "END" then
				if vEvent then
					if pNotifyChanges then
						-- Notify the calendar
						
						if vNewEvent then
							GroupCalendar_ScheduleChanged(pDatabase, vEvent.mDate)
							
							if not pDatabase.IsPlayerOwned then	
								GroupCalendar_AddedNewEvent(pDatabase, vEvent)
							end
						else
							if vEventDateChanged then
								local vEvent2, vDate = GroupCalendar.Database.FindEventByID(pDatabase, vEvent.mID)
								
								if vDate ~= vEvent.mDate then
									GroupCalendar.Database.DeleteEventFromDate(pDatabase, vDate, pEvent, true)
									GroupCalendar.Database.AddEvent(pDatabase, vEvent, true)
								end
							end
							
							GroupCalendar_EventChanged(pDatabase, vEvent, nil) -- only notify the calendar
						end
					end
					
					vEvent = nil
				elseif GroupCalendar.Debug.Errors then
					GroupCalendar:DebugMessage("Event not open when attemping to end update for "..pDatabase.UserName)
				end
			
			elseif vEvtOpcode == "DEL" then
				vEvent = GroupCalendar.Database.FindEventByID(pDatabase, vEventID)
				vQuickEvent = true
				
				if vEvent then
					GroupCalendar.Database.DeleteEvent(pDatabase, vEvent, true)
				elseif GroupCalendar.Debug.Errors then
					GroupCalendar:DebugMessage("Can't delete event "..vEventID..": Event not found in database for "..pDatabase.UserName)
				end
				
			elseif GroupCalendar.Debug.Errors then
				GroupCalendar:DebugMessage("Unknown change operator "..vEvtOpcode) 
			end
			
			if vQuickEvent then
				vEvent = nil
				vQuickEvent = false
			end	
		end
	end
end

function GroupCalendar.Database.PurgeDatabase(pDatabase, pDatabaseTag, pDatabaseID, pRevision)
	local vChanges
	
	if pDatabaseTag == "DB" then
		GroupCalendar.Database.RemoveAllRSVPsForDatabase(pDatabase, true)
		
		pDatabase.CurrentEventID = 0
		
		GroupCalendar.EraseTable(pDatabase.Events)
		
		pDatabase.Changes = CalendarChanges_Erase(pDatabase.Changes)
		
		vChanges = pDatabase.Changes
	elseif pDatabaseTag == "RAT" then
		pDatabase.RSVPs = CalendarChanges_Erase(pDatabase.RSVPs)
		vChanges = pDatabase.RSVPs
	else
		GroupCalendar:ErrorMessage("PurgeDatabase: Unknown tag %s", pDatabaseTag or "nil")
		return
	end
	
	if vChanges then
		vChanges.ID = pDatabaseID
		
		if pRevision ~= nil then
			vChanges.Revision = pRevision
		end
	end
		
	GroupCalendar_MajorDatabaseChange(pDatabase)
end

function GroupCalendar.Database.CheckDatabase(pDatabase)
	if not pDatabase.LocalUsers then
		pDatabase.LocalUsers = {}
	end
	
	if pDatabase.IsPlayerOwned
	and not pDatabase.LocalUsers[pDatabase.UserName] then
		if GroupCalendar.Debug.LocalUsers then
			GroupCalendar:DebugMessage("Making database for %s visible to himself", pDatabase.UserName)
		end
		
		pDatabase.LocalUsers[pDatabase.UserName] = true
	end
	
	-- Remove empty RSVP changelists
	
	if pDatabase.RSVPs then
		if pDatabase.RSVPs.Revision == nil then
			pDatabase.RSVPs.Revision = 0
		end
		
		if pDatabase.RSVPs.AuthRevision == nil then
			pDatabase.RSVPs.AuthRevision = 0
		end
		
		if pDatabase.RSVPs.ChangeList == nil then
			pDatabase.RSVPs.ChangeList = {}
		end
		
		for vRevision = 1, pDatabase.RSVPs.Revision do
			local vChangeList = pDatabase.RSVPs.ChangeList[vRevision]
			
			if vChangeList and table.getn(vChangeList) == 0 then
				pDatabase.RSVPs.ChangeList[vRevision] = nil
			end
		end
	end
	
	-- Make sure event changes are in order
	
	if pDatabase.Changes then
		if pDatabase.Changes.Revision == nil then
			pDatabase.Changes.Revision = 0
			
			for vRevision, vChangeList in pairs(pDatabase.RSVPs.ChangeList) do
				if vRevision > pDatabase.Changes.Revision then
					pDatabase.Changes.Revision = vRevision
				end
			end
			
			pDatabase.Changes.AuthRevision = 0
		end
		
		if pDatabase.Changes.AuthRevision == nil then
			pDatabase.Changes.AuthRevision = 0
		end
		
		if pDatabase.Changes.ChangeList == nil then
			pDatabase.Changes.ChangeList = {}
		end
	end
	
	-- Repair events
	
	for vDate, vEvents in pairs(pDatabase.Events) do
		for vEventIndex, vEvent in ipairs(vEvents) do
			if not vEvent.mDate then
				vEvent.mDate = vDate
			end
		end
	end
	
	-- Remove events with duplicate IDs
	
	for vDate, vEvents in pairs(pDatabase.Events) do
		local vEventIndex = 1
		local vNumEvents = table.getn(vEvents)
		
		while vEventIndex <= vNumEvents do
			local vEvent = vEvents[vEventIndex]
			
			if not vEvent
			or GroupCalendar.Database.FindEventByID(pDatabase, vEvent.mID) ~= vEvent then
				GroupCalendar:DebugMessage("Database.CheckDatabase: Removing extra event ID "..vEvent.mID.." from database for "..pDatabase.UserName)
				
				table.remove(vEvents, vEventIndex)
				vNumEvents = vNumEvents - 1
			else
				vEventIndex = vEventIndex + 1
			end
		end
	end
end

function GroupCalendar.Database.ScanForNewlines(pDatabase)
	for vDate, vEvents in pairs(pDatabase.Events) do
		for vEventID, vEvent in pairs(vEvents) do
			if vEvent.mDescription then
				vEvent.mDescription = string.gsub(vEvent.mDescription, "\n", "&n;")
			end
		end
	end

	if pDatabase.Changes and pDatabase.Changes.ChangeList then
		for vRevision = 1, pDatabase.Changes.Revision do
			local vChangeList = pDatabase.Changes.ChangeList[vRevision]
			
			if vChangeList then
				for vIndex, vChange in ipairs(vChangeList) do
					if type(vIndex) == "number" then
						vChanges[vIndex] = string.gsub(vChange, "\n", "&n;")
					end
				end
			end
		end
	end
end

function GroupCalendar.Database.Initialize()
	GroupCalendar.Database.CheckDatabases()
	
	-- Update the list of player-owned databases
	
	GroupCalendar.PlayerCharacters = {}
	
	for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if GroupCalendar.Database.DatabaseIsVisible(vDatabase)
		and vDatabase.IsPlayerOwned then
			GroupCalendar.PlayerCharacters[vDatabase.UserName] = true
		end
	end
end

function GroupCalendar.Database.CheckDatabases()
	-- Upgrade the database to format 4 (just purge all non-owned databases
	-- and rebuild the owned ones)
	
	if gGroupCalendar_Database.Format < 4 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if vDatabase.IsPlayerOwned then
				GroupCalendar.Database.RebuildDatabase(vDatabase)
			else
				gGroupCalendar_Database.Databases[vRealmUser] = nil
			end
		end
		
		gGroupCalendar_Database.Format = 4
	end
	
	-- Upgrade the database to format 5 (scan for newlines in event fields and escape them)
	
	if gGroupCalendar_Database.Format < 5 then
		for vRealmUser, vSettings in pairs(gGroupCalendar_Settings) do
			if type(vSettings) == "array" and vSettings.EventTemplates then
				for vEventID, vEventTemplate in pairs(vSettings.EventTemplates) do
					if vEventTemplate.mDescription then
						vEventTemplate.mDescription = string.gsub(vEventTemplate.mDescription, "\n", "&n;")
					end
				end
			end
		end
		
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			GroupCalendar.Database.ScanForNewlines(vDatabase)
		end
		
		gGroupCalendar_Database.Format = 5
	end

	-- Upgrade the database to format 6 (just purge all non-owned databases
	-- and rebuild the owned ones again)
	
	if gGroupCalendar_Database.Format < 6 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if vDatabase.IsPlayerOwned then
				GroupCalendar.Database.RebuildDatabase(vDatabase)
			else
				gGroupCalendar_Database.Databases[vRealmUser] = nil
			end
		end
		
		gGroupCalendar_Database.Format = 6
	end
	
	-- Upgrade to format 7 (just purge all non-owned databases)

	if gGroupCalendar_Database.Format < 7 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if not vDatabase.IsPlayerOwned then
				gGroupCalendar_Database.Databases[vRealmUser] = nil
			end
		end
		
		gGroupCalendar_Database.Format = 7
	end
	
	-- Upgrade to format 8 (rebuild all owned databases to force
	-- them to the new version numbering system)
	
	if gGroupCalendar_Database.Format < 8 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if vDatabase.IsPlayerOwned then
				GroupCalendar.Database.RebuildDatabase(vDatabase)
			end
		end
		
		gGroupCalendar_Database.Format = 8
	end

	-- Upgrade to format 9 (reconstruct non-owned databases to correct
	-- parsing errors)
	
	if gGroupCalendar_Database.Format < 9 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if not vDatabase.IsPlayerOwned then
				GroupCalendar.Database.ReconstructDatabase(vDatabase)
			end
		end
		
		gGroupCalendar_Database.Format = 9
	end

	-- Upgrade the database to format 10 (just purge all non-owned databases)
	
	if gGroupCalendar_Database.Format < 10 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if not vDatabase.IsPlayerOwned then
				gGroupCalendar_Database.Databases[vRealmUser] = nil
			end
		end
		
		gGroupCalendar_Database.Format = 10
	end
	
	-- Upgrade the database to format 11 (ensure that attendance for deleted events have been removed
	-- and that event IDs are numbers and not strings)
	
	if gGroupCalendar_Database.Format < 11 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			-- Convert all event IDs to a number to fix a bug
			-- caused by earlier versions
			
			for vDate, vEvents in pairs(vDatabase.Events) do
				for vIndex, vEvent in ipairs(vEvents) do
					vEvent.mID = tonumber(vEvent.mID)
				end
			end
		end
		
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if vDatabase.IsPlayerOwned then
				GroupCalendar.Database.RemoveObsoleteRSVPs(vDatabase)
				GroupCalendar.Database.RebuildRSVPs(vDatabase)
			else
				GroupCalendar.Database.ReprocessAllRSVPs(vDatabase)
			end
		end
		
		gGroupCalendar_Database.Format = 11
	end
	
	-- Upgrade to format 12 (reconstruct non-owned databases to correct
	-- parsing errors)
	
	if gGroupCalendar_Database.Format < 12 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if not vDatabase.IsPlayerOwned then
				GroupCalendar.Database.ReconstructDatabase(vDatabase)
			end
		end
		
		gGroupCalendar_Database.Format = 12
	end
	
	-- Upgrade to format 13 (rebuild owned databases to fix problem caused by 3.0b2)
	
	if gGroupCalendar_Database.Format < 13 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if vDatabase.IsPlayerOwned then
				GroupCalendar.Database.RebuildDatabase(vDatabase)
			end
		end
		
		gGroupCalendar_Database.Format = 13
	end
	
	-- Upgrade to format 14 (reconstruct all external databases)
	
	if gGroupCalendar_Database.Format < 14 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if not vDatabase.IsPlayerOwned then
				GroupCalendar.Database.ReconstructDatabase(vDatabase)
			end
		end
		
		gGroupCalendar_Database.Format = 14
	end
	
	-- Format 15 is obsolete
	
	-- Upgrade to format 16 (limit descriptions to GroupCalendar_cMaxFieldLength)
	
	if gGroupCalendar_Database.Format < 16 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			GroupCalendar.Database.FixDescriptionLimits(vDatabase)
		end
		
		gGroupCalendar_Database.Format = 16
	end
	
	-- Upgrade to format 17 (rebuild owned databases to give GC4 beta users a clean start)
	
	if gGroupCalendar_Database.Format < 17 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if vDatabase.IsPlayerOwned then
				GroupCalendar.Database.RebuildDatabase(vDatabase)
			end
		end
		
		gGroupCalendar_Database.Format = 17
	end
	
	-- Format 18 updates HighestKnownDatabaseID and HighestKnownRSVPID
	
	if gGroupCalendar_Database.Format < 18 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if vDatabase.Changes and (not vDatabase.HighestKnownDatabaseID or vDatabase.Changes.ID > vDatabase.HighestKnownDatabaseID) then
				vDatabase.HighestKnownDatabaseID = vDatabase.Changes.ID
			end
			
			if vDatabase.RSVPs and (not vDatabase.HighestKnownRSVPID or vDatabase.RSVPs.ID > vDatabase.HighestKnownRSVPID) then
				vDatabase.HighestKnownDatabaseID = vDatabase.RSVPs.ID
			end
		end
		
		gGroupCalendar_Database.Format = 18
	end
	
	-- Upgrade to format 19 (rebuild owned databases to give GC4 users a clean start
	-- and delete all non-owned databases)
	
	if gGroupCalendar_Database.Format < 19 then
		for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
			if vDatabase.IsPlayerOwned then
				GroupCalendar.Database.RebuildDatabase(vDatabase)
			else
				gGroupCalendar_Database.Databases[vRealmUser] = nil
			end
		end
		
		gGroupCalendar_Database.Format = 19
	end
	
	-- Repair any damaged databases
	
	for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if not vDatabase.Realm then
			local vStartIndex, vEndIndex, vRealmName, vUserName = string.find(vRealmUser, "([^_]+)_([^_]+)")
			
			if vStartIndex ~= nil then
				vDatabase.Realm = vRealmName
				vDatabase.UserName = vUserName
			end
		end
		
		GroupCalendar.Database.CheckDatabase(vDatabase)
	end
	
	-- Add the backups table if it's missing
	
	if not gGroupCalendar_Database.Backups then
		gGroupCalendar_Database.Backups = {}
	end
	
	-- Remove old events
	
	for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		GroupCalendar.Database.DeleteOldEvents(vDatabase)
	end
end

function GroupCalendar.Database.CheckDatabaseTrust()
	-- Return if they're in a guild but the roster isn't loaded
	-- so that we don't go and delete a bunch of guildie calendars
	-- by mistake
	
	if IsInGuild() and GetNumGuildMembers() == 0 then
		if GroupCalendar.Debug.Init then
			GroupCalendar:DebugMessage("CheckDatabaseTrust: Roster isn't loaded, scheduling a load")
		end
		
		GroupCalendar.Network:LoadGuildRoster()
		return
	end
	
	if GroupCalendar.Debug.Trust then
		GroupCalendar:DebugMessage("CheckDatabaseTrust: Verifying trust")
	end
	
	-- Verify that each database is still trusted
	
	for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		-- This hack fixes up the faction information for everyone in the guild
		-- since versions prior to 4.0 didn't store this
		
		if not vDatabase.Faction
		and vDatabase.Realm == GroupCalendar.RealmName
		and GroupCalendar.Network:UserIsInSameGuild(vDatabase.UserName) then
			vDatabase.Faction = GroupCalendar.PlayerFactionGroup
		end
		
		-- Delete databases for anyone no longer trusted
		
		if GroupCalendar.Database.DatabaseIsVisible(vDatabase) then
			if not vDatabase.IsPlayerOwned then
				-- If they're not even trusted for attendance, eliminate them completely
				
				if not GroupCalendar.Network:UserIsTrusted(vDatabase.UserName, "RAT") then
					GroupCalendar.Database.DeleteDatabase(vDatabase)
				
				-- Otherwise just don't store and forward events for them
				
				elseif not GroupCalendar.Network:UserIsTrusted(vDatabase.UserName, "DB") then
					GroupCalendar.Database.DeleteDatabaseEvents(vDatabase)
				end
			end
		end
	end
end

function GroupCalendar.Database.UpdateFriendListFaction()
	local vNumFriends = GetNumFriends()
	
	if vNumFriends == 0 then
		return false
	end
	
	local vChanged = false
	
	for vIndex = 1, vNumFriends do
		local vName = GetFriendInfo(vIndex)
		
		if vName then
			local vDatabase = GroupCalendar.Database.GetDatabase(vName)
			
			if vDatabase and vDatabase.Faction ~= GroupCalendar.PlayerFactionGroup then
				vDatabase.Faction = GroupCalendar.PlayerFactionGroup
				vChanged = true
			end
		end
	end
	
	GroupCalendar_MajorDatabaseChange()
	
	return vChanged
end

function GroupCalendar.Database.GetDateTime60Stamp()
	local vYear, vMonth, vDay, vHour, vMinute, vSecond = MCDateLib:GetLocalYMDHMS()
	
	local vDate = GroupCalendar.ConvertMDYToDate(vMonth, vDay, vYear)
	local vTime60 = GroupCalendar.ConvertHMSToTime60(vHour, vMinute, vSecond)
	
	return vDate, vTime60
end

function GroupCalendar.Database.GetRSVPs(pDatabase)
	local vRSVPs = pDatabase.RSVPs
	
	if not vRSVPs then
		vRSVPs = CalendarChanges_New(nil, pDatabase.HighestKnownRSVPID)
		pDatabase.HighestKnownRSVPID = vRSVPs.ID;
		pDatabase.RSVPs = vRSVPs
	end
	
	return vRSVPs
end

function GroupCalendar.Database.AddEventRSVP(pDatabase, pEvent, pAttendeeName, pRSVP)
	-- Verify that the attendance request is newer than the existing one
	
	local vExistingRSVP = GroupCalendar.Database.FindEventRSVP(pDatabase.UserName, pEvent, pAttendeeName)

	if vExistingRSVP then
		if vExistingRSVP.mDate > pRSVP.mDate
		or (vExistingRSVP.mDate == pRSVP.mDate
		and vExistingRSVP.mTime > pRSVP.mTime) then
			-- Adjust the date/time to be one second later than the previous request
			-- if it's older
			
			pRSVP.mDate = vExistingRSVP.mDate
			pRSVP.mTime = vExistingRSVP.mTime + 1
			
			if pRSVP.mTime >= 86400 then
				pRSVP.mTime = 0
				pRSVP.mDate = pRSVP.mDate + 1
			end
		end
	end

	-- Update the event attendance list

	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugMessage("Database.AddEventRSVP: Updating event attendance for "..pAttendeeName.." for ".." event "..pRSVP.mEventID)
	end

	if not pEvent.mAttendance then
		pEvent.mAttendance = GroupCalendar.NewTable()
	end
	
	local vEventRSVPString = GroupCalendar.Database.PackEventRSVP(pRSVP)
	
	pEvent.mAttendance[pAttendeeName] = vEventRSVPString

	-- Notify the network of the change

	local vChangedFields =
	{
		mAttendance =
		{
			op = "UPD",
			val =
			{
			}
		}
	}
	
	vChangedFields.mAttendance.val[pAttendeeName] = vEventRSVPString
	
	GroupCalendar.Database.EventChanged(pDatabase, pEvent, vChangedFields)
end

function GroupCalendar.Database.RemoveEventRSVP(pDatabase, pEvent, pAttendeeName)
	if not pEvent.mAttendance then
		return
	end
	
	pEvent.mAttendance[pAttendeeName] = nil

	-- Notify the network of the change

	local vChangedFields =
	{
		mAttendance =
		{
			op = "UPD",
			val =
			{
				[pAttendeeName] = "-",
			}
		}
	}
	
	GroupCalendar.Database.EventChanged(pDatabase, pEvent, vChangedFields)
end

function GroupCalendar.Database.AddRSVPRequest(pDatabase, pRSVP)
	-- Remove any existing RSVP for the same event
	
	if not GroupCalendar.Database.RemoveOlderRSVP(pDatabase, pRSVP) then
		if GroupCalendar.Debug.Errors then
			GroupCalendar:DebugMessage("Database.AddRSVPRequest: Ignoring %s, %d: %s (newer request received)", pDatabase.UserName, pRSVP.mEventID, pRSVP.mStatus)
		end
		
		return -- A newer request already exists so disregard this one
	end
	
	-- Add the new RSVP

	local vChangeList = GroupCalendar.Database.GetNewChangeList(pDatabase, "RAT")
	local vRSVPString = GroupCalendar.Database.PackRSVPRequest(pRSVP)
	local vRSVPAltsString = GroupCalendar.Database.GetRSVPAltsString(pRSVP)
	
	if vRSVPAltsString then
		vRSVPString = vRSVPString.."/ALTS:"..vRSVPAltsString
	end
	
	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugMessage("Database.AddRSVPRequest: Adding string "..vRSVPString)
	end
	
	table.insert(vChangeList, vRSVPString)
	
	GroupCalendar_MajorDatabaseChange(pDatabase)
end

function GroupCalendar.Database.GetRSVPOriginalDateTime(pRSVP)
	if pRSVP.mOriginalDate then
		return pRSVP.mOriginalDate, pRSVP.mOriginalTime
	else
		return pRSVP.mDate, pRSVP.mTime
	end
end

function GroupCalendar.Database.RemoveAllRSVPsForEvent(pDatabase, pEvent, pOwnedDatabasesOnly)
	local vPrefix = "EVT:"..pDatabase.UserName..","..pEvent.mID..","
	local vPrefixLength = string.len(vPrefix)
	
	GroupCalendar.Database.RemoveAllRSVPsByPrefix(pDatabase.Realm, vPrefix, vPrefixLength, pOwnedDatabasesOnly)
end

function GroupCalendar.Database.RemoveAllRSVPsForDatabase(pDatabase, pOwnedDatabasesOnly)
	local vPrefix = "EVT:"..pDatabase.UserName..","
	local vPrefixLength = string.len(vPrefix)
	
	GroupCalendar.Database.RemoveAllRSVPsByPrefix(pDatabase.Realm, vPrefix, vPrefixLength, pOwnedDatabasesOnly)
end

function GroupCalendar.Database.RemoveAllRSVPsByPrefix(pRealm, pPrefix, pPrefixLength, pOwnedDatabasesOnly)
	for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if vDatabase.Realm == pRealm
		and (not pOwnedDatabasesOnly or vDatabase.IsPlayerOwned) then
			GroupCalendar.Database.RemoveRSVPsByPrefix(vDatabase, pPrefix, pPrefixLength)
		end
	end
end

function GroupCalendar.Database.RemoveRSVPsByPrefix(pAttendeeDatabase, pPrefix, pPrefixLength)
	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugMessage("Database.RemoveRSVPsByPrefix(%s, %s, %d)", pAttendeeDatabase.UserName, pPrefix, pPrefixLength)
	end
	
	local vRSVPString, vIndex, vRevision = GroupCalendar.Database.FindRSVPPrefixString(pAttendeeDatabase, pPrefix, pPrefixLength)
	local vDidRemove = false
	
	while vRSVPString do
		local vChangeList = pAttendeeDatabase.RSVPs.ChangeList[vRevision]
		
		table.remove(vChangeList, vIndex)
		vDidRemove = true
		
		if table.getn(vChangeList) == 0 then
			pAttendeeDatabase.RSVPs.ChangeList[vRevision] = nil
		end
		
		vRSVPString, vIndex, vRevision = GroupCalendar.Database.FindRSVPPrefixString(pAttendeeDatabase, pPrefix, pPrefixLength)
	end
	
	-- Rebuild the RSVP database to eliminate the old ones from the network
	
	if vDidRemove and pAttendeeDatabase.IsPlayerOwned then
		GroupCalendar.Database.RebuildRSVPs(pAttendeeDatabase)
	end
end

function GroupCalendar.Database.ProcessRSVP(pRSVP)
	-- ProcessRSVP is the low-level function for processing attendance requests.  It
	-- does not modify any change lists and is used to enter new requests as well as
	-- to rebuild the database.  AddRSVP is the high-level equivalent which should
	-- be used for most purposes.
	
	local vEventDatabase = GroupCalendar.Database.GetDatabase(pRSVP.mOrganizerName, false)
	
	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugMessage("Database.ProcessRSVP: From %s for %s", pRSVP.mName, pRSVP.mOrganizerName)
		--GroupCalendar:DebugStack()
		--GroupCalendar:DebugTable("RSVP", pRSVP, 2)
	end
	
	-- Nothing to do if the database isn't one we own
	
	if not vEventDatabase or not vEventDatabase.IsPlayerOwned then
		return false
	end
	
	-- Process the request into our database
	
	local vEvent = GroupCalendar.Database.FindEventByID(vEventDatabase, pRSVP.mEventID)
	
	if not vEvent then
		if GroupCalendar.Debug.AutoConfirm then
			GroupCalendar:DebugMessage("Database.ProcessRSVP: Discarding request from "..pRSVP.mName.." for ".." event "..pRSVP.mEventID..": Event no longer exists")
		end
		
		return true -- Have the request deleted
	end
	
	-- Look up an existing RSVP
	
	local vExistingRSVP = GroupCalendar.Database.FindEventRSVP(vEventDatabase.UserName, vEvent, pRSVP.mName)
	
	-- If the player has been banned (removed) from the event then ignore any
	-- requests from them
	
	if vExistingRSVP
	and vExistingRSVP.mStatus == "-" then
		GroupCalendar:NoteMessage(GroupCalendar.cAttendanceNoticeBanned, {name = pRSVP.mName, event = GroupCalendar.Database.GetEventDisplayName(vEvent)})
		
		-- Don't change the status but update the date/time stamp so that the request
		-- gets discarded
		
		pRSVP.mStatus = "-"
		
	-- If the player is requesting attendance then figure out how to handle the request
	
	elseif pRSVP.mStatus == "Y" then
		-- If they're already accepted as confirmed on the list and aren't
		-- changing roles or status then preserve their current status
		
		if vExistingRSVP and vExistingRSVP.mStatus == "Y" and vExistingRSVP.mRole == pRSVP.mRole then
			
			pRSVP.mOriginalDate, pRSVP.mOriginalTime = GroupCalendar.Database.GetRSVPOriginalDateTime(vExistingRSVP)
			pRSVP.mStatus = vExistingRSVP.mStatus
		
		-- Otherwise put them on standby if using manual confirmations
		
		elseif vEvent.mManualConfirm then
			GroupCalendar:NoteMessage(GroupCalendar.cAttendanceNoticeManual, {name = pRSVP.mName, event = GroupCalendar.Database.GetEventDisplayName(vEvent)})
			
			if vExistingRSVP and (vExistingRSVP.mStatus == "S" or vExistingRSVP.mStatus == "Y") then
				pRSVP.mOriginalDate, pRSVP.mOriginalTime = GroupCalendar.Database.GetRSVPOriginalDateTime(vExistingRSVP)
			end
			
			pRSVP.mStatus = "S"
			
		-- Check availablility to determine how to handle automatic confirmations
		
		elseif GroupCalendar.Database.IsQuestingEventType(vEvent.mType) then -- Don't use limits settings for non-questing events
			local vAvailableSlots = GroupCalendar.NewObject(GroupCalendar._AvailableSlots, vEvent.mLimits, tern(vEvent.mRoleConfirm, "ROLE", "CLASS"))
			
			vAvailableSlots:AddEventAttendance(vEventDatabase, vEvent, pRSVP.mName)
			
			if vAvailableSlots:AddPlayer(pRSVP.mClassCode, pRSVP.mRole) then
				if not vExistingRSVP or vExistingRSVP.mStatus ~= "Y" then
					GroupCalendar:NoteMessage(GroupCalendar.cAttendanceNoticeYes, {name = pRSVP.mName, event = GroupCalendar.Database.GetEventDisplayName(vEvent)})
				end
			else
				GroupCalendar:NoteMessage(GroupCalendar.cAttendanceNoticeStandby, {name = pRSVP.mName, event = GroupCalendar.Database.GetEventDisplayName(vEvent)})
				pRSVP.mStatus = "S"
			end
		end
		
		-- Save their role setting
		
		if pRSVP.mName and pRSVP.mRole and pRSVP.mRole ~= "?" then
			local vUserDatabase = GroupCalendar.Database.GetDatabase(pRSVP.mName)
		
			if vUserDatabase then
				vUserDatabase.DefaultRole = pRSVP.mRole
			end
		end
	
	elseif pRSVP.mStatus == "N" then
		GroupCalendar:NoteMessage(GroupCalendar.cAttendanceNoticeNo, {name = pRSVP.mName, event = GroupCalendar.Database.GetEventDisplayName(vEvent)})
	
	elseif pRSVP.mStatus == "S" then
		GroupCalendar:NoteMessage(GroupCalendar.cAttendanceNoticeStandby, {name = pRSVP.mName, event = GroupCalendar.Database.GetEventDisplayName(vEvent)})
	end
	
	-- Add the RSVP
	
	GroupCalendar.Database.AddEventRSVP(vEventDatabase, vEvent, pRSVP.mName, pRSVP)
	
	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugMark()
	end
	
	return true
end

function GroupCalendar.Database.AddRSVP(pDatabase, pRSVP)
	if GroupCalendar.Debug.Errors and not pRSVP.mName then
		GroupCalendar:DebugTable("Missing attendee: ", pRSVP)
		return
	end
	
	if GroupCalendar.Database.ProcessRSVP(pRSVP) then
		if GroupCalendar.Debug.AutoConfirm then
			GroupCalendar:DebugMessage("Database.AddRSVP: Completed processing of %s", pRSVP.mName)
		end
		return
	end
	
	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugMessage("Database.AddRSVP: Adding RSVP for %s", pRSVP.mName)
	end
	
	GroupCalendar.Database.AddRSVPRequest(pDatabase, pRSVP)
end

function GroupCalendar.Database.RemoveOldAttendeeRSVP(pAttendeeName, pOrganizerName, pEventID, pRSVP)
	local vAttendeeDatabase = GroupCalendar.Database.GetDatabase(pAttendeeName, false)
	
	-- Just leave if it's not ours
	
	if not vAttendeeDatabase
	or not vAttendeeDatabase.IsPlayerOwned then
		return
	end
	
	-- Remove the RSVP request if it exists in their database
	
	GroupCalendar.Database.RemoveOlderRSVP(vAttendeeDatabase, pRSVP)
end

function GroupCalendar.Database.RemoveOlderRSVP(pAttendeeDatabase, pRSVP)
	if not pAttendeeDatabase.IsPlayerOwned then
		GroupCalendar:ErrorMessage("RemoveOlderRSVP called for %s database (not player owned)", pAttendeeDatabase.UserName)
		GroupCalendar:DebugStack()
		return
	end
	
	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugMessage("Database.RemoveOlderRSVP: Removing RSVP for "..pRSVP.mName.." from "..pAttendeeDatabase.UserName..","..pRSVP.mEventID)
		GroupCalendar:DebugTable("    pRSVP", pRSVP)
	end
	
	local vRSVPString, vIndex, vRevision = GroupCalendar.Database.FindRSVPRequestString(pAttendeeDatabase, pRSVP.mOrganizerName, pRSVP.mEventID)
	
	while vRSVPString ~= nil do
		if GroupCalendar.Debug.AutoConfirm then
			GroupCalendar:DebugMessage("Database.RemoveOlderRSVP: "..pRSVP.mOrganizerName..","..pRSVP.mEventID.." from position "..vRevision..","..vIndex)
		end
		
		-- If the existing RSVP is newer than the specified date/time then disregard the request
		
		if pRSVP.mDate ~= nil then
			local vRSVP = GroupCalendar.Database.UnpackRSVPRequest(vRSVPString, pRSVP.mName)
			
			if vRSVP.mDate > pRSVP.mDate
			or (vRSVP.mDate == pRSVP.mDate and vRSVP.mTime > pRSVP.mTime) then
				if GroupCalendar.Debug.AutoConfirm then
					GroupCalendar:DebugMessage("Database.RemoveOlderRSVP: Newer request already exists")
				end
				
				return false -- Fail to indicate that a newer request is already in the database
			end
		end
		
		-- Remove the old one
		
		local vChangeList = pAttendeeDatabase.RSVPs.ChangeList[vRevision]
		table.remove(vChangeList, vIndex)
		
		if GroupCalendar.Database.RebuildRSVPQueue == nil then
			GroupCalendar.Database.RebuildRSVPQueue = {}
		end
		
		GroupCalendar.Database.RebuildRSVPQueue[pAttendeeDatabase] = true
		
		if table.getn(vChangeList) == 0 then
			pAttendeeDatabase.RSVPs.ChangeList[vRevision] = nil
		end
		
		-- Keep removing in case the database has become corrupted with multiple copies
		
		vRSVPString, vIndex, vRevision = GroupCalendar.Database.FindRSVPRequestString(pAttendeeDatabase, pRSVP.mOrganizerName, pRSVP.mEventID)
	end
	
	return true -- Everything's ok, no newer RSVP was found
end

function GroupCalendar.Database.FindRSVPRequestString(pAttendeeDatabase, pOrganizerName, pEventID)
	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugMessage("Database.FindRSVPRequestString(%s, %s, %d)", pAttendeeDatabase.UserName, pOrganizerName, pEventID)
	end
	
	if not pEventID then
		GroupCalendar:DebugMessage("Database.FindRSVPRequestString: pEventID IS nil")
	end
	
	if not pOrganizerName then
		GroupCalendar:DebugMessage("Database.FindRSVPRequestString: pOrganizerName IS nil")
	end
	
	local vRSVPPrefix = "EVT:"..pOrganizerName..","..pEventID..","
	local vRSVPPrefixLength = string.len(vRSVPPrefix)
	
	return GroupCalendar.Database.FindRSVPPrefixString(pAttendeeDatabase, vRSVPPrefix, vRSVPPrefixLength)
end

function GroupCalendar.Database.FindLastRSVPRequestString(pDatabase, pOrganizerName, pEventID)
	if not pEventID then
		GroupCalendar:DebugMessage("Database.FindLastRSVPRequestString: pEventID IS NIL!")
	end
	
	if not pOrganizerName then
		GroupCalendar:DebugMessage("Database.FindLastRSVPRequestString: pOrganizerName IS NIL!")
	end
	
	local vRSVPPrefix = "EVT:"..pOrganizerName..","..pEventID..","
	local vRSVPPrefixLength = string.len(vRSVPPrefix)
	
	return GroupCalendar.Database.FindLastRSVPPrefixString(pDatabase, vRSVPPrefix, vRSVPPrefixLength)
end

function GroupCalendar.Database.FindRSVPPrefixString(pAttendeeDatabase, pPrefixString, pPrefixLength)
	if GroupCalendar.Debug.AutoConfirm then
		GroupCalendar:DebugMessage("Database.FindRSVPPrefixString(%s, %s, %d)", pAttendeeDatabase.UserName, pPrefixString, pPrefixLength)
	end
	
	local vRSVPs = GroupCalendar.Database.GetRSVPs(pAttendeeDatabase)
	
	for vRevision = 1, vRSVPs.Revision do
		local vChangeList = vRSVPs.ChangeList[vRevision]
		
		if vChangeList then
			local vNumChanges = table.getn(vChangeList)
			
			for vIndex = 1, vNumChanges do
				local vRSVP = vChangeList[vIndex]
				
				if string.sub(vRSVP, 1, pPrefixLength) == pPrefixString then
					return vRSVP, vIndex, vRevision
				end
			end
		end
	end
	
	return nil, nil, nil
end

function GroupCalendar.Database.FindLastRSVPPrefixString(pDatabase, pPrefixString, pPrefixLength)
	local vRSVPs = GroupCalendar.Database.GetRSVPs(pDatabase)
	local vLastRSVP, vLastIndex, vLastRevision
	
	for vRevision = 1, vRSVPs.Revision do
		local vChangeList = vRSVPs.ChangeList[vRevision]
		
		if vChangeList then
			local vNumChanges = table.getn(vChangeList)
			
			for vIndex = 1, vNumChanges do
				local vRSVP = vChangeList[vIndex]
				
				if string.sub(vRSVP, 1, pPrefixLength) == pPrefixString then
					vLastRSVP, vLastIndex, vLastRevision = vRSVP, vIndex, vRevision
				end
			end
		end
	end
	
	return vLastRSVP, vLastIndex, vLastRevision
end

function GroupCalendar.Database.FindRSVPRequestData(pAttendeeDatabase, pOrganizerName, pEventID)
	if not pEventID then
		GroupCalendar:DebugMessage("Database.FindRSVPRequestData: pEventID is nil!")
	end
	
	if not pOrganizerName then
		GroupCalendar:DebugMessage("Database.FindRSVPRequestData: pOrganizerName IS NIL!")
	end
	
	local vRSVPString = GroupCalendar.Database.FindRSVPRequestString(pAttendeeDatabase, pOrganizerName, pEventID)
	
	if not vRSVPString then
		return nil
	end
	
	return GroupCalendar.Database.UnpackRSVPRequest(vRSVPString, pAttendeeDatabase.UserName)
end

function GroupCalendar.Database.FindLastRSVPRequestData(pDatabase, pOrganizerName, pEventID)
	if not pEventID then
		GroupCalendar:DebugMessage("Database.FindLastRSVPRequestData: pEventID is nil!")
	end
	
	if not pOrganizerName then
		GroupCalendar:DebugMessage("Database.FindLastRSVPRequestData: pOrganizerName IS NIL!")
	end
	
	local vRSVPString = GroupCalendar.Database.FindLastRSVPRequestString(pDatabase, pOrganizerName, pEventID)
	
	if not vRSVPString then
		-- GroupCalendar:TestMessage("Database.FindLastRSVPRequestData: No data found for "..pDatabase.UserName.." "..pOrganizerName.." "..pEventID)
		return nil
	end
	
	-- GroupCalendar:TestMessage("Database.FindLastRSVPRequestData: Found "..vRSVPString.." for "..pDatabase.UserName.." "..pOrganizerName.." "..pEventID)
	
	return GroupCalendar.Database.UnpackRSVPRequest(vRSVPString, pDatabase.UserName)
end

function GroupCalendar.Database.FindEventRSVPString(pEvent, pAttendeeName)
	if not pEvent.mAttendance then
		return nil
	end
	
	return pEvent.mAttendance[pAttendeeName]
end

function GroupCalendar.Database.FindEventRSVP(pEventOwner, pEvent, pAttendeeName)
	if not pEvent.mAttendance then
		return nil
	end
	
	local vEventRSVPString = pEvent.mAttendance[pAttendeeName]
	
	if not vEventRSVPString then
		return nil
	end
	
	return GroupCalendar.Database.UnpackEventRSVP(pEventOwner, pAttendeeName, pEvent.ID, vEventRSVPString)
end

function GroupCalendar.Database.EventExists(pEventOwner, pEventID)
	local vDatabase = GroupCalendar.Database.GetDatabase(pEventOwner, false)
	
	if not vDatabase then
		return false
	end
	
	if not GroupCalendar.Database.FindEventByID(vDatabase, pEventID) then
		return false
	end
	
	return true
end

function GroupCalendar.Database.RemoveObsoleteRSVPs(pDatabase)
	local vRSVPs = GroupCalendar.Database.GetRSVPs(pDatabase)
	
	for vRevision = 1, vRSVPs.Revision do
		local vChangeList = vRSVPs.ChangeList[vRevision]
		
		if vChangeList then
			local vNumChanges = table.getn(vChangeList)
			local vIndex = 1
			
			while vIndex <= vNumChanges do
				local vRSVP = GroupCalendar.Database.UnpackRSVPRequest(vChangeList[vIndex], pDatabase.UserName)
				
				if not GroupCalendar.Database.EventExists(vRSVP.mOrganizerName, vRSVP.mEventID) then
					table.remove(vChangeList, vIndex)
					vNumChanges = vNumChanges - 1
				else
					vIndex = vIndex + 1
				end
			end
			
			if vNumChanges == 0 then
				vRSVPs.ChangeList[vRevision] = nil
			end
		end
	end
end

function GroupCalendar.Database.GetRSVPAltsString(pRSVP)
	local vAltsString = nil
	
	if not pRSVP.mAlts then
		return nil
	end
	
	for vPlayerName, _ in pairs(pRSVP.mAlts) do
		if not vAltsString then
			vAltsString = vPlayerName
		else
			vAltsString = vAltsString..","..vPlayerName
		end
	end
	
	return vAltsString
end

function GroupCalendar.Database.PackRSVPRequest(pRSVP)
	if not pRSVP.mStatus then
		GroupCalendar:DebugTable("PackRSVPRequest: pRSVP", pRSVP)
	end
	
	return string.format("EVT:%s,%d,%d,%d,%s,%s,%s,%s,%s,%s",
			pRSVP.mOrganizerName,
			pRSVP.mEventID,
			pRSVP.mDate,
			pRSVP.mTime,
			pRSVP.mStatus,
			GroupCalendar.Database.PackCharInfo(pRSVP),
			pRSVP.mComment or "",
			pRSVP.mGuild or "",
			pRSVP.mGuildRank or "",
			pRSVP.mRole or "")
end

function GroupCalendar.Database.UnpackRSVPRequest(pRSVPString, pAttendee)
	local vCommands = GroupCalendar.Network:ParseCommandString(pRSVPString)
	local vOpcode = vCommands[1].opcode
	
	if vOpcode ~= "EVT" then
		return false
	end
	
	local vOperands = vCommands[1].operands
	
	return GroupCalendar.Database.UnpackRSVPFieldArray(vOperands, pAttendee)
end

function GroupCalendar.Database.UnpackRSVPFieldArray(pArray, pAttendee)
	local vRSVP = GroupCalendar.NewTable()
	
	vRSVP.mOrganizerName = pArray[1]
	vRSVP.mName = pAttendee
	vRSVP.mEventID = tonumber(pArray[2])
	vRSVP.mDate = tonumber(pArray[3])
	vRSVP.mTime = tonumber(pArray[4])
	vRSVP.mStatus = pArray[5]
	vRSVP.mComment = pArray[7]
	vRSVP.mGuild = pArray[8]
	vRSVP.mGuildRank = tonumber(pArray[9])
	vRSVP.mRole = pArray[10]
	
	if vRSVP.mGuild == "" then
		vRSVP.mGuild = nil
	end
	
	GroupCalendar.Database.UnpackCharInfo(pArray[6], vRSVP)
	
	GroupCalendar.Database.FillInRSVPGuildInfo(vRSVP)
	
	return vRSVP
end

function GroupCalendar.Database.FillInRSVPGuildInfo(pRSVP)
	if pRSVP.mGuild then	
		return
	end
	
	vIsInGuild, vRankIndex = GroupCalendar.Network:UserIsInSameGuild(pRSVP.mName)
	
	if not vIsInGuild then
		return
	end
	
	pRSVP.mGuild = GroupCalendar.PlayerGuild
	pRSVP.mGuildRank = vRankIndex
end

function GroupCalendar.Database.PackEventRSVP(pEventRSVP)
	return string.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s",
			pEventRSVP.mDate,
			pEventRSVP.mTime,
			pEventRSVP.mStatus,
			GroupCalendar.Database.PackCharInfo(pEventRSVP),
			pEventRSVP.mComment or "",
			pEventRSVP.mGuild or "",
			pEventRSVP.mGuildRank or "",
			pEventRSVP.mOriginalDate or "",
			pEventRSVP.mOriginalTime or "",
			pEventRSVP.mRole or "")
end

function GroupCalendar.Database.UnpackEventRSVP(pOrganizerName, pAttendeeName, pEventID, pEventRSVPString)
	local vEventParameters = GroupCalendar.Network:ParseParameterString(pEventRSVPString)
	
	local vRSVPFields = GroupCalendar.NewTable()
	
	vRSVPFields.mOrganizerName = pOrganizerName
	vRSVPFields.mName = pAttendeeName
	vRSVPFields.mEventID = pEventID
	vRSVPFields.mDate = tonumber(vEventParameters[1])
	vRSVPFields.mTime = tonumber(vEventParameters[2])
	vRSVPFields.mStatus = vEventParameters[3]
	GroupCalendar.Database.UnpackCharInfo(vEventParameters[4], vRSVPFields)
	vRSVPFields.mComment = vEventParameters[5]
	vRSVPFields.mGuild = vEventParameters[6]
	vRSVPFields.mGuildRank = tonumber(vEventParameters[7])
	vRSVPFields.mOriginalDate = tonumber(vEventParameters[8])
	vRSVPFields.mOriginalTime = tonumber(vEventParameters[9])
	vRSVPFields.mRole = vEventParameters[10]
	
	if vRSVPFields.mGuild == "" then
		vRSVPFields.mGuild = nil
	end
	
	GroupCalendar.Database.FillInRSVPGuildInfo(vRSVPFields)
	
	GroupCalendar.DeleteTable(vEventParameters)
	
	return vRSVPFields
end

function GroupCalendar.Database.PackCharInfo(pCharInfo)
	local vRaceCode, vClassCode, vLevel
	
	vRaceCode = pCharInfo.mRaceCode
	
	if not vRaceCode then
		vRaceCode = "?"
	end
	
	vClassCode = pCharInfo.mClassCode
	
	if not vClassCode then
		vClassCode = "?"
	end
	
	if pCharInfo.mLevel then
		vLevel = pCharInfo.mLevel
	else
		vLevel = 0
	end
	
	return vRaceCode..vClassCode..vLevel
end

function GroupCalendar.Database.GetRaceCodeByRaceID(pRaceID)
	return GroupCalendar.RaceCodeByRaceID[pRaceID] or "?"
end

function GroupCalendar.Database.GetRaceCodeByRace(pRace)
	return GroupCalendar.RaceCodeByRace[pRace] or "?"
end

function GroupCalendar.Database.GetRaceByRaceCode(pRaceCode)
	local vRaceInfo = GroupCalendar.RaceNamesByRaceCode[pRaceCode]
	
	if not vRaceInfo then
		return nil
	end
	
	return vRaceInfo.name
end

function GroupCalendar.Database.GetClassCodeByClass(pClass)
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		if pClass == vClassInfo.femaleName or pClass == vClassInfo.maleName then
			return vClassCode
		end
	end
	
	return "?"
end

function GroupCalendar.Database.GetClassCodeByClassID(pClassID)
	for vClassCode, vClassInfo in pairs(GroupCalendar.ClassInfoByClassCode) do
		if pClassID == vClassInfo.classID then
			return vClassCode
		end
	end
	
	return "?"
end

function GroupCalendar.Database.GetClassByClassCode(pClassCode)
	local vClassInfo = GroupCalendar.ClassInfoByClassCode[pClassCode]
	
	if not vClassInfo then
		if pClassCode then
			return "Unknown ("..pClassCode..")"
		else
			return "Unknown (nil)"
		end
	else
		return vClassInfo.maleName
	end
end

function GroupCalendar.Database.UnpackCharInfo(pString, rCharInfo)
	if not pString then
		rCharInfo.mRaceCode = "?"
		rCharInfo.mClassCode = "?"
		rCharInfo.mLevel = 0
	else
		rCharInfo.mRaceCode = string.sub(pString, 1, 1)
		rCharInfo.mClassCode = string.sub(pString, 2, 2)
		rCharInfo.mLevel = tonumber(string.sub(pString, 3))
	end
end
	
function GroupCalendar.Database.IsQuestingEventType(pEventType)
	local vEventInfo = GroupCalendar.EventInfoByID[pEventType]
	
	if not vEventInfo then
		return true
	end
	
	return not vEventInfo.notQuesting
end

function GroupCalendar.Database.IsResetEventType(pEventType)
	if not pEventType then
		return false
	end
	
	return GroupCalendar.EventTypes.Reset.ResetEventInfo[pEventType] ~= nil
end

function GroupCalendar.Database.GetResetIconCoords(pEventType)
	if not pEventType then
		return nil
	end
	
	return GroupCalendar.EventTypes.Reset.ResetEventInfo[pEventType]
end

function GroupCalendar.Database.GetResetEventLargeIconPath(pEventType)
	if not pEventType then
		return nil
	end
	
	local vResetEventInfo = GroupCalendar.EventTypes.Reset.ResetEventInfo[pEventType]
	
	if vResetEventInfo.largeIcon then
		return vResetEventInfo.largeIcon, false
	elseif vResetEventInfo.largeSysIcon then
		return vResetEventInfo.largeSysIcon, true
	else
		return nil
	end
end

function GroupCalendar.Database.IsDungeonResetEventType(pEventType)
	if not pEventType then
		return false
	end
	
	local vResetEventInfo = GroupCalendar.EventTypes.Reset.ResetEventInfo[pEventType]
	
	if not vResetEventInfo then
		return false
	end
	
	return vResetEventInfo.isDungeon
end

function GroupCalendar.Database.LookupDungeonResetEventTypeByName(pName)
	for vEventType, vResetEventInfo in pairs(GroupCalendar.EventTypes.Reset.ResetEventInfo) do
		if vResetEventInfo.isDungeon then
			if vResetEventInfo.name == pName then
				return vEventType, vResetEventInfo
			end
		end
	end
	
	return nil
end

function GroupCalendar.Database.LookupTradeskillEventTypeByID(pID)
	for vEventType, vResetEventInfo in pairs(GroupCalendar.EventTypes.Reset.ResetEventInfo) do
		if vResetEventInfo.isTradeskill then
			if vResetEventInfo.id == pID then
				return vEventType
			end
		end
	end
	
	return nil
end

function GroupCalendar.Database.EventTypeUsesAttendance(pEventType)
	local vEventInfo = GroupCalendar.EventInfoByID[pEventType]
	
	if vEventInfo then
		return not vEventInfo.noAttendance
	end
	
	return not GroupCalendar.Database.IsResetEventType(pEventType)
end

function GroupCalendar.Database.EventTypeUsesLevelLimits(pEventType)
	local vEventInfo = GroupCalendar.EventInfoByID[pEventType]
	
	if vEventInfo then
		return not vEventInfo.notQuesting
	end
	
	return not GroupCalendar.Database.IsResetEventType(pEventType)
end

function GroupCalendar.Database.EventTypeUsesTime(pEventType)
	local vEventInfo = GroupCalendar.EventInfoByID[pEventType]
	
	if vEventInfo then
		return not vEventInfo.allDay
	end
	
	return true
end

function GroupCalendar.Database.IsPrivateEventType(pEventType)
	local vEventInfo = GroupCalendar.EventInfoByID[pEventType]
	
	if vEventInfo then
		return vEventInfo.isPrivate
	end
	
	return GroupCalendar.Database.IsResetEventType(pEventType)
end

function CalendarChanges_New(pID, pMinID)
	local vID
	
	if pID then
		vID = pID
	else
		vID = MCDateLib:GetUTCDateTimeStamp()
	end
	
	if pMinID and vID <= pMinID then
		vID = pMinID + 1
	end
	
	return
	{
		ID = vID,
		Revision = 0,
		AuthRevision = 0,
		ChangeList = {},
	}
end

function CalendarChanges_Erase(pChanges, pID)
	local vOldChangeList
	
	if not pChanges then
		pChanges = {}
	else
		vOldChangeList = pChanges.ChangeList -- Save this table for recycling
		GroupCalendar.EraseTable(pChanges)
	end
	
	local vID
	
	if pID then
		vID = pID
	else
		vID = MCDateLib:GetUTCDateTimeStamp()
	end
	
	pChanges.ID = vID
	pChanges.Revision = 0
	pChanges.AuthRevision = 0
	pChanges.ChangeList = GroupCalendar.RecycleTable(vOldChangeList)
	
	return pChanges
end

function CalendarChanges_Compact(pChanges, pHighestKnownID)
	local vNewChanges = nil
	
	for vRevision = 1, pChanges.Revision do
		local vChangeList = pChanges.ChangeList[vRevision]
		
		if vChangeList then
			for vIndex, vChange in ipairs(vChangeList) do
				if not vNewChanges then
					vNewChanges = {}
				end
				
				if type(vIndex) == "number" then
					table.insert(vNewChanges, vChange)
				end
			end
		end
	end
	
	pChanges.ID = MCDateLib:GetUTCDateTimeStamp()
	
	if pHighestKnownID and pChanges.ID <= pHighestKnownID then
		pChanges.ID = pHighestKnownID + 1
	end
	
	pChanges.ChangeList = {}
	
	if vNewChanges then
		pChanges.Revision = 1
		pChanges.AuthRevision = 0
		pChanges.ChangeList[1] = vNewChanges
	else
		pChanges.Revision = 0
		pChanges.AuthRevision = 0
	end
end

function CalendarChanges_Open(pChanges, pRevision)
	local vChangeList = pChanges.ChangeList[pRevision]
	
	if not vChangeList then
		vChangeList = {}
		pChanges.ChangeList[pRevision] = vChangeList
		pChanges.Revision = pRevision
	end
	
	-- vChangeList.IsOpen = true
	vChangeList.IsOpen = nil
	
	return vChangeList
end

function CalendarChanges_Close(pChanges, pRevision)
	local vChangeList = pChanges.ChangeList[pRevision]
	
	if not vChangeList then
		return
	end
	
	vChangeList.IsOpen = nil
end

function CalendarChanges_SetChangeList(pChanges, pRevision, pChangeList)
	if not pChanges.ChangeList then
		GroupCalendar:DebugMessage("SetChangeList: Changes.ChangeList is nil")
		GroupCalendar:DebugTable("    pChanges", pChanges)
		GroupCalendar:DebugStack()
		GroupCalendar:DebugMark()
	end
	
	pChanges.ChangeList[pRevision] = pChangeList
	
	if pRevision > pChanges.Revision then
		pChanges.Revision = pRevision
	end
end

function CalendarChanges_GetNewChangeList(pChanges)
	local vChangeList = nil
	local vRevisionChanged = false
	
	if pChanges.Revision > 0 then
		vChangeList = pChanges.ChangeList[pChanges.Revision]
	end
	
	--[[
	if vChangeList == nil
	or not vChangeList.IsOpen then
		pChanges.Revision = pChanges.Revision + 1
		
		vChangeList = {}
		pChanges.ChangeList[pChanges.Revision] = vChangeList
		
		vRevisionChanged = true
	end
	]]--
	
	pChanges.Revision = pChanges.Revision + 1
	
	vChangeList = {}
	pChanges.ChangeList[pChanges.Revision] = vChangeList
	
	vRevisionChanged = true
	
	return vChangeList, vRevisionChanged
end

function CalendarChanges_LockdownCurrentChangeList(pChanges)
	-- Just return if there are no changes yet
	
	if not pChanges
	or pChanges.Revision == 0 then
		return
	end
	
	-- See if the current list exists and is open
	
	local vChangeList = pChanges.ChangeList[pChanges.Revision]
	
	if not vChangeList
	or not vChangeList.IsOpen then
		return
	end
	
	-- Close the change list
	
	vChangeList.IsOpen = nil
end

function CalendarChanges_GetRevisionPath(pLabel, pUserName, pDatabaseID, pRevision, pAuthRevision)
	local vPath = pLabel..":"..pUserName..","
	
	if pDatabaseID then
		vPath = vPath..pDatabaseID
	end
	
	vPath = vPath..","..pRevision
	
	if pAuthRevision then
		vPath = vPath..","..pAuthRevision
	end
	
	return vPath.."/"
end

function CalendarChanges_GetQuickRevisionPath(pLabel, pRevision, pAuthRevision)
	local vPath = pLabel..":*,"..pRevision
	local vPath2 = pLabel..":*,*"
	
	if pAuthRevision then
		vPath = vPath..","..pAuthRevision
		vPath2 = vPath2..","..pAuthRevision
	end
	
	return vPath.."/", vPath2.."/"
end

function CalendarChanges_IsEmpty(pChanges)
	if not pChanges
	or pChanges.Revision == 0 then
		return true
	end
	
	return next(pChanges.ChangeList) == nil
end

function CalendarChanges_GetChangeList(pChanges, pRevision)
	return pChanges.ChangeList[pRevision]
end

GroupCalendar._AttendanceList = {}

function GroupCalendar._AttendanceList:Construct()
	self.NumCategories = 0
	self.NumPlayers = 0
	self.NumAttendees = 0
	self.Categories = {}
	self.SortedCategories = {}
	self.Items = {}
end

function GroupCalendar._AttendanceList:RemoveCategory(pCategoryID)
	local vClassInfo = self.Categories[pCategoryID]
	
	if not vClassInfo then
		return false
	end
	
	self.NumPlayers = self.NumPlayers - table.getn(vClassInfo.mAttendees)
	self.NumCategories = self.NumCategories - 1
	
	-- Remove it from the sorted categories
	
	for vIndex, vCategoryID in ipairs(self.SortedCategories) do
		if vCategoryID == pCategoryID then
			table.remove(self.SortedCategories, vIndex)
		end
	end

	self.Categories[pCategoryID] = nil
	return true
end

function GroupCalendar._AttendanceList:AddItem(pCategoryID, pItem, pStandby)
	if not pItem then
		GroupCalendar:ErrorMessage("_AttendanceList:AddItem: pItem is nil")
		return
	end
	
	if not pCategoryID then
		GroupCalendar:ErrorMessage("_AttendanceList:AddItem: pCategoryID is nil")
		return
	end
	
	local vClassInfo = self.Categories[pCategoryID]
	
	if not vClassInfo then
		vClassInfo = {mCount = 0, mStandbyCount = 0, mClassCode = pCategoryID, mAttendees = {}}
		self.Categories[pCategoryID] = vClassInfo
		
		self.NumCategories = self.NumCategories + 1
	end
	
	if pStandby then
		vClassInfo.mStandbyCount = vClassInfo.mStandbyCount + 1
	else
		-- If this is the first visible entry add the category to the sorted list
		
		if vClassInfo.mCount == 0 then
			table.insert(self.SortedCategories, pCategoryID)
		end
		
		--
		
		vClassInfo.mCount = vClassInfo.mCount + 1
		
		table.insert(vClassInfo.mAttendees, pItem)
	end
	
	self.NumPlayers = self.NumPlayers + 1
end

function GroupCalendar._AttendanceList:AddWhisper(pPlayerName, pWhispers)
	local vPlayer =
	{
		mName = pPlayerName,
		mWhispers = pWhispers.mWhispers,
	}
	
	local vGuildMemberIndex = GroupCalendar.Network:GetGuildMemberIndex(pPlayerName)
	
	if vGuildMemberIndex then
		local vMemberName, vRank, vRankIndex,
				vLevel, vClass, vZone, vNote,
				vOfficerNote, vOnline = GetGuildRosterInfo(vGuildMemberIndex)
		
		vPlayer.mLevel = vLevel
		vPlayer.mClassCode = GroupCalendar.Database.GetClassCodeByClass(vClass)
		vPlayer.mZone = vZone
		vPlayer.mOnline = vOnline
	end
	
	vPlayer.mDate = pWhispers.mDate
	vPlayer.mTime = pWhispers.mTime
	vPlayer.mType = "Whisper"
	
	return self:AddItem("WHISPERS", vPlayer)
end

function GroupCalendar._AttendanceList:AddEventAttendanceItems(pDatabase, pEvent)
	if not pEvent.mAttendance then
		return
	end
	
	for vAttendeeName, vRSVPString in pairs(pEvent.mAttendance) do
		local vRSVP = GroupCalendar.Database.UnpackEventRSVP(pDatabase.UserName, vAttendeeName, pEvent.mID, vRSVPString)
		
		self.Items[vRSVP.mName] = vRSVP
	end
end

function GroupCalendar._AttendanceList:AddPendingRequests(pDatabase, pEvent)
	for vRealmUser, vDatabase in pairs(gGroupCalendar_Database.Databases) do
		if GroupCalendar.Database.DatabaseIsVisible(vDatabase) then
			local vPendingRSVP = GroupCalendar.Database.FindRSVPRequestData(vDatabase, pDatabase.UserName, pEvent.mID)
			
			if vPendingRSVP then
				local vExistingRSVP = GroupCalendar.Database.FindEventRSVP(pDatabase.UserName, pEvent, vPendingRSVP.mName)
				
				if not vExistingRSVP or GroupCalendar.Database.CompareRSVPsByDate(vExistingRSVP, vPendingRSVP) then
					if vPendingRSVP.mStatus == "Y" then
						vPendingRSVP.mStatus = "P"
					end
					
					self:AddItem("PENDING", vPendingRSVP)
				end
			end
		end
	end
end

function GroupCalendar._AttendanceList:FindItem(pFieldName, pFieldValue, pCategoryID)
	if not pFieldValue then
		GroupCalendar:DebugMessage("AttendanceList:FindItem: pFieldValue is nil for "..pFieldName)
		return nil
	end
	
	local vLowerFieldValue = strlower(pFieldValue)
	
	-- Search all categories if none is specified
	
	if not pCategoryID then
		for vCategoryID, vCategoryInfo in pairs(self.Categories) do
			for vIndex, vItem in ipairs(vCategoryInfo.mAttendees) do
				local vItemFieldValue = vItem[pFieldName]
				
				if vItemFieldValue
				and strlower(vItemFieldValue) == vLowerFieldValue then
					return vItem
				end
			end
		end
	
	-- Search the specified category
	
	else
		local vCategoryInfo = self.Categories[pCategoryID]
		
		if not vCategoryInfo then
			return nil
		end
		
		for vIndex, vItem in ipairs(vCategoryInfo.mAttendees) do
			if strlower(vItem[pFieldName]) == vLowerFieldValue then
				return vItem
			end
		end
	end
	
	return nil
end

function GroupCalendar._AttendanceList:SortIntoCategories(pGetItemCategoryFunction)
	-- Clear the existing categories
	
	self.Categories = {}
	self.SortedCategories = {}
	
	--
	
	local vTotalAttendees = 0
	local vTotalStandby = 0
	
	for vName, vItem in pairs(self.Items) do
		local vCategoryID, vRealCategoryID = pGetItemCategoryFunction(vItem)
		
		if vCategoryID then -- nil categories are to be ignored (canceled attendance requests)
			if vCategoryID ~= "NO"
			and vCategoryID ~= "BANNED" then
				vTotalAttendees = vTotalAttendees + 1

				if vCategoryID == "STANDBY" then
					vTotalStandby = vTotalStandby + 1
					
					if vRealCategoryID then
						self:AddItem(vRealCategoryID, vItem, true)
					end
				end
			end
			
			self:AddItem(vCategoryID, vItem)
		end
	end
	
	self.NumAttendees = vTotalAttendees
	self.NumStandby = vTotalStandby
end

function GroupCalendar.GetRSVPStatusCategory(pItem)
	-- Ignore canceled requests
	
	if pItem.mStatus == "C" then return end
	
	--
	
	if pItem.mStatus == "N" then
		return "NO"
	elseif pItem.mStatus == "S" then
		return "STANDBY"
	elseif pItem.mStatus == "M" then
		return "MAYBE"
	elseif pItem.mStatus == "Q" then
		return "QUEUED"
	elseif pItem.mStatus == "-" then
		return "BANNED"
	else
		return "YES"
	end
end

function GroupCalendar.GetRSVPRoleCategory(pItem)
	local vCategoryID = GroupCalendar.GetRSVPStatusCategory(pItem)
	
	if not vCategoryID then
		return nil
	end
	
	if vCategoryID ~= "YES" then
		return vCategoryID, pItem.mRole or "?"
	end
	
	return pItem.mRole or "?"
end

function GroupCalendar.GetRSVPClassCategory(pItem)
	local vCategoryID = GroupCalendar.GetRSVPStatusCategory(pItem)
	
	if not vCategoryID then
		return nil
	end
	
	if vCategoryID ~= "YES" then
		return vCategoryID, pItem.mClassCode or "?"
	end
	
	return pItem.mClassCode or "?"
end

function CalendarEvent_GetAttendanceList(pDatabase, pEvent, pGroupBy)
	local vAttendanceList = GroupCalendar.NewObject(GroupCalendar._AttendanceList)
	
	-- Fill in the items list
	
	vAttendanceList:AddEventAttendanceItems(pDatabase, pEvent)
	
	-- Sort into categories
	
	local vGetItemCategoryFunction
	
	if pGroupBy == "Role" then
		vGetItemCategoryFunction = GroupCalendar.GetRSVPRoleCategory
	elseif pGroupBy == "Class" then
		vGetItemCategoryFunction = GroupCalendar.GetRSVPClassCategory
	else
		vGetItemCategoryFunction = GroupCalendar.GetRSVPStatusCategory
	end
	
	vAttendanceList:SortIntoCategories(vGetItemCategoryFunction)
	
	-- Add pending requests
	
	vAttendanceList:AddPendingRequests(pDatabase, pEvent)
	
	-- Done
	
	return vAttendanceList
end

function CalendarEvent_SortAttendanceCounts(pAttendanceCounts, pGroupBy, pSortBy)
	-- Sort the categories
	
	if pGroupBy == "Class" then
		table.sort(pAttendanceCounts.SortedCategories, GroupCalendar.Database.CompareClassCodes)
	elseif pGroupBy == "Role" then
		table.sort(pAttendanceCounts.SortedCategories, GroupCalendar.Database.CompareRoleCodes)
	else
		table.sort(pAttendanceCounts.SortedCategories, GroupCalendar.Database.CompareRankCodes)
	end
	
	-- Sort the attendance within each category
	
	local vCompareFunction
	
	if pSortBy == "Name" then
		vCompareFunction = GroupCalendar.Database.CompareRSVPsByName
	elseif pSortBy == "Date" then
		vCompareFunction = GroupCalendar.Database.CompareRSVPsByDate
	elseif pSortBy == "Rank" then
		vCompareFunction = GroupCalendar.Database.CompareRSVPsByRankAndDate
	end
	
	for vCategory, vClassInfo in pairs(pAttendanceCounts.Categories) do
		table.sort(vClassInfo.mAttendees, vCompareFunction)
	end
end

function GroupCalendar.Database.CompareRSVPsByDate(pRSVP1, pRSVP2)
	local vRSVP1Date, vRSVP1Time = GroupCalendar.Database.GetRSVPOriginalDateTime(pRSVP1)
	local vRSVP2Date, vRSVP2Time = GroupCalendar.Database.GetRSVPOriginalDateTime(pRSVP2)

	if not vRSVP1Date then
		return false
	elseif not vRSVP2Date then
		return true
	end
	
	if vRSVP1Date < vRSVP2Date then
		return true
	elseif vRSVP1Date > vRSVP2Date then
		return false
	elseif vRSVP1Time ~= vRSVP2Time then
		return vRSVP1Time < vRSVP2Time
	else
		return GroupCalendar.Database.CompareRSVPsByName(pRSVP1, pRSVP2)
	end
end

function GroupCalendar.Database.CompareRSVPsByName(pRSVP1, pRSVP2)
	return pRSVP1.mName < pRSVP2.mName
end

function GroupCalendar.Database.CompareRSVPsByRole(pRSVP1, pRSVP2)
	if not pRSVP1.mRole then
		return false
	end
	
	if not pRSVP2.mRole then
		return true
	end
	
	return GroupCalendar.RoleInfoByID[pRSVP1.mRole].SortPriority < GroupCalendar.RoleInfoByID[pRSVP2.mRole].SortPriority
end

function GroupCalendar.Database.CompareRSVPsByClass(pRSVP1, pRSVP2)
	return GroupCalendar.Database.CompareClassCodes(pRSVP1.mClassCode, pRSVP2.mClassCode)
end

function GroupCalendar.Database.CompareRSVPsByRankAndDate(pRSVP1, pRSVP2)
	local vRank1 = GroupCalendar.Database.MapGuildRank(pRSVP1.mGuild, pRSVP1.mGuildRank)
	local vRank2 = GroupCalendar.Database.MapGuildRank(pRSVP2.mGuild, pRSVP2.mGuildRank)
	
	if not vRank1 then
		if not vRank2 then
			return GroupCalendar.Database.CompareRSVPsByDate(pRSVP1, pRSVP2)
		else
			return false
		end
	elseif not vRank2 then
		return true
	end
	
	if vRank1 == vRank2 then
		return GroupCalendar.Database.CompareRSVPsByDate(pRSVP1, pRSVP2)
	else
		return vRank1 < vRank2
	end
end

GroupCalendar.cStatusCodeSortOrder =
{
	WHISPERS = 4,
	PENDING = 3,
	QUEUED = 2,
	YES = 1,
	STANDBY = -1,
	MAYBE = -2,
	NO = -3,
	BANNED = -4,
}

function GroupCalendar.Database.CompareClassCodes(pClassCode1, pClassCode2)
	-- This function works a little differently than it may seem.  The codes
	-- passed in are compared as class codes, but if they match a status code
	-- then they're sorted by that instead
	
	local vSortPriority1 = GroupCalendar.cStatusCodeSortOrder[pClassCode1]
	local vSortPriority2 = GroupCalendar.cStatusCodeSortOrder[pClassCode2]
	
	if vSortPriority1 then
		if not vSortPriority2 then
			return vSortPriority1 > 0
		end
		
		return vSortPriority1 > vSortPriority2
	end
	
	if vSortPriority2 then
		return vSortPriority2 < 0
	end
	
	return GroupCalendar.Database.GetClassByClassCode(pClassCode1) < GroupCalendar.Database.GetClassByClassCode(pClassCode2)
end

function GroupCalendar.Database.CompareRoleCodes(pRoleCode1, pRoleCode2)
	-- This function works a little differently than it may seem.  The codes
	-- passed in are compared as role codes, but if they match a status code
	-- then they're sorted by that instead
	
	local vSortPriority1 = GroupCalendar.cStatusCodeSortOrder[pRoleCode1]
	local vSortPriority2 = GroupCalendar.cStatusCodeSortOrder[pRoleCode2]
	
	if vSortPriority1 then
		if not vSortPriority2 then
			return vSortPriority1 > 0
		end
		
		return vSortPriority1 > vSortPriority2
	end
	
	if vSortPriority2 then
		return vSortPriority2 < 0
	end
	
	-- Compare using the role codes
	
	if not pRoleCode1 then
		return false
	end
	
	if not pRoleCode2 then
		return true
	end
	
	if not GroupCalendar.RoleInfoByID[pRoleCode1] then
		GroupCalendar:DebugMessage("Unknown role code 1 %s", pRoleCode1)
		return false
	end
	
	if not GroupCalendar.RoleInfoByID[pRoleCode2] then
		GroupCalendar:DebugMessage("Unknown role code 2 %s", pRoleCode2)
		return true
	end
	
	return GroupCalendar.RoleInfoByID[pRoleCode1].SortOrder < GroupCalendar.RoleInfoByID[pRoleCode2].SortOrder
end

function GroupCalendar.Database.CompareRankCodes(pRank1, pRank2)
	local vIsRank1 = type(pRank1) == "number"
	local vIsRank2 = type(pRank2) == "number"
	
	if vIsRank1 and vIsRank2 then
		return pRank1 < pRank2
	end
	
	if not vIsRank1 then
		if not vIsRank2 then
			return GroupCalendar.Database.CompareClassCodes(pRank1, pRank2)
		else
			return false
		end
	end
	
	return true
end

function GroupCalendar.Database.CreatePlayerRSVP(
				pDatabase, pEvent,
				pPlayerName,
				pPlayerRace, pPlayerClass, pPlayeLevel,
				pRole,
				pStatus,
				pComment,
				pGuild,
				pGuildRank,
				pAlts)
	local vDate, vTime60 = MCDateLib:GetServerDateTime60()
	local vAlts = nil
	
	--[[
	if pAlts then
		for vPlayerName, _ in pairs(pAlts) do
			if vPlayerName ~= pPlayerName then
				if not vAlts then
					vAlts = {}
				end
				
				vAlts[vPlayerName] = true
			end
		end
	end
	]]--
	local vRSVP = GroupCalendar.NewTable()
	
	vRSVP.mName = pPlayerName
	vRSVP.mOrganizerName = pDatabase.UserName
	vRSVP.mEventID = pEvent.mID
	vRSVP.mDate = vDate
	vRSVP.mTime = vTime60
	vRSVP.mStatus = pStatus
	vRSVP.mComment = pComment
	vRSVP.mRaceCode = pPlayerRace
	vRSVP.mClassCode = pPlayerClass
	vRSVP.mLevel = pPlayeLevel
	vRSVP.mRole = pRole
	vRSVP.mGuild = pGuild
	vRSVP.mGuildRank = pGuildRank
	vRSVP.mAlts = vAlts
	
	return vRSVP
end

function GroupCalendar.Database.PlayerLevelChanged(pPlayerLevel)
	if not GroupCalendar.UserDatabase then
		return
	end
	
	GroupCalendar.UserDatabase.PlayerLevel = pPlayerLevel
end

function GroupCalendar.Database.PlayerIsQualifiedForEvent(pEvent, pPlayerLevel)
	if not pPlayerLevel or pEvent.mClosed then
		return false
	end
	
	if pEvent.mMinLevel and pPlayerLevel < pEvent.mMinLevel then
		return false
	end
	
	if pEvent.mMaxLevel and pPlayerLevel > pEvent.mMaxLevel then
		return false
	end
	
	if pEvent.mGuild then
		if pEvent.mGuild ~= GroupCalendar.PlayerGuild then
			return false
		end
		
		if pEvent.mMinGuildRank and GroupCalendar.PlayerGuildRank > pEvent.mMinGuildRank then
			return false
		end
	end
	
	return true
end

function GroupCalendar.Database.PlayerInfoIsQualifiedForEvent(pPlayerInfo, pEvent)
	if pEvent.mClosed then
		return false, GroupCalendar.cAttendanceClosedEvent
	end
	
	if not pPlayerInfo then
		return true
	end
	
	if pEvent.mMinLevel or pEvent.mMaxLevel then
		if not pPlayerInfo.Level then
			return false, GroupCalendar.cAttendanceUnknownLevel
		end
		
		if pEvent.mMinLevel and pPlayerInfo.Level < pEvent.mMinLevel then
			return false, GroupCalendar.cAttendanceLevelTooLow
		end
		
		if pEvent.mMaxLevel and pPlayerInfo.Level > pEvent.mMaxLevel then
			return false, GroupCalendar.cAttendanceLevelTooHigh
		end
	end
	
	if pEvent.mGuild then
		if pEvent.mGuild ~= pPlayerInfo.Guild then
			return false, string.format(GroupCalendar.cAttendanceGuildMembersOnly, pEvent.mGuild)
		end
		
		if pEvent.mMinGuildRank and pPlayerInfo.RankIndex > pEvent.mMinGuildRank then
			return false, string.format(GroupCalendar.cAttendanceRankTooLow)
		end
	end
	
	return true
end

function GroupCalendar.Database.RescheduleEvent(pDatabase, pEvent, pNewDate)
	local vNewEvent = GroupCalendar.Database.NewEvent(pDatabase, pNewDate)
	
	vNewEvent.mType = pEvent.mType
	vNewEvent.mTitle = pEvent.mTitle

	vNewEvent.mTime = pEvent.mTime
	vNewEvent.mDuration = pEvent.mDuration

	vNewEvent.mDescription = pEvent.mDescription

	vNewEvent.mMinLevel = pEvent.mMinLevel
	vNewEvent.mAttendance = pEvent.mAttendance

	GroupCalendar.Database.AddEvent(pDatabase, vNewEvent)

	return GroupCalendar.Database.DeleteEvent(pDatabase, pEvent)
end

function GroupCalendar.Database.DeleteOldEvents(pDatabase)
	if not pDatabase.Events then
		return
	end
	
	for vDate, vEvents in pairs(pDatabase.Events) do
		if vDate < GroupCalendar.MinimumEventDate then
			-- Remove or reschedule the events for this date
			
			local vNumEvents = table.getn(vEvents)
			local vEventIndex = 1
			
			for vIndex = 1, vNumEvents do
				local vEvent = vEvents[vEventIndex]
				
				if pDatabase.IsPlayerOwned and vEvent.mType == "Birth" then
					local vMonth, vDay, vYear = GroupCalendar.ConvertDateToMDY(vDate)
					vYear = vYear + 1
					local vNewDate = GroupCalendar.ConvertMDYToDate(vMonth, vDay, vYear)
					
					if not GroupCalendar.Database.RescheduleEvent(pDatabase, vEvent, vNewDate) then
						GroupCalendar:DebugMessage("Can't reschedule event "..vEvent.mID.." for "..pDatabase.UserName..": Unknown error")
						vEventIndex = vEventIndex + 1
					end
				elseif not GroupCalendar.Database.DeleteEvent(pDatabase, vEvent) then
					GroupCalendar:DebugMessage("Can't delete old event "..vEvent.mID.." for "..pDatabase.UserName..": Unknown error")
					vEventIndex = vEventIndex + 1
				end
			end
		end
	end
end

function GroupCalendar.Database.PlayerIsAttendingEvent(pEventOwner, pEvent, pConfirmedResultsOnly)
	for vPlayerName, vPlayerValue in pairs(GroupCalendar.PlayerCharacters) do
		local vPlayerDatabase = GroupCalendar.Database.GetDatabase(vPlayerName, false)
		local vRSVP = nil
		local vResultCode
		
		if not pConfirmedResultsOnly and vPlayerDatabase then
			vRSVP = GroupCalendar.Database.FindLastRSVPRequestData(vPlayerDatabase, pEventOwner, pEvent.mID)
			vResultCode = "REQUESTED"
		end
		
		if not vRSVP then
			vRSVP = GroupCalendar.Database.FindEventRSVP(pEventOwner, pEvent, vPlayerName)
			vResultCode = "CONFIRMED"
		end
		
		if vRSVP then
			local vStatus1 = string.sub(vRSVP.mStatus, 1, 1)
			
			if vStatus1 == "Y" then
				return vResultCode
			elseif vStatus1 == "S" then
				return vResultCode.."_STANDBY"
			elseif vStatus1 == "M" then
				return vResultCode.."_MAYBE"
			end
		end
	end
	
	return false
end

function GroupCalendar.Database.RemoveSavedInstanceEvents(pDatabase, pCutoffDate)
	for vDate, vSchedule in pairs(pDatabase.Events) do
		if not pCutoffDate or vDate <= pCutoffDate then
			local vEventIndex = 1
			local vNumEvents = table.getn(vSchedule)
			
			while vEventIndex <= vNumEvents do
				local vEvent = vSchedule[vEventIndex]
				
				if GroupCalendar.Database.IsDungeonResetEventType(vEvent.mType) then
					GroupCalendar.Database.DeleteEvent(pDatabase, vEvent)
					vNumEvents = vNumEvents - 1
				else
					vEventIndex = vEventIndex + 1
				end
			end
		end
	end
end

function GroupCalendar.Database.RemoveTradeskillEventByType(pDatabase, pEventType, pIgnoreDate, pIgnoreTime)
	local vIgnoreDateTime
	
	if pIgnoreDate then
		vIgnoreDateTime = pIgnoreDate * GroupCalendar.cMinutesPerDay + pIgnoreTime
	end
	
	for vDate, vSchedule in pairs(pDatabase.Events) do
		local vEventIndex = 1
		local vNumEvents = table.getn(vSchedule)
		
		while vEventIndex <= vNumEvents do
			local vEvent = vSchedule[vEventIndex]
			
			if vEvent.mType == pEventType then
				local vEventDateTime = vEvent.mDate * GroupCalendar.cMinutesPerDay + vEvent.mTime
				
				if vIgnoreDateTime
				and math.abs(vEventDateTime - vIgnoreDateTime) < 2 then
					vIgnoreDateTime = nil -- Only ignore 1 event maximum
					vEventIndex = vEventIndex + 1
				else
					GroupCalendar.Database.DeleteEvent(pDatabase, vEvent)
					vNumEvents = vNumEvents - 1
				end
			else
				vEventIndex = vEventIndex + 1
			end
		end
	end
end

function GroupCalendar.Database.ScheduleResetEvent(pDatabase, pType, pResetDate, pResetTime)
	local vResetDateTime = pResetDate * GroupCalendar.cMinutesPerDay + pResetTime
	
	-- See if the event already exists
	
	local vSchedule = pDatabase.Events[pResetDate]
	
	if vSchedule then
		for vEventIndex, vEvent in ipairs(vSchedule) do
			if vEvent.mType == pType then
				-- Just return if it's already the right time within one minute
				
				local vEventDateTime = vEvent.mDate * GroupCalendar.cMinutesPerDay + vEvent.mTime
				
				if math.abs(vEventDateTime - vResetDateTime) < 2 then
					return
				
				-- Otherwise delete it and schedule a new one
				
				else
					GroupCalendar.Database.DeleteEvent(pDatabase, vEvent)
					break
				end
			end
		end
	end
	
	-- Schedule a new reset event
	
	local vEvent = GroupCalendar.Database.NewEvent(pDatabase, pResetDate)
	
	vEvent.mType = pType
	vEvent.mPrivate = true
	vEvent.mTime = pResetTime
	vEvent.mDuration = nil
	
	GroupCalendar.Database.AddEvent(pDatabase, vEvent)
end

function GroupCalendar.Database.ScheduleSavedInstanceEvents()
	local vCurrentServerDate, vCurrentServerTime = MCDateLib:GetServerDateTime()
	
	-- Remove the existing saved info
	
	GroupCalendar.Database.RemoveSavedInstanceEvents(GroupCalendar.UserDatabase, vCurrentServerDate)
	
	--
	
	local vNumSavedInstances = GetNumSavedInstances()
	local vResetIDMap = {}
	
	for vIndex = 1, vNumSavedInstances do
		vInstanceName, vInstanceID, vInstanceResetSeconds = GetSavedInstanceInfo(vIndex)
		
		local vEventType, vEventInfo = GroupCalendar.Database.LookupDungeonResetEventTypeByName(vInstanceName)
	
		if vEventType then
			local vServerResetDate, vServerResetTime = MCDateLib:GetServerDateTimeFromSecondsOffset(tonumber(vInstanceResetSeconds))
			
			GroupCalendar.Database.ScheduleSavedInstanceEvent(GroupCalendar.UserDatabase, vEventType, vEventInfo, vServerResetDate, vServerResetTime)
			
			if vEventInfo.eventID then
				vResetIDMap[vEventInfo.eventID] = vInstanceID
			end
		else
			GroupCalendar:DebugMessage("Can't schedule reset event for "..vInstanceName..": The instance name is not recognized")
		end
	end
	
	-- Go through this characters events, find any matching dungeons, and add the reset ID to the event
	
	for vDate, vEvent in pairs(GroupCalendar.UserDatabase.Events) do
		local vInstanceID = vResetIDMap[vEvent.mEventID]
		
		if vInstanceID then
			vEvent.mInstanceID = vInstanceID
			
			local vChangedFields = {op = "UPD", val = vInstanceID}
			
			GroupCalendar.Database.EventChanged(GroupCalendar.UserDatabase, vEvent, vChangedFields)
		end
		
	end
end

function GroupCalendar.Database.ScheduleSavedInstanceEvent(pDatabase, pEventType, pEventInfo, pResetDate, pResetTime)
	local vNumEvents, vFrequency
	
	if pEventInfo.frequency then
		vNumEvents = tern(pEventInfo.frequency == 7, 1, 4)
		vFrequency = pEventInfo.frequency * GroupCalendar.cMinutesPerDay
	else
		vNumEvents = 1
	end
	
	local vDate = pResetDate
	local vTime = pResetTime
	
	for vIndex = 1, vNumEvents do
		GroupCalendar.Database.ScheduleResetEvent(pDatabase, pEventType, vDate, vTime)
		
		if pEventInfo.frequency then
			vDate, vTime = MCDateLib:AddOffsetToDateTime(vDate, vTime, vFrequency)
		end
	end
end

function GroupCalendar.Database.ScheduleTradeskillCooldownEvent(pDatabase, pTradeskillID, pCooldownSeconds)
	local vType = GroupCalendar.Database.LookupTradeskillEventTypeByID(pTradeskillID)
	local vResetDate, vResetTime = MCDateLib:GetServerDateTimeFromSecondsOffset(pCooldownSeconds)
	
	GroupCalendar.Database.RemoveTradeskillEventByType(pDatabase, vType, vResetDate, vResetTime)
	
	GroupCalendar.Database.ScheduleResetEvent(pDatabase, vType, vResetDate, vResetTime)
end

function GroupCalendar.Database.UpdateCurrentTradeskillCooldown()
	GroupCalendar.Database.UpdateSkillCooldown(GroupCalendar.TradeSkillAPI)
end

function GroupCalendar.Database.UpdateCurrentCraftCooldown()
	GroupCalendar.Database.UpdateSkillCooldown(GroupCalendar.CraftSkillAPI)
end

function GroupCalendar.Database.UpdateSkillCooldown(pSkillAPI)
	local vSkillName, vCurrentLevel, vMaxLevel = pSkillAPI:GetSkillLine()
	
	if not vSkillName then
		return
	end
	
	local vSkillID = GroupCalendar.LookupTradeskillIDByName(vSkillName)
	
	if not vSkillID then
		return
	end
	
	local vCooldowns = GroupCalendar.GetSkillCooldowns(vSkillID, pSkillAPI)
	
	if vCooldowns then
		for vCooldownID, vCooldown in pairs(vCooldowns) do
			GroupCalendar.Database.ScheduleTradeskillCooldownEvent(GroupCalendar.UserDatabase, vCooldownID, vCooldown)
		end
	end
end

function GroupCalendar.Database.MapGuildRank(pFromGuild, pFromRank)
	if not pFromGuild
	or not pFromRank then
		return nil
	end
	
	-- If it's the same guild then just return the rank
	
	if pFromGuild == GroupCalendar.PlayerGuild then
		return pFromRank
	end
	
	-- Force to zero if not in any guild
	
	if not IsInGuild() then
		return nil
	end
	
	-- Just cover our eyes if the roster isn't loaded yet
	
	if GetNumGuildMembers() == 0 then
		GroupCalendar.Network:LoadGuildRoster()
		return pFromRank
	end
	
	local vMaxGuildRank = GuildControlGetNumRanks() - 1
	
	-- Get the mapping
	
	local vToRankMap

	if GroupCalendar.RealmSettings.RankMap then
		vToRankMap = GroupCalendar.RealmSettings.RankMap[GroupCalendar.PlayerGuild]
	end
	
	local vRankMap
	
	if vToRankMap then
		vRankMap = vToRankMap[pFromGuild]
	end
	
	if vRankMap then
		local vToRank = vRankMap[pFromRank]
		
		if vToRank then
			return vToRank
		end
		
		-- If there's not a mapping for this rank, map it to the
		-- same value as the next highest rank
		
		for vFromRank, vToRank in pairs(vRankMap) do
			if vFromRank > pFromRank then
				return vToRank
			end
		end
	end
	
	-- Do a dumb mapping which simply ensures that the rank index
	-- is valid for the current guild
	
	if pFromRank > vMaxGuildRank then
		return vMaxGuildRank
	else
		return pFromRank
	end
end

function GroupCalendar.Database.SetGuildRankMapping(pFromGuild, pFromRank, pToRank)
	if not pFromGuild
	or pFromGuild == ""
	or not pFromRank then
		return
	end
	
	-- If it's the same guild then there's nothing to do
	
	if pFromGuild == GroupCalendar.PlayerGuild then
		return
	end
	
	-- Make sure the maps exist
	
	if not GroupCalendar.RealmSettings.RankMap then
		GroupCalendar.RealmSettings.RankMap = {}
	end
	
	-- Make sure the to guild map exists
	
	local vToGuildMap = GroupCalendar.RealmSettings.RankMap[GroupCalendar.PlayerGuild]
	
	if not vToGuildMap then
		vToGuildMap = {}
		GroupCalendar.RealmSettings.RankMap[GroupCalendar.PlayerGuild] = vToGuildMap
	end
	
	-- Make sure the from guild map exists
	
	local vGuildMap = vToGuildMap[pFromGuild]
	
	if not vGuildMap then
		vGuildMap = {}
		vToGuildMap[pFromGuild] = vGuildMap
	end
	
	vGuildMap[pFromRank] = pToRank
end

function GroupCalendar.Database.UpdateGuildRankCache()
	if not GroupCalendar.PlayerGuild
	or not GroupCalendar.Network.Initialized then
		return
	end
	
	if not GroupCalendar.RealmSettings.GuildRanks then
		GroupCalendar.RealmSettings.GuildRanks = GroupCalendar.NewTable()
	end
	
	vGuildRanks = GroupCalendar.RecycleTable(GroupCalendar.RealmSettings.GuildRanks[GroupCalendar.PlayerGuild])
	
	local vNumRanks = GuildControlGetNumRanks()
	
	for vIndex = 1, vNumRanks do
		vGuildRanks[vIndex - 1] = GuildControlGetRankName(vIndex)
	end
	
	GroupCalendar.RealmSettings.GuildRanks[GroupCalendar.PlayerGuild] = vGuildRanks
end

