--[[
Name: LibBabble-Boss-3.0
Revision: $Rev: 74804 $
Author(s): ckknight (ckknight@gmail.com)
Website: http://ckknight.wowinterface.com/
Description: A library to provide localizations for bosses.
Dependencies: None
License: MIT
]]

local MAJOR_VERSION = "LibBabble-Boss-3.0"
local MINOR_VERSION = "$Revision: 74804 $"

-- #AUTODOC_NAMESPACE prototype

local GAME_LOCALE = GetLocale()
do
	-- LibBabble-Core-3.0 is hereby placed in the Public Domain
	-- Credits: ckknight
	local LIBBABBLE_MAJOR, LIBBABBLE_MINOR = "LibBabble-3.0", 2

	local LibBabble = LibStub:NewLibrary(LIBBABBLE_MAJOR, LIBBABBLE_MINOR)
	if LibBabble then
		local data = LibBabble.data or {}
		for k,v in pairs(LibBabble) do
			LibBabble[k] = nil
		end
		LibBabble.data = data

		local tablesToDB = {}
		for namespace, db in pairs(data) do
			for k,v in pairs(db) do
				tablesToDB[v] = db
			end
		end
		
		local function warn(message)
			local _, ret = pcall(error, message, 3)
			geterrorhandler()(ret)
		end

		local lookup_mt = { __index = function(self, key)
			local db = tablesToDB[self]
			local current_key = db.current[key]
			if current_key then
				self[key] = current_key
				return current_key
			end
			local base_key = db.base[key]
			local real_MAJOR_VERSION
			for k,v in pairs(data) do
				if v == db then
					real_MAJOR_VERSION = k
					break
				end
			end
			if not real_MAJOR_VERSION then
				real_MAJOR_VERSION = LIBBABBLE_MAJOR
			end
			if base_key then
				warn(("%s: Translation %q not found for locale %q"):format(real_MAJOR_VERSION, key, GAME_LOCALE))
				rawset(self, key, base_key)
				return base_key
			end
			warn(("%s: Translation %q not found."):format(real_MAJOR_VERSION, key))
			rawset(self, key, key)
			return key
		end }

		local function initLookup(module, lookup)
			local db = tablesToDB[module]
			for k in pairs(lookup) do
				lookup[k] = nil
			end
			setmetatable(lookup, lookup_mt)
			tablesToDB[lookup] = db
			db.lookup = lookup
			return lookup
		end

		local function initReverse(module, reverse)
			local db = tablesToDB[module]
			for k in pairs(reverse) do
				reverse[k] = nil
			end
			for k,v in pairs(db.current) do
				reverse[v] = k
			end
			tablesToDB[reverse] = db
			db.reverse = reverse
			db.reverseIterators = nil
			return reverse
		end

		local prototype = {}
		local prototype_mt = {__index = prototype}

		--[[---------------------------------------------------------------------------
		Notes:
			* If you try to access a nonexistent key, it will warn but allow the code to pass through.
		Returns:
			A lookup table for english to localized words.
		Example:
			local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
			local BL = B:GetLookupTable()
			assert(BL["Some english word"] == "Some localized word")
			DoSomething(BL["Some english word that doesn't exist"]) -- warning!
		-----------------------------------------------------------------------------]]
		function prototype:GetLookupTable()
			local db = tablesToDB[self]

			local lookup = db.lookup
			if lookup then
				return lookup
			end
			return initLookup(self, {})
		end
		--[[---------------------------------------------------------------------------
		Notes:
			* If you try to access a nonexistent key, it will return nil.
		Returns:
			A lookup table for english to localized words.
		Example:
			local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
			local B_has = B:GetUnstrictLookupTable()
			assert(B_has["Some english word"] == "Some localized word")
			assert(B_has["Some english word that doesn't exist"] == nil)
		-----------------------------------------------------------------------------]]
		function prototype:GetUnstrictLookupTable()
			local db = tablesToDB[self]

			return db.current
		end
		--[[---------------------------------------------------------------------------
		Notes:
			* If you try to access a nonexistent key, it will return nil.
			* This is useful for checking if the base (English) table has a key, even if the localized one does not have it registered.
		Returns:
			A lookup table for english to localized words.
		Example:
			local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
			local B_hasBase = B:GetBaseLookupTable()
			assert(B_hasBase["Some english word"] == "Some english word")
			assert(B_hasBase["Some english word that doesn't exist"] == nil)
		-----------------------------------------------------------------------------]]
		function prototype:GetBaseLookupTable()
			local db = tablesToDB[self]

			return db.base
		end
		--[[---------------------------------------------------------------------------
		Notes:
			* If you try to access a nonexistent key, it will return nil.
			* This will return only one English word that it maps to, if there are more than one to check, see :GetReverseIterator("word")
		Returns:
			A lookup table for localized to english words.
		Example:
			local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
			local BR = B:GetReverseLookupTable()
			assert(BR["Some localized word"] == "Some english word")
			assert(BR["Some localized word that doesn't exist"] == nil)
		-----------------------------------------------------------------------------]]
		function prototype:GetReverseLookupTable()
			local db = tablesToDB[self]

			local reverse = db.reverse
			if reverse then
				return reverse
			end
			return initReverse(self, {})
		end
		local blank = {}
		local weakVal = {__mode='v'}
		--[[---------------------------------------------------------------------------
		Arguments:
			string - the localized word to chek for.
		Returns:
			An iterator to traverse all English words that map to the given key
		Example:
			local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
			for word in B:GetReverseIterator("Some localized word") do
				DoSomething(word)
			end
		-----------------------------------------------------------------------------]]
		function prototype:GetReverseIterator(key)
			local db = tablesToDB[self]
			local reverseIterators = db.reverseIterators
			if not reverseIterators then
				reverseIterators = setmetatable({}, weakVal)
				db.reverseIterators = reverseIterators
			elseif reverseIterators[key] then
				return pairs(reverseIterators[key])
			end
			local t
			for k,v in pairs(db.current) do
				if v == key then
					if not t then
						t = {}
					end
					t[k] = true
				end
			end
			reverseIterators[key] = t or blank
			return pairs(reverseIterators[key])
		end
		--[[---------------------------------------------------------------------------
		Returns:
			An iterator to traverse all translations English to localized.
		Example:
			local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
			for english, localized in B:Iterate() do
				DoSomething(english, localized)
			end
		-----------------------------------------------------------------------------]]
		function prototype:Iterate()
			local db = tablesToDB[self]

			return pairs(db.current)
		end

		-- #NODOC
		-- modules need to call this to set the base table
		function prototype:SetBaseTranslations(base)
			local db = tablesToDB[self]
			local oldBase = db.base
			if oldBase then
				for k in pairs(oldBase) do
					oldBase[k] = nil
				end
				for k, v in pairs(base) do
					oldBase[k] = v
				end
				base = oldBase
			else
				db.base = base
			end
			for k,v in pairs(base) do
				if v == true then
					base[k] = k
				end
			end
		end

		local function init(module)
			local db = tablesToDB[module]
			if db.lookup then
				initLookup(module, db.lookup)
			end
			if db.reverse then
				initReverse(module, db.reverse)
			end
			db.reverseIterators = nil
		end

		-- #NODOC
		-- modules need to call this to set the current table. if current is true, use the base table.
		function prototype:SetCurrentTranslations(current)
			local db = tablesToDB[self]
			if current == true then
				db.current = db.base
			else
				local oldCurrent = db.current
				if oldCurrent then
					for k in pairs(oldCurrent) do
						oldCurrent[k] = nil
					end
					for k, v in pairs(current) do
						oldCurrent[k] = v
					end
					current = oldCurrent
				else
					db.current = current
				end
			end
			init(self)
		end

		for namespace, db in pairs(data) do
			setmetatable(db.module, prototype_mt)
			init(db.module)
		end

		-- #NODOC
		-- modules need to call this to create a new namespace.
		function LibBabble:New(namespace, minor)
			local module, oldminor = LibStub:NewLibrary(namespace, minor)
			if not module then
				return
			end

			if not oldminor then
				local db = {
					module = module,
				}
				data[namespace] = db
				tablesToDB[module] = db
			else
				for k,v in pairs(module) do
					module[k] = nil
				end
			end

			setmetatable(module, prototype_mt)

			return module
		end
	end
end

local lib = LibStub("LibBabble-3.0"):New(MAJOR_VERSION, MINOR_VERSION)
if not lib then
	return
end

lib:SetBaseTranslations {
--Ahn'Qiraj
	["Anubisath Defender"] = true,
	["Battleguard Sartura"] = true,
	["C'Thun"] = true,
	["Emperor Vek'lor"] = true,
	["Emperor Vek'nilash"] = true,
	["Eye of C'Thun"] = true,
	["Fankriss the Unyielding"] = true,
	["Lord Kri"] = true,
	["Ouro"] = true,
	["Princess Huhuran"] = true,
	["Princess Yauj"] = true,
	["The Bug Family"] = true,
	["The Prophet Skeram"] = true,
	["The Twin Emperors"] = true,
	["Vem"] = true,
	["Viscidus"] = true,

--Auchindoun
--Auchenai Crypts
	["Exarch Maladaar"] = true,
	["Shirrak the Dead Watcher"] = true,
--Mana-Tombs
	["Nexus-Prince Shaffar"] = true,
	["Pandemonius"] = true,
	["Tavarok"] = true,
--Shadow Labyrinth
	["Ambassador Hellmaw"] = true,
	["Blackheart the Inciter"] = true,
	["Grandmaster Vorpil"] = true,
	["Murmur"] = true,
--Sethekk Halls
	["Anzu"] = true,
	["Darkweaver Syth"] = true,
	["Talon King Ikiss"] = true,

--Blackfathom Deeps
	["Aku'mai"] = true,
	["Baron Aquanis"] = true,
	["Gelihast"] = true,
	["Ghamoo-ra"] = true,
	["Lady Sarevess"] = true,
	["Old Serra'kis"] = true,
	["Twilight Lord Kelris"] = true,

--Blackrock Depths
	["Ambassador Flamelash"] = true,
	["Anger'rel"] = true,
	["Anub'shiah"] = true,
	["Bael'Gar"] = true,
	["Chest of The Seven"] = true,
	["Doom'rel"] = true,
	["Dope'rel"] = true,
	["Emperor Dagran Thaurissan"] = true,
	["Eviscerator"] = true,
	["Fineous Darkvire"] = true,
	["General Angerforge"] = true,
	["Gloom'rel"] = true,
	["Golem Lord Argelmach"] = true,
	["Gorosh the Dervish"] = true,
	["Grizzle"] = true,
	["Hate'rel"] = true,
	["Hedrum the Creeper"] = true,
	["High Interrogator Gerstahn"] = true,
	["High Priestess of Thaurissan"] = true,
	["Houndmaster Grebmar"] = true,
	["Hurley Blackbreath"] = true,
	["Lord Incendius"] = true,
	["Lord Roccor"] = true,
	["Magmus"] = true,
	["Ok'thor the Breaker"] = true,
	["Panzor the Invincible"] = true,
	["Phalanx"] = true,
	["Plugger Spazzring"] = true,
	["Princess Moira Bronzebeard"] = true,
	["Pyromancer Loregrain"] = true,
	["Ribbly Screwspigot"] = true,
	["Seeth'rel"] = true,
	["The Seven Dwarves"] = true,
	["Verek"] = true,
	["Vile'rel"] = true,
	["Warder Stilgiss"] = true,

--Blackrock Spire
--Lower
	["Bannok Grimaxe"] = true,
	["Burning Felguard"] = true,
	["Crystal Fang"] = true,
	["Ghok Bashguud"] = true,
	["Gizrul the Slavener"] = true,
	["Halycon"] = true,
	["Highlord Omokk"] = true,
	["Mor Grayhoof"] = true,
	["Mother Smolderweb"] = true,
	["Overlord Wyrmthalak"] = true,
	["Quartermaster Zigris"] = true,
	["Shadow Hunter Vosh'gajin"] = true,
	["Spirestone Battle Lord"] = true,
	["Spirestone Butcher"] = true,
	["Spirestone Lord Magus"] = true,
	["Urok Doomhowl"] = true,
	["War Master Voone"] = true,
--Upper
	["General Drakkisath"] = true,
	["Goraluk Anvilcrack"] = true,
	["Gyth"] = true,
	["Jed Runewatcher"] = true,
	["Lord Valthalak"] = true,
	["Pyroguard Emberseer"] = true,
	["Solakar Flamewreath"] = true,
	["The Beast"] = true,
	["Warchief Rend Blackhand"] = true,

--Blackwing Lair
	["Broodlord Lashlayer"] = true,
	["Chromaggus"] = true,
	["Ebonroc"] = true,
	["Firemaw"] = true,
	["Flamegor"] = true,
	["Grethok the Controller"] = true,
	["Lord Victor Nefarius"] = true,
	["Nefarian"] = true,
	["Razorgore the Untamed"] = true,
	["Vaelastrasz the Corrupt"] = true,

--Black Temple
	["Essence of Anger"] = true,
	["Essence of Desire"] = true,
	["Essence of Suffering"] = true,
	["Gathios the Shatterer"] = true,
	["Gurtogg Bloodboil"] = true,
	["High Nethermancer Zerevor"] = true,
	["High Warlord Naj'entus"] = true,
	["Illidan Stormrage"] = true,
	["Illidari Council"] = true,
	["Lady Malande"] = true,
	["Mother Shahraz"] = true,
	["Reliquary of Souls"] = true,
	["Shade of Akama"] = true,
	["Supremus"] = true,
	["Teron Gorefiend"] = true,
	["The Illidari Council"] = true,
	["Veras Darkshadow"] = true,

--Caverns of Time
--Old Hillsbrad Foothills
	["Captain Skarloc"] = true,
	["Epoch Hunter"] = true,
	["Lieutenant Drake"] = true,
--The Black Morass
	["Aeonus"] = true,
	["Chrono Lord Deja"] = true,
	["Medivh"] = true,
	["Temporus"] = true,

--Coilfang Reservoir
--Serpentshrine Cavern
	["Coilfang Elite"] = true,
	["Coilfang Strider"] = true,
	["Fathom-Lord Karathress"] = true,
	["Hydross the Unstable"] = true,
	["Lady Vashj"] = true,
	["Leotheras the Blind"] = true,
	["Morogrim Tidewalker"] = true,
	["Pure Spawn of Hydross"] = true,
	["Shadow of Leotheras"] = true,
	["Tainted Spawn of Hydross"] = true,
	["The Lurker Below"] = true,
	["Tidewalker Lurker"] = true,
--The Slave Pens
	["Mennu the Betrayer"] = true,
	["Quagmirran"] = true,
	["Rokmar the Crackler"] = true,
--The Steamvault
	["Hydromancer Thespia"] = true,
	["Mekgineer Steamrigger"] = true,
	["Warlord Kalithresh"] = true,
--The Underbog
	["Claw"] = true,
	["Ghaz'an"] = true,
	["Hungarfen"] = true,
	["Overseer Tidewrath"] = true,
	["Swamplord Musel'ek"] = true,
	["The Black Stalker"] = true,

--Dire Maul
--Arena
	["Mushgog"] = true,
	["Skarr the Unbreakable"] = true,
	["The Razza"] = true,
--East
	["Alzzin the Wildshaper"] = true,
	["Hydrospawn"] = true,
	["Isalien"] = true,
	["Lethtendris"] = true,
	["Pimgib"] = true,
	["Pusillin"] = true,
	["Zevrim Thornhoof"] = true,
--North
	["Captain Kromcrush"] = true,
	["Cho'Rush the Observer"] = true,
	["Guard Fengus"] = true,
	["Guard Mol'dar"] = true,
	["Guard Slip'kik"] = true,
	["King Gordok"] = true,
	["Knot Thimblejack's Cache"] = true,
	["Stomper Kreeg"] = true,
--West
	["Illyanna Ravenoak"] = true,
	["Immol'thar"] = true,
	["Lord Hel'nurath"] = true,
	["Magister Kalendris"] = true,
	["Prince Tortheldrin"] = true,
	["Tendris Warpwood"] = true,
	["Tsu'zee"] = true,

--Gnomeregan
	["Crowd Pummeler 9-60"] = true,
	["Dark Iron Ambassador"] = true,
	["Electrocutioner 6000"] = true,
	["Grubbis"] = true,
	["Mekgineer Thermaplugg"] = true,
	["Techbot"] = true,
	["Viscous Fallout"] = true,

--Gruul's Lair
	["Blindeye the Seer"] = true,
	["Gruul the Dragonkiller"] = true,
	["High King Maulgar"] = true,
	["Kiggler the Crazed"] = true,
	["Krosh Firehand"] = true,
	["Olm the Summoner"] = true,

--Hellfire Citadel
--Hellfire Ramparts
	["Nazan"] = true,
	["Omor the Unscarred"] = true,
	["Vazruden the Herald"] = true,
	["Vazruden"] = true,
	["Watchkeeper Gargolmar"] = true,
--Magtheridon's Lair
	["Hellfire Channeler"] = true,
	["Magtheridon"] = true,
--The Blood Furnace
	["Broggok"] = true,
	["Keli'dan the Breaker"] = true,
	["The Maker"] = true,
--The Shattered Halls
	["Blood Guard Porung"] = true,
	["Grand Warlock Nethekurse"] = true,
	["Warbringer O'mrogg"] = true,
	["Warchief Kargath Bladefist"] = true,

--Hyjal Summit
	["Anetheron"] = true,
	["Archimonde"] = true,
	["Azgalor"] = true,
	["Kaz'rogal"] = true,
	["Rage Winterchill"] = true,

--Karazhan
	["Arcane Watchman"] = true,
	["Attumen the Huntsman"] = true,
	["Chess Event"] = true,
	["Dorothee"] = true,
	["Dust Covered Chest"] = true,
	["Grandmother"] = true,
	["Hyakiss the Lurker"] = true,
	["Julianne"] = true,
	["Kil'rek"] = true,
	["King Llane Piece"] = true,
	["Maiden of Virtue"] = true,
	["Midnight"] = true,
	["Moroes"] = true,
	["Netherspite"] = true,
	["Nightbane"] = true,
	["Prince Malchezaar"] = true,
	["Restless Skeleton"] = true,
	["Roar"] = true,
	["Rokad the Ravager"] = true,
	["Romulo & Julianne"] = true,
	["Romulo"] = true,
	["Shade of Aran"] = true,
	["Shadikith the Glider"] = true,
	["Strawman"] = true,
	["Terestian Illhoof"] = true,
	["The Big Bad Wolf"] = true,
	["The Crone"] = true,
	["The Curator"] = true,
	["Tinhead"] = true,
	["Tito"] = true,
	["Warchief Blackhand Piece"] = true,

-- Magisters' Terrace
	--["Kael'thas Sunstrider"] = true,
	["Priestess Delrissa"] = true,
	["Selin Fireheart"] = true,
	["Vexallus"] = true,

--Maraudon
	["Celebras the Cursed"] = true,
	["Gelk"] = true,
	["Kolk"] = true,
	["Landslide"] = true,
	["Lord Vyletongue"] = true,
	["Magra"] = true,
	["Maraudos"] = true,
	["Meshlok the Harvester"] = true,
	["Noxxion"] = true,
	["Princess Theradras"] = true,
	["Razorlash"] = true,
	["Rotgrip"] = true,
	["Tinkerer Gizlock"] = true,
	["Veng"] = true,

--Molten Core
	["Baron Geddon"] = true,
	["Cache of the Firelord"] = true,
	["Garr"] = true,
	["Gehennas"] = true,
	["Golemagg the Incinerator"] = true,
	["Lucifron"] = true,
	["Magmadar"] = true,
	["Majordomo Executus"] = true,
	["Ragnaros"] = true,
	["Shazzrah"] = true,
	["Sulfuron Harbinger"] = true,

--Naxxramas
	["Anub'Rekhan"] = true,
	["Deathknight Understudy"] = true,
	["Feugen"] = true,
	["Four Horsemen Chest"] = true,
	["Gluth"] = true,
	["Gothik the Harvester"] = true,
	["Grand Widow Faerlina"] = true,
	["Grobbulus"] = true,
	["Heigan the Unclean"] = true,
	["Highlord Mograine"] = true,
	["Instructor Razuvious"] = true,
	["Kel'Thuzad"] = true,
	["Lady Blaumeux"] = true,
	["Loatheb"] = true,
	["Maexxna"] = true,
	["Noth the Plaguebringer"] = true,
	["Patchwerk"] = true,
	["Sapphiron"] = true,
	["Sir Zeliek"] = true,
	["Stalagg"] = true,
	["Thaddius"] = true,
	["Thane Korth'azz"] = true,
	["The Four Horsemen"] = true,

--Onyxia's Lair
	["Onyxia"] = true,

--Ragefire Chasm
	["Bazzalan"] = true,
	["Jergosh the Invoker"] = true,
	["Maur Grimtotem"] = true,
	["Taragaman the Hungerer"] = true,

--Razorfen Downs
	["Amnennar the Coldbringer"] = true,
	["Glutton"] = true,
	["Mordresh Fire Eye"] = true,
	["Plaguemaw the Rotting"] = true,
	["Ragglesnout"] = true,
	["Tuten'kash"] = true,

--Razorfen Kraul
	["Agathelos the Raging"] = true,
	["Blind Hunter"] = true,
	["Charlga Razorflank"] = true,
	["Death Speaker Jargba"] = true,
	["Earthcaller Halmgar"] = true,
	["Overlord Ramtusk"] = true,

--Ruins of Ahn'Qiraj
	["Anubisath Guardian"] = true,
	["Ayamiss the Hunter"] = true,
	["Buru the Gorger"] = true,
	["General Rajaxx"] = true,
	["Kurinnaxx"] = true,
	["Lieutenant General Andorov"] = true,
	["Moam"] = true,
	["Ossirian the Unscarred"] = true,

--Scarlet Monastery
--Armory
	["Herod"] = true,
--Cathedral
	["High Inquisitor Fairbanks"] = true,
	["High Inquisitor Whitemane"] = true,
	["Scarlet Commander Mograine"] = true,
--Graveyard
	["Azshir the Sleepless"] = true,
	["Bloodmage Thalnos"] = true,
	["Fallen Champion"] = true,
	["Interrogator Vishas"] = true,
	["Ironspine"] = true,
--Library
	["Arcanist Doan"] = true,
	["Houndmaster Loksey"] = true,

--Scholomance
	["Blood Steward of Kirtonos"] = true,
	["Darkmaster Gandling"] = true,
	["Death Knight Darkreaver"] = true,
	["Doctor Theolen Krastinov"] = true,
	["Instructor Malicia"] = true,
	["Jandice Barov"] = true,
	["Kirtonos the Herald"] = true,
	["Kormok"] = true,
	["Lady Illucia Barov"] = true,
	["Lord Alexei Barov"] = true,
	["Lorekeeper Polkelt"] = true,
	["Marduk Blackpool"] = true,
	["Ras Frostwhisper"] = true,
	["Rattlegore"] = true,
	["The Ravenian"] = true,
	["Vectus"] = true,

--Shadowfang Keep
	["Archmage Arugal"] = true,
	["Arugal's Voidwalker"] = true,
	["Baron Silverlaine"] = true,
	["Commander Springvale"] = true,
	["Deathsworn Captain"] = true,
	["Fenrus the Devourer"] = true,
	["Odo the Blindwatcher"] = true,
	["Razorclaw the Butcher"] = true,
	["Wolf Master Nandos"] = true,

--Stratholme
	["Archivist Galford"] = true,
	["Balnazzar"] = true,
	["Baron Rivendare"] = true,
	["Baroness Anastari"] = true,
	["Black Guard Swordsmith"] = true,
	["Cannon Master Willey"] = true,
	["Crimson Hammersmith"] = true,
	["Fras Siabi"] = true,
	["Hearthsinger Forresten"] = true,
	["Magistrate Barthilas"] = true,
	["Maleki the Pallid"] = true,
	["Nerub'enkan"] = true,
	["Postmaster Malown"] = true,
	["Ramstein the Gorger"] = true,
	["Skul"] = true,
	["Stonespine"] = true,
	["The Unforgiven"] = true,
	["Timmy the Cruel"] = true,

--Sunwell Plateau
	["Kalecgos"] = true,
	["Sathrovarr the Corruptor"] = true,
	["Brutallus"] = true,
	["Felmyst"] = true,
	["Kil'jaeden"] = true,
	["M'uru"] = true,
	["Entropius"] = true,
	["The Eredar Twins"] = true,
	["Lady Sacrolash"] = true,
	["Grand Warlock Alythess"] = true,

--Tempest Keep
--The Arcatraz
	["Dalliah the Doomsayer"] = true,
	["Harbinger Skyriss"] = true,
	["Warden Mellichar"] = true,
	["Wrath-Scryer Soccothrates"] = true,
	["Zereketh the Unbound"] = true,
--The Botanica
	["Commander Sarannis"] = true,
	["High Botanist Freywinn"] = true,
	["Laj"] = true,
	["Thorngrin the Tender"] = true,
	["Warp Splinter"] = true,
--The Eye
	["Al'ar"] = true,
	["Cosmic Infuser"] = true,
	["Devastation"] = true,
	["Grand Astromancer Capernian"] = true,
	["High Astromancer Solarian"] = true,
	["Infinity Blades"] = true,
	["Kael'thas Sunstrider"] = true,
	["Lord Sanguinar"] = true,
	["Master Engineer Telonicus"] = true,
	["Netherstrand Longbow"] = true,
	["Phaseshift Bulwark"] = true,
	["Solarium Agent"] = true,
	["Solarium Priest"] = true,
	["Staff of Disintegration"] = true,
	["Thaladred the Darkener"] = true,
	["Void Reaver"] = true,
	["Warp Slicer"] = true,
--The Mechanar
	["Gatewatcher Gyro-Kill"] = true,
	["Gatewatcher Iron-Hand"] = true,
	["Mechano-Lord Capacitus"] = true,
	["Nethermancer Sepethrea"] = true,
	["Pathaleon the Calculator"] = true,

--The Deadmines
	["Brainwashed Noble"] = true,
	["Captain Greenskin"] = true,
	["Cookie"] = true,
	["Edwin VanCleef"] = true,
	["Foreman Thistlenettle"] = true,
	["Gilnid"] = true,
	["Marisa du'Paige"] = true,
	["Miner Johnson"] = true,
	["Mr. Smite"] = true,
	["Rhahk'Zor"] = true,
	["Sneed"] = true,
	["Sneed's Shredder"] = true,

--The Stockade
	["Bazil Thredd"] = true,
	["Bruegal Ironknuckle"] = true,
	["Dextren Ward"] = true,
	["Hamhock"] = true,
	["Kam Deepfury"] = true,
	["Targorr the Dread"] = true,

--The Temple of Atal'Hakkar
	["Atal'alarion"] = true,
	["Avatar of Hakkar"] = true,
	["Dreamscythe"] = true,
	["Gasher"] = true,
	["Hazzas"] = true,
	["Hukku"] = true,
	["Jade"] = true,
	["Jammal'an the Prophet"] = true,
	["Kazkaz the Unholy"] = true,
	["Loro"] = true,
	["Mijan"] = true,
	["Morphaz"] = true,
	["Ogom the Wretched"] = true,
	["Shade of Eranikus"] = true,
	["Veyzhak the Cannibal"] = true,
	["Weaver"] = true,
	["Zekkis"] = true,
	["Zolo"] = true,
	["Zul'Lor"] = true,

--Uldaman
	["Ancient Stone Keeper"] = true,
	["Archaedas"] = true,
	["Baelog"] = true,
	["Digmaster Shovelphlange"] = true,
	["Galgann Firehammer"] = true,
	["Grimlok"] = true,
	["Ironaya"] = true,
	["Obsidian Sentinel"] = true,
	["Revelosh"] = true,

--Wailing Caverns
	["Boahn"] = true,
	["Deviate Faerie Dragon"] = true,
	["Kresh"] = true,
	["Lady Anacondra"] = true,
	["Lord Cobrahn"] = true,
	["Lord Pythas"] = true,
	["Lord Serpentis"] = true,
	["Mad Magglish"] = true,
	["Mutanus the Devourer"] = true,
	["Skum"] = true,
	["Trigore the Lasher"] = true,
	["Verdan the Everliving"] = true,

--World Bosses
	["Avalanchion"] = true,
	["Azuregos"] = true,
	["Baron Charr"] = true,
	["Baron Kazum"] = true,
	["Doom Lord Kazzak"] = true,
	["Doomwalker"] = true,
	["Emeriss"] = true,
	["High Marshal Whirlaxis"] = true,
	["Lethon"] = true,
	["Lord Skwol"] = true,
	["Prince Skaldrenox"] = true,
	["Princess Tempestria"] = true,
	["Taerar"] = true,
	["The Windreaver"] = true,
	["Ysondre"] = true,

--Zul'Aman
	["Akil'zon"] = true,
	["Halazzi"] = true,
	["Jan'alai"] = true,
	["Malacrass"] = true,
	["Nalorakk"] = true,
	["Zul'jin"] = true,
	["Hex Lord Malacrass"] = true,

--Zul'Farrak
	["Antu'sul"] = true,
	["Chief Ukorz Sandscalp"] = true,
	["Dustwraith"] = true,
	["Gahz'rilla"] = true,
	["Hydromancer Velratha"] = true,
	["Murta Grimgut"] = true,
	["Nekrum Gutchewer"] = true,
	["Oro Eyegouge"] = true,
	["Ruuzlu"] = true,
	["Sandarr Dunereaver"] = true,
	["Sandfury Executioner"] = true,
	["Sergeant Bly"] = true,
	["Shadowpriest Sezz'ziz"] = true,
	["Theka the Martyr"] = true,
	["Witch Doctor Zum'rah"] = true,
	["Zerillis"] = true,
	["Zul'Farrak Dead Hero"] = true,

--Zul'Gurub
	["Bloodlord Mandokir"] = true,
	["Gahz'ranka"] = true,
	["Gri'lek"] = true,
	["Hakkar"] = true,
	["Hazza'rah"] = true,
	["High Priest Thekal"] = true,
	["High Priest Venoxis"] = true,
	["High Priestess Arlokk"] = true,
	["High Priestess Jeklik"] = true,
	["High Priestess Mar'li"] = true,
	["Jin'do the Hexxer"] = true,
	["Renataki"] = true,
	["Wushoolay"] = true,

--Ring of Blood (where? an instance? should be in other file?)
	["Brokentoe"] = true,
	["Mogor"] = true,
	["Murkblood Twin"] = true,
	["Murkblood Twins"] = true,
	["Rokdar the Sundered Lord"] = true,
	["Skra'gath"] = true,
	["The Blue Brothers"] = true,
	["Warmaul Champion"] = true,
}

if GAME_LOCALE == "enUS" then
	lib:SetCurrentTranslations(true)
elseif GAME_LOCALE == "deDE" then
	lib:SetCurrentTranslations {
--Ahn'Qiraj
		["Anubisath Defender"] = "Verteidiger des Anubisath",
		["Battleguard Sartura"] = "Schlachtwache Sartura",
		["C'Thun"] = "C'Thun",
		["Emperor Vek'lor"] = "Imperator Vek'lor",
		["Emperor Vek'nilash"] = "Imperator Vek'nilash",
		["Eye of C'Thun"] = "Auge von C'Thun",
		["Fankriss the Unyielding"] = "Fankriss der Unnachgiebige",
		["Lord Kri"] = "Lord Kri",
		["Ouro"] = "Ouro",
		["Princess Huhuran"] = "Prinzessin Huhuran",
		["Princess Yauj"] = "Prinzessin Yauj",
		["The Bug Family"] = "Die Käferfamilie",
		["The Prophet Skeram"] = "Der Prophet Skeram",
		["The Twin Emperors"] = "Die Zwillings-Imperatoren",
		["Vem"] = "Vem",
		["Viscidus"] = "Viscidus",

--Auchindoun
--Auchenai Crypts
		["Exarch Maladaar"] = "Exarch Maladaar",
		["Shirrak the Dead Watcher"] = "Shirrak der Totenwächter",
--Mana-Tombs
		["Nexus-Prince Shaffar"] = "Nexusprinz Shaffar",
		["Pandemonius"] = "Pandemonius",
		["Tavarok"] = "Tavarok",
--Shadow Labyrinth
		["Ambassador Hellmaw"] = "Botschafter Höllenschlund",
		["Blackheart the Inciter"] = "Schwarzherz der Hetzer",
		["Grandmaster Vorpil"] = "Großmeister Vorpil",
		["Murmur"] = "Murmur",
--Sethekk Halls
		["Anzu"] = "Anzu",
		["Darkweaver Syth"] = "Dunkelwirker Syth",
		["Talon King Ikiss"] = "Klauenkönig Ikiss",

--Blackfathom Deeps
		["Aku'mai"] = "Aku'mai",
		["Baron Aquanis"] = "Baron Aquanis",
		["Gelihast"] = "Gelihast",
		["Ghamoo-ra"] = "Ghamoo-ra",
		["Lady Sarevess"] = "Lady Sarevess",
		["Old Serra'kis"] = "Old Serra'kis",
		["Twilight Lord Kelris"] = "Lord des Schattenhammers Kelris",

--Blackrock Depths
		["Ambassador Flamelash"] = "Botschafter Flammenschlag",
		["Anger'rel"] = "Anger'rel",
		["Anub'shiah"] = "Anub'shiah",
		["Bael'Gar"] = "Bael'Gar",
		["Chest of The Seven"] = "Truhe der Sieben",
		["Doom'rel"] = "Un'rel",
		["Dope'rel"] = "Trott'rel",
		["Emperor Dagran Thaurissan"] = "Imperator Dagran Thaurissan",
		["Eviscerator"] = "Ausweider",
		["Fineous Darkvire"] = "Fineous Dunkelader",
		["General Angerforge"] = "General Zornesschmied",
		["Gloom'rel"] = "Dunk'rel",
		["Golem Lord Argelmach"] = "Golemlord Argelmach",
		["Gorosh the Dervish"] = "Gorosh der Derwisch",
		["Grizzle"] = "Grizzle",
		["Hate'rel"] = "Hass'rel",
		["Hedrum the Creeper"] = "Hedrum der Krabbler",
		["High Interrogator Gerstahn"] = "Verhörmeisterin Gerstahn",
		["High Priestess of Thaurissan"] = "	Hohepriesterin von Thaurissan",
		["Houndmaster Grebmar"] = "Hundemeister Grebmar",
		["Hurley Blackbreath"] = "Hurley Pestatem",
		["Lord Incendius"] = "Lord Incendius",
		["Lord Roccor"] = "Lord Roccor",
		["Magmus"] = "Magmus",
		["Ok'thor the Breaker"] = "Ok'thor der Zerstörer",
		["Panzor the Invincible"] = "Panzor der Unbesiegbare",
		["Phalanx"] = "Phalanx",
		["Plugger Spazzring"] = "Stöpsel Zapfring",
		["Princess Moira Bronzebeard"] = "Prinzessin Moira Bronzebeard",
		["Pyromancer Loregrain"] = "Pyromant Weisenkorn",
		["Ribbly Screwspigot"] = "Ribbly Schraubstutz",
		["Seeth'rel"] = "Wut'rel",
		["The Seven Dwarves"] = "Die Sieben Zwerge",
		["Verek"] = "Verek",
		["Vile'rel"] = "Bös'rel",
		["Warder Stilgiss"] = "	Wärter Stilgiss",

--Blackrock Spire
--Lower
		["Bannok Grimaxe"] = "Bannok Grimmaxt",
		["Burning Felguard"] = "Brennende Teufelswache",
		["Crystal Fang"] = "Kristallfangzahn",
		["Ghok Bashguud"] = "Ghok Haudrauf",
		["Gizrul the Slavener"] = "Gizrul der Geifernde",
		["Halycon"] = "Halycon",
		["Highlord Omokk"] = "Hochlord Omokk",
		["Mor Grayhoof"] = "Mor Grauhuf",
		["Mother Smolderweb"] = "Mutter Glimmernetz",
		["Overlord Wyrmthalak"] = "Oberanführer Wyrmthalak",
		["Quartermaster Zigris"] = "Rüstmeister Zigris",
		["Shadow Hunter Vosh'gajin"] = "Schattenjägerin Vosh'gajin",
		["Spirestone Battle Lord"] = "Kampflord der Felsspitzoger",
		["Spirestone Butcher"] = "Metzger der Felsspitzoger",
		["Spirestone Lord Magus"] = "Maguslord der Felsspitzoger",
		["Urok Doomhowl"] = "Urok Schreckensbote",
		["War Master Voone"] = "Kriegsmeister Voone",
--Upper
		["General Drakkisath"] = "General Drakkisath",
		["Goraluk Anvilcrack"] = "Goraluk Hammerbruch",
		["Gyth"] = "Gyth",
		["Jed Runewatcher"] = "Jed Runenblick",
		["Lord Valthalak"] = "Lord Valthalak",
		["Pyroguard Emberseer"] = "Feuerwache Glutseher",
		["Solakar Flamewreath"] = "Solakar Feuerkrone",
		["The Beast"] = "Die Bestie",
		["Warchief Rend Blackhand"] = "Kriegshäuptling Rend Schwarzfaust",

--Blackwing Lair
		["Broodlord Lashlayer"] = "Brutwächter Dreschbringer",
		["Chromaggus"] = "Chromaggus",
		["Ebonroc"] = "Schattenschwinge",
		["Firemaw"] = "Feuerschwinge",
		["Flamegor"] = "Flammenmaul",
		["Grethok the Controller"] = "Grethok der Aufseher",
		["Lord Victor Nefarius"] = "Lord Victor Nefarius",
		["Nefarian"] = "Nefarian",
		["Razorgore the Untamed"] = "Razorgore der Ungezähmte",
		["Vaelastrasz the Corrupt"] = "Vaelastrasz der Verdorbene",

--Black Temple
		["Essence of Anger"] = "Essenz des Zorns",
		["Essence of Desire"] = "Essenz der Begierde",
		["Essence of Suffering"] = "Essenz des Leidens",
		["Gathios the Shatterer"] = "Gathios der Zerschmetterer",
		["Gurtogg Bloodboil"] = "Gurtogg Siedeblut",
		["High Nethermancer Zerevor"] = "Hochnethermant Zerevor",
		["High Warlord Naj'entus"] = "Oberster Kriegsfürst Naj'entus",
		["Illidan Stormrage"] = "Illidan Sturmgrimm",
		["Illidari Council"] = "Rat der Illidari",
		["Lady Malande"] = "Lady Malande",
		["Mother Shahraz"] = "Mutter Shahraz",
		["Reliquary of Souls"] = "Reliquium der Seelen",
		["Shade of Akama"] = "Akamas Schemen",
		["Supremus"] = "Supremus",
		["Teron Gorefiend"] = "Teron Blutschatten",
		["The Illidari Council"] = "Rat der Illidari",
		["Veras Darkshadow"] = "Veras Schwarzschatten",

--Caverns of Time
--Old Hillsbrad Foothills
		["Captain Skarloc"] = "Kapitän Skarloc",
		["Epoch Hunter"] = "Epochenjäger",
		["Lieutenant Drake"] = "Leutnant Drach",
--The Black Morass
		["Aeonus"] = "Aeonus",
		["Chrono Lord Deja"] = "Chronolord Deja",
		["Medivh"] = "Medivh",
		["Temporus"] = "Temporus",

--Coilfang Reservoir
--Serpentshrine Cavern
		["Coilfang Elite"] = "Elitesoldat des Echsenkessels",
		["Coilfang Strider"] = "Schreiter des Echsenkessels",
		["Fathom-Lord Karathress"] = "Tiefenlord Karathress",
		["Hydross the Unstable"] = "Hydross der Unstete",
		["Lady Vashj"] = "Lady Vashj",
		["Leotheras the Blind"] = "Leotheras der Blinde",
		["Morogrim Tidewalker"] = "Morogrim Gezeitenwandler",
		["Pure Spawn of Hydross"] = "Gereinigter Nachkomme Hydross'",
		["Shadow of Leotheras"] = "Schatten von Leotheras",
		["Tainted Spawn of Hydross"] = "Besudelter Nachkomme Hydross'",
		["The Lurker Below"] = "Das Grauen aus der Tiefe",
		["Tidewalker Lurker"] = "Lauerer der Gezeitenwandler",
--The Slave Pens
		["Mennu the Betrayer"] = "Mennu der Verräter",
		["Quagmirran"] = "Quagmirran",
		["Rokmar the Crackler"] = "Rokmar der Zerquetscher",
--The Steamvault
		["Hydromancer Thespia"] = "Wasserbeschwörerin Thespia",
		["Mekgineer Steamrigger"] = "Robogenieur Dampfhammer",
		["Warlord Kalithresh"] = "Kriegsherr Kalithresh",
--The Underbog
		["Claw"] = "Klaue",
		["Ghaz'an"] = "Ghaz'an",
		["Hungarfen"] = "Hungarfenn",
		["Overseer Tidewrath"] = "Overseer Tidewrath",
		["Swamplord Musel'ek"] = "Sumpffürst Musel'ek",
		["The Black Stalker"] = "Die Schattenmutter",

--Dire Maul
--Arena
		["Mushgog"] = "Mushgog",
		["Skarr the Unbreakable"] = "Skarr der Unbezwingbare",
		["The Razza"] = "Der Razza",
--East
		["Alzzin the Wildshaper"] = "Alzzin der Wildformer",
		["Hydrospawn"] = "Hydrobrut",
		["Isalien"] = "Isalien",
		["Lethtendris"] = "Lethtendris",
		["Pimgib"] = "Pimgib",
		["Pusillin"] = "Pusillin",
		["Zevrim Thornhoof"] = "Zevrim Dornhuf",
--North
		["Captain Kromcrush"] = "Hauptmann Krombruch",
		["Cho'Rush the Observer"] = "Cho'Rush der Beobachter",
		["Guard Fengus"] = "Wache Fengus",
		["Guard Mol'dar"] = "Wache Mol'dar",
		["Guard Slip'kik"] = "Wache Slip'kik",
		["King Gordok"] = "König Gordok",
		["Knot Thimblejack's Cache"] = "Knot Thimblejacks Truhe",
		["Stomper Kreeg"] = "Stampfer Kreeg",
--West
		["Illyanna Ravenoak"] = "Illyanna Rabeneiche",
		["Immol'thar"] = "Immol'thar",
		["Lord Hel'nurath"] = "Lord Hel'nurath",
		["Magister Kalendris"] = "Magister Kalendris",
		["Prince Tortheldrin"] = "Prinz Tortheldrin",
		["Tendris Warpwood"] = "Tendris Wucherborke",
		["Tsu'zee"] = "Tsu'zee",

--Gnomeregan
		["Crowd Pummeler 9-60"] = "Meuteverprügler 9-60",
		["Dark Iron Ambassador"] = "Botschafter der Dunkeleisenzwerge",
		["Electrocutioner 6000"] = "Elektrokutor 6000",
		["Grubbis"] = "Grubbis",
		["Mekgineer Thermaplugg"] = "Robogenieur Thermadraht",
		["Techbot"] = "Techbot",
		["Viscous Fallout"] = "Verflüssigte Ablagerung",

--Gruul's Lair
		["Blindeye the Seer"] = "Blindauge der Seher",
		["Gruul the Dragonkiller"] = "Gruul der Drachenschlächter",
		["High King Maulgar"] = "Hochkönig Maulgar",
		["Kiggler the Crazed"] = "Kiggler the Crazed",
		["Krosh Firehand"] = "Krosh Feuerhand",
		["Olm the Summoner"] = "Olm der Beschwörer",

--Hellfire Citadel
--Hellfire Ramparts
		["Nazan"] = "Nazan",
		["Omor the Unscarred"] = "Omor der Narbenlose",
		["Vazruden the Herald"] = "Vazruden der Herold",
		["Vazruden"] = "Vazruden",
		["Watchkeeper Gargolmar"] = "Wachhabender Gargolmar",
--Magtheridon's Lair
		["Hellfire Channeler"] = "Kanalisierer des Höllenfeuers",
		["Magtheridon"] = "Magtheridon",
--The Blood Furnace
		["Broggok"] = "Broggok",
		["Keli'dan the Breaker"] = "Keli'dan der Zerstörer",
		["The Maker"] = "Der Schöpfer",
--The Shattered Halls
		["Blood Guard Porung"] = "Blutwache Porung",
		["Grand Warlock Nethekurse"] = "Großhexenmeister Nethekurse",
		["Warbringer O'mrogg"] = "Kriegshetzer O'mrogg",
		["Warchief Kargath Bladefist"] = "Kriegshäuptling Kargath Messerfaust",

--Hyjal Summit
		["Anetheron"] = "Anetheron",
		["Archimonde"] = "Archimonde",
		["Azgalor"] = "Azgalor",
		["Kaz'rogal"] = "Kaz'rogal",
		["Rage Winterchill"] = "Furor Winterfrost",

--Karazhan
		["Arcane Watchman"] = "Arkanwachmann",
		["Attumen the Huntsman"] = "Attumen der Jäger",
		["Chess Event"] = "Chess Event",
		["Dorothee"] = "Dorothee",
		["Dust Covered Chest"] = "Staub Bedeckter Kasten",
		["Grandmother"] = "Großmutter",
		["Hyakiss the Lurker"] = "Hyakiss der Lauerer",
		["Julianne"] = "Julianne",
		["Kil'rek"] = "Kil'rek",
		["King Llane Piece"] = "König Llane",
		["Maiden of Virtue"] = "Tugendhafte Maid",
		["Midnight"] = "Mittnacht",
		["Moroes"] = "Moroes",
		["Netherspite"] = "Nethergroll",
		["Nightbane"] = "Schrecken der Nacht",
		["Prince Malchezaar"] = "Prinz Malchezaar",
		["Restless Skeleton"] = "Ruheloses Skelett",
		["Roar"] = "Brüller",
		["Rokad the Ravager"] = "Rokad der Verheerer",
		["Romulo & Julianne"] = "Romulo & Julianne",
		["Romulo"] = "Romulo",
		["Shade of Aran"] = "Arans Schemen",
		["Shadikith the Glider"] = "Shadikith der Segler",
		["Strawman"] = "Strohmann",
		["Terestian Illhoof"] = "Terestian Siechhuf",
		["The Big Bad Wolf"] = "Der große böse Wolf",
		["The Crone"] = "Die böse Hexe",
		["The Curator"] = "Der Kurator",
		["Tinhead"] = "Blechkopf",
		["Tito"] = "Tito",
		["Warchief Blackhand Piece"] = "Kriegshäuptling Schwarzfaust",

-- Magisters' Terrace
		["Kael'thas Sunstrider"] = "Kael'thas Sonnenwanderer",
		["Priestess Delrissa"] = "Priesterin Delrissa",
		["Selin Fireheart"] = "Selin Feuerherz",
		["Vexallus"] = "Vexallus",

--Maraudon
		["Celebras the Cursed"] = "Celebras der Verfluchte",
		["Gelk"] = "Gelk",
		["Kolk"] = "Kolk",
		["Landslide"] = "Erdrutsch",
		["Lord Vyletongue"] = "Lord Schlangenzunge",
		["Magra"] = "Magra",
		["Maraudos"] = "Maraudos",
		["Meshlok the Harvester"] = "Meshlok der Ernter",
		["Noxxion"] = "Noxxion",
		["Princess Theradras"] = "Prinzessin Theradras",
		["Razorlash"] = "Schlingwurzler",
		["Rotgrip"] = "Faulschnapper",
		["Tinkerer Gizlock"] = "Tüftler Gizlock",
		["Veng"] = "Veng",

--Molten Core
		["Baron Geddon"] = "Baron Geddon",
		["Cache of the Firelord"] = "Truhe des Feuerlords",
		["Garr"] = "Garr",
		["Gehennas"] = "Gehennas",
		["Golemagg the Incinerator"] = "Golemagg der Verbrenner",
		["Lucifron"] = "Lucifron",
		["Magmadar"] = "Magmadar",
		["Majordomo Executus"] = "Majordomus Exekutus",
		["Ragnaros"] = "Ragnaros",
		["Shazzrah"] = "Shazzrah",
		["Sulfuron Harbinger"] = "Sulfuronherold",

--Naxxramas
		["Anub'Rekhan"] = "Anub'Rekhan",
		["Deathknight Understudy"] = "Reservist der Todesritter",
		["Feugen"] = "Feugen",
		["Four Horsemen Chest"] = "Die Vier Reiter Kiste",
		["Gluth"] = "Gluth",
		["Gothik the Harvester"] = "Gothik der Seelenjäger",
		["Grand Widow Faerlina"] = "Großwitwe Faerlina",
		["Grobbulus"] = "Grobbulus",
		["Heigan the Unclean"] = "Heigan der Unreine",
		["Highlord Mograine"] = "Hochlord Mograine",
		["Instructor Razuvious"] = "Instrukteur Razuvious",
		["Kel'Thuzad"] = "Kel'Thuzad",
		["Lady Blaumeux"] = "Lady Blaumeux",
		["Loatheb"] = "Loatheb",
		["Maexxna"] = "Maexxna",
		["Noth the Plaguebringer"] = "Noth der Seuchenfürst",
		["Patchwerk"] = "Flickwerk",
		["Sapphiron"] = "Saphiron",
		["Sir Zeliek"] = "Sire Zeliek",
		["Stalagg"] = "Stalagg",
		["Thaddius"] = "Thaddius",
		["Thane Korth'azz"] = "Thane Korth'azz",
		["The Four Horsemen"] = "Die Vier Reiter",

--Onyxia's Lair
		["Onyxia"] = "Onyxia",

--Ragefire Chasm
		["Bazzalan"] = "Bazzalan",
		["Jergosh the Invoker"] = "Jergosh der Herbeirufer",
		["Maur Grimtotem"] = "Maur Grimmtotem",
		["Taragaman the Hungerer"] = "Taragaman der Hungerleider",

--Razorfen Downs
		["Amnennar the Coldbringer"] = "Amnennar der Kältebringer",
		["Glutton"] = "Nimmersatt",
		["Mordresh Fire Eye"] = "Mordresh Feuerauge",
		["Plaguemaw the Rotting"] = "Seuchenschlund der Faulende",
		["Ragglesnout"] = "Struppmähne",
		["Tuten'kash"] = "Tuten'kash",

--Razorfen Kraul
		["Agathelos the Raging"] = "Agathelos der Tobende",
		["Blind Hunter"] = "Blinder Jäger",
		["Charlga Razorflank"] = "Charlga Klingenflanke",
		["Death Speaker Jargba"] = "Todessprecher Jargba",
		["Earthcaller Halmgar"] = "Erdenrufer Halmgar",
		["Overlord Ramtusk"] = "Oberanführer Rammhauer",

--Ruins of Ahn'Qiraj
		["Anubisath Guardian"] = "Beschützer des Anubisath",
		["Ayamiss the Hunter"] = "Ayamiss der Jäger",
		["Buru the Gorger"] = "Buru der Verschlinger",
		["General Rajaxx"] = "General Rajaxx",
		["Kurinnaxx"] = "Kurinnaxx",
		["Lieutenant General Andorov"] = "Generallieutenant Andorov",
		["Moam"] = "Moam",
		["Ossirian the Unscarred"] = "Ossirian der Narbenlose",

--Scarlet Monastery
--Armory
		["Herod"] = "Herod",
--Cathedral
		["High Inquisitor Fairbanks"] = "Hochinquisitor Fairbanks",
		["High Inquisitor Whitemane"] = "Hochinquisitor Weißsträhne",
		["Scarlet Commander Mograine"] = "Scharlachroter Kommandant Mograine",
--Graveyard
		["Azshir the Sleepless"] = "Azshir der Schlaflose",
		["Bloodmage Thalnos"] = "Blutmagier Thalnos",
		["Fallen Champion"] = "Gestürzter Held",
		["Interrogator Vishas"] = "Befrager Vishas",
		["Ironspine"] = "Eisenrücken",
--Library
		["Arcanist Doan"] = "Arkanist Doan",
		["Houndmaster Loksey"] = "Hundemeister Loksey",

--Scholomance
		["Blood Steward of Kirtonos"] = "Blutdiener von Kirtonos",
		["Darkmaster Gandling"] = "Dunkelmeister Gandling",
		["Death Knight Darkreaver"] = "Todesritter Schattensichel",
		["Doctor Theolen Krastinov"] = "Doktor Theolen Krastinov",
		["Instructor Malicia"] = "Instrukteurin Malicia",
		["Jandice Barov"] = "Jandice Barov",
		["Kirtonos the Herald"] = "Kirtonos der Herold",
		["Kormok"] = "Kormok",
		["Lady Illucia Barov"] = "Lady Illucia Barov",
		["Lord Alexei Barov"] = "Lord Alexei Barov",
		["Lorekeeper Polkelt"] = "Hüter des Wissens Polkelt",
		["Marduk Blackpool"] = "Marduk Blackpool",
		["Ras Frostwhisper"] = "Ras Frostraunen",
		["Rattlegore"] = "Blutrippe",
		["The Ravenian"] = "Der Ravenier",
		["Vectus"] = "Vectus",

--Shadowfang Keep
		["Archmage Arugal"] = "Erzmagier Arugal",
		["Arugal's Voidwalker"] = "Arugals Leerwandler",
		["Baron Silverlaine"] = "Baron Silberlein",
		["Commander Springvale"] = "Kommandant Springvale",
		["Deathsworn Captain"] = "Todeshöriger Captain",
		["Fenrus the Devourer"] = "Fenrus der Verschlinger",
		["Odo the Blindwatcher"] = "Odo der Blindseher",
		["Razorclaw the Butcher"] = "Klingenklaue der Metzger",
		["Wolf Master Nandos"] = "Wolfmeister Nados",

--Stratholme
		["Archivist Galford"] = "Archivar Galford",
		["Balnazzar"] = "Balnazzar",
		["Baron Rivendare"] = "Baron Totenschwur",
		["Baroness Anastari"] = "Baroness Anastari",
		["Black Guard Swordsmith"] = "Schwertschmied der schwarzen Wache",
		["Cannon Master Willey"] = "Kanonenmeister Willey",
		["Crimson Hammersmith"] = "Purpurroter Hammerschmied",
		["Fras Siabi"] = "Fras Siabi",
		["Hearthsinger Forresten"] = "Herdsinger Forresten",
		["Magistrate Barthilas"] = "Magistrat Barthilas",
		["Maleki the Pallid"] = "Maleki der Leichenblasse",
		["Nerub'enkan"] = "Nerub'enkan",
		["Postmaster Malown"] = "Postmeister Malown",
		["Ramstein the Gorger"] = "Ramstein der Verschlinger",
		["Skul"] = "Skul",
		["Stonespine"] = "Steinbuckel",
		["The Unforgiven"] = "Der Unverziehene",
		["Timmy the Cruel"] = "Timmy der Grausame",

--Sunwell Plateau
		["Kalecgos"] = "Kalecgos",
		["Sathrovarr the Corruptor"] = "Sathrovarr der Verderber",
		["Brutallus"] = "Brutallus",
		["Felmyst"] = "Teufelsruch",
		["Kil'jaeden"] = "Kil'jaeden",
		["M'uru"] = "M'uru",
		["Entropius"] = "Entropius",
		["The Eredar Twins"] = "Die Eredar Zwillinge",
		["Lady Sacrolash"] = "Lady Sacrolash",
		["Grand Warlock Alythess"] = "Großhexenmeisterin Alythess",

--Tempest Keep
--The Arcatraz
		["Dalliah the Doomsayer"] = "Dalliah die Verdammnisverkünderin",
		["Harbinger Skyriss"] = "Herold Horizontiss",
		["Warden Mellichar"] = "Aufseher Mellichar",
		["Wrath-Scryer Soccothrates"] = "Zornseher Soccothrates",
		["Zereketh the Unbound"] = "Zereketh der Unabhängige",
--The Botanica
		["Commander Sarannis"] = "Kommandant Sarannis",
		["High Botanist Freywinn"] = "Hochbotaniker Freywinn",
		["Laj"] = "Laj",
		["Thorngrin the Tender"] = "Dorngrin der Hüter",
		["Warp Splinter"] = "Warpzweig",
--The Eye
		["Al'ar"] = "Al'ar",
		["Cosmic Infuser"] = "Kosmische Macht",
		["Devastation"] = "Verwüstung",
		["Grand Astromancer Capernian"] = "Großastronom Capernian",
		["High Astromancer Solarian"] = "Hochastromantin Solarian",
		["Infinity Blades"] = "Klinge der Unendlichkeit",
		["Kael'thas Sunstrider"] = "Kael'thas Sonnenwanderer",
		["Lord Sanguinar"] = "Fürst Blutdurst",
		["Master Engineer Telonicus"] = "Meisteringenieur Telonicus",
		["Netherstrand Longbow"] = "Netherbespannter Langbogen",
		["Phaseshift Bulwark"] = "Phasenverschobenes Bollwerk",
		["Solarium Agent"] = "Solarian Agent",
		["Solarium Priest"] = "Solarian Priester",
		["Staff of Disintegration"] = "Stab der Auflösung",
		["Thaladred the Darkener"] = "Thaladred der Verfinsterer",
		["Void Reaver"] = "Leerhäscher",
		["Warp Slicer"] = "Warpschnitter",
--The Mechanar
		["Gatewatcher Gyro-Kill"] = "Torwächter Gyrotot",
		["Gatewatcher Iron-Hand"] = "Torwächter Eisenhand",
		["Mechano-Lord Capacitus"] = "Mechanolord Kapazitus",
		["Nethermancer Sepethrea"] = "Nethermant Sepethrea",
		["Pathaleon the Calculator"] = "Pathaleon der Kalkulator",

--The Deadmines
		["Brainwashed Noble"] = "Manipulierter Adliger",
		["Captain Greenskin"] = "Kapitän Grünhaut",
		["Cookie"] = "Krümel",
		["Edwin VanCleef"] = "Edwin van Cleef",
		["Foreman Thistlenettle"] = "Großknecht Distelklette",
		["Gilnid"] = "Gilnid",
		["Marisa du'Paige"] = "Marisa du'Paige",
		["Miner Johnson"] = "Minenarbeiter Johnson",
		["Mr. Smite"] = "Handlanger Pein",
		["Rhahk'Zor"] = "Rhahk'Zor",
		["Sneed"] = "Sneed",
		["Sneed's Shredder"] = "Sneeds Schredder",

--The Stockade
		["Bazil Thredd"] = "Bazil Thredd",
		["Bruegal Ironknuckle"] = "Bruegal Eisenfaust",
		["Dextren Ward"] = "Dextren Ward",
		["Hamhock"] = "Hamhock",
		["Kam Deepfury"] = "Kam Tiefenzorn",
		["Targorr the Dread"] = "Targorr der Schreckliche",

--The Temple of Atal'Hakkar
		["Atal'alarion"] = "Atal'alarion",
		["Avatar of Hakkar"] = "Avatar von Hakkar",
		["Dreamscythe"] = "Traumsense",
		["Gasher"] = "Schlitzer",
		["Hazzas"] = "Hazzas",
		["Hukku"] = "Hukku",
		["Jade"] = "Jade",
		["Jammal'an the Prophet"] = "Jammal'an der Prophet",
		["Kazkaz the Unholy"] = "Kazkaz der Unheilige",
		["Loro"] = "Loro",
		["Mijan"] = "Mijan",
		["Morphaz"] = "Morphaz",
		["Ogom the Wretched"] = "Ogom der Elende",
		["Shade of Eranikus"] = "Eranikus' Schemen",
		["Veyzhak the Cannibal"] = "Veyzhack der Kannibale",
		["Weaver"] = "Wirker",
		["Zekkis"] = "Zekkis",
		["Zolo"] = "Zolo",
		["Zul'Lor"] = "Zul'Lor",

--Uldaman
		["Ancient Stone Keeper"] = "Uralter Steinbewahrer",
		["Archaedas"] = "Archaedas",
		["Baelog"] = "Baelog",
		["Digmaster Shovelphlange"] = "Grubenmeister Schaufelphlansch",
		["Galgann Firehammer"] = "Galgann Feuerhammer",
		["Grimlok"] = "Grimlok",
		["Ironaya"] = "Ironaya",
		["Obsidian Sentinel"] = "Obsidianschildwache",
		["Revelosh"] = "Revelosh",

--Wailing Caverns
		["Boahn"] = "Boahn",
		["Deviate Faerie Dragon"] = "Deviatfeendrache",
		["Kresh"] = "Kresh",
		["Lady Anacondra"] = "Lady Anacondra",
		["Lord Cobrahn"] = "Lord Kobrahn",
		["Lord Pythas"] = "Lord Pythas",
		["Lord Serpentis"] = "Lord Serpentis",
		["Mad Magglish"] = "Zausel der Verrückte",
		["Mutanus the Devourer"] = "Mutanus der Verschlinger",
		["Skum"] = "Skum",
		["Trigore the Lasher"] = "Trigore der Peitscher",
		["Verdan the Everliving"] = "Verdan der Ewiglebende",

--World Bosses
		["Avalanchion"] = "Avalanchion",
		["Azuregos"] = "Azuregos",
		["Baron Charr"] = "Baron Glutarr",
		["Baron Kazum"] = "Baron Kazum",
		["Doom Lord Kazzak"] = "Verdammnislord Kazzak",
		["Doomwalker"] = "Verdammniswandler",
		["Emeriss"] = "Smariss",
		["High Marshal Whirlaxis"] = "Hochmarschall Whirlaxis",
		["Lethon"] = "Lethon",
		["Lord Skwol"] = "Lord Skwol",
		["Prince Skaldrenox"] = "Prince Skaldrenox",
		["Princess Tempestria"] = "Prinzessin Tempestria",
		["Taerar"] = "Taerar",
		["The Windreaver"] = "Der Windhäscher",
		["Ysondre"] = "Ysondre",

--Zul'Aman
		["Akil'zon"] = "Akil'zon",
		["Halazzi"] = "Halazzi",
		["Jan'alai"] = "Jan'alai",
		["Malacrass"] = "Malacrass",
		["Nalorakk"] = "Nalorakk",
		["Zul'jin"] = "Zul'jin",
		["Hex Lord Malacrass"] = "Hexlord Malacrass",

--Zul'Farrak
		["Antu'sul"] = "Antu'sul",
		["Chief Ukorz Sandscalp"] = "Häuptling Ukorz Sandwüter",
		["Dustwraith"] = "Karaburan",
		["Gahz'rilla"] = "Gahz'rilla",
		["Hydromancer Velratha"] = "Wasserbeschwörerin Velratha",
		["Murta Grimgut"] = "Murta Bauchgrimm",
		["Nekrum Gutchewer"] = "Nekrum der Ausweider",
		["Oro Eyegouge"] = "Oro Hohlauge",
		["Ruuzlu"] = "Ruuzlu",
		["Sandarr Dunereaver"] = "Sandarr der Wüstenräuber",
		["Sandfury Executioner"] = "Henker der Sandwüter",
		["Sergeant Bly"] = "Unteroffizier Bly",
		["Shadowpriest Sezz'ziz"] = "Schattenpriester Sezz'ziz",
		["Theka the Martyr"] = "Theka der Märtyrer",
		["Witch Doctor Zum'rah"] = "Hexendoktor Zum'rah" ,
		["Zerillis"] = "Zerillis",
		["Zul'Farrak Dead Hero"] = "Untoter Held aus Zul'Farrak",

--Zul'Gurub
		["Bloodlord Mandokir"] = "Blutfürst Mandokir",
		["Gahz'ranka"] = "Gahz'ranka",
		["Gri'lek"] = "Gri'lek",
		["Hakkar"] = "Hakkar",
		["Hazza'rah"] = "Hazza'rah",
		["High Priest Thekal"] = "Hohepriester Thekal",
		["High Priest Venoxis"] = "Hohepriester Venoxis",
		["High Priestess Arlokk"] = "Hohepriesterin Arlokk",
		["High Priestess Jeklik"] = "Hohepriesterin Jeklik",
		["High Priestess Mar'li"] = "Hohepriesterin Mar'li",
		["Jin'do the Hexxer"] = "Jin'do der Verhexer",
		["Renataki"] = "Renataki",
		["Wushoolay"] = "Wushoolay",

--Ring of Blood (where? an instnace? should be in other file?)
		["Brokentoe"] = "Schmetterzehe",
		["Mogor"] = "Mogor",
		["Murkblood Twin"] = "Zwilling der Finsterblut",
		["Murkblood Twins"] = "Zwillinge der Finsterblut",
		["Rokdar the Sundered Lord"] = "Rokdar der Zerklüftete",
		["Skra'gath"] = "Skra'gath",
		["The Blue Brothers"] = "Die Blaumänner",
		["Warmaul Champion"] = "Champion der Totschläger",
	}
elseif GAME_LOCALE == "frFR" then
	lib:SetCurrentTranslations {
--Ahn'Qiraj
		["Anubisath Defender"] = "Défenseur Anubisath",
		["Battleguard Sartura"] = "Garde de guerre Sartura",
		["C'Thun"] = "C'Thun",
		["Emperor Vek'lor"] = "Empereur Vek'lor",
		["Emperor Vek'nilash"] = "Empereur Vek'nilash",
		["Eye of C'Thun"] = "Œil de C'Thun",
		["Fankriss the Unyielding"] = "Fankriss l'Inflexible",
		["Lord Kri"] = "Seigneur Kri",
		["Ouro"] = "Ouro",
		["Princess Huhuran"] = "Princesse Huhuran",
		["Princess Yauj"] = "Princesse Yauj",
		["The Bug Family"] = "La famille insecte",
		["The Prophet Skeram"] = "Le Prophète Skeram",
		["The Twin Emperors"] = "Les Empereurs jumeaux",
		["Vem"] = "Vem",
		["Viscidus"] = "Viscidus",

--Auchindoun
--Auchenai Crypts
		["Exarch Maladaar"] = "Exarque Maladaar",
		["Shirrak the Dead Watcher"] = "Shirrak le Veillemort",
--Mana-Tombs
		["Nexus-Prince Shaffar"] = "Prince-nexus Shaffar",
		["Pandemonius"] = "Pandemonius",
		["Tavarok"] = "Tavarok",
--Shadow Labyrinth
		["Ambassador Hellmaw"] = "Ambassadeur Gueule-d'enfer",
		["Blackheart the Inciter"] = "Coeur-noir le Séditieux",
		["Grandmaster Vorpil"] = "Grand Maître Vorpil",
		["Murmur"] = "Marmon",
--Sethekk Halls
		["Anzu"] = "Anzu",
		["Darkweaver Syth"] = "Tisseur d'ombre Syth",
		["Talon King Ikiss"] = "Roi-serre Ikiss",

--Blackfathom Deeps
		["Aku'mai"] = "Aku'mai",
		["Baron Aquanis"] = "Baron Aquanis",
		["Gelihast"] = "Gelihast",
		["Ghamoo-ra"] = "Ghamoo-ra",
		["Lady Sarevess"] = "Dame Sarevess",
		["Old Serra'kis"] = "Vieux Serra'kis",
		["Twilight Lord Kelris"] = "Seigneur du crépuscule Kelris",

--Blackrock Depths
		["Ambassador Flamelash"] = "Ambassadeur Cinglefouet",
		["Anger'rel"] = "Colé'rel",
		["Anub'shiah"] = "Anub'shiah",
		["Bael'Gar"] = "Bael'Gar",
		["Chest of The Seven"] = "Coffre des sept",
		["Doom'rel"] = "Tragi'rel",
		["Dope'rel"] = "Demeu'rel",
		["Emperor Dagran Thaurissan"] = "Empereur Dagran Thaurissan",
		["Eviscerator"] = "Eviscérateur",
		["Fineous Darkvire"] = "Fineous Sombrevire",
		["General Angerforge"] = "Général Forgehargne",
		["Gloom'rel"] = "Funéb'rel",
		["Golem Lord Argelmach"] = "Seigneur golem Argelmach",
		["Gorosh the Dervish"] = "Gorosh le Derviche",
		["Grizzle"] = "Grison",
		["Hate'rel"] = "Haine'rel",
		["Hedrum the Creeper"] = "Hedrum le Rampant",
		["High Interrogator Gerstahn"] = "Grand Interrogateur Gerstahn",
		["High Priestess of Thaurissan"] = "Grande prêtresse de Thaurissan",
		["Houndmaster Grebmar"] = "Maître-chien Grebmar",
		["Hurley Blackbreath"] = "Hurley Soufflenoir",
		["Lord Incendius"] = "Seigneur Incendius",
		["Lord Roccor"] = "Seigneur Roccor",
		["Magmus"] = "Magmus",
		["Ok'thor the Breaker"] = "Ok'thor le Briseur",
		["Panzor the Invincible"] = "Panzor l'Invincible",
		["Phalanx"] = "Phalange",
		["Plugger Spazzring"] = "Lanfiche Brouillecircuit",
		["Princess Moira Bronzebeard"] = "Princesse Moira Barbe-de-bronze",
		["Pyromancer Loregrain"] = "Pyromancien Blé-du-savoir",
		["Ribbly Screwspigot"] = "Ribbly Fermevanne",
		["Seeth'rel"] = "Fulmi'rel",
		["The Seven Dwarves"] = "Les sept nains",
		["Verek"] = "Verek",
		["Vile'rel"] = "Ignobl'rel",
		["Warder Stilgiss"] = "Gardien Stilgiss",

--Blackrock Spire
--Lower
		["Bannok Grimaxe"] = "Bannok Hache-sinistre",
		["Burning Felguard"] = "Gangregarde ardent",
		["Crystal Fang"] = "Croc cristallin",
		["Ghok Bashguud"] = "Ghok Bounnebaffe",
		["Gizrul the Slavener"] = "Gizrul l'esclavagiste",
		["Halycon"] = "Halycon",
		["Highlord Omokk"] = "Généralissime Omokk",
		["Mor Grayhoof"] = "Mor Sabot-gris",
		["Mother Smolderweb"] = "Matriarche Couveuse",
		["Overlord Wyrmthalak"] = "Seigneur Wyrmthalak",
		["Quartermaster Zigris"] = "Intendant Zigris",
		["Shadow Hunter Vosh'gajin"] = "Chasseresse des ombres Vosh'gajin",
		["Spirestone Battle Lord"] = "Seigneur de bataille Pierre-du-pic",
		["Spirestone Butcher"] = "Boucher Pierre-du-pic",
		["Spirestone Lord Magus"] = "Seigneur magus Pierre-du-pic",
		["Urok Doomhowl"] = "Urok Hurleruine",
		["War Master Voone"] = "Maître de guerre Voone",
--Upper
		["General Drakkisath"] = "Général Drakkisath",
		["Goraluk Anvilcrack"] = "Goraluk Brisenclume",
		["Gyth"] = "Gyth",
		["Jed Runewatcher"] = "Jed Guette-runes",
		["Lord Valthalak"] = "Seigneur Valthalak",
		["Pyroguard Emberseer"] = "Pyrogarde Prophète ardent",
		["Solakar Flamewreath"] = "Solakar Voluteflamme",
		["The Beast"] = "La Bête",
		["Warchief Rend Blackhand"] = "Chef de guerre Rend Main-noire",

--Blackwing Lair
		["Broodlord Lashlayer"] = "Seigneur des couvées Lanistaire",
		["Chromaggus"] = "Chromaggus",
		["Ebonroc"] = "Rochébène",
		["Firemaw"] = "Gueule-de-feu",
		["Flamegor"] = "Flamegor",
		["Grethok the Controller"] = "Grethok le Contrôleur",
		["Lord Victor Nefarius"] = "Seigneur Victor Nefarius",
		["Nefarian"] = "Nefarian",
		["Razorgore the Untamed"] = "Tranchetripe l'Indompté",
		["Vaelastrasz the Corrupt"] = "Vaelastrasz le Corrompu",

--Black Temple
		["Essence of Anger"] = "Essence de la colère",
		["Essence of Desire"] = "Essence du désir",
		["Essence of Suffering"] = "Essence de la souffrance",
		["Gathios the Shatterer"] = "Gathios le Briseur",
		["Gurtogg Bloodboil"] = "Gurtogg Fièvresang",
		["High Nethermancer Zerevor"] = "Grand néantomancien Zerevor",
		["High Warlord Naj'entus"] = "Grand seigneur de guerre Naj'entus",
		["Illidan Stormrage"] = "Illidan Hurlorage",
		["Illidari Council"] = "Conseil illidari",
		["Lady Malande"] = "Dame Malande",
		["Mother Shahraz"] = "Mère Shahraz",
		["Reliquary of Souls"] = "Le reliquaire des âmes",
		["Shade of Akama"] = "Ombre d'Akama",
		["Supremus"] = "Supremus",
		["Teron Gorefiend"] = "Teron Fielsang",
		["The Illidari Council"] = "Le conseil illidari",
		["Veras Darkshadow"] = "Veras Ombrenoir",

--Caverns of Time
--Old Hillsbrad Foothills
		["Captain Skarloc"] = "Capitaine Skarloc",
		["Epoch Hunter"] = "Chasseur d'époques",
		["Lieutenant Drake"] = "Lieutenant Drake",
--The Black Morass
		["Aeonus"] = "Aeonus",
		["Chrono Lord Deja"] = "Chronoseigneur Déjà",
		["Medivh"] = "Medivh",
		["Temporus"] = "Temporus",

--Coilfang Reservoir
--Serpentshrine Cavern
		["Coilfang Elite"] = "Elite de Glissecroc",
		["Coilfang Strider"] = "Trotteur de Glissecroc",
		["Fathom-Lord Karathress"] = "Seigneur des fonds Karathress",
		["Hydross the Unstable"] = "Hydross l'Instable",
		["Lady Vashj"] = "Dame Vashj",
		["Leotheras the Blind"] = "Leotheras l'Aveugle",
		["Morogrim Tidewalker"] = "Morogrim Marcheur-des-flots",
		["Pure Spawn of Hydross"] = "Pur rejeton d'Hydross",
		["Shadow of Leotheras"] = "Ombre de Leotheras",
		["Tainted Spawn of Hydross"] = "Rejeton d'Hydross souillé",
		["The Lurker Below"] = "Le Rôdeur d'En bas",
		["Tidewalker Lurker"] = "Rôdeur marcheur-des-flots",
--The Slave Pens
		["Mennu the Betrayer"] = "Mennu le Traître",
		["Quagmirran"] = "Bourbierreux",
		["Rokmar the Crackler"] = "Rokmar le Crépitant",
--The Steamvault
		["Hydromancer Thespia"] = "Hydromancienne Thespia",
		["Mekgineer Steamrigger"] = "Mékgénieur Montevapeur",
		["Warlord Kalithresh"] = "Seigneur de guerre Kalithresh",
--The Underbog
		["Claw"] = "Griffe",
		["Ghaz'an"] = "Ghaz'an",
		["Hungarfen"] = "Hungarfen",
		["Overseer Tidewrath"] = "Surveillant Tidewrath",
		["Swamplord Musel'ek"] = "Seigneur des marais Musel'ek",
		["The Black Stalker"] = "La Traqueuse noire",

--Dire Maul
--Arena
		["Mushgog"] = "Mushgog",
		["Skarr the Unbreakable"] = "Bâlhafr l'Invaincu",
		["The Razza"] = "La Razza",
--East
		["Alzzin the Wildshaper"] = "Alzzin le Modeleur",
		["Hydrospawn"] = "Hydrogénos",
		["Isalien"] = "Isalien",
		["Lethtendris"] = "Lethtendris",
		["Pimgib"] = "Pimgib",
		["Pusillin"] = "Pusillin",
		["Zevrim Thornhoof"] = "Zevrim Sabot-de-ronce",
--North
		["Captain Kromcrush"] = "Capitaine Kromcrush",
		["Cho'Rush the Observer"] = "Cho'Rush l'Observateur",
		["Guard Fengus"] = "Garde Fengus",
		["Guard Mol'dar"] = "Garde Mol'dar",
		["Guard Slip'kik"] = "Garde Slip'kik",
		["King Gordok"] = "Roi Gordok",
		["Knot Thimblejack's Cache"] = "Réserve de Noué Dédodevie",
		["Stomper Kreeg"] = "Kreeg le Marteleur",
--West
		["Illyanna Ravenoak"] = "Illyanna Corvichêne",
		["Immol'thar"] = "Immol'thar",
		["Lord Hel'nurath"] = "Seigneur Hel'nurath",
		["Magister Kalendris"] = "Magistère Kalendris",
		["Prince Tortheldrin"] = "Prince Tortheldrin",
		["Tendris Warpwood"] = "Tendris Crochebois",
		["Tsu'zee"] = "Tsu'zee",

--Gnomeregan
		["Crowd Pummeler 9-60"] = "Faucheur de foule 9-60",
		["Dark Iron Ambassador"] = "Ambassadeur Sombrefer",
		["Electrocutioner 6000"] = "Electrocuteur 6000",
		["Grubbis"] = "Grubbis",
		["Mekgineer Thermaplugg"] = "Mekgénieur Thermojoncteur",
		["Techbot"] = "Techbot",
		["Viscous Fallout"] = "Retombée visqueuse",

--Gruul's Lair
		["Blindeye the Seer"] = "Oeillaveugle le Voyant",
		["Gruul the Dragonkiller"] = "Gruul le Tue-dragon",
		["High King Maulgar"] = "Haut Roi Maulgar",
		["Kiggler the Crazed"] = "Kiggler le Cinglé",
		["Krosh Firehand"] = "Krosh Brasemain",
		["Olm the Summoner"] = "Olm l'Invocateur",

--Hellfire Citadel
--Hellfire Ramparts
		["Nazan"] = "Nazan",
		["Omor the Unscarred"] = "Omor l'Intouché",
		["Vazruden the Herald"] = "Vazruden le Héraut",
		["Vazruden"] = "Vazruden",
		["Watchkeeper Gargolmar"] = "Gardien des guetteurs Gargolmar",
--Magtheridon's Lair
		["Hellfire Channeler"] = "Canaliste des Flammes infernales",
		["Magtheridon"] = "Magtheridon",
--The Blood Furnace
		["Broggok"] = "Broggok",
		["Keli'dan the Breaker"] = "Keli'dan le Briseur",
		["The Maker"] = "Le Faiseur",
--The Shattered Halls
		["Blood Guard Porung"] = "Garde de sang Porung",
		["Grand Warlock Nethekurse"] = "Grand démoniste Néanathème",
		["Warbringer O'mrogg"] = "Porteguerre O'mrogg",
		["Warchief Kargath Bladefist"] = "Chef de guerre Kargath Lamepoing",

--Hyjal Summit
		["Anetheron"] = "Anetheron",
		["Archimonde"] = "Archimonde",
		["Azgalor"] = "Azgalor",
		["Kaz'rogal"] = "Kaz'rogal",
		["Rage Winterchill"] = "Rage Froidhiver",

--Karazhan
		["Arcane Watchman"] = "Veilleur arcanique",
		["Attumen the Huntsman"] = "Attumen le Veneur",
		["Chess Event"] = "Partie d'échec",
		["Dorothee"] = "Dorothée",
		["Dust Covered Chest"] = "Coffre couvert de poussière",
		["Grandmother"] = "Mère-grand",
		["Hyakiss the Lurker"] = "Hyakiss le rôdeur",
		["Julianne"] = "Julianne",
		["Kil'rek"] = "Kil'rek",
		["King Llane Piece"] = "Pion du Roi Llane",
		["Maiden of Virtue"] = "Damoiselle de vertu",
		["Midnight"] = "Minuit",
		["Moroes"] = "Moroes",
		["Netherspite"] = "Dédain-du-Néant",
		["Nightbane"] = "Plaie-de-nuit",
		["Prince Malchezaar"] = "Prince Malchezaar",
		["Restless Skeleton"] = "Squelette sans repos",
		["Roar"] = "Graou",
		["Rokad the Ravager"] = "Rodak le ravageur",
		["Romulo & Julianne"] = "Romulo & Julianne",
		["Romulo"] = "Romulo",
		["Shade of Aran"] = "Ombre d'Aran",
		["Shadikith the Glider"] = "Shadikith le glisseur",
		["Strawman"] = "Homme de paille",
		["Terestian Illhoof"] = "Terestian Malsabot",
		["The Big Bad Wolf"] = "Le Grand Méchant Loup",
		["The Crone"] = "La Mégère",
		["The Curator"] = "Le conservateur",
		["Tinhead"] = "Tête de fer-blanc",
		["Tito"] = "Tito",
		["Warchief Blackhand Piece"] = "Pion du Chef de guerre Main-noire",

-- Magisters' Terrace
		--["Kael'thas Sunstrider"] = "Kael'thas Haut-soleil",
		["Priestess Delrissa"] = "Prêtresse Delrissa",
		["Selin Fireheart"] = "Selin Coeur-de-feu",
		["Vexallus"] = "Vexallus",

--Maraudon
		["Celebras the Cursed"] = "Celebras le Maudit",
		["Gelk"] = "Gelk",
		["Kolk"] = "Kolk",
		["Landslide"] = "Glissement de terrain",
		["Lord Vyletongue"] = "Seigneur Vylelangue",
		["Magra"] = "Magra",
		["Maraudos"] = "Maraudos",
		["Meshlok the Harvester"] = "Meshlok le Moissonneur",
		["Noxxion"] = "Noxcion",
		["Princess Theradras"] = "Princesse Theradras",
		["Razorlash"] = "Tranchefouet",
		["Rotgrip"] = "Grippe-charogne",
		["Tinkerer Gizlock"] = "Bricoleur Kadenaz",
		["Veng"] = "Veng",

--Molten Core
		["Baron Geddon"] = "Baron Geddon",
		["Cache of the Firelord"] = "Cachette du Seigneur du feu",
		["Garr"] = "Garr",
		["Gehennas"] = "Gehennas",
		["Golemagg the Incinerator"] = "Golemagg l'Incinérateur",
		["Lucifron"] = "Lucifron",
		["Magmadar"] = "Magmadar",
		["Majordomo Executus"] = "Chambellan Executus",
		["Ragnaros"] = "Ragnaros",
		["Shazzrah"] = "Shazzrah",
		["Sulfuron Harbinger"] = "Messager de Sulfuron",

--Naxxramas
		["Anub'Rekhan"] = "Anub'Rekhan",
		["Deathknight Understudy"] = "Doublure de chevalier de la mort",
		["Feugen"] = "Feugen",
		["Four Horsemen Chest"] = "Coffre des quatre cavaliers",
		["Gluth"] = "Gluth",
		["Gothik the Harvester"] = "Gothik le Moissonneur",
		["Grand Widow Faerlina"] = "Grande veuve Faerlina",
		["Grobbulus"] = "Grobbulus",
		["Heigan the Unclean"] = "Heigan l'Impur",
		["Highlord Mograine"] = "Généralissime Mograine",
		["Instructor Razuvious"] = "Instructeur Razuvious",
		["Kel'Thuzad"] = "Kel'Thuzad",
		["Lady Blaumeux"] = "Dame Blaumeux",
		["Loatheb"] = "Horreb",
		["Maexxna"] = "Maexxna",
		["Noth the Plaguebringer"] = "Noth le Porte-peste",
		["Patchwerk"] = "Le Recousu",
		["Sapphiron"] = "Saphiron",
		["Sir Zeliek"] = "Sire Zeliek",
		["Stalagg"] = "Stalagg",
		["Thaddius"] = "Thaddius",
		["Thane Korth'azz"] = "Thane Korth'azz",
		["The Four Horsemen"] = "Les quatre cavaliers",

--Onyxia's Lair
		["Onyxia"] = "Onyxia",

--Ragefire Chasm
		["Bazzalan"] = "Bazzalan",
		["Jergosh the Invoker"] = "Jergosh l'Invocateur",
		["Maur Grimtotem"] = "Maur Totem-sinistre",
		["Taragaman the Hungerer"] = "Taragaman l'Affameur",

--Razorfen Downs
		["Amnennar the Coldbringer"] = "Amnennar le Porte-froid",
		["Glutton"] = "Glouton",
		["Mordresh Fire Eye"] = "Mordresh Oeil-de-feu",
		["Plaguemaw the Rotting"] = "Pestegueule le Pourrissant",
		["Ragglesnout"] = "Groinfendu",
		["Tuten'kash"] = "Tuten'kash",

--Razorfen Kraul
		["Agathelos the Raging"] = "Agathelos le Déchaîné",
		["Blind Hunter"] = "Chasseur aveugle",
		["Charlga Razorflank"] = "Charlga Trancheflanc",
		["Death Speaker Jargba"] = "Nécrorateur Jargba",
		["Earthcaller Halmgar"] = "Implorateur de la terre Halmgar",
		["Overlord Ramtusk"] = "Seigneur Brusquebroche",

--Ruins of Ahn'Qiraj
		["Anubisath Guardian"] = "Gardien Anubisath",
		["Ayamiss the Hunter"] = "Ayamiss le Chasseur",
		["Buru the Gorger"] = "Buru Grandgosier",
		["General Rajaxx"] = "Général Rajaxx",
		["Kurinnaxx"] = "Kurinnaxx",
		["Lieutenant General Andorov"] = "Général de division Andorov",
		["Moam"] = "Moam",
		["Ossirian the Unscarred"] = "Ossirian l'Intouché",

--Scarlet Monastery
--Armory
		["Herod"] = "Hérode",
--Cathedral
		["High Inquisitor Fairbanks"] = "Grand Inquisiteur Fairbanks",
		["High Inquisitor Whitemane"] = "Grand Inquisiteur Blanchetête",
		["Scarlet Commander Mograine"] = "Commandant écarlate Mograine",
--Graveyard
		["Azshir the Sleepless"] = "Azshir le Sans-sommeil",
		["Bloodmage Thalnos"] = "Mage de sang Thalnos",
		["Fallen Champion"] = "Champion mort",
		["Interrogator Vishas"] = "Interrogateur Vishas",
		["Ironspine"] = "Echine-de-fer",
--Library
		["Arcanist Doan"] = "Arcaniste Doan",
		["Houndmaster Loksey"] = "Maître-chien Loksey",

--Scholomance
		["Blood Steward of Kirtonos"] = "Régisseuse sanglante de Kirtonos",
		["Darkmaster Gandling"] = "Sombre Maître Gandling",
		["Death Knight Darkreaver"] = "Chevalier de la mort Ravassombre",
		["Doctor Theolen Krastinov"] = "Docteur Theolen Krastinov",
		["Instructor Malicia"] = "Instructeur Malicia",
		["Jandice Barov"] = "Jandice Barov",
		["Kirtonos the Herald"] = "Kirtonos le Héraut",
		["Kormok"] = "Kormok",
		["Lady Illucia Barov"] = "Dame Illucia Barov",
		["Lord Alexei Barov"] = "Seigneur Alexei Barov",
		["Lorekeeper Polkelt"] = "Gardien du savoir Polkelt",
		["Marduk Blackpool"] = "Marduk Noirétang",
		["Ras Frostwhisper"] = "Ras Murmegivre",
		["Rattlegore"] = "Cliquettripes",
		["The Ravenian"] = "Le Voracien",
		["Vectus"] = "Vectus",

--Shadowfang Keep
		["Archmage Arugal"] = "Archimage Arugal",
		["Arugal's Voidwalker"] = "Marcheur du Vide d'Arugal",
		["Baron Silverlaine"] = "Baron d'Argelaine",
		["Commander Springvale"] = "Commandant Springvale",
		["Deathsworn Captain"] = "Capitaine Ligemort",
		["Fenrus the Devourer"] = "Fenrus le Dévoreur",
		["Odo the Blindwatcher"] = "Odo l'Aveugle",
		["Razorclaw the Butcher"] = "Tranchegriffe le Boucher",
		["Wolf Master Nandos"] = "Maître-loup Nandos",

--Stratholme
		["Archivist Galford"] = "Archiviste Galford",
		["Balnazzar"] = "Balnazzar",
		["Baron Rivendare"] = "Baron Vaillefendre",
		["Baroness Anastari"] = "Baronne Anastari",
		["Black Guard Swordsmith"] = "Fabricant d'épées de la Garde noire",
		["Cannon Master Willey"] = "Maître canonnier Willey",
		["Crimson Hammersmith"] = "Forgeur de marteaux cramoisi",
		["Fras Siabi"] = "Fras Siabi",
		["Hearthsinger Forresten"] = "Chanteloge Forrestin",
		["Magistrate Barthilas"] = "Magistrat Barthilas",
		["Maleki the Pallid"] = "Maleki le Blafard",
		["Nerub'enkan"] = "Nerub'enkan",
		["Postmaster Malown"] = "Postier Malown",
		["Ramstein the Gorger"] = "Ramstein Grandgosier",
		["Skul"] = "Krân",
		["Stonespine"] = "Echine-de-pierre",
		["The Unforgiven"] = "Le Condamné",
		["Timmy the Cruel"] = "Timmy le Cruel",

--Sunwell Plateau
		["Kalecgos"] = "Kalecgos",
		["Sathrovarr the Corruptor"] = "Sathrovarr le Corrupteur",
		["Brutallus"] = "Brutallus",
		["Felmyst"] = "Gangrebrume",
		["Kil'jaeden"] = "Kil'jaeden",
		["M'uru"] = "M'uru",
		["Entropius"] = "Entropius",
		["The Eredar Twins"] = "Les jumelles érédars",
		["Lady Sacrolash"] = "Dame Sacrocingle",
		["Grand Warlock Alythess"] = "Grande démoniste Alythess",

--Tempest Keep
--The Arcatraz
		["Dalliah the Doomsayer"] = "Dalliah l'Auspice-funeste",
		["Harbinger Skyriss"] = "Messager Cieuriss",
		["Warden Mellichar"] = "Gardien Mellichar",
		["Wrath-Scryer Soccothrates"] = "Scrute-courroux Soccothrates",
		["Zereketh the Unbound"] = "Zereketh le Délié",
--The Botanica
		["Commander Sarannis"] = "Commandant Sarannis",
		["High Botanist Freywinn"] = "Grand botaniste Freywinn",
		["Laj"] = "Laj",
		["Thorngrin the Tender"] = "Rirépine le Tendre",
		["Warp Splinter"] = "Brise-dimension",
--The Eye
		["Al'ar"] = "Al'ar",
		["Cosmic Infuser"] = "Masse d'infusion cosmique",
		["Devastation"] = "Dévastation",
		["Grand Astromancer Capernian"] = "Grande astromancienne Capernian",
		["High Astromancer Solarian"] = "Grande astromancienne Solarian",
		["Infinity Blades"] = "Lames d'infinité",
		["Kael'thas Sunstrider"] = "Kael'thas Haut-soleil",
		["Lord Sanguinar"] = "Seigneur Sanguinar",
		["Master Engineer Telonicus"] = "Maître ingénieur Telonicus",
		["Netherstrand Longbow"] = "Arc long brins-de-Néant",
		["Phaseshift Bulwark"] = "Rempart de déphasage",
		["Solarium Agent"] = "Agent du Solarium",
		["Solarium Priest"] = "Prêtre du Solarium",
		["Staff of Disintegration"] = "Bâton de désintégration",
		["Thaladred the Darkener"] = "Thaladred l'Assombrisseur",
		["Void Reaver"] = "Saccageur du Vide",
		["Warp Slicer"] = "Tranchoir dimensionnel",
--The Mechanar
		["Gatewatcher Gyro-Kill"] = "Gardien de porte Gyro-Meurtre",
		["Gatewatcher Iron-Hand"] = "Gardien de porte Main-en-fer",
		["Mechano-Lord Capacitus"] = "Mécano-seigneur Capacitus",
		["Nethermancer Sepethrea"] = "Néantomancien Sepethrea",
		["Pathaleon the Calculator"] = "Pathaleon le Calculateur",

--The Deadmines
		["Brainwashed Noble"] = "Noble manipulé",
		["Captain Greenskin"] = "Capitaine Vertepeau",
		["Cookie"] = "Macaron",
		["Edwin VanCleef"] = "Edwin VanCleef",
		["Foreman Thistlenettle"] = "Contremaître Crispechardon",
		["Gilnid"] = "Gilnid",
		["Marisa du'Paige"] = "Marisa du'Paige",
		["Miner Johnson"] = "Mineur Johnson",
		["Mr. Smite"] = "M. Châtiment",
		["Rhahk'Zor"] = "Rhahk'Zor",
		["Sneed"] = "Sneed",
		["Sneed's Shredder"] = "Déchiqueteur de Sneed",

--The Stockade
		["Bazil Thredd"] = "Bazil Thredd",
		["Bruegal Ironknuckle"] = "Bruegal Poing-de-fer",
		["Dextren Ward"] = "Dextren Ward",
		["Hamhock"] = "Hamhock",
		["Kam Deepfury"] = "Kam Furie-du-fond",
		["Targorr the Dread"] = "Targorr le Terrifiant",

--The Temple of Atal'Hakkar
		["Atal'alarion"] = "Atal'alarion",
		["Avatar of Hakkar"] = "Avatar d'Hakkar",
		["Dreamscythe"] = "Fauche-rêve",
		["Gasher"] = "Gasher",
		["Hazzas"] = "Hazzas",
		["Hukku"] = "Hukku",
		["Jade"] = "Jade",
		["Jammal'an the Prophet"] = "Jammal'an le prophète",
		["Kazkaz the Unholy"] = "Kazkaz l'Impie",
		["Loro"] = "Loro",
		["Mijan"] = "Mijan",
		["Morphaz"] = "Morphaz",
		["Ogom the Wretched"] = "Ogom le Misérable",
		["Shade of Eranikus"] = "Ombre d'Eranikus",
		["Veyzhak the Cannibal"] = "Veyzhak le Cannibale",
		["Weaver"] = "Tisserand",
		["Zekkis"] = "Zekkis",
		["Zolo"] = "Zolo",
		["Zul'Lor"] = "Zul'Lor",

--Uldaman
		["Ancient Stone Keeper"] = "Ancien Gardien des pierres",
		["Archaedas"] = "Archaedas",
		["Baelog"] = "Baelog",
		["Digmaster Shovelphlange"] = "Maître des fouilles Pellaphlange",
		["Galgann Firehammer"] = "Galgann Martel-de-feu",
		["Grimlok"] = "Grimlok",
		["Ironaya"] = "Ironaya",
		["Obsidian Sentinel"] = "Sentinelle d'obsidienne",
		["Revelosh"] = "Revelosh",

--Wailing Caverns
		["Boahn"] = "Boahn",
		["Deviate Faerie Dragon"] = "Dragon féérique déviant",
		["Kresh"] = "Kresh",
		["Lady Anacondra"] = "Dame Anacondra",
		["Lord Cobrahn"] = "Seigneur Cobrahn",
		["Lord Pythas"] = "Seigneur Pythas",
		["Lord Serpentis"] = "Seigneur Serpentis",
		["Mad Magglish"] = "Magglish le Dingue",
		["Mutanus the Devourer"] = "Mutanus le Dévoreur",
		["Skum"] = "Skum",
		["Trigore the Lasher"] = "Trigore le Flagelleur",
		["Verdan the Everliving"] = "Verdan l'Immortel",

--World Bosses
		["Avalanchion"] = "Avalanchion",
		["Azuregos"] = "Azuregos",
		["Baron Charr"] = "Baron Charr",
		["Baron Kazum"] = "Baron Kazum",
		["Doom Lord Kazzak"] = "Seigneur funeste Kazzak",
		["Doomwalker"] = "Marche-funeste",
		["Emeriss"] = "Emeriss",
		["High Marshal Whirlaxis"] = "Haut maréchal Trombe",
		["Lethon"] = "Léthon",
		["Lord Skwol"] = "Seigneur Skwol",
		["Prince Skaldrenox"] = "Prince Skaldrenox ",
		["Princess Tempestria"] = "Princesse Tempestria",
		["Taerar"] = "Taerar",
		["The Windreaver"] = "Ouraganien",
		["Ysondre"] = "Ysondre",

--Zul'Aman
		["Akil'zon"] = "Akil'zon",
		["Halazzi"] = "Halazzi",
		["Jan'alai"] = "Jan'alai",
		["Malacrass"] = "Malacrass",
		["Nalorakk"] = "Nalorakk",
		["Zul'jin"] = "Zul'jin",
		["Hex Lord Malacrass"] = "Seigneur des maléfices Malacrass",

--Zul'Farrak
		["Antu'sul"] = "Antu'sul",
		["Chief Ukorz Sandscalp"] = "Chef Ukorz Scalpessable",
		["Dustwraith"] = "Ame en peine poudreuse",
		["Gahz'rilla"] = "Gahz'rilla",
		["Hydromancer Velratha"] = "Hydromancienne Velratha",
		["Murta Grimgut"] = "Murta Mornentraille",
		["Nekrum Gutchewer"] = "Nekrum Mâchetripes",
		["Oro Eyegouge"] = "Oro Crève-oeil ",
		["Ruuzlu"] = "Ruuzlu",
		["Sandarr Dunereaver"] = "Sandarr Ravadune",
		["Sandfury Executioner"] = "Bourreau Furie-des-sables",
		["Sergeant Bly"] = "Sergent Bly",
		["Shadowpriest Sezz'ziz"] = "Prêtre des ombres Sezz'ziz",
		["Theka the Martyr"] = "Theka le Martyr",
		["Witch Doctor Zum'rah"] = "Sorcier-docteur Zum'rah",
		["Zerillis"] = "Zerillis",
		["Zul'Farrak Dead Hero"] = "Héros mort de Zul'Farrak",

--Zul'Gurub
		["Bloodlord Mandokir"] = "Seigneur sanglant Mandokir",
		["Gahz'ranka"] = "Gahz'ranka",
		["Gri'lek"] = "Gri'lek",
		["Hakkar"] = "Hakkar",
		["Hazza'rah"] = "Hazza'rah",
		["High Priest Thekal"] = "Grand prêtre Thekal",
		["High Priest Venoxis"] = "Grand prêtre Venoxis",
		["High Priestess Arlokk"] = "Grande prêtresse Arlokk",
		["High Priestess Jeklik"] = "Grande prêtresse Jeklik",
		["High Priestess Mar'li"] = "Grande prêtresse Mar'li",
		["Jin'do the Hexxer"] = "Jin'do le Maléficieur",
		["Renataki"] = "Renataki",
		["Wushoolay"] = "Wushoolay",

--Ring of Blood (where? an instance? should be in other file?)
		["Brokentoe"] = "Brisorteil",
		["Mogor"] = "Mogor",
		["Murkblood Twin"] = "Jumeau bourbesang",
		["Murkblood Twins"] = "Jumeaux bourbesang",
		["Rokdar the Sundered Lord"] = "Rokdar le Seigneur scindé",
		["Skra'gath"] = "Skra'gath",
		["The Blue Brothers"] = "Les Grands Bleus",
		["Warmaul Champion"] = "Champion Cogneguerre",
	}
elseif GAME_LOCALE == "zhCN" then
	lib:SetCurrentTranslations {
--Ahn'Qiraj
		["Anubisath Defender"] = "阿努比萨斯防御者",
		["Battleguard Sartura"] = "沙尔图拉",
		["C'Thun"] = "克苏恩",
		["Emperor Vek'lor"] = "维克洛尔大帝",
		["Emperor Vek'nilash"] = "维克尼拉斯大帝",
		["Eye of C'Thun"] = "克苏恩之眼",
		["Fankriss the Unyielding"] = "顽强的范克瑞斯",
		["Lord Kri"] = "克里勋爵",
		["Ouro"] = "奥罗",
		["Princess Huhuran"] = "哈霍兰公主",
		["Princess Yauj"] = "亚尔基公主",
		["The Bug Family"] = "虫子一家",
		["The Prophet Skeram"] = "预言者斯克拉姆",
		["The Twin Emperors"] = "双子皇帝",
		["Vem"] = "维姆",
		["Viscidus"] = "维希度斯",

--Auchindoun
--Auchenai Crypts
		["Exarch Maladaar"] = "大主教玛拉达尔",
		["Shirrak the Dead Watcher"] = "死亡观察者希尔拉克",
--Mana-Tombs
		["Nexus-Prince Shaffar"] = "节点亲王沙法尔",
		["Pandemonius"] = "潘德莫努斯",
		["Tavarok"] = "塔瓦洛克",
--Shadow Labyrinth
		["Ambassador Hellmaw"] = "赫尔默大使",
		["Blackheart the Inciter"] = "煽动者布莱卡特",
		["Grandmaster Vorpil"] = "沃匹尔大师",
		["Murmur"] = "摩摩尔",
--Sethekk Halls
		["Anzu"] = "安苏",
		["Darkweaver Syth"] = "黑暗编织者塞斯",
		["Talon King Ikiss"] = "利爪之王艾吉斯",

--Blackfathom Deeps
		["Aku'mai"] = "阿库麦尔",
		["Baron Aquanis"] = "阿奎尼斯男爵",
		["Gelihast"] = "格里哈斯特",
		["Ghamoo-ra"] = "加摩拉",
		["Lady Sarevess"] = "萨利维丝",
		["Old Serra'kis"] = "瑟拉吉斯",
		["Twilight Lord Kelris"] = "梦游者克尔里斯",

--Blackrock Depths
		["Ambassador Flamelash"] = "弗莱拉斯大使",
		["Anger'rel"] = "安格雷尔",
		["Anub'shiah"] = "阿努希尔",
		["Bael'Gar"] = "贝尔加",
		["Chest of The Seven"] = "七贤之箱",--七贤的宝箱
		["Doom'rel"] = "杜姆雷尔",
		["Dope'rel"] = "多普雷尔",
		["Emperor Dagran Thaurissan"] = "达格兰·索瑞森大帝",
		["Eviscerator"] = "剜眼者",
		["Fineous Darkvire"] = "弗诺斯·达克维尔",
		["General Angerforge"] = "安格弗将军",
		["Gloom'rel"] = "格鲁雷尔",
		["Golem Lord Argelmach"] = "傀儡统帅阿格曼奇",
		["Gorosh the Dervish"] = "修行者高罗什",
		["Grizzle"] = "格里兹尔",
		["Hate'rel"] = "黑特雷尔",
		["Hedrum the Creeper"] = "爬行者赫杜姆",
		["High Interrogator Gerstahn"] = "审讯官格斯塔恩",
		["High Priestess of Thaurissan"] = "索瑞森高阶女祭司",
		["Houndmaster Grebmar"] = "驯犬者格雷布玛尔",
		["Hurley Blackbreath"] = "霍尔雷·黑须",
		["Lord Incendius"] = "伊森迪奥斯",
		["Lord Roccor"] = "洛考尔",
		["Magmus"] = "玛格姆斯",
		["Ok'thor the Breaker"] = "破坏者奥科索尔",
		["Panzor the Invincible"] = "无敌的潘佐尔",
		["Phalanx"] = "方阵",
		["Plugger Spazzring"] = "普拉格",
		["Princess Moira Bronzebeard"] = "铁炉堡公主茉艾拉·铜须",
		["Pyromancer Loregrain"] = "控火师罗格雷恩",
		["Ribbly Screwspigot"] = "雷布里·斯库比格特",
		["Seeth'rel"] = "西斯雷尔",
		["The Seven Dwarves"] = "七贤矮人",
		["Verek"] = "维雷克",
		["Vile'rel"] = "瓦勒雷尔",
		["Warder Stilgiss"] = "典狱官斯迪尔基斯",

--Blackrock Spire
--Lower 黑下
		["Bannok Grimaxe"] = "班诺克·巨斧",
		["Burning Felguard"] = "燃烧地狱卫士",--check 翻译成2种 燃烧地狱守卫
		["Crystal Fang"] = "水晶之牙",
		["Ghok Bashguud"] = "霍克·巴什古德",
		["Gizrul the Slavener"] = "奴役者基兹鲁尔",
		["Halycon"] = "哈雷肯",
		["Highlord Omokk"] = "欧莫克大王",
		["Mor Grayhoof"] = "莫尔·灰蹄",
		["Mother Smolderweb"] = "烟网蛛后",
		["Overlord Wyrmthalak"] = "维姆萨拉克",
		["Quartermaster Zigris"] = "军需官兹格雷斯",
		["Shadow Hunter Vosh'gajin"] = "暗影猎手沃什加斯",
		["Spirestone Battle Lord"] = "尖石统帅",
		["Spirestone Butcher"] = "尖石屠夫",
		["Spirestone Lord Magus"] = "尖石首席法师",
		["Urok Doomhowl"] = "乌洛克",
		["War Master Voone"] = "指挥官沃恩",
--Upper 黑上
		["General Drakkisath"] = "达基萨斯将军",
		["Goraluk Anvilcrack"] = "古拉鲁克",
		["Gyth"] = "盖斯",
		["Jed Runewatcher"] = "杰德",
		["Lord Valthalak"] = "瓦塔拉克公爵",
		["Pyroguard Emberseer"] = "烈焰卫士艾博希尔",
		["Solakar Flamewreath"] = "索拉卡·火冠",
		["The Beast"] = "比斯巨兽",
		["Warchief Rend Blackhand"] = "大酋长雷德·黑手",

--Blackwing Lair
		["Broodlord Lashlayer"] = "勒什雷尔",
		["Chromaggus"] = "克洛玛古斯",
		["Ebonroc"] = "埃博诺克",
		["Firemaw"] = "费尔默",
		["Flamegor"] = "弗莱格尔",
		["Grethok the Controller"] = "黑翼控制者",
		["Lord Victor Nefarius"] = "维克多·奈法里奥斯",
		["Nefarian"] = "奈法利安",
		["Razorgore the Untamed"] = "狂野的拉佐格尔",
		["Vaelastrasz the Corrupt"] = "堕落的瓦拉斯塔兹",

--Black Temple
		["Essence of Anger"] = "愤怒精华",
		["Essence of Desire"] = "欲望精华",
		["Essence of Suffering"] = "苦痛精华",
		["Gathios the Shatterer"] = "击碎者加西奥斯",
		["Gurtogg Bloodboil"] = "古尔图格·血沸",
		["High Nethermancer Zerevor"] = "高阶灵术师塞勒沃尔",
		["High Warlord Naj'entus"] = "高阶督军纳因图斯",
		["Illidan Stormrage"] = "伊利丹·怒风",
		["Illidari Council"] = "伊利达雷议会",
		["Lady Malande"] = "女公爵玛兰德",
		["Mother Shahraz"] = "莎赫拉丝主母",
		["Reliquary of Souls"] = "灵魂之匣",
		["Shade of Akama"] = "阿卡玛之影",
		["Supremus"] = "苏普雷姆斯",
		["Teron Gorefiend"] = "塔隆·血魔",
		["The Illidari Council"] = "伊利达雷议会",
		["Veras Darkshadow"] = "维尔莱斯·深影",

--Caverns of Time
--Old Hillsbrad Foothills
		["Captain Skarloc"] = "斯卡洛克上尉",
		["Epoch Hunter"] = "时空猎手",
		["Lieutenant Drake"] = "德拉克中尉",
--The Black Morass
		["Aeonus"] = "埃欧努斯",
		["Chrono Lord Deja"] = "时空领主德亚",
		["Medivh"] = "麦迪文",
		["Temporus"] = "坦普卢斯",

--Coilfang Reservoir
--Serpentshrine Cavern
		["Coilfang Elite"] = "盘牙精英",
		["Coilfang Strider"] = "盘牙巡逻者",
		["Fathom-Lord Karathress"] = "深水领主卡拉瑟雷斯",
		["Hydross the Unstable"] = "不稳定的海度斯",
		["Lady Vashj"] = "瓦丝琪",
		["Leotheras the Blind"] = "盲眼者莱欧瑟拉斯",
		["Morogrim Tidewalker"] = "莫洛格里·踏潮者",
		["Pure Spawn of Hydross"] = "纯净的海度斯爪牙",
		["Shadow of Leotheras"] = "莱欧瑟拉斯之影",
		["Tainted Spawn of Hydross"] = "污染的海度斯爪牙",
		["The Lurker Below"] = "鱼斯拉",
		["Tidewalker Lurker"] = "踏潮潜伏者",
--The Slave Pens
		["Mennu the Betrayer"] = "背叛者门努",
		["Quagmirran"] = "夸格米拉",
		["Rokmar the Crackler"] = "巨钳鲁克玛尔",
--The Steamvault
		["Hydromancer Thespia"] = "水术师瑟丝比娅",
		["Mekgineer Steamrigger"] = "机械师斯蒂里格",
		["Warlord Kalithresh"] = "督军卡利瑟里斯",
--The Underbog
		["Claw"] = "克劳恩",
		["Ghaz'an"] = "加兹安",
		["Hungarfen"] = "霍加尔芬",
		["Overseer Tidewrath"] = "工头泰德瓦斯",
		["Swamplord Musel'ek"] = "沼地领主穆塞雷克",
		["The Black Stalker"] = "黑色阔步者",

--Dire Maul 厄运
--Arena 竞技场
		["Mushgog"] = "姆斯高格",
		["Skarr the Unbreakable"] = "无敌的斯卡尔",
		["The Razza"] = "拉扎尔",
--East
		["Alzzin the Wildshaper"] = "奥兹恩",
		["Hydrospawn"] = "海多斯博恩",
		["Isalien"] = "伊萨利恩",
		["Lethtendris"] = "蕾瑟塔蒂丝",
		["Pimgib"] = "匹姆吉布",
		["Pusillin"] = "普希林",
		["Zevrim Thornhoof"] = "瑟雷姆·刺蹄",
--North
		["Captain Kromcrush"] = "克罗卡斯",
		["Cho'Rush the Observer"] = "观察者克鲁什",
		["Guard Fengus"] = "卫兵芬古斯",
		["Guard Mol'dar"] = "卫兵摩尔达",
		["Guard Slip'kik"] = "卫兵斯里基克",
		["King Gordok"] = "戈多克大王",
		["Knot Thimblejack's Cache"] = "诺特·希姆加克的储物箱",
		["Stomper Kreeg"] = "践踏者克雷格",
--West
		["Illyanna Ravenoak"] = "伊琳娜·暗木",
		["Immol'thar"] = "伊莫塔尔",
		["Lord Hel'nurath"] = "赫尔努拉斯",
		["Magister Kalendris"] = "卡雷迪斯镇长",
		["Prince Tortheldrin"] = "托塞德林王子",
		["Tendris Warpwood"] = "特迪斯·扭木",
		["Tsu'zee"] = "苏斯",

--Gnomeregan
		["Crowd Pummeler 9-60"] = "群体打击者9-60",
		["Dark Iron Ambassador"] = "黑铁大师",
		["Electrocutioner 6000"] = "电刑器6000型",
		["Grubbis"] = "格鲁比斯",
		["Mekgineer Thermaplugg"] = "麦克尼尔·瑟玛普拉格",
		["Techbot"] = "尖端机器人",
		["Viscous Fallout"] = "粘性辐射尘",

--Gruul's Lair
		["Blindeye the Seer"] = "盲眼先知",
		["Gruul the Dragonkiller"] = "屠龙者格鲁尔",
		["High King Maulgar"] = "莫加尔大王",
		["Kiggler the Crazed"] = "疯狂的基戈尔",
		["Krosh Firehand"] = "克洛什·火拳",
		["Olm the Summoner"] = "召唤者沃尔姆",

--Hellfire Citadel
--Hellfire Ramparts
		["Nazan"] = "纳杉",
		["Omor the Unscarred"] = "无疤者奥摩尔",
		["Vazruden the Herald"] = "传令官瓦兹德",
		["Vazruden"] = "瓦兹德",
		["Watchkeeper Gargolmar"] = "巡视者加戈玛",
--Magtheridon's Lair
		["Hellfire Channeler"] = "地狱火导魔者",
		["Magtheridon"] = "玛瑟里顿",
--The Blood Furnace
		["Broggok"] = "布洛戈克",
		["Keli'dan the Breaker"] = "击碎者克里丹",
		["The Maker"] = "制造者",
--The Shattered Halls
		["Blood Guard Porung"] = "血卫士伯鲁恩",
		["Grand Warlock Nethekurse"] = "高阶术士奈瑟库斯",
		["Warbringer O'mrogg"] = "战争使者沃姆罗格",
		["Warchief Kargath Bladefist"] = "酋长卡加斯·刃拳",

--Hyjal Summit
		["Anetheron"] = "安纳塞隆",
		["Archimonde"] = "阿克蒙德",
		["Azgalor"] = "阿兹加洛",
		["Kaz'rogal"] = "卡兹洛加",
		["Rage Winterchill"] = "雷基·冬寒",

--Karazhan
		["Arcane Watchman"] = "奥术看守",
		["Attumen the Huntsman"] = "猎手阿图门",
		["Chess Event"] = "国际象棋",
		["Dorothee"] = "多萝茜",
		["Dust Covered Chest"] = "灰尘覆盖的箱子",--nga数据库
		["Grandmother"] = "老奶奶",
		["Hyakiss the Lurker"] = "潜伏者希亚其斯",
		["Julianne"] = "朱丽叶",
		["Kil'rek"] = "基尔里克",
		["King Llane Piece"] = "莱恩国王",
		["Maiden of Virtue"] = "贞节圣女",
		["Midnight"] = "午夜",
		["Moroes"] = "莫罗斯",
		["Netherspite"] = "虚空幽龙",
		["Nightbane"] = "夜之魇",
		["Prince Malchezaar"] = "玛克扎尔王子",
		["Restless Skeleton"] = "无法安息的骷髅",
		["Roar"] = "胆小的狮子",
		["Rokad the Ravager"] = "蹂躏者洛卡德",
		["Romulo & Julianne"] = "罗密欧与朱丽叶",
		["Romulo"] = "罗密欧",
		["Shade of Aran"] = "埃兰之影",
		["Shadikith the Glider"] = "滑翔者沙德基斯",
		["Strawman"] = "稻草人",
		["Terestian Illhoof"] = "特雷斯坦·邪蹄",
		["The Big Bad Wolf"] = "大灰狼",
		["The Crone"] = "巫婆",
		["The Curator"] = "馆长",
		["Tinhead"] = "铁皮人",
		["Tito"] = "托托",
		["Warchief Blackhand Piece"] = "黑手酋长",

-- Magisters' Terrace (魔导师平台)
		["Kael'thas Sunstrider"] = "凯尔萨斯·逐日者",
		["Priestess Delrissa"] = "女祭司德莉希亚",
		["Selin Fireheart"] = "塞林·火心",
		["Vexallus"] = "维萨鲁斯",

--Maraudon
		["Celebras the Cursed"] = "被诅咒的塞雷布拉斯",
		["Gelk"] = "吉尔克",
		["Kolk"] = "考尔克",
		["Landslide"] = "兰斯利德",
		["Lord Vyletongue"] = "维利塔恩",
		["Magra"] = "玛格拉",
		["Maraudos"] = "玛拉多斯",
		["Meshlok the Harvester"] = "收割者麦什洛克",
		["Noxxion"] = "诺克赛恩",
		["Princess Theradras"] = "瑟莱德丝公主",
		["Razorlash"] = "锐刺鞭笞者",
		["Rotgrip"] = "洛特格里普",
		["Tinkerer Gizlock"] = "工匠吉兹洛克",
		["Veng"] = "温格",

--Molten Core
		["Baron Geddon"] = "迦顿男爵",
		["Cache of the Firelord"] = "火焰之王的宝箱",
		["Garr"] = "加尔",
		["Gehennas"] = "基赫纳斯",
		["Golemagg the Incinerator"] = "焚化者古雷曼格",
		["Lucifron"] = "鲁西弗隆",
		["Magmadar"] = "玛格曼达",
		["Majordomo Executus"] = "管理者埃克索图斯",
		["Ragnaros"] = "拉格纳罗斯",
		["Shazzrah"] = "沙斯拉尔",
		["Sulfuron Harbinger"] = "萨弗隆先驱者",

--Naxxramas
		["Anub'Rekhan"] = "阿努布雷坎",
		["Deathknight Understudy"] = "见习死亡骑士",
		["Feugen"] = "费尔根",
		["Four Horsemen Chest"] = "四骑士之箱",
		["Gluth"] = "格拉斯",
		["Gothik the Harvester"] = "收割者戈提克",
		["Grand Widow Faerlina"] = "黑女巫法琳娜",
		["Grobbulus"] = "格罗布鲁斯",
		["Heigan the Unclean"] = "肮脏的希尔盖",
		["Highlord Mograine"] = "大领主莫格莱尼",
		["Instructor Razuvious"] = "教官拉苏维奥斯",
		["Kel'Thuzad"] = "克尔苏加德",
		["Lady Blaumeux"] = "女公爵布劳缪克丝",
		["Loatheb"] = "洛欧塞布",
		["Maexxna"] = "迈克斯纳",
		["Noth the Plaguebringer"] = "瘟疫使者诺斯",
		["Patchwerk"] = "帕奇维克",
		["Sapphiron"] = "萨菲隆",
		["Sir Zeliek"] = "瑟里耶克爵士",
		["Stalagg"] = "斯塔拉格",
		["Thaddius"] = "塔迪乌斯",
		["Thane Korth'azz"] = "库尔塔兹领主",
		["The Four Horsemen"] = "四骑士",

--Onyxia's Lair
		["Onyxia"] = "奥妮克希亚",

--Ragefire Chasm
		["Bazzalan"] = "巴扎兰",
		["Jergosh the Invoker"] = "祈求者耶戈什",
		["Maur Grimtotem"] = "玛尔·恐怖图腾",
		["Taragaman the Hungerer"] = "饥饿者塔拉加曼",

--Razorfen Downs
		["Amnennar the Coldbringer"] = "寒冰之王亚门纳尔",
		["Glutton"] = "暴食者",
		["Mordresh Fire Eye"] = "火眼莫德雷斯",
		["Plaguemaw the Rotting"] = "腐烂的普雷莫尔",
		["Ragglesnout"] = "拉戈斯诺特",
		["Tuten'kash"] = "图特卡什",

--Razorfen Kraul
		["Agathelos the Raging"] = "暴怒的阿迦赛罗斯",
		["Blind Hunter"] = "盲眼猎手",
		["Charlga Razorflank"] = "卡尔加·刺肋",
		["Death Speaker Jargba"] = "亡语者贾格巴",
		["Earthcaller Halmgar"] = "唤地者哈穆加",
		["Overlord Ramtusk"] = "主宰拉姆塔斯",

--Ruins of Ahn'Qiraj
		["Anubisath Guardian"] = "阿努比萨斯守卫者",
		["Ayamiss the Hunter"] = "狩猎者阿亚米斯",
		["Buru the Gorger"] = "吞咽者布鲁",
		["General Rajaxx"] = "拉贾克斯将军",
		["Kurinnaxx"] = "库林纳克斯",
		["Lieutenant General Andorov"] = "安多洛夫中将",
		["Moam"] = "莫阿姆",
		["Ossirian the Unscarred"] = "无疤者奥斯里安",

--Scarlet Monastery
--Armory
		["Herod"] = "赫洛德",
--Cathedral
		["High Inquisitor Fairbanks"] = "大检察官法尔班克斯",
		["High Inquisitor Whitemane"] = "大检察官怀特迈恩",
		["Scarlet Commander Mograine"] = "血色十字军指挥官莫格莱尼",
--Graveyard
		["Azshir the Sleepless"] = "永醒的艾希尔",
		["Bloodmage Thalnos"] = "血法师萨尔诺斯",
		["Fallen Champion"] = "死灵勇士",
		["Interrogator Vishas"] = "审讯员韦沙斯",
		["Ironspine"] = "铁脊死灵",
--Library
		["Arcanist Doan"] = "奥法师杜安",
		["Houndmaster Loksey"] = "驯犬者洛克希",

--Scholomance
		["Blood Steward of Kirtonos"] = "基尔图诺斯的卫士",
		["Darkmaster Gandling"] = "黑暗院长加丁",
		["Death Knight Darkreaver"] = "死亡骑士达克雷尔",
		["Doctor Theolen Krastinov"] = "瑟尔林·卡斯迪诺夫教授",
		["Instructor Malicia"] = "讲师玛丽希亚",
		["Jandice Barov"] = "詹迪斯·巴罗夫",
		["Kirtonos the Herald"] = "传令官基尔图诺斯",
		["Kormok"] = "库尔莫克",
		["Lady Illucia Barov"] = "伊露希亚·巴罗夫",
		["Lord Alexei Barov"] = "阿雷克斯·巴罗夫",
		["Lorekeeper Polkelt"] = "博学者普克尔特",
		["Marduk Blackpool"] = "马杜克·布莱克波尔",
		["Ras Frostwhisper"] = "莱斯·霜语",
		["Rattlegore"] = "血骨傀儡",
		["The Ravenian"] = "拉文尼亚",
		["Vectus"] = "维克图斯",

--Shadowfang Keep
		["Archmage Arugal"] = "大法师阿鲁高",
		["Arugal's Voidwalker"] = "阿鲁高的虚空行者",
		["Baron Silverlaine"] = "席瓦莱恩男爵",
		["Commander Springvale"] = "指挥官斯普林瓦尔",
		["Deathsworn Captain"] = "死亡之誓",
		["Fenrus the Devourer"] = "吞噬者芬鲁斯",
		["Odo the Blindwatcher"] = "盲眼守卫奥杜",
		["Razorclaw the Butcher"] = "屠夫拉佐克劳",
		["Wolf Master Nandos"] = "狼王南杜斯",

--Stratholme
		["Archivist Galford"] = "档案管理员加尔福特",
		["Balnazzar"] = "巴纳扎尔",
		["Baron Rivendare"] = "瑞文戴尔男爵",
		["Baroness Anastari"] = "安娜丝塔丽男爵夫人",
		["Black Guard Swordsmith"] = "黑衣守卫铸剑师",
		["Cannon Master Willey"] = "炮手威利",
		["Crimson Hammersmith"] = "红衣铸锤师",
		["Fras Siabi"] = "弗拉斯·希亚比",
		["Hearthsinger Forresten"] = "弗雷斯特恩",
		["Magistrate Barthilas"] = "巴瑟拉斯镇长",
		["Maleki the Pallid"] = "苍白的玛勒基",
		["Nerub'enkan"] = "奈鲁布恩坎",
		["Postmaster Malown"] = "邮差马龙",
		["Ramstein the Gorger"] = "吞咽者拉姆斯登",
		["Skul"] = "斯库尔",
		["Stonespine"] = "石脊",
		["The Unforgiven"] = "不可宽恕者",
		["Timmy the Cruel"] = "悲惨的提米",

--Sunwell Plateau (太阳之井高地)
		["Kalecgos"] = "卡雷苟斯",
		["Sathrovarr the Corruptor"] = "腐蚀者萨索瓦尔",
		["Brutallus"] = "布鲁塔卢斯",
		["Felmyst"] = "菲米丝",
		["Kil'jaeden"] = "基尔加丹",
		["M'uru"] = "穆鲁",
		["Entropius"] = "熵魔",
		["The Eredar Twins"] = "艾瑞达双子",
		["Lady Sacrolash"] = "萨洛拉丝女王",
		["Grand Warlock Alythess"] = "高阶术士奥蕾塞丝",

--Tempest Keep
--The Arcatraz
		["Dalliah the Doomsayer"] = "末日预言者达尔莉安",
		["Harbinger Skyriss"] = "预言者斯克瑞斯",
		["Warden Mellichar"] = "监护者梅里卡尔",
		["Wrath-Scryer Soccothrates"] = "天怒预言者苏克拉底",
		["Zereketh the Unbound"] = "自由的瑟雷凯斯",
--The Botanica
		["Commander Sarannis"] = "指挥官萨拉妮丝",
		["High Botanist Freywinn"] = "高级植物学家弗雷温",
		["Laj"] = "拉伊",
		["Thorngrin the Tender"] = "看管者索恩格林",
		["Warp Splinter"] = "迁跃扭木",
--The Eye
		["Al'ar"] = "奥",
		["Cosmic Infuser"] = "宇宙灌注者",
		["Devastation"] = "毁坏",
		["Grand Astromancer Capernian"] = "星术师卡波妮娅",
		["High Astromancer Solarian"] = "大星术师索兰莉安",
		["Infinity Blades"] = "无尽之刃",
		["Kael'thas Sunstrider"] = "凯尔萨斯·逐日者",
		["Lord Sanguinar"] = "萨古纳尔男爵",
		["Master Engineer Telonicus"] = "首席技师塔隆尼库斯",
		["Netherstrand Longbow"] = "灵弦长弓",
		["Phaseshift Bulwark"] = "相位壁垒",
		["Solarium Agent"] = "日晷密探",
		["Solarium Priest"] = "日晷祭司",
		["Staff of Disintegration"] = "瓦解法杖",
		["Thaladred the Darkener"] = "亵渎者萨拉德雷",
		["Void Reaver"] = "空灵机甲",
		["Warp Slicer"] = "迁跃切割者",
--The Mechanar
		["Gatewatcher Gyro-Kill"] = "看守者盖罗基尔",
		["Gatewatcher Iron-Hand"] = "看守者埃隆汉",
		["Mechano-Lord Capacitus"] = "机械领主卡帕西图斯",
		["Nethermancer Sepethrea"] = "灵术师塞比瑟蕾",
		["Pathaleon the Calculator"] = "计算者帕萨雷恩的影像",

--The Deadmines
		["Brainwashed Noble"] = "被洗脑的贵族",
		["Captain Greenskin"] = "绿皮队长",
		["Cookie"] = "曲奇",
		["Edwin VanCleef"] = "艾德温·范克里夫",
		["Foreman Thistlenettle"] = "工头希斯耐特",
		["Gilnid"] = "基尔尼格",
		["Marisa du'Paige"] = "玛里莎·杜派格",
		["Miner Johnson"] = "矿工约翰森",
		["Mr. Smite"] = "重拳先生",
		["Rhahk'Zor"] = "拉克佐",
		["Sneed"] = "斯尼德",
		["Sneed's Shredder"] = "斯尼德的伐木机",

--The Stockade
		["Bazil Thredd"] = "巴基尔·斯瑞德",
		["Bruegal Ironknuckle"] = "布鲁高·铁拳",
		["Dextren Ward"] = "迪克斯特·瓦德",
		["Hamhock"] = "哈姆霍克",
		["Kam Deepfury"] = "卡姆·深怒",
		["Targorr the Dread"] = "可怕的塔格尔",

--The Temple of Atal'Hakkar
		["Atal'alarion"] = "阿塔拉利恩",
		["Avatar of Hakkar"] = "哈卡的化身",
		["Dreamscythe"] = "德姆塞卡尔",
		["Gasher"] = "加什尔",
		["Hazzas"] = "哈扎斯",
		["Hukku"] = "胡库",
		["Jade"] = "玉龙",
		["Jammal'an the Prophet"] = "预言者迦玛兰",
		["Kazkaz the Unholy"] = "邪恶的卡萨卡兹",
		["Loro"] = "洛若尔",
		["Mijan"] = "米杉",
		["Morphaz"] = "摩弗拉斯",
		["Ogom the Wretched"] = "可悲的奥戈姆",
		["Shade of Eranikus"] = "伊兰尼库斯的阴影",
		["Veyzhak the Cannibal"] = "食尸者维萨克",
		["Weaver"] = "德拉维沃尔",
		["Zekkis"] = "泽基斯",
		["Zolo"] = "祖罗",
		["Zul'Lor"] = "祖罗尔",

--Uldaman
		["Ancient Stone Keeper"] = "古代的石头看守者",
		["Archaedas"] = "阿扎达斯",
		["Baelog"] = "巴尔洛戈",
		["Digmaster Shovelphlange"] = "挖掘专家舒尔弗拉格",
		["Galgann Firehammer"] = "加加恩·火锤",
		["Grimlok"] = "格瑞姆洛克",
		["Ironaya"] = "艾隆纳亚",
		["Obsidian Sentinel"] = "黑曜石哨兵",
		["Revelosh"] = "鲁维罗什",

--Wailing Caverns
		["Boahn"] = "博艾恩",
		["Deviate Faerie Dragon"] = "变异精灵龙",
		["Kresh"] = "克雷什",
		["Lady Anacondra"] = "安娜科德拉",
		["Lord Cobrahn"] = "考布莱恩",
		["Lord Pythas"] = "皮萨斯",
		["Lord Serpentis"] = "瑟芬迪斯",
		["Mad Magglish"] = "疯狂的马格利什",
		["Mutanus the Devourer"] = "吞噬者穆坦努斯",
		["Skum"] = "斯卡姆",
		["Trigore the Lasher"] = "鞭笞者特里高雷",
		["Verdan the Everliving"] = "永生者沃尔丹",

--World Bosses
		["Avalanchion"] = "阿瓦兰奇奥",
		["Azuregos"] = "艾索雷葛斯",
		["Baron Charr"] = "火焰男爵查尔",
		["Baron Kazum"] = "卡苏姆男爵",
		["Doom Lord Kazzak"] = "末日领主卡扎克",
		["Doomwalker"] = "末日行者",
		["Emeriss"] = "艾莫莉丝",
		["High Marshal Whirlaxis"] = "大元帅维拉希斯",
		["Lethon"] = "莱索恩",
		["Lord Skwol"] = "斯古恩男爵",
		["Prince Skaldrenox"] = "斯卡德诺克斯王子",
		["Princess Tempestria"] = "泰比斯蒂亚公主",
		["Taerar"] = "泰拉尔",
		["The Windreaver"] = "烈风掠夺者",
		["Ysondre"] = "伊森德雷",

--Zul'Aman Add new bosses for 2.3
		["Akil'zon"] = "埃基尔松",
		["Halazzi"] = "哈尔拉兹",
		["Jan'alai"] = "加亚莱",
		["Malacrass"] = "玛拉卡斯",
		["Nalorakk"] = "纳洛拉克",
		["Zul'jin"] = "祖尔金",
		["Hex Lord Malacrass"] = "妖术领主玛拉卡斯",

--Zul'Farrak
		["Antu'sul"] = "安图苏尔",
		["Chief Ukorz Sandscalp"] = "乌克兹·沙顶",
		["Dustwraith"] = "灰尘怨灵",
		["Gahz'rilla"] = "加兹瑞拉",
		["Hydromancer Velratha"] = "水占师维蕾萨",
		["Murta Grimgut"] = "穆尔塔",
		["Nekrum Gutchewer"] = "耐克鲁姆",
		["Oro Eyegouge"] = "欧罗·血眼",
		["Ruuzlu"] = "卢兹鲁",
		["Sandarr Dunereaver"] = "杉达尔·沙掠者",
		["Sandfury Executioner"] = "沙怒刽子手",
		["Sergeant Bly"] = "布莱中士",
		["Shadowpriest Sezz'ziz"] = "暗影祭司塞瑟斯",
		["Theka the Martyr"] = "殉教者塞卡",
		["Witch Doctor Zum'rah"] = "巫医祖穆拉恩",
		["Zerillis"] = "泽雷利斯",
		["Zul'Farrak Dead Hero"] = "祖尔法拉克阵亡英雄",

--Zul'Gurub
		["Bloodlord Mandokir"] = "血领主曼多基尔",
		["Gahz'ranka"] = "加兹兰卡",
		["Gri'lek"] = "格里雷克",
		["Hakkar"] = "哈卡",
		["Hazza'rah"] = "哈扎拉尔",
		["High Priest Thekal"] = "高阶祭司塞卡尔",
		["High Priest Venoxis"] = "高阶祭司温诺希斯",
		["High Priestess Arlokk"] = "高阶祭司娅尔罗",
		["High Priestess Jeklik"] = "高阶祭司耶克里克",
		["High Priestess Mar'li"] = "高阶祭司玛尔里",
		["Jin'do the Hexxer"] = "妖术师金度",
		["Renataki"] = "雷纳塔基",
		["Wushoolay"] = "乌苏雷",

--Ring of Blood (where? an instnace? should be in other file?)
		["Brokentoe"] = "断蹄",
		["Mogor"] = "穆戈尔",
		["Murkblood Twin"] = "暗血双子",
		["Murkblood Twins"] = "暗血双子",
		["Rokdar the Sundered Lord"] = "裂石之王洛卡达尔",
		["Skra'gath"] = "瑟克拉加斯",
		["The Blue Brothers"] = "The Blue Brothers",
		["Warmaul Champion"] = "战槌勇士",
	}
elseif GAME_LOCALE == "zhTW" then
	lib:SetCurrentTranslations {
--Ahn'Qiraj
		["Anubisath Defender"] = "阿努比薩斯防衛者",
		["Battleguard Sartura"] = "沙爾圖拉",
		["C'Thun"] = "克蘇恩",
		["Emperor Vek'lor"] = "維克洛爾大帝",
		["Emperor Vek'nilash"] = "維克尼拉斯大帝",
		["Eye of C'Thun"] = "克蘇恩之眼",
		["Fankriss the Unyielding"] = "不屈的范克里斯",
		["Lord Kri"] = "克里領主",
		["Ouro"] = "奧羅",
		["Princess Huhuran"] = "哈霍蘭公主",
		["Princess Yauj"] = "亞爾基公主",
		["The Bug Family"] = "蟲子家族",
		["The Prophet Skeram"] = "預言者斯克拉姆",
		["The Twin Emperors"] = "雙子皇帝",
		["Vem"] = "維姆",
		["Viscidus"] = "維希度斯",

--Auchindoun
--Auchenai Crypts
		["Exarch Maladaar"] = "主教瑪拉達爾",
		["Shirrak the Dead Watcher"] = "死亡看守者辛瑞克",
--Mana-Tombs
		["Nexus-Prince Shaffar"] = "奈薩斯王子薩法爾",
		["Pandemonius"] = "班提蒙尼厄斯",
		["Tavarok"] = "塔瓦洛克",
--Shadow Labyrinth
		["Ambassador Hellmaw"] = "海爾瑪大使",
		["Blackheart the Inciter"] = "煽動者黑心",
		["Grandmaster Vorpil"] = "領導者瓦皮歐",
		["Murmur"] = "莫爾墨",
--Sethekk Halls
		["Anzu"] = "安祖",
		["Darkweaver Syth"] = "暗法師希斯",
		["Talon King Ikiss"] = "鷹王伊奇斯",

--Blackfathom Deeps
		["Aku'mai"] = "阿庫麥爾",
		["Baron Aquanis"] = "阿奎尼斯男爵",
		["Gelihast"] = "格里哈斯特",
		["Ghamoo-ra"] = "加摩拉",
		["Lady Sarevess"] = "薩利維絲女士",
		["Old Serra'kis"] = "瑟拉吉斯",
		["Twilight Lord Kelris"] = "暮光領主克爾里斯",

--Blackrock Depths
		["Ambassador Flamelash"] = "弗萊拉斯大使",
		["Anger'rel"] = "安格雷爾",
		["Anub'shiah"] = "阿努希爾",
		["Bael'Gar"] = "貝爾加",
		["Chest of The Seven"] = "七賢之箱",
		["Doom'rel"] = "杜姆雷爾",
		["Dope'rel"] = "多普雷爾",
		["Emperor Dagran Thaurissan"] = "達格蘭·索瑞森大帝",
		["Eviscerator"] = "剜眼者",
		["Fineous Darkvire"] = "弗諾斯·達克維爾",
		["General Angerforge"] = "安格弗將軍",
		["Gloom'rel"] = "格魯雷爾",
		["Golem Lord Argelmach"] = "魔像領主阿格曼奇",
		["Gorosh the Dervish"] = "『修行者』高羅什",
		["Grizzle"] = "格里茲爾",
		["Hate'rel"] = "黑特雷爾",
		["Hedrum the Creeper"] = "『爬行者』赫杜姆",
		["High Interrogator Gerstahn"] = "審訊官格斯塔恩",
		["High Priestess of Thaurissan"] = "索瑞森高階女祭司",
		["Houndmaster Grebmar"] = "馴犬者格雷布瑪爾",
		["Hurley Blackbreath"] = "霍爾雷·黑鬚",
		["Lord Incendius"] = "伊森迪奧斯領主",
		["Lord Roccor"] = "洛考爾領主",
		["Magmus"] = "瑪格姆斯",
		["Ok'thor the Breaker"] = "『破壞者』奧科索爾",
		["Panzor the Invincible"] = "無敵的潘佐爾",
		["Phalanx"] = "法拉克斯",
		["Plugger Spazzring"] = "普拉格",
		["Princess Moira Bronzebeard"] = "茉艾拉·銅鬚公主",
		["Pyromancer Loregrain"] = "控火師羅格雷恩",
		["Ribbly Screwspigot"] = "雷布里·斯庫比格特",
		["Seeth'rel"] = "西斯雷爾",
		["The Seven Dwarves"] = "七賢人",
		["Verek"] = "維雷克",
		["Vile'rel"] = "瓦勒雷爾",
		["Warder Stilgiss"] = "守衛斯迪爾基斯",

--Blackrock Spire
--Lower
		["Bannok Grimaxe"] = "班諾克·巨斧",
		["Burning Felguard"] = "燃燒惡魔守衛",
		["Crystal Fang"] = "水晶之牙",
		["Ghok Bashguud"] = "霍克·巴什古德",
		["Gizrul the Slavener"] = "『奴役者』基茲盧爾",
		["Halycon"] = "哈雷肯",
		["Highlord Omokk"] = "歐莫克大王",
		["Mor Grayhoof"] = "莫爾·灰蹄",
		["Mother Smolderweb"] = "煙網蛛后",
		["Overlord Wyrmthalak"] = "維姆薩拉克主宰",
		["Quartermaster Zigris"] = "軍需官茲格雷斯",
		["Shadow Hunter Vosh'gajin"] = "暗影獵手沃許加斯",
		["Spirestone Battle Lord"] = "尖石戰鬥統帥",
		["Spirestone Butcher"] = "尖石屠夫",
		["Spirestone Lord Magus"] = "尖石首席魔導師",
		["Urok Doomhowl"] = "烏洛克",
		["War Master Voone"] = "指揮官沃恩",
--Upper
		["General Drakkisath"] = "達基薩斯將軍",
		["Goraluk Anvilcrack"] = "古拉魯克",
		["Gyth"] = "蓋斯",
		["Jed Runewatcher"] = "傑德",
		["Lord Valthalak"] = "瓦薩拉克領主",
		["Pyroguard Emberseer"] = "烈焰衛士艾博希爾",
		["Solakar Flamewreath"] = "索拉卡·火冠",
		["The Beast"] = "比斯巨獸",
		["Warchief Rend Blackhand"] = "大酋長雷德·黑手",

--Blackwing Lair
		["Broodlord Lashlayer"] = "龍領主勒西雷爾",
		["Chromaggus"] = "克洛瑪古斯",
		["Ebonroc"] = "埃博諾克",
		["Firemaw"] = "費爾默",
		["Flamegor"] = "弗萊格爾",
		["Grethok the Controller"] = "『控制者』葛瑞托克",
		["Lord Victor Nefarius"] = "維克多·奈法利斯領主",
		["Nefarian"] = "奈法利安",
		["Razorgore the Untamed"] = "狂野的拉佐格爾",
		["Vaelastrasz the Corrupt"] = "墮落的瓦拉斯塔茲",

--Black Temple
		["Essence of Anger"] = "憤怒精華",
		["Essence of Desire"] = "慾望精華",
		["Essence of Suffering"] = "受難精華",
		["Gathios the Shatterer"] = "粉碎者高希歐",
		["Gurtogg Bloodboil"] = "葛塔格·血沸",
		["High Nethermancer Zerevor"] = "高等虛空術師札瑞佛",
		["High Warlord Naj'entus"] = "高階督軍納珍塔斯",
		["Illidan Stormrage"] = "伊利丹·怒風",
		["Illidari Council"] = "伊利達瑞議事",
		["Lady Malande"] = "瑪蘭黛女士",
		["Mother Shahraz"] = "薩拉茲女士",
		["Reliquary of Souls"] = "靈魂之匣",
		["Shade of Akama"] = "阿卡瑪的黑暗面",
		["Supremus"] = "瑟普莫斯",
		["Teron Gorefiend"] = "泰朗·血魔",
		["The Illidari Council"] = "伊利達瑞議事",
		["Veras Darkshadow"] = "維拉斯·深影",

--Caverns of Time
--Old Hillsbrad Foothills
		["Captain Skarloc"] = "史卡拉克上尉",
		["Epoch Hunter"] = "紀元狩獵者",
		["Lieutenant Drake"] = "中尉崔克",
--The Black Morass
		["Aeonus"] = "艾奧那斯",
		["Chrono Lord Deja"] = "時間領主迪賈",
		["Medivh"] = "麥迪文",
		["Temporus"] = "坦普拉斯",

--Coilfang Reservoir
--Serpentshrine Cavern
		["Coilfang Elite"] = "盤牙精英",
		["Coilfang Strider"] = "盤牙旅行者",
		["Fathom-Lord Karathress"] = "深淵之王卡拉薩瑞斯",
		["Hydross the Unstable"] = "不穩定者海卓司",
		["Lady Vashj"] = "瓦許女士",
		["Leotheras the Blind"] = "『盲目者』李奧薩拉斯",
		["Morogrim Tidewalker"] = "莫洛葛利姆·潮行者",
		["Pure Spawn of Hydross"] = "純正的海卓司子嗣",
		["Shadow of Leotheras"] = "李奧薩拉斯的陰影",
		["Tainted Spawn of Hydross"] = "腐化的海卓司之子",
		["The Lurker Below"] = "海底潛伏者",
		["Tidewalker Lurker"] = "潮行者潛伏者",
--The Slave Pens
		["Mennu the Betrayer"] = "背叛者曼紐",
		["Quagmirran"] = "奎克米瑞",
		["Rokmar the Crackler"] = "爆裂者洛克瑪",
--The Steamvault
		["Hydromancer Thespia"] = "海法師希斯比亞",
		["Mekgineer Steamrigger"] = "米克吉勒·蒸氣操控者",
		["Warlord Kalithresh"] = "督軍卡利斯瑞",
--The Underbog
		["Claw"] = "裂爪",
		["Ghaz'an"] = "高薩安",
		["Hungarfen"] = "飢餓之牙",
		["Overseer Tidewrath"] = "監督者泰洛斯",
		["Swamplord Musel'ek"] = "沼澤之王莫斯萊克",
		["The Black Stalker"] = "黑色捕獵者",

--Dire Maul
--Arena
		["Mushgog"] = "姆斯高格",
		["Skarr the Unbreakable"] = "無敵的斯卡爾",
		["The Razza"] = "拉札",
--East
		["Alzzin the Wildshaper"] = "『狂野變形者』奧茲恩",
		["Hydrospawn"] = "海多斯博恩",
		["Isalien"] = "依薩利恩",
		["Lethtendris"] = "蕾瑟塔蒂絲",
		["Pimgib"] = "匹姆吉布",
		["Pusillin"] = "普希林",
		["Zevrim Thornhoof"] = "瑟雷姆·刺蹄",
--North
		["Captain Kromcrush"] = "克羅卡斯",
		["Cho'Rush the Observer"] = "『觀察者』克魯什",
		["Guard Fengus"] = "衛兵芬古斯",
		["Guard Mol'dar"] = "衛兵摩爾達",
		["Guard Slip'kik"] = "衛兵斯里基克",
		["King Gordok"] = "戈多克大王",
		["Knot Thimblejack's Cache"] = "諾特·希姆加克的儲物箱",
		["Stomper Kreeg"] = "踐踏者克雷格",
--West
		["Illyanna Ravenoak"] = "伊琳娜·鴉橡",
		["Immol'thar"] = "伊莫塔爾",
		["Lord Hel'nurath"] = "赫爾努拉斯領主",
		["Magister Kalendris"] = "卡雷迪斯鎮長",
		["Prince Tortheldrin"] = "托塞德林王子",
		["Tendris Warpwood"] = "特迪斯·扭木",
		["Tsu'zee"] = "蘇斯",

--Gnomeregan
		["Crowd Pummeler 9-60"] = "群體打擊者9-60",
		["Dark Iron Ambassador"] = "黑鐵大使",
		["Electrocutioner 6000"] = "電刑器6000型",
		["Grubbis"] = "格魯比斯",
		["Mekgineer Thermaplugg"] = "麥克尼爾·瑟瑪普拉格",
		["Techbot"] = "尖端機器人",
		["Viscous Fallout"] = "粘性輻射塵",

--Gruul's Lair
		["Blindeye the Seer"] = "先知盲眼",
		["Gruul the Dragonkiller"] = "弒龍者戈魯爾",
		["High King Maulgar"] = "大君王莫卡爾",
		["Kiggler the Crazed"] = "瘋癲者奇克勒",
		["Krosh Firehand"] = "克羅斯·火手",
		["Olm the Summoner"] = "召喚者歐莫",

--Hellfire Citadel
--Hellfire Ramparts
		["Nazan"] = "納桑",
		["Omor the Unscarred"] = "無疤者歐瑪爾",
		["Vazruden the Herald"] = "『信使』維斯路登",
		["Vazruden"] = "維斯路登",
		["Watchkeeper Gargolmar"] = "看護者卡爾古瑪",
--Magtheridon's Lair
		["Hellfire Channeler"] = "地獄火導魔師",
		["Magtheridon"] = "瑪瑟里頓",
--The Blood Furnace
		["Broggok"] = "布洛克",
		["Keli'dan the Breaker"] = "『破壞者』凱利丹",
		["The Maker"] = "創造者",
--The Shattered Halls
		["Blood Guard Porung"] = "血衛士波洛克",
		["Grand Warlock Nethekurse"] = "大術士奈德克斯",
		["Warbringer O'mrogg"] = "戰爭製造者·歐姆拉格",
		["Warchief Kargath Bladefist"] = "大酋長卡加斯·刃拳",

--Hyjal Summit
		["Anetheron"] = "安納塞隆",
		["Archimonde"] = "阿克蒙德",
		["Azgalor"] = "亞茲加洛",
		["Kaz'rogal"] = "卡茲洛加",
		["Rage Winterchill"] = "瑞齊·凜冬",

--Karazhan
		["Arcane Watchman"] = "秘法警備者",
		["Attumen the Huntsman"] = "獵人阿圖曼",
		["Chess Event"] = "西洋棋事件",
		["Dorothee"] = "桃樂絲",
		["Dust Covered Chest"] = "滿佈灰塵箱子",
		["Grandmother"] = "外婆",
		["Hyakiss the Lurker"] = "潛伏者亞奇斯",
		["Julianne"] = "茱麗葉",
		["Kil'rek"] = "基瑞克",
		["King Llane Piece"] = "萊恩王棋子",
		["Maiden of Virtue"] = "貞潔聖女",
		["Midnight"] = "午夜",
		["Moroes"] = "摩洛",
		["Netherspite"] = "尼德斯",
		["Nightbane"] = "夜禍",
		["Prince Malchezaar"] = "莫克札王子",
		["Restless Skeleton"] = "永不安息的骷髏",
		["Roar"] = "獅子",
		["Rokad the Ravager"] = "劫毀者拉卡",
		["Romulo & Julianne"] = "羅慕歐與茱麗葉",
		["Romulo"] = "羅慕歐",
		["Shade of Aran"] = "埃蘭之影",
		["Shadikith the Glider"] = "滑翔者薛迪依斯",
		["Strawman"] = "稻草人",
		["Terestian Illhoof"] = "泰瑞斯提安·疫蹄",
		["The Big Bad Wolf"] = "大野狼",
		["The Crone"] = "老巫婆",
		["The Curator"] = "館長",
		["Tinhead"] = "機器人",
		["Tito"] = "多多",
		["Warchief Blackhand Piece"] = "黑手大酋長棋子",

-- Magisters' Terrace
		["Kael'thas Sunstrider"] = "凱爾薩斯·逐日者",
		["Priestess Delrissa"] = "女牧師戴利莎",
		["Selin Fireheart"] = "賽林·炎心",
		["Vexallus"] = "維克索魯斯",

--Maraudon
		["Celebras the Cursed"] = "被詛咒的塞雷布拉斯",
		["Gelk"] = "吉爾克",
		["Kolk"] = "考爾克",
		["Landslide"] = "蘭斯利德",
		["Lord Vyletongue"] = "維利塔恩領主",
		["Magra"] = "瑪格拉",
		["Maraudos"] = "瑪拉多斯",
		["Meshlok the Harvester"] = "『收割者』麥什洛克",
		["Noxxion"] = "諾克賽恩",
		["Princess Theradras"] = "瑟萊德絲公主",
		["Razorlash"] = "銳刺鞭笞者",
		["Rotgrip"] = "洛特格里普",
		["Tinkerer Gizlock"] = "技工吉茲洛克",
		["Veng"] = "溫格",

--Molten Core
		["Baron Geddon"] = "迦頓男爵",
		["Cache of the Firelord"] = "火焰之王的寶箱",
		["Garr"] = "加爾",
		["Gehennas"] = "基赫納斯",
		["Golemagg the Incinerator"] = "『焚化者』古雷曼格",
		["Lucifron"] = "魯西弗隆",
		["Magmadar"] = "瑪格曼達",
		["Majordomo Executus"] = "管理者埃克索圖斯",
		["Ragnaros"] = "拉格納羅斯",
		["Shazzrah"] = "沙斯拉爾",
		["Sulfuron Harbinger"] = "薩弗隆先驅者",

--Naxxramas
		["Anub'Rekhan"] = "阿努比瑞克漢",
		["Deathknight Understudy"] = "死亡騎士實習者",
		["Feugen"] = "伏晨",
		["Four Horsemen Chest"] = "四騎士箱子",
		["Gluth"] = "古魯斯",
		["Gothik the Harvester"] = "『收割者』高希",
		["Grand Widow Faerlina"] = "大寡婦費琳娜",
		["Grobbulus"] = "葛羅巴斯",
		["Heigan the Unclean"] = "『骯髒者』海根",
		["Highlord Mograine"] = "大領主莫格萊尼",
		["Instructor Razuvious"] = "講師拉祖維斯",
		["Kel'Thuzad"] = "科爾蘇加德",
		["Lady Blaumeux"] = "布洛莫斯女士",
		["Loatheb"] = "憎恨者",
		["Maexxna"] = "梅克絲娜",
		["Noth the Plaguebringer"] = "『瘟疫使者』諾斯",
		["Patchwerk"] = "縫補者",
		["Sapphiron"] = "薩菲隆",
		["Sir Zeliek"] = "札里克爵士",
		["Stalagg"] = "斯塔拉格",
		["Thaddius"] = "泰迪斯",
		["Thane Korth'azz"] = "寇斯艾茲族長",
		["The Four Horsemen"] = "四騎士",

--Onyxia's Lair
		["Onyxia"] = "奧妮克希亞",

--Ragefire Chasm
		["Bazzalan"] = "巴札蘭",
		["Jergosh the Invoker"] = "『塑能師』耶戈什",
		["Maur Grimtotem"] = "瑪爾·恐怖圖騰",
		["Taragaman the Hungerer"] = "『飢餓者』塔拉加曼",

--Razorfen Downs
		["Amnennar the Coldbringer"] = "『寒冰使者』亞門納爾",
		["Glutton"] = "暴食者",
		["Mordresh Fire Eye"] = "火眼莫德雷斯",
		["Plaguemaw the Rotting"] = "腐爛的普雷莫爾",
		["Ragglesnout"] = "拉戈斯諾特",
		["Tuten'kash"] = "圖特卡什",

--Razorfen Kraul
		["Agathelos the Raging"] = "暴怒的阿迦賽羅斯",
		["Blind Hunter"] = "盲眼獵手",
		["Charlga Razorflank"] = "卡爾加·刺肋",
		["Death Speaker Jargba"] = "亡語者賈格巴",
		["Earthcaller Halmgar"] = "喚地者哈穆加",
		["Overlord Ramtusk"] = "拉姆塔斯主宰",

--Ruins of Ahn'Qiraj
		["Anubisath Guardian"] = "阿努比薩斯守衛者",
		["Ayamiss the Hunter"] = "『狩獵者』阿亞米斯",
		["Buru the Gorger"] = "『暴食者』布魯",
		["General Rajaxx"] = "拉賈克斯將軍",
		["Kurinnaxx"] = "庫林納克斯",
		["Lieutenant General Andorov"] = "安多洛夫中將",
		["Moam"] = "莫阿姆",
		["Ossirian the Unscarred"] = "『無疤者』奧斯里安",

--Scarlet Monastery
--Armory
		["Herod"] = "赫洛德",
--Cathedral
		["High Inquisitor Fairbanks"] = "高等審判官法爾班克斯",
		["High Inquisitor Whitemane"] = "高等審判官懷特邁恩",
		["Scarlet Commander Mograine"] = "血色十字軍指揮官莫格萊尼",
--Graveyard
		["Azshir the Sleepless"] = "不眠的艾希爾",
		["Bloodmage Thalnos"] = "血法師薩爾諾斯",
		["Fallen Champion"] = "亡靈勇士",
		["Interrogator Vishas"] = "審訊員韋沙斯",
		["Ironspine"] = "鐵脊死靈",
--Library
		["Arcanist Doan"] = "秘法師杜安",
		["Houndmaster Loksey"] = "馴犬者洛克希",

--Scholomance
		["Blood Steward of Kirtonos"] = "基爾圖諾斯的衛士",
		["Darkmaster Gandling"] = "黑暗院長加丁",
		["Death Knight Darkreaver"] = "死亡騎士達克雷爾",
		["Doctor Theolen Krastinov"] = "瑟爾林·卡斯迪諾夫教授",
		["Instructor Malicia"] = "講師瑪麗希亞",
		["Jandice Barov"] = "詹迪斯·巴羅夫",
		["Kirtonos the Herald"] = "傳令官基爾圖諾斯",
		["Kormok"] = "科爾莫克",
		["Lady Illucia Barov"] = "伊露希亞·巴羅夫女士",
		["Lord Alexei Barov"] = "阿萊克斯·巴羅夫領主",
		["Lorekeeper Polkelt"] = "博學者普克爾特",
		["Marduk Blackpool"] = "馬杜克·布萊克波爾",
		["Ras Frostwhisper"] = "萊斯·霜語",
		["Rattlegore"] = "血骨傀儡",
		["The Ravenian"] = "拉文尼亞",
		["Vectus"] = "維克圖斯",

--Shadowfang Keep
		["Archmage Arugal"] = "大法師阿魯高",
		["Arugal's Voidwalker"] = "阿魯高的虛無行者",
		["Baron Silverlaine"] = "席瓦萊恩男爵",
		["Commander Springvale"] = "指揮官斯普林瓦爾",
		["Deathsworn Captain"] = "死亡誓言者隊長",
		["Fenrus the Devourer"] = "『吞噬者』芬魯斯",
		["Odo the Blindwatcher"] = "『盲眼守衛』奧杜",
		["Razorclaw the Butcher"] = "屠夫拉佐克勞",
		["Wolf Master Nandos"] = "狼王南杜斯",

--Stratholme
		["Archivist Galford"] = "檔案管理員加爾福特",
		["Balnazzar"] = "巴納札爾",
		["Baron Rivendare"] = "瑞文戴爾男爵",
		["Baroness Anastari"] = "安娜絲塔麗男爵夫人",
		["Black Guard Swordsmith"] = "黑衣守衛鑄劍師",
		["Cannon Master Willey"] = "砲手威利",
		["Crimson Hammersmith"] = "紅衣鑄錘師",
		["Fras Siabi"] = "弗拉斯·希亞比",
		["Hearthsinger Forresten"] = "弗雷斯特恩",
		["Magistrate Barthilas"] = "巴瑟拉斯鎮長",
		["Maleki the Pallid"] = "蒼白的瑪勒基",
		["Nerub'enkan"] = "奈幽布恩坎",
		["Postmaster Malown"] = "郵差瑪羅恩",
		["Ramstein the Gorger"] = "『暴食者』拉姆斯登",
		["Skul"] = "斯庫爾",
		["Stonespine"] = "石脊",
		["The Unforgiven"] = "不可寬恕者",
		["Timmy the Cruel"] = "悲慘的提米",

--Sunwell Plateau
		["Kalecgos"] = "卡雷苟斯",
		["Sathrovarr the Corruptor"] = "『墮落者』塞斯諾瓦",
		["Brutallus"] = "布魯托魯斯",
		["Felmyst"] = "魔霧",
		["The Eredar Twins"] = "埃雷達爾雙子",
		["Kil'jaeden"] = "基爾加丹",
		["M'uru"] = "莫魯",
		["Entropius"] = "安卓普斯",
		["Lady Sacrolash"] = "莎珂蕾希女士",
		["Grand Warlock Alythess"] = "大術士艾黎瑟絲",

--Tempest Keep
--The Arcatraz
		["Dalliah the Doomsayer"] = "末日預言者達利亞",
		["Harbinger Skyriss"] = "先驅者史蓋力司",
		["Warden Mellichar"] = "看守者米利恰爾",
		["Wrath-Scryer Soccothrates"] = "怒鐮者索寇斯瑞特",
		["Zereketh the Unbound"] = "無約束的希瑞奇斯",
--The Botanica
		["Commander Sarannis"] = "指揮官薩瑞尼斯",
		["High Botanist Freywinn"] = "大植物學家費瑞衛恩",
		["Laj"] = "拉杰",
		["Thorngrin the Tender"] = "『看管者』索古林",
		["Warp Splinter"] = "扭曲分裂者",
--The Eye
		["Al'ar"] = "歐爾",
		["Cosmic Infuser"] = "宇宙灌溉者",
		["Devastation"] = "毀滅",
		["Grand Astromancer Capernian"] = "大星術師卡普尼恩",
		["High Astromancer Solarian"] = "高階星術師索拉瑞恩",
		["Infinity Blades"] = "無盡之刃",
		["Kael'thas Sunstrider"] = "凱爾薩斯·逐日者",
		["Lord Sanguinar"] = "桑古納爾領主",
		["Master Engineer Telonicus"] = "工程大師泰隆尼卡斯",
		["Netherstrand Longbow"] = "虛空之絃長弓",
		["Phaseshift Bulwark"] = "相位壁壘",
		["Solarium Agent"] = "日光之室密探",
		["Solarium Priest"] = "日光之室牧師",
		["Staff of Disintegration"] = "瓦解之杖",
		["Thaladred the Darkener"] = "扭曲預言家薩拉瑞德",
		["Void Reaver"] = "虛無搶奪者",
		["Warp Slicer"] = "扭曲分割者",
--The Mechanar
		["Gatewatcher Gyro-Kill"] = "看守者蓋洛奇歐",
		["Gatewatcher Iron-Hand"] = "看守者鐵手",
		["Mechano-Lord Capacitus"] = "機械王卡帕希特斯",
		["Nethermancer Sepethrea"] = "虛空術師賽菲瑞雅",
		["Pathaleon the Calculator"] = "操縱者帕薩里歐",

--The Deadmines
		["Brainwashed Noble"] = "被洗腦的貴族",
		["Captain Greenskin"] = "綠皮隊長",
		["Cookie"] = "廚師",
		["Edwin VanCleef"] = "艾德溫·范克里夫",
		["Foreman Thistlenettle"] = "工頭希斯耐特",
		["Gilnid"] = "基爾尼格",
		["Marisa du'Paige"] = "瑪里莎·杜派格",
		["Miner Johnson"] = "礦工約翰森",
		["Mr. Smite"] = "重拳先生",
		["Rhahk'Zor"] = "拉克佐",
		["Sneed"] = "斯尼德",
		["Sneed's Shredder"] = "斯尼德的伐木機",

--The Stockade
		["Bazil Thredd"] = "巴基爾·斯瑞德",
		["Bruegal Ironknuckle"] = "布魯戈·艾爾克納寇",
		["Dextren Ward"] = "迪克斯特·瓦德",
		["Hamhock"] = "哈姆霍克",
		["Kam Deepfury"] = "卡姆·深怒",
		["Targorr the Dread"] = "可怕的塔高爾",

--The Temple of Atal'Hakkar
		["Atal'alarion"] = "阿塔拉利恩",
		["Avatar of Hakkar"] = "哈卡的化身",
		["Dreamscythe"] = "德姆塞卡爾",
		["Gasher"] = "加什爾",
		["Hazzas"] = "哈札斯",
		["Hukku"] = "胡庫",
		["Jade"] = "玉龍",
		["Jammal'an the Prophet"] = "『預言者』迦瑪蘭",
		["Kazkaz the Unholy"] = "邪惡的卡薩卡茲",
		["Loro"] = "洛若爾",
		["Mijan"] = "米杉",
		["Morphaz"] = "摩弗拉斯",
		["Ogom the Wretched"] = "可悲的奧戈姆",
		["Shade of Eranikus"] = "伊蘭尼庫斯的陰影",
		["Veyzhak the Cannibal"] = "『食人者』維薩克",
		["Weaver"] = "德拉維沃爾",
		["Zekkis"] = "澤基斯",
		["Zolo"] = "祖羅",
		["Zul'Lor"] = "祖羅爾",

--Uldaman
		["Ancient Stone Keeper"] = "古代的石頭看守者",
		["Archaedas"] = "阿札達斯",
		["Baelog"] = "巴爾洛戈",
		["Digmaster Shovelphlange"] = "挖掘專家舒爾弗拉格",
		["Galgann Firehammer"] = "加加恩·火錘",
		["Grimlok"] = "格瑞姆洛克",
		["Ironaya"] = "艾隆納亞",
		["Obsidian Sentinel"] = "黑曜石哨兵",
		["Revelosh"] = "魯維羅什",

--Wailing Caverns
		["Boahn"] = "博艾恩",
		["Deviate Faerie Dragon"] = "變異精靈龍",
		["Kresh"] = "克雷什",
		["Lady Anacondra"] = "安娜科德拉",
		["Lord Cobrahn"] = "考布萊恩領主",
		["Lord Pythas"] = "皮薩斯領主",
		["Lord Serpentis"] = "瑟芬迪斯領主",
		["Mad Magglish"] = "瘋狂的馬格利什",
		["Mutanus the Devourer"] = "『吞噬者』穆坦努斯",
		["Skum"] = "斯卡姆",
		["Trigore the Lasher"] = "『鞭笞者』特里高雷",
		["Verdan the Everliving"] = "永生的沃爾丹",

--World Bosses
		["Avalanchion"] = "阿瓦蘭奇奧",
		["Azuregos"] = "艾索雷葛斯",
		["Baron Charr"] = "火焰男爵查爾",
		["Baron Kazum"] = "卡蘇姆男爵",
		["Doom Lord Kazzak"] = "毀滅領主卡札克",
		["Doomwalker"] = "厄運行者",
		["Emeriss"] = "艾莫莉絲",
		["High Marshal Whirlaxis"] = "大元帥維拉希斯",
		["Lethon"] = "雷索",
		["Lord Skwol"] = "斯古恩領主",
		["Prince Skaldrenox"] = "斯卡德諾克斯王子",
		["Princess Tempestria"] = "泰比斯蒂亞公主",
		["Taerar"] = "泰拉爾",
		["The Windreaver"] = "烈風搶奪者",
		["Ysondre"] = "伊索德雷",

--Zul'Aman
		["Akil'zon"] = "阿奇爾森",
		["Halazzi"] = "哈拉齊",
		["Jan'alai"] = "賈納雷",
		["Malacrass"] = "瑪拉克雷斯",
		["Nalorakk"] = "納羅拉克",
		["Zul'jin"] = "祖爾金",
		["Hex Lord Malacrass"] = "妖術領主瑪拉克雷斯", -- confirm ?

--Zul'Farrak
		["Antu'sul"] = "安圖蘇爾",
		["Chief Ukorz Sandscalp"] = "烏克茲·沙頂",
		["Dustwraith"] = "灰塵怨靈",
		["Gahz'rilla"] = "加茲瑞拉",
		["Hydromancer Velratha"] = "水占師維蕾薩",
		["Murta Grimgut"] = "莫爾塔",
		["Nekrum Gutchewer"] = "耐克魯姆",
		["Oro Eyegouge"] = "歐魯·鑿眼",
		["Ruuzlu"] = "盧茲魯",
		["Sandarr Dunereaver"] = "杉達爾·沙掠者",
		["Sandfury Executioner"] = "沙怒劊子手",
		["Sergeant Bly"] = "布萊中士",
		["Shadowpriest Sezz'ziz"] = "暗影祭司塞瑟斯",
		["Theka the Martyr"] = "『殉教者』塞卡",
		["Witch Doctor Zum'rah"] = "巫醫·祖穆拉恩",
		["Zerillis"] = "澤雷利斯",
		["Zul'Farrak Dead Hero"] = "祖爾法拉克陣亡英雄",

--Zul'Gurub
		["Bloodlord Mandokir"] = "血領主曼多基爾",
		["Gahz'ranka"] = "加茲蘭卡",
		["Gri'lek"] = "格里雷克",
		["Hakkar"] = "哈卡",
		["Hazza'rah"] = "哈札拉爾",
		["High Priest Thekal"] = "高階祭司塞卡爾",
		["High Priest Venoxis"] = "高階祭司溫諾希斯",
		["High Priestess Arlokk"] = "哈卡萊先知",
		["High Priestess Jeklik"] = "高階祭司耶克里克",
		["High Priestess Mar'li"] = "哈卡萊安魂者",
		["Jin'do the Hexxer"] = "『妖術師』金度",
		["Renataki"] = "雷納塔基",
		["Wushoolay"] = "烏蘇雷",

--Ring of Blood (where? an instnace? should be in other file?)
		["Brokentoe"] = "斷趾",
		["Mogor"] = "莫古",
		["Murkblood Twin"] = "黑暗之血雙子",
		["Murkblood Twins"] = "黑暗之血雙子",
		["Rokdar the Sundered Lord"] = "『碎裂領主』洛克達",
		["Skra'gath"] = "史卡拉克斯",
		["The Blue Brothers"] = "憂鬱兄弟黨",
		["Warmaul Champion"] = "戰槌勇士",
	}
elseif GAME_LOCALE == "koKR" then
	lib:SetCurrentTranslations {
--Ahn'Qiraj
		["Anubisath Defender"] = "아누비사스 문지기",
		["Battleguard Sartura"] = "전투감시병 살투라",
		["C'Thun"] = "쑨",
		["Emperor Vek'lor"] = "제왕 베클로어",
		["Emperor Vek'nilash"] = "제왕 베크닐라쉬",
		["Eye of C'Thun"] = "쑨의 눈",
		["Fankriss the Unyielding"] = "불굴의 판크리스",
		["Lord Kri"] = "군주 크리",
		["Ouro"] = "아우로",
		["Princess Huhuran"] = "공주 후후란",
		["Princess Yauj"] = "공주 야우즈",
		["The Bug Family"] = "벌레 무리",
		["The Prophet Skeram"] = "예언자 스케람",
		["The Twin Emperors"] = "쌍둥이 제왕",
		["Vem"] = "벰",
		["Viscidus"] = "비시디우스",

--Auchindoun
--Auchenai Crypts
		["Exarch Maladaar"] = "총독 말라다르",
		["Shirrak the Dead Watcher"] = "죽음의 감시인 쉴라크",
--Mana-Tombs
		["Nexus-Prince Shaffar"] = "연합왕자 샤파르",
		["Pandemonius"] = "팬더모니우스",
		["Tavarok"] = "타바로크",
--Shadow Labyrinth
		["Ambassador Hellmaw"] = "사자 지옥아귀",
		["Blackheart the Inciter"] = "선동자 검은심장",
		["Grandmaster Vorpil"] = "단장 보르필",
		["Murmur"] = "울림",
--Sethekk Halls
		["Anzu"] = "안주", --summoned boss
		["Darkweaver Syth"] = "흑마술사 시스",
		["Talon King Ikiss"] = "갈퀴대왕 이키스",

--Blackfathom Deeps
		["Aku'mai"] = "아쿠마이",
		["Baron Aquanis"] = "남작 아쿠아니스",
		["Gelihast"] = "겔리하스트",
		["Ghamoo-ra"] = "가무라 ",
		["Lady Sarevess"] = "여왕 사레베스",
		["Old Serra'kis"] = "늙은 세라키스",
		["Twilight Lord Kelris"] = "황혼의 군주 켈리스",

--Blackrock Depths
		["Ambassador Flamelash"] = "사자 화염채찍",
		["Anger'rel"] = "격노의 문지기",
		["Anub'shiah"] = "아눕쉬아",
		["Bael'Gar"] = "벨가르",
		["Chest of The Seven"] = "Chest of The Seven",
		["Doom'rel"] = "운명의 문지기",
		["Dope'rel"] = "최면의 문지기",
		["Emperor Dagran Thaurissan"] = "제왕 다그란 타우릿산",
		["Eviscerator"] = "적출자",
		["Fineous Darkvire"] = "파이너스 다크바이어",
		["General Angerforge"] = "사령관 앵거포지",
		["Gloom'rel"] = "그늘의 문지기",
		["Golem Lord Argelmach"] = "골렘군주 아젤마크",
		["Gorosh the Dervish"] = "광신자 고로쉬", --check
		["Grizzle"] = "그리즐",
		["Hate'rel"] = "증오의 문지기",
		["Hedrum the Creeper"] = "왕거미 헤드룸",
		["High Interrogator Gerstahn"] = "대심문관 게르스탄",
		["High Priestess of Thaurissan"] = "타우릿산의 대여사제",
		["Houndmaster Grebmar"] = "사냥개조련사 그렙마르",
		["Hurley Blackbreath"] = "헐레이 블랙브레스",
		["Lord Incendius"] = "군주 인센디우스",
		["Lord Roccor"] = "불의군주 록코르",
		["Magmus"] = "마그무스",
		["Ok'thor the Breaker"] = "파괴자 오크토르",
		["Panzor the Invincible"] = "무적의 판저",
		["Phalanx"] = "팔란스",
		["Plugger Spazzring"] = "플러거스파즈링",
		["Princess Moira Bronzebeard"] = "공주 모이라 브론즈비어드",
		["Pyromancer Loregrain"] = "화염술사 로어그레인",
		["Ribbly Screwspigot"] = "리블리 스크류스피곳",
		["Seeth'rel"] = "불안의 문지기",
		["The Seven Dwarves"] = "The Seven Dwarves",
		["Verek"] = "베레크",
		["Vile'rel"] = "타락의 문지기",
		["Warder Stilgiss"] = "문지기 스틸기스",

--Blackrock Spire
--Lower
		["Bannok Grimaxe"] = "반노크 그림액스",
		["Burning Felguard"] = "불타는 지옥수호병",
		["Crystal Fang"] = "수정 맹독 거미",
		["Ghok Bashguud"] = "고크 배시구드",
		["Gizrul the Slavener"] = "흉포한 기즈룰",
		["Halycon"] = "할리콘",
		["Highlord Omokk"] = "대군주 오모크",
		["Mor Grayhoof"] = "모르 그레이후프",
		["Mother Smolderweb"] = "여왕 불그물거미",
		["Overlord Wyrmthalak"] = "대군주 윔타라크",
		["Quartermaster Zigris"] = "병참장교 지그리스",
		["Shadow Hunter Vosh'gajin"] = "어둠사냥꾼 보쉬가진",
		["Spirestone Battle Lord"] = "뾰족바위일족 전투대장",
		["Spirestone Butcher"] = "뾰족바위일족 학살자",
		["Spirestone Lord Magus"] = "뾰족바위일족 마법사장",
		["Urok Doomhowl"] = "우르크 둠하울",
		["War Master Voone"] = "대장군 부네",
--Upper
		["General Drakkisath"] = "사령관 드라키사스",
		["Goraluk Anvilcrack"] = "고랄루크 앤빌크랙",
		["Gyth"] = "기스",
		["Jed Runewatcher"] = "제드 룬와처",
		["Lord Valthalak"] = "군주 발타라크",
		["Pyroguard Emberseer"] = "불의 수호자 엠버시어",
		["Solakar Flamewreath"] = "화염고리 솔라카르",
		["The Beast"] = "괴수",
		["Warchief Rend Blackhand"] = "대족장 렌드 블랙핸드",

--Blackwing Lair
		["Broodlord Lashlayer"] = "용기대장 래쉬레이어",
		["Chromaggus"] = "크로마구스",
		["Ebonroc"] = "에본로크",
		["Firemaw"] = "화염아귀",
		["Flamegor"] = "플레임고르",
		["Grethok the Controller"] = "감시자 그레토크",
		["Lord Victor Nefarius"] = "군주 빅터 네파리우스",
		["Nefarian"] = "네파리안",
		["Razorgore the Untamed"] = "폭군 서슬송곳니",
		["Vaelastrasz the Corrupt"] = "타락한 밸라스트라즈",

--Black Temple
		["Essence of Anger"] = "격노의 정수",
		["Essence of Desire"] = "욕망의 정수",
		["Essence of Suffering"] = "고뇌의 정수",
		["Gathios the Shatterer"] = "파괴자 가디오스",
		["Gurtogg Bloodboil"] = "구르토그 블러드보일", -- check
		["High Nethermancer Zerevor"] = "고위 황천술사 제레보르",
		["High Warlord Naj'entus"] = "대장군 나젠투스",
		["Illidan Stormrage"] = "일리단 스톰레이지",
		["Illidari Council"] = "일리다리 의회",
		["Lady Malande"] = "여군주 말란데",
		["Mother Shahraz"] = "대모 샤라즈",
		["Reliquary of Souls"] = "영혼의 성물함",
		["Shade of Akama"] = "아카마의 망령",
		["Supremus"] = "궁극의 심연",
		["Teron Gorefiend"] = "테론 고어핀드",
		["The Illidari Council"] = "일리다리 의회", -- check
		["Veras Darkshadow"] = "베라스 다크섀도",

--Caverns of Time
--Old Hillsbrad Foothills
		["Captain Skarloc"] = "경비대장 스칼록",
		["Epoch Hunter"] = "시대의 사냥꾼",
		["Lieutenant Drake"] = "부관 드레이크",
--The Black Morass
		["Aeonus"] = "아에누스",
		["Chrono Lord Deja"] = "시간의 군주 데자",
		["Medivh"] = "메디브",
		["Temporus"] = "템퍼루스",

--Coilfang Reservoir
--Serpentshrine Cavern
		["Coilfang Elite"] = "갈퀴송곳니 정예병",
		["Coilfang Strider"] = "갈퀴송곳니 포자손",
		["Fathom-Lord Karathress"] = "심연의 군주 카라드레스",
		["Hydross the Unstable"] = "불안정한 히드로스",
		["Lady Vashj"] = "여군주 바쉬",
		["Leotheras the Blind"] = "눈먼 레오테라스",
		["Morogrim Tidewalker"] = "겅둥파도 모로그림",
		["Pure Spawn of Hydross"] = "순수한 히드로스의 피조물",
		["Shadow of Leotheras"] = "레오테라스의 그림자",
		["Tainted Spawn of Hydross"] = "오염된 히드로스의 피조물",
		["The Lurker Below"] = "심연의 잠복꾼",
		["Tidewalker Lurker"] = "겅둥파도 잠복꾼",
--The Slave Pens
		["Mennu the Betrayer"] = "배반자 멘누",
		["Quagmirran"] = "쿠아그미란",
		["Rokmar the Crackler"] = "딱딱이 로크마르",
--The Steamvault
		["Hydromancer Thespia"] = "풍수사 세스피아",
		["Mekgineer Steamrigger"] = "기계공학자 스팀리거",
		["Warlord Kalithresh"] = "장군 칼리스레쉬",
--The Underbog
		["Claw"] = "클로",
		["Ghaz'an"] = "가즈안",
		["Hungarfen"] = "헝가르펜",
		["Overseer Tidewrath"] = "우두머리 성난파도",
		["Swamplord Musel'ek"] = "늪군주 뮤즐레크",
		["The Black Stalker"] = "검은 추적자",

--Dire Maul
--Arena
		["Mushgog"] = "머쉬고그",
		["Skarr the Unbreakable"] = "무적의 스카르",
		["The Razza"] = "라자",
--East
		["Alzzin the Wildshaper"] = "칼날바람 알진",
		["Hydrospawn"] = "히드로스폰",
		["Isalien"] = "이살리엔",
		["Lethtendris"] = "레스텐드리스",
		["Pimgib"] = "핌기브",
		["Pusillin"] = "푸실린",
		["Zevrim Thornhoof"] = "제브림 쏜후프",
--North
		["Captain Kromcrush"] = "대장 크롬크러쉬",
		["Cho'Rush the Observer"] = "정찰병 초루쉬",
		["Guard Fengus"] = "경비병 펜구스",
		["Guard Mol'dar"] = "경비병 몰다르",
		["Guard Slip'kik"] = "경기병 슬립킥",
		["King Gordok"] = "왕 고르독",
		["Knot Thimblejack's Cache"] = "노트 팀블젝의 은닉품", -- check
		["Stomper Kreeg"] = "천둥발 크리그",
--West
		["Illyanna Ravenoak"] = "일샨나 레이븐호크",
		["Immol'thar"] = "이몰타르",
		["Lord Hel'nurath"] = "군주 헬누라스",
		["Magister Kalendris"] = "마법사 칼렌드리스",
		["Prince Tortheldrin"] = "왕자 토르텔드린",
		["Tendris Warpwood"] = "굽이나무 텐드리스",
		["Tsu'zee"] = "츄지",

--Gnomeregan
		["Crowd Pummeler 9-60"] = "고철 압축기 9-60",
		["Dark Iron Ambassador"] = "검은무쇠단 사절",
		["Electrocutioner 6000"] = "기계화 문지기 6000",
		["Grubbis"] = "그루비스 ",
		["Mekgineer Thermaplugg"] = "멕기니어 텔마플러그",
		["Techbot"] = "첨단로봇",
		["Viscous Fallout"] = "방사성 폐기물",

--Gruul's Lair
		["Blindeye the Seer"] = "현자 블라인드아이",
		["Gruul the Dragonkiller"] = "용 학살자 그룰",
		["High King Maulgar"] = "왕중왕 마울가르",
		["Kiggler the Crazed"] = "광기의 키글러",
		["Krosh Firehand"] = "크로쉬 파이어핸드",
		["Olm the Summoner"] = "소환사 올름",

--Hellfire Citadel
--Hellfire Ramparts
		["Nazan"] = "나잔",
		["Omor the Unscarred"] = "무적의 오모르",
		["Vazruden the Herald"] = "사자 바즈루덴",
		["Vazruden"] = "바즈루덴",
		["Watchkeeper Gargolmar"] = "감시자 가르골마르",
--Magtheridon's Lair
		["Hellfire Channeler"] = "지옥불 역술사",
		["Magtheridon"] = "마그테리돈",
--The Blood Furnace
		["Broggok"] = "브로고크",
		["Keli'dan the Breaker"] = "파괴자 켈리단",
		["The Maker"] = "재앙의 창조자",
--The Shattered Halls
		["Blood Guard Porung"] = "혈투사 포룽",
		["Grand Warlock Nethekurse"] = "대흑마법사 네더쿠르스",
		["Warbringer O'mrogg"] = "돌격대장 오므로그",
		["Warchief Kargath Bladefist"] = "대족장 카르가스 블레이드피스트",

--Hyjal Summit
		["Anetheron"] = "아네테론",
		["Archimonde"] = "아키몬드",
		["Azgalor"] = "아즈갈로",
		["Kaz'rogal"] = "카즈로갈",
		["Rage Winterchill"] = "격노한 윈터칠",

--Karazhan
		["Arcane Watchman"] = "비전 보초",
		["Attumen the Huntsman"] = "사냥꾼 어튜멘",
		["Chess Event"] = "Chess Event",
		["Dorothee"] = "도로시",
		["Dust Covered Chest"] = "Dust Covered Chest",
		["Grandmother"] = "할머니",
		["Hyakiss the Lurker"] = "잠복꾼 히아키스",
		["Julianne"] = "줄리엔",
		["Kil'rek"] = "킬렉",
		["King Llane Piece"] = "국왕 레인",
		["Maiden of Virtue"] = "고결의 여신",
		["Midnight"] = "천둥이",
		["Moroes"] = "모로스",
		["Netherspite"] = "황천의 원령",
		["Nightbane"] = "파멸의 어둠",
		["Prince Malchezaar"] = "공작 말체자르",
		["Restless Skeleton"] = "잠 못 드는 해골",
		["Roar"] = "어흥이",
		["Rokad the Ravager"] = "파괴자 로카드",
		["Romulo & Julianne"] = "로밀로 & 줄리엔",
		["Romulo"] = "로밀로",
		["Shade of Aran"] = "아란의 망령",
		["Shadikith the Glider"] = "활강의 샤디키스",
		["Strawman"] = "허수아비",
		["Terestian Illhoof"] = "테레스티안 일후프",
		["The Big Bad Wolf"] = "커다란 나쁜 늑대",
		["The Crone"] = "마녀",
		["The Curator"] = "전시 관리인",
		["Tinhead"] = "양철나무꾼",
		["Tito"] = "티토",
		["Warchief Blackhand Piece"] = "대족장 블랙핸드",

-- Magisters' Terrace
		["Kael'thas Sunstrider"] = "캘타스 선스트라이더",
		["Priestess Delrissa"] = "여사제 델리사",
		["Selin Fireheart"] = "셀린 파이어하트",
		["Vexallus"] = "벡살루스",

--Maraudon
		["Celebras the Cursed"] = "저주받은 셀레브라스",
		["Gelk"] = "겔크",
		["Kolk"] = "콜크",
		["Landslide"] = "산사태",
		["Lord Vyletongue"] = "군주 바일텅",
		["Magra"] = "마그라",
		["Maraudos"] = "마라우도스",
		["Meshlok the Harvester"] = "정원사 메슬로크",
		["Noxxion"] = "녹시온",
		["Princess Theradras"] = "공주 테라드라스",
		["Razorlash"] = "칼날채찍",
		["Rotgrip"] = "썩은 아귀",
		["Tinkerer Gizlock"] = "땜장이 기즐록",
		["Veng"] = "벵",

--Molten Core
		["Baron Geddon"] = "남작 게돈",
		["Cache of the Firelord"] = "Cache of the Firelord",
		["Garr"] = "가르",
		["Gehennas"] = "게헨나스",
		["Golemagg the Incinerator"] = "초열의 골레마그",
		["Lucifron"] = "루시프론",
		["Magmadar"] = "마그마다르",
		["Majordomo Executus"] = "청지기 이그젝큐투스",
		["Ragnaros"] = "라그나로스",
		["Shazzrah"] = "샤즈라",
		["Sulfuron Harbinger"] = "설퍼론 사자",

--Naxxramas
		["Anub'Rekhan"] = "아눕레칸",
		["Deathknight Understudy"] = "죽음의 기사 수습생",
		["Feugen"] = "퓨진",
		["Four Horsemen Chest"] = "Four Horsemen Chest",
		["Gluth"] = "글루스",
		["Gothik the Harvester"] = "영혼의 착취자 고딕",
		["Grand Widow Faerlina"] = "귀부인 팰리나",
		["Grobbulus"] = "그라불루스",
		["Heigan the Unclean"] = "부정의 헤이건",
		["Highlord Mograine"] = "대영주 모그레인",
		["Instructor Razuvious"] = "훈련교관 라주비어스",
		["Kel'Thuzad"] = "켈투자드",
		["Lady Blaumeux"] = "여군주 블라미우스",
		["Loatheb"] = "로데브",
		["Maexxna"] = "맥스나",
		["Noth the Plaguebringer"] = "역병술사 노스",
		["Patchwerk"] = "패치워크",
		["Sapphiron"] = "사피론",
		["Sir Zeliek"] = "젤리에크 경",
		["Stalagg"] = "스탈라그",
		["Thaddius"] = "타디우스",
		["Thane Korth'azz"] = "영주 코스아즈",
		["The Four Horsemen"] = "4인의 기병대",

--Onyxia's Lair
		["Onyxia"] = "오닉시아",

--Ragefire Chasm
		["Bazzalan"] = "바잘란",
		["Jergosh the Invoker"] = "기원사 제로쉬",
		["Maur Grimtotem"] = "마우르 그림토템",
		["Taragaman the Hungerer"] = "욕망의 타라가만",

--Razorfen Downs
		["Amnennar the Coldbringer"] = "혹한의 암네나르",
		["Glutton"] = "게걸먹보",
		["Mordresh Fire Eye"] = "불꽃눈 모드레쉬",
		["Plaguemaw the Rotting"] = "썩어가는 역병아귀",
		["Ragglesnout"] = "너덜주둥이",
		["Tuten'kash"] = "투텐카쉬",

--Razorfen Kraul
		["Agathelos the Raging"] = "흉포한 아가테로스",
		["Blind Hunter"] = "장님 사냥꾼",
		["Charlga Razorflank"] = "서슬깃 차를가",
		["Death Speaker Jargba"] = "죽음의 예언자 잘그바",
		["Earthcaller Halmgar"] = "대지술사 함가르",
		["Overlord Ramtusk"] = "대군주 램터스크",

--Ruins of Ahn'Qiraj
		["Anubisath Guardian"] = "아누비사스 감시자",
		["Ayamiss the Hunter"] = "사냥꾼 아야미스",
		["Buru the Gorger"] = "먹보 부루",
		["General Rajaxx"] = "장군 라작스",
		["Kurinnaxx"] = "쿠린낙스",
		["Lieutenant General Andorov"] = "사령관 안도로브",
		["Moam"] = "모암",
		["Ossirian the Unscarred"] = "무적의 오시리안",

--Scarlet Monastery
--Armory
		["Herod"] = "헤로드",
--Cathedral
		["High Inquisitor Fairbanks"] = "종교재판관 페어뱅크스",
		["High Inquisitor Whitemane"] = "종교재판관 화이트메인",
		["Scarlet Commander Mograine"] = "붉은십자군 사령관 모그레인",
--Graveyard
		["Azshir the Sleepless"] = "잠들지 않는 아즈시르",
		["Bloodmage Thalnos"] = "혈법사 탈노스",
		["Fallen Champion"] = "타락한 용사",
		["Interrogator Vishas"] = "심문관 비샤스",
		["Ironspine"] = "무쇠해골",
--Library
		["Arcanist Doan"] = "신비술사 도안",
		["Houndmaster Loksey"] = "사냥개 조련사 록시",

--Scholomance
		["Blood Steward of Kirtonos"] = "키르토노스의 혈지기",
		["Darkmaster Gandling"] = "암흑스승 간틀링",
		["Death Knight Darkreaver"] = "죽음의 기사 다크리버",
		["Doctor Theolen Krastinov"] = "학자 테올린 크라스티노브",
		["Instructor Malicia"] = "조교 말리시아",
		["Jandice Barov"] = "잔다이스 바로브",
		["Kirtonos the Herald"] = "사자 키르토노스",
		["Kormok"] = "코르모크",
		["Lady Illucia Barov"] = "여군주 일루시아 바로브",
		["Lord Alexei Barov"] = "군주 알렉세이 바로브",
		["Lorekeeper Polkelt"] = "현자 폴켈트",
		["Marduk Blackpool"] = "마르두크 블랙풀",
		["Ras Frostwhisper"] = "라스 프로스트위스퍼",
		["Rattlegore"] = "들창어금니",
		["The Ravenian"] = "라베니안",
		["Vectus"] = "벡투스",

--Shadowfang Keep
		["Archmage Arugal"] = "대마법사 아루갈",
		["Arugal's Voidwalker"] = "아루갈의 보이드워커",
		["Baron Silverlaine"] = "남작 실버레인",
		["Commander Springvale"] = "사령관 스프링베일",
		["Deathsworn Captain"] = "죽음의 경비대장", -- check
		["Fenrus the Devourer"] = "파멸의 펜루스",
		["Odo the Blindwatcher"] = "눈먼감시자 오도",
		["Razorclaw the Butcher"] = "도살자 칼날발톱",
		["Wolf Master Nandos"] = "늑대왕 난도스",

--Stratholme
		["Archivist Galford"] = "기록관 갈포드",
		["Balnazzar"] = "발나자르",
		["Baron Rivendare"] = "남작 리븐데어",
		["Baroness Anastari"] = "남작부인 아나스타리",
		["Black Guard Swordsmith"] = "검은호위대 검제작자",
		["Cannon Master Willey"] = "포병대장 윌리",
		["Crimson Hammersmith"] = "진홍십자군 대장장이",
		["Fras Siabi"] = "프라스 샤비",
		["Hearthsinger Forresten"] = "하스싱어 포레스턴",
		["Magistrate Barthilas"] = "집정관 바실라스",
		["Maleki the Pallid"] = "냉혈한 말레키",
		["Nerub'enkan"] = "네룹엔칸",
		["Postmaster Malown"] = "우체국장 말로운",
		["Ramstein the Gorger"] = "먹보 람스타인",
		["Skul"] = "스컬",
		["Stonespine"] = "뾰족바위",
		["The Unforgiven"] = "용서받지 못한 자",
		["Timmy the Cruel"] = "잔혹한 티미",

--Sunwell Plateau
		["Kalecgos"] = "칼렉고스",
		["Sathrovarr the Corruptor"] = "타락의 사스로바르",
		["Brutallus"] = "브루탈루스",
		["Felmyst"] = "지옥안개",
		["Kil'jaeden"] = "킬제덴",
		["M'uru"] = "므우루",
		["Entropius"] = "엔트로피우스",
		["The Eredar Twins"] = "에레다르 쌍둥이",
		["Lady Sacrolash"] = "여군주 사크로래쉬",
		["Grand Warlock Alythess"] = "대흑마법사 알리테스",

--Tempest Keep
--The Arcatraz
		["Dalliah the Doomsayer"] = "파멸의 예언자 달리아",
		["Harbinger Skyriss"] = "선구자 스키리스",
		["Warden Mellichar"] = "교도관 멜리챠르",
		["Wrath-Scryer Soccothrates"] = "격노의 점술사 소코드라테스",
		["Zereketh the Unbound"] = "속박이 풀린 제레케스",
--The Botanica
		["Commander Sarannis"] = "지휘관 새래니스",
		["High Botanist Freywinn"] = "고위 식물학자 프레이윈",
		["Laj"] = "라즈",
		["Thorngrin the Tender"] = "감시인 쏜그린",
		["Warp Splinter"] = "차원의 분리자",
--The Eye
		["Al'ar"] = "알라르",
		["Cosmic Infuser"] = "붕괴의 지팡이",
		["Devastation"] = "황폐의 도끼",
		["Grand Astromancer Capernian"] = "대점성술사 카퍼니안",
		["High Astromancer Solarian"] = "고위 점성술사 솔라리안",
		["Infinity Blades"] = "무한의 비수",
		["Kael'thas Sunstrider"] = "캘타스 선스트라이더",
		["Lord Sanguinar"] = "군주 생귀나르",
		["Master Engineer Telonicus"] = "수석기술자 텔로니쿠스",
		["Netherstrand Longbow"] = "황천매듭 장궁",
		["Phaseshift Bulwark"] = "위상 변화의 보루방패",
		["Solarium Agent"] = "태양의 전당 요원",
		["Solarium Priest"] = "태양의 전당 사제",
		["Staff of Disintegration"] = "우주 에너지 주입기",
		["Thaladred the Darkener"] = "암흑의 인도자 탈라드레드",
		["Void Reaver"] = "공허의 절단기",
		["Warp Slicer"] = "차원의 절단기",
--The Mechanar
		["Gatewatcher Gyro-Kill"] = "문지기 회전톱날",
		["Gatewatcher Iron-Hand"] = "문지기 무쇠주먹",
		["Mechano-Lord Capacitus"] = "기계군주 캐퍼시투스",
		["Nethermancer Sepethrea"] = "황천술사 세페스레아",
		["Pathaleon the Calculator"] = "철두철미한 파탈리온",

--The Deadmines
		["Brainwashed Noble"] = "세뇌당한 귀족",
		["Captain Greenskin"] = "선장 그린스킨",
		["Cookie"] = "쿠키",
		["Edwin VanCleef"] = "에드윈 밴클리프",
		["Foreman Thistlenettle"] = "현장감독 시슬네틀",
		["Gilnid"] = "길니드",
		["Marisa du'Paige"] = "마리사 두페이지",
		["Miner Johnson"] = "광부 존슨",
		["Mr. Smite"] = "미스터 스마이트",
		["Rhahk'Zor"] = "라크조르",
		["Sneed"] = "스니드",
		["Sneed's Shredder"] = "스니드의 벌목기",

--The Stockade
		["Bazil Thredd"] = "바질 스레드",
		["Bruegal Ironknuckle"] = "무쇠주먹 브루갈",
		["Dextren Ward"] = "덱스트렌 워드",
		["Hamhock"] = "햄혹",
		["Kam Deepfury"] = "캄 딥퓨리",
		["Targorr the Dread"] = "흉악범 타고르",

--The Temple of Atal'Hakkar
		["Atal'alarion"] = "아탈알라리온",
		["Avatar of Hakkar"] = "학카르의 화신",
		["Dreamscythe"] = "드림사이드",
		["Gasher"] = "게이셔",
		["Hazzas"] = "하자스",
		["Hukku"] = "후쿠",
		["Jade"] = "제이드",
		["Jammal'an the Prophet"] = "예언자 잠말란",
		["Kazkaz the Unholy"] = "타락한 카즈카즈",
		["Loro"] = "로로",
		["Mijan"] = "마이잔",
		["Morphaz"] = "몰파즈",
		["Ogom the Wretched"] = "비운의 오그옴",
		["Shade of Eranikus"] = "에라니쿠스의 사령",
		["Veyzhak the Cannibal"] = "식인트롤 베이쟉",
		["Weaver"] = "위버",
		["Zekkis"] = "젝키스",
		["Zolo"] = "졸로",
		["Zul'Lor"] = "줄로",

--Uldaman
		["Ancient Stone Keeper"] = "고대 바위 문지기",
		["Archaedas"] = "아카에다스",
		["Baelog"] = "밸로그",
		["Digmaster Shovelphlange"] = "발굴단장 쇼벨플랜지",
		["Galgann Firehammer"] = "갈간 파이어해머",
		["Grimlok"] = "그림로크",
		["Ironaya"] = "아이로나야",
		["Obsidian Sentinel"] = "흑요석 파수꾼",
		["Revelosh"] = "레벨로쉬",

--Wailing Caverns
		["Boahn"] = "보안",
		["Deviate Faerie Dragon"] = "돌연변이 요정용",
		["Kresh"] = "크레쉬",
		["Lady Anacondra"] = "여군주 아나콘드라",
		["Lord Cobrahn"] = "군주 코브란",
		["Lord Pythas"] = "군주 피타스",
		["Lord Serpentis"] = "군주 서펜디스",
		["Mad Magglish"] = "광기의 매글리시",
		["Mutanus the Devourer"] = "걸신들린 무타누스",
		["Skum"] = "스컴",
		["Trigore the Lasher"] = "채찍꼬리 트리고어",
		["Verdan the Everliving"] = "영생의 베르단",

--World Bosses
		["Avalanchion"] = "아발란치온",
		["Azuregos"] = "아주어고스",
		["Baron Charr"] = "남작 차르",
		["Baron Kazum"] = "남작 카줌",
		["Doom Lord Kazzak"] = "파멸의 군주 카자크",
		["Doomwalker"] = "파멸의 절단기",
		["Emeriss"] = "에메리스",
		["High Marshal Whirlaxis"] = "대장군 휠락시스", -- check
		["Lethon"] = "레손",
		["Lord Skwol"] = "군주 스퀄",
		["Prince Skaldrenox"] = "왕자 스칼레녹스",
		["Princess Tempestria"] = "공주 템페스트리아",
		["Taerar"] = "타에라",
		["The Windreaver"] = "칼날바람",
		["Ysondre"] = "이손드레",

--Zul'Aman
		["Akil'zon"] = "아킬존",
		["Halazzi"] = "할라지",
		["Jan'alai"] = "잔알라이",
		["Malacrass"] = "말라크라스", -- check
		["Nalorakk"] = "날로라크",
		["Zul'jin"] = "줄진",
		["Hex Lord Malacrass"] = "주술 군주 말라크라스",

--Zul'Farrak
		["Antu'sul"] = "안투술",
		["Chief Ukorz Sandscalp"] = "족장 우코르즈 샌드스칼프",
		["Dustwraith"] = "더스트레이스",
		["Gahz'rilla"] = "가즈릴라",
		["Hydromancer Velratha"] = "유체술사 벨라타",
		["Murta Grimgut"] = "무르타 그림구트",
		["Nekrum Gutchewer"] = "네크룸 거트츄어",
		["Oro Eyegouge"] = "오로 아이가우지",
		["Ruuzlu"] = "루즐루",
		["Sandarr Dunereaver"] = "Sandarr Dunereaver",
		["Sandfury Executioner"] = "성난모래부족 사형집행인",
		["Sergeant Bly"] = "하사관 블라이",
		["Shadowpriest Sezz'ziz"] = "어둠의사제 세즈지즈",
		["Theka the Martyr"] = "순교자 데카",
		["Witch Doctor Zum'rah"] = "의술사 줌라",
		["Zerillis"] = "제릴리스",
		["Zul'Farrak Dead Hero"] = "줄파락 죽음의 영웅",

--Zul'Gurub
		["Bloodlord Mandokir"] = "혈군주 만도키르",
		["Gahz'ranka"] = "가즈란카",
		["Gri'lek"] = "그리렉",
		["Hakkar"] = "학카르",
		["Hazza'rah"] = "하자라",
		["High Priest Thekal"] = "대사제 데칼",
		["High Priest Venoxis"] = "대사제 베녹시스",
		["High Priestess Arlokk"] = "대여사제 알로크",
		["High Priestess Jeklik"] = "대여사제 제클릭",
		["High Priestess Mar'li"] = "대여사제 말리",
		["Jin'do the Hexxer"] = "주술사 진도",
		["Renataki"] = "레나타키",
		["Wushoolay"] = "우슬레이",

--Ring of Blood (where? an instance? should be in other file?)
		["Brokentoe"] = "망치발굽",
		["Mogor"] = "모고르",
		["Murkblood Twin"] = "수렁피일족 쌍둥이",
		["Murkblood Twins"] = "수렁피일족 쌍둥이",
		["Rokdar the Sundered Lord"] = "파괴의 군주 로크다르",
		["Skra'gath"] = "스크라가스",
		["The Blue Brothers"] = "푸른 형제들",
		["Warmaul Champion"] = "전쟁망치일족 용사",
	}
elseif GAME_LOCALE == "esES" then
	lib:SetCurrentTranslations {
--Ahn'Qiraj
		["Anubisath Defender"] = "Defensor Anubisath",
		["Battleguard Sartura"] = "Guardia de batalla Sartura",
		["C'Thun"] = "C'Thun",
		["Emperor Vek'lor"] = "Emperador Vek'lor",
		["Emperor Vek'nilash"] = "Emperador Vek'nilash",
		["Eye of C'Thun"] = "Ojo de C'Thun",
		["Fankriss the Unyielding"] = "Fankriss el Implacable",
		["Lord Kri"] = "Lord Kri",
		["Ouro"] = "Ouro",
		["Princess Huhuran"] = "Princesa Huhuran",
		["Princess Yauj"] = "Princesa Yauj",
		["The Bug Family"] = "La Familia Insecto",    -- check
		["The Prophet Skeram"] = "El profeta Skeram",
		["The Twin Emperors"] = "Los Emperadores Gemelos",   -- check
		["Vem"] = "Vem",
		["Viscidus"] = "Viscidus",

--Auchindoun
--Auchenai Crypts
		["Exarch Maladaar"] = "Exarca  Maladaar",
		["Shirrak the Dead Watcher"] = "Shirrak el Vig\195\173a de los Muertos",
--Mana-Tombs
		["Nexus-Prince Shaffar"] = "Pr\195\173ncipe-nexo Shaffar",
		["Pandemonius"] = "Pandemonius",
		["Tavarok"] = "Tavarok",
--Shadow Labyrinth
		["Ambassador Hellmaw"] = "Embajador Faucinferno",
		["Blackheart the Inciter"] = "Negrozón el Incitador",
		["Grandmaster Vorpil"] = "Maestro mayor Vorpil",
		["Murmur"] = "Murmur",
--Sethekk Halls
		["Anzu"] = "Anzu",
		["Darkweaver Syth"] = "Tejeoscuro Syth",
		["Talon King Ikiss"] = "Rey Garra Ikiss",

--Blackfathom Deeps
		["Aku'mai"] = "Aku'mai",
		["Baron Aquanis"] = "Bar\195\179n Aquanis",
		["Gelihast"] = "Gelihast",
		["Ghamoo-ra"] = "Ghamoo-ra",
		["Lady Sarevess"] = "Lady Sarevess",
		["Old Serra'kis"] = "Viejo Serra'kis",
		["Twilight Lord Kelris"] = "Se\195\177or Crepuscular Kelris",

--Blackrock Depths
		["Ambassador Flamelash"] = "Embajador Latifuego",
		["Anger'rel"] = "Anger'rel",
		["Anub'shiah"] = "Anub'shiah",
		["Bael'Gar"] = "Bael'Gar",
		["Chest of The Seven"] = "Tesoro de los Siete",
		["Doom'rel"] = "Doom'rel",
		["Dope'rel"] = "Dope'rel",
		["Emperor Dagran Thaurissan"] = "Emperador Dagran Thaurissan",
		["Eviscerator"] = "Eviscerador",
		["Fineous Darkvire"] = "Finoso Virunegro",
		["General Angerforge"] = "General Forjira",
		["Gloom'rel"] = "Gloom'rel",
		["Golem Lord Argelmach"] = "Se\195\177or G\195\179lem Argelmach",
		["Gorosh the Dervish"] = "Gorosh el Endemoniado",
		["Grizzle"] = "	Grisez",
		["Hate'rel"] = "Odio'rel",
		["Hedrum the Creeper"] = "Hedrum el Trepador",
		["High Interrogator Gerstahn"] = "Alto Interrogador Gerstahn",
		["High Priestess of Thaurissan"] = "Alta Sacerdotisa de Thaurissan", -- check
		["Houndmaster Grebmar"] = "Maestro de canes Grebmar",
		["Hurley Blackbreath"] = "Hurley Negr\195\161lito",
		["Lord Incendius"] = "Lord Incendius",
		["Lord Roccor"] = "Lord Roccor",
		["Magmus"] = "Magmus",
		["Ok'thor the Breaker"] = "Ok'thor el Rompedor",
		["Panzor the Invincible"] = "Panzor el Invencible",
		["Phalanx"] = "Falange",
		["Plugger Spazzring"] = "Plugger Aropatoso",
		["Princess Moira Bronzebeard"] = "Princesa Moira Barbabronce",
		["Pyromancer Loregrain"] = "Pirom\195\161ntico Cultugrano",
		["Ribbly Screwspigot"] = "Ribbly Llavenrosca",
		["Seeth'rel"] = "Seeth'rel",
		["The Seven Dwarves"] = "Los Siete Enanos",  -- check
		["Verek"] = "Verek",
		["Vile'rel"] = "Vil'rel",
		["Warder Stilgiss"] = "Guarda Stilgiss",

--Blackrock Spire
--Lower
		["Bannok Grimaxe"] = "Bannok Hachamacabra",
		["Burning Felguard"] = "Guarda vil ardiente",
		["Crystal Fang"] = "Colmillor de cristal",
		["Ghok Bashguud"] = "Ghok Bashguud",
		["Gizrul the Slavener"] = "Gizrul el Esclavista",
		["Halycon"] = "Halycon",
		["Highlord Omokk"] = "Alto Se\195\177or Omokk",
		["Mor Grayhoof"] = "Mor Grayhoof", -- fix
		["Mother Smolderweb"] = "Madre Telabrasada",
		["Overlord Wyrmthalak"] = "Se\195\177or Supremo Vermiothalak",
		["Quartermaster Zigris"] = "Intendente Zigris",
		["Shadow Hunter Vosh'gajin"] = "Cazador de las Sombras Vosh'gajin",
		["Spirestone Battle Lord"] = "Se\195\177or de batalla Cumbrerroca",
		["Spirestone Butcher"] = "Carnicero Cumbrerroca",
		["Spirestone Lord Magus"] = "Se\195\177or Magus Cumbrerroca",
		["Urok Doomhowl"] = "Urok Aullapocalipsis",
		["War Master Voone"] = "Maestro de guerra Voone",
--Upper
		["General Drakkisath"] = "General Drakkisath",
		["Goraluk Anvilcrack"] = "Goraluk Yunquegrieta",
		["Gyth"] = "Gyth",
		["Jed Runewatcher"] = "Jed vig\195\173a de las runas",
		["Lord Valthalak"] = "Lord Valthalak",
		["Pyroguard Emberseer"] = "Piroguardi\195\161n Brasadivino",
		["Solakar Flamewreath"] = "Solakar Corona de Fuego",
		["The Beast"] = "La Bestia",
		["Warchief Rend Blackhand"] = "Jefe de Guerra Desgarro Pu\195\177o Negro",

--Blackwing Lair
		["Broodlord Lashlayer"] = "Se\195\177or de prole Capazote",
		["Chromaggus"] = "Chromaggus",
		["Ebonroc"] = "Ebonroc",
		["Firemaw"] = "Faucefogo",
		["Flamegor"] = "Flamagor",
		["Grethok the Controller"] = "Grethok el Controlador",
		["Lord Victor Nefarius"] = "Lord V\195\173ctor Nefarius",
		["Nefarian"] = "Nefarian",
		["Razorgore the Untamed"] = "Sangrevaja el Indomable",
		["Vaelastrasz the Corrupt"] = "Vaelastrasz el Corrupto",

--Black Temple
		["Essence of Anger"] = "Esencia de C\195\179lera",
		["Essence of Desire"] = "Esencia de Deseo",
		["Essence of Suffering"] = "Esencia de Sufrimiento",
		["Gathios the Shatterer"] = "Gathios the Shatterer",
		["Gurtogg Bloodboil"] = "Gurtogg Sangre Hirviente",
		["High Nethermancer Zerevor"] = "High Nethermancer Zerevor",
		["High Warlord Naj'entus"] = "Gran Se\195\177or de la Guerra Naj'entus",
		["Illidan Stormrage"] = "Lord Illidan Tempestira",  -- check
		["Illidari Council"] = "Concilio Illidari",
		["Lady Malande"] = "Lady Malande",
		["Mother Shahraz"] = "Madre Shahraz",
		["Reliquary of Souls"] = "Relicario de Almas",
		["Shade of Akama"] = "Sombra de Akama",
		["Supremus"] = "Supremus",
		["Teron Gorefiend"] = "Teron Sanguino",
		["The Illidari Council"] = "El concilio Illidari",
		["Veras Darkshadow"] = "Veras Darkshadow",

--Caverns of Time
--Old Hillsbrad Foothills
		["Captain Skarloc"] = "Capitán Skarloc",
		["Epoch Hunter"] = "Cazador de eras",
		["Lieutenant Drake"] = "Teniente Draco",
--The Black Morass
		["Aeonus"] = "Aeonus",
		["Chrono Lord Deja"] = "Cronolord Deja",
		["Medivh"] = "Medivh",
		["Temporus"] = "Temporus",

--Coilfang Reservoir
--Serpentshrine Cavern
		["Coilfang Elite"] = "Elite Colimillo Torcido",
		["Coilfang Strider"] = "Coilfang Strider",  -- fix
		["Fathom-Lord Karathress"] = "Se\195\177or de la profundidades Karathress",
		["Hydross the Unstable"] = "Hydross el Inestable",
		["Lady Vashj"] = "Lady Vashj",  -- fix
		["Leotheras the Blind"] = "Leotheras el Ciego",
		["Morogrim Tidewalker"] = "Morogrim Levantamareas",
		["Pure Spawn of Hydross"] = "Pure Spawn of Hydross",  -- fix
		["Shadow of Leotheras"] = "Sombra de Leotheras",
		["Tainted Spawn of Hydross"] = "Tainted Spawn of Hydross",  -- fix
		["The Lurker Below"] = "El Rondador de abajo",
		["Tidewalker Lurker"] = "Tidewalker Lurker",   -- fix
--The Slave Pens
		["Mennu the Betrayer"] = "Mennu el Traidor",
		["Quagmirran"] = "Quagmirran",
		["Rokmar the Crackler"] = "Rokmar el Crujidor",
--The Steamvault
		["Hydromancer Thespia"] = "Hidrom\195\161ntico Thespia",
		["Mekgineer Steamrigger"] = "Mekigeniero Vaporino",
		["Warlord Kalithresh"] = "Se\195\177or de la Guerra Kalithresh",
--The Underbog
		["Claw"] = "Zarpa",
		["Ghaz'an"] = "Ghaz'an",
		["Hungarfen"] = "Panthambre",
		["Overseer Tidewrath"] = "Avizor Aleta de Cólera",
		["Swamplord Musel'ek"] = "Se\195\177or del pantano Musel'ek",
		["The Black Stalker"] = "La acechadora negra",

--Dire Maul
--Arena
		["Mushgog"] = "Mushgog",
		["Skarr the Unbreakable"] = "Skarr el Inquebrantable",
		["The Razza"] = "El Razza",
--East
		["Alzzin the Wildshaper"] = "Alzzin el Formaferal",
		["Hydrospawn"] = "Hidromilecio",
		["Isalien"] = "Isalien",
		["Lethtendris"] = "Lethtendris",
		["Pimgib"] = "Pimgib",
		["Pusillin"] = "Pusill\195\173n",
		["Zevrim Thornhoof"] = "Zevrim Pezu\195\177ahendida",
--North
		["Captain Kromcrush"] = "Capit\195\161n Kromcrush",
		["Cho'Rush the Observer"] = "Cho'Rush el Observador",
		["Guard Fengus"] = "Guardia Fengus",
		["Guard Mol'dar"] = "	Guardia Mol'dar",
		["Guard Slip'kik"] = "Guardia Slip'kik",
		["King Gordok"] = "Rey Gordok",
		["Knot Thimblejack's Cache"] = "Carretilla de Knot Llavededo",
		["Stomper Kreeg"] = "Vapuleador Kreeg",
--West
		["Illyanna Ravenoak"] = "Illyanna Roblecuervo",
		["Immol'thar"] = "Immol'thar",
		["Lord Hel'nurath"] = "Lord Hel'nurath",    -- check
		["Magister Kalendris"] = "Magister Kalendris",
		["Prince Tortheldrin"] = "Pr\195\173ncipe Tortheldrin",
		["Tendris Warpwood"] = "Tendris Madeguerra",
		["Tsu'zee"] = "Tsu'zee",

--Gnomeregan
		["Crowd Pummeler 9-60"] = "Gopleamasa 9-60",
		["Dark Iron Ambassador"] = "Embajador Hierro Negro",
		["Electrocutioner 6000"] = "Electrocutor 6000",
		["Grubbis"] = "Grubbis",
		["Mekgineer Thermaplugg"] = "Mekigeniero Termochufe",
		["Techbot"] = "Tecnobot",
		["Viscous Fallout"] = "Radiactivo viscoso",

--Gruul's Lair
		["Blindeye the Seer"] = "Ciego el Vidente",
		["Gruul the Dragonkiller"] = "Gruul el Asesino de Dragones",
		["High King Maulgar"] = "Su majestad Maulgar",
		["Kiggler the Crazed"] = "Kiggler el Enloquecido",
		["Krosh Firehand"] = "Krosh Manofuego",
		["Olm the Summoner"] = "Olm el Invocador",

--Hellfire Citadel
--Hellfire Ramparts
		["Nazan"] = "Nazan",
		["Omor the Unscarred"] = "Omor el Sinmarcas",
		["Vazruden the Herald"] = "Vazruden el Heraldo",
		["Vazruden"] = "Vazruden",
		["Watchkeeper Gargolmar"] = "Guardi\195\161n vig\195\173a Gargolmar",
--Magtheridon's Lair
		["Hellfire Channeler"] = "Canalizador Fuego Infernal",
		["Magtheridon"] = "Magtheridon",
--The Blood Furnace
		["Broggok"] = "Broggok",
		["Keli'dan the Breaker"] = "Keli'dan el Ultrajador",
		["The Maker"] = "El Hacedor",
--The Shattered Halls
		["Blood Guard Porung"] = "Guardia de sangre Porung", -- check
		["Grand Warlock Nethekurse"] = "Brujo supremo Malbisal",
		["Warbringer O'mrogg"] = "Belisario O'mrogg",
		["Warchief Kargath Bladefist"] = "Jefe de Guerra Garrafilada", -- check

--Hyjal Summit
		["Anetheron"] = "Anetheron",
		["Archimonde"] = "Archimonde",
		["Azgalor"] = "Azgalor",
		["Kaz'rogal"] = "Kaz'rogal",
		["Rage Winterchill"] = "Ira Fr\195\173oinvierno",

--Karazhan
		["Arcane Watchman"] = "Vigilante Arcano",
		["Attumen the Huntsman"] = "Attumen el Montero",
		["Chess Event"] = "Evento de ajedrez", -- check
		["Dorothee"] = "Dorothea",
--		["Dust Covered Chest"] = true,
		["Grandmother"] = "Abuela",
		["Hyakiss the Lurker"] = "Hyakiss el Rondador",
		["Julianne"] = "Julianne",
		["Kil'rek"] = "Kil'rek",
		["King Llane Piece"] = "Rey Llane",  -- check - Pieza de...
		["Maiden of Virtue"] = "Doncella de Virtud",
		["Midnight"] = "Medianoche",
		["Moroes"] = "Moroes",
		["Netherspite"] = "Rencor abisal",  -- check
		["Nightbane"] = "Nocturno",  -- check
		["Prince Malchezaar"] = "Pr\195\173ncipe Malchezaar",
		["Restless Skeleton"] = "Esqueleto inquieto",  -- check
		["Roar"] = "Rugido",
		["Rokad the Ravager"] = "Rokad el Devastador",
		["Romulo & Julianne"] = "Romulo y Julianne", -- check
		["Romulo"] = "Romulo",
		["Shade of Aran"] = "Sombra de Aran",
		["Shadikith the Glider"] = "Shadikith the Glider",  -- fix
		["Strawman"] = "Espantapájaros",
		["Terestian Illhoof"] = "Terestian Pezuña Enferma",
		["The Big Bad Wolf"] = "El Gran Lobo Malvado",
		["The Crone"] = "La Vieja Bruja",  -- check
		["The Curator"] = "Curator",
		["Tinhead"] = "Cabezalata",
		["Tito"] = "Tito",
		["Warchief Blackhand Piece"] = "Jefe de Guerra Mano Negra",  -- check - Pieza de...

-- Magisters' Terrace
		--["Kael'thas Sunstrider"] = true,
		["Priestess Delrissa"] = "Priestess Delrissa", -- translate me
		["Selin Fireheart"] = "Selin Fireheart", -- translate me
		["Vexallus"] = "Vexallus", -- translate me

--Maraudon
		["Celebras the Cursed"] = "Celebras el Maldito",
		["Gelk"] = "Gelk",
		["Kolk"] = "Kolk",
		["Landslide"] = "Derrumblo",
		["Lord Vyletongue"] = "Lord Lenguavil",
		["Magra"] = "Magra",
		["Maraudos"] = "Maraudos",
		["Meshlok the Harvester"] = "Meshlok el Cosechador",
		["Noxxion"] = "Noxxion",
		["Princess Theradras"] = "Princesa Theradras",
		["Razorlash"] = "Lativaja",
		["Rotgrip"] = "Escamapodrida",
		["Tinkerer Gizlock"] = "Manitas Gizlock",
		["Veng"] = "Veng",

--Molten Core
		["Baron Geddon"] = "Bar\195\179n Geddon",
--		["Cache of the Firelord"] = true,
		["Garr"] = "Garr",
		["Gehennas"] = "Gehennas",
		["Golemagg the Incinerator"] = "Golemagg el Incinerador",
		["Lucifron"] = "Lucifron",
		["Magmadar"] = "Magmadar",
		["Majordomo Executus"] = "Mayordomo Executus",
		["Ragnaros"] = "Ragnaros",
		["Shazzrah"] = "Shazzrah",
		["Sulfuron Harbinger"] = "Sulfuron Presagista",

--Naxxramas
		["Anub'Rekhan"] = "Anub'Rekhan",
		["Deathknight Understudy"] = "Suplente Caballero de la Muerte",
		["Feugen"] = "Feugen",
--		["Four Horsemen Chest"] = true,
		["Gluth"] = "Gluth",
		["Gothik the Harvester"] = "Gothik el Cosechador",
		["Grand Widow Faerlina"] = "Gran Viuda Faerlina",
		["Grobbulus"] = "Grobbulus",
		["Heigan the Unclean"] = "Heigan el Impuro",
		["Highlord Mograine"] = "Alto Se\195\177or Mograine",
		["Instructor Razuvious"] = "Instructor Razuvious",
		["Kel'Thuzad"] = "Kel'Thuzad",
		["Lady Blaumeux"] = "Lady Blaumeux",
		["Loatheb"] = "Loatheb",
		["Maexxna"] = "Maexxna",
		["Noth the Plaguebringer"] = "Noth el Pesteador",
		["Patchwerk"] = "Remendejo",
		["Sapphiron"] = "Sapphiron",
		["Sir Zeliek"] = "Sir Zeliek",
		["Stalagg"] = "Stalagg",
		["Thaddius"] = "Thaddius",
		["Thane Korth'azz"] = "Thane Korth'azz",
		["The Four Horsemen"] = "Los Cuatro Jinetes",   -- check

--Onyxia's Lair
		["Onyxia"] = "Onyxia",

--Ragefire Chasm
		["Bazzalan"] = "Bazzalan",
		["Jergosh the Invoker"] = "Jergosh el Convocador",
		["Maur Grimtotem"] = "Maur T\195\179tem Siniestro",
		["Taragaman the Hungerer"] = "Taragaman el Hambriento",

--Razorfen Downs
		["Amnennar the Coldbringer"] = "Amnennar el G\195\169lido",
		["Glutton"] = "Glot\195\179n",
		["Mordresh Fire Eye"] = "Mordresh Ojo de Fuego",
		["Plaguemaw the Rotting"] = "Fauzpeste el Putrefacto",
		["Ragglesnout"] = "Morrandrajos",
		["Tuten'kash"] = "Tuten'kash",

--Razorfen Kraul
		["Agathelos the Raging"] = "Agathelos el Furioso",
		["Blind Hunter"] = "Cazador ciego",
		["Charlga Razorflank"] = "Charlga Filonavaja",
		["Death Speaker Jargba"] = "M\195\169dium Jargba",
		["Earthcaller Halmgar"] = "Clamor de Tierra Halmgar",
		["Overlord Ramtusk"] = "Se\195\177or Supremo Colmicarnero",

--Ruins of Ahn'Qiraj
		["Anubisath Guardian"] = "Guardi\195\161n Anubisath",
		["Ayamiss the Hunter"] = "Ayamiss el Cazador",
		["Buru the Gorger"] = "Buru el Manducador",
		["General Rajaxx"] = "General Rajaxx",
		["Kurinnaxx"] = "Kurinnaxx",
		["Lieutenant General Andorov"] = "Teniente General Andorov",
		["Moam"] = "Moam",
		["Ossirian the Unscarred"] = "Osirio el Sinmarcas",

--Scarlet Monastery
--Armory
		["Herod"] = "Herod",
--Cathedral
		["High Inquisitor Fairbanks"] = "Alto Inquisidor Ribalimpia",
		["High Inquisitor Whitemane"] = "Alta Inquisidora Melenablanca",
		["Scarlet Commander Mograine"] = "Comandante Escarlata Mograine",
--Graveyard
		["Azshir the Sleepless"] = "Azshir el Insomne",
		["Bloodmage Thalnos"] = "Mago sangriento Thalnos",
		["Fallen Champion"] = "Campe\195\179n ca\195\173do",
		["Interrogator Vishas"] = "Interrogador Vishas",
		["Ironspine"] = "Dorsacerado",
--Library
		["Arcanist Doan"] = "Arcanista Doan",
		["Houndmaster Loksey"] = "Maestro de canes Loksey",

--Scholomance
		["Blood Steward of Kirtonos"] = "Administrador de sangre de Kirtonos",
		["Darkmaster Gandling"] = "Maestro oscuro Gandling",
		["Death Knight Darkreaver"] = "Caballero de la Muerte Atracoscuro",
		["Doctor Theolen Krastinov"] = "Doctor Theolen Krastinov",
		["Instructor Malicia"] = "Instructor Malicia",
		["Jandice Barov"] = "Jandice Barov",
		["Kirtonos the Herald"] = "Kirtonos el Heraldo",
		["Kormok"] = "Kormok",
		["Lady Illucia Barov"] = "Lady Illucia Barov",
		["Lord Alexei Barov"] = "Lord Alexei Barov",
		["Lorekeeper Polkelt"] = "Tradicionalista Polkelt",
		["Marduk Blackpool"] = "Marduz Pozonegro",
		["Ras Frostwhisper"] = "Ras Levescarcha",
		["Rattlegore"] = "Traquesangre",
		["The Ravenian"] = "El Devorador",
		["Vectus"] = "Vectus",

--Shadowfang Keep
		["Archmage Arugal"] = "Archimago Arugal",
		["Arugal's Voidwalker"] = "Abisario de Arugal",  -- "Arugal's Voidwalker"
		["Baron Silverlaine"] = "Bar\195\179n Filargenta",
		["Commander Springvale"] = "Comandante Vallefont",
		["Deathsworn Captain"] = "Capit\195\161n Juramorte",
		["Fenrus the Devourer"] = "Fenrus el Devorador",
		["Odo the Blindwatcher"] = "Odo el vig\195\173a ciego",
		["Razorclaw the Butcher"] = "Zarpador el Carnicero",
		["Wolf Master Nandos"] = "Maestro de lobos Nandos",

--Stratholme
		["Archivist Galford"] = "Archivista Galford",
		["Balnazzar"] = "Balnazzar",
		["Baron Rivendare"] = "Bar\195\179n Rivendare",
		["Baroness Anastari"] = "Baronesa Anastari",
		["Black Guard Swordsmith"] = "Armero Guardia Negra",
		["Cannon Master Willey"] = "Ca\195\177onero Jefe Willey",
		["Crimson Hammersmith"] = "Forjamartillos Carmes\195\173",
		["Fras Siabi"] = "Fras Siabi",
		["Hearthsinger Forresten"] = "Escupezones Foreste",
		["Magistrate Barthilas"] = "Magistrado Barthilas",
		["Maleki the Pallid"] = "Maleki el P\195\161lido",
		["Nerub'enkan"] = "Nerub'enkan",
		["Postmaster Malown"] = "Jefe de correos Malown",    -- check
		["Ramstein the Gorger"] = "Ramstein el Empachador",
		["Skul"] = "Skul",
		["Stonespine"] = "Pidrespina",
		["The Unforgiven"] = "El Imperdonable",
		["Timmy the Cruel"] = "Timmy el Cruel",

--Sunwell Plateau
		["Kalecgos"] = "Kalecgos",
		["Sathrovarr the Corruptor"] = "Sathrovarr the Corruptor",
		["Brutallus"] = "Brutallus",
		["Felmyst"] = "Felmyst",
		["Kil'jaeden"] = "Kil'jaeden",
		["M'uru"] = "M'uru",
		["The Eredar Twins"] = "The Eredar Twins",
		["Lady Sacrolash"] = "Lady Sacrolash",
		["Grand Warlock Alythess"] = "Grand Warlock Alythess",

--Tempest Keep
--The Arcatraz
		["Dalliah the Doomsayer"] = "Dalliah la Decidora del Destino",
		["Harbinger Skyriss"] = "Presagista Cieloriss",
		["Warden Mellichar"] = "Celador Mellichar",
		["Wrath-Scryer Soccothrates"] = "Ar\195\186spice de c\195\179lera Soccothrates",
		["Zereketh the Unbound"] = "Zereketh el Desatado",
--The Botanica
		["Commander Sarannis"] = "Comandante Sarannis",
		["High Botanist Freywinn"] = "Gran botánico Freywinn",
		["Laj"] = "Laj",
		["Thorngrin the Tender"] = "Thorngrin el Tierno",
		["Warp Splinter"] = "Deshecho de distorsión",  -- check
--The Eye
		["Al'ar"] = "Al'ar",
		["Cosmic Infuser"] = "Infusor cósmico",
		["Devastation"] = "Devastación",
		["Grand Astromancer Capernian"] = "Gran Astromante Capernian",
		["High Astromancer Solarian"] = "Gran astrom\195\161ntico Solarian",
		["Infinity Blades"] = "Infinity Blades",   -- fix
		["Kael'thas Sunstrider"] = "Kael'thas Caminante del Sol",
		["Lord Sanguinar"] = "Lord Sanguinar",
		["Master Engineer Telonicus"] = "Maestro Ingeriero Telonicus",
		["Netherstrand Longbow"] = "Arco largo de fibra abisal",
		["Phaseshift Bulwark"] = "Baluarte de cambio de fase",
		["Solarium Agent"] = "Solarium Agent",  -- fix
		["Solarium Priest"] = "Solarium Priest",  -- fix
		["Staff of Disintegration"] = "Bast\195\179n de desintegraci\195\179n",
		["Thaladred the Darkener"] = "Thaladred el Oscurecedor",
		["Void Reaver"] = "Atracador del Vac\195\173o",
		["Warp Slicer"] = "Cercenadora de distorsi\195\179n",
--The Mechanar
		["Gatewatcher Gyro-Kill"] = "Vígia de las puertas Giromata",
		["Gatewatcher Iron-Hand"] = "Vigía de las puertas Manoyerro",
		["Mechano-Lord Capacitus"] = "Lord-mecano Capacitus",
		["Nethermancer Sepethrea"] = "Abisálico Sepethrea",
		["Pathaleon the Calculator"] = "Panthaleon el Calculador",

--The Deadmines
		["Brainwashed Noble"] = "Noble aducido",
		["Captain Greenskin"] = "Capit\195\161n Verdepel",
		["Cookie"] = "El Chef",
		["Edwin VanCleef"] = "Edwin VanCleef",
		["Foreman Thistlenettle"] = "Supervisor Cardortiga",
		["Gilnid"] = "Gilnid",
		["Marisa du'Paige"] = "Marisa du'Paige",
		["Miner Johnson"] = "Minero Johnson",
		["Mr. Smite"] = "Sr. Golpin",
		["Rhahk'Zor"] = "Rhahk'Zor",
		["Sneed"] = "Sneed",
		["Sneed's Shredder"] = "Machacador de Sneed",

--The Stockade
		["Bazil Thredd"] = "Bazil Thredd",
		["Bruegal Ironknuckle"] = "Bruegal Nudoferro",
		["Dextren Ward"] = "Dextren Tutor",
		["Hamhock"] = "Hamhock",
		["Kam Deepfury"] = "Kam Furiahonda",
		["Targorr the Dread"] = "Targor el Pavoroso",

--The Temple of Atal'Hakkar
		["Atal'alarion"] = "Atal'alarion",
		["Avatar of Hakkar"] = "Avatar de Hakkar",
		["Dreamscythe"] = "Guada\195\177asue\195\177os",
		["Gasher"] = "Gasher",
		["Hazzas"] = "Hazzas",
		["Hukku"] = "Hukku",
--		["Jade"] = true,
		["Jammal'an the Prophet"] = "Jammal'an el Profeta",
		["Kazkaz the Unholy"] = "Kazkaz el Blasfemo",
		["Loro"] = "Loro",
		["Mijan"] = "Mijar",
		["Morphaz"] = "Morphaz",
		["Ogom the Wretched"] = "Ogom el Desdichado",
		["Shade of Eranikus"] = "Sombra de Eranikus",
		["Veyzhak the Cannibal"] = "Veyzhak el Can\195\173bal",
		["Weaver"] = "Sastr\195\179n",
		["Zekkis"] = "Zekkis",
		["Zolo"] = "Zolo",
		["Zul'Lor"] = "Zul'Lor",

--Uldaman
		["Ancient Stone Keeper"] = "Vigilante p\195\169treo anciano",
		["Archaedas"] = "Archaedas",
		["Baelog"] = "Baelog",
		["Digmaster Shovelphlange"] = "Maestro de excavación Palatiro",
		["Galgann Firehammer"] = "Galgann Flamartillo",
		["Grimlok"] = "Grimlok",
		["Ironaya"] = "Hierraya",
		["Obsidian Sentinel"] = "Centinela Obsidiano",
		["Revelosh"] = "Revelosh",

--Wailing Caverns
		["Boahn"] = "Boahn",
		["Deviate Faerie Dragon"] = "Drag\195\179n f\195\169rico descarriado",
		["Kresh"] = "Kresh",
		["Lady Anacondra"] = "Lady Anacondra",
		["Lord Cobrahn"] = "Lord Cobrahn",
		["Lord Pythas"] = "Lord Pythas",
		["Lord Serpentis"] = "Lord Serpentis",
		["Mad Magglish"] = "Magglish el Loco",
		["Mutanus the Devourer"] = "Mutanus el Devorador",
		["Skum"] = "Skum",
		["Trigore the Lasher"] = "Trigore el Azotador",
		["Verdan the Everliving"] = "Verdan el Eterno",

--World Bosses
		["Avalanchion"] = "Avalanchion",
		["Azuregos"] = "Azuregos",
		["Baron Charr"] = "Bar\195\179n Charr",
		["Baron Kazum"] = "Bar\195\179n Kazum",
		["Doom Lord Kazzak"] = "Señor Apocalíptico Kazzak",
		["Doomwalker"] = "Caminante del Destino",  -- check
		["Emeriss"] = "Emeriss",
		["High Marshal Whirlaxis"] = "High Marshal Whirlaxis",
		["Lethon"] = "Lethon",
		["Lord Skwol"] = "Lord Skwol",
		["Prince Skaldrenox"] = "Pr\195\173ncipe Skaldrenox",
		["Princess Tempestria"] = "Princesa Tempestria",
		["Taerar"] = "Taerar",
		["The Windreaver"] = "El Atracavientos",
		["Ysondre"] = "Ysondre",

--Zul'Aman
		["Akil'zon"] = "Akil'zon",
		["Halazzi"] = "Halazzi",
		["Jan'alai"] = "Jan'alai",
		["Malacrass"] = "Malacrass",
		["Nalorakk"] = "Nalorakk",
		["Zul'jin"] = "Zul'jin",
		["Hex Lord Malacrass"] = "Hex Lord Malacrass",

--Zul'Farrak
		["Antu'sul"] = "Antu'sul",
		["Chief Ukorz Sandscalp"] = "Jefe Ukorz Cabellarena",
		["Dustwraith"] = "Ãnima de polvo",
		["Gahz'rilla"] = "Gahz'rilla",
		["Hydromancer Velratha"] = "Hidrom\195\161ntica Velratha",
		["Murta Grimgut"] = "Murta Tripuriosa",
		["Nekrum Gutchewer"] = "Nekrum Cometripas",
		["Oro Eyegouge"] = "Oro Bocojo ",
		["Ruuzlu"] = "Ruuzlu",
		["Sandarr Dunereaver"] = "Sandarr Asaltadunas",
		["Sandfury Executioner"] = "Ejecutor Furiarena",
		["Sergeant Bly"] = "Sargento Bly",
		["Shadowpriest Sezz'ziz"] = "Sacerdote oscuro Sezz'ziz",
		["Theka the Martyr"] = "Theka la M\195\161rtir",
		["Witch Doctor Zum'rah"] = "M\195\169dico brujo Zum'rah",
		["Zerillis"] = "Zerillis",
		["Zul'Farrak Dead Hero"] = "H\195\169roe muerto Zul'Farrak",

--Zul'Gurub
		["Bloodlord Mandokir"] = "Se\195\177or sangriento Mandokir",
		["Gahz'ranka"] = "Gahz'ranka",
		["Gri'lek"] = "Gri'lek",
		["Hakkar"] = "Hakkar",
		["Hazza'rah"] = "Hazza'rah",
		["High Priest Thekal"] = "Sumo Sacerdote Thekal",
		["High Priest Venoxis"] = "Sumo Sacerdote Venoxis",
		["High Priestess Arlokk"] = "Suma Sacerdotisa Arlokk",
		["High Priestess Jeklik"] = "Suma Sacerdotisa Jeklik",
		["High Priestess Mar'li"] = "Suma Sacerdotisa Mar'li",
		["Jin'do the Hexxer"] = "Jin'do el Aojador",
		["Renataki"] = "Renataki",
		["Wushoolay"] = "Wushoolay",

--Ring of Blood (where? an instnace? should be in other file?)
		["Brokentoe"] = "Dedorroto",
		["Mogor"] = "Mogor",
		["Murkblood Twin"] = "Gemelo Sangreoscura",
		["Murkblood Twins"] = "Gemelos Sangreoscura",
		["Rokdar the Sundered Lord"] = "Rokdar el Señor Hendido",
		["Skra'gath"] = "Skra'gath",
		["The Blue Brothers"] = "Los Hermanos Azules",
		["Warmaul Champion"] = "Campeón Mazo de Guerra",
	}
else
	error(("%s: Locale %q not supported"):format(MAJOR_VERSION, GAME_LOCALE))
end
