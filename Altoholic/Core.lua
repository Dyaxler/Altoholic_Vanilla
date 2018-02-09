Altoholic = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceEvent-2.0", "AceDB-2.0", "AceHook-2.1")
Altoholic:RegisterChatCommand({"/Altoholic", "/Alto"}, options)	
Altoholic:RegisterDB("AltoholicDB")
Altoholic.SearchResults = {}
Altoholic.CharacterInfo = {}
Altoholic.BagIndices = {}
Altoholic.MenuCache = {}
Altoholic.vars = {}
Altoholic.vars.version = "v1.0.9"
local G = AceLibrary("Gratuity-2.0")
local L = AceLibrary("AceLocale-2.2"):new("Altoholic")
local V = Altoholic.vars
local BF = LibStub("LibBabble-Faction-3.0"):GetLookupTable()
local BZ = LibStub("LibBabble-Zone-3.0"):GetLookupTable()


local options = { 
	type='group',
	args = {
		search = {
			type = 'text',
			name = L['search'],
			usage = "<item name>",
			desc = L["Search in bags"],
			get = false,
			set = "CmdSearchBags",
			input = true,
		},
		show = {
			type = 'execute',
			name = L['show'],
			desc = L["Shows the UI"],
			func = function() AltoholicFrame:Show() end
		},
		hide = {
			type = 'execute',
			name = L['hide'],
			desc = L["Hides the UI"],
			func = function() AltoholicFrame:Hide() end
		},
		toggle = {
			type = 'execute',
			name = L['toggle'],
			desc = L["Toggles the UI"],
			func = function() Altoholic:ToggleUI() end
		},
    }
}

Altoholic.Categories = {
	"AltoSummary", 
	"AltoBags",
	"AltoContainers",
	"AltoMail",
	"AltoSearch",
	"AltoEquipment",
	"AltoReputations",
	"AltoOptions",
	"AltoQuests",
	"AltoRecipes",
	"AltoAuctions",
	"AltoSkills"
}

Altoholic.RecipesBooks = {
    --Craft Recipes:
    "Pattern:",
    "Plans:",
    "Formula:",
    "Schematic:",
    "Recipe:",
    --Class Books:
    "Book of",
    "Book:",
    "Codex of",
    "Codex:",
    "Grimoire of",
    "Grimoire:",
    "Guide:",
    "Handbook of",
    "Libram:",
    "Manual of",
    "Tablet of",
    "Tome of"
}

Altoholic.XPToNext	= { 
-- From: http://www.wowwiki.com/Formulas:XP_To_Level, retrieved Feb 6, 2008
-- read: at XPToNext[1], you need 400 xp to get to 2
    400,900,1400,2100,2800,3600,4500,5400,6500,7600,8800,10100,
    11400,12900,14400,16000,17700,19400,21300,23200,25200,27300,
    29400,31700,34000,36400,38900,41400,44300,47400,50800,54500,
    58600,62800,67100,71600,76100,80800,85700,90700,95800,101000,
    106300,111800,117500,123200,129100,135100,141200,147500,153900,
    160400,167100,173900,180800,187900,195000,202300,209800
}

-- Allow ESC to close the main frame
tinsert(UISpecialFrames, "AltoholicFrame");

--[[	*** Note on reputation ***
the "reputation" table is kept out of the "char" table for practical reasons, as the table will be populated with so many different entries for each alt,
it was much easier to organize things this way to ensure a more efficient parsing when data will be displayed, this also prevents from creating
a large temporary table that would have to be garbage collected later on. Character names will be duplicated in each sub-table, 
but this is a little trade-off I accept.
--]]
 
Altoholic:RegisterDefaults('account', {
	options = {
		MinimapIconAngle = 268,
		MinimapIconRadius = 78,
		MailWarningThreshold = 5,
		SortDescending = 0, 				-- display search results in the loot table in ascending (0) or descending (1) order ?
		RestXPMode = 0, 					-- display max rest xp in normal 100% mode or in level equivalent 150% mode (1) ?
		ScanMailBody = 0,					-- by default, scan the body of a mail (this action marks it as read)
		TooltipSource = 1,
		TooltipCount = 1,
		TooltipTotal = 1,
		TooltipAlreadyKnown = 0,
        TooltipLearnableBy = 1,
		ShowMinimap = 1,
		SearchAutoQuery = 0,
		TotalLoots = 0,					-- make at least one search in the loot tables to initialize these values
		UnknownLoots = 0
	},
	data = {
		['*'] = {							-- Faction
			['*'] = {						-- Realm
				reputation = {
					['*'] = {				-- "Ironforge"
						['*'] = nil
					}
				},
				guild = {
					['*'] = {				-- guild["MyUberGuild"]
						lastbankvisitby = "",
						lastbankvisittime = 0,
						bankmoney = 0,
						bank = {
							['*'] = {
								tabID = nil,
								name = "",
								ids = { ['*'] = nil },
								links = { ['*'] = nil },
								counts = { ['*'] = nil }
							}
						}
					}
				},
				unsafeItems = {},
				char = {
					['*'] = {					-- Character Name
						level = 0,
						race = "",
						class = "",
						talent = "",
						bags = "",
						bankslots = "",
						zone = "",				-- in which zone the player went offline
						subzone = "",			-- in which subzone .. 
						xp = 0,					-- current level xp
						xpmax = 0,				-- max xp at current level 
						restxp = 0,
						isResting = true,		-- most players will logout at an inn, so default to true
						money = 0,
						played = 0,				-- 57396 seconds = 0 days 15 hours 56 minutes 36 seconds
						lastlogout = 0,
						lastmailcheck = 0,	-- last time the mail was checked for this char
						lastAHcheck = 0,		-- last time the AH was checked for this char
						pvp_hk = 0,				-- pvp honorable kills
						pvp_dk = 0,				-- pvp dishonorable kills
						pvp_ArenaPoints = 0,
						pvp_HonorPoints = 0,
						skill = {
							['*'] = {			-- "Professions"
								['*'] = nil
							}
						},
						spells = {
                            ['*'] = {
                                name = nil,
                                rank = nil
                            }
						},
						inventory = {},		-- 19 inventory slots, a simple table containing item id's
						SavedInstance = {},	-- raid timers
						ProfessionCooldowns = {},
						questlog = {
							['*'] = {
								name = nil,		-- name: name of the header (usually the location)
								link = nil,		-- the quest link
								isHeader = nil,
								isCollapsed = false,
								tag = nil,			-- quest tag=  "Elite", "Dungeon", "PVP", "Raid", "Group", "Heroic" or nil
								groupsize = nil,
								money = nil,
								isComplete = nil
							}
						},
						recipes = {
							['*'] = {
								ScanFailed = true,	-- by default, consider that scanning this profession was not valid
								list = {
									['*'] = {
										id = nil,
										name = nil,
										link = nil,
										isHeader = nil,
										isCollapsed = false,
										reagents = nil,	-- itemID : count | itemID : count .. etc
									}
								}
							}
						},
						auctions = {
							['*'] = {
								id = nil,
								count = 1,
								AHLocation = nil,		-- nil = faction AH, 1 = goblin AH
								highBidder = nil,
								startPrice = nil,
								buyoutPrice = nil,
								timeLeft = nil
							}
						},
						bids = {
							['*'] = {
								id = nil,
								count = 1,
								AHLocation = nil,		-- nil = faction AH, 1 = goblin AH
								owner = nil,
								bidPrice = nil,
								buyoutPrice = nil,
								timeLeft = nil
							}
						},
						mail = {
							['*'] = {
								icon = nil,
								link = nil,
								count = 0,
								money = 0,
								lastcheck = 0,		-- last time "THIS" mail was checked (can be different than that of the mailbox)
								text = "",
								subject = "",
								sender = "",
								daysleft = 0,
								realm = ""
							}
						},
						bag = {
							['*'] = {					-- bag["Bag0"]
								icon = nil,				-- bag's texture
								link = nil,				-- bag's itemlink
								size = 0,
								freeslots = 0,
								bagtype = 0,
								ids = { ['*'] = nil },
								links = { ['*'] = nil },
								counts = { ['*'] = nil }
							}
						}
					}
				}
			}
		}
	}
})

-- Factions reference table, based on http://www.wowwiki.com/Factions
-- a table with a similar structure (but only with required lines) will be build to make the reputations frame
Altoholic.FactionsRefTable = {
	{ FACTION_ALLIANCE },
	BZ["Darnassus"],
	L["Exodar"],
	L["Gnomeregan Exiles"],
	BZ["Ironforge"],
	L["Stormwind"],
	{ FACTION_HORDE },
	L["Darkspear Trolls"],
	BZ["Orgrimmar"],
	BZ["Thunder Bluff"],
	BZ["Undercity"],
	BZ["Silvermoon City"],
	{ L["Alliance Forces"] },
	BF["The League of Arathor"],
	BF["Silverwing Sentinels"],
	BF["Stormpike Guard"],
	{ L["Horde Forces"] },
	BF["The Defilers"],
	BF["Warsong Outriders"],
	BF["Frostwolf Clan"],
	{ L["Steamwheedle Cartel"] },
	BZ["Booty Bay"],
	BZ["Everlook"],
	BZ["Gadgetzan"],
	BZ["Ratchet"],
	{ BZ["Outland"] },
	BF["Ashtongue Deathsworn"],
	BF["Cenarion Expedition"],
	BF["The Consortium"],
	BF["Honor Hold"],
	BF["Kurenai"],
	BF["The Mag'har"],
	BF["Netherwing"],
	BF["Ogri'la"],
	BF["Sporeggar"],
	BF["Thrallmar"],
	{ BZ["Shattrath City"] },
	BF["Lower City"],
	BF["Sha'tari Skyguard"],
	BF["Shattered Sun Offensive"],
	BF["The Aldor"],
	BF["The Scryers"],
	BF["The Sha'tar"],
	{ L["Other"] },
	BF["Argent Dawn"],
	BF["Bloodsail Buccaneers"],
	BF["Brood of Nozdormu"],
	BF["Cenarion Circle"],
	BF["Darkmoon Faire"],
	BF["Gelkis Clan Centaur"],
	BF["Hydraxian Waterlords"],
	BF["Keepers of Time"],
	BF["Magram Clan Centaur"],
	L["Ravenholdt"],
	BF["The Scale of the Sands"],
	L["Shen'dralar"],
	L["Syndicate"],
	BF["Thorium Brotherhood"],
	BF["Timbermaw Hold"],
	BF["Tranquillien"],
	BF["Wintersaber Trainers"],
	BF["The Violet Eye"],
	BF["Zandalar Tribe"]
}

-- a few constants to increase readability in the tables below, some stats are taken from WoWUI's GlobalStrings.lua, but not all of them are suitable
-- SPELL_STAT0_NAME = "Strength";
-- SPELL_STAT1_NAME = "Agility";
-- SPELL_STAT2_NAME = "Stamina";
-- SPELL_STAT3_NAME = "Intellect";
-- SPELL_STAT4_NAME = "Spirit";

local ITEM_MOD_CRIT_RATING = "Improves your chance to get a critical strike by %d."
local ITEM_MOD_CRIT_SPELL_RATING = "Improves your chance to get a critical strike with spells by %d."
local ITEM_MOD_HIT_RATING = "Improves your chance to hit by %d."
local ITEM_MOD_HIT_SPELL_RATING = "Improves your chance to hit with spells by %d."
local STAT_HEALING = "Increases healing done by spells and effects by up to %d+."
local STAT_SPELLDMG = "Increases damage and healing done by magical spells and effects by up to %d+."
local STAT_AP = "%d+ Attack Power."
local ITEM_MOD_DEFENSE_SKILL_RATING = "Increased Defense %+%d."
local ITEM_MOD_DODGE_RATING = "Increases your chance to dodge an attack by %d."
local ITEM_MOD_BLOCK_RATING = "Increases your chance to block attacks with a shield by %d."
local STAT_MP5 = L["Restores %d+ mana per"]
local STAT_SHAMAN_ONLY = L["Classes: Shaman"] .. "$"
local STAT_MAGE_ONLY = L["Classes: Mage"] .. "$"
local STAT_ROGUE_ONLY = L["Classes: Rogue"] .. "$"
local STAT_HUNTER_ONLY = L["Classes: Hunter"] .. "$"
local STAT_WARRIOR_ONLY = L["Classes: Warrior"] .. "$"
local STAT_PALADIN_ONLY = L["Classes: Paladin"] .. "$"
local STAT_WARLOCK_ONLY = L["Classes: Warlock"] .. "$"
local STAT_PRIEST_ONLY = L["Classes: Priest"] .. "$"
local STAT_RESIST = L["Resistance"]

-- Class constants, for readability, these values match the ones in Altoholic.Classes (altoholic.lua)
local CLASS_MAGE	= 1
local CLASS_WARRIOR	= 2
local CLASS_HUNTER	= 3
local CLASS_ROGUE	= 4
local CLASS_WARLOCK	= 5
local CLASS_DRUID	= 6
local CLASS_SHAMAN	= 7
local CLASS_PALADIN	= 8
local CLASS_PRIEST	= 9

-- When processing item stats, exclude an item if one of these strings is encountered, then discard the item
Altoholic.ExcludeStats = {
	[CLASS_MAGE.."DPS"] = { 
		STAT_RESIST,
        SPELL_STAT0_NAME,
		SPELL_STAT1_NAME, 
		STAT_HEALING,
		STAT_AP,
		ITEM_MOD_DEFENSE_SKILL_RATING,
		ITEM_MOD_DODGE_RATING,
		ITEM_MOD_BLOCK_RATING, 
		STAT_PRIEST_ONLY,
		STAT_WARLOCK_ONLY
	},
	[CLASS_WARRIOR.."Tank"]	= { 
		STAT_RESIST,
        SPELL_STAT3_NAME,
		SPELL_STAT4_NAME, 
		STAT_MP5, 
		STAT_HEALING, 
		STAT_AP, 
		STAT_SPELLDMG, 
		STAT_PALADIN_ONLY
	},
	[CLASS_WARRIOR.."DPS"] = { 
		STAT_RESIST,
        SPELL_STAT3_NAME,
		SPELL_STAT4_NAME, 
		STAT_MP5, 
		STAT_HEALING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		STAT_SPELLDMG, 
		STAT_PALADIN_ONLY
	},
	[CLASS_HUNTER.."DPS"] = { 
		STAT_RESIST, 
		SPELL_STAT0_NAME, 
		STAT_HEALING, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		STAT_SPELLDMG, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_SHAMAN_ONLY
	},
	[CLASS_ROGUE.."DPS"] = { 
		STAT_RESIST, 
        SPELL_STAT3_NAME,
		SPELL_STAT4_NAME,
		STAT_MP5, 
		STAT_HEALING, 
		STAT_SPELLDMG, 
		ITEM_MOD_BLOCK_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING
	},
	[CLASS_WARLOCK.."DPS"] = { 
		STAT_RESIST, 
        SPELL_STAT0_NAME,
		SPELL_STAT1_NAME, 
		STAT_HEALING, 
		STAT_AP, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_MAGE_ONLY, 
		STAT_PRIEST_ONLY
	},
	[CLASS_DRUID.."Tank"] = { 
		STAT_RESIST, 
		STAT_HEALING, 
		STAT_SPELLDMG,
		STAT_AP,
        ITEM_MOD_BLOCK_RATING,
        ITEM_MOD_CRIT_SPELL_RATING,
        ITEM_MOD_HIT_SPELL_RATING,
        STAT_MP5,
		STAT_ROGUE_ONLY
	},

	[CLASS_DRUID.."Heal"] = { 
		STAT_RESIST, 
        SPELL_STAT0_NAME,
		SPELL_STAT1_NAME,
		STAT_SPELLDMG, 
		STAT_AP,
        ITEM_MOD_HIT_SPELL_RATING,  
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_DODGE_RATING,
		ITEM_MOD_BLOCK_RATING
	},
	[CLASS_DRUID.."DPS"] = { 
		STAT_RESIST, 
        SPELL_STAT3_NAME,
		SPELL_STAT4_NAME, 
		STAT_HEALING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_SPELLDMG, 
		STAT_ROGUE_ONLY
	},
	[CLASS_DRUID.."Balance"] = { 
		STAT_RESIST, 
        SPELL_STAT0_NAME,
		SPELL_STAT1_NAME,
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		STAT_HEALING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_AP
	},
	[CLASS_SHAMAN.."Heal"] = { 
		STAT_RESIST, 
		ITEM_MOD_CRIT_RATING, 
        SPELL_STAT0_NAME,
		SPELL_STAT1_NAME,
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_SPELLDMG,
		STAT_AP
	},
	[CLASS_SHAMAN.."DPS"] = { 
		STAT_RESIST, 
		STAT_HEALING, 
		STAT_SPELLDMG, 
		ITEM_MOD_CRIT_SPELL_RATING, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_HUNTER_ONLY
	},
	[CLASS_SHAMAN.."Elemental"] = { 
		STAT_RESIST, 
        SPELL_STAT0_NAME,
		SPELL_STAT1_NAME,
		STAT_HEALING, 
		ITEM_MOD_HIT_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_AP, 
		ITEM_MOD_CRIT_RATING
	},
	[CLASS_PALADIN.."Tank"]	= { 
		STAT_RESIST, 
		SPELL_STAT1_NAME, 
		STAT_AP, 
		STAT_HEALING, 
		ITEM_MOD_CRIT_RATING, 
		STAT_WARRIOR_ONLY
	},
	[CLASS_PALADIN.."Heal"]	= { 
		STAT_RESIST, 
        SPELL_STAT0_NAME,
		SPELL_STAT1_NAME, 
		ITEM_MOD_CRIT_RATING, 
		STAT_AP, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_HIT_RATING
	},
	[CLASS_PALADIN.."DPS"] = { 
		STAT_RESIST, 
		STAT_HEALING, 
		STAT_SPELLDMG, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		STAT_WARRIOR_ONLY },

	[CLASS_PRIEST.."Heal"] = { 
		STAT_RESIST, 
        SPELL_STAT0_NAME,
		SPELL_STAT1_NAME,
		STAT_SPELLDMG, 
		STAT_AP,
        ITEM_MOD_HIT_SPELL_RATING,    
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING
	},
	[CLASS_PRIEST.."DPS"] = { 
		STAT_RESIST,
		SPELL_STAT0_NAME, 
		SPELL_STAT1_NAME,
		STAT_HEALING, 
		STAT_AP,
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_MAGE_ONLY, 
		STAT_WARLOCK_ONLY
	}
}

Altoholic.BaseStats = {	-- the order of these strings should match the "-s" in the associated entry of the FormatStats table
	[CLASS_MAGE.."DPS"]		    = { SPELL_STAT2_NAME, SPELL_STAT3_NAME, SPELL_STAT4_NAME, ITEM_MOD_CRIT_SPELL_RATING, ITEM_MOD_HIT_SPELL_RATING, STAT_SPELLDMG },
	[CLASS_WARRIOR.."Tank"]	    = { SPELL_STAT2_NAME, SPELL_STAT0_NAME, ITEM_MOD_DEFENSE_SKILL_RATING, ITEM_MOD_DODGE_RATING, ITEM_MOD_HIT_RATING },
	[CLASS_WARRIOR.."DPS"]	    = { SPELL_STAT2_NAME, SPELL_STAT0_NAME, SPELL_STAT1_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP },
	[CLASS_HUNTER.."DPS"]	    = { SPELL_STAT2_NAME, SPELL_STAT1_NAME, SPELL_STAT3_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP },
	[CLASS_ROGUE.."DPS"]		= { SPELL_STAT2_NAME, SPELL_STAT1_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP },
	[CLASS_WARLOCK.."DPS"]	    = { SPELL_STAT2_NAME, SPELL_STAT3_NAME, ITEM_MOD_CRIT_SPELL_RATING, ITEM_MOD_HIT_SPELL_RATING, STAT_SPELLDMG },
	[CLASS_DRUID.."Tank"]	    = { SPELL_STAT2_NAME, SPELL_STAT0_NAME, SPELL_STAT1_NAME, ITEM_MOD_DEFENSE_SKILL_RATING, ITEM_MOD_DODGE_RATING, ITEM_MOD_HIT_RATING },
	[CLASS_DRUID.."Heal"]	    = { SPELL_STAT2_NAME, SPELL_STAT3_NAME, SPELL_STAT4_NAME, ITEM_MOD_CRIT_SPELL_RATING, STAT_MP5, STAT_HEALING },
	[CLASS_DRUID.."DPS"]		= { SPELL_STAT2_NAME, SPELL_STAT0_NAME, SPELL_STAT1_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP },
	[CLASS_DRUID.."Balance"]	= { SPELL_STAT2_NAME, SPELL_STAT3_NAME, STAT_MP5, ITEM_MOD_CRIT_SPELL_RATING, ITEM_MOD_HIT_SPELL_RATING, STAT_SPELLDMG },
	[CLASS_SHAMAN.."Heal"]	    = { SPELL_STAT2_NAME, SPELL_STAT3_NAME, ITEM_MOD_CRIT_SPELL_RATING, STAT_MP5, STAT_HEALING },
	[CLASS_SHAMAN.."DPS"]	    = { SPELL_STAT2_NAME, SPELL_STAT0_NAME, SPELL_STAT1_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP },
	[CLASS_SHAMAN.."Elemental"]	= { SPELL_STAT2_NAME, SPELL_STAT3_NAME, STAT_MP5, ITEM_MOD_CRIT_SPELL_RATING, ITEM_MOD_HIT_SPELL_RATING, STAT_SPELLDMG },
	[CLASS_PALADIN.."Tank"]	    = { SPELL_STAT2_NAME, SPELL_STAT0_NAME, ITEM_MOD_DEFENSE_SKILL_RATING, ITEM_MOD_DODGE_RATING, ITEM_MOD_HIT_RATING, STAT_SPELLDMG },
	[CLASS_PALADIN.."Heal"] 	= { SPELL_STAT2_NAME, SPELL_STAT3_NAME, ITEM_MOD_CRIT_SPELL_RATING, STAT_MP5, STAT_HEALING },
	[CLASS_PALADIN.."DPS"]	    = { SPELL_STAT2_NAME, SPELL_STAT0_NAME, SPELL_STAT3_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP },
	[CLASS_PRIEST.."Heal"]	    = { SPELL_STAT2_NAME, SPELL_STAT3_NAME, SPELL_STAT4_NAME, ITEM_MOD_CRIT_SPELL_RATING, STAT_MP5, STAT_HEALING },
	[CLASS_PRIEST.."DPS"]	    = { SPELL_STAT2_NAME, SPELL_STAT3_NAME, SPELL_STAT4_NAME, ITEM_MOD_CRIT_SPELL_RATING, ITEM_MOD_HIT_SPELL_RATING, STAT_SPELLDMG },
}

Altoholic.FormatStats = {
	[CLASS_MAGE.."DPS"]		    = L["Sta:-s |rInt:-s |rSpi:-s\n|rCrit:-s |rHit:-s |rDmg:-s"],
	[CLASS_WARRIOR.."Tank"]	    = L["Sta:-s |rStr:-s |rDef:-s\n|rDodge:-s |rHit:-s"],
	[CLASS_WARRIOR.."DPS"]	    = L["Sta:-s |rStr:-s |rAgi:-s\n|rCrit:-s |rHit:-s |rAP:-s"],
	[CLASS_HUNTER.."DPS"]	    = L["Sta:-s |rAgi:-s |rInt:-s\n|rCrit:-s |rHit:-s |rAP:-s"],
	[CLASS_ROGUE.."DPS"]		= L["Sta:-s |rAgi:-s\n|rCrit:-s |rHit:-s |rAP:-s"],
	[CLASS_WARLOCK.."DPS"]	    = L["Sta:-s |rInt:-s\n|rCrit:-s |rHit:-s |rDmg:-s"],
	[CLASS_DRUID.."Tank"]	    = L["Sta:-s |rStr:-s |rAgi:-s\n|rDef:-s |rDodge:-s |rHit:-s"],
	[CLASS_DRUID.."Heal"]	    = L["Sta:-s |rInt:-s |rSpi:-s\n|rCrit:-s |rMP5:-s |rHeal:-s"],
	[CLASS_DRUID.."DPS"]		= L["Sta:-s |rStr:-s |rAgi:-s\n|rCrit:-s |rHit:-s |rAP:-s"],
	[CLASS_DRUID.."Balance"]	= L["Sta:-s |rInt:-s |rMP5:-s\n|rCrit:-s |rHit:-s |rDmg:-s"],
	[CLASS_SHAMAN.."Heal"]	    = L["Sta:-s |rInt:-s\n|rCrit:-s |rMP5:-s |rHeal:-s"],
	[CLASS_SHAMAN.."DPS"]	    = L["Sta:-s |rStr:-s |rAgi:-s\n|rCrit:-s |rHit:-s |rAP:-s"],
	[CLASS_SHAMAN.."Elemental"]	= L["Sta:-s |rInt:-s |rMP5:-s\n|rCrit:-s |rHit:-s |rDmg:-s"],
	[CLASS_PALADIN.."Tank"]	    = L["Sta:-s |rInt:-s |rDef:-s\n|rDodge:-s |rHit:-s |rDmg:-s"],
	[CLASS_PALADIN.."Heal"]	    = L["Sta:-s |rInt:-s\n|rCrit:-s |rMP5:-s |rHeal:-s"],
	[CLASS_PALADIN.."DPS"]	    = L["Sta:-s |rStr:-s |rInt:-s\n|rCrit:-s |rHit:-s |rAP:-s"],
	[CLASS_PRIEST.."Heal"]	    = L["Sta:-s |rInt:-s |rSpi:-s\n|rCrit:-s |rMP5:-s |rHeal:-s"],
	[CLASS_PRIEST.."DPS"]	    = L["Sta:-s |rInt:-s |rSpi:-s\n|rCrit:-s |rHit:-s |rDmg:-s"],
}

-- Add herb/ore possession info to Plants/Mines, thanks to Tempus on wowace for gathering this.
Altoholic.Gathering = {

	[L["Adamantite Deposit"]]              = 23425, -- Adamantite Ore
	[L["Copper Vein"]]                     =  2770, -- Copper Ore
	[L["Dark Iron Deposit"]]               = 11370, -- Dark Iron Ore
	[L["Fel Iron Deposit"]]                = 23424, -- Fel Iron Ore
	[L["Gold Vein"]]                       =  2776, -- Gold Ore
	[L["Hakkari Thorium Vein"]]            = 10620, -- Thorium Ore
	[L["Iron Deposit"]]                    =  2772, -- Iron Ore
	[L["Khorium Vein"]]                    = 23426, -- Khorium Ore
	[L["Mithril Deposit"]]                 =  3858, -- Mithril Ore
	[L["Ooze Covered Gold Vein"]]          =  2776, -- Gold Ore
	[L["Ooze Covered Mithril Deposit"]]    =  3858, -- Mithril Ore
	[L["Ooze Covered Rich Thorium Vein"]]  = 10620, -- Thorium Ore
	[L["Ooze Covered Silver Vein"]]        =  2775, -- Silver Ore
	[L["Ooze Covered Thorium Vein"]]       = 10620, -- Thorium Ore
	[L["Ooze Covered Truesilver Deposit"]] =  7911, -- Truesilver Ore
	[L["Rich Adamantite Deposit"]]         = 23425, -- Adamantite Ore
	[L["Rich Thorium Vein"]]               = 10620, -- Thorium Ore
	[L["Silver Vein"]]                     =  2775, -- Silver Ore
	[L["Small Thorium Vein"]]              = 10620, -- Thorium Ore
	[L["Tin Vein"]]                        =  2771, -- Tin Ore
	[L["Truesilver Deposit"]]              =  7911, -- Truesilver Ore

	[L["Lesser Bloodstone Deposit"]]       =  4278, -- Lesser Bloodstone Ore
	[L["Incendicite Mineral Vein"]]        =  3340, -- Incendicite Ore
	[L["Indurium Mineral Vein"]]           =  5833, -- Indurium Ore
	[L["Nethercite Deposit"]]              = 32464, -- Nethercite Ore
	-- [L["Large Obsidian Chunk"]] = ??,
	-- [L["Small Obsidian Chunk"]] = ??,

	[L["Ancient Lichen"]]       = 22790,
	[L["Arthas' Tears"]]        =  8836,
	[L["Black Lotus"]]          = 13768,
	[L["Blindweed"]]            =  8839,
	[L["Bloodthistle"]]         = 22710,
	[L["Briarthorn"]]           =  2450,
	[L["Bruiseweed"]]           =  2453,
	[L["Dreamfoil"]]            = 13463,
	[L["Dreaming Glory"]]       = 22786,
	[L["Earthroot"]]            =  2449,
	[L["Fadeleaf"]]             =  3818,
	[L["Felweed"]]              = 22785,
	[L["Firebloom"]]            =  4625,
	[L["Flame Cap"]]            = 22788,
	[L["Ghost Mushroom"]]       =  8845,
	[L["Golden Sansam"]]        = 13464,
	[L["Goldthorn"]]            =  3821,
	[L["Grave Moss"]]           =  3369,
	[L["Gromsblood"]]           =  8846,
	[L["Icecap"]]               = 13469,
	[L["Khadgar's Whisker"]]    =  3358,
	[L["Kingsblood"]]           =  3356,
	[L["Liferoot"]]             =  3357,
	[L["Mageroyal"]]            =   785,
	[L["Mana Thistle"]]         = 22793,
	[L["Mountain Silversage"]]  = 13465,
	[L["Netherbloom"]]          = 22791,
	[L["Nightmare Vine"]]       = 22792,
	[L["Peacebloom"]]           =  2447,
	[L["Plaguebloom"]]          = 13466,
	[L["Purple Lotus"]]         =  8831,
	[L["Ragveil"]]              = 22787,
	[L["Silverleaf"]]           =   765,
	[L["Stranglekelp"]]         =  3820,
	[L["Sungrass"]]             =  8838,
	[L["Terocone"]]             = 22789,
	[L["Wild Steelbloom"]]      =  3355,
	[L["Wintersbite"]]          =  3819,

	[L["Glowcap"]]              = 24245,
	[L["Netherdust Bush"]]      = 32468, -- Netherdust Pollen
	[L["Sanguine Hibiscus"]]    = 24246,
}

function Altoholic:CmdSearchBags(word1, word2)
	if not (AltoholicFrame:IsVisible()) then
		AltoholicFrame:Show();
	end
	local text = word1
	if word2 then
		text = text .. " " .. word2
	end
	AltoholicFrame_SearchEditBox:SetText(strlower(text))
	Altoholic:SearchItem();
end

function Altoholic:strsplit(delimiter, subject)
  local delimiter, fields = delimiter or ":", {}
  local pattern = string.format("([^%s]+)", delimiter)
  string.gsub(subject, pattern, function(c) fields[table.getn(fields)+1] = c end)
  return unpack(fields)
end

Altoholic_UIDropDownMenu_CreateInfo = Altoholic_UIDropDownMenu_CreateInfo or loadstring("local t = {} return function() for k in pairs(t) do t[k] = nil t[k] = {} end return t end")()