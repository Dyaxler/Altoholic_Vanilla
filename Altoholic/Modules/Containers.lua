local L = AceLibrary("AceLocale-2.2"):new("Altoholic")
local V = Altoholic.vars

function Altoholic:Containers_Update()
	local VisibleLines = 7
	local frame = "AltoContainers"
	local entry = frame.."Entry"
	if table.getn(self.BagIndices) == 0 then
		self:ClearScrollFrame(getglobal(frame.."ScrollFrame"), entry, VisibleLines, 41)
		return
	else
		getglobal("AltoholicFrame_Status"):SetText("|cFFFFD700" .. V.CurrentAlt .. " of ".. V.CurrentRealm .. " |cFFFFFFFF" .. L["Containers"])
		getglobal("AltoholicFrame_Status"):Show()
	end
	local c = self.db.account.data[V.CurrentFaction][V.CurrentRealm].char[V.CurrentAlt]
	local offset = FauxScrollFrame_GetOffset(getglobal(frame.."ScrollFrame"));
	for i=1, VisibleLines do
		local line = i + offset
		local b = c.bag["Bag" .. self.BagIndices[line].bagID]
		local itemName = entry..i .. "Item1";
		if self.BagIndices[line].from == 1 then
			local itemButton = getglobal(itemName);	
			itemButton:SetID(0)
			local itemTexture = getglobal(itemName .. "IconTexture")
			if b.icon ~= nil then
				itemTexture:SetTexture(b.icon);
			else
				itemTexture:SetTexture("Interface\\Icons\\INV_Box_03");
			end
			itemTexture:SetWidth(36);
			itemTexture:SetHeight(36);
			itemTexture:SetAllPoints(itemButton);
			getglobal(itemName):Show()
		else
			getglobal(itemName):Hide()
		end
		for j=3, 14 do
			local itemName = entry..i .. "Item" .. j;
			local itemButton = getglobal(itemName);
			local itemIndex = self.BagIndices[line].from - 3 + j
			if (itemIndex <= b.size) then 
				itemButton:SetID(itemIndex)
				local itemTexture = getglobal(itemName .. "IconTexture")
				if b.ids[itemIndex] ~= nil then
                    local _, _, _, _, _, _, _, _, itemTextureIcon = GetItemInfo(b.ids[itemIndex]); 
					itemTexture:SetTexture(itemTextureIcon);
				else
					itemTexture:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot");
				end
				itemTexture:SetWidth(36);
				itemTexture:SetHeight(36);
				itemTexture:SetAllPoints(itemButton);
				local itemCount = getglobal(itemName .. "Count")
				if (b.counts[itemIndex] == nil) or (b.counts[itemIndex] < 2)then
					itemCount:Hide();
				else
					itemCount:SetText(b.counts[itemIndex]);
					itemCount:Show();
				end
			
				getglobal(itemName):Show()
			else
				getglobal(itemName):Hide()
			end
		end
		getglobal(entry..i):Show()
		getglobal(entry..i):SetID(self.BagIndices[line].bagID)
	end
	if table.getn(self.BagIndices) < VisibleLines then
		FauxScrollFrame_Update(getglobal(frame.."ScrollFrame"), VisibleLines, VisibleLines, 41);
	else
		FauxScrollFrame_Update(getglobal(frame.."ScrollFrame"), table.getn(self.BagIndices), VisibleLines, 41);
	end	
end	

function Altoholic:Item_OnEnter(this, bagID, itemID)
	local id, link
    local r = self.db.account.data[V.CurrentFaction][V.CurrentRealm]
    if itemID == 0	then
        GameTooltip:SetOwner(this, "ANCHOR_LEFT");
        if bagID == -2 then
            GameTooltip:AddLine(KEYRING,1,1,1);
            GameTooltip:AddLine(L["32 Keys Max"],1,1,1);
        elseif bagID == 0 then
            GameTooltip:AddLine(BACKPACK_TOOLTIP,1,1,1);
            GameTooltip:AddLine(format(CONTAINER_SLOTS, 16, BAGSLOT),1,1,1);
            
        elseif bagID == 100 then
            GameTooltip:AddLine(L["Bank"],0.5,0.5,1);
            GameTooltip:AddLine(L["28 Slot"],1,1,1);
        else
            local _, _, BagHyperlink = string.find(r.char[V.CurrentAlt].bag["Bag" .. bagID].link, ".*|H(.*)|h.*")
            GameTooltip:SetHyperlink(BagHyperlink);
            if (bagID >= 5) and (bagID <= 11) then
                GameTooltip:AddLine(L["Bank bag"],0,1,0);
            end
        end
        --Altoholic:WhoKnowsRecipe(this, "Game")
        Altoholic:ProcessTooltip(GameTooltip, "Game")
        GameTooltip:Show();
        return
    else
        id = r.char[V.CurrentAlt].bag["Bag" .. bagID].ids[itemID]
        link = r.char[V.CurrentAlt].bag["Bag" .. bagID].links[itemID]
    end
	if id ~= nil then
		GameTooltip:SetOwner(this, "ANCHOR_LEFT");
		if not link then
            local _, itemLink = GetItemInfo(id)
			link = itemLink
		end
		if not link then
			GameTooltip:AddLine(L["Unknown link, please relog this character"],1,1,1);
		else
			GameTooltip:SetHyperlink(link);
		end
        --Altoholic:WhoKnowsRecipe(this, "Game")
        Altoholic:ProcessTooltip(GameTooltip, "Game", link)
		GameTooltip:Show();
	end
end

function Altoholic:Item_OnClick(button, itemID)
    local item, link
    local bagID = this:GetParent():GetID()
    local r = self.db.account.data[V.CurrentFaction][V.CurrentRealm]
    item = r.char[V.CurrentAlt].bag["Bag" .. bagID].ids[itemID]
    if not item then return end
	if type(item) == "number" then
		_, link = GetItemInfo(item)
	else
		link = item
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
