-------------------------------------------------------------------------------
-- Constants.lua
-------------------------------------------------------------------------------
-- File date: 2010-07-07T09:34:58Z
-- File hash: 71e6a45
-- Project hash: fc58e9f
-- Project version: v2.01-14-gfc58e9f
-------------------------------------------------------------------------------
-- Please see http://www.wowace.com/addons/arl/ for more information.
-------------------------------------------------------------------------------
-- This source code is released under All Rights Reserved.
-------------------------------------------------------------------------------
-- **AckisRecipeList** provides an interface for scanning professions for missing recipes.
-- There are a set of functions which allow you make use of the ARL database outside of ARL.
-- ARL supports all professions currently in World of Warcraft 3.3.2
-- @class file
-- @name ARL.lua
-- @release 1.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------
local ns               = select(2, ...)

-------------------------------------------------------------------------------
-- Profession data.
-------------------------------------------------------------------------------

ns.professions         = {
	["Alchemy"]        = 11611,
	["Blacksmithing"]  = 9785, -- Blacksmithing
	["Engineering"]    = 12656, -- Engineering
	["Enchanting"]     = 13920, -- Enchanting
	["Jewelcrafting"]  = 28895, -- Jewelcrafting
	["Leatherworking"] = 10662, -- Leatherworking
	["Weaponcrafting"] = 201004, -- Weaponcrafting
	["Tailoring"]      = 12180, -- Tailoring
	["Armorcrafting"]  = 202008, -- Armorcrafting
}
ns.ordered_professions = {
	--ns.professions.Blacksmithing,
	--ns.professions.Leatherworking,
	--ns.professions.Tailoring,
	ns.professions.Armorcrafting,
	ns.professions.Weaponcrafting,
	ns.professions.Jewelcrafting,
	ns.professions.Enchanting,
	ns.professions.Engineering,
	ns.professions.Alchemy,
}

ns.profession_textures = {
	"alchemy", -- 1
	"blacksmith", -- 2
	"cooking", -- 3
	"enchant", -- 4
	"engineer", -- 5
	"firstaid", -- 6
	"inscribe", -- 7
	"jewel",   -- 8
	"leather", -- 9
	"runeforge", -- 10
	"smelting", -- 11
	"tailor",  -- 12
}

-------------------------------------------------------------------------------
-- Item checkboxes
-------------------------------------------------------------------------------
ns.item_qualities      = {
	--{ tt = "", text = "Poor",      section = 0 },
	{ tt = "", text = "Common",    section = 1 },
	{ tt = "", text = "Uncommon",  section = 2 },
	{ tt = "", text = "Rare",      section = 3 },
	{ tt = "", text = "Epic",      section = 4 },
	{ tt = "", text = "Legendary", section = 5 },
	{ tt = "", text = "Artifact",  section = 6 },
}

ns.item_stats          = {
	{ tt = ITEM_MOD_INTELLECT_SHORT,          text = "Intellect",    section = "ITEM_MOD_INTELLECT_SHORT" },
	{ tt = ITEM_MOD_STRENGTH_SHORT,           text = "Strength",     section = "ITEM_MOD_STRENGTH_SHORT" },
	{ tt = ITEM_MOD_AGILITY_SHORT,            text = "Agility",      section = "ITEM_MOD_AGILITY_SHORT" },
	{ tt = ITEM_MOD_SPIRIT_SHORT,             text = "Spirit",       section = "ITEM_MOD_SPIRIT_SHORT" },
	{ tt = ITEM_MOD_STAMINA_SHORT,            text = "Stamina",      section = "ITEM_MOD_STAMINA_SHORT" },
	{ tt = ITEM_MOD_EXPERTISE_RATING_SHORT,   text = "Lucky Hit",    section = "ITEM_MOD_EXPERTISE_RATING_SHORT" },
	{ tt = ITEM_MOD_SPELL_POWER_SHORT,        text = "Spell Power",  section = "ITEM_MOD_SPELL_POWER_SHORT" },
	{ tt = ITEM_MOD_HIT_RANGED_RATING_SHORT,  text = "Fire SP",      section = "ITEM_MOD_HIT_RANGED_RATING_SHORT" },
	{ tt = ITEM_MOD_HIT_SPELL_RATING_SHORT,   text = "Nature SP",    section = "ITEM_MOD_HIT_SPELL_RATING_SHORT" },
	{ tt = ITEM_MOD_CRIT_RANGED_RATING_SHORT, text = "Shadow SP",    section = "ITEM_MOD_CRIT_RANGED_RATING_SHORT" },
	{ tt = ITEM_MOD_HIT_MELEE_RATING_SHORT,   text = "Holy SP",      section = "ITEM_MOD_HIT_MELEE_RATING_SHORT" },
	{ tt = ITEM_MOD_CRIT_SPELL_RATING_SHORT,  text = "Arcane SP",    section = "ITEM_MOD_CRIT_SPELL_RATING_SHORT" },
	{ tt = ITEM_MOD_CRIT_MELEE_RATING_SHORT,  text = "Frost SP",     section = "ITEM_MOD_CRIT_MELEE_RATING_SHORT" },
	{ tt = ITEM_MOD_HASTE_RATING_SHORT,       text = "Haste",        section = "ITEM_MOD_HASTE_RATING_SHORT" },
	{ tt = ITEM_MOD_CRIT_RATING_SHORT,        text = "Critical hit", section = "ITEM_MOD_CRIT_RATING_SHORT" },
	{
		tt = ITEM_MOD_HIT_TAKEN_MELEE_RATING_SHORT,
		text = "CDR",
		section =
		"ITEM_MOD_HIT_TAKEN_MELEE_RATING_SHORT"
	},
	{ tt = ITEM_MOD_HIT_RATING_SHORT, text = "Hit", section = "ITEM_MOD_HIT_RATING_SHORT" },
}
-------------------------------------------------------------------------------
-- Colors.
-------------------------------------------------------------------------------
local function RGBtoHEX(r, g, b)
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function GetColorsFromTable(dict)
	return dict.r, dict.g, dict.b
end

-- Recipe difficulty colors.
ns.difficulty_colors = {
	["trivial"] = "808080",
	["easy"] = "40bf40",
	["medium"] = "ffff00",
	["optimal"] = "ff8040",
	["impossible"] = "ff0000",
}

ns.basic_colors = {
	["grey"] = "666666",
	["white"] = "ffffff",
	["yellow"] = "ffff00",
	["normal"] = "ffd100",
}
