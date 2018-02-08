local L = AceLibrary("AceLocale-2.2"):new("Altoholic")
local V = Altoholic.vars
local LEVEL_CAP = 60
local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"
local RED		= "|cFFFF0000"
local TEAL		= "|cFF00FF9A"
local YELLOW	= "|cFFFFFF00"

function Altoholic:Search_Update()
	local VisibleLines = 7
	local frame = "AltoSearch"
	local entry = frame.."Entry"
	if table.getn(self.SearchResults) == 0 then
		self:ClearScrollFrame(getglobal(frame.."ScrollFrame"), entry, VisibleLines, 41)
		return
	end
	local offset = FauxScrollFrame_GetOffset(getglobal(frame.."ScrollFrame"));
	for i=1, VisibleLines do
		local line = i + offset
		local s = self.SearchResults[line]
		if s ~= nil then
			local itemID = s.id
			local itemName, itemRarity, itemIcon, hex
			if not itemID then
				hex = WHITE
				getglobal(entry..i.."ItemIconTexture"):SetTexture("Interface\\Icons\\Trade_Engraving");
			else
				itemName, _, itemRarity, _, _, _, _, _, itemIcon = GetItemInfo(itemID)
				_, _, _, hex = GetItemQualityColor(itemRarity)
    			getglobal(entry..i.."ItemIconTexture"):SetTexture(itemIcon);
			end
			if V.SearchLoots ~= nil then
				getglobal(entry..i.."Realm"):SetText(WHITE .. L["Item Level"] .. ": " .. YELLOW .. s.iLvl)
			else
				getglobal(entry..i.."Realm"):SetText(s.realm)
			end
			if s.craftName then
				getglobal(entry..i.."Name"):SetText(hex .. s.craftName)
				getglobal(entry..i.."SourceNormalText"):SetText(s.craftLink)
				getglobal(entry..i.."Source"):SetID(line)
			else 
				getglobal(entry..i.."Name"):SetText(hex .. itemName)
				getglobal(entry..i.."Source"):SetText(TEAL .. s.location)
				getglobal(entry..i.."Source"):SetID(0)
			end
			getglobal(entry..i.."Character"):SetText(s.char)
			if (s.count ~= nil) and (s.count > 1) then
				getglobal(entry..i.."ItemCount"):SetText(s.count)
				getglobal(entry..i.."ItemCount"):Show()
			else
				getglobal(entry..i.."ItemCount"):Hide()
			end
			getglobal(entry..i.."Item"):SetID(line)
			getglobal(entry..i):Show()
		else
			getglobal(entry..i):Hide()
		end
	end
	if (offset+VisibleLines) <= table.getn(self.SearchResults) then
		getglobal("AltoholicFrame_Status"):SetText(table.getn(self.SearchResults) .. L[" results found (Showing "] .. (offset+1) .. "-" .. (offset+VisibleLines) .. ")")
	else
		getglobal("AltoholicFrame_Status"):SetText(table.getn(self.SearchResults) .. L[" results found (Showing "] .. (offset+1) .. "-" .. table.getn(self.SearchResults) .. ")")
	end
	getglobal("AltoholicFrame_Status"):Show()
	if table.getn(self.SearchResults) < VisibleLines then
		FauxScrollFrame_Update(getglobal(frame.."ScrollFrame"), VisibleLines, VisibleLines, 41);
	else
		FauxScrollFrame_Update(getglobal(frame.."ScrollFrame"), table.getn(self.SearchResults), VisibleLines, 41);
	end
end

-- *** Search Functions ***
function Altoholic:SearchReset()
	AltoholicFrame_SearchEditBox:SetText("")
	AltoholicFrame_MinLevel:SetText("")
	AltoholicFrame_MaxLevel:SetText("")
	for i=1, 7 do
		getglobal("AltoSearchEntry" .. i):Hide()
	end
	getglobal("AltoholicFrame_Status"):Hide()
    self.SearchResults = {}
end

function Altoholic:SearchItem(searchType, searchSubType)
	if (V.ongoingsearch ~= nil) then
		return
	end
	V.ongoingsearch = 1
	V.SearchLoots = nil
	V.SearchType = searchType
	V.SearchSubType = searchSubType
	local value = AltoholicFrame_SearchEditBox:GetText()
	V.SearchValue = strlower(value)
	V.MinLevel = AltoholicFrame_MinLevel:GetNumber()
	V.MaxLevel = AltoholicFrame_MaxLevel:GetNumber()
	if V.MaxLevel == 0 then
		V.MaxLevel = LEVEL_CAP
	end
    self.SearchResults = {}
	if AltoholicFrame_RadioButton1:GetChecked() then
		V.SearchFaction = V.faction
		V.SearchRealm = V.realm
		self:SearchRealm()
	elseif AltoholicFrame_RadioButton2:GetChecked() then
		for FactionName, f in pairs(self.db.account.data) do
			for RealmName, _ in pairs(f) do
				V.SearchFaction = FactionName
				V.SearchRealm = RealmName
				self:SearchRealm()
			end
		end
	else
		V.TotalLoots = 0
		V.TotalUnknown = 0
		V.MaxAutoQuery = 5
		V.AutoQueriesDone = 0
		V.SearchLoots = true
		for Instance, BossList in pairs(Altoholic.LootTable) do
			for Boss, LootList in pairs(BossList) do
				for itemID, _ in pairs(LootList) do
					self:VerifyLoot(Instance, Boss, LootList[itemID])
				end
			end
		end
		local O = self.db.account.options
		O.TotalLoots = V.TotalLoots
		O.UnknownLoots = V.TotalUnknown
		getglobal("AltoOptionsLootInfo"):SetText(GREEN .. O.TotalLoots .. "|r " .. L["Loots"] .. " / " .. GREEN .. O.UnknownLoots .. "|r " .. L["Unknown"])								
		V.TotalLoots = nil
		V.TotalUnknown = nil
		V.MaxAutoQuery = nil
	end
	if table.getn(self.SearchResults) == 0 then
		if V.SearchValue == "" then 
			getglobal("AltoholicFrame_Status"):SetText(L["No match found!"])
		else
			getglobal("AltoholicFrame_Status"):SetText(value .. L[" not found!"])
		end
		getglobal("AltoholicFrame_Status"):Show()
	end
	V.ongoingsearch = nil
	V.SearchValue = nil
	V.SearchFaction = nil
	V.SearchRealm = nil
	V.SearchType = nil
	V.SearchSubType = nil
	if V.SearchLoots then
		if AltoOptions_SortDescending:GetChecked() then
			table.sort(self.SearchResults, function(a,b)
				return a.iLvl > b.iLvl
			end)
		else
			table.sort(self.SearchResults, function(a,b)
				return a.iLvl < b.iLvl
			end)
		end
	end
	self:ActivateMenuItem("AltoSearch")
end

function Altoholic:SearchRealm()
	for CharacterName, c in pairs(self.db.account.data[V.SearchFaction][V.SearchRealm].char) do
		V.SearchCharacter = self:GetClassColor(c.class) .. CharacterName
		for BagName, b in pairs(c.bag) do
			if (BagName == "Bag100") then
				V.SearchLocation = L["Bank"]
			elseif (BagName == "Bag-2") then
				V.SearchLocation = KEYRING
			else
				local bagNum = tonumber(string.sub(BagName, 4))
				if (bagNum >= 0) and (bagNum <= 4) then
					V.SearchLocation = L["Bags"]
				else
					V.SearchLocation = L["Bank"]
				end			
			end
			for slotID=1, b.size do
				if b.ids[slotID] ~= nil then
					self:VerifyItem(b.ids[slotID], b.counts[slotID])
				end
			end
		end
		V.SearchLocation = L["Equipped"]
		for slotID=1, 19 do
			if c.inventory[slotID] ~= nil then
				self:VerifyItem(c.inventory[slotID], 1)
			end
		end
		if AltoholicFrame_CheckButton1:GetChecked() then
			V.SearchLocation = L["Mail"]
			for slotID=1, table.getn(c.mail) do
				local s = c.mail[slotID]
				if s.link ~= nil then
					self:VerifyItem(self:GetIDFromLink(s.link), s.count)
				end
			end
		end
		if AltoholicFrame_CheckButton3:GetChecked() and (V.SearchType == nil) then
			for ProfessionName, p in pairs(c.recipes) do
				if p.ScanFailed == false then
					for CraftNumber, craft in pairs(p.list) do
						self:VerifyRecipe(craft.link, ProfessionName, craft.id, CraftNumber, CharacterName)
					end
				end
			end
		end
	end
	V.SearchLocation = nil
	V.SearchCharacter = nil
end

function Altoholic:VerifyRecipe(link, profession, itemID, CraftNumber, charName)
	if not link then return end
	local itemName = self:GetCraftFromRecipe(link)
	if not itemName then return end
	if string.find(strlower(itemName), V.SearchValue, 1, true) == nil then
		return 
	end
	table.insert(self.SearchResults, {
		id = itemID,
		char = V.SearchCharacter,
		craftName = itemName,
		craftLink = link,
		realm = self:GetRealmString(V.SearchFaction, V.SearchRealm),
		searchRealm = V.SearchRealm,
		searchFaction = V.SearchFaction,
		location = profession,
		craftNum = CraftNumber,
		altName = charName
	} )
end

function Altoholic:VerifyItem(itemID, itemCount)
	local itemName, _, itemRarity, itemMinLevel, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(itemID)
	if (itemName == nil) and (itemRarity == nil) then
		return
	end
	if (V.SearchType ~= nil) and (V.SearchType ~= itemType) then
		return
	end
	if (V.SearchSubType ~= nil) and (V.SearchSubType ~= itemSubType) then
		return
	end	
	if (itemRarity < V.SearchRarity) then
		return
	end
	if (itemMinLevel == 0) then
		if (AltoholicFrame_IncludeNoMinLevel:GetChecked() == nil) then
			return
		end
	else
		if (itemMinLevel < V.MinLevel) or (itemMinLevel > V.MaxLevel) then
			return
		end
	end
	if V.SearchSlot ~= 0 then
		if self.InvSlots[itemEquipLoc] ~= V.SearchSlot then
			return
		end
	end
	if string.find(strlower(itemName), V.SearchValue, 1, true) == nil then
		return
	end
	table.insert(self.SearchResults, {
		id = itemID,
		char = V.SearchCharacter,
		count = itemCount,
		realm = self:GetRealmString(V.SearchFaction, V.SearchRealm),
		location = V.SearchLocation
	} )
end

function Altoholic:VerifyLoot(Instance, Boss, itemID)
	V.TotalLoots = V.TotalLoots + 1
	local itemName, itemLink, itemRarity, itemMinLevel, itemType, itemSubType, _, itemEquipLoc, itemIcon = GetItemInfo(itemID)
    if itemMinLevel == 0 or itemMinLevel == nil then
        itemMinLevel = 57
    end    
    local itemLevel = itemMinLevel + 5
	if (itemName == nil) and (itemRarity == nil) then
		V.TotalUnknown = V.TotalUnknown + 1
		if V.AutoQueriesDone < V.MaxAutoQuery then
			if AltoOptions_SearchAutoQuery:GetChecked() then
				if self:IsUnsafeItemKnown(itemID) then
					return
				end
				GameTooltip:SetHyperlink("item:"..itemID..":0:0:0:0:0:0:0")
				GameTooltip:ClearLines();
				self:SaveUnsafeItem(itemID)
			end
			V.AutoQueriesDone = V.AutoQueriesDone + 1
		end
		return
	end
	if (V.SearchType ~= nil) and (V.SearchType ~= itemType) then
		return		-- if there's a type and it's invalid .. Exit
	end
	if (V.SearchSubType ~= nil) and (V.SearchSubType ~= itemSubType) then
		return		-- if there's a subtype and it's invalid .. Exit
	end	
	if (itemRarity < V.SearchRarity) then
		return		-- if rarity is too low .. exit
	end
	if (itemMinLevel == 0) then
		if (AltoholicFrame_IncludeNoMinLevel:GetChecked() == nil) then
			return		-- no minimum requireement & should not be included ? .. exit
		end
	else
		if (itemMinLevel < V.MinLevel) or (itemMinLevel > V.MaxLevel) then
			return		-- not within the right level boundaries ? .. exit
		end
	end
	if V.SearchSlot ~= 0 then	-- if a specific equipment slot is specified ..
		if self.InvSlots[itemEquipLoc] ~= V.SearchSlot then
			return		-- not the right slot ? .. exit
		end
	end
	if string.find(strlower(itemName), V.SearchValue, 1, true) == nil then
		return		-- item name does not match search value ? .. exit
	end
	table.insert(self.SearchResults, {
		id = itemID,
		iLvl = itemLevel,
		char = GREEN .. Boss,
		location = WHITE .. Instance
	} )
end

function Altoholic:SaveUnsafeItem(itemID)
	if self:IsUnsafeItemKnown(itemID) then			-- if the unsafe item has already been saved .. exit
		return
	end
	table.insert(self.db.account.data[V.faction][V.realm].unsafeItems, itemID)
end

function Altoholic:IsUnsafeItemKnown(itemID)
	for k, v in pairs(self.db.account.data[V.faction][V.realm].unsafeItems) do 	-- browse current realm's unsafe item list
		if v == itemID then		-- if the itemID passed as parameter is a known unsafe item .. return true to skip it
			return true
		end
	end
	return false			-- false if unknown
end

function Altoholic:BuildUnsafeItemList()
	V.TmpUnsafe = {}		-- create a temporary table with confirmed unsafe id's
	for k, v in pairs(self.db.account.data[V.faction][V.realm].unsafeItems) do
		local itemName = GetItemInfo(v)
		if not itemName then							-- if the item is really unsafe .. save it
			table.insert(V.TmpUnsafe, v)
		end
	end
    self.db.account.data[V.faction][V.realm].unsafeItems = {}
	for k, v in pairs(V.TmpUnsafe) do
		table.insert(self.db.account.data[V.faction][V.realm].unsafeItems, v)	-- save the confirmed unsafe ids back in the db
	end
    V.TmpUnsafe = {}
	V.TmpUnsafe = nil
end

function Altoholic:VerifyUpgrade()
	local itemName, _, itemRarity, itemMinLevel, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(V.SearchLootItemID)
    if itemMinLevel == 0 or itemMinLevel == nil then
        itemMinLevel = 57
    end
    local itemLevel = itemMinLevel + 5
	if (itemName == nil) and (itemRarity == nil) then
		return			-- with these 2 being nil, the item isn't in the item cache, so its link would be invalid: don't list it
	end
	if (itemLevel <= V.Search_iLvl) or (V.SearchType ~= itemType) or 
		(V.SearchSubType ~= itemSubType) then
		return		-- not within the right level boundaries ? invalid type or subtype ? .. exit
	end
	if Altoholic.InvSlots[itemEquipLoc] ~= V.SearchEquipLoc then
		return		-- not the right slot ? .. exit
	end
	table.insert(Altoholic.SearchResults, {
		id = V.SearchLootItemID,
		iLvl = itemLevel,
		char = GREEN .. V.SearchBoss,
		location = WHITE .. V.SearchInstance
	} )
end

function Altoholic:VerifyUpgradeByStats()
	local itemName, itemLink, itemRarity, itemMinLevel, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(V.SearchLootItemID)
    if itemMinLevel == 0 or itemMinLevel == nil then
        itemMinLevel = 57
    end
    local itemLevel = itemMinLevel + 5
	if (itemName == nil) and (itemRarity == nil) then
		return			-- with these 2 being nil, the item isn't in the item cache, so its link would be invalid: don't list it
	end
	if (itemLevel <= V.Search_iLvl) or (V.SearchType ~= itemType) or 
		(V.SearchSubType ~= itemSubType) then
		return		-- not within the right level boundaries ? invalid type or subtype ? .. exit
	end
	if Altoholic.InvSlots[itemEquipLoc] ~= V.SearchEquipLoc then
		return		-- not the right slot ? .. exit
	end
	AltoTooltip:ClearLines();	
	AltoTooltip:SetOwner(this, "ANCHOR_LEFT");
	AltoTooltip:SetHyperlink(itemLink)	-- Set the link to be able to parse item stats (set owner is done earlier, before the loop)
    V.TooltipLines = {}
	for i = 4, AltoTooltip:NumLines() do	-- parse all tooltip lines, one by one, start at 5 since 1= item name, 2 = binds on.., 3 = type/slot/unique, 4 = Armor value ..etc
		local tooltipLine = getglobal("AltoTooltipTextLeft" .. i):GetText()
		if tooltipLine then
			if string.find(tooltipLine, L["Socket"]) == nil then
				for _, v in pairs(Altoholic.ExcludeStats[V.CharacterClass]) do
					--if string.find(tooltipLine, v, 1, true) ~= nil then return end
					if string.find(tooltipLine, v) ~= nil then return end
				end
				V.TooltipLines[i] = tooltipLine
			end
		end
	end
	local statLine = Altoholic.FormatStats[V.CharacterClass]
	local statFound
	for _, BaseStat in pairs(Altoholic.BaseStats[V.CharacterClass]) do
		statFound = nil
        local stat
		for i, tooltipText in pairs(V.TooltipLines) do
			if string.find(tooltipText, BaseStat) ~= nil then
                if string.find(tooltipText, ".+(Set:).+") then
                    stat = nil
                else
                    stat = tonumber(string.sub(tooltipText, string.find(tooltipText, "%d+")))
                end
                if stat then
                    if stat > V.SearchItemStats[BaseStat] then
                        statLine = string.gsub(statLine, "-s", GREEN .. stat, 1)
                    elseif stat < V.SearchItemStats[BaseStat] then
                        statLine = string.gsub(statLine, "-s", RED .. stat, 1)
                    else
                        statLine = string.gsub(statLine, "-s", WHITE .. stat, 1)
                    end
                    table.remove(V.TooltipLines, i)	-- remove the current entry, so it won't be parsed in the next loop cycle
                    statFound = true
                    break
                end
			end
		end
		if not statFound then
			if V.SearchItemStats[BaseStat] > 0 then		-- if the stat exists in the original item ..
				statLine = string.gsub(statLine, "-s", RED .. "0", 1)	-- .. then 0 should be in red (since its absence means its a lower value)
			else
				statLine = string.gsub(statLine, "-s", WHITE .. "0", 1)	-- .. whereas if it didn't, the value is equal (0 spirit on the original item vs 0 spirit on the current one)
			end
		end
	end
	table.insert(Altoholic.SearchResults, {
		id = V.SearchLootItemID,
		iLvl = itemLevel,
		char = statLine,
		location = WHITE .. V.SearchInstance .. ", " .. GREEN .. V.SearchBoss
	} )
end

function Altoholic:Search_OnClick(button, id)
    local s = Altoholic.SearchResults[this:GetID()]
    if s.id ~= nil then
        local _, link = GetItemInfo(s.id)
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
end
