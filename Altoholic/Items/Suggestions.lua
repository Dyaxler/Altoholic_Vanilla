local L = AceLibrary("AceLocale-2.2"):new("Altoholic")
local BI = LibStub("LibBabble-Inventory-3.0"):GetLookupTable()
local BZ = LibStub("LibBabble-Zone-3.0"):GetLookupTable()
local BF = LibStub("LibBabble-Faction-3.0"):GetLookupTable()
local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"
local YELLOW	= "|cFFFFFF00"

-- temporary test, until all locales are done for the suggestions, test the ones that are done in order to use them instead of enUS, this test will be replaced later on.
if (GetLocale() == "zhCN") or
	(GetLocale() == "zhTW") then return end				-- exit to use zhCN or zhTW instead of enUS

-- This table contains a list of suggestions to get to the next level of reputation, craft or skill
Altoholic.Suggestions = {
	[L["Riding"]] = {
		{ 75, "Apprentice riding skill (Lv 40): |cFFFFFFFF90g\n|cFFFFD700Standard mount in/near a capital city: |cFFFFFFFF10g" },
		{ 150, "Journeyman riding skill (Lv 60): |cFFFFFFFF600g\n|cFFFFD700Epic mount in/near a capital city: |cFFFFFFFF100g" }
	},
	
	-- source : http://forums.worldofwarcraft.com/thread.html?topicId=102789457&sid=1
	-- ** Primary professions **
	[BI["Tailoring"]] = {
		{ 50, "Up to 50: Bolt of Linen Cloth" },
		{ 70, "Up to 70: Linen Bag" },
		{ 75, "Up to 75: Reinforced Linen Cape" },
		{ 105, "Up to 105: Bolt of Woolen Cloth" },
		{ 110, "Up to 110: Gray Woolen Shirt"},
		{ 125, "Up to 125: Double-stitched Woolen Shoulders" },
		{ 145, "Up to 145: Bolt of Silk Cloth" },
		{ 160, "Up to 160: Azure Silk Hood" },
		{ 170, "Up to 170: Silk Headband" },
		{ 175, "Up to 175: Formal White Shirt" },
		{ 185, "Up to 185: Bolt of Mageweave" },
		{ 205, "Up to 205: Crimson Silk Vest" },
		{ 215, "Up to 215: Crimson Silk Pantaloons" },
		{ 220, "Up to 220: Black Mageweave Leggings\nor Black Mageweave Vest" },
		{ 230, "Up to 230: Black Mageweave Gloves" },
		{ 250, "Up to 250: Black Mageweave Headband\nor Black Mageweave Shoulders" },
		{ 260, "Up to 260: Bolt of Runecloth" },
		{ 275, "Up to 275: Runecloth Belt" },
		{ 280, "Up to 280: Runecloth Bag" },
		{ 300, "Up to 300: Runecloth Gloves" }
	},
	[BI["Leatherworking"]] = {
		{ 35, "Up to 35: Light Armour Kit" },
		{ 55, "Up to 55: Cured Light Hide" },
		{ 85, "Up to 85: Embossed Leather Gloves" },
		{ 100, "Up to 100: Fine Leather Belt" },
		{ 120, "Up to 120: Cured Medium Hide" },
		{ 125, "Up to 125: Fine Leather Belt" },
		{ 150, "Up to 150: Dark Leather Belt" },
		{ 160, "Up to 160: Cured Heavy Hide" },
		{ 170, "Up to 170: Heavy Armour Kit" },
		{ 180, "Up to 180: Dusky Leather Leggings\nor Guardian Pants" },
		{ 195, "Up to 195: Barbaric Shoulders" },
		{ 205, "Up to 205: Dusky Bracers" },
		{ 220, "Up to 220: Thick Armor Kit" },
		{ 225, "Up to 225: Nightscape Headband" },
		{ 250, "Up to 250: Depends on your specialization\nNightscape Headband/Tunic/Pants (Elemental)\nTough Scorpid Breastplate/Gloves (Dragonscale)\nTurtle Scale set (Tribal)" },
		{ 260, "Up to 260: Nightscape Boots" },
		{ 270, "Up to 270: Wicked Leather Gauntlets" },
		{ 285, "Up to 285: Wicked Leather Bracers" },
		{ 300, "Up to 300: Wicked Leather Headband" }
	},
	[BI["Engineering"]] = {
		{ 40, "Up to 40: Rough Blasting Powder" },
		{ 50, "Up to 50: Handful of Copper Bolt" },
		{ 51, "Craft one Arclight Spanner" },
		{ 65, "Up to 65: Copper Tubes" },
		{ 75, "Up to 75: Rough Boom Sticks" },
		{ 95, "Up to 95: Coarse Blasting Powder" },
		{ 105, "Up to 105: Silver Contacts" },
		{ 120, "Up to 120: Bronze Tubes" },
		{ 125, "Up to 125: Small Bronze Bombs" },
		{ 145, "Up to 145: Heavy Blasting Powder" },
		{ 150, "Up to 150: Big Bronze Bombs" },
		{ 175, "Up to 175: Blue, Green or Red Fireworks" },
		{ 176, "Craft one Gyromatic Micro-Adjustor" },
		{ 190, "Up to 190: Solid Blasting Powder" },
		{ 195, "Up to 195: Big Iron Bomb" },
		{ 205, "Up to 205: Mithril Tubes" },
		{ 210, "Up to 210: Unstable Triggers" },
		{ 225, "Up to 225: Hi-Impact Mithril Slugs" },
		{ 235, "Up to 235: Mithril Casings" },
		{ 245, "Up to 245: Hi-Explosive Bomb" },
		{ 250, "Up to 250: Mithril Gyro-Shot" },
		{ 260, "Up to 260: Dense Blasting Powder" },
		{ 290, "Up to 290: Thorium Widget" },
		{ 300, "Up to 300: Thorium Tubes\nor Thorium Shells (cheaper)" }
	},
	[BI["Enchanting"]] = {
		{ 2, "Up to 2: Runed Copper Rod" },
		{ 75, "Up to 75: Enchant Bracer - Minor Health" },
		{ 85, "Up to 85: Enchant Bracer - Minor Deflection" },
		{ 100, "Up to 100: Enchant Bracer - Minor Stamina" },
		{ 101, "Craft one Runed Silver Rod" },
		{ 105, "Up to 105: Enchant Bracer - Minor Stamina" },
		{ 120, "Up to 120: Greater Magic Wand" },
		{ 130, "Up to 130: Enchant Shield - Minor Stamina" },
		{ 150, "Up to 150: Enchant Bracer - Lesser Stamina" },
		{ 151, "Craft one Runed Golden Rod" },
		{ 160, "Up to 160: Enchant Bracer - Lesser Stamina" },
		{ 165, "Up to 165: Enchant Shield - Lesser Stamina" },
		{ 180, "Up to 180: Enchant Bracer - Spirit" },
		{ 200, "Up to 200: Enchant Bracer - Strength" },
		{ 201, "Craft one Runed Truesilver Rod" },
		{ 205, "Up to 205: Enchant Bracer - Strength" },
		{ 225, "Up to 225: Enchant Cloak - Greater Defense" },
		{ 235, "Up to 235: Enchant Gloves - Agility" },
		{ 245, "Up to 245: Enchant Chest - Superior Health" },
		{ 250, "Up to 250: Enchant Bracer - Greater Strength" },
		{ 270, "Up to 270: Lesser Mana Oil\nRecipe is sold in Silithus" },
		{ 290, "Up to 290: Enchant Shield - Greater Stamina\nor Enchant Boots: Greater Stamina" },
		{ 291, "Craft one Runed Arcanite Rod" },
		{ 300, "Up to 300: Enchant Cloak - Superior Defense" }
	},
	[BI["Blacksmithing"]] = {	
		{ 25, "Up to 25: Rough Sharpening Stones" },
		{ 45, "Up to 45: Rough Grinding Stones" },
		{ 75, "Up to 75: Copper Chain Belt" },
		{ 80, "Up to 80: Coarse Grinding Stones" },
		{ 100, "Up to 100: Runed Copper Belt" },
		{ 105, "Up to 105: Silver Rod" },
		{ 125, "Up to 125: Rough Bronze Leggings" },
		{ 150, "Up to 150: Heavy Grinding Stone" },
		{ 155, "Up to 155: Golden Rod" },
		{ 165, "Up to 165: Green Iron Leggings" },
		{ 185, "Up to 185: Green Iron Bracers" },
		{ 200, "Up to 200: Golden Scale Bracers" },
		{ 210, "Up to 210: Solid Grinding Stone" },
		{ 215, "Up to 215: Golden Scale Bracers" },
		{ 235, "Up to 235: Steel Plate Helm\nor Mithril Scale Bracers (cheaper)\nRecipe in Aerie Peak (A) or Stonard (H)" },
		{ 250, "Up to 250: Mithril Coif\nor Mothril Spurs (cheaper)" },
		{ 260, "Up to 260: Dense Sharpening Stones" },
		{ 270, "Up to 270: Thorium Belt or Bracers (cheaper)\nEarthforged Leggings (Armorsmith)\nLight Earthforged Blade (Swordsmith)\nLight Emberforged Hammer (Hammersmith)\nLight Skyforged Axe (Axesmith)" },
		{ 295, "Up to 295: Imperial Plate Bracers" },
		{ 300, "Up to 300: Imperial Plate Boots" }
	},
	[BI["Alchemy"]] = {	
		{ 60, "Up to 60: Minor Healing Potion" },
		{ 110, "Up to 110: Lesser Healing Potion" },
		{ 140, "Up to 140: Healing Potion" },
		{ 155, "Up to 155: Lesser Mana Potion" },
		{ 185, "Up to 185: Greater Healing Potion" },
		{ 210, "Up to 210: Elixir of Agility" },
		{ 215, "Up to 215: Elixir of Greater Defense" },
		{ 230, "Up to 230: Superior Healing Potion" },
		{ 250, "Up to 250: Elixir of Detect Undead" },
		{ 265, "Up to 265: Elixir of Greater Agility" },
		{ 285, "Up to 285: Superior Mana Potion" },
		{ 300, "Up to 300: Major Healing Potion" }
	},
	[L["Mining"]] = {
		{ 65, "Up to 65: Mine Copper\nAvailable in all starting zones" },
		{ 125, "Up to 125: Mine Tin, Silver, Incendicite and Lesser Bloodstone\n\nMine Incendicite at Thelgen Rock (Wetlands)\nEasy leveling up to 125" },
		{ 175, "Up to 175: Mine Iron and Gold\nDesolace, Ashenvale, Badlands, Arathi Highlands,\nAlterac Mountains, Stranglethorn Vale, Swamp of Sorrows" },
		{ 250, "Up to 250: Mine Mithril and Truesilver\nBlasted Lands, Searing Gorge, Badlands, The Hinterlands,\nWestern Plaguelands, Azshara, Winterspring, Felwood, Stonetalon Mountains, Tanaris" },
		{ 300, "Up to 300: Mine Thorium \nUn’goro Crater, Azshara, Winterspring, Blasted Lands\nSearing Gorge, Burning Steppes, Eastern Plaguelands, Western Plaguelands" }
	},
	[L["Herbalism"]] = {
		{ 50, "Up to 50: Collect Silverleaf and Peacebloom\nAvailable in all starting zones" },
		{ 70, "Up to 70: Collect Mageroyal and Earthroot\nThe Barrens, Westfall, Silverpine Forest, Loch Modan" },
		{ 100, "Up to 100: Collect Briarthorn\nSilverpine Forest, Duskwood, Darkshore,\nLoch Modan, Redridge Mountains" },
		{ 115, "Up to 115: Collect Bruiseweed\nAshenvale, Stonetalon Mountains, Southern Barrens\nLoch Modan, Redridge Mountains" },
		{ 125, "Up to 125: Collect Wild Steelbloom\nStonetalon Mountains, Arathi Highlands, Stranglethorn Vale\nSouthern Barrens, Thousand Needles" },
		{ 160, "Up to 160: Collect Kingsblood\nAshenvale, Stonetalon Mountains, Wetlands,\nHillsbrad Foothills, Swamp of Sorrows" },
		{ 185, "Up to 185: Collect Fadeleaf\nSwamp of Sorrows" },
		{ 205, "Up to 205: Collect Khadgar's Whisker\nThe Hinterlands, Arathi Highlands, Swamp of Sorrows" },
		{ 230, "Up to 230: Collect Firebloom\nSearing Gorge, Blasted Lands, Tanaris" },
		{ 250, "Up to 250: Collect Sungrass\nFelwood, Feralas, Azshara\nThe Hinterlands" },
		{ 270, "Up to 270: Collect Gromsblood\nFelwood, Blasted Lands,\nMannoroc Coven in Desolace" },
		{ 285, "Up to 285: Collect Dreamfoil\nUn'goro Crater, Azshara" },
		{ 300, "Up to 300: Collect Plagueblooms\nEastern & Western Plaguelands, Felwood\nor Icecaps in Winterspring" }
	},
	[L["Skinning"]] = {
		{ 300, "Up to 300: Divide your current skill level by 5,\nand skin mobs of that level" }
	},
	-- source: http://www.almostgaming.com/wowguides/world-of-warcraft-lockpicking-guide
	[L["Lockpicking"]] = {
		{ 85, "Up to 85: Thieves Training\nAtler Mill, Redridge Moutains (A)\nShip near Ratchet (H)" },
		{ 150, "Up to 150: Chest near the boss of the poison quest\nWestfall (A) or The Barrens (H)" },
		{ 185, "Up to 185: Murloc camps (Wetlands)" },
		{ 225, "Up to 225: Sar'Theris Strand (Desolace)\n" },
		{ 250, "Up to 250: Angor Fortress (Badlands)" },
		{ 275, "Up to 275: Slag Pit (Searing Gorge)" },
		{ 300, "Up to 300: Lost Rigger Cove (Tanaris)\nBay of Storms (Azshara)" }
	},
	
	-- ** Secondary professions **
	[BI["First Aid"]] = {
		{ 40, "Up to 40: Linen Bandages" },
		{ 80, "Up to 80: Heavy Linen Bandages\nBecome Journeyman at 50" },
		{ 115, "Up to 115: Wool Bandages" },
		{ 150, "Up to 150: Heavy Wool Bandages\nGet Expert First Aid book at 125\nBuy the 2 manuals in Stromguarde (A) or Brackenwall Village (H)" },
		{ 180, "Up to 180: Silk Bandages" },
		{ 210, "Up to 210: Heavy Silk Bandages" },
		{ 240, "Up to 240: Mageweave Bandages\nFirst Aid quest at level 35\nTheramore Isle (A) or Hammerfall (H)" },
		{ 260, "Up to 260: Heavy Mageweave Bandages" },
		{ 290, "Up to 290: Runecloth Bandages" },
		{ 300, "Up to 300: Heavy Runecloth Bandages" }
	},
	[BI["Cooking"]] = {
		{ 40, "Up to 40: Spice Bread"	},
		{ 85, "Up to 85: Smoked Bear Meat, Crab Cake" },
		{ 100, "Up to 100: Cooked Crab Claw (A)\nDig Rat Stew (H)" },
		{ 125, "Up to 125: Dig Rat Stew (H)\nSeasoned Wolf Kabob (A)" },
		{ 175, "Up to 175: Curiously Tasty Omelet (A)\nHot Lion Chops (H)" },
		{ 200, "Up to 200: Roast Raptor" },
		{ 225, "Up to 225: Spider Sausage\n\n|cFFFFFFFFCooking quest:\n|cFFFFD70012 Giant Eggs,\n10 Zesty Clam Meat,\n20 Alterac Swiss " },
		{ 275, "Up to 275: Monster Omelet\nor Tender Wolf Steaks" },
		{ 285, "Up to 285: Runn Tum Tuber Surprise\nDire Maul (Pusillin)" },
		{ 300, "Up to 300: Smoked Desert Dumplings\nQuest in Silithus" }
	},	
	-- source: http://www.wowguideonline.com/fishing.html
	[BI["Fishing"]] = {
		{ 50, "Up to 50: Any starting zone" },
		{ 75, "Up to 75:\nThe Canals in Stormwind\nThe Pond in Orgrimmar" },
		{ 150, "Up to 150: Hillsbrad Foothills' river" },
		{ 225, "Up to 225: Expert Fishing book sold in Booty Bay\nFish in Desolace or Arathi Highlands" },
		{ 250, "Up to 250: Hinterlands, Tanaris\n\n|cFFFFFFFFFishing quest in Dustwallow Marsh\n|cFFFFD700Savage Coast Blue Sailfin (Stranglethorn Vale)\nFeralas Ahi (Verdantis River, Feralas)\nSer'theris Striker (Northern Sartheris Strand, Desolace)\nMisty Reed Mahi Mahi (Swamp of Sorrows coastline)" },
		{ 260, "Up to 260: Felwood" },
		{ 300, "Up to 300: Azshara" }
	},
	
	-- suggested leveling zones, compiled by Thaoky, based on too many sources to list + my own leveling experience on Alliance side
	["Leveling"] = {
		{ 10, "Up to 10: Any starting zone" },
		{ 20, "Up to 20: "  .. BZ["Loch Modan"] .. "\n" .. BZ["Westfall"] .. "\n" .. BZ["Darkshore"] 
						.. "\n" .. BZ["Silverpine Forest"] .. "\n" .. BZ["The Barrens"]},
		{ 25, "Up to 25: " .. BZ["Wetlands"] .. "\n" .. BZ["Redridge Mountains"] .. "\n" .. BZ["Ashenvale"] 
						.. "\n" .. BZ["The Barrens"] .. "\n" .. BZ["Stonetalon Mountains"] .. "\n" .. BZ["Hillsbrad Foothills"] },
		{ 28, "Up to 28: " .. BZ["Duskwood"] .. "\n" .. BZ["Wetlands"] .. "\n" .. BZ["Ashenvale"] 
						.. "\n" .. BZ["Stonetalon Mountains"] .. "\n" .. BZ["Thousand Needles"] },
		{ 31, "Up to 31: " .. BZ["Duskwood"] .. "\n" .. BZ["Thousand Needles"] .. "\n" .. BZ["Ashenvale"] },
		{ 35, "Up to 35: " .. BZ["Thousand Needles"] .. "\n" .. BZ["Stranglethorn Vale"] .. "\n" .. BZ["Alterac Mountains"] 
						.. "\n" .. BZ["Arathi Highlands"] .. "\n" .. BZ["Desolace"] },
		{ 40, "Up to 40: " .. BZ["Stranglethorn Vale"] .. "\n" .. BZ["Desolace"] .. "\n" .. BZ["Badlands"]
						.. "\n" .. BZ["Dustwallow Marsh"] .. "\n" .. BZ["Swamp of Sorrows"] },
		{ 43, "Up to 43: " .. BZ["Tanaris"] .. "\n" .. BZ["Stranglethorn Vale"] .. "\n" .. BZ["Badlands"] 
						.. "\n" .. BZ["Dustwallow Marsh"] .. "\n" .. BZ["Swamp of Sorrows"] },
		{ 45, "Up to 45: " .. BZ["Tanaris"] .. "\n" .. BZ["Feralas"] .. "\n" .. BZ["The Hinterlands"] },
		{ 48, "Up to 48: " .. BZ["Tanaris"] .. "\n" .. BZ["Feralas"] .. "\n" .. BZ["The Hinterlands"] .. "\n" .. BZ["Searing Gorge"] },
		{ 51, "Up to 51: " .. BZ["Tanaris"] .. "\n" .. BZ["Azshara"] .. "\n" .. BZ["Blasted Lands"] 
						.. "\n" .. BZ["Searing Gorge"] .. "\n" .. BZ["Un'Goro Crater"] .. "\n" .. BZ["Felwood"] },
		{ 55, "Up to 55: " .. BZ["Un'Goro Crater"] .. "\n" .. BZ["Felwood"] .. "\n" .. BZ["Burning Steppes"]
						.. "\n" .. BZ["Blasted Lands"] .. "\n" .. BZ["Western Plaguelands"] },
		{ 58, "Up to 58: " .. BZ["Winterspring"] .. "\n" .. BZ["Burning Steppes"] .. "\n" .. BZ["Western Plaguelands"] 
						.. "\n" .. BZ["Eastern Plaguelands"] .. "\n" .. BZ["Silithus"] },
		{ 60, "Up to 60: " .. BZ["Winterspring"] .. "\n" .. BZ["Eastern Plaguelands"] .. "\n" .. BZ["Silithus"] },
	}
}