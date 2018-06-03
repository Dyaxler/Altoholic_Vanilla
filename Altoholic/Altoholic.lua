-- *** TO DO's ***
-- **   (1) Profession Cooldowns - in BC there was a tidy API we could hit to return profession cooldowns.
-- **   In vanilla I'll have to figure out the best way to do this. Either scan the recipies tool tip
-- **   or save the time stamp when the player uses the recipe.

-- *** Open bugs ***

-- .Libs
local G = AceLibrary("Gratuity-2.0")
local L = AceLibrary("AceLocale-2.2"):new("Altoholic")
local BI = LibStub("LibBabble-Inventory-3.0"):GetLookupTable()
local V = Altoholic.vars
local WHITE		= "|cFFFFFFFF"
local RED		= "|cFFFF0000"
local GREEN		= "|cFF00FF00"
local YELLOW	= "|cFFFFFF00"
local ORANGE	= "|cFFFF7F00"
local TEAL		= "|cFF00FF9A"
local GOLD		= "|cFFFFD700"
local MENU_SUMMARY = 1
local MENU_CONTAINERS = 2
local MENU_MAIL = 3
local MENU_SEARCH = 4
local MENU_EQUIPMENT = 5
local MENU_QUESTS = 6
local MENU_RECIPES = 7
local MENU_AUCTIONS = 8
local MENU_BIDS = 9
local INFO_REALM_LINE = 1
local INFO_CHARACTER_LINE = 2
local INFO_TOTAL_LINE = 3
local LEVEL_CAP = 60

Altoholic.Menu = {
	{	name = L["Account Summary"], isCollapsed = false,
		subMenu = {
			{ name = L["Characters"], OnClick = function() Altoholic:ActivateMenuItem("AltoSummary") end },
			{ name = L["Bag Usage"], OnClick = function() Altoholic:ActivateMenuItem("AltoBags") end },
			{ name = SKILLS, OnClick = function() Altoholic:ActivateMenuItem("AltoSkills") end },
			{ name = L["Reputations"], OnClick = function() Altoholic:ActivateMenuItem("AltoReputations") end }
		},
		OnClick = function() Altoholic:Menu_Update(MENU_SUMMARY) end
    },
	{	name = L["Containers"], isCollapsed = true,
		subMenu = {},
		OnClick = function() Altoholic:Menu_Update(MENU_CONTAINERS) end
    },
	{	name = L["E-Mail"], isCollapsed = true,
        subMenu = {},
		OnClick = function() Altoholic:Menu_Update(MENU_MAIL) end
    },
	{	name = L["Search"], isCollapsed = true,
        subMenu = {
			{ name = BI["Weapon"], isCollapsed = true,
				subMenu = {
					{ name = L["Any"], OnClick = function() Altoholic:SearchItem(BI["Weapon"]) end },
					{ name = L["1H Axes"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["One-Handed Axes"]) end },
					{ name = L["2H Axes"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["Two-Handed Axes"]) end },
					{ name = L["1H Maces"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["One-Handed Maces"]) end },
					{ name = L["2H Maces"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["Two-Handed Maces"]) end },
					{ name = L["1H Swords"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["One-Handed Swords"]) end },
					{ name = L["2H Swords"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["Two-Handed Swords"]) end },
					{ name = BI["Bows"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["Bows"]) end },
					{ name = BI["Guns"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["Guns"]) end },
					{ name = BI["Crossbows"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["Crossbows"]) end },
					{ name = BI["Staves"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["Staves"]) end },
					{ name = BI["Wands"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["Wands"]) end },
					{ name = BI["Polearms"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["Polearms"]) end },
					{ name = BI["Daggers"],	OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["Daggers"]) end },
					{ name = BI["Fist Weapons"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["Fist Weapons"]) end },
					{ name = BI["Thrown"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], BI["Thrown"]) end },
					{ name = L["Miscellaneous"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], L["Miscellaneous"]) end },
					{ name = L["Fishing Poles"], OnClick = function() Altoholic:SearchItem(BI["Weapon"], L["Fishing Poles"]) end }
				},
				OnClick = function() Altoholic:Menu_Update(MENU_SEARCH, 1 )	end
            },
			{ name = BI["Armor"], isCollapsed = true,
				subMenu = {
					{ name = L["Any"], OnClick = function() Altoholic:SearchItem(BI["Armor"]) end },
					{ name = L["Miscellaneous"], OnClick = function() Altoholic:SearchItem(BI["Armor"], L["Miscellaneous"]) end },
					{ name = BI["Cloth"], OnClick = function() Altoholic:SearchItem(BI["Armor"], BI["Cloth"])	end },
					{ name = BI["Leather"], OnClick = function() Altoholic:SearchItem(BI["Armor"], BI["Leather"])	end },
					{ name = BI["Mail"], OnClick = function() Altoholic:SearchItem(BI["Armor"], BI["Mail"]) end },
					{ name = BI["Plate"], OnClick = function() Altoholic:SearchItem(BI["Armor"], BI["Plate"])	end },
					{ name = BI["Shields"], OnClick = function() Altoholic:SearchItem(BI["Armor"], BI["Shields"])	end },
					{ name = BI["Librams"], OnClick = function() Altoholic:SearchItem(BI["Armor"], BI["Librams"])	end },
					{ name = BI["Idols"], OnClick = function() Altoholic:SearchItem(BI["Armor"], BI["Idols"]) end },
					{ name = BI["Totems"], OnClick = function() Altoholic:SearchItem(BI["Armor"], BI["Totems"]) end }
				},
				OnClick = function() Altoholic:Menu_Update(MENU_SEARCH, 2 )	end
            },
			{ name = BI["Consumable"],	isCollapsed = true,
				subMenu = {},
				OnClick = function() Altoholic:SearchItem(BI["Consumable"])	end
			},
			{ name = BI["Trade Goods"],	isCollapsed = true,
				subMenu = {},
				OnClick = function()	Altoholic:SearchItem(BI["Trade Goods"])	end
			},
			{ name = BI["Recipe"], isCollapsed = true,
				subMenu = {
					{ name = L["Any"], OnClick = function() Altoholic:SearchItem(BI["Recipe"]) end },
					{ name = BI["Alchemy"], OnClick = function() Altoholic:SearchItem(BI["Recipe"], BI["Alchemy"]) end },
					{ name = BI["Blacksmithing"], OnClick = function() Altoholic:SearchItem(BI["Recipe"], BI["Blacksmithing"]) end },
					{ name = BI["Enchanting"], OnClick = function() Altoholic:SearchItem(BI["Recipe"], BI["Enchanting"]) end },
					{ name = BI["Engineering"], OnClick = function() Altoholic:SearchItem(BI["Recipe"], BI["Engineering"]) end },
					{ name = BI["Leatherworking"], OnClick = function() Altoholic:SearchItem(BI["Recipe"], BI["Leatherworking"]) end },
					{ name = BI["Tailoring"], OnClick = function() Altoholic:SearchItem(BI["Recipe"], BI["Tailoring"]) end },
					{ name = BI["Book"], OnClick = function() Altoholic:SearchItem(BI["Recipe"], BI["Book"]) end },
					{ name = BI["Cooking"], OnClick = function() Altoholic:SearchItem(BI["Recipe"], BI["Cooking"]) end },
					{ name = BI["First Aid"],	OnClick = function() Altoholic:SearchItem(BI["Recipe"], BI["First Aid"]) end }
				},
				OnClick = function() Altoholic:Menu_Update(MENU_SEARCH, 5 )	end
			}
		},
		OnClick = function() Altoholic:Menu_Update(MENU_SEARCH) end
	},
	{ name = L["Equipment"], isCollapsed = true,
		subMenu = {},
		OnClick = function() Altoholic:Menu_Update(MENU_EQUIPMENT) end
	},
	{ name = L["Quests"], isCollapsed = true,
		subMenu = {},
		OnClick = function() Altoholic:Menu_Update(MENU_QUESTS) end
	},
	{ name = L["Recipes"], isCollapsed = true,
		subMenu = {},
		OnClick = function() Altoholic:Menu_Update(MENU_RECIPES) end
	},
	{ name = AUCTIONS, isCollapsed = true,
		subMenu = {},
		OnClick = function() Altoholic:Menu_Update(MENU_AUCTIONS) end
	},
	{ name = BIDS, isCollapsed = true,
		subMenu = {},
		OnClick = function() Altoholic:Menu_Update(MENU_BIDS) end
	},
	{ name = L["Options"], OnClick = function() Altoholic:ActivateMenuItem("AltoOptions") end	}
}

Altoholic.InvSlots = {
	["INVTYPE_HEAD"] = 1,
	["INVTYPE_SHOULDER"] = 2,
	["INVTYPE_CHEST"] = 3,
	["INVTYPE_ROBE"] = 3,
	["INVTYPE_WRIST"] = 4,
	["INVTYPE_HAND"] = 5,
	["INVTYPE_WAIST"] = 6,
	["INVTYPE_LEGS"] = 7,
	["INVTYPE_FEET"] = 8,
	["INVTYPE_NECK"] = 9,
	["INVTYPE_CLOAK"] = 10,
	["INVTYPE_FINGER"] = 11,
	["INVTYPE_TRINKET"] = 12,
	["INVTYPE_WEAPON"] = 13,
	["INVTYPE_2HWEAPON"] = 14,
	["INVTYPE_WEAPONMAINHAND"] = 15,
	["INVTYPE_WEAPONOFFHAND"] = 16,
	["INVTYPE_HOLDABLE"] = 16,
	["INVTYPE_SHIELD"] = 17,
	["INVTYPE_RANGED"] = 18,
	["INVTYPE_THROWN"] = 18,
	["INVTYPE_RANGEDRIGHT"] = 18,
	["INVTYPE_RELIC"] = 18
}

Altoholic.EquipmentSlots = {
	[1] = BI["Head"],			-- "INVTYPE_HEAD"
	[2] = BI["Shoulder"],	-- "INVTYPE_SHOULDER"
	[3] = BI["Chest"],		-- "INVTYPE_CHEST",  "INVTYPE_ROBE"
	[4] = BI["Wrist"],		-- "INVTYPE_WRIST"
	[5] = BI["Hands"],		-- "INVTYPE_HAND"
	[6] = BI["Waist"],		-- "INVTYPE_WAIST"
	[7] = BI["Legs"],			-- "INVTYPE_LEGS"
	[8] = BI["Feet"],			-- "INVTYPE_FEET"
	[9] = BI["Neck"],			-- "INVTYPE_NECK"
	[10] = BI["Back"],		-- "INVTYPE_CLOAK"
	[11] = BI["Ring"],		-- "INVTYPE_FINGER"
	[12] = BI["Trinket"],	-- "INVTYPE_TRINKET"
	[13] = BI["One-Hand"],	-- "INVTYPE_WEAPON"
	[14] = BI["Two-Hand"],	-- "INVTYPE_2HWEAPON"
	[15] = BI["Main Hand"],	-- "INVTYPE_WEAPONMAINHAND"
	[16] = BI["Off Hand"],	-- "INVTYPE_WEAPONOFFHAND", "INVTYPE_HOLDABLE"
	[17] = BI["Shield"],		-- "INVTYPE_SHIELD"
	[18] = L["Ranged"]		-- "INVTYPE_RANGED",  "INVTYPE_THROWN", "INVTYPE_RANGEDRIGHT", "INVTYPE_RELIC"
}

-- ** texture coordinates found in a scrub.lua somewhere on the web
Altoholic.classicon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes";

Altoholic.ClassInfo = {
	[1] = { color = "|cFF69CCF0", texcoord = {0.25, 0.49609375, 0, 0.25} },
	[2] = { color = "|cFFC79C6E", texcoord = {0, 0.25, 0, 0.25} },
	[3] = { color = "|cFFABD473", texcoord = {0, 0.25, 0.25, 0.5} },
	[4] = { color = "|cFFFFF569", texcoord = {0.49609375, 0.7421875, 0, 0.25} },
	[5] = { color = "|cFF9482CA", texcoord = {0.7421875, 0.98828125, 0.25, 0.5} },
	[6] = { color = "|cFFFF7D0A", texcoord = {0.7421875, 0.98828125, 0, 0.25} },
	[7] = { color = "|cFF2459FF", texcoord = {0.25, 0.49609375, 0.25, 0.5} },
	[8] = { color = "|cFFF58CBA", texcoord = {0, 0.25, 0.5, 0.75} },
	[9] = { color = WHITE, texcoord = {0.49609375, 0.7421875, 0.25, 0.5} }
}

Altoholic.Classes = {
	[L["Mage"]]		= 1,
	[L["Warrior"]]	= 2,
	[L["Hunter"]]	= 3,
	[L["Rogue"]]	= 4,
	[L["Warlock"]]	= 5,
	[L["Druid"]]	= 6,
	[L["Shaman"]]	= 7,
	[L["Paladin"]]	= 8,
	[L["Priest"]]	= 9,
	-- frFR female class names
	["Guerrière"] = 2,			-- Warrior
	["Chasseresse"] = 3,			-- Hunter
	["Voleuse"] = 4,				-- Rogue
	["Druidesse"] = 6,			-- Druid
	["Chamane"] = 7,				-- Shaman
	["Prêtresse"] = 9,			-- Priest
	-- deDE female class names
	["Magierin"] = 1,				-- Mage
	["Kriegerin"] = 2,			-- Warrior
	["J\195\164gerin"] = 3,		-- Hunter
	["Schurkin"] = 4,				-- Rogue
	["Hexenmeisterin"] = 5,		-- Warlock
	["Druidin"] = 6,				-- Druid
	["Schamanin"] = 7,			-- Shaman
	["Priesterin"] = 9			-- Priest
}

Altoholic.Books = {
	[L["Mage"]]		= "Tome",
	[L["Warrior"]]	= "Manual",
	[L["Hunter"]]	= "Guide",
	[L["Rogue"]]	= "Handbook",
	[L["Warlock"]]	= "Grimoire",
	[L["Druid"]]	= "Book",
	[L["Shaman"]]	= "Tablet",
	[L["Paladin"]]	= "Libram",
	[L["Priest"]]	= "Codex",
}

Altoholic.equipment = {
	{ color = "|cFF69CCF0", name = BI["Head"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Head"},
	{ color = "|cFFABD473", name = BI["Neck"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Neck"},
	{ color = "|cFF69CCF0", name = BI["Shoulder"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Shoulder"},
	{ color = WHITE, name = BI["Shirt"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Shirt"},
	{ color = "|cFF69CCF0", name = BI["Chest"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest"},
	{ color = "|cFF69CCF0", name = BI["Waist"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Waist"},
	{ color = "|cFF69CCF0", name = BI["Legs"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Legs"},
	{ color = "|cFF69CCF0", name = BI["Feet"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Feet"},
	{ color = "|cFF69CCF0", name = BI["Wrist"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Wrists"},
	{ color = "|cFF69CCF0", name = BI["Hands"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands"},
	{ color = ORANGE, name = BI["Ring"] .. " 1", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger"},
	{ color = ORANGE, name = BI["Ring"] .. " 2", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger"},
	{ color = ORANGE, name = BI["Trinket"] .. " 1", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket"},
	{ color = ORANGE, name = BI["Trinket"] .. " 2", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket"},
	{ color = "|cFFABD473", name = BI["Back"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest"},
	{ color = "|cFFFFFF00", name = BI["Main Hand"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-MainHand"},
	{ color = "|cFFFFFF00", name = BI["Off Hand"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-SecondaryHand"},
	{ color = "|cFFABD473", name = L["Ranged"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Ranged"},
	{ color = WHITE, name = BI["Tabard"], icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Tabard"}
}

function Altoholic:OnInitialize()
end

function Altoholic:OnEnable()
	self:RegisterEvent("PLAYER_ALIVE")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("PLAYER_XP_UPDATE")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvent("PLAYER_UPDATE_RESTING")
	self:RegisterEvent("PLAYER_GUILD_UPDATE")
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ZONE_CHANGED_INDOORS")
	self:RegisterEvent("TIME_PLAYED_MSG")
	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	self:RegisterEvent("AUCTION_HOUSE_SHOW")
	self:RegisterEvent("AUCTION_HOUSE_CLOSED")
	self:RegisterEvent("MAIL_SHOW")
	self:RegisterEvent("MAIL_CLOSED")
	self:RegisterEvent("AceEvent_FullyInitialized")
	getglobal("AltoholicFrameName"):SetText("Altoholic |cFFFFFFFF"..V.version)
	V.faction = UnitFactionGroup("player")
    V.realm = GetRealmName()
  	V.player = UnitName("player")
	V.alt = V.player
	if self.db.account.data[V.faction][V.realm].char[V.player].playtime == nil then
		RequestTimePlayed()
	end
	local f = CreateFrame("Frame", "RarityDropDownMenu", AltoholicFrame, "UIDropDownMenuTemplate");
	f:SetPoint("LEFT", "AltoholicFrame_MaxLevel", "RIGHT", 0, -5)
	UIDropDownMenu_SetWidth(80, f)
	UIDropDownMenu_SetButtonWidth(20, f)
	UIDropDownMenu_Initialize(f, function(self)
		Altoholic:DropDownRarity_Initialize();
	end)
	f = CreateFrame("Frame", "SlotsDropDownMenu", AltoholicFrame, "UIDropDownMenuTemplate");
	f:SetPoint("LEFT", "AltoholicFrame_MaxLevel", "RIGHT", 110, -5)
	UIDropDownMenu_SetWidth(80, f)
	UIDropDownMenu_SetButtonWidth(20, f)
	UIDropDownMenu_Initialize(f, function(self)
		Altoholic:DropDownSlot_Initialize();
	end)
	-- *** Create Scroll Frames' children lines ***
	self:CreateScrollLines("AltoSummary", "CharacterSummaryTemplate", 14);
	self:CreateScrollLines("AltoBags", "BagUsageTemplate", 14);
	self:CreateScrollLines("AltoContainers", "ContainerTemplate", 7, 14);
    self:CreateScrollLines("AltoMail", "MailEntryTemplate", 7);
	self:CreateScrollLines("AltoSearch", "SearchEntryTemplate", 7);
	self:CreateScrollLines("AltoEquipment", "EquipmentEntryTemplate", 7, 10);
	-- Manually fill the reputation frame
	local repFrame = "AltoReputations"
	f = CreateFrame("Button", repFrame .. "Entry" .. 1, getglobal(repFrame), "ReputationEntryTemplate")
	f:SetPoint("TOPLEFT", repFrame .. "ScrollFrame", "TOPLEFT", 0, -45)
	for i = 2, 11 do
		f = CreateFrame("Button", repFrame .. "Entry" .. i, getglobal(repFrame), "ReputationEntryTemplate")
		f:SetPoint("TOPLEFT", repFrame .. "Entry" .. (i-1), "BOTTOMLEFT", 0, 0)
	end
	for i=1, 11 do
		getglobal(repFrame.."Entry"..i.."Item10"):SetPoint("BOTTOMRIGHT", repFrame .. "Entry"..i, "BOTTOMRIGHT", -15, 0);
		for j=9, 1, -1 do
			getglobal(repFrame.."Entry"..i.."Item" .. j):SetPoint("BOTTOMRIGHT", repFrame.."Entry"..i.."Item" .. (j + 1), "BOTTOMLEFT", -5, 0);
		end
	end
	getglobal(repFrame.."ClassesItem10"):SetPoint("BOTTOMRIGHT", repFrame .. "Classes", "BOTTOMRIGHT", -15, 0);
	for j=9, 1, -1 do
		getglobal(repFrame.."ClassesItem" .. j):SetPoint("BOTTOMRIGHT", repFrame.."ClassesItem" .. (j + 1), "BOTTOMLEFT", -5, 0);
	end
	self:CreateScrollLines("AltoSkills", "SkillsTemplate", 14);
	self:CreateScrollLines("AltoQuests", "QuestEntryTemplate", 14);
	self:CreateScrollLines("AltoRecipes", "RecipesEntryTemplate", 14);
	self:CreateScrollLines("AltoAuctions", "AuctionEntryTemplate", 7);
	self:CheckExpiredMail()
	self:BuildContainersSubMenu()
	self:BuildMailSubMenu()
	self:BuildEquipmentSubMenu()
	self:BuildQuestsSubMenu()
	self:BuildRecipesSubMenu()
	self:BuildAuctionsSubMenu()
	self:BuildBidsSubMenu()
	local O = self.db.account.options
	getglobal("AltoOptions_SliderAngle"):SetValue(O.MinimapIconAngle)
	getglobal("AltoOptions_SliderRadius"):SetValue(O.MinimapIconRadius)
	getglobal("AltoOptions_SliderMailExpiry"):SetValue(O.MailWarningThreshold)
	getglobal("AltoOptions_TooltipSource"):SetChecked(O.TooltipSource)
	getglobal("AltoOptions_TooltipCount"):SetChecked(O.TooltipCount)
	getglobal("AltoOptions_TooltipTotal"):SetChecked(O.TooltipTotal)
	getglobal("AltoOptions_TooltipAlreadyKnown"):SetChecked(O.TooltipAlreadyKnown)
    getglobal("AltoOptions_TooltipLearnableBy"):SetChecked(O.TooltipLearnableBy)
	getglobal("AltoOptions_ShowMinimap"):SetChecked(O.ShowMinimap)
	getglobal("AltoOptions_SortDescending"):SetChecked(O.SortDescending)
	getglobal("AltoOptions_RestXPMode"):SetChecked(O.RestXPMode)
	getglobal("AltoOptions_ScanMailBody"):SetChecked(O.ScanMailBody)
	getglobal("AltoOptions_SearchAutoQuery"):SetChecked(O.SearchAutoQuery)
	getglobal("AltoOptionsLootInfo"):SetText(GREEN .. O.TotalLoots .. "|r " .. L["Loots"] .. " / " .. GREEN .. O.UnknownLoots .. "|r " .. L["Unknown"])
	if AltoOptions_ShowMinimap:GetChecked() then
		self:MoveMinimapIcon()
		AltoholicMinimapButton:Show();
	else
		AltoholicMinimapButton:Hide();
	end
end

function Altoholic:OnDisable()
    -- Refresh DB on exit
	-- self:UpdatePlayerStats()
	-- self:UpdatePlayerBags()
end

function Altoholic_MiniMapButton_OnClick(button)
    if button == "LeftButton" then
        Altoholic:ToggleUI()
    end
end

function Altoholic:ToggleUI()
	if (AltoholicFrame:IsVisible()) then
		AltoholicFrame:Hide();
	else
		AltoholicFrame:Show();
	end
end

function Altoholic:ActivateMenuItem(frame)
	for k, v in pairs(self.Categories) do
       	getglobal(v):Hide()
	end
	getglobal(frame):Show()
end

function Altoholic:OnShow()
	if V.ExpiredMail then
		getglobal("AltoholicFrame_Status"):SetText(L["Mail expires in less than "].. self.db.account.options.MailWarningThreshold .. L[" days"])
		getglobal("AltoholicFrame_Status"):Show()
		V.ExpiredMail = nil
	end
	self:UpdatePlayerStats()
	self:UpdatePlayerBags()
	self:UpdateTalents()
	SetPortraitTexture(AltoholicFramePortrait,"player");
	V.guild = GetGuildInfo("player")
	if V.RebuildRecipeMenu then
		self:BuildRecipesSubMenu()
	end
	self:BuildFactionsTable()
	self:BuildCharacterInfoTable()
	self:ActivateMenuItem("AltoSummary")
	self:Menu_Update()
end

function Altoholic:BuildCharacterInfoTable()
	local money = 0
	local played = 0
	local levels = 0
	V.SkillsCache = {}
	V.Skills = {}
    self.CharacterInfo = {}
	for FactionName, f in pairs(self.db.account.data) do
		for RealmName, r in pairs(f) do
			local realmmoney = 0
			local realmplayed = 0
			local realmlevels = 0
			table.insert(self.CharacterInfo, { linetype = INFO_REALM_LINE,
				isCollapsed = false,
				faction = FactionName,
				realm = RealmName
			} )
			for CharacterName, c in pairs(r.char) do
				V.Skills[1] = ""
				V.Skills[2] = ""
				V.SkillsCache[1] = 0
				V.SkillsCache[2] = 0
				local i = 1
				for SkillName, s in pairs(c.skill[L["Professions"]]) do
					V.SkillsCache[i] = self:GetSkillInfo(s)
					V.Skills[i] = SkillName
					i = i + 1
				end
				V.SkillsCache[3] = self:GetSkillInfo( c.skill[L["Secondary Skills"]][BI["Cooking"]] )
				V.SkillsCache[4] = self:GetSkillInfo( c.skill[L["Secondary Skills"]][BI["First Aid"]] )
				V.SkillsCache[5] = self:GetSkillInfo( c.skill[L["Secondary Skills"]][BI["Fishing"]] )
				V.SkillsCache[6] = self:GetSkillInfo( c.skill[L["Secondary Skills"]][L["Riding"]] )
				local color = self:GetClassColor(c.class)
				local bank
				if (c.bankslots == nil) or (c.bankslots == "") then
					bank = L["Bank not visited yet"]
				else
					bank = c.bankslots
				end
				table.insert(self.CharacterInfo, { linetype = INFO_CHARACTER_LINE,
					name = CharacterName,
					bankslots = bank,
					skillRank1 = V.SkillsCache[1],
					skillName1 = V.Skills[1],
					skillRank2 = V.SkillsCache[2],
					skillName2 = V.Skills[2],
					cooking = V.SkillsCache[3],
					firstaid = V.SkillsCache[4],
					fishing = V.SkillsCache[5],
					riding = V.SkillsCache[6],
				} )
				realmlevels = realmlevels + c.level
				realmmoney = realmmoney + c.money
				realmplayed = realmplayed + c.played
			end
			table.insert(self.CharacterInfo, { linetype = INFO_TOTAL_LINE,
				level = WHITE .. realmlevels .. " |r" .. L["Levels"],
				money = self:GetMoneyString(realmmoney, WHITE),
				played = self:GetTimeString(realmplayed)
			} )
			levels = levels + realmlevels
			money = money + realmmoney
			played = played + realmplayed
		end
	end
	getglobal("AltoholicFrameTotalLv"):SetText(WHITE .. levels .. " |rLv")
	getglobal("AltoholicFrameTotalGold"):SetText(floor( money / 10000 ) .. "|cFFFFD700g")
	getglobal("AltoholicFrameTotalPlayed"):SetText(floor(played / 86400) .. "|cFFFFD700d")
    SkillsCache = {}
    V.Skills = {}
end

function Altoholic:DropDownRarity_Initialize()
	local info = Altoholic_UIDropDownMenu_CreateInfo();
	V.SearchRarity = 0
	for i = 0, 6 do
		info.text = ITEM_QUALITY_COLORS[i].hex .. getglobal("ITEM_QUALITY"..i.."_DESC")
		info.value = i
		info.func = function(self)
			UIDropDownMenu_SetSelectedValue(this.owner, this.value);
			V.SearchRarity = this.value
		end
		info.owner = this:GetParent();
		info.checked = nil;
		info.icon = nil;
		UIDropDownMenu_AddButton(info, 1);
	end
end

function Altoholic:DropDownSlot_Initialize()
	local info = Altoholic_UIDropDownMenu_CreateInfo();
	V.SearchSlot = 0
	info.text = L["Any"]
	info.value = 0
	info.func = function(self)
		UIDropDownMenu_SetSelectedValue(this.owner, this.value);
		V.SearchSlot = this.value
	end
	info.owner = this:GetParent();
	info.checked = nil;
	info.icon = nil;
	UIDropDownMenu_AddButton(info, 1);
	for i = 1, 18 do
		info.text = Altoholic.EquipmentSlots[i]
		info.value = i
		info.func = function(self)
			UIDropDownMenu_SetSelectedValue(this.owner, this.value);
			V.SearchSlot = this.value
		end
		info.owner = this:GetParent();
		info.checked = nil;
		info.icon = nil;
		UIDropDownMenu_AddButton(info, 1);
	end
end

function Altoholic:UpdatePlayerInventory()
	local r = self.db.account.data[V.faction][V.realm]
	local c = r.char[V.player]
	local nTotalSlots = 0
	local nSlots
	nTotalSlots = GetContainerNumSlots(0)
	c.bags = nTotalSlots .. "/"
	for i = 1, 4 do
		nSlots = GetContainerNumSlots(i)
		nTotalSlots = nTotalSlots + nSlots
		c.bags = c.bags .. WHITE .. nSlots
		if i ~= 4 then
			c.bags = c.bags .. "|r/"
		end
	end
	c.bags = c.bags .. " |r(|cFF00FF00" .. nTotalSlots .. "|r)"
end

function Altoholic:UpdatePlayerStats()
	local r = self.db.account.data[V.faction][V.realm]
	local c = r.char[V.player]
	self:PLAYER_XP_UPDATE()
	self:UpdatePlayerSkills()
    self:UpdatePlayerSpells()
    self:UpdatePlayerInventory()
	self:UpdateEquipment()
	self:PLAYER_MONEY()
	-- *** Factions ***
	for i = GetNumFactions(), 1, -1 do
		local _, _, _, _, _, _, _,	_, isHeader, isCollapsed, _ = GetFactionInfo(i)
		if isHeader and isCollapsed then
			ExpandFactionHeader(i)
		end
	end
	for i = 1, GetNumFactions() do
		local name, _, _, bottom, top, earned, _,	_, isHeader, _, _ = GetFactionInfo(i)
		if isHeader == nil then
			r.reputation[name][V.player] = bottom .. "|" .. top .. "|" .. earned
		end
	end
	self:UpdateQuestLog()
	self:UpdateRaidTimers()
	self:UpdatePVPStats()
end

function Altoholic:UpdatePlayerSkills()
	local c = self.db.account.data[V.faction][V.realm].char[UnitName("player")]
    -- *** Skills inventory ***
	for i = GetNumSkillLines(), 1, -1 do
		local _, isHeader = GetSkillLineInfo(i)
		if isHeader then
			ExpandSkillHeader(i)
		end
	end
	local category
	for i = 1, GetNumSkillLines() do
		local skillName, isHeader, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
		if isHeader then
			category = skillName
		else
			c.skill[category][skillName] = skillRank .. "|" .. skillMaxRank
		end
	end
end

function Altoholic:UpdatePlayerSpells()
	local c = self.db.account.data[V.faction][V.realm].char[UnitName("player")]
    -- *** Spells inventory ***
    local i = 1
    while true do
        local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
        if not spellName then
          do break end
        end
        if string.find(spellRank, ".*Rank.*") then
            SpellName = spellName.." ("..spellRank..")"
        else
            SpellName = spellName
        end
        c.spells[i] = SpellName
        i = i + 1
    end
    local i = nil
    local SpellName = nil
end

function Altoholic:UpdatePVPStats()
	local c = self.db.account.data[V.faction][V.realm].char[UnitName("player")]
	c.pvp_hk, c.pvp_dk = GetPVPLifetimeStats()
    local _, _, contribution, _ = GetPVPLastWeekStats()
	c.pvp_HonorPoints = contribution
end

function Altoholic:UpdateTalents()
	local c = self.db.account.data[V.faction][V.realm].char[UnitName("player")]
	c.talent = ""
	for i = 1, GetNumTalentTabs() do
		local numTalents = GetNumTalents(i)
		local _, _, pointsSpent, _ = GetTalentTabInfo( i );
		c.talent = c.talent .. WHITE .. pointsSpent
		if i ~= 3 then
			c.talent = c.talent .. "|r/"
		end
	end
end

function Altoholic:UpdateEquipment()
	local c = self.db.account.data[V.faction][V.realm].char[UnitName("player")]
	for i = 1, 19 do
		local link = GetInventoryItemLink("player", i)
		if link ~= nil then
			if self:GetEnchantInfo(link) then
				c.inventory[i] = link
			else
				c.inventory[i] = self:GetIDFromLink(link)
			end
		else
			c.inventory[i] = nil
		end
	end
end

function Altoholic:UpdatePlayerBags()
	for bagID = 0, 4 do
		self:UpdatePlayerBag(bagID)
	end
	self:UpdateKeyRing()
end

function Altoholic:CheckPlayerInventory(bagID)
    local totalSlots, usedSlosts, availableSlots;
    local totalSlots = 0;
    local usedSlots = 0;
    if bagID == nil then
        for bag = 0, 4 do
            local size = GetContainerNumSlots(bag);
            if (size and size > 0) then
                totalSlots = totalSlots + size;
                for slot = 1, size do
                    if (GetContainerItemInfo(bag, slot)) then
                        usedSlots = usedSlots + 1;
                    end
                end
            end
        end
        availableSlots = totalSlots - usedSlots;
        return availableSlots
    else
        local size = GetContainerNumSlots(bagID);
        if (size and size > 0) then
            totalSlots = totalSlots + size;
            for slot = 1, size do
                if (GetContainerItemInfo(bagID, slot)) then
                    usedSlots = usedSlots + 1;
                end
            end
        end
        availableSlots = totalSlots - usedSlots;
        return availableSlots
    end
end

function Altoholic:UpdatePlayerBag(bagID)
	if bagID < 0 then return end
    local c = self.db.account.data[V.faction][V.realm].char
	local b = c[V.player].bag["Bag" .. bagID]
    if c[0] then
        c[0] = {}
        c[0] = nil
    end
    if b[0] then
        b[0] = {}
        b[0] = nil
    end
	if bagID == 0 then	-- Bag 0
		b.icon = "Interface\\Buttons\\Button-Backpack-Up";
		b.link = nil;
	else	-- Bags 1 through 11
		b.icon = GetInventoryItemTexture("player", ContainerIDToInventoryID(bagID))
		b.link = GetInventoryItemLink("player", ContainerIDToInventoryID(bagID))
	end
	b.freeslots = Altoholic:CheckPlayerInventory(bagID)
	b.size = GetContainerNumSlots(bagID)
	self:PopulateContainer(bagID)
end

function Altoholic:PopulateContainer(bagID)
	local b = self.db.account.data[V.faction][V.realm].char[V.player].bag["Bag" .. bagID]
	for slotID = 1, b.size do
		b.ids[slotID] = nil
		b.counts[slotID] = nil
		b.links[slotID] = nil
		local link = GetContainerItemLink(bagID, slotID)
		if link ~= nil then
			b.ids[slotID] = self:GetIDFromLink(link)
			if self:GetEnchantInfo(link) then
				b.links[slotID] = link
			end
			local _, count = GetContainerItemInfo(bagID, slotID)
			if (count ~= nil) and (count > 1)  then
				b.counts[slotID] = count
			end
		end
	end
end

function Altoholic:UpdateKeyRing()
	local b = self.db.account.data[V.faction][V.realm].char[V.player].bag["Bag-2"]
	b.size = GetContainerNumSlots(-2)
	b.icon = "Interface\\Icons\\INV_Misc_Key_14";
	b.link = nil
	self:PopulateContainer(-2)
end

function Altoholic:UpdateContainerCache()
	local c = self.db.account.data[V.CurrentFaction][V.CurrentRealm].char[V.CurrentAlt]
	Altoholic.BagIndices = {}
	for bagID = 0, 10 do
		if c.bag["Bag"..bagID] ~= nil then
			self:UpdateBagIndices(bagID, c.bag["Bag"..bagID].size)
		end
	end
	self:UpdateBagIndices(-2, 32)
	if c.bag["Bag100"] ~= nil then
		self:UpdateBagIndices(100, 28)
	end
end

function Altoholic:UpdateBagIndices(bag, size)
	local lowerLimit = 1
	while size > 0 do
		table.insert(self.BagIndices, { bagID=bag, from=lowerLimit} )
		if size <= 12 then
			return
		else
			size = size - 12
			lowerLimit = lowerLimit + 12
		end
	end
end

function Altoholic:UpdatePlayerBank(scanBags)
	if scanBags == nil then
		scanBags = true
	end
	local c = self.db.account.data[V.faction][V.realm].char[V.player]
	if scanBags then
		local nTotalSlots = 28
		c.bankslots = "28/"
		for bagID = 5, 10 do
			self:UpdatePlayerBag(bagID)
			local nSlots = GetContainerNumSlots(bagID)
			nTotalSlots = nTotalSlots + nSlots
			c.bankslots = c.bankslots .. WHITE .. nSlots
			if bagID ~= 11 then
				c.bankslots = c.bankslots .. "|r/"
			end
		end
		c.bankslots = c.bankslots .. " |r(|cFF00FF00" .. nTotalSlots .. "|r)"
	end
	local b = c.bag["Bag100"]
	b.size = 28
	for slotID = 40, 67 do
		local index = slotID-39
		b.ids[index] = nil
		b.counts[index] = nil
		b.links[index] = nil
		local link = GetInventoryItemLink("player", slotID)
		if link ~= nil then
			b.ids[index] = self:GetIDFromLink(link)
			if self:GetEnchantInfo(link) then
				b.links[index] = link
			end
			local count = GetInventoryItemCount("player", slotID)
			if (count ~= nil) and (count > 1)  then
				b.counts[index] = count
			end
		end
	end
end

function Altoholic:UpdateRaidTimers()
	local c = self.db.account.data[V.faction][V.realm].char[V.player]
    c.SavedInstance = {}
	for i=1, GetNumSavedInstances() do
		local instanceName, instanceID, instanceReset = GetSavedInstanceInfo(i)
		c.SavedInstance[instanceName] = instanceID .. "|" .. instanceReset .. "|" .. time()
	end
end

-- *** Scroll Frames Update ***
function Altoholic:Menu_Update(MenuLevel1, MenuLevel2, MenuLevel3)
	local VisibleLines = 15
	if MenuLevel1 ~= nil then
		local m
		if MenuLevel2 ~= nil then
			if MenuLevel3 ~= nil then
				m = self.Menu[MenuLevel1].subMenu[MenuLevel2].subMenu[MenuLevel3]
			else
				m = self.Menu[MenuLevel1].subMenu[MenuLevel2]
            end
		else
			m = self.Menu[MenuLevel1]
		end
		if m.isCollapsed == true then
			m.isCollapsed = false
		else
			m.isCollapsed = true
		end
	end
    self.MenuCache = {}
	for _, L0 in pairs (self.Menu) do
		table.insert(self.MenuCache, { linetype=1, name=L0.name, OnClick=L0.OnClick } )
		if L0.isCollapsed == false then
			for _, L1 in pairs (L0.subMenu) do
				table.insert(self.MenuCache, { linetype=2, name=L1.name, id=L1.id, OnClick=L1.OnClick	} )
				if L1.isCollapsed == false then
					for _, L2 in pairs (L1.subMenu) do
						table.insert(self.MenuCache, { linetype=3, name=L2.name, id=L2.id, OnClick=L2.OnClick	} )
						if L2.isCollapsed == false then
							for _, L3 in pairs (L2.subMenu) do
								table.insert(self.MenuCache, { linetype=4, name=L3.name, id=L3.id, OnClick=L3.OnClick	} )
							end
						end
					end
				end
			end
		end
	end
	local offset = FauxScrollFrame_GetOffset(getglobal("AltoholicMenuScrollFrame"));
	for i=1, VisibleLines do
		local line = i + offset
		if line > table.getn(self.MenuCache) then
			getglobal("CategoryButton"..i):Hide()
		else
            local p = self.MenuCache[line]
            if p.linetype == 1 then
                getglobal("CategoryButton"..i.."NormalText"):SetText(WHITE .. p.name)
            elseif p.linetype == 2 then
                getglobal("CategoryButton"..i.."NormalText"):SetText("|cFFBBFFBB   " .. p.name)
            elseif p.linetype == 3 then
                getglobal("CategoryButton"..i.."NormalText"):SetText("|cFFBBBBFF      " .. p.name)
            else
                getglobal("CategoryButton"..i.."NormalText"):SetText("|cFFFFFFBB         " .. p.name)
            end
            if p.id ~= nil then
                getglobal("CategoryButton"..i):SetID(p.id)
            end
            getglobal("CategoryButton"..i):SetScript("OnClick", p.OnClick)
            getglobal("CategoryButton"..i):Show()
        end
	end
	FauxScrollFrame_Update(getglobal("AltoholicMenuScrollFrame"), table.getn(self.MenuCache), VisibleLines, 20);
end

-- *** Menu Management ***
function Altoholic:SelectAlt(id)
	local realmID = floor(id / 100)
	local charID = mod(id, 100)
	local realmNum = 1
	for FactionName, f in pairs(self.db.account.data) do
		for RealmName, r in pairs(f) do
			local charNum = 1
			for CharacterName, c in pairs(r.char) do
				if (charNum == charID) and (realmNum == realmID) then
					V.CurrentFaction = FactionName
					V.CurrentRealm = RealmName
					V.CurrentAlt = CharacterName
					return
				end
				charNum = charNum + 1
			end
			realmNum = realmNum + 1
		end
	end
end

function Altoholic:BuildContainersSubMenu()
    self.Menu[MENU_CONTAINERS].subMenu = {}
	local n = 1
	for FactionName, f in pairs(self.db.account.data) do
		for RealmName, r in pairs(f) do
            local realmsID = n
			table.insert(self.Menu[MENU_CONTAINERS].subMenu, {
				name = self:GetRealmString(FactionName, RealmName),
				isCollapsed = true,
				id = n,
				subMenu = {},
				OnClick = function(self)
                    Altoholic:Menu_Update(MENU_CONTAINERS, realmsID) end
			} )
			local i = 1
			for CharacterName, c in pairs(r.char) do
                local altID = (n*100)+i
				table.insert(self.Menu[MENU_CONTAINERS].subMenu[n].subMenu, {
					name = CharacterName,
					id = (n*100)+i,
					OnClick = function(self)
						Altoholic:SelectAlt(altID)
						Altoholic:UpdateContainerCache()
						Altoholic:ClearScrollFrame(getglobal("AltoContainersScrollFrame"), "AltoContainersEntry", 7, 41)
						Altoholic:ActivateMenuItem("AltoContainers")
					end
				} )
				i = i + 1
			end
			n = n + 1
		end
	end
end

function Altoholic:BuildMailSubMenu()
    self.Menu[MENU_MAIL].subMenu = {}
	local n = 1
	for FactionName, f in pairs(self.db.account.data) do
		for RealmName, r in pairs(f) do
            local realmsID = n
			table.insert(self.Menu[MENU_MAIL].subMenu, {
				name = self:GetRealmString(FactionName, RealmName),
				isCollapsed = true,
				id = n,
				subMenu = {},
				OnClick = function(self) Altoholic:Menu_Update(MENU_MAIL, realmsID)	end
			} )
    		local i = 1
			for CharacterName, c in pairs(r.char) do
				if table.getn(c.mail) >= 1 then
					CharacterNameM = CharacterName .. " " .. GREEN .. L["(has mail)"]
				end
                local altID = (n*100)+i
				table.insert(self.Menu[MENU_MAIL].subMenu[n].subMenu, {
					name = CharacterName,
                    hasmail = CharacterNameM,
					id = (n*100)+i,
					OnClick = function(self)
						Altoholic:SelectAlt(altID)
						Altoholic:ActivateMenuItem("AltoMail")
					end
				} )
				i = i + 1
			end
			n = n + 1
		end
	end
end

function Altoholic:BuildEquipmentSubMenu()
    self.Menu[MENU_EQUIPMENT].subMenu = {}
	local n = 1
	for FactionName, f in pairs(self.db.account.data) do
		for RealmName, r in pairs(f) do
            local altID = (n*100)+1
			table.insert(self.Menu[MENU_EQUIPMENT].subMenu, {
				name = self:GetRealmString(FactionName, RealmName),
				isCollapsed = true,
				id = (n*100)+1,
				subMenu = {},
				OnClick = function(self)
					Altoholic:SelectAlt(altID)
					Altoholic:ActivateMenuItem("AltoEquipment")
				end
			} )
			n = n + 1
		end
	end
end

function Altoholic:BuildQuestsSubMenu()
    self.Menu[MENU_QUESTS].subMenu = {}
	local n = 1
	for FactionName, f in pairs(self.db.account.data) do
		for RealmName, r in pairs(f) do
            local realmsID = n
			table.insert(self.Menu[MENU_QUESTS].subMenu, {
				name = self:GetRealmString(FactionName, RealmName),
				isCollapsed = true,
				id = n,
				subMenu = {},
				OnClick = function(self) Altoholic:Menu_Update(MENU_QUESTS, realmsID)	end
			} )
			local i = 1
			for CharacterName, c in pairs(r.char) do
                local altID = (n*100)+i
				table.insert(self.Menu[MENU_QUESTS].subMenu[n].subMenu, {
					name = CharacterName,
					id = (n*100)+i,
					OnClick = function(self)
						Altoholic:SelectAlt(altID)
						Altoholic:ActivateMenuItem("AltoQuests")
					end
				} )
				i = i + 1
			end
			n = n + 1
		end
	end
end

function Altoholic:BuildRecipesSubMenu()
    self.Menu[MENU_RECIPES].subMenu = nil
    self.Menu[MENU_RECIPES].subMenu = {}
	self.Menu[MENU_RECIPES].isCollapsed = true
	local n = 1
	for FactionName, f in pairs(self.db.account.data) do
		for RealmName, r in pairs(f) do
            local realmsID = n
			table.insert(self.Menu[MENU_RECIPES].subMenu, {
				name = self:GetRealmString(FactionName, RealmName),
				isCollapsed = true,
				id = n,
				subMenu = {},
				OnClick = function(self) Altoholic:Menu_Update(MENU_RECIPES, realmsID)	end
			} )
			local i = 1
			for CharacterName, c in pairs(r.char) do
                local altID = (n * 100) + i
				table.insert(self.Menu[MENU_RECIPES].subMenu[n].subMenu, {
					name = CharacterName,
					isCollapsed = true,
					id = (n * 100) + i,
					subMenu = {},
					OnClick = function(self)
						local id = altID
						local realmID = floor(id / 100)
						local charID = mod(id, 100)
						--Altoholic:SelectAlt(id)
						Altoholic:Menu_Update(MENU_RECIPES, realmID, charID)
					end
				} )
				for TradeSkillName, _ in pairs(c.recipes) do
                    local skillsID = Altoholic:GetProfessionID(TradeSkillName) + (n * 10000) + (i * 100)
                    table.insert(self.Menu[MENU_RECIPES].subMenu[n].subMenu[i].subMenu, {
                        name = TradeSkillName,
                        id = Altoholic:GetProfessionID(TradeSkillName) + (n * 10000) + (i * 100),
                        OnClick = function(self)
                            local id = skillsID
                            local skillID = mod(id, 100)
                            id = floor(id / 100)
                            Altoholic:SelectAlt(altID)
                            Altoholic:SelectProfession(skillID)
                            Altoholic:ActivateMenuItem("AltoRecipes")
                        end
                    } )
				end
				i = i + 1
			end
			n = n + 1
		end
	end
end

function Altoholic:BuildAuctionsSubMenu()
    self.Menu[MENU_AUCTIONS].subMenu = {}
    local n = 1
	for FactionName, f in pairs(self.db.account.data) do
        for RealmName, r in pairs(f) do
            local realmsID = n
			table.insert(self.Menu[MENU_AUCTIONS].subMenu, {
				name = self:GetRealmString(FactionName, RealmName),
				isCollapsed = true,
				id = n,
				subMenu = {},
				OnClick = function(self) Altoholic:Menu_Update(MENU_AUCTIONS, realmsID) end
			} )
			local i = 1
			for CharacterName, c in pairs(r.char) do
                local CharacterName = CharacterName
                if table.getn(c.auctions) >= 1 then
                    CharacterName = CharacterName .. " " .. GREEN .. L["(has auctions)"]
                end
                local altID = (n*100)+i
				table.insert(self.Menu[MENU_AUCTIONS].subMenu[n].subMenu, {
					name = CharacterName,
					id = (n*100)+i,
					OnClick = function(self)
						Altoholic.Auctions_Update = Altoholic.Auctions_Update_Auctions
						V.AuctionType = "auctions"
						Altoholic:SelectAlt(altID)
						Altoholic:ActivateMenuItem("AltoAuctions")
					end
				} )
				i = i + 1
			end
            n = n + 1
		end
	end
end

function Altoholic:BuildBidsSubMenu()
    self.Menu[MENU_BIDS].subMenu = {}
	local n = 1
	for FactionName, f in pairs(self.db.account.data) do
		for RealmName, r in pairs(f) do
            local realmsID = n
			table.insert(self.Menu[MENU_BIDS].subMenu, {
				name = self:GetRealmString(FactionName, RealmName),
				isCollapsed = true,
				id = n,
				subMenu = {},
				OnClick = function(self) Altoholic:Menu_Update(MENU_BIDS, realmsID) end
			} )
			local i = 1
			for CharacterName, c in pairs(r.char) do
                local CharacterName = CharacterName
				if table.getn(c.bids) > 0 then
					CharacterName = CharacterName .. " " .. GREEN .. L["(has bids)"]
				end
                local altID = (n*100)+i
				table.insert(self.Menu[MENU_BIDS].subMenu[n].subMenu, {
					name = CharacterName,
					id = (n*100)+i,
					OnClick = function(self)
						Altoholic.Auctions_Update = Altoholic.Auctions_Update_Bids
						V.AuctionType = "bids"
						Altoholic:SelectAlt(altID)
						Altoholic:ActivateMenuItem("AltoAuctions")
					end
				} )
				i = i + 1
			end
			n = n + 1
		end
	end
end

function Altoholic:BuildFactionsTable()
	local repDB = self.db.account.data[V.faction][V.realm].reputation
	if V.Factions then
        Altoholic.vars.Factions = {}
	else
		V.Factions = {}
	end
	local factionGroup
	for i, f in pairs(self.FactionsRefTable) do
		if type(f) == "string" then
			for repName, _ in pairs(repDB) do
				if repName == f then
					if factionGroup ~= nil then
						table.insert(V.Factions, {
							name = self.FactionsRefTable[factionGroup][1],
							isHeader = true,
							isCollapsed = false
						} )
						factionGroup = nil
					end
					table.insert(V.Factions, f)
					break
				end
			end
		else
			factionGroup = i
		end
	end
end

function Altoholic:GetProfessionID(skill)
    local Profs = {
    [1] = BI["Tailoring"],
    [2] = BI["Leatherworking"],
    [3] = BI["Engineering"],
    [4] = BI["Enchanting"],
    [5] = BI["Blacksmithing"],
    [6] = BI["Alchemy"],
    [7] = L["Mining"],
    [8] = BI["First Aid"],
    [9] = BI["Cooking"],
    [10] = BI["Fishing"],
    [11] = L["Riding"],
    [12] = L["Poisons"],
    [13] = L["Lockpicking"]
    }
	for i,v in (Profs) do
		if skill == v then
			return i
		end
	end
end

function Altoholic:SelectProfession(id)
    local Profs = {
    [1] = BI["Tailoring"],
    [2] = BI["Leatherworking"],
    [3] = BI["Engineering"],
    [4] = BI["Enchanting"],
    [5] = BI["Blacksmithing"],
    [6] = BI["Alchemy"],
    [7] = L["Mining"],
    [8] = BI["First Aid"],
    [9] = BI["Cooking"],
    [10] = BI["Fishing"],
    [11] = L["Riding"],
    [12] = L["Poisons"],
    [13] = L["Lockpicking"]
    }
    for i,v in (Profs) do
        if id == i then
            local ProfessionLevel
            V.CurrentProfession = v
            if id < 8 then
                ProfessionLevel = Altoholic.db.account.data[V.CurrentFaction][V.CurrentRealm].char[V.CurrentAlt].skill[L["Professions"]][V.CurrentProfession]
            elseif id == 8 or id == 9 or id == 10 or id == 11 then
                ProfessionLevel = Altoholic.db.account.data[V.CurrentFaction][V.CurrentRealm].char[V.CurrentAlt].skill[L["Secondary Skills"]][V.CurrentProfession]
            elseif id == 12 or id == 13 then
                if c.class ~= L["Rogue"] then
			        return
		        end
                ProfessionLevel = Altoholic.db.account.data[V.CurrentFaction][V.CurrentRealm].char[V.CurrentAlt].skill[L["Rogue Proficiencies"]][V.CurrentProfession]
            end
            local rank, maxRank = Altoholic:strsplit("|", ProfessionLevel)
            V.CurrentProfessionLevel = Altoholic:GetSkillColor(tonumber(rank)) .. rank .. "/" .. maxRank
        end
    end
end

function Altoholic:ClearScrollFrame(name, entry, lines, height)
	for i=1, lines do
		getglobal(entry..i):Hide()
	end
	FauxScrollFrame_Update(name, lines, lines, height);
end

function Altoholic:CreateScrollLines(parentFrame, inheritsFrom, numLines, numItems)
	local f = CreateFrame("Button", parentFrame .. "Entry" .. 1, getglobal(parentFrame), inheritsFrom)
	f:SetPoint("TOPLEFT", parentFrame .. "ScrollFrame", "TOPLEFT", 0, 0)
	for i = 2, numLines do
		f = CreateFrame("Button", parentFrame .. "Entry" .. i, getglobal(parentFrame), inheritsFrom)
		f:SetPoint("TOPLEFT", parentFrame .. "Entry" .. (i-1), "BOTTOMLEFT", 0, 0)
	end
	if not numItems then return end
	for i=1, numLines do
		getglobal(parentFrame.."Entry"..i.."Item" .. numItems):SetPoint("BOTTOMRIGHT", parentFrame .. "Entry"..i, "BOTTOMRIGHT", -15, 0);
		for j=(numItems-1), 1, -1 do
			getglobal(parentFrame.."Entry"..i.."Item" .. j):SetPoint("BOTTOMRIGHT", parentFrame.."Entry"..i.."Item" .. (j + 1), "BOTTOMLEFT", -5, 0);
		end
	end
end

function Altoholic_GetItemLink(itemID)
    if not itemID then return end
    local itemName, itemString, itemQuality = GetItemInfo(itemID)
    local _, _, _, itemColor = GetItemQualityColor(itemQuality)
    local itemLink = itemColor .. "|H" .. itemString .. "|h[" .. itemName .. "]|h|r"
    return itemLink
end

function Altoholic:GetIDFromLink(link)
    if not link then return end
    local _, _, itemId = string.find(link, ".*item:(%d+).*")
    return tonumber(itemId)
end

function Altoholic:GetEnchantIDFromLink(link)
    if not link then return end
    local _, _, itemId = string.find(link, ".*(enchant:%d+).*")
    return tostring(itemId)
end

function Altoholic:GetEnchantInfo(link)
	local _, _, itemString = Altoholic:strsplit("|", link)
	local _, itemId, enchantId, suffixId, uniqueId = Altoholic:strsplit(":", itemString)
	local isEnchanted = false
	for i=1, 6 do
		if i == enchantId or suffixId and i ~= "0" then
			isEnchanted = true
			break
		end
	end
	return isEnchanted, enchantId, suffixId
end

function Altoholic:GetMoneyString(copper, color)
	local gold = floor( copper / 10000 );
	copper = copper - (gold * 10000)
	local silver = floor( copper / 100 );
	copper = copper - (silver * 100)
	if color == nil then
		color = "|cFFFFD700"
	end
	return color .. gold .. "|cFFFFD700g " .. color .. silver .. "|cFFC7C7CFs " .. color .. copper .. "|cFFEDA55Fc"
end

function Altoholic:GetTimeString(seconds)
	local days = floor(seconds / 86400);
	seconds = seconds - (days * 86400)
	local hours = floor(seconds / 3600);
	seconds = seconds - (hours * 3600)
	local minutes = floor(seconds / 60);
	seconds = seconds - (minutes * 60)
	local c1 = WHITE
	local c2 = "|r"
	return c1 .. days .. c2 .. "d " .. c1 .. hours .. c2 .. "h " .. c1 .. minutes .. c2 .. "m"
end

function Altoholic:GetRealmString(faction, realm)
	if faction == FACTION_ALLIANCE then
		return "|cFF2459FF" .. realm
	else
		return "|cFFFF0000" .. realm
	end
end

function Altoholic:GetFullRealmString(faction, realm)
	if faction == "Alliance" then
		return "|cFF2459FF[" .. FACTION_ALLIANCE .. "] " .. WHITE .. realm
	else
		return "|cFFFF0000[" .. FACTION_HORDE .. "] " .. WHITE .. realm
	end
end

function Altoholic:GetQuestTypeString(tag, size)
	if size == 0 then
		return WHITE .. tag
	elseif size == 2 then
		return WHITE .. tag .. GREEN .. " (" .. size .. ")"
	elseif size == 3 then
		return WHITE .. tag .. YELLOW .. " (" .. size .. ")"
	elseif size == 4 then
		return WHITE .. tag .. ORANGE .. " (" .. size .. ")"
	end
	return WHITE .. tag .. RED .. " (" .. size .. ")"
end

function Altoholic:GetClassColor(class)
	return self.ClassInfo[self.Classes[class]].color
end

function Altoholic:GetDelayInDays(delay)
	return floor((time() - delay) / 86400)
end

function Altoholic:GetRestedXP(level, restXP, logout, isResting)
	if level == LEVEL_CAP then
		return L["No rest XP"]
	end
	local rate = self:GetRestXPRate(level, restXP)
	if logout ~= 0 then
		if isResting then
			rate = rate + ((time() - logout) / 8640)
		else
			rate = rate + ((time() - logout) / 34560)
		end
	end
	local coeff
	if AltoOptions_RestXPMode:GetChecked() then
		coeff = 1.5
		rate = rate * coeff
	else
		coeff = 1
	end
	if rate >= (100 * coeff) then
		return "|cFF00FF00" .. format("%d", (100 * coeff)) .. L["% rested"]
	else
		local color
		if rate < (30 * coeff) then
			color = "|cFFFF0000"
		elseif rate < (60 * coeff) then
			color = "|cFFFFFF00"
		else
			color = GREEN
		end
		return color .. format("%d", rate) .. L["% rested"]
	end
end

function Altoholic:GetRestXPRate(level, restXP)
	if not restXP then return 0 end
	return (restXP / ((self.XPToNext[level] / 100) * 1.5))
end

function Altoholic:GetCharacterInfo(line)
	for i = line-1, 1, -1 do
		local s = self.CharacterInfo[i]
		if s.linetype == INFO_REALM_LINE then
			return s.faction, s.realm
		end
	end
end

function Altoholic:GetItemDropLocation(searchedID)
	for Instance, BossList in pairs(Altoholic.LootTable) do
		for Boss, LootList in pairs(BossList) do
			for itemID, _ in pairs(LootList) do
				if LootList[itemID] == searchedID then
					return Instance, Boss
				end
			end
		end
	end
	return nil
end

function Altoholic:GetItemCount(searchedID)
	if V.ItemCount == nil then
		V.ItemCount = {}
	end
	local count = 0
	for CharacterName, c in pairs(self.db.account.data[V.faction][V.realm].char) do
		local bagCount = 0
		local bankCount = 0
		for BagName, b in pairs(c.bag) do
			for slotID=1, b.size do
				local id = b.ids[slotID]
				if (id) and (id == searchedID) then
					local itemCount
					if (b.counts[slotID] == nil) or (b.counts[slotID] == 0) then
						itemCount = 1
					else
						itemCount = b.counts[slotID]
					end
					if (BagName == "Bag100") then
						bankCount = bankCount + itemCount
					elseif (BagName == "Bag-2") then
						bagCount = bagCount + itemCount
					else
						local bagNum = tonumber(string.sub(BagName, 4))
						if (bagNum >= 0) and (bagNum <= 4) then
							bagCount = bagCount + itemCount
						else
							bankCount = bankCount + itemCount
						end
					end
				end
			end
		end
		local equipCount = 0
		for slotID=1, 19 do
			local s = c.inventory[slotID]
			if (s ~= nil) then
				if type(s) == "number" then
					if (s == searchedID) then
						equipCount = equipCount + 1
					end
				elseif self:GetIDFromLink(s) == searchedID then
					equipCount = equipCount + 1
				end
			end
		end
		local mailCount = 0
		for slotID=1, table.getn(c.mail) do
			local s = c.mail[slotID]
			if (s.link ~= nil) and (self:GetIDFromLink(s.link) == searchedID) then
				if (s.count == nil) or (s.count == 0) then
					mailCount = mailCount + 1
				else
					mailCount = mailCount + s.count
				end
			end
		end
		local charCount = bagCount + bankCount + equipCount + mailCount
		count = count + charCount
		if charCount > 0 then
			local charInfo = ORANGE .. charCount .. WHITE .. " ("
			if bagCount > 0 then
				charInfo = charInfo .. WHITE .. L["Bags"] .. ": "  .. TEAL .. bagCount
				charCount = charCount - bagCount
				if charCount > 0 then
					charInfo = charInfo .. WHITE .. L[", "]
				end
			end
			if bankCount > 0 then
				charInfo = charInfo .. WHITE .. L["Bank"] .. ": " .. TEAL .. bankCount
				charCount = charCount - bankCount
				if charCount > 0 then
					charInfo = charInfo .. WHITE .. L[", "]
				end
			end
			if equipCount > 0 then
				charInfo = charInfo .. WHITE .. L["Equipped"] .. ": "  .. TEAL .. equipCount
				charCount = charCount - equipCount
				if charCount > 0 then
					charInfo = charInfo .. WHITE .. L[", "]
				end
			end
			if mailCount > 0 then
				charInfo = charInfo .. WHITE .. L["Mail"] .. ": "  .. TEAL .. mailCount
			end
			charInfo = charInfo .. WHITE .. ")"
			V.ItemCount[Altoholic:GetClassColor(c.class) .. CharacterName] = charInfo
		end
	end
	return count
end

function Altoholic:IsGatheringNode(name)
	if name == nil then return nil end
	for k, v in pairs( self.Gathering ) do
		if name == k then
			return v
		end
	end
	return nil
end

function Altoholic:IsKnownQuest(quest)    
	if not quest then return nil end
	local bOtherCharsOnQuest
	for CharacterName, c in pairs(self.db.account.data[V.faction][V.realm].char) do
		if CharacterName ~= V.player then
			for index, q in pairs(c.questlog) do
				local altQuestName = q.link
				if altQuestName == quest then
					if not bOtherCharsOnQuest then
						ItemRefTooltip:AddLine(" ",1,1,1);
						ItemRefTooltip:AddLine(GREEN .. L["Are also on this quest:"],1,1,1);
						bOtherCharsOnQuest = true
					end
					ItemRefTooltip:AddLine(Altoholic:GetClassColor(c.class) .. CharacterName,1,1,1);
                    ItemRefTooltip:Show();
				end
			end
		end
	end
end

function Altoholic:GetSuggestion(index, level)
	if self.Suggestions[index] == nil then return nil end
	for k, v in pairs( self.Suggestions[index] ) do
		if level < v[1] then
			return v[2]
		end
	end
	return nil
end

function Altoholic:GetSkillColor(rank)
	if rank < 75 then
		return RED
	elseif rank < 150 then
		return ORANGE
	elseif rank < 225 then
		return YELLOW
	else
		return GREEN
	end
end

function Altoholic:UpdateMinimapIconCoords()
	local xPos, yPos = GetCursorPosition()
	local left, bottom = Minimap:GetLeft(), Minimap:GetBottom()
	xPos = left - xPos/UIParent:GetScale() + 70
	yPos = yPos/UIParent:GetScale() - bottom - 70
	local O = self.db.account.options
	O.MinimapIconAngle = math.deg(math.atan2(yPos, xPos))
	if(O.MinimapIconAngle < 0) then
		O.MinimapIconAngle = O.MinimapIconAngle + 360
	end
	getglobal("AltoOptions_SliderAngle"):SetValue(O.MinimapIconAngle)
end

function Altoholic:UpdateSlider(name, text, field)
	local s = getglobal(name)
	getglobal(name .. "Text"):SetText(text .. " (" .. s:GetValue() ..")");
	local a = self.db.account
	if a == nil then return	end
	a.options[field] = s:GetValue()
	self:MoveMinimapIcon()
end

function Altoholic:MoveMinimapIcon()
	local O = self.db.account.options
	AltoholicMinimapButton:SetPoint(	"TOPLEFT", "Minimap", "TOPLEFT",
		54 - (O.MinimapIconRadius * cos(O.MinimapIconAngle)),
		(O.MinimapIconRadius * sin(O.MinimapIconAngle)) - 55	);
end

-- *** Overloaded events (OnEnter, OnClick ..) ***
function Altoholic:DrawCharacterTooltip(charName)
	local c = self.db.account.data[V.CurrentFaction][V.CurrentRealm].char[charName]
	AltoTooltip:SetOwner(this, "ANCHOR_LEFT");
	AltoTooltip:ClearLines();
	AltoTooltip:AddLine(Altoholic:GetClassColor(c.class)..charName,1,1,1);
	AltoTooltip:AddLine(L["Level"] .. " " .. GREEN .. c.level .. " |r".. c.race .. " " .. c.class,1,1,1);
	AltoTooltip:AddLine(L["Zone"] .. ": " .. GOLD .. c.zone .. " |r(" .. GOLD .. c.subzone .."|r)",1,1,1);
	if c.restxp then
		AltoTooltip:AddLine(L["Rest XP"] .. ": " .. GREEN .. c.restxp,1,1,1);
	end
	AltoTooltip:Show();
end

-- *** Hooks ***
local Orig_ChatEdit_InsertLink = ChatEdit_InsertLink
function ChatEdit_InsertLink(text,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9)
	if text and AltoholicFrame_SearchEditBox:IsVisible() then
		AltoholicFrame_SearchEditBox:Insert(GetItemInfo(text))
		return true
	else
		return Orig_ChatEdit_InsertLink(text,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9)
	end
end

-- ** GameTooltip Hooks **
function Altoholic:HookTooltip()
    self:SecureHook(GameTooltip, "SetBagItem", function(this, bag, slot)
        Altoholic:ProcessTooltip(GameTooltip, "Game", link, bag, slot)
    end)
    self:SecureHook(GameTooltip, "SetInventoryItem", function(this, bag, slot)
        Altoholic:ProcessTooltip(GameTooltip, "Game", link, bag, slot)
    end)
    self:SecureHook(GameTooltip, "SetInboxItem", function(index)
        Altoholic:ProcessTooltip(index, "Game")
    end)
    self:SecureHook(GameTooltip, "SetAuctionItem", function(this, type, index)
        local link = GetAuctionItemLink(type, index)
        Altoholic:ProcessTooltip(GameTooltip, "Game", link)
    end)
    self:SecureHook("SetItemRef", function(link, name, button)
        Altoholic:ProcessTooltip(ItemRefTooltip, "ItemRef", link)
        Altoholic:IsKnownQuest(name)
    end)
    --[[self:SecureHook(GameTooltip, "Show", function(tooltip)
        local itemID = Altoholic:IsGatheringNode(getglobal("GameTooltipTextLeft1"):GetText() )
        if itemID then
            if AltoOptions_TooltipCount:GetChecked() or AltoOptions_TooltipTotal:GetChecked() then
                V.ToolTipCachedCount = Altoholic:GetItemCount(itemID)
                if V.ToolTipCachedCount > 0 then
                    V.ToolTipCachedTotal = GOLD .. L["Total owned"] .. ": |cff00ff9a" .. V.ToolTipCachedCount
                else
                    V.ToolTipCachedTotal = nil
                end
            end
            if (AltoOptions_TooltipCount:GetChecked()) and (V.ToolTipCachedCount > 0) then
                GameTooltip:AddLine(" ",1,1,1);
                for CharacterName, c in pairs (V.ItemCount) do
                    GameTooltip:AddDoubleLine(CharacterName .. ":",  TEAL .. c);
                end
            end
            if (AltoOptions_TooltipTotal:GetChecked()) and (V.ToolTipCachedTotal) then
                GameTooltip:AddLine(V.ToolTipCachedTotal,1,1,1);
            end
        end
    end)]]
end

function Altoholic_OnShow()
  --do return end
  local itemID = Altoholic:IsGatheringNode(getglobal("GameTooltipTextLeft1"):GetText() );
  --DEFAULT_CHAT_FRAME:AddMessage("OnSHow " .. itemID);
  if itemID then
      if AltoOptions_TooltipCount:GetChecked() or AltoOptions_TooltipTotal:GetChecked() then
          V.ItemCount = nil;
          V.ToolTipCachedCount = Altoholic:GetItemCount(itemID)
          if V.ToolTipCachedCount > 0 then
              V.ToolTipCachedTotal = GOLD .. L["Total owned"] .. ": |cff00ff9a" .. V.ToolTipCachedCount
          else
              V.ToolTipCachedTotal = nil
          end
      end
      if (AltoOptions_TooltipCount:GetChecked()) and (V.ToolTipCachedCount > 0) then
          GameTooltip:AddLine(" ",1,1,1);
          for CharacterName, c in pairs (V.ItemCount) do
              GameTooltip:AddDoubleLine(CharacterName .. ":",  TEAL .. c);
          end
      end
      if (AltoOptions_TooltipTotal:GetChecked()) and (V.ToolTipCachedTotal) then
          GameTooltip:AddLine(V.ToolTipCachedTotal,1,1,1);
          GameTooltip:AddLine(" ",1,1,1);
      end
  end
end

function Altoholic:RecipeOrBook(ttname)
    local isRecipe, isBook
    if ttname then
        local isMatch = nil
        local rb = Altoholic.RecipesBooks
        for r = 1, 5 do
            if string.find(ttname, rb[r]) then
                isMatch = "isRecipe"
            end
        end
        for b = 6, 17 do
            if string.find(ttname, rb[b]) then
                isMatch = "isBook"
            end
        end
        if isMatch then
            return isMatch
        end
    else
        return nil
    end
end

function Altoholic:AltHasTradeSkill(c, prof)
    local r = self.db.account.data[V.faction][V.realm].char[c]
    if c then
        local minSkillp, _ = Altoholic:GetSkillInfo(r.skill[L["Professions"]][prof])
        if minSkillp > 0 then
            return true
        end      
        local minSkills, _ = Altoholic:GetSkillInfo(r.skill[L["Secondary Skills"]][prof])
        if minSkills > 0 then
            return true
        end
    else
        return false
    end
end

function Altoholic:WhoKnowsRecipe(tooltip, ttype)
    if (AltoOptions_TooltipAlreadyKnown:GetChecked() or AltoOptions_TooltipLearnableBy:GetChecked()) == nil then return end
    if tooltip == nil then return end
    if ttype == "Game" then
        local ttype = "Game"
        self = GameTooltip
    elseif ttype == "ItemRef" then
        local ttype = "ItemRef"
        self = ItemRefTooltip
    end
    local ttname = getglobal(ttype..'TooltipTextLeft1'):GetText()
    if ttname == nil then return end
    if Altoholic:RecipeOrBook(ttname) == "isBook" then
        local ttuse = getglobal(ttype..'TooltipTextLeft4'):GetText()
        local spellName, reqClass, reqLevel
        if string.find(ttuse, "%sTeaches") and not string.find(getglobal(ttype..'TooltipTextLeft4'):GetText(), USED) then
            _, _, spellName = string.find(ttuse, ".*Teaches%s(.+%s%(.+%))")
            _, _, reqClass = string.find(getglobal(ttype..'TooltipTextLeft2'):GetText(), string.gsub(ITEM_CLASSES_ALLOWED,"%%s","(.+)"))
            _, _, reqLevel = string.find(getglobal(ttype..'TooltipTextLeft3'):GetText(), string.gsub(ITEM_MIN_LEVEL,"%%d","(.+)"))
            local book
            for CharacterName, c in pairs(Altoholic.db.account.data[V.faction][V.realm].char) do
                local isNotKnownByChar = false
                for _, SpellName in pairs(c.spells) do
                    if SpellName ~= spellName then
                        isNotKnownByChar = true
                        break
                    end
                end
                local ttlines
                if isNotKnownByChar and reqClass == c.class then
                    if AltoOptions_TooltipLearnableBy:GetChecked() then
                        if c.level < tonumber(reqLevel) then
                            ttlines = RED .. L["Will be learnable by "] .. WHITE .. CharacterName .. YELLOW .. " ("..c.level..")" .. "\n"
                        else
                            ttlines = YELLOW .. L["Could be learned by "] .. WHITE .. CharacterName .. "\n"
                        end
                    else
                        ttlines = ""
                    end
                elseif reqClass == c.class then
                    if AltoOptions_TooltipAlreadyKnown:GetChecked() then 
                        ttlines = TEAL .. L["Already known by "] .. WHITE .. CharacterName .. "\n"
                    else
                        ttlines = ""
                    end
                end
                if book == nil then
                    book = ttlines
                elseif ttlines then
                    book = book .. ttlines
                end
            end
            if book then
                self:AddLine(" ",1,1,1)
                self:AddLine(book,1,1,1)
            end
        end
    elseif Altoholic:RecipeOrBook(ttname) == "isRecipe" then        
        local recipeName, ttProfession, profName, profLevel, recipeTT, msg
        _, _, recipeName = string.find(ttname, ".*:%s(.+)")
        ttProfession = getglobal(ttype..'TooltipTextLeft2'):GetText()
        _, _, profName, profLevel = string.find(ttProfession, ".*%s(.+)%s%((.+)%)")
        profLevel = tonumber(profLevel)
        for CharacterName, c in pairs(Altoholic.db.account.data[V.faction][V.realm].char) do
            if Altoholic:AltHasTradeSkill(CharacterName, profName) and c.recipes[profName].ScanFailed then
                self:AddLine(" ",1,1,1)
                self:AddLine("------------------------------------------------",1,1,1)
                self:AddLine("Recipe database is empty for " .. CharacterName .. ".",1,0,0)
                self:AddLine("Please open your " .. profName .. " tradeskill.",1,0,0)
                self:AddLine("------------------------------------------------",1,1,1)
            end
            for ProfessionName, p in pairs(c.recipes) do
                if ProfessionName == profName then
                    local isKnownByChar = false
                    for _, TradeSkillInfo in pairs (p.list) do
                        if TradeSkillInfo.name ~= nil then
                            local skillName = TradeSkillInfo.name
                            if skillName == recipeName then
                                isKnownByChar = true
                                break
                            end
                        end
                    end
                    local ttlines = nil
                    if isKnownByChar then
                        if AltoOptions_TooltipAlreadyKnown:GetChecked() then 
                            ttlines = TEAL .. L["Already known by "] .. WHITE .. CharacterName .. "\n"
                        else
                            ttlines = ""
                        end
                    else
                        if AltoOptions_TooltipLearnableBy:GetChecked() then 
                            local curRank
                            if (ProfessionName == BI["Cooking"]) or
                                (ProfessionName == BI["First Aid"]) or
                                (ProfessionName == BI["Fishing"]) then
                                curRank = Altoholic:GetSkillInfo( c.skill[L["Secondary Skills"]][ProfessionName] )
                            else
                                curRank = Altoholic:GetSkillInfo( c.skill[L["Professions"]][ProfessionName] )
                            end
                            if curRank < profLevel and curRank > 0 then
                                ttlines = RED .. L["Will be learnable by "] .. WHITE .. CharacterName .. YELLOW .. " ("..curRank..")" .. "\n"
                            elseif curRank > profLevel then
                                ttlines = YELLOW .. L["Could be learned by "] .. WHITE .. CharacterName .. "\n"
                            end
                        else
                            ttlines = ""
                        end
                    end
                    if recipeTT == nil then
                        recipeTT = ttlines
                    else
                        recipeTT = recipeTT .. ttlines
                    end
                end                
            end
        end
        if recipeTT then
            self:AddLine(" ",1,1,1)
            self:AddLine(recipeTT,1,1,1)
        end
    end
end

function Altoholic:GetCraftFromRecipe(link)
	local _, _, _, recipeName = Altoholic:strsplit("|", link)
	local craftName
	local pos = string.find(recipeName, L["Transmute"])
	if pos then
		return string.sub(recipeName, pos, -2)
	else
        _, _, _, craftName = Altoholic:strsplit(":", recipeName)
	end
	if craftName == nil then
		return string.sub(recipeName, 3, -2)
	end
	return string.sub(craftName, 2, -2)
end

function Altoholic:ProcessTooltip(tooltip, ttype, link, bagID, slotID)
    if Altoholic:IsGatheringNode(getglobal("GameTooltipTextLeft1"):GetText() ) then return end;
    local itemID
    if bagID == "player" then        
        bagID = 100
        slotID = slotID - 39
    end
    if link then
        itemID = self:GetIDFromLink(link)
    elseif bagID and slotID then
        itemID = self.db.account.data[V.faction][V.realm].char[V.alt].bag["Bag" .. bagID].ids[slotID]
        if itemID == nil then return end
    end
	if (not V.ToolTipCachedItemID) or 
		(V.ToolTipCachedItemID and (itemID ~= V.ToolTipCachedItemID)) then
		V.TooltipRecipeCache = nil
        V.ItemCount = nil
		if AltoOptions_TooltipSource:GetChecked() then
			local Instance, Boss = self:GetItemDropLocation(itemID)
			V.ToolTipCachedItemID = itemID
			if (Instance == nil) then
				V.ToolTipCachedSource = nil
			else
				V.ToolTipCachedSource = GOLD .. L["Source"]..  ": |cff00ff9a" .. Instance .. ": " .. Boss
			end
		else
			V.ToolTipCachedSource = nil
		end
		if AltoOptions_TooltipCount:GetChecked() or AltoOptions_TooltipTotal:GetChecked() then
			V.ToolTipCachedCount = self:GetItemCount(itemID)
			if V.ToolTipCachedCount > 0 then
				V.ToolTipCachedTotal = GOLD .. L["Total owned"] .. ": |cff00ff9a" .. V.ToolTipCachedCount
			else
				V.ToolTipCachedTotal = nil
			end
		end
	end
	if (AltoOptions_TooltipCount:GetChecked()) and (V.ToolTipCachedCount > 0) then
		tooltip:AddLine(" ",1,1,1);
		for CharacterName, c in pairs (V.ItemCount) do
			tooltip:AddDoubleLine(CharacterName .. ":",  TEAL .. c);
		end
	end
	if (AltoOptions_TooltipTotal:GetChecked()) and (V.ToolTipCachedTotal) then
		tooltip:AddLine(V.ToolTipCachedTotal,1,1,1,true);
	end
	if V.ToolTipCachedSource then
		tooltip:AddLine(" ",1,1,1);
		tooltip:AddLine(V.ToolTipCachedSource,1,1,1,true);
	end
	-- Keep here if necessary, can be useful for debugging
	-- local iLevel = select(4, GetItemInfo(itemID))
	-- if iLevel then
		-- tooltip:AddLine(" ",1,1,1);
		-- tooltip:AddDoubleLine("Item ID: " .. GREEN .. itemID,  "iLvl: " .. GREEN .. iLevel);
		-- tooltip:AddLine(TEAL .. select(10, GetItemInfo(itemID)));
	-- end
	if not V.TooltipRecipeCache then
        self:WhoKnowsRecipe(tooltip, ttype)
	end
    tooltip:Show()
end

-- *** EVENT HANDLERS ***
function Altoholic:PLAYER_ALIVE()
	local c = self.db.account.data[V.faction][V.realm].char[V.player]
	c.level = UnitLevel("player")
	c.race = UnitRace("player")
	c.class = UnitClass("player")
	self:UpdatePlayerStats()
	self:UpdateTalents()
end

function Altoholic:AceEvent_FullyInitialized()
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
	self:RegisterEvent("TRADE_SKILL_SHOW")
	self:RegisterEvent("TRADE_SKILL_CLOSE")
	self:RegisterEvent("CRAFT_SHOW")
	self:RegisterEvent("CRAFT_CLOSE")
	self:RegisterEvent("LEARNED_SPELL_IN_TAB")
	local c = self.db.account.data[V.faction][V.realm].char[V.player]
	c.level = UnitLevel("player")
	c.race = UnitRace("player")
	c.class = UnitClass("player")
	self:UpdatePlayerStats()
	self:UpdateTalents()
    self:UpdatePlayerBags()
	self:BuildUnsafeItemList()
    self:HookTooltip()
end

function Altoholic:PLAYER_LEVEL_UP(newLevel)
	self.db.account.data[V.faction][V.realm].char[V.player].level = newLevel
end

function Altoholic:PLAYER_XP_UPDATE()
	local c = self.db.account.data[V.faction][V.realm].char[V.player]
	c.xp = UnitXP("player")
	c.xpmax = UnitXPMax("player")
	c.restxp = GetXPExhaustion()
end

function Altoholic:PLAYER_MONEY()
	self.db.account.data[V.faction][V.realm].char[V.player].money = GetMoney();
end

function Altoholic:PLAYER_UPDATE_RESTING()
	self.db.account.data[V.faction][V.realm].char[V.player].isResting = IsResting();
end

function Altoholic:PLAYER_GUILD_UPDATE()
	V.guild = GetGuildInfo("player")
end

function Altoholic:ZONE_CHANGED()
	self:UpdatePlayerLocation()
end

function Altoholic:ZONE_CHANGED_NEW_AREA()
	self:UpdatePlayerLocation()
end

function Altoholic:ZONE_CHANGED_INDOORS()
	self:UpdatePlayerLocation()
end

function Altoholic:UpdatePlayerLocation()
	local c = self.db.account.data[V.faction][V.realm].char[V.player]
	c.zone = GetRealZoneText()
	c.subzone = GetSubZoneText()
end

function Altoholic:PLAYER_LOGOUT()
	self.db.account.data[V.faction][V.realm].char[V.player].lastlogout = time()
end

function Altoholic:TIME_PLAYED_MSG(TotalTime, CurrentLevelTime)
	self.db.account.data[V.faction][V.realm].char[V.player].played = TotalTime
end

function Altoholic:UNIT_INVENTORY_CHANGED()
	self:UpdateEquipment()
end

function Altoholic:BAG_UPDATE(bag)
	V.ToolTipCachedItemID = nil
	if (bag >= 5) and (bag <= 11) and not V.isBankOpen then
		return
	end
	if V.isMailBoxOpen then
		self:UpdatePlayerMail()
	end
    self:UpdatePlayerBags()
    self:UpdatePlayerInventory()
end

function Altoholic:BANKFRAME_OPENED()
    self:UpdatePlayerBank()
	V.isBankOpen = true
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
end

function Altoholic:BANKFRAME_CLOSED()
	V.isBankOpen = nil
	if self:IsEventRegistered("PLAYERBANKSLOTS_CHANGED") then
		self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED")
	end
end

function Altoholic:PLAYERBANKSLOTS_CHANGED()
	self:UpdatePlayerBank(false)
end
