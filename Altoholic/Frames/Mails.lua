local L = AceLibrary("AceLocale-2.2"):new("Altoholic")
local V = Altoholic.vars
local GREEN		= "|cFF00FF00"

function Altoholic:Mail_Update()
	local c = self.db.account.data[V.CurrentFaction][V.CurrentRealm].char[V.CurrentAlt]
	local VisibleLines = 7
	local frame = "Mail"
	local entry = frame.."Entry"
	if table.getn(c.mail) == 0 then
		if c.lastmailcheck == 0 then
			getglobal("AltoholicFrame_Status"):SetText("|cFFFFD700" .. V.CurrentAlt .. " of ".. V.CurrentRealm .. " |cFFFFFFFF" .. L[" has not visited his/her mailbox yet"])
		else
			getglobal("AltoholicFrame_Status"):SetText("|cFFFFD700" .. V.CurrentAlt .. " of ".. V.CurrentRealm .. " |cFFFFFFFF" .. L[" has no mail, last check "] .. self:GetDelayInDays(c.lastmailcheck).. L[" days ago"])
		end
		getglobal("AltoholicFrame_Status"):Show()
		
		self:ClearScrollFrame(getglobal(frame.."ScrollFrame"), entry, VisibleLines, 41)
		return
	else
		getglobal("AltoholicFrame_Status"):SetText("|cFFFFD700" .. V.CurrentAlt .. " of ".. V.CurrentRealm .. " |cFFFFFFFF" .. L["Mailbox"])
		getglobal("AltoholicFrame_Status"):Show()
	end
	local offset = FauxScrollFrame_GetOffset(getglobal(frame.."ScrollFrame"));
	for i=1, VisibleLines do
		local line = i + offset
		if line <= table.getn(c.mail) then
			local s = c.mail[line]
			if s.link then
				getglobal(entry..i.."Name"):SetText(s.link)
			else
				getglobal(entry..i.."Name"):SetText(s.subject)
			end
			getglobal(entry..i.."Character"):SetText(s.sender)
			getglobal(entry..i.."Expiry"):SetText(self:FormatMailExpiry(s.lastcheck, s.daysleft) .. L[" days"])
			getglobal(entry..i.."ItemIconTexture"):SetTexture(s.icon);
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
	getglobal("AltoholicFrame_Status"):SetText(L["Mail was last checked "] .. self:GetDelayInDays(c.lastmailcheck).. L[" days ago"])
	getglobal("AltoholicFrame_Status"):Show()
	if table.getn(c.mail) < VisibleLines then
		FauxScrollFrame_Update(getglobal(frame.."ScrollFrame"), VisibleLines, VisibleLines, 41);
	else
		FauxScrollFrame_Update(getglobal(frame.."ScrollFrame"), table.getn(c.mail), VisibleLines, 41);
	end
end

function Altoholic:FormatMailExpiry(lastcheck, mailexpiry)
	if (lastcheck == nil) or (lastcheck == 0) then
		return GREEN .. string.format("%.2f", mailexpiry)
	end
	local expiry = self:GetMailExpiry(lastcheck, mailexpiry)
	if expiry > 10 then
		return GREEN .. string.format("%.2f", expiry)
	elseif expiry > 5 then
		return "|cFFFFFF00" .. string.format("%.2f", expiry)
	end
	return "|cFFFF0000" .. string.format("%.2f", expiry)
end

function Altoholic:GetMailExpiry(lastcheck, mailexpiry)
	return mailexpiry - ((time() - lastcheck) / 86400)
end

function Altoholic:CheckExpiredMail()
	local O = self.db.account.options
	for FactionName, f in pairs(self.db.account.data) do
		for RealmName, r in pairs(f) do
			for CharacterName, c in pairs(r.char) do
				for k, v in pairs(c.mail) do
					if self:GetMailExpiry(v.lastcheck, v.daysleft) < O.MailWarningThreshold then
						V.ExpiredMail = true
						return
					end
				end
			end
		end
	end
end

function Altoholic:UpdatePlayerMail()
	local c = self.db.account.data[V.faction][V.realm].char[V.player]
	local numItems = GetInboxNumItems();
    c.mail = {}
	if numItems == 0 then
		return
	end
	for i = 1, numItems do
        local packageIcon , stationeryIcon, mailSender, mailSubject, mailMoney, _, daysLeft = GetInboxHeaderInfo(i);
    	local name, mailIcon, itemCount, quality, canUse = GetInboxItem(i)
		if name ~= nil then
			table.insert(c.mail, {
                icon = packageIcon,
                count = itemCount,
                text = name,
                subject = mailSubject,
                sender = mailSender,
                quality = quality,
                lastcheck = time(),
                daysleft = daysLeft
			} )
		end
		local inboxText
		if AltoOptions_ScanMailBody:GetChecked() then
			inboxText = GetInboxText(i)
		end
		if (mailMoney > 0) or inboxText then
			if mailMoney > 0 then
				mailIcon = "Interface\\Icons\\INV_Misc_Coin_01"
			else
				mailIcon = stationaryIcon
			end
			table.insert(c.mail, {
				icon = mailIcon,
				money = mailMoney,
				text = inboxText,
				subject = mailSubject,
				sender = mailSender,
				lastcheck = time(),
				daysleft = daysLeft
			} )
		end
	end
	table.sort(c.mail, function(a, b)
		return a.daysleft < b.daysleft
	end)
end

-- *** Hooks ***
local Orig_SendMail = SendMail
function SendMail(recipient, subject, body,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9)
	for CharacterName, c in pairs(Altoholic.db.account.data[V.faction][V.realm].char) do
		if CharacterName == recipient then
			for k, v in pairs(V.Attachments) do
				table.insert(c.mail, {
					icon = v.icon,
					link = v.link,
					count = v.count,
					sender = V.player,
					lastcheck = time(),
					daysleft = 30,
					realm = V.realm
				} )
			end
			local moneySent = GetSendMailMoney()
			if (moneySent > 0) or (strlen(body) > 0) then
				local mailIcon
				if moneySent > 0 then
					mailIcon = "Interface\\Icons\\INV_Misc_Coin_01"
				else
					mailIcon = "Interface\\Icons\\INV_Misc_Note_01"
				end
				table.insert(c.mail, {
					money = moneySent,
					icon = mailIcon,
					text = body,
					subject = subject,
					sender = V.player,
					lastcheck = time(),
					daysleft = 30,
					realm = V.realm
				} )
			end
			if (c.lastmailcheck == nil) or (c.lastmailcheck == 0) then
				c.lastmailcheck = time()
			end
			table.sort(c.mail, function(a, b)
				return a.daysleft < b.daysleft
			end)
			break
		end
	end
    V.Attachments = {}
	Orig_SendMail(recipient, subject, body,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9)
end

-- *** EVENT HANDLERS ***
function Altoholic:MAIL_SHOW()
	CheckInbox()
	self:RegisterEvent("MAIL_INBOX_UPDATE")
	self:RegisterEvent("MAIL_SEND_INFO_UPDATE")
	V.Attachments = {}
	V.AllowMailUpdate = true
	V.isMailBoxOpen = true
end

function Altoholic:MAIL_CLOSED()
	V.isMailBoxOpen = nil
	if V.mailclose == nil then
		V.mailclose = 1
		self:UpdatePlayerMail()
		self.db.account.data[V.faction][V.realm].char[V.player].lastmailcheck = time()
		self:BuildMailSubMenu()
		self:UpdatePlayerBags()
		self:UnregisterEvent("MAIL_INBOX_UPDATE");
		self:UnregisterEvent("MAIL_SEND_INFO_UPDATE");
	else
		V.mailclose = nil
	end
	V.Attachments = nil
end

function Altoholic:MAIL_INBOX_UPDATE()
	if V.AllowMailUpdate then
		self:UpdatePlayerMail()
		V.AllowMailUpdate = false
	end
end

function Altoholic:MAIL_SEND_INFO_UPDATE()
    V.Attachments = {}
	for i=1, 12 do
		local name, itemIcon, itemCount = GetSendMailItem(i)
		if name ~= nil then
			table.insert(V.Attachments, {
				icon = itemIcon,
				link = GetSendMailItemLink(i),
				count = itemCount
			} )
		end
	end
end
