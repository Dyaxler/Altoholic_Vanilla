local BZ = LibStub("LibBabble-Zone-3.0"):GetLookupTable()
local L = AceLibrary("AceLocale-2.2"):new("Altoholic")
local V = Altoholic.vars
local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"
local ORANGE	= "|cFFFF7F00"
local RED		= "|cFFFF0000"
local TEAL		= "|cFF00FF9A"

function Altoholic:Auctions_Update_Auctions()
	local c = self.db.account.data[V.CurrentFaction][V.CurrentRealm].char[V.CurrentAlt]		-- current alt
	local VisibleLines = 7
	local frame = "AltoAuctions"
	local entry = frame.."Entry"
	
	if table.getn(c.auctions) == 0 then
		getglobal("AltoholicFrame_Status"):SetText("|cFFFFD700" .. V.CurrentAlt .. " of ".. V.CurrentRealm .. " |cFFFFFFFF" .. L[" has no auctions"])
		getglobal("AltoholicFrame_Status"):Show()
		
		self:ClearScrollFrame(getglobal(frame.."ScrollFrame"), entry, VisibleLines, 41)
		return
	else
   		getglobal("AltoholicFrame_Status"):SetText("|cFFFFD700" .. V.CurrentAlt .. " of ".. V.CurrentRealm .. " |cFFFFFFFF: " .. L["last check "] .. self:GetDelayInDays(c.lastAHcheck).. L[" days ago"])
		getglobal("AltoholicFrame_Status"):Show()
	end

	local offset = FauxScrollFrame_GetOffset(getglobal(frame.."ScrollFrame"));
	
	for i=1, VisibleLines do
		local line = i + offset
		if line <= table.getn(c.auctions) then
			local s = c.auctions[line]
			
			local itemName, _, itemRarity = GetItemInfo(s.id)
            local _, _, _, itemQualityColor = GetItemQualityColor(itemRarity)
			getglobal(entry..i.."Name"):SetText(itemQualityColor .. itemName)
			
			getglobal(entry..i.."TimeLeft"):SetText( TEAL .. getglobal("AUCTION_TIME_LEFT"..s.timeLeft) 
								.. " (" .. getglobal("AUCTION_TIME_LEFT"..s.timeLeft .. "_DETAIL") .. ")")

			local bidder
			if s.AHLocation then
				bidder = L["Goblin AH"] .. "\n"
			else
				bidder = ""
			end
			
			if s.highBidder then
				bidder = bidder .. WHITE .. s.highBidder
			else
				bidder = bidder .. RED .. NO_BIDS
			end
			getglobal(entry..i.."HighBidder"):SetText(bidder)
			
			getglobal(entry..i.."Price"):SetText(self:GetMoneyString(s.startPrice) .. "\n"  
					.. GREEN .. BUYOUT .. ": " ..  self:GetMoneyString(s.buyoutPrice))
            local _, _, _, _, _, _, _, _, itexture  = GetItemInfo(s.id)
			getglobal(entry..i.."ItemIconTexture"):SetTexture(itexture);
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
	
	if table.getn(c.auctions) < VisibleLines then
		FauxScrollFrame_Update(getglobal(frame.."ScrollFrame"), VisibleLines, VisibleLines, 41);
	else
		FauxScrollFrame_Update(getglobal(frame.."ScrollFrame"), table.getn(c.auctions), VisibleLines, 41);
	end
end

function Altoholic:Auctions_Update_Bids()
	local c = self.db.account.data[V.CurrentFaction][V.CurrentRealm].char[V.CurrentAlt]		-- current alt
	local VisibleLines = 7
	local frame = "AltoAuctions"
	local entry = frame.."Entry"
	
	if table.getn(c.bids) == 0 then
		getglobal("AltoholicFrame_Status"):SetText("|cFFFFD700" .. V.CurrentAlt .. " of ".. V.CurrentRealm .. " |cFFFFFFFF" .. L[" has no bids"])
		getglobal("AltoholicFrame_Status"):Show()
		
		self:ClearScrollFrame(getglobal(frame.."ScrollFrame"), entry, VisibleLines, 41)
		return
	else
		getglobal("AltoholicFrame_Status"):SetText("|cFFFFD700" .. V.CurrentAlt .. " of ".. V.CurrentRealm .. " |cFFFFFFFF" .. BIDS .. ": " .. L["last check "] .. self:GetDelayInDays(c.lastAHcheck).. L[" days ago"])
		getglobal("AltoholicFrame_Status"):Show()
	end

	local offset = FauxScrollFrame_GetOffset(getglobal(frame.."ScrollFrame"));
	
	for i=1, VisibleLines do
		local line = i + offset
		if line <= table.getn(c.bids) then
			local s = c.bids[line]
			
			local itemName, _, itemRarity = GetItemInfo(s.id)
            local _, _, _, itemQualityColor = GetItemQualityColor(itemRarity)
			getglobal(entry..i.."Name"):SetText(itemQualityColor .. itemName)
			
			getglobal(entry..i.."TimeLeft"):SetText( TEAL .. getglobal("AUCTION_TIME_LEFT"..s.timeLeft) 
								.. " (" .. getglobal("AUCTION_TIME_LEFT"..s.timeLeft .. "_DETAIL") .. ")")
			
			if s.AHLocation then
				getglobal(entry..i.."HighBidder"):SetText(L["Goblin AH"] .. "\n" .. WHITE .. s.owner)
			else
				getglobal(entry..i.."HighBidder"):SetText(WHITE .. s.owner)
			end
			
			getglobal(entry..i.."Price"):SetText(ORANGE .. CURRENT_BID .. ": " .. self:GetMoneyString(s.bidPrice) .. "\n"  
					.. GREEN .. BUYOUT .. ": " ..  self:GetMoneyString(s.buyoutPrice))
            local _, _, _, _, _, _, _, _, itexture  = GetItemInfo(s.id)
			getglobal(entry..i.."ItemIconTexture"):SetTexture(itexture);
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
	
	if table.getn(c.bids) < VisibleLines then
		FauxScrollFrame_Update(getglobal(frame.."ScrollFrame"), VisibleLines, VisibleLines, 41);
	else
		FauxScrollFrame_Update(getglobal(frame.."ScrollFrame"), table.getn(c.bids), VisibleLines, 41);
	end
end

function Altoholic:UpdatePlayerBids()
	local c = self.db.account.data[V.faction][V.realm].char[UnitName("player")]
	local numItems = GetNumAuctionItems("bidder")

	local AHZone
	local zone = GetRealZoneText()
	if (zone == BZ["Stranglethorn Vale"]) or		-- if it's a goblin AH .. save the value 1
		(zone == BZ["Tanaris"]) or
		(zone == BZ["Winterspring"]) then
		AHZone = 1
	end

	self:ClearAHEntries("bids", AHZone, UnitName("player"))
	
	c.lastAHcheck = time()
	if numItems == 0 then return end
	
	for i = 1, numItems do
		local itemName, _, itemCount, _, _, _,	_, 
			_, buyout, bidAmount, _, ownerName = GetAuctionItemInfo("bidder", i);
			
		if itemName then
			table.insert(c.bids, {
				id = self:GetIDFromLink(GetAuctionItemLink("bidder", i)),
				count = itemCount,
				AHLocation = AHZone,
				bidPrice = bidAmount,
				buyoutPrice = buyout,
				owner = ownerName,
				timeLeft = GetAuctionItemTimeLeft("bidder", i)
			} )
		end
	end
	
end

function Altoholic:UpdatePlayerAuctions()
	local c = self.db.account.data[V.faction][V.realm].char[UnitName("player")]
	local numItems = GetNumAuctionItems("owner")

	local AHZone
	local zone = GetRealZoneText()
	if (zone == BZ["Stranglethorn Vale"]) or		-- if it's a goblin AH .. save the value 1
		(zone == BZ["Tanaris"]) or
		(zone == BZ["Winterspring"]) then
		AHZone = 1
	end	

	self:ClearAHEntries("auctions", AHZone, UnitName("player"))
	
	c.lastAHcheck = time()
	if numItems == 0 then return end
	
	for i = 1, numItems do
		local itemName, _, itemCount, _, _, _,	minBid, 
			_, buyout, _,	highBidderName = GetAuctionItemInfo("owner", i);

		if itemName then
			table.insert(c.auctions, {
				id = self:GetIDFromLink(GetAuctionItemLink("owner", i)),
				count = itemCount,
				AHLocation = AHZone,
				highBidder = highBidderName,
				startPrice = minBid,
				buyoutPrice = buyout,
				timeLeft = GetAuctionItemTimeLeft("owner", i)
			} )
		end
	end
	
end

function Altoholic:ClearAHEntries(AHType, AHZone, character)
	local c = self.db.account.data[V.faction][V.realm].char[character]
	
	for i = table.getn(c[AHType]), 1, -1 do			-- parse backwards to avoid messing up the index
		if c[AHType][i].AHLocation == AHZone then
			table.remove(c[AHType], i)
		end
	end
end


function AltoAuctions_RightClickMenu_OnLoad()
	local info = Altoholic_UIDropDownMenu_CreateInfo(); 

	info.text		= WHITE .. L["Clear your faction's entries"]
	info.value		= 1
	info.func		= Altoholic_ClearPlayerAHEntries;
	UIDropDownMenu_AddButton(info, 1); 

	info.text		= WHITE .. L["Clear goblin AH entries"]
	info.value		= 2
	info.func		= Altoholic_ClearPlayerAHEntries;
	UIDropDownMenu_AddButton(info, 1); 
	
	info.text		= WHITE .. L["Clear all entries"]
	info.value		= 3
	info.func		= Altoholic_ClearPlayerAHEntries;
	UIDropDownMenu_AddButton(info, 1); 
end

function Altoholic_ClearPlayerAHEntries()
	local c = Altoholic.db.account.data[V.CurrentFaction][V.CurrentRealm].char[V.CurrentAlt]		-- current alt
	
	if (this.value == 1) or (this.value == 3) then	-- clean this faction's data
		for i = table.getn(c[V.AuctionType]), 1, -1 do
			if c[V.AuctionType][i].AHLocation == nil then
				table.remove(c[V.AuctionType], i)
			end
		end
	end
	
	if (this.value == 2) or (this.value == 3) then	-- clean goblin AH
		for i = (c[V.AuctionType]), 1, -1 do
			if c[V.AuctionType][i].AHLocation == 1 then
				table.remove(c[V.AuctionType], i)
			end
		end
	end
	
	Altoholic:BuildAuctionsSubMenu()
	Altoholic:BuildBidsSubMenu()
	Altoholic:Menu_Update()
	Altoholic:Auctions_Update();
end

-- *** EVENT HANDLERS ***
function Altoholic:AUCTION_HOUSE_SHOW()
	V.isAHOpen = true
	self:RegisterEvent("AUCTION_BIDDER_LIST_UPDATE")
	self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
end

function Altoholic:AUCTION_BIDDER_LIST_UPDATE()
	self:UpdatePlayerBids()
end

function Altoholic:AUCTION_OWNED_LIST_UPDATE()
	self:UpdatePlayerAuctions()
end

function Altoholic:AUCTION_HOUSE_CLOSED()
	V.isAHOpen = nil
	
	if self:IsEventRegistered("AUCTION_OWNED_LIST_UPDATE") then
		self:UnregisterEvent("AUCTION_OWNED_LIST_UPDATE")
		self:BuildAuctionsSubMenu()
	end
	
	if self:IsEventRegistered("AUCTION_BIDDER_LIST_UPDATE") then
		self:UnregisterEvent("AUCTION_BIDDER_LIST_UPDATE")
		self:BuildBidsSubMenu()
	end
end
