local L = AceLibrary("AceLocale-2.2"):new("Altoholic")

L:RegisterTranslations("deDE", function() return {

	-- Note: since 2.4.004 and the support of LibBabble, certain lines are commented, but remain there for clarity (especially those concerning the menu)

	["Mage"] = "Magier",
	["Warrior"] = "Krieger",
	["Hunter"] = "Jäger",
	["Rogue"] = "Schurke",
	["Warlock"] = "Hexenmeister",
	["Druid"] = "Druide",
	["Shaman"] = "Schamane",
	["Paladin"] = "Paladin",
	["Priest"] = "Priester",
	
	-- Stats
	["Sta:-s |rInt:-s |rSpi:-s\n|rCrit:-s |rHit:-s |rDmg:-s"] = "Sta:-s |rInt:-s |rSpi:-s\n|rCrit:-s |rHit:-s |rDmg:-s",
	["Sta:-s |rInt:-s |rSpi:-s\n|rCrit:-s |rMP5:-s |rHeal:-s"] = "Sta:-s |rInt:-s |rSpi:-s\n|rCrit:-s |rMP5:-s |rHeal:-s",
	["Sta:-s |rInt:-s |rMP5:-s\n|rCrit:-s |rHit:-s |rDmg:-s"] = "Sta:-s |rInt:-s |rMP5:-s\n|rCrit:-s |rHit:-s |rDmg:-s",
	["Sta:-s |rInt:-s\n|rCrit:-s |rHit:-s |rDmg:-s"] = "Sta:-s |rInt:-s\n|rCrit:-s |rHit:-s |rDmg:-s",
	["Sta:-s |rInt:-s\n|rCrit:-s |rMP5:-s |rHeal:-s"] = "Sta:-s |rInt:-s\n|rCrit:-s |rMP5:-s |rHeal:-s",
	["Sta:-s |rInt:-s |rDef:-s\n|rDodge:-s |rHit:-s |rDmg:-s"] = "Sta:-s |rInt:-s |rDef:-s\n|rDodge:-s |rHit:-s |rDmg:-s",
	["Sta:-s |rStr:-s |rDef:-s\n|rDodge:-s |rHit:-s"] = "Sta:-s |rStr:-s |rDef:-s\n|rDodge:-s |rHit:-s",
	["Sta:-s |rStr:-s |rAgi:-s\n|rDef:-s |rDodge:-s |rHit:-s"] = "Sta:-s |rStr:-s |rAgi:-s\n|rDef:-s |rDodge:-s |rHit:-s",
	["Sta:-s |rStr:-s |rAgi:-s\n|rCrit:-s |rHit:-s |rAP:-s"] = "Sta:-s |rStr:-s |rAgi:-s\n|rCrit:-s |rHit:-s |rAP:-s",
	["Sta:-s |rStr:-s |rInt:-s\n|rCrit:-s |rHit:-s |rAP:-s"] = "Sta:-s |rStr:-s |rInt:-s\n|rCrit:-s |rHit:-s |rAP:-s",
	["Sta:-s |rAgi:-s |rInt:-s\n|rCrit:-s |rHit:-s |rAP:-s"] = "Sta:-s |rAgi:-s |rInt:-s\n|rCrit:-s |rHit:-s |rAP:-s",
	["Sta:-s |rAgi:-s\n|rCrit:-s |rHit:-s |rAP:-s"] = "Sta:-s |rAgi:-s\n|rCrit:-s |rHit:-s |rAP:-s",
	
	-- note: these string are the ones found in item tooltips, make sure to respect the case when translating, and to distinguish them (like crit vs spell crit)
	["Increases healing done by up to %d+"] = "Increases healing done by up to %d+",
	["Increases damage and healing done by magical spells and effects by up to %d+"] = "Increases damage and healing done by magical spells and effects by up to %d+",
	["Increases attack power by %d+"] = "Increases attack power by %d+",
	["Restores %d+ mana per"] = "Restores %d+ mana per",
	["Classes: Shaman"] = "Classes: Shaman",
	["Classes: Mage"] = "Classes: Mage",
	["Classes: Rogue"] = "Classes: Rogue",
	["Classes: Hunter"] = "Classes: Hunter",
	["Classes: Warrior"] = "Classes: Warrior",
	["Classes: Paladin"] = "Classes: Paladin",
	["Classes: Warlock"] = "Classes: Warlock",
	["Classes: Priest"] = "Classes: Priest",
	["Resistance"] = "Resistance",
	
	-- equipment slots
	["Ranged"] = "Fernkampf",
	
	--skills
	["Professions"] = "Berufe",
	["Secondary Skills"] = "Sekundäre Fertigkeiten",
	["Fishing"] = "Angeln",
	["Riding"] = "Reiten",
	["Herbalism"] = "Kräuterkunde",
	["Mining"] = "Bergbau",
	["Skinning"] = "Kürschnerei",
	["Lockpicking"] = "Schlossknacken",
	["Poisons"] = "Gifte",
	["Beast Training"] = "Begleiter Training",
	
	--factions not in LibFactions or LibZone
	["Exodar"] = "Die Exodar",
	["Gnomeregan Exiles"] = "Gnomeregangnome",
	["Stormwind"] = "Sturmwind",
	["Darkspear Trolls"] = "Dunkelspeertrolle",
	["Alliance Forces"] = "Streitkräfte der Allianz",
	["Horde Forces"] = "Streitkräfte der Horde",
	["Steamwheedle Cartel"] = "Dampfdruckkartell",
	["Other"] = "Andere",
	["Ravenholdt"] = "Rabenholdt",
	["Shen'dralar"] = "Shen'dralar",
	["Syndicate"] = "Syndikat",
	
	-- menu
	["Account Summary"] = "Account Übersicht",
	["Characters"] = "Charaktere",
	["Bag Usage"] = "Taschennutzung",
	["Reputations"] = "Ruf",
	["Containers"] = "Taschen",
	["Guild Bank not visited yet (or not guilded)"] = "Guildenbank bisher nicht geöffnet (oder nicht in Gilde)",
	["E-Mail"] = "Post",
	["Search"] = "Suche",
		-- ["Weapon"] = "Waffen",
			["Any"] = "Sonstige",
			-- ["One-Handed Axes"] = "Einhandäxte",
			-- ["Two-Handed Axes"] = "Zweihandäxte",
			-- ["One-Handed Maces"] = "Einhandstreikolben",
			-- ["Two-Handed Maces"] = "Zweihandstreitkolben",
			-- ["One-Handed Swords"] = "Einhandschwerter",
			-- ["Two-Handed Swords"] = "Zweihandschwerter",
			["1H Axes"] = "1H Äxte",
			["2H Axes"] = "2H Äxte",
			["1H Maces"] = "1H Streikolben",
			["2H Maces"] = "2H Streitkolben",
			["1H Swords"] = "1H Schwerter",
			["2H Swords"] = "2H Schwerter",
			-- ["Bows"] = "Bogen",
			-- ["Guns"] = "Gewehre",
			-- ["Crossbows"] = "Armbrust",
			-- ["Staves"] = "Stab",
			-- ["Wands"] = "Zauberstab",
			-- ["Polearms"] = "Stangenwaffen",
			-- ["Daggers"] = "Dolche",
			-- ["Fist Weapons"] = "Faustwaffen",
			-- ["Thrown"] = "Wurfwaffen",
			["Miscellaneous"] = "Verschiedenes",
			["Fishing Poles"] = "Angelruten",
		-- ["Armor"] = "R/195/188stung",
			-- ["Cloth"] = "Stoff",
			-- ["Leather"] = "Leder",
			-- ["Mail"] = "Schwere R/195/188stung",
			-- ["Plate"] = "Platte",
			-- ["Shields"] = "Schilde",
			-- ["Librams"] = false,
			-- ["Idols"] = false,
			-- ["Totems"] = false,
		-- ["Consumable"] = "Verbrauchbar",
			-- ["Food & Drink"] = "Essen & Trinken",
			-- ["Potion"] = "Tr/195/164nke",
			-- ["Elixir"] = "Elixiere",
			-- ["Flask"] = "Fl/195/164schchen",
			-- ["Bandage"] = "Verb/195/164nde",
			-- ["Item Enhancement"] = "Gegenstandsverbesserungen",
			-- ["Scroll"] = false,
			-- ["Other"] = "Anderes",
		-- ["Trade Goods"] = "Handelswaren",
			-- ["Elemental"] = ,				-- translation needed
			-- ["Metal & Stone"] = ,				-- translation needed
			-- ["Meat"] = "Fleisch",
			-- ["Herb"] = "Pflanzen",
			-- ["Enchanting"] = "Verzauberung",
			-- ["Jewelcrafting"] = "Juwelenschleifen",
			-- ["Parts"] = false,
			-- ["Devices"] = false,
			-- ["Explosives"] = "Explosives",
		-- ["Gem"] = "Edelstein",
			-- ["Red"] = "Rot",
			-- ["Blue"] = "Blau",
			-- ["Yellow"] = "Gelb",
			-- ["Purple"] = ,				-- translation needed
			-- ["Green"] = "Grün",
			-- ["Orange"] = "Orange",
			-- ["Meta"] = "Meta",
			-- ["Simple"] = "Einfach",
			-- ["Prismatic"] = "Prismatisch",
		-- ["Recipe"] = "Rezepte",
			-- ["Alchemy"] = "Alchimie",
			-- ["Blacksmithing"] = "Schmiedekunst",
			-- ["Enchanting"] = "Verzauberkunst",
			-- ["Engineering"] = "Inginieurskunst",
			-- ["Leatherworking"] = "Lederverarbeitung",
			-- ["Tailoring"] = "Schneiderei",
			-- ["Book"] = "B/195/188cher",
			-- ["Cooking"] = "Kochkunst",
			-- ["First Aid"] = "Erste Hilfe",
	["Quests"] = "Quests",
	["Recipes"] = "Rezepte",
	["Equipment"] = "Ausrüstung",
	["Options"] = "Optionen",
	
	--Altoholic.lua
	["Loots"] = "Loots",				-- translation needed
	["Unknown"] = "Unknown",				-- translation needed
	["Mail expires in less than "] = "Mail expires in less than ",				-- translation needed
	[" days"] = " days",				-- translation needed
	["Bank not visited yet"] = "Bank not visited yet",				-- translation needed
	["Levels"] = "Levels",				-- translation needed
	["(has mail)"] = "(has mail)",				-- translation needed
	["(has auctions)"] = "(has auctions)",
	["(has bids)"] = "(has bids)",
	
	["No rest XP"] = "No rest XP",
	["% rested"] = "% rested",
	["Transmute"] = "Transmute",
	
	["Bags"] = "Bags",				-- translation needed
	["Bank"] = "Bank",
	["Equipped"] = "Equipped",				-- translation needed
	["Mail"] = "Mail",				-- translation needed
	[", "] = ", ",						-- required for znCH
	["(Guild bank: "] = "(Guild bank: ",				-- translation needed
	
	["Level"] = "Level",				-- translation needed
	["Zone"] = "Zone",				-- translation needed
	["Rest XP"] = "Rest XP",				-- translation needed
	
	["Source"] = "Source",				-- translation needed
	["Total owned"] = "Total owned",				-- translation needed
	["Already known by "] = "Already known by ",				-- translation needed
	["Will be learnable by "] = "Will be learnable by ",				-- translation needed
	["Could be learned by "] = "Could be learned by ",				-- translation needed
	
	["At least one recipe could not be read"] = "At least one recipe could not be read",				-- translation needed
	["Please open this window again"] = "Please open this window again",				-- translation needed
	
	--Core.lua
	['search'] = 'search',
	["Search in bags"] = "Search in bags",				-- translation needed
	['show'] = 'show',
	["Shows the UI"] = "Shows the UI",				-- translation needed
	['hide'] = 'hide',
	["Hides the UI"] = "Hides the UI",				-- translation needed
	['toggle'] = 'toggle',
	["Toggles the UI"] = "Toggles the UI",				-- translation needed
	
	--AltoholicFu.lua
	["Left-click to"] = "Left-click to",				-- translation needed
	["open/close"] = "open/close",				-- translation needed
	
	--AccountSummary.lua
	["View bags"] = "View bags",				-- translation needed
	["View mailbox"] = "View mailbox",				-- translation needed
	["View quest log"] = "View quest log",				-- translation needed
	["View auctions"] = "View auctions",
	["View bids"] = "View bids",
	["Delete this Alt"] = "Delete this Alt",				-- translation needed
	["Cannot delete current character"] = "Cannot delete current character",				-- translation needed
	["Character "] = "Character ",				-- translation needed
	[" successfully deleted"] = " successfully deleted",				-- translation needed
	["Suggested leveling zone: "] = "Suggested leveling zone: ",				-- translation needed
	["Arena points: "] = "Arena points: ",				-- translation needed
	["Honor points: "] = "Honor points: ",				-- translation needed
	
	-- AuctionHouse.lua
	[" has no auctions"] = " has no auctions",
	[" has no bids"] = " has no bids",
	["last check "] = "last check ",
	["Goblin AH"] = "Goblin AH",
	["Clear your faction's entries"] = "Clear your faction's entries",
	["Clear goblin AH entries"] = "Clear goblin AH entries",
	["Clear all entries"] = "Clear all entries",
	
	
	--BagUsage.lua
	["Totals"] = "Totals",				-- translation needed
	["slots"] = "slots",				-- translation needed
	["free"] = "free",				-- translation needed
	
	--Containers.lua
	["32 Keys Max"] = "32 Keys Max",				-- translation needed
	["28 Slot"] = "28 Slot",				-- translation needed
	["Bank bag"] = "Bank bag",				-- translation needed
	["Unknown link, please relog this character"] = "Unknown link, please relog this character",				-- translation needed
	
	--Equipment.lua
	["Find Upgrade"] = "Find Upgrade",				-- translation needed
	["(based on iLvl)"] = "(based on iLvl)",				-- translation needed
	["Right-Click to find an upgrade"] = "Right-Click to find an upgrade",
	["Tank"] = "Tank",
	["DPS"] = "DPS",
	["Balance"] = "Balance",
	["Elemental Shaman"] = "Elemental Shaman",		-- shaman spec !
	["Heal"] = "Heal",
	
	--GuildBank.lua
	["Last visited "] = "Last visited ",				-- translation needed
	[" days ago by "] = " days ago by ",				-- translation needed
	
	--Mails.lua
	[" has not visited his/her mailbox yet"] = " has not visited his/her mailbox yet",				-- translation needed
	[" has no mail, last check "] = " has no mail, last check ",				-- translation needed
	[" days ago"] = " days ago",				-- translation needed
	["Mailbox"] = "Mailbox",				-- translation needed
	["Mail was last checked "] = "Mail was last checked ",				-- translation needed
	[" days"] = " days",				-- translation needed
	
	--Quests.lua
	["No quest found for "] = "No quest found for ",				-- translation needed
	["QuestID"] = "QuestID",				-- translation needed
	["Are also on this quest:"] = "Are also on this quest:",				-- translation needed
	
	--Recipes.lua
	["No data: "] = "No data: ",				-- translation needed
	[" scan failed for "] = " scan failed for ",				-- translation needed
	
	--Reputations.lua
	["Shift-Click to link this info"] = "Shift-Click to link this info",				-- translation needed
	[" is "] = " is ",				-- translation needed
	[" with "] = " with ",				-- translation needed
	
	--Search.lua
	["Item Level"] = "Item Level",				-- translation needed
	[" results found (Showing "] = " results found (Showing ",				-- translation needed
	["No match found!"] = "No match found!",				-- translation needed
	[" not found!"] = " not found!",				-- translation needed
	["Socket"] = "Socket",
	
	--skills.lua
	["Rogue Proficiencies"] = "Rogue Proficiencies",				-- translation needed
	["up to"] = "up to",				-- translation needed
	["at"] = "at",				-- translation needed
	["and above"] = "and above",				-- translation needed
	["Suggestion"] = "Suggestion",				-- translation needed
	["Prof. 1"] = "Prof. 1",
	["Prof. 2"] = "Prof. 2",
	
	--loots.lua
	--Instinct drop
	["Trash Mobs"] = "Trash Mobs",				-- translation needed
	["Random Boss"] = "Random Boss",				-- translation needed
	["Druid Set"] = "Druid Set",				-- translation needed
	["Hunter Set"] = "Hunter Set",				-- translation needed
	["Mage Set"] = "Mage Set",				-- translation needed
	["Paladin Set"] = "Paladin Set",				-- translation needed
	["Priest Set"] = "Priest Set",				-- translation needed
	["Rogue Set"] = "Rogue Set",				-- translation needed
	["Shaman Set"] = "Shaman Set",				-- translation needed
	["Warlock Set"] = "Warlock Set",				-- translation needed
	["Warrior Set"] = "Warrior Set",				-- translation needed
	["Legendary Mount"] = "Legendary Mount",				-- translation needed
	["Legendaries"] = "Legendaries",				-- translation needed
	["Muddy Churning Waters"] = "Muddy Churning Waters",				-- translation needed
	["Shared"] = "Shared",				-- translation needed
	["Enchants"] = "Enchants",				-- translation needed
	["Rajaxx's Captains"] = "Rajaxx's Captains",
	["Class Books"] = "Klassenbücher",
	["Quest Items"] = "Quest Items",				-- translation needed
	["Druid of the Fang (Trash Mob)"] = "Druid of the Fang (Trash Mob)",				-- translation needed
	["Spawn Of Hakkar"] = "Brut von Hakkar",
	["Troll Mini bosses"] = "Troll Mini bosses",				-- translation needed
	["Henry Stern"] = "Henry Stern",
	["Magregan Deepshadow"] = "Magregan Grubenschatten",
	["Tablet of Ryuneh"] = "Schrifttafel von Ryun'eh",
	["Krom Stoutarm Chest"] = "Krom Starkarms Truhe",
	["Garrett Family Chest"] = "Familientruhe der Garretts",
	["Eric The Swift"] = "Eric 'Der Flinke'",
	["Olaf"] = "Olaf",
	["Baelog's Chest"] = "Baelogs Truhe",
	["Conspicuous Urn"] = "Verdächtige Urne",
	["Tablet of Will"] = "Schrifttafel des Willens",
	["Shadowforge Cache"] = "Shadowforge Cache",				-- translation needed
	["Roogug"] = "Roogug",
	["Aggem Thorncurse"] = "Aggem Dornfluch",
	["Razorfen Spearhide"] = "Speerträger der Klingenhauer",
	["Pyron"] = "Pyron",
	["Theldren"] = "Theldren",
	["The Vault"] = "Der Tresor",
	["Summoner's Tomb"] = "Summoner's Tomb",				-- translation needed
	["Plans"] = "Pläne",
	["Zelemar the Wrathful"] = "Zelemar der Hasserfüllte",
	["Rethilgore"] = "Rotkralle",
	["Fel Steed"] = "Teufelsross",
	["Tribute Run"] = "Tribut Run",
	["Shen'dralar Provisioner"] = "Versorger der Shen'dralar",
	["Books"] = "Books",				-- translation needed
	["Trinkets"] = "Trinkets",				-- translation needed
	["Sothos & Jarien"] = "Sothos und Jarien",
	["Fel Iron Chest"] = "Fel Iron Chest",				-- translation needed
	[" (Heroic)"] = " (Heroisch)",
	["Yor (Heroic Summon)"] = "Yor (Heroic Summon)",
	["Avatar of the Martyred"] = "Avatar des Gemarterten",
	["Anzu the Raven God (Heroic Summon)"] = "Anzu the Raven God (Heroic Summon)",
	["Thomas Yance"] = "Thomas Yance",
	["Aged Dalaran Wizard"] = "Gealterter Hexer von Dalaran",
	["Cache of the Legion"] = "Behälter der Legion",
	["Opera (Shared Drops)"] = "Opera (Shared Drops)",				-- translation needed
	["Timed Chest"] = "Timed Chest",				-- translation needed
	["Patterns"] = "Muster",
	
	--Rep
	["Token Hand-Ins"] = "Token Hand-Ins",				-- translation needed
	["Items"] = "Items",				-- translation needed
	["Beasts Deck"] = "Beasts Deck",				-- translation needed
	["Elementals Deck"] = "Elementals Deck",				-- translation needed
	["Warlords Deck"] = "Warlords Deck",				-- translation needed
	["Portals Deck"] = "Portals Deck",				-- translation needed
	["Furies Deck"] = "Furies Deck",				-- translation needed
	["Storms Deck"] = "Storms Deck",				-- translation needed
	["Blessings Deck"] = "Blessings Deck",				-- translation needed
	["Lunacy Deck"] = "Lunacy Deck",				-- translation needed
	["Quest rewards"] = "Quest rewards",				-- translation needed
	--["Shattrath"] = true,
	
	--World drop
	["Outdoor Bosses"] = "Outdoor Bosses",				-- translation needed
	["Highlord Kruul"] = "Hochlord Kruul",
	["Bash'ir Landing"] = "Bash'ir Landing",				-- translation needed
	["Skyguard Raid"] = "Skyguard Raid",				-- translation needed
	["Stasis Chambers"] = "Stasis Chambers",				-- translation needed
	["Skettis"] = "Skettis",
	["Darkscreecher Akkarai"] = "Dunkelkreischer Akkarai",
	["Karrog"] = "Karrog",
	["Gezzarak the Huntress"] = "Gezzarak die Jägerin",
	["Vakkiz the Windrager"] = "Vakkiz der Windzürner",
	["Terokk"] = "Terokk",
	["Ethereum Prison"] = "Gefängnis des Astraleums",
	["Armbreaker Huffaz"] = "Armbrecher Huffaz",
	["Fel Tinkerer Zortan"] = "Teufelstüftler Zortan",
	["Forgosh"] = "Forgosh",
	["Gul'bor"] = "Gul'bor",
	["Malevus the Mad"] = "Malevus die Verrückte",
	["Porfus the Gem Gorger"] = "Porfus der Edelsteinschlinger",
	["Wrathbringer Laz-tarash"] = "Zornschaffer Laz-tarash",
	["Abyssal Council"] = "Abyssischer Rat",
	["Crimson Templar (Fire)"] = "Crimson Templar (Fire)",				-- translation needed
	["Azure Templar (Water)"] = "Azure Templar (Water)",				-- translation needed
	["Hoary Templar (Wind)"] = "Hoary Templar (Wind)",				-- translation needed
	["Earthen Templar (Earth)"] = "Earthen Templar (Earth)",				-- translation needed
	["The Duke of Cinders (Fire)"] = "The Duke of Cinders (Fire)",				-- translation needed
	["The Duke of Fathoms (Water)"] = "The Duke of Fathoms (Water)",				-- translation needed
	["The Duke of Zephyrs (Wind)"] = "The Duke of Zephyrs (Wind)",				-- translation needed
	["The Duke of Shards (Earth)"] = "The Duke of Shards (Earth)",				-- translation needed
	["Elemental Invasion"] = "Invasion der Elementare",
	["Gurubashi Arena"] = "Gurubashi Arena",				-- translation needed
	["Booty Run"] = "Booty Run",				-- translation needed
	["Fishing Extravaganza"] = "Fishing Extravaganza",				-- translation needed
	["First Prize"] = "Hauptpreis",
	["Rare Fish"] = "Besondere Fische",
	["Rare Fish Rewards"] = "Besonderer Fisch - Belohnungen",
	["Children's Week"] = "Kinderwoche",
	["Love is in the air"] = "Herzklopfen",
	["Gift of Adoration"] = "Geschenke der Verehrung",
	["Box of Chocolates"] = "Schokoladenschachtel",
	["Hallow's End"] = "Schlotternächte",
	["Various Locations"] = "Verschiedene Orte",
	["Treat Bag"] = "Schlotterbeutel",
	["Headless Horseman"] = "Kopfloser Reiter",
	["Feast of Winter Veil"] = "Winterhauchfest",
	["Smokywood Pastures Vendor"] = "Smokywood Pastures Vendor",				-- translation needed
	["Gaily Wrapped Present"] = "Fröhlich verpacktes Geschenk",
	["Festive Gift"] = "Festtagsgeschenk",
	["Winter Veil Gift"] = "Winterhauchgeschenk",
	["Gently Shaken Gift"] = "Leicht geschütteltes Geschenk",
	["Ticking Present"] = "Tickendes Geschenk",
	["Carefully Wrapped Present"] = "Sorgfältig verpacktes Geschenk",
	["Noblegarden"] = "Nobelgarten",
	["Brightly Colored Egg"] = "Osterei",
	["Smokywood Pastures Extra-Special Gift"] = "Kokelwälder Extraspezialgeschenk",
	["Harvest Festival"] = "Erntedankfest",
	["Food"] = "Food",				-- translation needed
	["Scourge Invasion"] = "Invasion der Geißel",
	--["Miscellaneous"] = true,
	["Cloth Set"] = "Cloth Set",				-- translation needed
	["Leather Set"] = "Leather Set",				-- translation needed
	["Mail Set"] = "Mail Set",				-- translation needed
	["Plate Set"] = "Plate Set",				-- translation needed
	["Balzaphon"] = "Balzaphon",				-- translation needed
	["Lord Blackwood"] = "Lord Blackwood",				-- translation needed
	["Revanchion"] = "Revanchion",				-- translation needed
	["Scorn"] = "Scorn",				-- translation needed
	["Sever"] = "Sever",				-- translation needed
	["Lady Falther'ess"] = "Lady Falther'ess",				-- translation needed
	["Lunar Festival"] = "Lunar Festival",				-- translation needed
	["Fireworks Pack"] = "Fireworks Pack",				-- translation needed
	["Lucky Red Envelope"] = "Lucky Red Envelope",				-- translation needed
	["Midsummer Fire Festival"] = "Midsummer Fire Festival",				-- translation needed
	["Lord Ahune"] = "Lord Ahune",				-- translation needed
	["Shartuul"] = "Shartuul",				-- translation needed
	["Blade Edge Mountains"] = "Blade Edge Mountains",				-- translation needed
	["Brewfest"] = "Brewfest",				-- translation needed
	["Barleybrew Brewery"] = "Barleybrew Brewery",				-- translation needed
	["Thunderbrew Brewery"] = "Thunderbrew Brewery",				-- translation needed
	["Gordok Brewery"] = "Gordok Brewery",				-- translation needed
	["Drohn's Distillery"] = "Drohn's Distillery",				-- translation needed
	["T'chali's Voodoo Brewery"] = "T'chali's Voodoo Brewery",				-- translation needed
	
	--craft
	["Crafted Weapons"] = "Crafted Weapons",				-- translation needed
	["Master Swordsmith"] = "Master Swordsmith",				-- translation needed
	["Master Axesmith"] = "Master Axesmith",				-- translation needed
	["Master Hammersmith"] = "Master Hammersmith",				-- translation needed
	["Blacksmithing (Lv 60)"] = "Blacksmithing (Lv 60)",				-- translation needed
	["Blacksmithing (Lv 70)"] = "Blacksmithing (Lv 70)",				-- translation needed
	["Engineering (Lv 60)"] = "Engineering (Lv 60)",				-- translation needed
	["Engineering (Lv 70)"] = "Engineering (Lv 70)",				-- translation needed
	["Blacksmithing Plate Sets"] = "Blacksmithing Plate Sets",				-- translation needed
	["Imperial Plate"] = "Stolz des Imperiums",
	["The Darksoul"] = "Die dunkle Seele",
	["Fel Iron Plate"] = "Teufelseisenplattenrüstung",
	["Adamantite Battlegear"] = "Adamantitschlachtrüstung",
	["Flame Guard"] = "Flammenwächter",
	["Enchanted Adamantite Armor"] = "Verzauberte Adamantitrüstung",
	["Khorium Ward"] = "Khoriumschutz",
	["Faith in Felsteel"] = "Teufelsstählerner Wille",
	["Burning Rage"] = "Brennernder Zorn",
	["Blacksmithing Mail Sets"] = "Blacksmithing Mail Sets",				-- translation needed
	["Bloodsoul Embrace"] = "Umarmung der Blutseele",
	["Fel Iron Chain"] = "Teufelseisenkettenrüstung",	
	["Tailoring Sets"] = "Tailoring Sets",				-- translation needed
	["Bloodvine Garb"] = "Blutrebengewand",
	["Netherweave Vestments"] = "Netherstoffgewänder",
	["Imbued Netherweave"] = "Magieerfüllte Netherstoffroben",
	["Arcanoweave Vestments"] = "Arkanostoffgewänder",
	["The Unyielding"] = "Der Unerschütterliche",
	["Whitemend Wisdom"] = "Weisheit des weißen Heilers",
	["Spellstrike Infusion"] = "Insignien des Zauberschlags",
	["Battlecast Garb"] = "Gewand des Schlachtenzaubers",
	["Soulcloth Embrace"] = "Seelenstoffumarmung",
	["Primal Mooncloth"] = "Urmondroben",
	["Shadow's Embrace"] = "Umarmung der Schatten",
	["Wrath of Spellfire"] = "Zorn des Zauberfeuers",
	["Leatherworking Leather Sets"] = "Leatherworking Leather Sets",				-- translation needed
	["Volcanic Armor"] = "Vulkanrüstung",
	["Ironfeather Armor"] = "Eisenfederrüstung",
	["Stormshroud Armor"] = "Sturmschleier",
	["Devilsaur Armor"] = "Teufelsaurierrüstung",
	["Blood Tiger Harness"] = "Harnisch des Bluttigers",
	["Primal Batskin"] = "Urzeitliche Fledermaushaut",
	["Wild Draenish Armor"] = "Wilde draenische Rüstung",
	["Thick Draenic Armor"] = "Dicke draenische Rüstung",
	["Fel Skin"] = "Teufelshaut",
	["Strength of the Clefthoof"] = "Macht der Grollhufe",
	["Primal Intent"] = "Urinstinkt",
	["Windhawk Armor"] = "Rüstung des Windfalken",
	["Leatherworking Mail Sets"] = "Leatherworking Mail Sets",				-- translation needed
	["Green Dragon Mail"] = "Grüner Drachenschuppenpanzer",
	["Blue Dragon Mail"] = "Blauer Drachenschuppenpanzer",
	["Black Dragon Mail"] = "Schwarzer Drachenschuppenpanzer",
	["Scaled Draenic Armor"] = "Geschuppte draenische Rüstung",
	["Felscale Armor"] = "Teufelsschuppenrüstung",
	["Felstalker Armor"] = "Rüstung des Teufelspirschers",
	["Fury of the Nether"] = "Netherzorn",
	["Netherscale Armor"] = "Netherschuppenrüstung",
	["Netherstrike Armor"] = "Rüstung des Netherstoßes",	
	["Armorsmith"] = "Armorsmith",				-- translation needed
	["Weaponsmith"] = "Weaponsmith",				-- translation needed
	["Dragonscale"] = "Dragonscale",				-- translation needed
	["Elemental"] = "Elemental",				-- translation needed
	["Tribal"] = "Tribal",				-- translation needed
	["Mooncloth"] = "Mooncloth",				-- translation needed
	["Shadoweave"] = "Shadoweave",				-- translation needed
	["Spellfire"] = "Spellfire",				-- translation needed
	["Gnomish"] = "Gnomish",				-- translation needed
	["Goblin"] = "Goblin",				-- translation needed
	["Apprentice"] = "Apprentice",				-- translation needed
	["Journeyman"] = "Journeyman",				-- translation needed
	["Expert"] = "Expert",				-- translation needed
	["Artisan"] = "Artisan",				-- translation needed
	["Master"] = "Master",				-- translation needed
	
	--Set & PVP
	["Superior Rewards"] = "Seltene Items",
	["Epic Rewards"] = "Epische Items",
	["Lv 10-19 Rewards"] = "Belohnungen (Level 10-19)",
	["Lv 20-29 Rewards"] = "Belohnungen (Level 20-29)",
	["Lv 30-39 Rewards"] = "Belohnungen (Level 30-39)",
	["Lv 40-49 Rewards"] = "Belohnungen (Level 40-49)",
	["Lv 50-59 Rewards"] = "Belohnungen (Level 50-59)",
	["Lv 60 Rewards"] = "Belohnungen (Level 60)",	
	["PVP Cloth Set"] = "PVP Cloth Set",				-- translation needed
	["PVP Leather Sets"] = "PVP Leather Sets",				-- translation needed
	["PVP Mail Sets"] = "PVP Mail Sets",				-- translation needed
	["PVP Plate Sets"] = "PVP Plate Sets",				-- translation needed
	["World PVP"] = "World PVP",				-- translation needed
	["Hellfire Fortifications"] = "Befestigung des Höllenfeuers",
	["Twin Spire Ruins"] = "Ruinen der Zwillingsspitze",
	["Spirit Towers (Terrokar)"] = "Geistertürme (Terrokar)",
	["Halaa (Nagrand)"] = "Halaa (Nagrand)",
	["Arena Season 1"] = "Arena Season 1",				-- translation needed
	["Arena Season 2"] = "Arena Season 2",				-- translation needed
	["Arena Season 3"] = "Arena Season 3",				-- translation needed
	["Arena Season 4"] = "Arena Season 4",				-- translation needed
	["Weapons"] = "Waffen",
	["Level 60 Honor PVP"] = "Level 60 Honor PVP",				-- translation needed
	["Accessories"] = "Accessories",				-- translation needed
	["Level 70 Reputation PVP"] = "Level 70 Reputation PVP",				-- translation needed
	["Level 70 Honor PVP"] = "Level 70 Honor PVP",				-- translation needed
	["Non Set Accessories"] = "Non Set Accessories",				-- translation needed
	["Non Set Cloth"] = "Non Set Cloth",				-- translation needed
	["Non Set Leather"] = "Non Set Leather",				-- translation needed
	["Non Set Mail"] = "Non Set Mail",				-- translation needed
	["Non Set Plate"] = "Non Set Plate",				-- translation needed
	["Tier 0.5 Quests"] = "Tier 0.5 Quests",				-- translation needed
	["Tier 3 (Naxxramas Tokens)"] = "Tier 3 (Naxxramas Tokens)",				-- translation needed
	["Tier 4 Tokens"] = "Tier 4 Tokens",				-- translation needed
	["Tier 5 Tokens"] = "Tier 5 Tokens",				-- translation needed
	["Tier 6 Tokens"] = "Tier 6 Tokens",				-- translation needed
	["Blizzard Collectables"] = "Blizzard Collectables",				-- translation needed
	["WoW Collector Edition"] = "WoW Collector Edition",				-- translation needed
	["BC Collector Edition (Europe)"] = "BC Collector Edition (Europe)",				-- translation needed
	["Blizzcon 2005"] = "Blizzcon 2005",
	["Blizzcon 2007"] = "Blizzcon 2007",
	["Christmas Gift 2006"] = "Christmas Gift 2006",				-- translation needed
	["Upper Deck"] = "Upper Deck",				-- translation needed
	["Loot Card Items"] = "Loot Card Items",				-- translation needed
	["Heroic Mode Tokens"] = "Heroic Mode Tokens",				-- translation needed
	["Fire Resistance Gear"] = "Fire Resistance Gear",				-- translation needed

	["Cloaks"] = "Cloaks",				-- translation needed
	["Relics"] = "Relics",				-- translation needed
	["World Drops"] = "World Drops",				-- translation needed
	["Level 30-39"] = "Level 30-39",
	["Level 40-49"] = "Level 40-49",
	["Level 50-60"] = "Level 50-60",
	["Level 70"] = "Level 70",
	
	-- Altoholic.Gathering : Mining 
	["Copper Vein"] = "Kupfervorkommen",
	["Tin Vein"] = "Zinnvorkommen",
	["Iron Deposit"] = "Eisenvorkommen",
	["Silver Vein"] = "Silbervorkommen",
	["Gold Vein"] = "Goldvorkommen",
	["Mithril Deposit"] = "Mithrilablagerung",
	["Ooze Covered Mithril Deposit"] = "Brühschlammbedeckte Mithrilablagerung",
	["Truesilver Deposit"] = "Echtsilberablagerung",
	["Ooze Covered Silver Vein"] = "Brühschlammbedecktes Silbervorkommen",
	["Ooze Covered Gold Vein"] = "Brühschlammbedecktes Goldvorkommen",
	["Ooze Covered Truesilver Deposit"] = "Brühschlammbedeckte Echtsilberablagerung",
	["Ooze Covered Rich Thorium Vein"] = "Brühschlammbedecktes reiches Thoriumvorkommen",
	["Ooze Covered Thorium Vein"] = "Brühschlammbedecktes Thoriumvorkommen",
	["Small Thorium Vein"] = "Kleines Thoriumvorkommen",
	["Rich Thorium Vein"] = "Reiches Thoriumvorkommen",
	["Hakkari Thorium Vein"] = "Hakkari Thoriumvorkommen",
	["Dark Iron Deposit"] = "Dunkeleisenablagerung",
	["Lesser Bloodstone Deposit"] = "Geringe Blutsteinablagerung",
	["Incendicite Mineral Vein"] = "Pyrophormineralvorkommen",
	["Indurium Mineral Vein"] = "Induriummineralvorkommen",
	["Fel Iron Deposit"] = "Teufelseisenvorkommen",
	["Adamantite Deposit"] = "Adamantitablagerung",
	["Rich Adamantite Deposit"] = "Reiche Adamantitablagerung",
	["Khorium Vein"] = "Khoriumvorkommen",
	["Large Obsidian Chunk"] = "Großer Obsidianbrocken",
	["Small Obsidian Chunk"] = "Kleiner Obsidianbrocken",
	["Nethercite Deposit"] = "Netheritablagerung",
	
	-- Altoholic.Gathering : Herbalism
	["Peacebloom"] = "Friedensblume",
	["Silverleaf"] = "Silberblatt",
	["Earthroot"] = "Erdwurzel",
	["Mageroyal"] = "Maguskönigskraut",
	["Briarthorn"] = "Wilddornrose",
	["Swiftthistle"] = "Flitzdistel",
	["Stranglekelp"] = "Würgetang",
	["Bruiseweed"] = "Beulengras",
	["Wild Steelbloom"] = "Wildstahlblume",
	["Grave Moss"] = "Grabmoos",
	["Kingsblood"] = "Königsblut",
	["Liferoot"] = "Lebenswurz",
	["Fadeleaf"] = "Blassblatt",
	["Goldthorn"] = "Golddorn",
	["Khadgar's Whisker"] = "Khadgars Schnurrbart",
	["Wintersbite"] = "Winterbiss",
	["Firebloom"] = "Feuerblüte",
	["Purple Lotus"] = "Lila Lotus",
	["Wildvine"] = "Wildranke",
	["Arthas' Tears"] = "Arthas’ Tränen",
	["Sungrass"] = "Sonnengras",
	["Blindweed"] = "Blindkraut",
	["Ghost Mushroom"] = "Geisterpilz",
	["Gromsblood"] = "Gromsblut",
	["Golden Sansam"] = "Goldener Sansam",
	["Dreamfoil"] = "Traumblatt",
	["Mountain Silversage"] = "Bergsilbersalbei",
	["Plaguebloom"] = "Pestblüte",
	["Icecap"] = "Eiskappe",
	["Bloodvine"] = "Blutrebe",
	["Black Lotus"] = "Schwarzer Lotus",
	["Felweed"] = "Teufelsgras",
	["Dreaming Glory"] = "Traumwinde",
	["Terocone"] = "Terozapfen",
	["Ancient Lichen"] = "Urflechte",
	["Bloodthistle"] = "Blutdistel",
	["Mana Thistle"] = "Manadistel",
	["Netherbloom"] = "Netherblüte",
	["Nightmare Vine"] = "Alptraumranke",
	["Ragveil"] = "Zottelkappe",
	["Flame Cap"] = "Flammenkappe",
	["Fel Lotus"] = "Teufelslotus",
	["Netherdust Bush"] = "Netherstaubbusch",  	
	-- ["Glowcap"] = true,
	-- ["Sanguine Hibiscus"] = true,
	
} end)

if GetLocale() == "deDE" then
-- Altoholic.xml local
LEFT_HINT = "Left-click to |cFF00FF00open";
RIGHT_HINT = "Right-click to |cFF00FF00drag";

XML_TEXT_1 = "Totals";
XML_TEXT_2 = "Search Containers";
XML_TEXT_3 = "Level Range";
XML_TEXT_4 = "Rarity";
XML_TEXT_5 = "Equipment Slot";
XML_TEXT_6 = "Reset";
XML_TEXT_7 = "Search";

XML_TEXT_MAIN_WINDOW_1 = "Include items without level requirement";
XML_TEXT_MAIN_WINDOW_2 = "Search this realm only";
XML_TEXT_MAIN_WINDOW_3 = "Search all realms";
XML_TEXT_MAIN_WINDOW_4 = "Search loot tables";
XML_TEXT_MAIN_WINDOW_5 = "Include mailboxes";
XML_TEXT_MAIN_WINDOW_6 = "Include guild bank(s)";
XML_TEXT_MAIN_WINDOW_7 = "Include known recipes";

--Options.xml
XML_TEXT_8 = "Tooltip Options";
XML_TEXT_9 = "Search Options";
XML_TEXT_10 = "Move to change the angle of the minimap icon";
XML_TEXT_11 = "Minimap Icon Angle (";
XML_TEXT_12 = "Move to change the radius of the minimap icon";
XML_TEXT_13 = "Minimap Icon Radius (";
XML_TEXT_14 = "Warn when mail expires in less days than this value";
XML_TEXT_15 = "Mail Expiry Warning (";
XML_TEXT_16 = "Show Minimap Icon";
XML_TEXT_17 = "Sort loots in descending order";
XML_TEXT_18 = "Max rest XP displayed as 150%";
XML_TEXT_19 = "Scan mail body (marks it as read)";
XML_TEXT_20 = "Display Item Source";
XML_TEXT_21 = "Display Item Count Per Character";
XML_TEXT_22 = "Display Total Item Count";
XML_TEXT_23 = "Include Guild Bank Count";
XML_TEXT_24 = "Include Already Known";
XML_TEXT_25 = "AutoQuery server |cFFFF0000(disconnection risk)";
XML_TEXT_26 = "|cFFFFFFFFIf an item not in the local item cache\n"
				.. "is encountered while searching loot tables,\n"
				.. "Altoholic will attempt to query the server for 5 new items.\n\n"
				.. "This will gradually improve the consistency of the searches,\n"
				.. "as more items are available in the item cache.\n\n"
				.. "There is a risk of disconnection if the queried item\n"
				.. "is a loot from a high level dungeon.\n\n"
				.. "|cFF00FF00Disable|r to avoid this risk";
XML_TEXT_27 = "Include Learnable By";
end
