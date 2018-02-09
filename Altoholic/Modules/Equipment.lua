local L = AceLibrary("AceLocale-2.2"):new("Altoholic")
local V = Altoholic.vars
local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"
local CLASS_MAGE = 1
local CLASS_WARRIOR	= 2
local CLASS_HUNTER	= 3
local CLASS_ROGUE = 4
local CLASS_WARLOCK	= 5
local CLASS_DRUID = 6
local CLASS_SHAMAN	= 7
local CLASS_PALADIN	= 8
local CLASS_PRIEST	= 9

function Altoholic:Equipment_Update()
	local VisibleLines = 7
	local frame = "AltoEquipment"
	local entry = frame.."Entry"
	-- ** draw class icons **
	local i = 1
	for CharacterName, c in pairs(self.db.account.data[V.CurrentFaction][V.CurrentRealm].char) do
		local itemName = entry .. "1Item" .. i;
		local itemButton = getglobal(itemName);
		itemButton:SetScript("OnEnter", Altoholic_Equipment_OnEnter)
		itemButton:SetScript("OnLeave", function(self) AltoTooltip:Hide() end)
		itemButton:SetScript("OnClick", Altoholic_Equipment_OnClick)
		local tc = self.ClassInfo[ self.Classes[c.class] ].texcoord
		local itemTexture = getglobal(itemName .. "IconTexture")		
		itemTexture:SetTexture(self.classicon);
		itemTexture:SetTexCoord(tc[1], tc[2], tc[3], tc[4]);
		itemTexture:SetWidth(36);
		itemTexture:SetHeight(36);
		itemTexture:SetAllPoints(itemButton);
		itemButton.CharName = CharacterName
		getglobal(itemName):Show()
		i = i + 1
	end
	while i <= 10 do
		getglobal(entry .. "1Item" .. i):Hide()
		getglobal(entry .. "1Item" .. i).CharName = nil
		i = i + 1
	end
	getglobal(entry .. "1"):Show()
	getglobal(entry .. "1"):SetID(0)
	-- ** draw equipment icons **
	local offset = FauxScrollFrame_GetOffset(getglobal(frame.."ScrollFrame"));
	for i=2, VisibleLines do
		local line = i + offset - 1
		getglobal(entry..i.."Name"):SetText(self.equipment[line].color .. self.equipment[line].name)
		local j = 1
		for CharacterName, c in pairs(self.db.account.data[V.CurrentFaction][V.CurrentRealm].char) do
			local itemName = entry.. i .. "Item" .. j;
			local itemButton = getglobal(itemName);
			itemButton:SetScript("OnEnter", Altoholic_Equipment_OnEnter)
			itemButton:SetScript("OnClick", Altoholic_Equipment_OnClick)
			local itemTexture = getglobal(itemName .. "IconTexture")
			local itemID = c.inventory[line]
			if itemID ~= nil then
				itemButton.CharName = CharacterName
                local _, _, _, _, _, _, _, _, itexture = GetItemInfo(itemID)
				itemTexture:SetTexture(itexture);
			else
				itemButton.CharName = nil
				itemTexture:SetTexture(self.equipment[line].icon);
			end
			itemTexture:SetWidth(36);
			itemTexture:SetHeight(36);
			itemTexture:SetAllPoints(itemButton);
			getglobal(itemName):Show()
			j = j + 1
		end
		while j <= 10 do
			getglobal(entry.. i .. "Item" .. j):Hide()
			j = j + 1
		end
		getglobal(entry..i):Show()
		getglobal(entry..i):SetID(line)
	end
	FauxScrollFrame_Update(getglobal(frame.."ScrollFrame"), 19, VisibleLines, 41);
end

function Altoholic_Equipment_OnEnter()
    if not this then return end
	local r = Altoholic.db.account.data[V.CurrentFaction][V.CurrentRealm]		-- this realm
	local itemID = this:GetParent():GetID()
	if itemID == 0 then		-- class icon
		Altoholic:DrawCharacterTooltip(this.CharName)
		return
	end
    if not this.CharName then return end
	local item = r.char[this.CharName].inventory[itemID]	--  equipment slot
	--if not item then return end
	GameTooltip:SetOwner(this, "ANCHOR_LEFT");
	if type(item) == "number" then
        local _, link = GetItemInfo(item)
		GameTooltip:SetHyperlink(link);
	else
		GameTooltip:SetHyperlink(item);
	end
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(GREEN .. L["Right-Click to find an upgrade"]);
	GameTooltip:Show();
end

function Altoholic_Equipment_OnClick()
    if not this then return end
	local r = Altoholic.db.account.data[V.CurrentFaction][V.CurrentRealm]		-- this realm
	local itemID = this:GetParent():GetID()

	if itemID == 0 then return end		-- class icon
	if not this.CharName then return end
	local item = r.char[this.CharName].inventory[itemID]	--  equipment slot
	if not item then return end
	
	local link
	if type(item) == "number" then
		_, link = GetItemInfo(item)
	else
		link = item
	end
	local button = arg1
	if button == "RightButton" then
		V.UpgradeItemID = Altoholic:GetIDFromLink(link)		-- item ID of the item to find an upgrade for
		V.CharacterClass = Altoholic.Classes[ r.char[this.CharName].class ]
		ToggleDropDownMenu(1, nil, AltoEquipmentRightClickMenu, this:GetName(), 0, -5);
		return
	end
	
	if ( button == "LeftButton" ) and ( IsControlKeyDown() ) then
		DressUpItemLink(link);
	elseif ( button == "LeftButton" ) and ( IsShiftKeyDown() ) then
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:Insert(Altoholic_GetItemLink(link));
        elseif (WIM_EditBoxInFocus) then
            WIM_EditBoxInFocus:Insert(Altoholic_GetItemLink(link));
		else
			AltoholicFrame_SearchEditBox:SetText(GetItemInfo(link))
		end
	end
end

function Equipment_RightClickMenu_OnLoad()
	local info = Altoholic_UIDropDownMenu_CreateInfo(); 

	info.text		= L["Find Upgrade"] .. " " .. GREEN .. L["(based on iLvl)"]
	info.value		= -1
	info.func		= Altoholic_FindEquipmentUpgrade;
	UIDropDownMenu_AddButton(info, 1); 

	-- Tank upgrade
	if (V.CharacterClass == CLASS_WARRIOR) or
		(V.CharacterClass == CLASS_DRUID) or
		(V.CharacterClass == CLASS_PALADIN) then
		
		info.text		= L["Find Upgrade"] .. " " .. GREEN .. "(".. L["Tank"] .. ")"
		info.value		= V.CharacterClass .. "Tank"
		info.func		= Altoholic_FindEquipmentUpgrade;
		UIDropDownMenu_AddButton(info, 1); 	
	end
	
	-- DPS upgrade
	if V.CharacterClass then
		info.text		= L["Find Upgrade"] .. " " .. GREEN .. "(".. L["DPS"] .. ")"
		info.value		= V.CharacterClass .. "DPS"
		info.func		= Altoholic_FindEquipmentUpgrade;
		UIDropDownMenu_AddButton(info, 1); 
	end
		
	if V.CharacterClass == CLASS_DRUID then
		info.text		= L["Find Upgrade"] .. " " .. GREEN .. "(".. L["Balance"] .. ")"
		info.value		= V.CharacterClass .. "Balance"
		info.func		= Altoholic_FindEquipmentUpgrade;
		UIDropDownMenu_AddButton(info, 1); 
	elseif V.CharacterClass == CLASS_SHAMAN then
		info.text		= L["Find Upgrade"] .. " " .. GREEN .. "(".. L["Elemental Shaman"] .. ")"
		info.value		= V.CharacterClass .. "Elemental"
		info.func		= Altoholic_FindEquipmentUpgrade;
		UIDropDownMenu_AddButton(info, 1); 
	end
		
	-- Heal upgrade
	if (V.CharacterClass == CLASS_PRIEST) or
		(V.CharacterClass == CLASS_SHAMAN) or
		(V.CharacterClass == CLASS_DRUID) or
		(V.CharacterClass == CLASS_PALADIN) then
		
		info.text		= L["Find Upgrade"] .. " " .. GREEN .. "(".. L["Heal"] .. ")"
		info.value		= V.CharacterClass .. "Heal"
		info.func		= Altoholic_FindEquipmentUpgrade;
		UIDropDownMenu_AddButton(info, 1); 
	end
end

function Altoholic_FindEquipmentUpgrade(self)
	local _, itemLink, _, itemMinLevel, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(V.UpgradeItemID)
    if itemMinLevel == 0 or itemMinLevel == nil then
        itemMinLevel = 57
    end
    local itemLevel = itemMinLevel + 5
	V.Search_iLvl = itemLevel
	V.SearchType = itemType
	V.SearchSubType = itemSubType
	V.SearchEquipLoc = Altoholic.InvSlots[itemEquipLoc]
    Altoholic.SearchResults = {}
	V.SearchLoots = true
	local VerifyFunc
	if this.value ~= -1 then
		V.CharacterClass = this.value
		VerifyFunc = Altoholic.VerifyUpgradeByStats
		AltoTooltip:SetOwner(this, "ANCHOR_LEFT");
		-- Get current item stats
		V.SearchItemStats = {}
		V.TooltipLines = {}
		local statLine = Altoholic.FormatStats[V.CharacterClass]
		AltoTooltip:SetHyperlink(itemLink)
		for _, BaseStat in pairs(Altoholic.BaseStats[V.CharacterClass]) do
			for i = 4, AltoTooltip:NumLines() do
				local tooltipText = getglobal("AltoTooltipTextLeft" .. i):GetText()
				if tooltipText then
					if string.find(tooltipText, BaseStat) ~= nil then
						V.SearchItemStats[BaseStat] = tonumber(string.sub(tooltipText, string.find(tooltipText, "%d+")))
						statLine = string.gsub(statLine, "-s", WHITE .. V.SearchItemStats[BaseStat], 1)
						break
					end
				end
			end
			if not V.SearchItemStats[BaseStat] then
				V.SearchItemStats[BaseStat] = 0 -- Set the current stat to zero if it was not found on the item
				statLine = string.gsub(statLine, "-s", WHITE .. "0", 1)
			end
		end
		AltoTooltip:ClearLines();
		
		-- Save currently equipped item to the results table
		table.insert(Altoholic.SearchResults, {
			id = V.UpgradeItemID,
			iLvl = itemLevel,
			char = statLine,
			location = "Currently equipped"
		} )
	else	-- simple search, point to simple VerifyUpgrade method
		VerifyFunc = Altoholic.VerifyUpgrade
	end

	V.UpgradeItemID = nil
	
	for Instance, BossList in pairs(Altoholic.LootTable) do		-- parse the loot table to find an upgrade
		for Boss, LootList in pairs(BossList) do
			for itemID, _ in pairs(LootList) do
				V.SearchInstance = Instance
				V.SearchBoss = Boss
				V.SearchLootItemID = LootList[itemID]
				VerifyFunc()
			end
		end
	end
	AltoTooltip:Hide();
	V.Search_iLvl = nil
	V.SearchType = nil
	V.SearchSubType = nil
	V.SearchEquipLoc = nil
	V.CharacterClass = nil
	V.SearchInstance = nil
	V.SearchBoss = nil
	V.SearchLootItemID = nil
    V.SearchItemStats = {}
    V.SearchItemStats = nil
    V.TooltipLines = {}
	V.TooltipLines = nil
	if AltoOptions_SortDescending:GetChecked() then
		table.sort(Altoholic.SearchResults, function(a,b)
			return a.iLvl > b.iLvl
		end)
	else
		table.sort(Altoholic.SearchResults, function(a,b)
			return a.iLvl < b.iLvl
		end)
	end
	Altoholic:ActivateMenuItem("AltoSearch")
end
