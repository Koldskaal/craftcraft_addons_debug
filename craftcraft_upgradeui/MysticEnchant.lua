local Addon = select(2, ...)
local M = CreateFrame("FRAME", "MysticEnchantingFrame", Collections)
Addon.MysticEnchant = M
-- Ref for compatability with older UI
CollectionsFrame = M
M:SetFrameStrata("DIALOG")

-------------------------------------------------------------------------------
--                                  Settings                                 --
-------------------------------------------------------------------------------

local GLOBAL_BREATHING_ENABLED = false
local ACTIVE_ITEM = nil
local ACTIVE_ENCHANT = nil
local ITEM_BAG = nil
local ITEM_SLOT = nil
local ITEM_BAG_TEMP = nil
local ITEM_SLOT_TEMP = nil
local CAN_REFUND = false

local UNKNOWN_ENCHANT_ICON = "Interface\\Icons\\Inv_misc_questionmark"

local REFORGE_QUALITY_MIN = 2
local REFORGE_QUALITY_MAX = 5

local ReforgeToken = 98462
local ReforgeExtract = 98463
local ReforgeOrb = 98570
local balanceToken = 0
local balanceExtract = 0
local balanceOrbs = 0


local REFORGE_GOLD_COST = 25000
local REFORGE_RUNE_COST = 1

local ENCHANT_GREEN_ORB_COST = 3
local ENCHANT_BLUE_ORB_COST = 6
local ENCHANT_PURPLE_ORB_COST = 10
local ENCHANT_LEGENDARY_ORB_COST = 25

local ENCHANT_GOLD_MULTIPLIER = 150000

local ENCHANT_GREEN_GOLD_COST = ENCHANT_GREEN_ORB_COST * ENCHANT_GOLD_MULTIPLIER
local ENCHANT_BLUE_GOLD_COST = ENCHANT_BLUE_ORB_COST * ENCHANT_GOLD_MULTIPLIER
local ENCHANT_PURPLE_GOLD_COST = ENCHANT_PURPLE_ORB_COST * ENCHANT_GOLD_MULTIPLIER
local ENCHANT_LEGENDARY_GOLD_COST = ENCHANT_LEGENDARY_ORB_COST * ENCHANT_GOLD_MULTIPLIER

local ReforgeTokenTexture = "Interface\\Icons\\Inv_Custom_ReforgeToken"
local ReforgeExtractTexture = "Interface\\Icons\\Inv_Custom_MysticExtract"
local ReforgeOrbTexture = "Interface\\Icons\\inv_custom_CollectionRCurrency"

-- Search will respect these categories, categories not included will search all enchants.
local SEARCH_INSIDE_CATEGORY_ID = {
    [2] = true,  -- Relevant (Popular)
    [3] = true,  -- Relevant (All)
    [4] = true,  -- Armor Only
    [5] = true,  -- "ANY" Enchants (same as 1)
    [6] = true,  -- Known Enchants
    [7] = true,  -- Unknown Enchants
    [8] = true,  -- Uncommon
    [9] = true,  -- Rare
    [10] = true, -- Epic
    [11] = true, -- Legendary
    [12] = true, -- Worldforged
}

-- FIXME: better way of handling blocked slots.
-- [Inv Type thats valid] = "disallowed class"
local VALID_INVTYPE = {
    ["INVTYPE_HEAD"] = true,
    ["INVTYPE_NECK"] = true,
    ["INVTYPE_SHOULDER"] = true,
    ["INVTYPE_BODY"] = true,
    ["INVTYPE_CHEST"] = true,
    ["INVTYPE_ROBE"] = true,
    ["INVTYPE_WAIST"] = true,
    ["INVTYPE_LEGS"] = true,
    ["INVTYPE_FEET"] = true,
    ["INVTYPE_WRIST"] = true,
    ["INVTYPE_HAND"] = true,
    ["INVTYPE_FINGER"] = true,
    ["INVTYPE_TRINKET"] = true,
    ["INVTYPE_CLOAK"] = true,
    ["INVTYPE_WEAPON"] = "ARMOR",
    ["INVTYPE_SHIELD"] = "ARMOR",
    ["INVTYPE_2HWEAPON"] = "ARMOR",
    ["INVTYPE_WEAPONMAINHAND"] = "ARMOR",
    ["INVTYPE_WEAPONOFFHAND"] = "ARMOR",
    ["INVTYPE_HOLDABLE"] = "ARMOR",
    ["INVTYPE_RANGED"] = "ARMOR",
    ["INVTYPE_THROWN"] = "ARMOR",
    ["INVTYPE_RANGEDRIGHT"] = "ARMOR",
    ["INVTYPE_RELIC"] = "ARMOR",
}

local ParentButtons = {
    [1] = CharacterHeadSlot,
    [2] = CharacterNeckSlot,
    [3] = CharacterShoulderSlot,
    [15] = CharacterBackSlot,
    [5] = CharacterChestSlot,
    [4] = CharacterShirtSlot,
    [19] = CharacterTabardSlot,
    [9] = CharacterWristSlot,
    [10] = CharacterHandsSlot,
    [6] = CharacterWaistSlot,
    [7] = CharacterLegsSlot,
    [8] = CharacterFeetSlot,
    [11] = CharacterFinger0Slot,
    [12] = CharacterFinger1Slot,
    [13] = CharacterTrinket0Slot,
    [14] = CharacterTrinket1Slot,
    [16] = CharacterMainHandSlot,
    [17] = CharacterSecondaryHandSlot,
    [18] = CharacterRangedSlot
}

local PaperDoll_RE_Total_Quality = {
}

M.PaperDollEnchantQualitySettings = {
    Addon.AwTexPath .. "enchant\\EnchantBorder_white",
    Addon.AwTexPath .. "EnchOverhaul\\BorderNewGreen",
    Addon.AwTexPath .. "EnchOverhaul\\BorderNewBlue",
    Addon.AwTexPath .. "EnchOverhaul\\BorderNewEpic",
    Addon.AwTexPath .. "EnchOverhaul\\BorderNewLeg",
    [0] = Addon.AwTexPath .. "enchant\\EnchantBorder_white", -- Quality 0 = missing enchant
}

local CollectionSlotMap = {
}

local EnchantableHeirlooms = {
    [42943] = true,
    [42944] = true,
    [42945] = true,
    [42946] = true,
    [42947] = true,
    [42948] = true,
    [42949] = true,
    [42950] = true,
    [42951] = true,
    [42952] = true,
    [42984] = true,
    [42985] = true,
    [42991] = true,
    [42992] = true,
    [44091] = true,
    [44092] = true,
    [44093] = true,
    [44094] = true,
    [44095] = true,
    [44096] = true,
    [44097] = true,
    [44098] = true,
    [44099] = true,
    [44100] = true,
    [44101] = true,
    [44102] = true,
    [44103] = true,
    [44105] = true,
    [44107] = true,
    [48677] = true,
    [48683] = true,
    [48685] = true,
    [48687] = true,
    [48689] = true,
    [48691] = true,
    [48716] = true,
    [48718] = true,
    [1542949] = true,
    [1548685] = true,
    [1540350] = true,
    [1542943] = true,
    [1880000] = true,
    [97747] = true,
}

local ExtractableHeirlooms = {
    [1880000] = true,
    [97747] = true,
}
-------------------------------------------------------------------------------
--                                 Variables                                 --
-------------------------------------------------------------------------------
M.MaxEcnhantsPerPage = 15
M.EnchantList = {}
M.CurrentList = {}
M.CurrentPage = 1
M.PageCount = 1
M.SuccessChance = 100
M.KnownEnchants = 0
M.TotalEnchants = #M.EnchantList
M.QualityData = {}
M.KnownEnchantCount = 0
M.IsTryingToCast = false

M.EnchantQualitySettings = {
    [0] = { "|cff00FF00", "Spells\\Creature_spellportallarge_green.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_UnCommon", { 0.12, 1.00, 0.00 } },
    [1] = { "|cffffffff", "Spells\\Creature_spellportallarge_lightred.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_Common", { 1.00, 1.00, 1.00 } },
    [2] = { "|cff1eff00", "Spells\\Creature_spellportallarge_green.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_UnCommon", { 0.12, 1.00, 0.00 } },
    [3] = { "|cff0070dd", "Spells\\Creature_spellportallarge_blue.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_Rare", { 0.00, 0.44, 0.87 } },
    [4] = { "|cffa335ee", "Spells\\Creature_spellportallarge_purple.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_Epic", { 0.64, 0.21, 0.93 } },
    [5] = { "|cffff8000", "Spells\\Creature_spellportallarge_yellow.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_Legendary", { 1.00, 0.50, 0.00 } },
    [6] = { "|cffff8000", "Spells\\Creature_spellportallarge_yellow.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_Legendary", { 1.00, 0.50, 0.00 } },
    [7] = { "|cffff8000", "Spells\\Creature_spellportallarge_yellow.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_Legendary", { 1.00, 0.50, 0.00 } },
    [8] = { "|cffff8000", "Spells\\Creature_spellportallarge_yellow.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_Legendary", { 1.00, 0.50, 0.00 } },
    [9] = { "|cffff8000", "Spells\\Creature_spellportallarge_yellow.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_Legendary", { 1.00, 0.50, 0.00 } },
    [10] = { "|cffff8000", "Spells\\Creature_spellportallarge_yellow.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_Legendary", { 1.00, 0.50, 0.00 } },
    [11] = { "|cffff8000", "Spells\\Creature_spellportallarge_yellow.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_Legendary", { 1.00, 0.50, 0.00 } },
    [12] = { "|cffff8000", "Spells\\Creature_spellportallarge_yellow.m2", Addon.AwTexPath .. "Collections\\EnchantEffect_Legendary", { 1.00, 0.50, 0.00 } },
}

M.MaxQualityLibrary = {
    [0] = 19,
    [1] = 19,
    [2] = 19,
    [3] = 19,
    [4] = 3,
    [5] = 1,
    [6] = 19,
    [7] = 19,
    [8] = 19,
}
M.SlotStackData = {}

StaticPopupDialogs["ASC_ERROR_TIMEOUT"] = {
    text = "Choose Mystic Enchant to add it to your build",
    button1 = OKAY,
    --button2 = "Cancel",
    whileDead = true,
    timeout = 5,
    hideOnEscape = true,
    exclusive = 1,
    --[[OnAccept = function(self)
        print("Accept, Debug")
    end]] --
}

StaticPopupDialogs["ASC_REFORGE_COST_GOLD"] = {
    text = "", -- set by show
    button1 = OKAY,
    button2 = CANCEL,
    whileDead = true,
    hideOnEscape = true,
    exclusive = 1,
    acceptFunc = function()
        M.AllowReforgeGoldCost = true
    end
}

local EXTRACT_TOOLTIP_DEFAULT = { "|cffFFFFFFClick to Extract|r", "|cffFFFFFFRequires|r x1 |cffFFFFFF|T" ..
ReforgeExtractTexture .. ".blp:13:13|t Mystic Extract|r" }
local EXTRACT_TOOLTIP_NO_GOSSIP = { "|cffFFFFFFInteract with a Mystic Enchanting Altar to extract an enchant|r" }
local EXTRACT_TOOLTIP_NO_EXTRACT = { "|cffCC0000Cannot Extract Enchant|r", "Requires |cffFFFFFFx1 |T" ..
ReforgeExtractTexture .. ".blp:13:13|t Mystic Extract|r",
    "|cffFFFFFFMystic Extracts|r are earned each time you level up your |cffFFFFFFMystic Enchanting Level|r",
    "Your |cffFFFFFFMystic Enchanting Level|r is increased by reforging equipment!" }
local EXTRACT_TOOLTIP_NO_ITEM = { "|cffCC0000Cannot Extract Enchant|r",
    "|cffFFFFFFPlace an item with an enchant you want to store in your collection into the altar to extract it|r" }
local EXTRACT_TOOLTIP_NO_ENCHANT = { "|cffCC0000Cannot Extract Enchant|r",
    "|cffFFFFFFThe current item does not have an enchantment on it!" }
local EXTRACT_TOOLTIP_LOW_QUALITY = { "|cffCC0000Cannot Extract Enchant|r",
    "|cffFFFFFFItem quality must be|r |cff0070FFRare|r |cffFFFFFFor higher to extract an enchant|r" }
local EXTRACT_TOOLTIP_HIGH_QUALITY = { "|cffCC0000Cannot Extract Enchant|r",
    "|cffFFFFFFItem quality must be|r |cffFF8000Legendary|r |cffFFFFFFor lower to extract an enchant|r" }

local EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_DEFAULT

local REFORGE_TOOLTIP_DEFAULT = { "|cffFFFFFFClick to Reforge|r", "|cffFFFFFFRequires|r x1 |cffFFFFFF|T" ..
ReforgeTokenTexture .. ".blp:13:13|t Mystic Rune or gold" }
local REFORGE_TOOLTIP_NO_GOSSIP = { "|cffFFFFFFInteract with a Mystic Enchanting Altar to reforge an item|r" }
local REFORGE_TOOLTIP_NO_ITEM = { "|cffCC0000Cannot Reforge|r",
    "|cffFFFFFFYou must place an item in the enchanting slot to reforge and discover new enchants|r" }
local REFORGE_TOOLTIP_LOW_QUALITY = { "|cffCC0000Cannot Reforge|r",
    "|cffFFFFFFItem quality must be|r |cff0070FFRare|r |cffFFFFFFor higher to reforge an item|r" }

local REFORGE_TOOLTIP = REFORGE_TOOLTIP_DEFAULT
-------------------------------------------------------------------------------
--                               Slot Template                               --
-------------------------------------------------------------------------------
local function CurrencyTemplate(name, parent)
    local frame = CreateFrame("BUTTON", "$parent." .. name, parent)
    frame:SetSize(207, 22)

    frame.BG_Left = frame:CreateTexture(nil, "BACKGROUND")
    frame.BG_Left:SetSize(6, 24)
    frame.BG_Left:SetPoint("LEFT", 0, 0)
    frame.BG_Left:SetTexCoord(0.0, 0.01171875, 0.421875, 0.5625)
    frame.BG_Left:SetTexture("Interface\\Buttons\\UI-Button-Borders2")
    --frame.BG_Left:SetVertexColor(0, 1, 0)

    frame.BG_Middle = frame:CreateTexture(nil, "BACKGROUND")
    frame.BG_Middle:SetSize(frame:GetWidth() - 12, 24)
    frame.BG_Middle:SetPoint("LEFT", frame.BG_Left, "RIGHT")
    frame.BG_Middle:SetTexCoord(0.01171875, 0.3046875, 0.421875, 0.5625)
    frame.BG_Middle:SetTexture("Interface\\Buttons\\UI-Button-Borders2")
    --frame.BG_Middle:SetVertexColor(0, 1, 0)

    frame.BG_Right = frame:CreateTexture(nil, "BACKGROUND")
    frame.BG_Right:SetSize(6, 24)
    frame.BG_Right:SetPoint("LEFT", frame.BG_Middle, "RIGHT")
    frame.BG_Right:SetTexCoord(0.3046875, 0.31640625, 0.421875, 0.5625)
    frame.BG_Right:SetTexture("Interface\\Buttons\\UI-Button-Borders2")
    --frame.BG_Right:SetVertexColor(0, 1, 0)

    frame.DescText = frame:CreateFontString()
    frame.DescText:SetFontObject(GameFontNormal)
    frame.DescText:SetPoint("LEFT", frame, 6, 0)
    frame.DescText:SetText("Your Mystic Orbs")
    frame.DescText:SetJustifyH("LEFT")

    frame.CurrencyButton = CreateFrame("BUTTON", "$parentCurrencyButton", frame)
    frame.CurrencyButton:SetSize(14, 14)
    frame.CurrencyButton:SetPoint("RIGHT", frame, -8, 0)

    frame.CurrencyButton.Icon = frame.CurrencyButton:CreateTexture(nil, "ARTWORK")
    frame.CurrencyButton.Icon:SetAllPoints()
    frame.CurrencyButton.Icon:SetTexture(ReforgeOrbTexture)

    frame.OrbText = frame:CreateFontString()
    frame.OrbText:SetFontObject(GameFontHighlight)
    frame.OrbText:SetPoint("RIGHT", frame.CurrencyButton, "LEFT", -4, 0)
    frame.OrbText:SetText("|cffFFFFFF1000|r")
    frame.OrbText:SetJustifyH("RIGHT")

    frame.Item = ReforgeOrb
    frame:SetScript("OnEnter", ItemButtonOnEnter)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    frame:SetScript("OnClick", ItemButtonOnClick)

    return frame
end

local function CreateUnlockAnimation(frame, size)
    frame.animStepAdd1Tex = frame:CreateTexture(nil, "ARTWORK")
    frame.animStepAdd1Tex:SetSize(size[1] * 0.8, size[2] * 0.8)
    frame.animStepAdd1Tex:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\AnimS1")
    frame.animStepAdd1Tex:SetPoint("CENTER", 0, 0)
    frame.animStepAdd1Tex:SetAlpha(0)

    frame.animStepAdd2Tex = frame:CreateTexture(nil, "OVERLAY")
    frame.animStepAdd2Tex:SetSize(unpack(size))
    frame.animStepAdd2Tex:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\AnimS2")
    frame.animStepAdd2Tex:SetPoint("CENTER", 0, 0)
    frame.animStepAdd2Tex:SetAlpha(0)

    frame.animStepAdd3Tex = frame:CreateTexture(nil, "ARTWORK")
    frame.animStepAdd3Tex:SetSize(unpack(size))
    frame.animStepAdd3Tex:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\AnimS3")
    frame.animStepAdd3Tex:SetPoint("CENTER", 0, 0)
    frame.animStepAdd3Tex:SetAlpha(0)

    -- 1st step of animation
    frame.animStepAdd1Tex.AG = frame.animStepAdd1Tex:CreateAnimationGroup()

    frame.animStepAdd1Tex.AG.Alpha0 = frame.animStepAdd1Tex.AG:CreateAnimation("Alpha")
    frame.animStepAdd1Tex.AG.Alpha0:SetStartDelay(0)
    frame.animStepAdd1Tex.AG.Alpha0:SetDuration(0.1)
    frame.animStepAdd1Tex.AG.Alpha0:SetOrder(0)
    frame.animStepAdd1Tex.AG.Alpha0:SetEndDelay(0)
    frame.animStepAdd1Tex.AG.Alpha0:SetSmoothing("IN")
    frame.animStepAdd1Tex.AG.Alpha0:SetChange(1)

    frame.animStepAdd1Tex.AG.Rotation = frame.animStepAdd1Tex.AG:CreateAnimation("Rotation")
    frame.animStepAdd1Tex.AG.Rotation:SetDuration(3)
    frame.animStepAdd1Tex.AG.Rotation:SetOrder(0)
    frame.animStepAdd1Tex.AG.Rotation:SetEndDelay(0)
    frame.animStepAdd1Tex.AG.Rotation:SetSmoothing("NONE")
    frame.animStepAdd1Tex.AG.Rotation:SetDegrees(-180)

    frame.animStepAdd1Tex.AG.Alpha1 = frame.animStepAdd1Tex.AG:CreateAnimation("Alpha")
    frame.animStepAdd1Tex.AG.Alpha1:SetStartDelay(0)
    frame.animStepAdd1Tex.AG.Alpha1:SetDuration(3)
    frame.animStepAdd1Tex.AG.Alpha1:SetOrder(1)
    frame.animStepAdd1Tex.AG.Alpha1:SetEndDelay(0)
    frame.animStepAdd1Tex.AG.Alpha1:SetSmoothing("OUT")
    frame.animStepAdd1Tex.AG.Alpha1:SetChange(-1)

    -- 2nd step of animation
    frame.animStepAdd2Tex.AG = frame.animStepAdd2Tex:CreateAnimationGroup()

    frame.animStepAdd2Tex.AG.Alpha0 = frame.animStepAdd2Tex.AG:CreateAnimation("Alpha")
    frame.animStepAdd2Tex.AG.Alpha0:SetStartDelay(0.5)
    frame.animStepAdd2Tex.AG.Alpha0:SetDuration(1)
    frame.animStepAdd2Tex.AG.Alpha0:SetOrder(0)
    frame.animStepAdd2Tex.AG.Alpha0:SetEndDelay(0)
    frame.animStepAdd2Tex.AG.Alpha0:SetSmoothing("IN")
    frame.animStepAdd2Tex.AG.Alpha0:SetChange(1)

    frame.animStepAdd2Tex.AG.Scale1 = frame.animStepAdd2Tex.AG:CreateAnimation("Scale")
    frame.animStepAdd2Tex.AG.Scale1:SetScale(0.1, 0.1)
    frame.animStepAdd2Tex.AG.Scale1:SetDuration(0.0)
    frame.animStepAdd2Tex.AG.Scale1:SetStartDelay(0)
    frame.animStepAdd2Tex.AG.Scale1:SetOrder(0)
    frame.animStepAdd2Tex.AG.Scale1:SetSmoothing("NONE")

    frame.animStepAdd2Tex.AG.Scale2 = frame.animStepAdd2Tex.AG:CreateAnimation("Scale")
    frame.animStepAdd2Tex.AG.Scale2:SetScale(10, 10)
    frame.animStepAdd2Tex.AG.Scale2:SetDuration(1)
    frame.animStepAdd2Tex.AG.Scale2:SetStartDelay(0)
    frame.animStepAdd2Tex.AG.Scale2:SetOrder(1)
    frame.animStepAdd2Tex.AG.Scale2:SetSmoothing("IN_OUT")

    frame.animStepAdd2Tex.AG.Alpha1 = frame.animStepAdd2Tex.AG:CreateAnimation("Alpha")
    frame.animStepAdd2Tex.AG.Alpha1:SetStartDelay(0)
    frame.animStepAdd2Tex.AG.Alpha1:SetDuration(4)
    frame.animStepAdd2Tex.AG.Alpha1:SetOrder(2)
    frame.animStepAdd2Tex.AG.Alpha1:SetEndDelay(0)
    frame.animStepAdd2Tex.AG.Alpha1:SetSmoothing("OUT")
    frame.animStepAdd2Tex.AG.Alpha1:SetChange(-1)

    -- 3rd step of animation
    frame.animStepAdd3Tex.AG = frame.animStepAdd3Tex:CreateAnimationGroup()

    frame.animStepAdd3Tex.AG.Alpha0 = frame.animStepAdd3Tex.AG:CreateAnimation("Alpha")
    frame.animStepAdd3Tex.AG.Alpha0:SetDuration(0.1)
    frame.animStepAdd3Tex.AG.Alpha0:SetOrder(1)
    frame.animStepAdd3Tex.AG.Alpha0:SetEndDelay(0)
    frame.animStepAdd3Tex.AG.Alpha0:SetSmoothing("IN")
    frame.animStepAdd3Tex.AG.Alpha0:SetChange(1)

    frame.animStepAdd3Tex.AG.Scale1 = frame.animStepAdd3Tex.AG:CreateAnimation("Scale")
    frame.animStepAdd3Tex.AG.Scale1:SetScale(0.1, 0.1)
    frame.animStepAdd3Tex.AG.Scale1:SetDuration(0.1)
    frame.animStepAdd3Tex.AG.Scale1:SetEndDelay(0)
    frame.animStepAdd3Tex.AG.Scale1:SetOrder(1)
    frame.animStepAdd3Tex.AG.Scale1:SetSmoothing("NONE")

    frame.animStepAdd3Tex.AG.Scale2 = frame.animStepAdd3Tex.AG:CreateAnimation("Scale")
    frame.animStepAdd3Tex.AG.Scale2:SetScale(15, 15)
    frame.animStepAdd3Tex.AG.Scale2:SetDuration(3)
    frame.animStepAdd3Tex.AG.Scale2:SetStartDelay(0)
    frame.animStepAdd3Tex.AG.Scale2:SetOrder(2)
    frame.animStepAdd3Tex.AG.Scale2:SetSmoothing("IN_OUT")

    frame.animStepAdd3Tex.AG.Alpha1 = frame.animStepAdd3Tex.AG:CreateAnimation("Alpha")
    frame.animStepAdd3Tex.AG.Alpha1:SetStartDelay(0)
    frame.animStepAdd3Tex.AG.Alpha1:SetDuration(3)
    frame.animStepAdd3Tex.AG.Alpha1:SetOrder(2)
    frame.animStepAdd3Tex.AG.Alpha1:SetEndDelay(0)
    frame.animStepAdd3Tex.AG.Alpha1:SetSmoothing("OUT")
    frame.animStepAdd3Tex.AG.Alpha1:SetChange(-1)

    local addFrame = CreateFrame("FRAME", nil, frame)
    addFrame:SetSize(frame:GetSize())
    addFrame:SetPoint("CENTER", 0, 0)

    addFrame.animStep1Tex = addFrame:CreateTexture(nil, "ARTWORK")
    addFrame.animStep1Tex:SetSize(size[1] * 0.8, size[2] * 0.8)
    addFrame.animStep1Tex:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\AnimS1")
    addFrame.animStep1Tex:SetPoint("CENTER", 0, 0)
    addFrame.animStep1Tex:SetBlendMode("ADD")
    addFrame.animStep1Tex:SetAlpha(0)

    addFrame.animStep2Tex = addFrame:CreateTexture(nil, "OVERLAY")
    addFrame.animStep2Tex:SetSize(unpack(size))
    addFrame.animStep2Tex:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\AnimS2")
    addFrame.animStep2Tex:SetPoint("CENTER", 0, 0)
    addFrame.animStep2Tex:SetBlendMode("ADD")
    addFrame.animStep2Tex:SetAlpha(0)

    addFrame.animStep3Tex = addFrame:CreateTexture(nil, "ARTWORK")
    addFrame.animStep3Tex:SetSize(unpack(size))
    addFrame.animStep3Tex:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\AnimS3")
    addFrame.animStep3Tex:SetPoint("CENTER", 0, 0)
    addFrame.animStep3Tex:SetBlendMode("ADD")
    addFrame.animStep3Tex:SetAlpha(0)

    -- 1st step of animation
    addFrame.animStep1Tex.AG = addFrame.animStep1Tex:CreateAnimationGroup()

    addFrame.animStep1Tex.AG.Alpha0 = addFrame.animStep1Tex.AG:CreateAnimation("Alpha")
    addFrame.animStep1Tex.AG.Alpha0:SetStartDelay(0)
    addFrame.animStep1Tex.AG.Alpha0:SetDuration(0.1)
    addFrame.animStep1Tex.AG.Alpha0:SetOrder(0)
    addFrame.animStep1Tex.AG.Alpha0:SetEndDelay(0)
    addFrame.animStep1Tex.AG.Alpha0:SetSmoothing("IN")
    addFrame.animStep1Tex.AG.Alpha0:SetChange(1)

    addFrame.animStep1Tex.AG.Rotation = addFrame.animStep1Tex.AG:CreateAnimation("Rotation")
    addFrame.animStep1Tex.AG.Rotation:SetDuration(3)
    addFrame.animStep1Tex.AG.Rotation:SetOrder(0)
    addFrame.animStep1Tex.AG.Rotation:SetEndDelay(0)
    addFrame.animStep1Tex.AG.Rotation:SetSmoothing("NONE")
    addFrame.animStep1Tex.AG.Rotation:SetDegrees(-180)

    addFrame.animStep1Tex.AG.Alpha1 = addFrame.animStep1Tex.AG:CreateAnimation("Alpha")
    addFrame.animStep1Tex.AG.Alpha1:SetStartDelay(0)
    addFrame.animStep1Tex.AG.Alpha1:SetDuration(3)
    addFrame.animStep1Tex.AG.Alpha1:SetOrder(1)
    addFrame.animStep1Tex.AG.Alpha1:SetEndDelay(0)
    addFrame.animStep1Tex.AG.Alpha1:SetSmoothing("OUT")
    addFrame.animStep1Tex.AG.Alpha1:SetChange(-1)

    -- 2nd step of animation
    addFrame.animStep2Tex.AG = addFrame.animStep2Tex:CreateAnimationGroup()

    addFrame.animStep2Tex.AG.Alpha0 = addFrame.animStep2Tex.AG:CreateAnimation("Alpha")
    addFrame.animStep2Tex.AG.Alpha0:SetStartDelay(0.5)
    addFrame.animStep2Tex.AG.Alpha0:SetDuration(1)
    addFrame.animStep2Tex.AG.Alpha0:SetOrder(0)
    addFrame.animStep2Tex.AG.Alpha0:SetEndDelay(0)
    addFrame.animStep2Tex.AG.Alpha0:SetSmoothing("IN")
    addFrame.animStep2Tex.AG.Alpha0:SetChange(1)

    addFrame.animStep2Tex.AG.Scale1 = addFrame.animStep2Tex.AG:CreateAnimation("Scale")
    addFrame.animStep2Tex.AG.Scale1:SetScale(0.1, 0.1)
    addFrame.animStep2Tex.AG.Scale1:SetDuration(0.0)
    addFrame.animStep2Tex.AG.Scale1:SetStartDelay(0)
    addFrame.animStep2Tex.AG.Scale1:SetOrder(0)
    addFrame.animStep2Tex.AG.Scale1:SetSmoothing("NONE")

    addFrame.animStep2Tex.AG.Scale2 = addFrame.animStep2Tex.AG:CreateAnimation("Scale")
    addFrame.animStep2Tex.AG.Scale2:SetScale(10, 10)
    addFrame.animStep2Tex.AG.Scale2:SetDuration(1)
    addFrame.animStep2Tex.AG.Scale2:SetStartDelay(0)
    addFrame.animStep2Tex.AG.Scale2:SetOrder(1)
    addFrame.animStep2Tex.AG.Scale2:SetSmoothing("IN_OUT")

    addFrame.animStep2Tex.AG.Alpha1 = addFrame.animStep2Tex.AG:CreateAnimation("Alpha")
    addFrame.animStep2Tex.AG.Alpha1:SetStartDelay(0)
    addFrame.animStep2Tex.AG.Alpha1:SetDuration(4)
    addFrame.animStep2Tex.AG.Alpha1:SetOrder(2)
    addFrame.animStep2Tex.AG.Alpha1:SetEndDelay(0)
    addFrame.animStep2Tex.AG.Alpha1:SetSmoothing("OUT")
    addFrame.animStep2Tex.AG.Alpha1:SetChange(-1)

    -- 3rd step of animation
    addFrame.animStep3Tex.AG = addFrame.animStep3Tex:CreateAnimationGroup()

    addFrame.animStep3Tex.AG.Alpha0 = addFrame.animStep3Tex.AG:CreateAnimation("Alpha")
    addFrame.animStep3Tex.AG.Alpha0:SetDuration(0.1)
    addFrame.animStep3Tex.AG.Alpha0:SetOrder(1)
    addFrame.animStep3Tex.AG.Alpha0:SetEndDelay(0)
    addFrame.animStep3Tex.AG.Alpha0:SetSmoothing("IN")
    addFrame.animStep3Tex.AG.Alpha0:SetChange(1)

    addFrame.animStep3Tex.AG.Scale1 = addFrame.animStep3Tex.AG:CreateAnimation("Scale")
    addFrame.animStep3Tex.AG.Scale1:SetScale(0.1, 0.1)
    addFrame.animStep3Tex.AG.Scale1:SetDuration(0.1)
    addFrame.animStep3Tex.AG.Scale1:SetEndDelay(0)
    addFrame.animStep3Tex.AG.Scale1:SetOrder(1)
    addFrame.animStep3Tex.AG.Scale1:SetSmoothing("NONE")

    addFrame.animStep3Tex.AG.Scale2 = addFrame.animStep3Tex.AG:CreateAnimation("Scale")
    addFrame.animStep3Tex.AG.Scale2:SetScale(15, 15)
    addFrame.animStep3Tex.AG.Scale2:SetDuration(3)
    addFrame.animStep3Tex.AG.Scale2:SetStartDelay(0)
    addFrame.animStep3Tex.AG.Scale2:SetOrder(2)
    addFrame.animStep3Tex.AG.Scale2:SetSmoothing("IN_OUT")

    addFrame.animStep3Tex.AG.Alpha1 = addFrame.animStep3Tex.AG:CreateAnimation("Alpha")
    addFrame.animStep3Tex.AG.Alpha1:SetStartDelay(0)
    addFrame.animStep3Tex.AG.Alpha1:SetDuration(3)
    addFrame.animStep3Tex.AG.Alpha1:SetOrder(2)
    addFrame.animStep3Tex.AG.Alpha1:SetEndDelay(0)
    addFrame.animStep3Tex.AG.Alpha1:SetSmoothing("OUT")
    addFrame.animStep3Tex.AG.Alpha1:SetChange(-1)

    function frame.PlayUnlock()
        frame.animStepAdd1Tex.AG:Stop()
        frame.animStepAdd2Tex.AG:Stop()
        frame.animStepAdd3Tex.AG:Stop()

        frame.animStepAdd1Tex.AG:Play()
        frame.animStepAdd2Tex.AG:Play()
        frame.animStepAdd3Tex.AG:Play()

        addFrame.animStep1Tex.AG:Stop()
        addFrame.animStep2Tex.AG:Stop()
        addFrame.animStep3Tex.AG:Stop()

        addFrame.animStep1Tex.AG:Play()
        addFrame.animStep2Tex.AG:Play()
        addFrame.animStep3Tex.AG:Play()
    end

    frame.UnlockDone = function() end

    function frame.SetUnlockColor(r, g, b)
        frame.animStepAdd1Tex:SetVertexColor(r, g, b)
        frame.animStepAdd2Tex:SetVertexColor(r, g, b)
        frame.animStepAdd3Tex:SetVertexColor(r, g, b)
        addFrame.animStep1Tex:SetVertexColor(r, g, b)
        addFrame.animStep2Tex:SetVertexColor(r, g, b)
        addFrame.animStep3Tex:SetVertexColor(r, g, b)
    end

    addFrame.animStep2Tex.AG.Scale2:SetScript("OnFinished", function()
        frame.UnlockDone()
    end)
end

local function ActiveEffectButtonTemplate(parent)
    local frame = CreateFrame("FRAME", nil, parent)
    frame:SetSize(32, 32)

    frame.text = frame:CreateFontString(nil, "ARTWORK")
    frame.text:SetJustifyH("LEFT")
    frame.text:SetPoint("LEFT", 0, 0)
    frame.text:SetFontObject(GameFontNormalSmall)

    frame.btn = CreateFrame("BUTTON", nil, frame)
    frame.btn:SetSize(32, 32)
    frame.btn:SetNormalTexture(Addon.AwTexPath .. "EnchOverhaul\\qualityLight")
    frame.btn:SetHighlightTexture(Addon.AwTexPath .. "EnchOverhaul\\qualityLight")
    frame.btn:SetPoint("LEFT", frame.text, "RIGHT", -6, 0)
    frame.active = 0
    frame.total = 3
    frame.str = "|cffFFFFFF%i|r/%i"
    frame.quality = 1
    frame.tooltip = "Epic"
    frame.btn:SetScript("OnEnter", function(self)
        local _, _, _, qualityColor = GetItemQualityColor(self:GetParent().quality)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("|cffFFFFFFYou have " ..
            self:GetParent().active .. " " .. qualityColor .. self:GetParent().tooltip .. "|r |cffFFFFFFenchants.|r")
        GameTooltip:AddLine("You can't have more than " ..
            self:GetParent().total .. " " .. qualityColor .. self:GetParent().tooltip .. "|r enchants")
        GameTooltip:AddLine("be active at the same time.")
        GameTooltip:Show()
    end)
    frame.btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    frame.btn.BG = frame.btn:CreateTexture(nil, "BACKGROUND")
    frame.btn.BG:SetSize(16, 16)
    frame.btn.BG:SetPoint("CENTER")
    frame.btn.BG:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\QualityBorder")

    function frame.UpdateText()
        frame.text:SetText(string.format(frame.str, frame.active, frame.total))
    end

    frame.UpdateText()

    return frame
end

local function StackDisplayOnEnter(self)
    if self.Spell and self.Spell ~= 0 then
        local spellName = GetSpellInfo(self.Spell)
        local Link = "|cff71d5ff|Hspell:" .. self.Spell .. "|h[" .. spellName .. "]|h|r"
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(Link)

        if self.Quality ~= nil then
            local maxEnchants = M.MaxQualityLibrary[self.Quality]
            local qualityText = M.EnchantQualitySettings[self.Quality][1] ..
                _G["ITEM_QUALITY" .. self.Quality .. "_DESC"] .. "|r"

            local qualityStr = "You can only have |cffFFFFFF" .. maxEnchants .. "|r " .. qualityText ..
                " enchants active."
            local qualityStr2 = "Current " .. qualityText .. " Enchants: |cffFFFFFF%d/" .. maxEnchants .. "|r"

            if self.Quality == 4 and M.EquippedEpicEnchants > 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(qualityStr, nil, nil, nil, false)
                GameTooltip:AddLine(format(qualityStr2, M.EquippedEpicEnchants), nil, nil, nil, true)
            elseif self.Quality == 5 and M.EquippedLegendaryEnchants > 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(qualityStr, nil, nil, nil, false)
                GameTooltip:AddLine(format(qualityStr2, M.EquippedLegendaryEnchants), nil, nil, nil, true)
            end
        end

        GameTooltip:Show()
    end
end

local function EnchantStackDisplayButton_OnModifiedClick(self, button)
    if (IsModifiedClick("CHATLINK")) then
        if self.Spell and self.Spell ~= 0 then
            local spellName = GetSpellInfo(self.Spell)
            local Link = "|cff71d5ff|Hspell:" .. self.Spell .. "|h[" .. spellName .. "]|h|r"
            if (Link) then
                ChatEdit_InsertLink(Link);
            end
        end
        return;
    end
end

local function EnchantTemplate_Max(btn)
    btn.Icon:SetVertexColor(1, 0, 0, 1)
    if btn:GetNormalTexture() then
        btn:GetNormalTexture():SetVertexColor(1, 0, 0, 1)
    end
    btn.Maxed:Show()
end

local function EnchantTemplate_Normalize(btn)
    btn.Icon:SetVertexColor(1, 1, 1, 1)
    if (btn:GetNormalTexture()) then
        btn:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
    end
    btn.Maxed:Hide()
end

function M:CollectionEnchantTemplate(parent)
    local btn = CreateFrame("Button", nil, parent, nil)
    btn:SetSize(36, 36)
    btn:SetNormalTexture(Addon.AwTexPath .. "enchant\\EnchantBorder")
    btn:SetHighlightTexture(Addon.AwTexPath .. "enchant\\EnchantBorder_highlight")
    btn:GetHighlightTexture():ClearAllPoints()
    btn:GetHighlightTexture():SetSize(52, 52)
    btn:GetHighlightTexture():SetPoint("CENTER", 0, 0)
    btn:Hide()

    btn.Icon = btn:CreateTexture(nil, "BORDER", nil)
    btn.Icon:SetSize(28, 28)
    SetPortraitToTexture(btn.Icon, "Interface\\Icons\\inv_chest_samurai")
    btn.Icon:SetPoint("CENTER", 0, 0)

    btn.Maxed = btn:CreateTexture(nil, "OVERLAY", nil)
    btn.Maxed:SetSize(28, 28)
    btn.Maxed:SetPoint("CENTER", 0, 0)
    btn.Maxed:SetTexture(Addon.AwTexPath .. "enchant\\RedSign")
    btn.Maxed:Hide()

    btn:SetScript("OnEnter", StackDisplayOnEnter)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    btn:SetScript("OnClick", function(self, button)
        if (IsModifiedClick()) then
            EnchantStackDisplayButton_OnModifiedClick(self, button);
        end
    end)

    CreateUnlockAnimation(btn, { 128, 128 })

    function btn:SlotButtonSetQuality(quality)
        -- btn:SetNormalTexture(M.PaperDollEnchantQualitySettings[quality])
    end

    return btn
end

local function SlotButton_OnDisable(self)
    self.BG:SetDesaturated(true)
    self.Icon:SetDesaturated(true)
    self.breathing = false
end

local function SlotButton_OnEnable(self)
    self.BG:SetDesaturated(false)
    self.Icon:SetDesaturated(false)
    self.breathing = true
end

local function SlotButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    self:RegisterEvent("MODIFIER_STATE_CHANGED")

    local slotId, _, checkRelic = GetInventorySlotInfo(self.Slot)
    local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", slotId);
    if (not hasItem) then
        GameTooltip:SetText("Slot is empty");
    end

    CursorUpdate(self);
end

local function SlotButton_OnLeave(self)
    self:UnregisterEvent("MODIFIER_STATE_CHANGED")
    GameTooltip:Hide()
    ResetCursor()
end

local function SlotButton_OnEvent(self, event)
    if not (self.Slot) then
        return
    end

    local slotId = GetInventorySlotInfo(self.Slot)
    local itemId = GetInventoryItemID("player", slotId)

    if event == "PLAYER_EQUIPMENT_CHANGED" then
        if (itemId) then
            local texture = GetInventoryItemTexture("player", slotId)
            local quality = GetInventoryItemQuality("player", slotId) or 0
            self.Icon:Show()
            self.Icon:SetTexture(texture)

            if EnchantableHeirlooms[itemId] or (quality >= REFORGE_QUALITY_MIN) and (quality <= REFORGE_QUALITY_MAX) then
                self.Icon:SetDesaturated(false)
                self.breathing = true
            else
                self.Icon:SetDesaturated(true)
                self.breathing = false
            end
        else
            self.breathing = false
            self.Icon:Hide()
        end

        if (GLOBAL_BREATHING_ENABLED) and (self.breathing) then
            self.AnimatedTex.AG:Stop()
            self.AnimatedTex.AG:Play()
            self.AnimatedTex:Show()
        else
            self.AnimatedTex:Hide()
        end
        return
    end

    if (event == "MODIFIER_STATE_CHANGED") then
        if (self:IsMouseOver()) then
            self:GetScript("OnEnter")(self)
        end

        return
    end
end

local function SlotButtonHandleMax(self)
    if not (self.Spell) or not (self.Stack) then
        return false
    end

    if (self.Stack > self.MaxStack) then
        EnchantTemplate_Max(self)
    end
end

local function HandleCollectionSlot(self, enchantID)
    local RE = GetREData(enchantID)
    local spellID = RE.spellID
    local quality = RE.quality
    EnchantTemplate_Normalize(self)

    local _, _, icon = GetSpellInfo(spellID)

    if not icon then
        icon = UNKNOWN_ENCHANT_ICON
    end

    self.Spell = spellID
    self.Quality = quality
    self:Show()
    self:SlotButtonSetQuality(quality)
    SetPortraitToTexture(self.Icon, icon)
    SlotButtonHandleMax(self)
end

local function ClearData()
    ACTIVE_ITEM = nil
    ACTIVE_ENCHANT = nil
    ITEM_BAG = nil
    ITEM_SLOT = nil
    CAN_REFUND = false
end

local function SetExtractButtonEnabled(btn, enabled)
    if enabled then
        btn:Enable()
    else
        SetButtonPulse(btn, 0, 1)
        btn:Disable()
    end
end

local function DisenchantButtonTokenCheck(self)
    if not AT_MYSTIC_ENCHANT_ALTAR then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_NO_GOSSIP
        SetExtractButtonEnabled(self, false)
        return
    end

    if not GetItemCount(ReforgeExtract) then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_NO_EXTRACT
        SetExtractButtonEnabled(self, false)
        return
    end

    if GetItemCount(ReforgeExtract) <= 0 then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_NO_EXTRACT
        SetExtractButtonEnabled(self, false)
        return
    end

    if not ACTIVE_ITEM then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_NO_ITEM
        SetExtractButtonEnabled(self, false)
        return
    end

    if not ACTIVE_ENCHANT or ACTIVE_ENCHANT == 0 then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_NO_ENCHANT
        SetExtractButtonEnabled(self, false)
        return
    end

    local _, _, quality = GetItemInfo(ACTIVE_ITEM)
    local itemID = GetItemInfoFromHyperlink(ACTIVE_ITEM)
    -- We have an item but can't determine its quality for some reason? Just enable the button and let the server resolve
    if not quality then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_DEFAULT
        SetExtractButtonEnabled(self, true)
        return
    end

    if not EnchantableHeirlooms[itemID] and quality <= REFORGE_QUALITY_MIN then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_LOW_QUALITY
        SetExtractButtonEnabled(self, false)
        return
    end

    if not ExtractableHeirlooms[itemID] and quality > REFORGE_QUALITY_MAX then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_HIGH_QUALITY
        SetExtractButtonEnabled(self, false)
        return
    end

    EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_DEFAULT
    SetExtractButtonEnabled(self, true)
end

local function SetRollButtonEnabled(btn, enabled)
    if enabled then
        btn:Enable()
    else
        SetButtonPulse(btn, 0, 1)
        btn:Disable()
    end

    if btn:IsMouseOver() then
        btn:CallScript("OnEnter")
    end
end

local function RollButtonCheck(self)
    if not AT_MYSTIC_ENCHANT_ALTAR then
        REFORGE_TOOLTIP = REFORGE_TOOLTIP_NO_GOSSIP
        SetRollButtonEnabled(self, false)
        return
    end

    if not ACTIVE_ITEM then
        REFORGE_TOOLTIP = REFORGE_TOOLTIP_NO_ITEM
        SetRollButtonEnabled(self, false)
        return
    end

    local _, _, quality = GetItemInfo(ACTIVE_ITEM)

    if not quality then
        REFORGE_TOOLTIP = REFORGE_TOOLTIP_DEFAULT
        SetRollButtonEnabled(self, true)
        return
    end

    if not EnchantableHeirlooms[ACTIVE_ITEM] and quality <= REFORGE_QUALITY_MIN then
        REFORGE_TOOLTIP = REFORGE_TOOLTIP_LOW_QUALITY
        SetRollButtonEnabled(self, false)
        return
    end

    REFORGE_TOOLTIP = REFORGE_TOOLTIP_DEFAULT
    SetRollButtonEnabled(self, true)
end

local function EnableBreathing()
    GLOBAL_BREATHING_ENABLED = true

    for slot, btn in pairs(CollectionSlotMap) do
        if (btn:IsEnabled() == 1) then
            if (btn.breathing) then
                btn.AnimatedTex.AG:Stop()
                btn.AnimatedTex.AG:Play()
                btn.AnimatedTex:Show()
            end
        end
    end
    M.EnchantFrame.BreathTex.AG:Stop()
    M.EnchantFrame.BreathTex.AG:Play()
    M.EnchantFrame.BreathTex:Show()
end

local function DisableBreathing()
    GLOBAL_BREATHING_ENABLED = false

    for slot, btn in pairs(CollectionSlotMap) do
        btn.AnimatedTex:Hide()
    end

    M.EnchantFrame.BreathTex:Hide()
end

local function ReforgeItemCost(item)
    local _, _, _, ilvl = GetItemInfo(item)

    if not balanceToken or balanceToken <= 0 then
        return REFORGE_GOLD_COST, true
    else
        return REFORGE_RUNE_COST, false
    end
end

local function EnchantItemCost(item)
    local cost = nil

    if not M.CollectionsEnchant then
        return cost
    end


    local RE = GetREData(M.CollectionsEnchant)

    if not RE then
        return cost
    end

    if RE.quality <= 2 then
        if balanceOrbs < ENCHANT_GREEN_ORB_COST then
            return ENCHANT_GREEN_GOLD_COST, true
        else
            return ENCHANT_GREEN_ORB_COST, false
        end
    elseif RE.quality == 3 then
        if balanceOrbs < ENCHANT_BLUE_ORB_COST then
            return ENCHANT_BLUE_GOLD_COST, true
        else
            return ENCHANT_BLUE_ORB_COST, false
        end
    elseif RE.quality == 4 then
        if balanceOrbs < ENCHANT_PURPLE_ORB_COST then
            return ENCHANT_PURPLE_GOLD_COST, true
        else
            return ENCHANT_PURPLE_ORB_COST, false
        end
    elseif RE.quality >= 5 then
        if balanceOrbs < ENCHANT_LEGENDARY_ORB_COST then
            return ENCHANT_LEGENDARY_GOLD_COST, true
        else
            return ENCHANT_LEGENDARY_ORB_COST, false
        end
    end
end

local function ClearControlFrame(self)
    for slot, btn in pairs(CollectionSlotMap) do
        btn:SetChecked(false)
    end

    M.ControlFrame.TokenFrame:Hide()
    M.ControlFrame.MoneyFrame:Hide()
    M.EnchantFrame.Icon:SetTexture("Interface\\Icons\\spell_frost_stun")
    M.EnchantFrame.Icon:SetVertexColor(0.5, 0, 0.5, 0.5)
    M.EnchantFrame.EnchName:SetText("Drag an item here")
    M.EnchantFrame.ItemName:SetText("Use " .. MYSTIC_ENCHANTING_ALTAR)
    M.EnchantFrame.Enchant:Hide()
    ClearData()
    if self then
        CursorUpdate(self)
    end
    RollButtonCheck(M.ControlFrame.RollButton)
    DisenchantButtonTokenCheck(M.ControlFrame.ExtractButton)
    M.EnchantFrame.BG:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\LabelTop")

    if (M.Initializated) then
        EnableBreathing()
    end
end

local function SlotButton_OnClick(self)
    local link = GetInventoryItemLink("player", self.SlotID)
    local isModifiedClick = false

    if (IsModifiedClick("CHATLINK")) then
        if (link) then
            ChatEdit_InsertLink(link)
        end
        isModifiedClick = true
    end

    local itemBagSaved = ITEM_BAG
    local itemSlotSaved = ITEM_SLOT
    ClearControlFrame(self)

    if not (link) then
        return
    end
    if AT_MYSTIC_ENCHANT_ALTAR and (M.Initializated and self.SlotID) then
        if itemBagSaved and itemSlotSaved and (itemBagSaved == 255) and (itemSlotSaved == self.SlotID) and not (isModifiedClick) then
            return
        end
        ITEM_BAG_TEMP = 255
        ITEM_SLOT_TEMP = self.SlotID

        local enchantID = GetREInSlot(ITEM_BAG_TEMP, ITEM_SLOT_TEMP)
        local cost, useGold = ReforgeItemCost(link)
        M.PlaceItem(link, enchantID, { cost, useGold }, ITEM_BAG_TEMP, ITEM_SLOT_TEMP)
        if M.IsTryingToCast then
            M:PrepareCollectionReforge()
            M.IsTryingToCast:SetScript("OnUpdate", nil)
        end
    else
        if not (isModifiedClick) then
            StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "Use |cffFFFFFF" ..
                MYSTIC_ENCHANTING_ALTAR .. "|r to use this option."
            StaticPopup_Show("ASC_ERROR_TIMEOUT")
        end
    end
end

local function CollectionSlotButtonTemplate(parent)
    if not (parent.buttonInfo) then
        parent.buttonInfo = 1
    else
        parent.buttonInfo = parent.buttonInfo + 1
    end

    local btn = CreateFrame("CheckButton", nil, parent, nil)
    btn:SetSize(42, 42)
    btn:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

    btn:SetNormalTexture(Addon.AwTexPath .. "EnchOverhaul\\Slot2")
    btn:SetCheckedTexture(Addon.AwTexPath .. "EnchOverhaul\\Slot2Selected")
    btn:SetHighlightTexture(Addon.AwTexPath .. "EnchOverhaul\\slottemplateHighlight")
    btn:SetPushedTexture(Addon.AwTexPath .. "EnchOverhaul\\Slot2Pushed")
    btn:SetDisabledTexture(Addon.AwTexPath .. "EnchOverhaul\\Slot2")
    btn:GetDisabledTexture():SetDesaturated(true)

    btn.BG = btn:CreateTexture(nil, "BACKGROUND")
    btn.BG:SetSize(56, 56)
    btn.BG:SetPoint("CENTER", 0, -1)
    btn.BG:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\slottemplateBG")

    btn.Icon = btn:CreateTexture(nil, "BORDER")
    btn.Icon:SetSize(36, 36)
    btn.Icon:SetPoint("CENTER", 0, 0)
    btn.Icon:SetTexture("Interface\\Icons\\inv_misc_book_09")

    btn.Enchant = M:CollectionEnchantTemplate(btn)

    btn:SetScript("OnClick", SlotButton_OnClick)
    btn:SetScript("OnDisable", SlotButton_OnDisable)
    btn:SetScript("OnEnable", SlotButton_OnEnable)
    btn:SetScript("OnEnter", SlotButton_OnEnter)
    btn:SetScript("OnLeave", SlotButton_OnLeave)
    btn:SetScript("OnEvent", SlotButton_OnEvent)

    btn.AnimatedTex = btn:CreateTexture(nil, "OVERLAY")
    btn.AnimatedTex:SetAllPoints()
    btn.AnimatedTex:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\Slot2Selected")
    btn.AnimatedTex:SetAlpha(0)
    btn.AnimatedTex:SetBlendMode("ADD")
    btn.AnimatedTex:Hide()

    btn.AnimatedTex.AG = btn.AnimatedTex:CreateAnimationGroup()

    btn.AnimatedTex.AG.Alpha0 = btn.AnimatedTex.AG:CreateAnimation("Alpha")
    btn.AnimatedTex.AG.Alpha0:SetStartDelay(0)
    btn.AnimatedTex.AG.Alpha0:SetDuration(1)
    btn.AnimatedTex.AG.Alpha0:SetOrder(0)
    btn.AnimatedTex.AG.Alpha0:SetEndDelay(0)
    btn.AnimatedTex.AG.Alpha0:SetSmoothing("IN")
    btn.AnimatedTex.AG.Alpha0:SetChange(1)

    btn.AnimatedTex.AG.Alpha1 = btn.AnimatedTex.AG:CreateAnimation("Alpha")
    btn.AnimatedTex.AG.Alpha1:SetStartDelay(0)
    btn.AnimatedTex.AG.Alpha1:SetDuration(1)
    btn.AnimatedTex.AG.Alpha1:SetOrder(0)
    btn.AnimatedTex.AG.Alpha1:SetEndDelay(0)
    btn.AnimatedTex.AG.Alpha1:SetSmoothing("IN_OUT")
    btn.AnimatedTex.AG.Alpha1:SetChange(-1)

    btn.AnimatedTex.AG:SetScript("OnFinished", function()
        btn.AnimatedTex.AG:Play()
    end)

    btn.AnimatedTex.AG:Play()
    btn.breathing = false

    return btn
end
-------------------------------------------------------------------------------
--                            Collection Template                            --
-------------------------------------------------------------------------------

local function ReforgeCheck()
    local _, _, quality = GetItemInfo(ACTIVE_ITEM)
    local itemID = GetItemInfoFromHyperlink(ACTIVE_ITEM)
    if not EnchantableHeirlooms[itemID] and (quality < REFORGE_QUALITY_MIN or quality > REFORGE_QUALITY_MAX) then
        StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "Item must be uncommon quality or better"
        StaticPopup_Show("ASC_ERROR_TIMEOUT")
        return false
    elseif M.CollectionsEnchant and M.CollectionsEnchant == ACTIVE_ENCHANT then
        StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "You already have this enchant on your item."
        StaticPopup_Show("ASC_ERROR_TIMEOUT")
        return false
    elseif M.CollectionsEnchant and M.CollectionsEnchant ~= 0 and ACTIVE_ITEM and M.Initializated then
        return true
    else
        return false
    end
end

local function RefundEnchant()
    if (ACTIVE_ITEM and ITEM_BAG and ITEM_SLOT and M.CollectionsEnchant) then
        PlaySound("igMainMenuOptionCheckBoxOn")
    end
end

local function RefundFullCheck()
    if CAN_REFUND then
        local RE = GetREData(ACTIVE_ENCHANT)
        local activeQuality = RE.quality
        local currQuality = GetREData(M.CollectionsEnchant).quality

        if (activeQuality and currQuality) and (currQuality <= activeQuality) then
            M.ConfirmDisenchant.text:SetText(
                "Collection Reforge Cost: |cff00FF00FREE|r\nReforge Success Chance: |cffFFFFFF100%|r\n\nAre you sure you want to continue?\n")
        end

        M.ConfirmDisenchant.Mode = "REFUND"
    end
end

local function UpdateCollectionReforgeDialogue()
    if not ACTIVE_ITEM then
        return false
    end

    local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(ACTIVE_ITEM)
    local cost, useGold = EnchantItemCost(ACTIVE_ITEM)

    if useGold then
        local gold, silver, copper = GetGoldForMoney(cost)
        M.ConfirmDisenchant.currencyText:SetText("|cffFFFFFF" ..
            gold ..
            " |TInterface\\MONEYFRAME\\UI-GoldIcon.blp:16:16:0:-1|t " ..
            silver ..
            " |TInterface\\MONEYFRAME\\UI-SilverIcon.blp:16:16:0:-1|t " ..
            copper .. " |TInterface\\MONEYFRAME\\UI-CopperIcon.blp:16:16:0:-1|t|r")
    else
        M.ConfirmDisenchant.currencyText:SetText("|cffFFFFFF" ..
            cost .. " |TInterface\\Icons\\inv_custom_CollectionRCurrency.blp:16:16:0:-1|t|r")
    end

    M.ConfirmDisenchant.text:SetText("Collection Reforge Cost:")
    M.ConfirmDisenchant.confirmText:SetText("Are you sure you want to continue?")
    M.ConfirmDisenchant.Alert:SetTexture(texture)

    M.ConfirmDisenchant.Alert:SetVertexColor(1, 1, 1, 1)

    RefundFullCheck()
end

function M:PrepareCollectionReforge()
    if not (ReforgeCheck()) then
        return false
    end

    M.ConfirmDisenchant.Mode = "COLLECTIONREFORGE"

    HandleCollectionSlot(M.ConfirmDisenchant.Enchant, M.CollectionsEnchant)
    UpdateCollectionReforgeDialogue()

    M.ConfirmDisenchant:Show()
end

local function ItemTemplate_OnDisable(self)
    self.TextNormal:SetFontObject(GameFontDisable)
end

local function ItemTemplate_OnEnable(self)
    self.TextNormal:SetFontObject(GameFontNormal)
end

local function ItemTemplate_OnEnter(self)
    if self.Spell == nil then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -13, -50)
    GameTooltip:SetHyperlink(self.Spell)
    GameTooltip:Show()
end

local function ItemTemplate_OnLeave()
    GameTooltip:Hide()
end

local function ItemTemplate_fake_OnClick(self)
    if not self.Spell then return end
    if (IsModifiedClick("CHATLINK")) then
        if IsWorldforgedRE(self.Enchant) and not IsReforgeEnchantmentKnown(self.Enchant) then
            return
        end
        ChatEdit_InsertLink(self.Spell)
        return
    end

    if (GLOBAL_BC_CHOOSE_ENCHANT) then
        HandleEnchantAddToBuildCreator(self.Spell)
        return
    end
end

local function ItemTemplate_OnUpdate(self)
    if IsMouseButtonDown() and not (GameTooltip and GameTooltip:GetItem()) or not AT_MYSTIC_ENCHANT_ALTAR then
        SetCursor(nil)
        self:SetScript("OnUpdate", nil)
        M.IsTryingToCast = false
    end
    if AT_MYSTIC_ENCHANT_ALTAR then
        if GameTooltip and GameTooltip:GetItem() then
            SetCursor("CAST_CURSOR")
        else
            SetCursor("CAST_ERROR_CURSOR")
        end
    end
end

local function ItemTemplate_OnClick(self)
    if not self.Spell then return end
    if M.IsTryingToCast then return end

    if (IsModifiedClick("CHATLINK")) then
        if IsWorldforgedRE(self.Enchant) and not IsReforgeEnchantmentKnown(self.Enchant) then
            return
        end
        ChatEdit_InsertLink(self.Spell)
        return
    end

    PlaySound("GAMEABILITYACTIVATE")

    if (GLOBAL_BC_CHOOSE_ENCHANT) then
        HandleEnchantAddToBuildCreator(self.Spell)
        return
    end
    if AT_MYSTIC_ENCHANT_ALTAR then
        if (self.Enchant) and IsReforgeEnchantmentKnown(self.Enchant) then
            M.CollectionsEnchant = self.Enchant

            if (ITEM_BAG and ITEM_SLOT) then
                M:PrepareCollectionReforge()
            else
                M.IsTryingToCast = self
                self:SetScript("OnUpdate", ItemTemplate_OnUpdate)
            end
        else
            M.CollectionsEnchant = 0
        end
    end
end

local function CollectionItemTemplate(parent)
    if not (parent.itemCount) then
        parent.itemCount = 1
    else
        parent.itemCount = parent.itemCount + 1
    end

    local index = parent.itemCount
    local btn = CreateFrame("FRAME", "CollectionItemFrame" .. index, parent, nil)
    btn:SetSize(128, 64)

    btn.BackgroundTexture = btn:CreateTexture("CollectionItemFrame" .. index .. ".BackgroundTexture", "BORDER")
    btn.BackgroundTexture:SetSize(35, 35)
    btn.BackgroundTexture:SetTexture("Interface\\Icons\\INV_Chest_Samurai")
    btn.BackgroundTexture:SetPoint("LEFT", btn, 0, 0)

    btn.BG = btn:CreateTexture("CollectionItemFrame" .. index .. ".BG", "BACKGROUND")
    btn.BG:SetSize(246, 78)
    btn.BG:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\EBG")
    btn.BG:SetPoint("CENTER", 32, -10.5)

    btn.Button = CreateFrame("Button", "CollectionItemFrame" .. index .. ".Button", btn, nil)
    btn.Button:SetSize(170, 85)
    btn.Button:SetPoint("CENTER", 0, 0)
    btn.Button:EnableMouse(true)
    --btn.Button:SetNormalTexture(Addon.AwTexPath.."Collections\\CollectionsItemNormal")
    --btn.Button:SetDisabledTexture(Addon.AwTexPath.."Collections\\CollectionsItemDisabled")
    --btn.Button:SetPushedTexture(Addon.AwTexPath.."Collections\\CollectionsItemPushed")
    --btn.Button:SetHighlightTexture(Addon.AwTexPath.."Collections\\CollectionsItemNormal")
    btn.Button:Disable()
    --btn.Button:GetDisabledTexture():SetVertexColor(0.6,0.6,0.6,1)
    btn.IconBorder = btn:CreateTexture("CollectionItemFrame" .. index .. ".IconBorder", "ARTWORK")
    btn.IconBorder:SetSize(48, 48)
    btn.IconBorder:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\BorderNewGreen")
    btn.IconBorder:SetPoint("LEFT", btn, -7, 0)

    btn.IconHighlight = btn:CreateTexture("CollectionItemFrame" .. index .. ".IconHighlight", "OVERLAY")
    btn.IconHighlight:SetSize(64, 64)
    btn.IconHighlight:SetTexture(Addon.AwTexPath .. "enchant\\EnchantBorder_highlight")
    btn.IconHighlight:SetPoint("CENTER", btn.IconBorder, 0, 0)
    btn.IconHighlight:SetBlendMode("ADD")
    btn.IconHighlight:Hide()
    --btn:SetNormalTexture(Addon.AwTexPath.."enchant\\EnchantBorder")
    --btn:SetHighlightTexture(Addon.AwTexPath.."enchant\\EnchantBorder_highlight")

    btn.Button_fake = CreateFrame("Button", "CollectionItemFrame" .. index .. ".Button_fake", btn.Button, nil)
    btn.Button_fake:SetSize(170, 85)
    btn.Button_fake:SetPoint("CENTER", 0, 0)
    btn.Button_fake:EnableMouse(true)

    btn.Button.TextNormal = btn.Button:CreateFontString("CollectionItemFrame" .. index .. ".Button.TextNormal")
    btn.Button.TextNormal:SetSize(100, 45)
    btn.Button.TextNormal:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    btn.Button.TextNormal:SetFontObject(GameFontNormal)
    btn.Button.TextNormal:SetPoint("CENTER", 26, 1)
    btn.Button.TextNormal:SetShadowOffset(0, -1)
    btn.Button.TextNormal:SetText("Enchant Effect Name")
    btn.Button.TextNormal:SetJustifyH("LEFT")

    btn.Button_fake:SetScript("OnEnter", ItemTemplate_OnEnter)
    btn.Button_fake:SetScript("OnClick", ItemTemplate_fake_OnClick)
    btn.Button_fake:SetScript("OnLeave", ItemTemplate_OnLeave)
    btn.Button:SetScript("OnDisable", ItemTemplate_OnDisable)
    btn.Button:SetScript("OnEnable", ItemTemplate_OnEnable)
    btn.Button:SetScript("OnEnter", function(self)
        self:GetParent().IconHighlight:Show()
        self.TextNormal:SetTextColor(1, 1, 1, 1)
        ItemTemplate_OnEnter(self)
    end)
    btn.Button:SetScript("OnLeave", function(self)
        self:GetParent().IconHighlight:Hide()
        self.TextNormal:SetTextColor(unpack(self.textColor))
        ItemTemplate_OnLeave(self)
    end)
    btn.Button:SetScript("OnClick", ItemTemplate_OnClick)

    btn.Button:SetScript("OnMouseUp", function(self)
        btn.Button.TextNormal:SetPoint("CENTER", 26, 1)
    end)

    btn.Button:SetScript("OnMouseDown", function(self)
        btn.Button.TextNormal:SetPoint("CENTER", 28, -1)
    end)

    btn:Hide()
    return btn
end
-------------------------------------------------------------------------------
--                              Base Scripts                                 --
-------------------------------------------------------------------------------
local function UnlockRefund(canRefund)
    if canRefund then
        CAN_REFUND = true
        --M.EnchantFrame.Enchant.Refund:Show()
    else
        CAN_REFUND = false
        M.EnchantFrame.Enchant.Refund:Hide()
    end
end

local function GetDisabledColoredText(color)
    local r, g, b = unpack(color)
    r = max(r * 0.75, 0)
    g = max(g * 0.75, 0)
    b = max(b * 0.75, 0)

    return { r, g, b }
end

local function UpdateRerollCost(cost)
    if not (ACTIVE_ITEM) or not (M.Initializated) then
        return false
    end

    if cost[2] then
        MoneyFrame_Update(M.ControlFrame.MoneyFrame, cost[1])
        M.ControlFrame.TokenFrame:Hide()
        M.ControlFrame.MoneyFrame:Show()
    else
        M.ControlFrame.MoneyFrame:Hide()
        M.ControlFrame.TokenFrame:Show()
        M.ControlFrame.TokenFrame.TokenText:SetText("Cost: |cffFFFFFF" .. cost[1] .. "|r")
    end
end

local function GetRequiredRollsForLevel(level)
    if level == 0 then
        return 1
    end

    if level >= 250 and not C_Realm:IsRealmMask(Enum.RealmMask.Area52) then
        return 557250 + (level - 250) * 4097
    end

    return floor(354 * level + 7.5 * level * level)
end

local function UpdateProgress(level, progress)
    local lastRequired = 0
    local maxRequired = 1

    if not tonumber(level) or not tonumber(progress) then
        return
    end

    if level > 0 then
        lastRequired = GetRequiredRollsForLevel(level - 1)
        maxRequired = GetRequiredRollsForLevel(level)
    end

    --print("Progress Update: Last Required:", lastRequired, "Max Required:",  maxRequired, "Current:", progress)
    M.ProgressBar:SetMinMaxValues(lastRequired, maxRequired)
    M.ProgressBar:SetValue(progress)
    M.LevelFrame.TitleText:SetText(level)
    M.ProgressBar.Text:SetText(string.format("Level %i", level) ..
        " " .. string.format("(%s/%s)", ShortenNumber(progress), ShortenNumber(maxRequired)))

    if M.CDB then
        M.CDB.EnchantProgress = progress or 0
        M.CDB.EnchantLevel = level or 0
        M.CDB.LastRequired = lastRequired or 0
        M.CDB.NextRequired = maxRequired or 1
    end
end

local function UpdateMysticRuneBalance()
    local OldBalanceExtract = balanceExtract
    balanceToken = GetItemCount(ReforgeToken)
    balanceExtract = GetItemCount(ReforgeExtract)
    balanceOrbs = GetItemCount(ReforgeOrb)

    if not (balanceToken) then
        balanceToken = 0
    end

    if not (balanceExtract) then
        balanceExtract = 0
    end

    if not (balanceOrbs) then
        balanceOrbs = 0
    end

    M.ControlFrame.Currency.ExtractText:SetText(string.format("Mystic Extract: |cffFFFFFF%i|r", balanceExtract))
    M.ControlFrame.Currency.TokenText:SetText(string.format("Mystic Rune: |cffFFFFFF%i|r", balanceToken))
    M.CollectionsList.CurrencyOrbs.OrbText:SetText(balanceOrbs)
end

local function PlaceItem(self, flag)
    local infoType, _, itemLink = GetCursorInfo()
    if AT_MYSTIC_ENCHANT_ALTAR and ((infoType == "item") or flag) and ITEM_BAG_TEMP and ITEM_SLOT_TEMP and M.Initializated then
        ClearControlFrame()

        local enchantID = GetREInSlot(ITEM_BAG_TEMP, ITEM_SLOT_TEMP)
        local cost, useGold = ReforgeItemCost(itemLink)
        M.PlaceItem(itemLink, enchantID, { cost, useGold }, ITEM_BAG_TEMP, ITEM_SLOT_TEMP)
        return true
    elseif not (ACTIVE_ITEM) then
        StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "|cffFFFFFFDrag|r an item and use |cffFFFFFF" ..
            MYSTIC_ENCHANTING_ALTAR .. "|r to use this option."
        StaticPopup_Show("ASC_ERROR_TIMEOUT")
        ClearControlFrame()
        return false
    end

    ClearControlFrame()
    return false
end

local function CollectionsOnHide()
    AT_MYSTIC_ENCHANT_ALTAR = false
    GLOBAL_BC_CHOOSE_ENCHANT = false -- to avoid issues
    M.Initializated = false
    if M.IsTryingToCast then
        M.IsTryingToCast:SetScript("OnUpdate", nil)
    end
    M.IsTryingToCast = false
    DisableBreathing()
    M.ConfirmDisenchant:Hide()
    ClearControlFrame()
end

local function GetLastLockedItem(bag, slot)
    ITEM_BAG_TEMP = bag
    ITEM_SLOT_TEMP = slot
    if (bag and (slot == nil)) then
        ITEM_BAG_TEMP = 255
    end
end

local function PrepareReforge(self)
    if (ACTIVE_ITEM and ITEM_BAG and ITEM_SLOT) and (self:IsEnabled() == 1) then
        if balanceToken == 0 then
            local cost = ReforgeItemCost(ACTIVE_ITEM)
            if GetMoney() < cost then
                SendSystemMessage("You don't have enough gold to reforge that item")
                return
            end

            if not M.AllowReforgeGoldCost and cost > 0 then
                local dialog = StaticPopupDialogs["ASC_REFORGE_COST_GOLD"]
                dialog.text = "You are about to spend "

                local gold, silver, copper = GetGoldForMoney(cost)

                dialog.text = dialog.text .. gold .. " |TInterface\\MONEYFRAME\\UI-GoldIcon.blp:14:14|t "
                dialog.text = dialog.text .. silver .. " |TInterface\\MONEYFRAME\\UI-SilverIcon.blp:14:14|t "
                dialog.text = dialog.text .. copper .. " |TInterface\\MONEYFRAME\\UI-CopperIcon.blp:14:14|t "
                dialog.text = dialog.text ..
                    "on reforging this item.\nYou will not see this dialog again.\nDo you wish to continue?"
                dialog.OnAccept = function()
                    dialog.acceptFunc()
                    PrepareReforge(self)
                end
                StaticPopup_Show("ASC_REFORGE_COST_GOLD")
                return
            end
        end
        PlaySound("igMainMenuOptionCheckBoxOn")

        -- double check we haven't swapped the items around real quick
        if ITEM_BAG == 255 then
            local itemLink = GetInventoryItemLink("player", ITEM_SLOT)
            if ACTIVE_ITEM ~= itemLink then
                return
            end
        else
            local _, _, _, _, _, _, itemLink = GetContainerItemInfo(ITEM_BAG, ITEM_SLOT)
            if ACTIVE_ITEM ~= itemLink then
                return
            end
        end
        --[[if ITEM_BAG == 255 then
            print("[Request] Inventory Reforge Slot:", ITEM_SLOT, GetInventoryItemLink("player", ITEM_SLOT))
        else
            print("[Request] Bag Reforge Bag:", ITEM_BAG, "Slot:", ITEM_SLOT, GetContainerItemLink(ITEM_BAG, ITEM_SLOT))
        end]]
        RequestSlotReforgeEnchantment(ITEM_BAG, ITEM_SLOT)
    end
end

local function CollectionReforge()
    if (ACTIVE_ITEM and ITEM_BAG and ITEM_SLOT and M.CollectionsEnchant) then
        -- Double check the item is valid

        local RE = GetREData(M.CollectionsEnchant)

        if not RE then
            StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "Cannot enchant |cff00CCFF[" .. name .. "]|r\nInvalid enchant"
            StaticPopup_Show("ASC_ERROR_TIMEOUT")
            return
        end

        local item, itemID

        if ITEM_BAG == 255 then
            item = GetInventoryItemLink("player", ITEM_SLOT)
            itemID = GetInventoryItemID("player", ITEM_SLOT)
        else
            item = GetContainerItemLink(ITEM_BAG, ITEM_SLOT)
            itemID = GetContainerItemID(ITEM_BAG, ITEM_SLOT)
        end
        local name, _, quality, _, _, _, _, _, itemType = GetItemInfo(item)

        if not VALID_INVTYPE[itemType] then
            StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "Cannot enchant |cff00CCFF[" ..
                name .. "]|r\nInvalid Item Type"
            StaticPopup_Show("ASC_ERROR_TIMEOUT")
            return
        end

        if VALID_INVTYPE[itemType] == RE.class then
            StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "Cannot enchant |cff00CCFF[" ..
                name .. "]|r\nEnchant cannot be applied to weapons"
            StaticPopup_Show("ASC_ERROR_TIMEOUT")
            return
        end

        if not EnchantableHeirlooms[itemID] and (quality < REFORGE_QUALITY_MIN or quality > REFORGE_QUALITY_MAX) then
            StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text =
            "Item must be\n|cFF1EFF0CUncommon|r, |cFF0070FFRare|r, |cFFA335EEEpic|r, or |cFFFF8000Legendary|r\nto enchant it"
            StaticPopup_Show("ASC_ERROR_TIMEOUT")
            return
        end

        if not IsReforgeEnchantmentKnown(M.CollectionsEnchant) then
            StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "You don't know that enchant"
            StaticPopup_Show("ASC_ERROR_TIMEOUT")
            return
        end

        PlaySound(13829)
        RequestSlotReforgeEnchantment(ITEM_BAG, ITEM_SLOT, M.CollectionsEnchant)
    end
end

local function DisenchantItem()
    if GetItemCount(ReforgeExtract) and (GetItemCount(ReforgeExtract) > 0) then
        if (ACTIVE_ITEM and ITEM_BAG and ITEM_SLOT and ACTIVE_ENCHANT) then
            if IsReforgeEnchantmentKnown(ACTIVE_ENCHANT) then
                SendSystemMessage("You already know this enchant")
                return
            end
            PlaySound("igMainMenuOptionCheckBoxOn")

            RequestSlotReforgeExtraction(ITEM_BAG, ITEM_SLOT)
            ClearControlFrame()
        end
    else
        SendSystemMessage("You don't have enough Mystic Extract to disenchant that item")
    end
end

local function PrepareDisenchant()
    if not (ACTIVE_ITEM or ITEM_BAG or ITEM_SLOT or not ACTIVE_ENCHANT) then
        return false
    end

    local Type = GetCursorInfo()

    if Type and (Type == "item") then
        return false
    end

    local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(ACTIVE_ITEM)

    M.ConfirmDisenchant.Mode = "DISENCHANT"
    M.ConfirmDisenchant:Show()
    M.ConfirmDisenchant.text:SetText(
        "Are you sure you want to remove\nMystic Enchant from following item:\n(This will remove the enchant from the item)\n|CffFF0000(This will DESTROY the Item)|r\n" ..
        link)
    M.ConfirmDisenchant.currencyText:SetText("")
    M.ConfirmDisenchant.confirmText:SetText("")
    M.ConfirmDisenchant.Alert:SetTexture(texture)
    M.ConfirmDisenchant.Alert:SetVertexColor(1, 0, 0, 1)
    HandleCollectionSlot(M.ConfirmDisenchant.Enchant, ACTIVE_ENCHANT)
end

local function EnchantShowDisenchantHint(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    for _, line in ipairs(EXTRACT_TOOLTIP) do
        GameTooltip:AddLine(line, nil, nil, nil, true)
    end
    GameTooltip:Show()
end

local function EnchantShowRollHint(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    for _, line in ipairs(REFORGE_TOOLTIP) do
        GameTooltip:AddLine(line, 1, 1, 1, true)
    end

    if ACTIVE_ENCHANT then
        local RE = GetMysticEnchantInfo(ACTIVE_ENCHANT)
        if RE then
            GameTooltip:AddLine(
                "Reforges " ..
                ITEM_QUALITY_COLORS[RE.quality]:WrapText(GetSpellInfo(RE.spellID)) ..
                " into a new random mystic enchant.", 1,
                0.82, 0, true)
        end
    end
    GameTooltip:Show()
end

local function EnchantShowLink(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if (ACTIVE_ITEM) then
        GameTooltip:SetHyperlink(ACTIVE_ITEM)
    else
        GameTooltip:SetText("Drag an item here to reforge it\nor to extract Mystic Enchant.");
    end
    GameTooltip:Show()
end

local function UpdateListButtons(pagenumber)
    for i = 1, 15 do
        _G["CollectionItemFrame" .. i]:Hide()
    end

    local listtodisplay = {}

    local StartListValues = pagenumber * M.MaxEcnhantsPerPage - (M.MaxEcnhantsPerPage - 1)
    local EndListValues = pagenumber * M.MaxEcnhantsPerPage

    if (#M.CurrentList < EndListValues) then
        EndListValues = #M.CurrentList
    end

    for i = StartListValues, EndListValues do
        table.insert(listtodisplay, M.CurrentList[i])
    end

    local button_progress = 1

    while (button_progress <= #listtodisplay) do
        local RE = GetREData(listtodisplay[button_progress].enchantID)
        local EnchantEntry = RE.enchantID
        local spellID = RE.spellID
        local EnchantKnown = IsReforgeEnchantmentKnown(RE.enchantID)
        local spellName, _, spellIcon = GetSpellInfo(spellID)
        local quality = RE.quality
        local enchantColor = M.EnchantQualitySettings[RE.quality][1]

        if not (spellName) then
            SendSystemMessage("|cffFFFF00Please, update your patch. Client can't load spell " ..
                spellID .. " for using in enchant collection|r")
            return false
        end

        SetPortraitToTexture(_G["CollectionItemFrame" .. button_progress .. ".BackgroundTexture"], spellIcon)

        if (quality) then
            if EnchantKnown then
                _G["CollectionItemFrame" .. button_progress .. ".Button"].textColor = M.EnchantQualitySettings[quality]
                    [4]
            else
                _G["CollectionItemFrame" .. button_progress .. ".Button"].textColor = GetDisabledColoredText(M
                    .EnchantQualitySettings[quality][4])
            end
        else
            _G["CollectionItemFrame" .. button_progress .. ".Button"].textColor = { 1, 1, 1 }
        end

        if (EnchantKnown) then
            _G["CollectionItemFrame" .. button_progress .. ".Button"]:Enable()
            _G["CollectionItemFrame" .. button_progress .. ".Button_fake"]:Hide()
            _G["CollectionItemFrame" .. button_progress .. ".Button.TextNormal"]:SetFontObject(GameFontNormal)
            _G["CollectionItemFrame" .. button_progress .. ".Button.TextNormal"]:SetTextColor(unpack(_G
                ["CollectionItemFrame" .. button_progress .. ".Button"].textColor))
            _G["CollectionItemFrame" .. button_progress .. ".BackgroundTexture"]:SetVertexColor(1, 1, 1, 1)
            _G["CollectionItemFrame" .. button_progress .. ".Button"].Enchant = EnchantEntry
            _G["CollectionItemFrame" .. button_progress .. ".IconBorder"]:SetVertexColor(1, 1, 1, 1)
            --_G["CollectionItemFrame"..button_progress..".Button"]:SetNormalTexture(Addon.AwTexPath.."Collections\\CollectionsItemNormal")
        else
            _G["CollectionItemFrame" .. button_progress .. ".Button_fake"]:Show()
            _G["CollectionItemFrame" .. button_progress .. ".Button"]:Disable()
            _G["CollectionItemFrame" .. button_progress .. ".Button.TextNormal"]:SetFontObject(GameFontDisable)
            _G["CollectionItemFrame" .. button_progress .. ".Button.TextNormal"]:SetTextColor(unpack(_G
                ["CollectionItemFrame" .. button_progress .. ".Button"].textColor))
            _G["CollectionItemFrame" .. button_progress .. ".IconBorder"]:SetVertexColor(0.4, 0.4, 0.4, 1)
            _G["CollectionItemFrame" .. button_progress .. ".BackgroundTexture"]:SetVertexColor(0.4, 0.4, 0.4, 0.8)
        end
        _G["CollectionItemFrame" .. button_progress .. ".Button"].Spell = "|cff71d5ff|Hspell:" ..
            spellID .. "|h[" .. spellName .. "]|h|r"
        _G["CollectionItemFrame" .. button_progress .. ".Button_fake"].Spell = "|cff71d5ff|Hspell:" ..
            spellID .. "|h[" .. spellName .. "]|h|r"
        _G["CollectionItemFrame" .. button_progress .. ".Button"].Enchant = EnchantEntry
        _G["CollectionItemFrame" .. button_progress .. ".Button_fake"].Enchant = EnchantEntry
        _G["CollectionItemFrame" .. button_progress .. ".Button.TextNormal"]:SetText(spellName)
        -- _G["CollectionItemFrame" .. button_progress .. ".IconBorder"]:SetTexture(M.PaperDollEnchantQualitySettings
        --     [tonumber(quality)])
        _G["CollectionItemFrame" .. button_progress]:Show()
        button_progress = button_progress + 1
    end
end

local function UpdatePageInfo(pagenum)
    M.CollectionsList.PageText:SetText(format("Page: %s/%s", pagenum, M.PageCount))
end

local function UpdateListInfo(list, pagenumber)
    M.CurrentList = {}
    if not (pagenumber) then
        pagenumber = 1
    end

    for _, RE in pairs(list) do
        if RE.enchantID ~= 0 then
            tinsert(M.CurrentList, RE)
        end
    end

    table.sort(M.CurrentList, function(low, high)
        return low.quality > high.quality
    end)

    M.PageCount = math.ceil(#M.CurrentList / M.MaxEcnhantsPerPage)

    if (M.PageCount < 1) then
        M.PageCount = 1
    end

    M.CurrentPage = pagenumber
    UpdatePageInfo(M.CurrentPage)

    if (M.PageCount <= 1) then
        M.CollectionsList.NextButton:Disable()
    else
        M.CollectionsList.NextButton:Enable()
    end

    if (pagenumber == 1) then
        M.CollectionsList.PrevButton:Disable()
    end

    UpdateListButtons(pagenumber)
end

local function CollectionListNextPage(self)
    PlaySound("igMainMenuContinue")
    M.CurrentPage = M.CurrentPage + 1

    if (M.CurrentPage == M.PageCount) then
        self:Disable()
    end

    if (M.CollectionsList.PrevButton:IsEnabled() == 0) then
        M.CollectionsList.PrevButton:Enable()
    end

    UpdatePageInfo(M.CurrentPage)
    UpdateListButtons(M.CurrentPage)
end

local function CollectionListPrevPage(self)
    PlaySound("igMainMenuContinue")
    M.CurrentPage = M.CurrentPage - 1

    if (M.CurrentPage == 1) then
        self:Disable()
    end

    if (M.CollectionsList.NextButton:IsEnabled() == 0) then
        M.CollectionsList.NextButton:Enable()
    end

    UpdatePageInfo(M.CurrentPage)
    UpdateListButtons(M.CurrentPage)
end

local function BuildClassList(class)
    local list = {}

    for _, v in pairs(MYSTIC_ENCHANTS) do
        if (v.class == class) then
            table.insert(list, v)
        end
    end

    UpdateListInfo(list)
end

local function BuildListByWorldforged()
    local list = {}

    for _, v in pairs(MYSTIC_ENCHANTS) do
        if IsWorldforgedRE(v) then
            table.insert(list, v)
        end
    end

    UpdateListInfo(list)
end

local function BuildKnownList(known)
    M.KnownEnchantCount = 0
    local list = {}

    for i, v in pairs(MYSTIC_ENCHANTS) do
        if IsReforgeEnchantmentKnown(v.enchantID) then
            M.KnownEnchantCount = M.KnownEnchantCount + 1
        end
        if IsReforgeEnchantmentKnown(v.enchantID) and known then
            table.insert(list, v)
        elseif not known and not IsReforgeEnchantmentKnown(v.enchantID) then
            table.insert(list, v)
        end
    end
    UpdateListInfo(list)
end

local function BuildListByQuality(quality)
    local list = {}

    for i, v in pairs(MYSTIC_ENCHANTS) do
        if (v.quality == quality) then
            table.insert(list, v)
        end
    end

    UpdateListInfo(list)
end

local function BuildListByRelevancy()
    local list = {}

    local added = {}

    for sid in pairs(CAO_Known) do
        local topEnchants = SpellSuggestions:GetTopEnchants(sid, 20)

        for _, id in ipairs(topEnchants) do
            local data = GetREData(id)
            if data and data.enchantID ~= 0 and not added[data.enchantID] then
                added[data.enchantID] = true
                tinsert(list, data)
            end
        end
    end

    UpdateListInfo(list)
end

local function BuildListByMySpells()
    local list = {}

    local added = {}
    local search = {}

    for sid in pairs(CAO_Known) do
        local name = GetSpellInfo(sid)
        if name then
            tinsert(search, name:lower())
        end
        local topEnchants = SpellSuggestions:GetTopEnchants(sid, 20)

        for _, id in ipairs(topEnchants) do
            local data = GetREData(id)
            if data and data.enchantID ~= 0 and not added[data.enchantID] then
                added[data.enchantID] = true
                tinsert(list, data)
            end
        end
    end

    for _, v in pairs(MYSTIC_ENCHANTS) do
        if v.enchantID ~= 0 and not added[v.enchantID] then
            local reName = GetSpellInfo(v.spellID)
            reName = reName and reName:lower() or ""
            local description, embeddedSpells = C_Spell:GetSpellDescription(v.spellID)
            description = description:lower()
            for _, name in ipairs(search) do
                if reName:find(name, 1, true) or description:find(name, 1, true) then
                    tinsert(list, v)
                    break
                end
                if embeddedSpells then
                    local didInsert = false
                    for _, desc in ipairs(embeddedSpells) do
                        if desc[1]:lower():find(name, 1, true) then
                            tinsert(list, v)
                            didInsert = true
                            break
                        end
                    end
                    if didInsert then
                        break
                    end
                end
            end
        end
    end

    UpdateListInfo(list)
end

function ClearSearchEscape(self)
    local text = self:GetText()

    if not (text) or (text == "") then
        self:SetText(SEARCH)
    end

    self:ClearFocus(self)
end

local function SearchForEnchant()
    local searchBox = M.SearchBox
    SearchBoxTemplate_OnTextChanged(searchBox)
    local searchList = MYSTIC_ENCHANTS

    if SEARCH_INSIDE_CATEGORY_ID[M.EnchantTypeList.SelectedId] then
        if M.CurrentList then
            M.EnchantTypeList.List[M.EnchantTypeList.SelectedId].func()
            searchList = M.CurrentList
        else
            UIDropDownMenu_SetSelectedID(M.EnchantTypeList, 1)
            M.EnchantTypeList.SelectedId = 1
            UIDropDownMenu_SetText(M.EnchantTypeList, M.EnchantTypeList.List[1].text)
        end
    else
        UIDropDownMenu_SetSelectedID(M.EnchantTypeList, 1)
        M.EnchantTypeList.SelectedId = 1
        UIDropDownMenu_SetText(M.EnchantTypeList, M.EnchantTypeList.List[1].text)
    end

    local results
    local text = searchBox:GetText()

    if text and text ~= "" then
        text = text:lower()
        results = {}

        for _, RE in pairs(searchList) do
            local sid = RE.spellID
            if sid and sid > 0 then
                local name = GetSpellInfo(RE.spellID)
                if name then
                    local description, embeddedSpells = C_Spell:GetSpellDescription(sid)

                    name = name and name:lower()
                    description = description:lower()

                    local didInsert = false
                    if name:find(text, 1, true) or description:find(text, 1, true) then
                        table.insert(results, RE)
                        didInsert = true
                    end

                    if not didInsert and embeddedSpells then
                        for _, line in ipairs(embeddedSpells) do
                            if line[1]:lower():find(text, 1, true) then
                                tinsert(results, RE)
                                didInsert = true
                                break
                            end
                        end
                    end

                    if not didInsert and (text == "dev" or text == "development" or text == "test") and RE.developmentRealmsOnly then
                        table.insert(results, RE)
                    end
                else
                    local versionDate, versionTime = GetClientVersion()
                    C_Logger.Error("Mystic Enchant Data Contains Missing spellID: [" ..
                        RE.spellID .. "] DBC Version: " .. versionDate .. " @ " .. versionTime)
                end
            end
        end
    else
        if M.EnchantTypeList.List[M.EnchantTypeList.SelectedId] then
            M.EnchantTypeList.List[M.EnchantTypeList.SelectedId].func()
            return false
        end
        results = searchList
    end

    UpdateListInfo(results)
end

local function ReceiveNewEnchant(enchantID)
    if not enchantID or enchantID == 0 then
        return
    end
    local RE = GetREData(enchantID)
    local spellID = RE.spellID

    local spellName, _, spellIcon = GetSpellInfo(spellID)

    if not spellName then
        return
    end

    local enchantColor = M.EnchantQualitySettings[RE.quality][1]

    M.CollectionsList.NewEnchantInCollection.Enchant = "|Hspell:" .. spellID .. "|h[" .. spellName .. "]|h"
    M.CollectionsList.NewEnchantInCollection.BackgroundTexture:SetTexture(spellIcon)
    M.CollectionsList.NewEnchantInCollection.TextNormal:SetText(enchantColor ..
        M.CollectionsList.NewEnchantInCollection.Enchant .. "|r")
    M.CollectionsList.NewEnchantInCollection.TextAdd:SetText("|cffFFFFFFYou have successfuly unlocked " ..
        enchantColor .. M.CollectionsList.NewEnchantInCollection.Enchant .. "|r enchant")

    M.CollectionsList.NewEnchantInCollection.AnimationGroup:Stop()
    M.CollectionsList.NewEnchantInCollection.AnimationGroup:Play()
    PlaySound("Glyph_MajorDestroy")
    BuildKnownList(true)
end

function M:GetEnchantOrbCost(enchantId)
    if not enchantId or enchantId == 0 then
        return 0
    end

    local RE = GetREData(enchantId)
    if RE.enchantID == 0 then
        return 0
    end

    if RE.quality <= 2 then
        return ENCHANT_GREEN_ORB_COST
    elseif RE.quality == 3 then
        return ENCHANT_BLUE_ORB_COST
    elseif RE.quality == 4 then
        return ENCHANT_PURPLE_ORB_COST
    elseif RE.quality >= 5 then
        return ENCHANT_LEGENDARY_ORB_COST
    end
end

-------------------------------------------------------------------------------
--                           Paper doll scripts                              --
-------------------------------------------------------------------------------
local function SetPaperDollEnchantVisual(index, RE)
    local spellID = RE.spellID

    local _, _, icon = GetSpellInfo(spellID)

    if not icon then
        icon = UNKNOWN_ENCHANT_ICON
    end

    local quality = RE.quality

    local count = M.EquippedEnchantStacks[RE.enchantID] or 0

    local btn = _G["EnchantStackDisplayButton" .. index]
    EnchantTemplate_Normalize(btn)
    -- btn:SetNormalTexture(M.PaperDollEnchantQualitySettings[quality])
    btn.Quality = quality

    SetPortraitToTexture(btn.Icon, icon)

    btn.Spell = spellID
    btn.Stack = count

    if (count == 0) then
        btn.MaxStack = 1
    else
        btn.MaxStack = RE.stackable
    end

    if btn.Stack > btn.MaxStack then
        EnchantTemplate_Max(btn)
    end
    if RE.quality >= 5 and M.EquippedLegendaryEnchants > 1 then
        EnchantTemplate_Max(btn)
    elseif RE.quality == 4 and M.EquippedEpicEnchants > 3 then
        EnchantTemplate_Max(btn)
    end

    btn:Show()
end

function GetEquippedEnchantsByQuality(quality)
    local enchants = {}
    for enchantID, count in pairs(M.EquippedEnchantStacks) do
        local RE = GetREData(enchantID)
        if RE.enchantID ~= 0 and RE.quality == quality then
            enchants[RE.spellID] = count
        end
    end

    return enchants
end

function UpdatePaperDollEnchantList()
    local index = 0
    local enchantSlots = Addon.CharacterFrame.Extension.EnchantPanel.Enchants

    for _, enchantSlot in ipairs(enchantSlots) do
        enchantSlot:Hide()
    end

    for enchantID, count in pairs(M.EquippedEnchantStacks) do
        index = index + 1

        local RE = GetREData(enchantID)
        local sname, _, sicon = GetSpellInfo(RE.spellID)
        if not sname or not sicon then
            sname = "Unknown Enchant"
            sicon = UNKNOWN_ENCHANT_ICON
        end

        local enchantSlot = enchantSlots[index]
        local maxStacks = RE.stackable
        local enchantQualityColor = M.EnchantQualitySettings[RE.quality][1]

        enchantSlot.Button.Spell = RE.spellID
        enchantSlot.Button.Icon:SetTexture(sicon)
        enchantSlot.Name:SetText(enchantQualityColor .. sname .. "|r")
        if (count == 99) then
            enchantSlot.Count:SetText("|cffFF00000/" .. maxStacks .. "|r")
        else
            enchantSlot.Count:SetText(count .. "/" .. maxStacks)
        end
        enchantSlot:Show()
    end

    if index == 0 then
        Addon.CharacterFrame.Extension.SwapButton:Disable()
        return
    end

    Addon.CharacterFrame.Extension.SwapButton:Enable()

    local enchantPanel = Addon.CharacterFrame.Extension.EnchantPanel

    if index * 50 > enchantPanel.Scroll:GetHeight() then
        enchantPanel.Scroll:EnableMouseWheel(true)
    else
        enchantPanel.Scroll:EnableMouseWheel(false)
    end

    enchantPanel.Scroll.ScrollBar:SetMinMaxValues(1, max(index * 50 - 300, 50))
end

local function UpdateActiveEnchants()
    M.EnchantLimits.Legendary.active = M.EquippedLegendaryEnchants
    M.EnchantLimits.Epic.active = M.EquippedEpicEnchants
    M.EnchantLimits:UpdateValues()
    --M.ControlFrame.Currency.TotalLeg.active = M.EquippedLegendaryEnchants -- TODO: Remove old counters
    --M.ControlFrame.Currency.TotalEpic.active = M.EquippedEpicEnchants
    --M.ControlFrame.Currency.TotalRare.active = totalRare + totalUncommon
    --M.ControlFrame.Currency.TotalLeg.UpdateText()
    --M.ControlFrame.Currency.TotalEpic.UpdateText()
    --M.ControlFrame.Currency.TotalRare.UpdateText()
    --local totalStr = string.format("Active Effects: "..legQualityColor.."Legendary|r: |cffFFFFFF%i|r/1 "..epicQualityColor.."Epic|r: |cffFFFFFF%i|r/3 "..rareQualityColor.."Rare|r/"..uncommonQualityColor.."Uncommon|r: |cffFFFFFF%i|r/13", totalLegendary, totalEpic, (totalUncommon+totalRare))
    --M.ControlFrame.Currency.ActiveText:SetText(totalStr)
end
-------------------------------------------------------------------------------
--                               AIO Scripts                                 --
-------------------------------------------------------------------------------

local function UpdatePaperDoll()
    M.QualityData = {}

    for i, _ in pairs(ParentButtons) do
        if not _G["EnchantStackDisplayButton" .. i] then -- called before AIO loaded stuff
            return
        end
        _G["EnchantStackDisplayButton" .. i]:Hide()
        _G["EnchantStackDisplayButton" .. i].Maxed:Hide()
    end

    M.EquippedEnchantStacks = {}
    M.EquippedEnchantItemSlots = {}
    M.EquippedLegendaryEnchants = 0
    M.EquippedEpicEnchants = 0

    for i = 1, 19 do
        local slot = M.PaperDoll["Slot" .. i]
        if slot then
            slot:GetScript("OnEvent")(slot, "PLAYER_EQUIPMENT_CHANGED")
            slot.Enchant:Hide()
            slot.Enchant.Maxed:Hide()

            local enchantID = GetREInSlot(255, slot.SlotID) or 0
            slot.enchantID = enchantID

            if enchantID ~= 0 then
                HandleCollectionSlot(slot.Enchant, enchantID)

                if GetREData(enchantID).quality >= 5 then
                    M.EquippedLegendaryEnchants = M.EquippedLegendaryEnchants + 1
                elseif GetREData(enchantID).quality == 4 then
                    M.EquippedEpicEnchants = M.EquippedEpicEnchants + 1
                end

                if M.EquippedEnchantItemSlots[enchantID] == nil then
                    M.EquippedEnchantItemSlots[enchantID] = { ParentButtons[slot.SlotID] }
                else
                    table.insert(M.EquippedEnchantItemSlots[enchantID], ParentButtons[slot.SlotID])
                end

                if M.EquippedEnchantStacks[enchantID] == nil then
                    M.EquippedEnchantStacks[enchantID] = 1
                else
                    M.EquippedEnchantStacks[enchantID] = M.EquippedEnchantStacks[enchantID] + 1
                end
            end
        end
    end

    -- i dont like looping this twice but its the only real way to check if we have too many of an enchant
    for i = 1, 19 do
        local slot = M.PaperDoll["Slot" .. i]
        if slot and slot.SlotID ~= nil then
            if slot.enchantID ~= nil and slot.enchantID ~= 0 then
                local RE = GetREData(slot.enchantID)

                if M.EquippedEnchantStacks[slot.enchantID] ~= nil then
                    SetPaperDollEnchantVisual(slot.SlotID, RE)

                    if M.EquippedEnchantStacks[slot.enchantID] > RE.stackable then
                        EnchantTemplate_Max(slot.Enchant)
                    end

                    if RE.quality >= 5 and M.EquippedLegendaryEnchants > 1 then
                        EnchantTemplate_Max(slot.Enchant)
                    elseif RE.quality == 4 and M.EquippedEpicEnchants > 3 then
                        EnchantTemplate_Max(slot.Enchant)
                    end
                end
            end
        end
    end

    UpdatePaperDollEnchantList()
    UpdateActiveEnchants()
end

function M.ClickItem(bag, slot)
    if M.IsTryingToCast then
        if slot == nil then
            ITEM_BAG_TEMP = 255
            ITEM_BAG_SLOT = bag
        else
            ITEM_BAG_TEMP = bag
            ITEM_BAG_SLOT = slot
        end
        PlaceItem()
        M:PrepareCollectionReforge()
        M.IsTryingToCast:SetScript("OnUpdate", nil)
    end
end

function M.PlaceItem(item, enchantID, cost, bag, slot)
    -- local itemID = GetItemInfoFromHyperlink(item)
    M.ConfirmDisenchant:Hide()
    local name, itemlink, quality, _, _, _, _, _, itemType, texture, _ = GetItemInfo(item)
    -- check if we can even place this item
    if not VALID_INVTYPE[itemType] then
        StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "Cannot enchant |cff00CCFF[" .. name .. "]|r\nInvalid Item Type"
        StaticPopup_Show("ASC_ERROR_TIMEOUT")
        return
    end

    if itemID and not EnchantableHeirlooms[itemID] and (quality < REFORGE_QUALITY_MIN or quality > REFORGE_QUALITY_MAX) then
        StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text =
        "Item must be\n|cFF1EFF0CUncommon|r, |cFF0070FFRare|r, |cFFA335EEEpic|r, or |cFFFF8000Legendary|r\nto enchant it"
        StaticPopup_Show("ASC_ERROR_TIMEOUT")
        return
    end

    --Setting up item to the button
    PlaySound("Glyph_MajorCreate")
    ACTIVE_ITEM = item
    ITEM_SLOT = slot
    ITEM_BAG = bag

    local RE = GetREData(enchantID)
    local enchantName, _, enchantTexture = GetSpellInfo(RE.spellID)

    if enchantID == 0 then
        enchantName = "Unknown Enchant"
        enchantTexture = UNKNOWN_ENCHANT_ICON
    end

    local qualityColor = M.EnchantQualitySettings[RE.quality][1]

    M.EnchantFrame.Icon:SetVertexColor(1, 1, 1, 1)
    M.EnchantFrame.EnchName:Show()
    M.EnchantFrame.ItemName:Show()

    M.EnchantFrame.Icon:SetTexture(texture)
    M.EnchantFrame.ItemName:SetText(itemlink)

    UpdateRerollCost(cost)

    if M.EnchantFrame.BGHighlight.AG:IsPlaying() then
        M.EnchantFrame.BGHighlight.AG:Stop()
    end

    M.EnchantFrame.BGHighlight.AG:Play()
    M.EnchantFrame.BG:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\LabelTopActive")
    DisableBreathing()

    if not enchantName then
        M.EnchantFrame.EnchName:SetText("|cffFFFFFFNo Mystic Enchant|r")
        M.EnchantFrame.Enchant:Hide()
        ACTIVE_ENCHANT = nil
    else
        M.EnchantFrame.EnchName:SetText(qualityColor .. enchantName .. "|r")
        M.EnchantFrame.Enchant.Qualtiy = RE.quality
        M.EnchantFrame.Enchant.Spell = RE.spellID
        M.EnchantFrame.Enchant:Show()
        HandleCollectionSlot(M.EnchantFrame.Enchant, enchantID)
        ACTIVE_ENCHANT = enchantID

        --handle refund here
        --local canRefund = false
        --UnlockRefund(canRefund)
    end

    if (bag == 255) and CollectionSlotMap[slot] then
        CollectionSlotMap[slot]:SetChecked(true)
    end

    DisenchantButtonTokenCheck(M.ControlFrame.ExtractButton)
    RollButtonCheck(M.ControlFrame.RollButton)
    ClearCursor()
end

local function OnReforgeSuccess(playerGUID, enchantID)
    if playerGUID ~= tonumber(UnitGUID("player"), 16) then
        return
    end

    if not ACTIVE_ITEM then -- we just directly applied the enchant
        Timer.After(0.1, function()
            UpdatePaperDoll()
            DisenchantButtonTokenCheck(M.ControlFrame.ExtractButton)
            RollButtonCheck(M.ControlFrame.RollButton)
        end)
        PlaySound("Glyph_MinorCreate")
        return
    else
        -- check item hasn't changed.
        if ITEM_BAG == 255 then
            local itemLink = GetInventoryItemLink("player", ITEM_SLOT)
            if ACTIVE_ITEM ~= itemLink then
                PlaySound("Glyph_MinorCreate")
                ClearControlFrame()
                return
            end
        else
            local _, _, _, _, _, _, itemLink = GetContainerItemInfo(ITEM_BAG, ITEM_SLOT)
            if ACTIVE_ITEM ~= itemLink then
                PlaySound("Glyph_MinorCreate")
                ClearControlFrame()
                return
            end
        end
    end
    local RE = GetREData(enchantID)

    local enchantName, _, enchantTexture = GetSpellInfo(RE.spellID)

    if not enchantName or not enchantTexture then
        enchantName = RE.spellName
        enchantTexture = UNKNOWN_ENCHANT_ICON
        SendSystemMessage("Mystic Enchanting: Reforged unknown enchant [|cffFFFFFF" .. enchantID ..
            "|r]. Tell a developer")
    end

    local qualityNumber = RE.quality
    local qualityColor = M.EnchantQualitySettings[qualityNumber][1]

    if enchantName then
        if not (M.EnchantFrame.Enchant:IsVisible()) then
            M.EnchantFrame.Enchant:SetNormalTexture("")
            M.EnchantFrame.Enchant.Icon:Hide()
        end

        M.EnchantFrame.Enchant:Show()
        ACTIVE_ENCHANT = enchantID

        local r, g, b = GetItemQualityColor(qualityNumber)
        M.EnchantFrame.Enchant.SetUnlockColor(r, g, b)

        M.EnchantFrame.EnchName:SetText(qualityColor .. enchantName .. "|r")

        Timer.After(0.1, function()
            UpdatePaperDoll()
            M.EnchantFrame.Enchant.Icon:Show()
            HandleCollectionSlot(M.EnchantFrame.Enchant, enchantID)
            HandleCollectionSlot(M.ConfirmDisenchant.Enchant, enchantID)
            DisenchantButtonTokenCheck(M.ControlFrame.ExtractButton)
            RollButtonCheck(M.ControlFrame.RollButton)
        end)

        M.EnchantFrame.Enchant.PlayUnlock()
        PlaySound("Glyph_MinorCreate")
    end

    DisenchantButtonTokenCheck(M.ControlFrame.ExtractButton)
    RollButtonCheck(M.ControlFrame.RollButton)
end

function M:Display()
    PlaySound("Glyph_MajorCreate")
    Collections:GoToTab(4)
end

function M:Close()
    PlaySound("igMainMenuOptionCheckBoxOn")
    M:Hide()
    HideUIPanel(Collections)
end

function M.GetSuccessChance(chance)
    M.SuccessChance = chance
end

-------------------------------------------------------------------------------
--                                    UI                                     --
-------------------------------------------------------------------------------
M:SetSize(784, 512)
--M:SetPoint("LEFT", 70, 30)
M:SetPoint("CENTER", 0, 0)
--M:SetFrameLevel(10)

M.Icon = M:CreateTexture(nil, "BACKGROUND")
M.Icon:SetSize(60, 60)
M.Icon:SetPoint("TOPLEFT", 4, 2)
M.Icon:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\inv_blacksmithing_khazgoriananvil1")
SetPortraitToTexture(M.Icon, Addon.AwTexPath .. "EnchOverhaul\\inv_blacksmithing_khazgoriananvil1")

M.BG = M:CreateTexture(nil, "BORDER")
M.BG:SetSize(1024, 1014)
M.BG:SetPoint("CENTER", 0, 1)
M.BG:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\EnchRework2")

M.CloseButton = CreateFrame("Button", "$parentCloseButton", M, "UIPanelCloseButton")
M.CloseButton:SetPoint("TOPRIGHT", -4, -1)
M.CloseButton:EnableMouse(true)
M.CloseButton:SetScript("OnMouseUp", function()
    PlaySound("QUESTLOGCLOSE")
    HideUIPanel(Collections)
end)

M.TitleText = M:CreateFontString()
M.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
M.TitleText:SetFontObject(GameFontNormal)
M.TitleText:SetPoint("TOP", 0, -11)
M.TitleText:SetShadowOffset(1, -1)
M.TitleText:SetText(MYSTIC_ENCHANTING_ALTAR)

-------------------------------------------------------------------------------
--                                   Level                                   --
-------------------------------------------------------------------------------
M.LevelFrame = CreateFrame("Button", "$parentLevelFrame", M)
M.LevelFrame:SetPoint("BOTTOMRIGHT", M.Icon, 8, -8)
M.LevelFrame:SetWidth(36)
M.LevelFrame:SetHeight(36)
--M.LevelFrame:SetHighlightTexture(Addon.AwTexPath.."Misc\\roundbuttonhighlight")

M.LevelFrame.Border = M.LevelFrame:CreateTexture(nil, "ARTWORK")
M.LevelFrame.Border:SetSize(36, 36)
M.LevelFrame.Border:SetPoint("CENTER", -1, -1)
M.LevelFrame.Border:SetTexture(Addon.AwTexPath .. "Collections\\StoreCollectionRound")

M.LevelFrame.Icon = M.LevelFrame:CreateTexture(nil, "BORDER")
M.LevelFrame.Icon:SetSize(24, 24)
M.LevelFrame.Icon:SetPoint("CENTER", 0, 0)
M.LevelFrame.Icon:SetVertexColor(0.1, 0.1, 0.1, 1)
SetPortraitToTexture(M.LevelFrame.Icon, "Interface\\icons\\INV_Misc_Book_11")

M.LevelFrame.Highlight = M.LevelFrame:CreateTexture(nil, "BACKGROUND")
M.LevelFrame.Highlight:SetSize(70, 70)
M.LevelFrame.Highlight:SetPoint("CENTER", 0, 2)
M.LevelFrame.Highlight:SetTexture(Addon.AwTexPath .. "Collections\\DragonHighlight")
M.LevelFrame.Highlight:SetBlendMode("ADD")

M.LevelFrame.TitleText = M.LevelFrame:CreateFontString(nil, "OVERLAY")
M.LevelFrame.TitleText:SetFontObject(GameFontHighlight)
M.LevelFrame.TitleText:SetPoint("CENTER", -1.5, 0)
M.LevelFrame.TitleText:SetText("")

M.LevelFrame.Highlight.AnimG = M.LevelFrame.Highlight:CreateAnimationGroup()
M.LevelFrame.Highlight.AnimG.Rotation = M.LevelFrame.Highlight.AnimG:CreateAnimation("Rotation")
M.LevelFrame.Highlight.AnimG.Rotation:SetDuration(60)
M.LevelFrame.Highlight.AnimG.Rotation:SetOrder(1)
M.LevelFrame.Highlight.AnimG.Rotation:SetEndDelay(0)
M.LevelFrame.Highlight.AnimG.Rotation:SetSmoothing("NONE")
M.LevelFrame.Highlight.AnimG.Rotation:SetDegrees(-360)

M.LevelFrame.Highlight.AnimG:SetScript("OnFinished", function(self)
    self:Play()
end)

M.LevelFrame.Highlight.AnimG:Play()

--[[M.LevelFrame:SetScript("OnUpdate", function()
  if not(M.LevelFrame.Highlight.AnimG:IsPlaying()) then
      M.LevelFrame.Highlight.AnimG:Play()
  end

  if not(M.LevelFrame.AnimG:IsPlaying()) then
    M.LevelFrame.AnimG:Play()
  end
end)]]
--
-------------------------------------------------------------------------------
--                                 Top Navi                                  --
-------------------------------------------------------------------------------
-- M.SearchBox = CreateFrame("EditBox", "$parentSearchBox", M, "SearchBoxTemplate")
-- M.SearchBox:SetSize(130, 26)
-- M.SearchBox:SetPoint("TOPRIGHT", M, -140, -33)
-- M.SearchBox.Instructions:SetText(SEARCH)
-- M.SearchBox:SetScript("OnTextChanged", function(self)
--     if self.SearchTimer then
--         self.SearchTimer:Cancel()
--     end
--     self.SearchTimer = Timer.NewTimer(0.15, SearchForEnchant)
-- end)
-- M.SearchBox:SetScript("OnEscapePressed", function(self)
--     SearchForEnchant()
--     EditBox_ClearFocus(self)
-- end)

M.EnchantTypeList = CreateFrame("Button", "$parentEnchantTypeList", M, "UIDropDownMenuTemplate")
M.EnchantTypeList:SetPoint("TOPRIGHT", M, -10, -32)

M.EnchantTypeList.List = {
    { -- 1
        text = "All",
        value = 1,
        tooltipTitle = "Shows all enchants",
        tooltipOnButton = true,
        func = function() UpdateListInfo(MYSTIC_ENCHANTS) end,
    },
    { -- 2
        text = "Relevant (Popular)",
        value = 2,
        tooltipTitle = "Shows popular enchants relevant to spells you know",
        tooltipOnButton = true,
        func = function() BuildListByRelevancy() end,
    },
    { -- 3
        text = "Relevant (All)",
        value = 3,
        tooltipTitle = "Shows ALL enchants relevant to spells you know",
        tooltipOnButton = true,
        func = function() BuildListByMySpells() end,
    },
    { -- 4
        text = "Armor Only",
        value = 4,
        tooltipTitle = "Shows enchants that cannot be applied to weapons",
        tooltipOnButton = true,
        func = function() BuildClassList("ARMOR") end,
    },
    { -- 5
        text = "Armor and Weapons",
        value = 5,
        tooltipTitle = "Shows all enchants",
        tooltipOnButton = true,
        func = function() BuildClassList("ANY") end,
    },
    { -- 6
        text = "Known",
        value = 6,
        tooltipTitle = "Shows your known enchants",
        tooltipOnButton = true,
        func = function() BuildKnownList(true) end,
    },
    { -- 7
        text = "Not Known",
        value = 7,
        tooltipTitle = "Shows enchants you don't know",
        tooltipOnButton = true,
        func = function() BuildKnownList(false) end,
    },
    { -- 8
        text = "|cff1eff00Uncommon|r",
        value = 8,
        tooltipTitle = "Shows |cff1eff00uncommon|r quality enchants",
        tooltipOnButton = true,
        func = function() BuildListByQuality(2) end,
    },
    { -- 9
        text = "|cff0070ddRare|r",
        value = 9,
        tooltipTitle = "Shows |cff0070ddrare|r quality enchants",
        tooltipOnButton = true,
        func = function() BuildListByQuality(3) end,
    },
    { -- 10
        text = "|cffa335eeEpic|r",
        value = 10,
        tooltipTitle = "Shows |cffa335eeepic|r quality enchants",
        tooltipOnButton = true,
        func = function() BuildListByQuality(4) end,
    },
    { -- 11
        text = "|cffff8000Legendary|r",
        value = 11,
        tooltipTitle = "Shows |cffff8000Legendary|r quality enchants",
        tooltipOnButton = true,
        func = function() BuildListByQuality(5) end,
    },
    { -- 11
        text = "|cff00CCFFWorldforged|r",
        value = 12,
        tooltipTitle = "Shows |cff00CC88Worldforged|r enchants",
        tooltipOnButton = true,
        func = function() BuildListByWorldforged() end,
    }
}

function M.EnchantTypeList.Init(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for _, infoData in pairs(M.EnchantTypeList.List) do
        info = UIDropDownMenu_CreateInfo()
        for k, v in pairs(infoData) do
            info[k] = v
        end

        local func = info.func
        info.func = function(self)
            UIDropDownMenu_SetSelectedID(M.EnchantTypeList, self:GetID())
            M.EnchantTypeList.SelectedId = self:GetID()
            UIDropDownMenu_SetText(M.EnchantTypeList, M.EnchantTypeList.List[self:GetID()].text)
            SearchForEnchant()
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

UIDropDownMenu_Initialize(M.EnchantTypeList, M.EnchantTypeList.Init)
UIDropDownMenu_SetWidth(M.EnchantTypeList, 90);
UIDropDownMenu_SetButtonWidth(M.EnchantTypeList, 70)
UIDropDownMenu_SetSelectedID(M.EnchantTypeList, 6)
M.EnchantTypeList.SelectedId = 6
UIDropDownMenu_SetText(M.EnchantTypeList, M.EnchantTypeList.List[6].text)
UIDropDownMenu_JustifyText(M.EnchantTypeList, "LEFT")
-------------------------------------------------------------------------------
--                                 Collection                                --
-------------------------------------------------------------------------------
M.CollectionsList = CreateFrame("FRAME", "$parentCollectionsList", M, nil)
M.CollectionsList:SetPoint("CENTER", 145, -15)
M.CollectionsList:SetSize(470, 425)
M.CollectionsList:EnableMouseWheel(true)
--M.CollectionsList:SetBackdrop(StaticPopup1:GetBackdrop())

--[[M.CollectionsList.TitleText = M.CollectionsList:CreateFontString()
M.CollectionsList.TitleText:SetFont("Fonts\\MORPHEUS.TTF", 20)
M.CollectionsList.TitleText:SetFontObject(GameFontHighlight)
M.CollectionsList.TitleText:SetPoint("TOP", 0, -14)
M.CollectionsList.TitleText:SetSize(417, 22)
M.CollectionsList.TitleText:SetText("Enchant Collection")
M.CollectionsList.TitleText:SetJustifyH("CENTER")

M.CollectionsList.SpellsSubText = M.CollectionsList:CreateFontString()
M.CollectionsList.SpellsSubText:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.CollectionsList.SpellsSubText:SetFontObject(GameFontNormal)
M.CollectionsList.SpellsSubText:SetPoint("CENTER", M.CollectionsList.TitleText, "BOTTOM", 0,-8)
--M.CollectionsList.SpellsText:SetShadowOffset(0,0)
M.CollectionsList.SpellsSubText:SetSize(260, 22)
M.CollectionsList.SpellsSubText:SetText("Select an enchant to apply to your item")
M.CollectionsList.SpellsSubText:SetJustifyH("CENTER")]]
--

--[[M.CollectionsList.NextButton.Text = M.CollectionsList.NextButton:CreateFontString()
M.CollectionsList.NextButton.Text:SetFontObject(GameFontNormal)
M.CollectionsList.NextButton.Text:SetPoint("RIGHT", M.CollectionsList.NextButton, "LEFT", 0, 0)
M.CollectionsList.NextButton.Text:SetJustifyH("RIGHT")
M.CollectionsList.NextButton.Text:SetText(NEXT)]]
--


M.CollectionsList.CurrencyOrbs = CurrencyTemplate("CurrencyOrbs", M.CollectionsList)
M.CollectionsList.CurrencyOrbs:SetPoint("TOP", M.CollectionsList, 0, -26)

M.CollectionsList.PrevButton = CreateFrame("Button", "$parentPrevButton", M.CollectionsList, nil)
M.CollectionsList.PrevButton:SetSize(28, 28)
M.CollectionsList.PrevButton:SetPoint("RIGHT", M.CollectionsList, "BOTTOM", 6, 41)
M.CollectionsList.PrevButton:EnableMouse(true)
M.CollectionsList.PrevButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
M.CollectionsList.PrevButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
M.CollectionsList.PrevButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
M.CollectionsList.PrevButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
M.CollectionsList.PrevButton:SetScript("OnClick", CollectionListPrevPage)

M.CollectionsList.NextButton = CreateFrame("Button", "$parentNextButton", M.CollectionsList, nil)
M.CollectionsList.NextButton:SetSize(28, 28)
M.CollectionsList.NextButton:SetPoint("LEFT", M.CollectionsList.PrevButton, "RIGHT", 4, 0)
M.CollectionsList.NextButton:EnableMouse(true)
M.CollectionsList.NextButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
M.CollectionsList.NextButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
M.CollectionsList.NextButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
M.CollectionsList.NextButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
M.CollectionsList.NextButton:SetScript("OnClick", CollectionListNextPage)

M.CollectionsList.PageText = M.CollectionsList:CreateFontString()
M.CollectionsList.PageText:SetFontObject(GameFontHighlight)
M.CollectionsList.PageText:SetPoint("RIGHT", M.CollectionsList.PrevButton, "LEFT", -4, 0)
M.CollectionsList.PageText:SetSize(200, 16)
M.CollectionsList.PageText:SetJustifyH("RIGHT")

--[[M.CollectionsList.PrevButton.Text = M.CollectionsList.PrevButton:CreateFontString()
M.CollectionsList.PrevButton.Text:SetFontObject(GameFontNormal)
M.CollectionsList.PrevButton.Text:SetPoint("LEFT", M.CollectionsList.PrevButton, "RIGHT", 0, 0)
M.CollectionsList.PrevButton.Text:SetJustifyH("LEFT")
M.CollectionsList.PrevButton.Text:SetText(PREV)]]
--

M.CollectionsList:SetScript("OnMouseWheel", function(self, delta)
    if (M.CollectionsList.PrevButton:IsEnabled() == 1) and (delta == -1) then
        CollectionListPrevPage(M.CollectionsList.PrevButton)
    elseif (M.CollectionsList.NextButton:IsEnabled() == 1) and (delta == 1) then
        CollectionListNextPage(M.CollectionsList.NextButton)
    end
end)


CollectionItemFrame1 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame1:SetPoint("CENTER", -150, 127)

CollectionItemFrame2 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame2:SetPoint("CENTER", 0, 127)

CollectionItemFrame3 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame3:SetPoint("CENTER", 150, 127)

CollectionItemFrame4 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame4:SetPoint("CENTER", -150, 67)

CollectionItemFrame5 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame5:SetPoint("CENTER", 0, 67)

CollectionItemFrame6 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame6:SetPoint("CENTER", 150, 67)

CollectionItemFrame7 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame7:SetPoint("CENTER", -150, 7)

CollectionItemFrame8 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame8:SetPoint("CENTER", 0, 7)

CollectionItemFrame9 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame9:SetPoint("CENTER", 150, 7)

CollectionItemFrame10 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame10:SetPoint("CENTER", -150, -53)

CollectionItemFrame11 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame11:SetPoint("CENTER", 0, -53)

CollectionItemFrame12 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame12:SetPoint("CENTER", 150, -53)

CollectionItemFrame13 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame13:SetPoint("CENTER", -150, -113)

CollectionItemFrame14 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame14:SetPoint("CENTER", 0, -113)

CollectionItemFrame15 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame15:SetPoint("CENTER", 150, -113)

-------------------------------------------------------------------------------
--                                ProgressBar                                --
-------------------------------------------------------------------------------
M.ProgressBar = CreateFrame("StatusBar", "$parentProgressBar", M)
M.ProgressBar:SetSize(212, 19)
M.ProgressBar:SetPoint("TOP", M.TitleText, "BOTTOM", 0, -13.5)
M.ProgressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
M.ProgressBar:EnableMouse(true)
M.ProgressBar:SetStatusBarColor(0, .6, 0, 1)
M.ProgressBar:SetMinMaxValues(0, 100)
M.ProgressBar:SetValue(0)

M.ProgressBar:SetScript("OnEnter", function(self)
    if M.CDB then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(format("|cffFFFFFF%s|r/|cffFFFFFF%s|r", M.CDB.EnchantProgress, M.CDB.NextRequired))
        GameTooltip:AddLine(MYSTIC_ENCHANT_EXP_BAR_DESC, nil, nil, nil, true)
        GameTooltip:Show()
    end
end)

M.ProgressBar:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

M.ProgressBar.BG = M.ProgressBar:CreateTexture(nil, "BACKGROUND")
--M.ProgressBar.BG:SetSize(512,64)
M.ProgressBar.BG:SetPoint("TOPLEFT", M.ProgressBar)
M.ProgressBar.BG:SetPoint("BOTTOMRIGHT", M.ProgressBar)
M.ProgressBar.BG:SetVertexColor(0, 0, 0, 0.4)

M.ProgressBar.Border = M.ProgressBar:CreateTexture(nil, "OVERLAY")
--M.ProgressBar.BG:SetSize(512,64)
M.ProgressBar.Border:SetTexture("Interface\\AchievementFrame\\UI-Achievement-ProgressBar-Border")
M.ProgressBar.Border:SetPoint("TOPLEFT", M.ProgressBar, -6, 5)
M.ProgressBar.Border:SetPoint("BOTTOMRIGHT", M.ProgressBar, 6, -5)
M.ProgressBar.Border:SetTexCoord(0, 0.8745, 0, 0.75)

M.ProgressBar.Text = M.ProgressBar:CreateFontString(nil)
M.ProgressBar.Text:SetFontObject(GameFontHighlight)
M.ProgressBar.Text:SetPoint("CENTER")

--[[M.ProgressBar.ArtWork = M.ProgressBar:CreateTexture(nil, "ARTWORK")
M.ProgressBar.ArtWork:SetSize(512,64)
M.ProgressBar.ArtWork:SetTexture(Addon.AwTexPath.."EnchOverhaul\\CollectionsBar")
M.ProgressBar.ArtWork:SetPoint("CENTER",M.ProgressBar,0,25)

M.ProgressBar.ArtWork_Hover = M.ProgressBar:CreateTexture(nil, "OVERLAY")
M.ProgressBar.ArtWork_Hover:SetSize(512,64)
M.ProgressBar.ArtWork_Hover:SetTexture(Addon.AwTexPath.."EnchOverhaul\\CollectionsBar_Hover")
M.ProgressBar.ArtWork_Hover:SetPoint("CENTER",M.ProgressBar,0,25)
M.ProgressBar.ArtWork_Hover:SetBlendMode("ADD")
M.ProgressBar.ArtWork_Hover:SetAlpha(0)
M.ProgressBar.ArtWork_Hover:Hide()

M.ProgressBar.Hover = M.ProgressBar:CreateTexture(nil, "OVERLAY")
M.ProgressBar.Hover:SetSize(280,13)
M.ProgressBar.Hover:SetTexture(Addon.AwTexPath.."Collections\\CollectionsBarEnchants")
M.ProgressBar.Hover:SetPoint("CENTER", 0, 0)
M.ProgressBar.Hover:SetBlendMode("ADD")
M.ProgressBar.Hover:Hide()]]
--

-------------------------------------------------------------------------------
--                              Left Side Panel                              --
-------------------------------------------------------------------------------
M.PaperDoll = CreateFrame("FRAME", "$parentPaperDoll", M, nil)
M.PaperDoll:SetPoint("LEFT", 17, 24)
M.PaperDoll:SetSize(280, 333)
--M.PaperDoll:SetBackdrop(GameTooltip:GetBackdrop())

M.PaperDoll.Slot1 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot1:SetPoint("TOPLEFT", M.PaperDoll, "TOPLEFT", 4, -2)
M.PaperDoll.Slot1.Enchant:SetPoint("LEFT", M.PaperDoll.Slot1, "RIGHT", -2, 0)
M.PaperDoll.Slot1.Slot = "HeadSlot"
M.PaperDoll.Slot1.SlotID = 1

M.PaperDoll.Slot2 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot2:SetPoint("TOP", M.PaperDoll.Slot1, "BOTTOM", 0, 2)
M.PaperDoll.Slot2.Enchant:SetPoint("LEFT", M.PaperDoll.Slot2, "RIGHT", -2, 0)
M.PaperDoll.Slot2.Slot = "NeckSlot"
M.PaperDoll.Slot2.SlotID = 2

M.PaperDoll.Slot3 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot3:SetPoint("TOP", M.PaperDoll.Slot2, "BOTTOM", 0, 2)
M.PaperDoll.Slot3.Enchant:SetPoint("LEFT", M.PaperDoll.Slot3, "RIGHT", -2, 0)
M.PaperDoll.Slot3.Slot = "ShoulderSlot"
M.PaperDoll.Slot3.SlotID = 3

M.PaperDoll.Slot4 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot4:SetPoint("TOP", M.PaperDoll.Slot3, "BOTTOM", 0, 2)
M.PaperDoll.Slot4.Enchant:SetPoint("LEFT", M.PaperDoll.Slot4, "RIGHT", -2, 0)
M.PaperDoll.Slot4.Slot = "BackSlot"
M.PaperDoll.Slot4.SlotID = 15

M.PaperDoll.Slot5 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot5:SetPoint("TOP", M.PaperDoll.Slot4, "BOTTOM", 0, 2)
M.PaperDoll.Slot5.Enchant:SetPoint("LEFT", M.PaperDoll.Slot5, "RIGHT", -2, 0)
M.PaperDoll.Slot5.Slot = "ChestSlot"
M.PaperDoll.Slot5.SlotID = 5

-- shirt
M.PaperDoll.Slot6 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot6:SetPoint("TOP", M.PaperDoll.Slot5, "BOTTOM", 0, 2)
M.PaperDoll.Slot6.Enchant:Hide()
M.PaperDoll.Slot6.Icon:Hide()
M.PaperDoll.Slot6:Disable()
M.PaperDoll.Slot6.SlotID = 0

-- tabard
M.PaperDoll.Slot7 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot7:SetPoint("TOP", M.PaperDoll.Slot6, "BOTTOM", 0, 2)
M.PaperDoll.Slot7.Enchant:Hide()
M.PaperDoll.Slot7.Icon:Hide()
M.PaperDoll.Slot7:Disable()
M.PaperDoll.Slot7.SlotID = 0

M.PaperDoll.Slot8 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot8:SetPoint("TOP", M.PaperDoll.Slot7, "BOTTOM", 0, 2)
M.PaperDoll.Slot8.Enchant:SetPoint("LEFT", M.PaperDoll.Slot8, "RIGHT", -2, 0)
M.PaperDoll.Slot8.Slot = "WristSlot"
M.PaperDoll.Slot8.SlotID = 9

M.PaperDoll.Slot9 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot9:SetPoint("TOPRIGHT", M.PaperDoll, "TOPRIGHT", -4, -2)
M.PaperDoll.Slot9.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot9, "LEFT", 2, 0)
M.PaperDoll.Slot9.Slot = "HandsSlot"
M.PaperDoll.Slot9.SlotID = 10

M.PaperDoll.Slot10 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot10:SetPoint("TOP", M.PaperDoll.Slot9, "BOTTOM", 0, 2)
M.PaperDoll.Slot10.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot10, "LEFT", 2, 0)
M.PaperDoll.Slot10.Slot = "WaistSlot"
M.PaperDoll.Slot10.SlotID = 6

M.PaperDoll.Slot11 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot11:SetPoint("TOP", M.PaperDoll.Slot10, "BOTTOM", 0, 2)
M.PaperDoll.Slot11.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot11, "LEFT", 2, 0)
M.PaperDoll.Slot11.Slot = "LegsSlot"
M.PaperDoll.Slot11.SlotID = 7

M.PaperDoll.Slot12 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot12:SetPoint("TOP", M.PaperDoll.Slot11, "BOTTOM", 0, 2)
M.PaperDoll.Slot12.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot12, "LEFT", 2, 0)
M.PaperDoll.Slot12.Slot = "FeetSlot"
M.PaperDoll.Slot12.SlotID = 8

M.PaperDoll.Slot13 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot13:SetPoint("TOP", M.PaperDoll.Slot12, "BOTTOM", 0, 2)
M.PaperDoll.Slot13.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot13, "LEFT", 2, 0)
M.PaperDoll.Slot13.Slot = "Finger0Slot"
M.PaperDoll.Slot13.SlotID = 11

M.PaperDoll.Slot14 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot14:SetPoint("TOP", M.PaperDoll.Slot13, "BOTTOM", 0, 2)
M.PaperDoll.Slot14.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot14, "LEFT", 2, 0)
M.PaperDoll.Slot14.Slot = "Finger1Slot"
M.PaperDoll.Slot14.SlotID = 12

M.PaperDoll.Slot15 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot15:SetPoint("TOP", M.PaperDoll.Slot14, "BOTTOM", 0, 2)
M.PaperDoll.Slot15.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot15, "LEFT", 2, 0)
M.PaperDoll.Slot15.Slot = "Trinket0Slot"
M.PaperDoll.Slot15.SlotID = 13

M.PaperDoll.Slot16 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot16:SetPoint("TOP", M.PaperDoll.Slot15, "BOTTOM", 0, 2)
M.PaperDoll.Slot16.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot16, "LEFT", 2, 0)
M.PaperDoll.Slot16.Slot = "Trinket1Slot"
M.PaperDoll.Slot16.SlotID = 14

M.PaperDoll.Slot17 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot17:SetPoint("BOTTOM", M.PaperDoll, "BOTTOM", 0, 2)
M.PaperDoll.Slot17.Enchant:SetPoint("BOTTOM", M.PaperDoll.Slot17, "TOP", 0, -2)
M.PaperDoll.Slot17.Slot = "SecondaryHandSlot"
M.PaperDoll.Slot17.SlotID = 17

M.PaperDoll.Slot18 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot18:SetPoint("LEFT", M.PaperDoll.Slot17, "RIGHT", -2, 0)
M.PaperDoll.Slot18.Enchant:SetPoint("BOTTOM", M.PaperDoll.Slot18, "TOP", 0, -2)
M.PaperDoll.Slot18.Slot = "RangedSlot"
M.PaperDoll.Slot18.SlotID = 18

M.PaperDoll.Slot19 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot19:SetPoint("RIGHT", M.PaperDoll.Slot17, "LEFT", 2, 0)
M.PaperDoll.Slot19.Enchant:SetPoint("BOTTOM", M.PaperDoll.Slot19, "TOP", 0, -2)
M.PaperDoll.Slot19.Slot = "MainHandSlot"
M.PaperDoll.Slot19.SlotID = 16

CollectionSlotMap = {
    [1] = M.PaperDoll.Slot1,
    [2] = M.PaperDoll.Slot2,
    [3] = M.PaperDoll.Slot3,
    [15] = M.PaperDoll.Slot4,
    [5] = M.PaperDoll.Slot5,
    [9] = M.PaperDoll.Slot8,
    [10] = M.PaperDoll.Slot9,
    [6] = M.PaperDoll.Slot10,
    [7] = M.PaperDoll.Slot11,
    [8] = M.PaperDoll.Slot12,
    [11] = M.PaperDoll.Slot13,
    [12] = M.PaperDoll.Slot14,
    [13] = M.PaperDoll.Slot15,
    [14] = M.PaperDoll.Slot16,
    [16] = M.PaperDoll.Slot19,
    [17] = M.PaperDoll.Slot17,
    [18] = M.PaperDoll.Slot18
}
-------------------------------------------------------------------------------
--                                   Model                                   --
-------------------------------------------------------------------------------
M.PaperDoll.Model = CreateFrame("PlayerModel", "$parentModel", M.PaperDoll, nil)
M.PaperDoll.Model:SetPoint("CENTER", 0, 15)
M.PaperDoll.Model:SetSize(233, 295)
M.PaperDoll.Model:EnableMouse(true)
M.PaperDoll.Model.rotation = 0

M.PaperDoll.Model:SetScript("OnShow", function(self)
    self:SetUnit("player");
end)

M.PaperDoll.Model:SetScript("OnLoad", function(self)
    Model_OnLoad(self);
    self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end)
M.PaperDoll.Model:SetScript("OnEvent", function(self)
    self:RefreshUnit();
end)
M.PaperDoll.Model:SetScript("OnUpdate", function(self, elapsed)
    Model_OnUpdate(self, elapsed);

    if (M.PaperDoll.Model.Rotation_X) then
        local x = GetCursorPosition();
        local diff = (x - M.PaperDoll.Model.Rotation_X) * 0.01;
        M.PaperDoll.Model.Rotation_X = GetCursorPosition();

        if (diff > 0) then
            Model_RotateRight(self)
        elseif (diff < 0) then
            Model_RotateLeft(self)
        end
    end
end)

M.PaperDoll.Model:SetScript("OnMouseDown", function(self, button)
    if (button == "LeftButton") then
        M.PaperDoll.Model.Rotation_X = GetCursorPosition();
    end
end)

M.PaperDoll.Model:SetScript("OnMouseUp", function(self, button)
    if (button == "LeftButton") then
        M.PaperDoll.Model.Rotation_X = nil
    end
end)

M.PaperDoll.ModelRotateLeftButton = CreateFrame("Button", "$parentRotateLeftButton", M.PaperDoll.Model, nil)
M.PaperDoll.ModelRotateLeftButton:SetSize(35, 35)
M.PaperDoll.ModelRotateLeftButton:SetPoint("TOP", -16, 0)
M.PaperDoll.ModelRotateLeftButton:SetNormalTexture("Interface\\Buttons\\UI-RotationLeft-Button-Up")
M.PaperDoll.ModelRotateLeftButton:SetPushedTexture("Interface\\Buttons\\UI-RotationLeft-Button-Down")
M.PaperDoll.ModelRotateLeftButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Round")
M.PaperDoll.ModelRotateLeftButton:SetScript("OnLoad", function(self)
    self:RegisterForClicks("LeftButtonDown", "LeftButtonUp");
end)
M.PaperDoll.ModelRotateLeftButton:SetScript("OnClick", function(self)
    Model_RotateLeft(self:GetParent());
end)
M.PaperDoll.ModelRotateLeftButton:Hide()

M.PaperDoll.ModelRotateRightButton = CreateFrame("Button", "$parentRotateRightButton", M.PaperDoll.Model, nil)
M.PaperDoll.ModelRotateRightButton:SetSize(35, 35)
M.PaperDoll.ModelRotateRightButton:SetPoint("TOP", 16, 0)
M.PaperDoll.ModelRotateRightButton:SetNormalTexture("Interface\\Buttons\\UI-RotationRight-Button-Up")
M.PaperDoll.ModelRotateRightButton:SetPushedTexture("Interface\\Buttons\\UI-RotationRight-Button-Down")
M.PaperDoll.ModelRotateRightButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Round")
M.PaperDoll.ModelRotateRightButton:SetScript("OnLoad", function(self)
    self:RegisterForClicks("LeftButtonDown", "LeftButtonUp");
end)
M.PaperDoll.ModelRotateRightButton:SetScript("OnClick", function(self)
    Model_RotateRight(self:GetParent());
end)
M.PaperDoll.ModelRotateRightButton:Hide()

M.PaperDoll.Model:SetUnit("player");

-------------------------------------------------------------------------------
--                              Rarity Limits                                --
-------------------------------------------------------------------------------
local function RarityGemTemplate(parent, index)
    local frame = CreateFrame("FRAME", "$parentGem" .. index, parent)
    frame:SetSize(16, 16)
    frame.state = nil -- frame state should exist only for animated gems

    frame.border = frame:CreateTexture(nil, "BACKGROUND")
    frame.border:SetTexture(Addon.AwTexPath .. "CAOverhaul\\rarity_border")
    frame.border:SetSize(16, 16)
    frame.border:SetPoint("CENTER")

    frame.rarity = frame:CreateTexture(nil, "BORDER")
    frame.rarity:SetTexture(Addon.AwTexPath .. "CAOverhaul\\rarity")
    frame.rarity:SetSize(16, 16)
    frame.rarity:SetPoint("CENTER")

    frame.rarityAdd = frame:CreateTexture(nil, "ARTWORK")
    frame.rarityAdd:SetTexture(Addon.AwTexPath .. "CAOverhaul\\rarity")
    frame.rarityAdd:SetSize(16, 16)
    frame.rarityAdd:SetPoint("CENTER")
    frame.rarityAdd:SetBlendMode("ADD")

    -- animations
    local frame_flash = CreateFrame("FRAME", "$parentGemFlash" .. index, parent)
    frame_flash:SetSize(frame:GetSize())
    frame_flash:SetPoint("CENTER", frame, 0, 0)
    frame_flash:SetFrameLevel(frame:GetFrameLevel() + 1)

    frame_flash.tex = frame_flash:CreateTexture(nil, "OVERLAY")
    frame_flash.tex:SetTexture(Addon.AwTexPath .. "CAOverhaul\\rarityflash")
    frame_flash.tex:SetSize(22, 22)
    frame_flash.tex:SetPoint("CENTER", 0, 0)
    frame_flash.tex:SetBlendMode("ADD")
    frame_flash.tex:SetAlpha(0)

    frame_flash.sparkle = frame_flash:CreateTexture(nil, "OVERLAY")
    frame_flash.sparkle:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\AnimS2")
    frame_flash.sparkle:SetSize(32, 32)
    frame_flash.sparkle:SetPoint("CENTER")
    frame_flash.sparkle:SetBlendMode("ADD")
    frame_flash.sparkle:SetAlpha(0)

    frame_flash:Hide()

    frame_flash.tex.AG = frame_flash.tex:CreateAnimationGroup()

    frame_flash.tex.AG.FadeIn = frame_flash.tex.AG:CreateAnimation("Alpha")
    frame_flash.tex.AG.FadeIn:SetChange(1)
    frame_flash.tex.AG.FadeIn:SetSmoothing("IN")
    frame_flash.tex.AG.FadeIn:SetDuration(0.15)
    frame_flash.tex.AG.FadeIn:SetOrder(1)

    frame_flash.tex.AG.FadeOut = frame_flash.tex.AG:CreateAnimation("Alpha")
    frame_flash.tex.AG.FadeOut:SetChange(-1)
    frame_flash.tex.AG.FadeOut:SetSmoothing("OUT")
    frame_flash.tex.AG.FadeOut:SetDuration(0.5)
    frame_flash.tex.AG.FadeOut:SetOrder(2)

    frame_flash.sparkle.AG = frame_flash.sparkle:CreateAnimationGroup()

    frame_flash.sparkle.AG.rotation = frame_flash.sparkle.AG:CreateAnimation("Rotation")
    frame_flash.sparkle.AG.rotation:SetDegrees(90)
    frame_flash.sparkle.AG.rotation:SetSmoothing("IN")
    frame_flash.sparkle.AG.rotation:SetDuration(0.3)
    frame_flash.sparkle.AG.rotation:SetOrder(1)

    frame_flash.sparkle.AG.FadeIn = frame_flash.sparkle.AG:CreateAnimation("Alpha")
    frame_flash.sparkle.AG.FadeIn:SetChange(1)
    frame_flash.sparkle.AG.FadeIn:SetSmoothing("IN")
    frame_flash.sparkle.AG.FadeIn:SetDuration(0.3)
    frame_flash.sparkle.AG.FadeIn:SetOrder(1)

    frame_flash.sparkle.AG.rotation = frame_flash.sparkle.AG:CreateAnimation("Rotation")
    frame_flash.sparkle.AG.rotation:SetDegrees(90)
    frame_flash.sparkle.AG.rotation:SetSmoothing("OUT")
    frame_flash.sparkle.AG.rotation:SetDuration(1)
    frame_flash.sparkle.AG.rotation:SetOrder(2)

    frame_flash.sparkle.AG.FadeOut = frame_flash.sparkle.AG:CreateAnimation("Alpha")
    frame_flash.sparkle.AG.FadeOut:SetChange(-1)
    frame_flash.sparkle.AG.FadeOut:SetSmoothing("OUT")
    frame_flash.sparkle.AG.FadeOut:SetDuration(1)
    frame_flash.sparkle.AG.FadeOut:SetOrder(2)

    frame_flash.sparkle.AG.FadeOut:SetScript("OnFinished", function(self)
        frame_flash:Hide()
    end)

    frame.AG = frame:CreateAnimationGroup()
    frame.AG.FadeIn = frame.AG:CreateAnimation("Alpha")
    frame.AG.FadeIn:SetChange(-1)
    frame.AG.FadeIn:SetSmoothing("IN")
    frame.AG.FadeIn:SetDuration(0.01)
    frame.AG.FadeIn:SetEndDelay(0.1)
    frame.AG.FadeIn:SetOrder(1)

    frame.AG.FadeOut = frame.AG:CreateAnimation("Alpha")
    frame.AG.FadeOut:SetChange(1)
    frame.AG.FadeOut:SetSmoothing("OUT")
    frame.AG.FadeOut:SetDuration(0.5)
    frame.AG.FadeOut:SetOrder(2)

    function frame:PlayUnlock()
        frame.AG:Stop()
        frame_flash.tex.AG:Stop()
        frame_flash.sparkle.AG:Stop()

        frame.AG:Play()
        frame_flash:Show()
        frame_flash.tex.AG:Play()
        frame_flash.sparkle.AG:Play()
    end

    -- end of animations

    function frame:SetColor(r, g, b, a)
        frame.color = { r, g, b, a }
        frame.rarity:SetVertexColor(r, g, b, a)
        frame.rarityAdd:SetVertexColor(r, g, b, a)
        frame_flash.sparkle:SetVertexColor(r, g, b)
        frame_flash.tex:SetVertexColor(r + 0.3, g + 0.3, b + 0.3)
    end

    function frame:Disable()
        --frame.border:SetVertexColor(0.5, 0.5, 0.5, 1)
        frame.rarity:SetVertexColor(0.1, 0.1, 0.1, 1)
        frame.rarityAdd:Hide()

        if (frame.state) then
            frame.state = 0
        end
    end

    function frame:Enable()
        frame.border:SetVertexColor(1, 1, 1, 1)
        frame.rarity:SetVertexColor(unpack(self.color))
        frame.rarityAdd:Show()

        if frame.state and (frame.state == 0) then
            frame:PlayUnlock()
            frame.state = 1
        end
    end

    return frame
end

local function RarityBarTemplate(parent, index)
    local frame = CreateFrame("BUTTON", "$parentProgression" .. index, parent)
    local max_gems = 10
    local qualitySounds = {
        [0] = "common_ui_mission_select",
        [2] = "rare_ui_orderhall_talent_ready_toast",
        [3] = "rare_ui_orderhall_talent_ready_toast",
        [4] = "epic_ui_mission_200percent",
        [5] = "legendary_ui_legendary_item_toast",
    }
    --frame:SetSize(240,24)
    frame:SetSize(parent:GetWidth() / 2, 19)
    frame:EnableMouse(true)
    frame.rarity = index
    frame.rarityName = _G["ITEM_QUALITY" .. index .. "_DESC"]
    frame.gemsVisible = 0

    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
        local enchantText = self.gemsVisible ~= 1 and ENCHANTS or ENSCRIBE
        local totalEnchantText = self.total ~= 1 and ENCHANTS or ENSCRIBE
        GameTooltip:AddLine(format("|cffFFFFFFYou have %d|r %s %s", self.gemsVisible, self.rarityName, enchantText),
            ITEM_QUALITY_COLORS[self.rarity]:GetRGB())
        GameTooltip:AddLine(
            format("|cffFFD100You cannot have more than %d|r %s %s", self.total, self.rarityName, totalEnchantText),
            ITEM_QUALITY_COLORS[self.rarity]:GetRGB())
        GameTooltip:AddLine("active at the same time.")
        GameTooltip:Show()
        self.highlight:Show()
    end)

    frame:SetScript("OnLeave", function(self)
        self.highlight:Hide()
        GameTooltip:Hide()
    end)

    frame:SetScript("OnClick", function(self)
        if self.searchText then
            if not CA2.SearchBox:GetText():lower():find(self.searchText:lower()) then
                CA2.SearchBox:SetText(self.searchText)
                CA2.SearchBox:SearchForSpells()
            end
        end
    end)

    frame.bgMiddle = frame:CreateTexture(nil, "BACKGROUND")
    frame.bgMiddle:SetSize(frame:GetWidth() - 45, frame:GetHeight() + 1)
    frame.bgMiddle:SetPoint("CENTER", 0, 0)
    frame.bgMiddle:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\SKA\\CollapsibleHeader")
    frame.bgMiddle:SetTexCoord(0.48046875, 0.98046875, 0.01562500, 0.26562500)

    frame.bgLeft = frame:CreateTexture(nil, "BORDER")
    frame.bgLeft:SetSize(76, frame:GetHeight() + 1)
    frame.bgLeft:SetPoint("LEFT", frame.bgMiddle, "LEFT", -20, 0)
    frame.bgLeft:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\SKA\\CollapsibleHeader")
    frame.bgLeft:SetTexCoord(0.17578125, 0.47265625, 0.29687500, 0.54687500)

    frame.bgRight = frame:CreateTexture(nil, "BORDER")
    frame.bgRight:SetSize(76, frame:GetHeight() + 1)
    frame.bgRight:SetPoint("RIGHT", frame.bgMiddle, "RIGHT", 20, 0)
    frame.bgRight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\SKA\\CollapsibleHeader")
    frame.bgRight:SetTexCoord(0.17578125, 0.47265625, 0.01562500, 0.26562500)

    frame.highlight = frame:CreateTexture(nil, "OVERLAY")
    frame.highlight:SetSize(312, 22)
    frame.highlight:SetPoint("CENTER", 1, 0)
    frame.highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\BCNew\\CategoryTabH")
    frame.highlight:SetBlendMode("ADD")
    frame.highlight:Hide()

    frame.TextL = frame:CreateFontString(nil)
    frame.TextL:SetFontObject(GameFontNormalSmall)
    frame.TextL:SetPoint("LEFT", 8, 0)
    frame.TextL:SetText("|cffff8000" .. ITEM_QUALITY5_DESC .. "|r")

    frame.TextR = frame:CreateFontString(nil)
    frame.TextR:SetFontObject(GameFontHighlight)
    frame.TextR:SetPoint("RIGHT", -8, 0)
    frame.TextR:SetText("0/5")
    frame.TextR:Hide()

    frame.gems = {}
    for i = 1, max_gems do
        frame.gems[i] = RarityGemTemplate(frame, i)

        if (i == 1) then
            frame.gems[i]:SetPoint("LEFT", frame.TextL, "RIGHT", 8, 0)
        else
            frame.gems[i]:SetPoint("LEFT", frame.gems[i - 1], "RIGHT", 2, 0)
        end

        frame.gems[i].state = 0
        frame.gems[i]:Hide()
    end

    function frame:SetVertexColor(r, g, b)
        for _, gem in pairs(frame.gems) do
            gem:SetColor(r, g, b, 1)
        end

        for i = 1, min(frame.total, max_gems) do
            frame.gems[i]:Show()
            frame.gems[i]:Disable()
        end
    end

    function frame:EnableGem()
        frame.gemsVisible = frame.gemsVisible + 1
        frame.gems[frame.gemsVisible]:Enable()

        if (qualitySounds[frame.rarity]) and frame:IsVisible() then
            PlaySound(qualitySounds[frame.rarity])
        end
    end

    function frame:DisableGem()
        frame.gems[frame.gemsVisible]:Disable()
        frame.gemsVisible = frame.gemsVisible - 1
    end

    function frame:RefreshValue()
        local rarity = frame.rarity
        local new_value = frame.active
        local diff = new_value - frame.gemsVisible

        if (diff > 0) then
            for i = 1, diff do
                if frame.gemsVisible >= max_gems then
                    break
                end

                frame:EnableGem()
            end
        elseif (diff < 0) then
            for i = 1, math.abs(diff) do
                if frame.gemsVisible <= 0 then
                    break
                end

                frame:DisableGem()
            end
        end
    end

    return frame
end
-------------------------------------------------------------------------------
--                                 Enchant                                   --
-------------------------------------------------------------------------------
M.EnchantFrame = CreateFrame("FRAME", "$parentEnchantFrame", M, nil)
M.EnchantFrame:SetPoint("TOP", M.PaperDoll, "BOTTOM", 0, 1)
M.EnchantFrame:SetSize(280, 52)
M.EnchantFrame:SetFrameLevel(5)
--M.EnchantFrame:SetBackdrop(GameTooltip:GetBackdrop())

M.EnchantFrame.BG = M.EnchantFrame:CreateTexture(nil, "BORDER")
M.EnchantFrame.BG:SetSize(512, 128)
M.EnchantFrame.BG:SetPoint("CENTER", 0, 0)
M.EnchantFrame.BG:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\LabelTop")

M.EnchantFrame.BGHighlight = M.EnchantFrame:CreateTexture(nil, "ARTWORK")
M.EnchantFrame.BGHighlight:SetSize(512, 128)
M.EnchantFrame.BGHighlight:SetPoint("CENTER", 0, 0)
M.EnchantFrame.BGHighlight:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\LabelTopAH")
M.EnchantFrame.BGHighlight:SetAlpha(0)
M.EnchantFrame.BGHighlight:SetBlendMode("ADD")

M.EnchantFrame.Icon = M.EnchantFrame:CreateTexture(nil, "BACKGROUND")
M.EnchantFrame.Icon:SetSize(40, 40)
M.EnchantFrame.Icon:SetPoint("LEFT", 6, 0)
M.EnchantFrame.Icon:SetTexture("Interface\\Icons\\spell_frost_stun")
M.EnchantFrame.Icon:SetVertexColor(0.5, 0, 0.5, 0.5)

M.EnchantFrame.BreathTex = M.EnchantFrame:CreateTexture(nil, "OVERLAY")
M.EnchantFrame.BreathTex:SetSize(399, 399)
M.EnchantFrame.BreathTex:SetPoint("CENTER", M.EnchantFrame.Icon, 1, 0)
M.EnchantFrame.BreathTex:SetTexture(Addon.AwTexPath .. "EnchOverhaul\\BreathTexture")
M.EnchantFrame.BreathTex:SetAlpha(0)
M.EnchantFrame.BreathTex:Hide()
--M.EnchantFrame.BreathTex:SetBlendMode("ADD")

M.EnchantFrame.SlotButton = CreateFrame("Button", "$parentSlotButton", M.EnchantFrame, nil)
M.EnchantFrame.SlotButton:SetSize(46, 46)
M.EnchantFrame.SlotButton:SetHighlightTexture(Addon.AwTexPath .. "EnchOverhaul\\Slot2Selected")
M.EnchantFrame.SlotButton:SetPoint("CENTER", M.EnchantFrame.Icon, 0, 0)

M.EnchantFrame.EnchName = M.EnchantFrame:CreateFontString()
M.EnchantFrame.EnchName:SetFont("Fonts\\FRIZQT__.TTF", 12)
M.EnchantFrame.EnchName:SetFontObject(GameFontDisable)
M.EnchantFrame.EnchName:SetPoint("LEFT", M.EnchantFrame.SlotButton, "RIGHT", 6, 6)
M.EnchantFrame.EnchName:SetShadowOffset(1, -1)
M.EnchantFrame.EnchName:SetJustifyH("LEFT")
M.EnchantFrame.EnchName:SetWidth(160)
--M.EnchantFrame.EnchName:SetSize(200, 28)

M.EnchantFrame.ItemName = M.EnchantFrame:CreateFontString()
M.EnchantFrame.ItemName:SetFontObject(GameFontDisable)
M.EnchantFrame.ItemName:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.EnchantFrame.ItemName:SetPoint("TOP", M.EnchantFrame.EnchName, "BOTTOM", 0, -2)
M.EnchantFrame.ItemName:SetShadowOffset(1, -1)
M.EnchantFrame.ItemName:SetJustifyH("LEFT")
M.EnchantFrame.ItemName:SetJustifyV("TOP")
M.EnchantFrame.ItemName:SetSize(160, 14)

M.EnchantFrame.EnchName:SetText("Drag an item here")
-- M.EnchantFrame.ItemName:SetText("Use " .. MYSTIC_ENCHANTING_ALTAR)

M.EnchantFrame.Enchant = M:CollectionEnchantTemplate(M.EnchantFrame)
M.EnchantFrame.Enchant:SetPoint("RIGHT", M.EnchantFrame, -1, -1)
M.EnchantFrame.Enchant:SetSize(48, 48)
M.EnchantFrame.Enchant.Icon:SetSize(36, 36)
M.EnchantFrame.Enchant.Maxed:SetSize(48, 48)
M.EnchantFrame.Enchant:GetHighlightTexture():ClearAllPoints()
M.EnchantFrame.Enchant:GetHighlightTexture():SetSize(64, 64)
M.EnchantFrame.Enchant:GetHighlightTexture():SetPoint("CENTER", 0, 0)
M.EnchantFrame.Enchant:Hide()

M.EnchantFrame.SlotButton:SetScript("OnMouseDown", function(self)
    PlaceItem(self, false)
end)
M.EnchantFrame.SlotButton:SetScript("OnEnter", EnchantShowLink)
M.EnchantFrame.SlotButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
-------------------------------------------------------------------------------
--                                  Bottom                                   --
-------------------------------------------------------------------------------
M.ControlFrame = CreateFrame("FRAME", "$parentControlFrame", M, nil)
M.ControlFrame:SetPoint("TOP", M.EnchantFrame, "BOTTOM", 0, -1)
M.ControlFrame:SetSize(280, 28)

M.ControlFrame:SetScript("OnShow", function(self)
    self:RegisterEvent("BAG_UPDATE")
end)

M.ControlFrame:SetScript("OnHide", function(self)
    self:UnregisterEvent("BAG_UPDATE")
end)

M.ControlFrame:SetScript("OnEvent", UpdateMysticRuneBalance)
--M.ControlFrame:SetBackdrop(GameTooltip:GetBackdrop())

M.ControlFrame.ExtractButton = CreateFrame("Button", "$parentExtractButton", M.ControlFrame,
    "SecureActionButtonTemplate, UIPanelButtonTemplate")
M.ControlFrame.ExtractButton:SetWidth(80)
M.ControlFrame.ExtractButton:SetHeight(22)
M.ControlFrame.ExtractButton:SetPoint("RIGHT", -1, 1)
M.ControlFrame.ExtractButton:RegisterForClicks("AnyUp")
M.ControlFrame.ExtractButton:SetText("Extract")
M.ControlFrame.ExtractButton:SetMotionScriptsWhileDisabled(true)
M.ControlFrame.ExtractButton:SetScript("OnClick", PrepareDisenchant)
M.ControlFrame.ExtractButton:SetScript("OnShow", DisenchantButtonTokenCheck)
M.ControlFrame.ExtractButton:SetScript("OnEnter", EnchantShowDisenchantHint)
M.ControlFrame.ExtractButton:SetScript("Onleave", function()
    GameTooltip:Hide()
end)
M.ControlFrame.ExtractButton:Disable()


M.ControlFrame.RollButton = CreateFrame("Button", "$parentRollButton", M.ControlFrame,
    "SecureActionButtonTemplate, UIPanelButtonTemplate")
M.ControlFrame.RollButton:SetWidth(80)
M.ControlFrame.RollButton:SetHeight(22)
M.ControlFrame.RollButton:SetPoint("RIGHT", M.ControlFrame.ExtractButton, "LEFT", -3, 0)
M.ControlFrame.RollButton:RegisterForClicks("AnyUp")
M.ControlFrame.RollButton:SetText("Reforge")
M.ControlFrame.RollButton:Disable()
M.ControlFrame.RollButton:SetMotionScriptsWhileDisabled(true)
M.ControlFrame.RollButton:SetScript("OnClick", PrepareReforge)
M.ControlFrame.RollButton:SetScript("OnShow", RollButtonCheck)
M.ControlFrame.RollButton:SetScript("OnEnter", EnchantShowRollHint)
M.ControlFrame.RollButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-------------------------------------------------------------------------------
--                                Cost Frame                                 --
-------------------------------------------------------------------------------
M.ControlFrame.MoneyFrame = CreateFrame("FRAME", "$parentMoneyFrame", M.ControlFrame, "SmallMoneyFrameTemplate")
-- old wow ui stuff sucks
M.ControlFrame.MoneyFrame.CopperButton = _G[M.ControlFrame.MoneyFrame:GetName() .. "CopperButton"]
M.ControlFrame.MoneyFrame.SilverButton = _G[M.ControlFrame.MoneyFrame:GetName() .. "SilverButton"]
M.ControlFrame.MoneyFrame.GoldButton = _G[M.ControlFrame.MoneyFrame:GetName() .. "GoldButton"]
M.ControlFrame.MoneyFrame:SetPoint("RIGHT", M.ControlFrame.RollButton, "LEFT", -3, 0)
M.ControlFrame.MoneyFrame:SetSize(109, 28)
M.ControlFrame.MoneyFrame:Hide()

-- clear default settings
M.ControlFrame.MoneyFrame:SetScript("OnLoad", nil)
M.ControlFrame.MoneyFrame:SetScript("OnEvent", nil)
M.ControlFrame.MoneyFrame:SetScript("OnShow", nil)
M.ControlFrame.MoneyFrame:SetScript("OnHide", nil)
M.ControlFrame.MoneyFrame.CopperButton:SetScript("OnClick", nil)
M.ControlFrame.MoneyFrame.SilverButton:SetScript("OnClick", nil)
M.ControlFrame.MoneyFrame.GoldButton:SetScript("OnClick", nil)

M.ControlFrame.MoneyFrame.info = {
    truncateSmallCoins = true,
    collapse = 1,
    showSmallerCoins = "Backpack",
}

MoneyFrame_Update(M.ControlFrame.MoneyFrame, 0)

M.ControlFrame.TokenFrame = CreateFrame("FRAME", "$parentTokenFrame", M.ControlFrame)
M.ControlFrame.TokenFrame:SetPoint("RIGHT", M.ControlFrame.RollButton, "LEFT", -3, 0)
M.ControlFrame.TokenFrame:SetSize(109, 28)

M.ControlFrame.TokenFrame.TokenButton = CreateFrame("BUTTON", "$parentTokenButton", M.ControlFrame.TokenFrame)
M.ControlFrame.TokenFrame.TokenButton:SetSize(16, 16)
M.ControlFrame.TokenFrame.TokenButton:SetPoint("RIGHT", M.ControlFrame.TokenFrame, "RIGHT", -8, 0)
M.ControlFrame.TokenFrame.TokenButton.Item = ReforgeToken
M.ControlFrame.TokenFrame.TokenButton:SetScript("OnEnter", ItemButtonOnEnter)
M.ControlFrame.TokenFrame.TokenButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
M.ControlFrame.TokenFrame.TokenButton:SetScript("OnClick", ItemButtonOnClick)

M.ControlFrame.TokenFrame.TokenText = M.ControlFrame.TokenFrame:CreateFontString()
M.ControlFrame.TokenFrame.TokenText:SetFontObject(GameFontNormal)
--M.ControlFrame.TokenFrame.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
M.ControlFrame.TokenFrame.TokenText:SetPoint("RIGHT", M.ControlFrame.TokenFrame.TokenButton, "LEFT", -4, 0)
M.ControlFrame.TokenFrame.TokenText:SetText("Rune: |cffFFFFFF1000|r")
M.ControlFrame.TokenFrame.TokenText:SetJustifyH("LEFT")

M.ControlFrame.TokenFrame.TokenButton.Icon = M.ControlFrame.TokenFrame.TokenButton:CreateTexture(nil, "ARTWORK")
M.ControlFrame.TokenFrame.TokenButton.Icon:SetSize(12, 12)
M.ControlFrame.TokenFrame.TokenButton.Icon:SetPoint("CENTER", 0, 0)
M.ControlFrame.TokenFrame.TokenButton.Icon:SetTexture(ReforgeTokenTexture)
M.ControlFrame.TokenFrame:Hide()


M.ControlFrame.Currency = CreateFrame("FRAME", "$parentCurrency", M.ControlFrame)
M.ControlFrame.Currency:SetSize(M.ControlFrame:GetWidth(), 24)
M.ControlFrame.Currency:SetPoint("TOP", M.ControlFrame, "BOTTOM", 0, 0)

M.ControlFrame.Currency.BG_Left = M.ControlFrame.Currency:CreateTexture(nil, "BACKGROUND")
M.ControlFrame.Currency.BG_Left:SetSize(6, 24)
M.ControlFrame.Currency.BG_Left:SetPoint("LEFT", 0, 0)
M.ControlFrame.Currency.BG_Left:SetTexCoord(0.0, 0.01171875, 0.421875, 0.5625)
M.ControlFrame.Currency.BG_Left:SetTexture("Interface\\Buttons\\UI-Button-Borders2")
--M.ControlFrame.Currency.BG_Left:SetVertexColor(0, 1, 0)

M.ControlFrame.Currency.BG_Middle = M.ControlFrame.Currency:CreateTexture(nil, "BACKGROUND")
M.ControlFrame.Currency.BG_Middle:SetSize(M.ControlFrame.Currency:GetWidth() - 12, 24)
M.ControlFrame.Currency.BG_Middle:SetPoint("LEFT", M.ControlFrame.Currency.BG_Left, "RIGHT")
M.ControlFrame.Currency.BG_Middle:SetTexCoord(0.01171875, 0.3046875, 0.421875, 0.5625)
M.ControlFrame.Currency.BG_Middle:SetTexture("Interface\\Buttons\\UI-Button-Borders2")
--M.ControlFrame.Currency.BG_Middle:SetVertexColor(0, 1, 0)

M.ControlFrame.Currency.BG_Right = M.ControlFrame.Currency:CreateTexture(nil, "BACKGROUND")
M.ControlFrame.Currency.BG_Right:SetSize(6, 24)
M.ControlFrame.Currency.BG_Right:SetPoint("LEFT", M.ControlFrame.Currency.BG_Middle, "RIGHT")
M.ControlFrame.Currency.BG_Right:SetTexCoord(0.3046875, 0.31640625, 0.421875, 0.5625)
M.ControlFrame.Currency.BG_Right:SetTexture("Interface\\Buttons\\UI-Button-Borders2")
--frame.BG_Right:SetVertexColor(0, 1, 0)
-------------------------------------------------------------------------------
--                              Active Enchants                              --
-------------------------------------------------------------------------------
M.ControlFrame.Currency.ActiveText = M.ControlFrame.Currency:CreateFontString()
M.ControlFrame.Currency.ActiveText:SetFontObject(GameFontNormalSmall)
M.ControlFrame.Currency.ActiveText:SetPoint("LEFT", M.ControlFrame.Currency, "LEFT", 8, 1)
M.ControlFrame.Currency.ActiveText:SetJustifyH("LEFT")
-- M.ControlFrame.Currency.ActiveText:SetText(RARITY_SLOTS .. ": ")
M.ControlFrame.Currency.ActiveText:Hide()

M.ControlFrame.Currency.TotalLeg = ActiveEffectButtonTemplate(M.ControlFrame.Currency)
M.ControlFrame.Currency.TotalLeg:SetPoint("LEFT", M.ControlFrame.Currency.ActiveText, "RIGHT", 16, 0)
M.ControlFrame.Currency.TotalLeg.text:SetPoint("LEFT", M.ControlFrame.Currency.ActiveText, "RIGHT", 2, 0)
M.ControlFrame.Currency.TotalLeg.total = 1
M.ControlFrame.Currency.TotalLeg.quality = 5
M.ControlFrame.Currency.TotalLeg.tooltip = "Legendary"
M.ControlFrame.Currency.TotalLeg.UpdateText()
M.ControlFrame.Currency.TotalLeg.btn:SetNormalTexture(Addon.AwTexPath .. "EnchOverhaul\\QualityLegLight")
M.ControlFrame.Currency.TotalLeg.btn:SetHighlightTexture(Addon.AwTexPath .. "EnchOverhaul\\QualityLegLight")

M.ControlFrame.Currency.TotalEpic = ActiveEffectButtonTemplate(M.ControlFrame.Currency)
M.ControlFrame.Currency.TotalEpic:SetPoint("LEFT", M.ControlFrame.Currency.TotalLeg.btn, "RIGHT", -4, 0)
M.ControlFrame.Currency.TotalEpic.text:SetPoint("LEFT", M.ControlFrame.Currency.TotalLeg.btn, "RIGHT", -4, 0)
M.ControlFrame.Currency.TotalEpic.total = 3
M.ControlFrame.Currency.TotalEpic.quality = 4
M.ControlFrame.Currency.TotalEpic.tooltip = "Epic"
M.ControlFrame.Currency.TotalEpic.UpdateText()

M.ControlFrame.Currency.TotalLeg:Hide()
M.ControlFrame.Currency.TotalEpic:Hide()

M.ControlFrame.Currency.TotalRare = ActiveEffectButtonTemplate(M.ControlFrame.Currency)
M.ControlFrame.Currency.TotalRare:SetPoint("LEFT", M.ControlFrame.Currency.TotalEpic.btn, "RIGHT", -4, 0)
M.ControlFrame.Currency.TotalRare.text:SetPoint("LEFT", M.ControlFrame.Currency.TotalEpic.btn, "RIGHT", -4, 0)
M.ControlFrame.Currency.TotalRare.total = 13
M.ControlFrame.Currency.TotalRare.active = 13
M.ControlFrame.Currency.TotalRare.quality = 3
M.ControlFrame.Currency.TotalRare.tooltip = "Rare/|cff00FF00Uncommon|r"
M.ControlFrame.Currency.TotalRare.UpdateText()

M.ControlFrame.Currency.TotalRare.btn:SetNormalTexture(Addon.AwTexPath .. "EnchOverhaul\\QualityRareLight")
M.ControlFrame.Currency.TotalRare.btn:SetHighlightTexture(Addon.AwTexPath .. "EnchOverhaul\\QualityRareLight")
M.ControlFrame.Currency.TotalRare:Hide()
-- mystic Extract
M.ControlFrame.Currency.ExtractButton = CreateFrame("BUTTON", "$parentExtractButton", M.ControlFrame.Currency)
M.ControlFrame.Currency.ExtractButton:SetSize(14, 14)
M.ControlFrame.Currency.ExtractButton:SetPoint("RIGHT", -4, 0)
M.ControlFrame.Currency.ExtractButton.Item = ReforgeExtract
M.ControlFrame.Currency.ExtractButton:SetScript("OnEnter", ItemButtonOnEnter)
M.ControlFrame.Currency.ExtractButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
M.ControlFrame.Currency.ExtractButton:SetScript("OnClick", ItemButtonOnClick)

M.ControlFrame.Currency.ExtractButton.Icon = M.ControlFrame.Currency.ExtractButton:CreateTexture(nil, "ARTWORK")
M.ControlFrame.Currency.ExtractButton.Icon:SetAllPoints()
M.ControlFrame.Currency.ExtractButton.Icon:SetTexture(ReforgeExtractTexture)

M.ControlFrame.Currency.ExtractText = M.ControlFrame.Currency:CreateFontString()
M.ControlFrame.Currency.ExtractText:SetFontObject(GameFontNormalSmall)
--M.ControlFrame.Currency.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
M.ControlFrame.Currency.ExtractText:SetPoint("RIGHT", M.ControlFrame.Currency.ExtractButton, "LEFT", -4, 0)
M.ControlFrame.Currency.ExtractText:SetText("Extract: |cffFFFFFF1000|r")
M.ControlFrame.Currency.ExtractText:SetJustifyH("RIGHT")

M.ControlFrame.Currency.TokenButton = CreateFrame("BUTTON", "$parentTokenButton", M.ControlFrame.Currency)
M.ControlFrame.Currency.TokenButton:SetSize(14, 14)
M.ControlFrame.Currency.TokenButton:SetPoint("RIGHT", M.ControlFrame.Currency.ExtractText, "LEFT", -8, 0)
M.ControlFrame.Currency.TokenButton.Item = ReforgeToken
M.ControlFrame.Currency.TokenButton:SetScript("OnEnter", ItemButtonOnEnter)
M.ControlFrame.Currency.TokenButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
M.ControlFrame.Currency.TokenButton:SetScript("OnClick", ItemButtonOnClick)

M.ControlFrame.Currency.TokenButton.Icon = M.ControlFrame.Currency.TokenButton:CreateTexture(nil, "ARTWORK")
M.ControlFrame.Currency.TokenButton.Icon:SetAllPoints()
M.ControlFrame.Currency.TokenButton.Icon:SetTexture(ReforgeTokenTexture)

M.ControlFrame.Currency.TokenText = M.ControlFrame.Currency:CreateFontString()
M.ControlFrame.Currency.TokenText:SetFontObject(GameFontNormalSmall)
M.ControlFrame.Currency.TokenText:SetPoint("RIGHT", M.ControlFrame.Currency.TokenButton, "LEFT", -4, 0)
M.ControlFrame.Currency.TokenText:SetText("Rune: |cffFFFFFF1000|r")
M.ControlFrame.Currency.TokenText:SetJustifyH("LEFT")

M.EnchantLimits = CreateFrame("FRAME", "M.EnchantLimits", M) -- TODO: Make rarities localized string from items
M.EnchantLimits:SetSize(310, 36)
M.EnchantLimits:SetPoint("LEFT", M.ControlFrame.Currency, "RIGHT", 2, 2)

M.EnchantLimits.Legendary = RarityBarTemplate(M.EnchantLimits, 5)
M.EnchantLimits.Legendary:SetPoint("LEFT", M.EnchantLimits, 0, 0)
M.EnchantLimits.Legendary.total = 1
M.EnchantLimits.Legendary.active = 0
M.EnchantLimits.Legendary:SetVertexColor(1.00, 0.50, 0.00)
M.EnchantLimits.Legendary.TextL:SetText("|cffff8000" .. ITEM_QUALITY5_DESC .. " " .. ENCHANTS .. "|r")
--M.EnchantLimits.Legendary:SetBackdrop(GameTooltip:GetBackdrop())
M.EnchantLimits.Legendary:SetWidth(M.EnchantLimits.Legendary:GetWidth() - 2)
-- MagicButton_OnLoad(M.EnchantLimits.Legendary)

M.EnchantLimits.Epic = RarityBarTemplate(M.EnchantLimits, 4)
M.EnchantLimits.Epic:SetPoint("LEFT", M.EnchantLimits.Legendary, "RIGHT", 0, 0)
M.EnchantLimits.Epic.total = 3
M.EnchantLimits.Epic.active = 0
M.EnchantLimits.Epic:SetVertexColor(0.64, 0.21, 0.93)
M.EnchantLimits.Epic.TextL:SetText("|cffa335ee" .. ITEM_QUALITY4_DESC .. " " .. ENCHANTS .. "|r")
--M.EnchantLimits.Epic:SetBackdrop(GameTooltip:GetBackdrop())
-- MagicButton_OnLoad(M.EnchantLimits.Epic)

M.EnchantLimits.bars = {
    M.EnchantLimits.Legendary,
    M.EnchantLimits.Epic,
}

function M.EnchantLimits:UpdateValues()
    for _, bar in pairs(M.EnchantLimits.bars) do
        bar:RefreshValue()
    end
end

M.EnchantLimits:UpdateValues()

-------------------------------------------------------------------------------
--                               Cast bar menu                               --
-------------------------------------------------------------------------------
local spellNameEnchanting = GetSpellInfo(964998)

local function CastingBarFrame_OnEvent_Enchants(self, event, ...)
    local arg1 = ...;

    local unit = "player";
    if (event == "PLAYER_ENTERING_WORLD") then
        local nameSpell = UnitCastingInfo(unit);

        if (nameSpell) then
            event = "UNIT_SPELLCAST_START";
            arg1 = unit;
        else
            CastingBarFrame_FinishSpell(self);
        end
    end

    if (arg1 ~= unit) then
        return;
    end

    local selfName = self:GetName();
    local barSpark = _G[selfName .. "Spark"];
    local barText = _G[selfName .. "Text"];
    local barFlash = _G[selfName .. "Flash"];
    local barIcon = _G[selfName .. "Icon"];
    local barBorder = _G[selfName .. "Border"];
    local barBorderShield = _G[selfName .. "BorderShield"];
    if (event == "UNIT_SPELLCAST_START") then
        local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible =
            UnitCastingInfo(unit);

        if not (name) or (not (M.Manager.SavePresetSpellNames[name]) and not (M.Manager.LoadPresetSpellNames[name]) and not (name == spellNameEnchanting)) then
            self:Hide();
            return;
        end

        self:ClearAllPoints()

        if name == spellNameEnchanting then
            self:SetPoint("CENTER", M.EnchantFrame, 0, 48)
        else
            self:SetPoint("CENTER", M, 0, 0)
        end

        self:SetStatusBarColor(1.0, 1, 1);
        if (barSpark) then
            barSpark:Show();
        end
        self.value = (GetTime() - (startTime / 1000));
        self.maxValue = (endTime - startTime) / 1000;
        self:SetMinMaxValues(0, self.maxValue);
        self:SetValue(self.value);
        if (barText) then
            barText:SetText(text);
        end
        if (barIcon) then
            barIcon:SetTexture(texture);
        end
        self:SetAlpha(1.0);
        self.holdTime = 0;
        self.casting = 1;
        self.castID = castID;
        self.channeling = nil;
        self.fadeOut = nil;
        if (barBorderShield) then
            if (self.showShield and notInterruptible) then
                barBorderShield:Show();
                if (barBorder) then
                    barBorder:Hide();
                end
            else
                barBorderShield:Hide();
                if (barBorder) then
                    barBorder:Show();
                end
            end
        end
        if (self.showCastbar) then
            self:Show();
        end
    elseif (event == "UNIT_SPELLCAST_STOP") then
        if (not self:IsVisible()) then
            self:Hide();
        end
        if ((self.casting and event == "UNIT_SPELLCAST_STOP" and select(4, ...) == self.castID)) then
            if (barSpark) then
                barSpark:Hide();
            end
            if (barFlash) then
                barFlash:SetAlpha(0.0);
                barFlash:Show();
            end
            self:SetValue(self.maxValue);
            if (event == "UNIT_SPELLCAST_STOP") then
                self.casting = nil;
                self:SetStatusBarColor(1, 1.0, 1);
            else
                self.channeling = nil;
            end
            self.flash = 1;
            self.fadeOut = 1;
            self.holdTime = 0;
        end
    elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") then
        if (self:IsShown() and
                (self.casting and select(4, ...) == self.castID) and not self.fadeOut) then
            self:SetValue(self.maxValue);
            self:SetStatusBarColor(1.0, 0.0, 0.0);
            if (barSpark) then
                barSpark:Hide();
            end
            if (barText) then
                if (event == "UNIT_SPELLCAST_FAILED") then
                    barText:SetText(FAILED);
                else
                    barText:SetText(INTERRUPTED);
                end
            end
            self.casting = nil;
            self.channeling = nil;
            self.fadeOut = 1;
            self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
        end
    elseif (event == "UNIT_SPELLCAST_DELAYED") then
        if (self:IsShown()) then
            local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
            if not (name) or (not (M.Manager.SavePresetSpellNames[name]) and not (M.Manager.LoadPresetSpellNames[name]) and not (name == spellNameEnchanting)) then
                -- if there is no name, there is no bar
                self:Hide();
                return;
            end

            self:ClearAllPoints()

            if name == spellNameEnchanting then
                self:SetPoint("CENTER", M.EnchantFrame, 0, 48)
            else
                self:SetPoint("CENTER", M, 0, 0)
            end

            self.value = (GetTime() - (startTime / 1000));
            self.maxValue = (endTime - startTime) / 1000;
            self:SetMinMaxValues(0, self.maxValue);
            if (not self.casting) then
                self:SetStatusBarColor(1, 1, 1);
                if (barSpark) then
                    barSpark:Show();
                end
                if (barFlash) then
                    barFlash:SetAlpha(0.0);
                    barFlash:Hide();
                end
                self.casting = 1;
                self.channeling = nil;
                self.flash = 0;
                self.fadeOut = 0;
            end
        end
    end
end

local function CastingBarFrame_OnLoad_Enchants(self, unit, showTradeSkills, showShield)
    self:RegisterEvent("UNIT_SPELLCAST_START");
    self:RegisterEvent("UNIT_SPELLCAST_STOP");
    self:RegisterEvent("UNIT_SPELLCAST_FAILED");
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
    self:RegisterEvent("UNIT_SPELLCAST_DELAYED");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");

    self.unit = unit;
    self.showTradeSkills = false;
    self.showShield = false;
    self.casting = nil;
    self.channeling = nil;
    self.holdTime = 0;
    self.showCastbar = true;

    local barIcon = _G[self:GetName() .. "Icon"];
    if (barIcon) then
        barIcon:Hide();
    end
end

M.CastBar = CreateFrame("StatusBar", "$parent.CastBar", M, "CastingBarFrameTemplate")
M.CastBar:SetPoint("CENTER", 0, 0)
M.CastBar:SetFrameLevel(10)
M.CastBar:SetSize(195, 13)
M.CastBar:SetStatusBarTexture(Addon.AwTexPath .. "Collections\\CollectionsBarEnchants")
M.CastBar:SetStatusBarColor(1, 1, 1, 1)
M.CastBar:SetScript("OnEvent", CastingBarFrame_OnEvent_Enchants)
M.CastBar:SetScript("OnLoad", CastingBarFrame_OnLoad_Enchants)
M.CastBar:Hide()

M.CastBar.BackgroundTexture = M.CastBar:CreateTexture(nil, "BACKGROUND")
M.CastBar.BackgroundTexture:SetSize(390, 96)
M.CastBar.BackgroundTexture:SetTexture(Addon.AwTexPath .. "Collections\\Shadow")
M.CastBar.BackgroundTexture:SetPoint("CENTER", 0, 0)
-------------------------------------------------------------------------------
--                             New Enchant Menu                              --
-------------------------------------------------------------------------------
M.CollectionsList.AnimationBackground = CreateFrame("FRAME", "$parentAnimationBackground", M.CollectionsList, nil)
M.CollectionsList.AnimationBackground:SetPoint("CENTER", M.CollectionsList, 0, 0)
M.CollectionsList.AnimationBackground:SetSize(512, 512)
M.CollectionsList.AnimationBackground:SetFrameLevel(7)
M.CollectionsList.AnimationBackground:Hide()

M.CollectionsList.AnimationBackground.BackgroundTexture = M.CollectionsList.AnimationBackground:CreateTexture(nil,
    "BACKGROUND")
M.CollectionsList.AnimationBackground.BackgroundTexture:SetSize(512, 512)
M.CollectionsList.AnimationBackground.BackgroundTexture:SetTexture(Addon.AwTexPath .. "Collections\\Shadow")
M.CollectionsList.AnimationBackground.BackgroundTexture:SetPoint("CENTER", 0, 0)

M.CollectionsList.AnimationBackground.HighLightOfNewItem = CreateFrame("FRAME", "$parentHighlightOfNewItem",
    M.CollectionsList.AnimationBackground, nil)
M.CollectionsList.AnimationBackground.HighLightOfNewItem:SetPoint("CENTER", M.CollectionsList.AnimationBackground, -67, 0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem:SetSize(256, 256)
M.CollectionsList.AnimationBackground.HighLightOfNewItem:SetFrameLevel(7)

M.CollectionsList.AnimationBackground.HighLightOfNewItem.HighlightTex = M.CollectionsList.AnimationBackground
    .HighLightOfNewItem:CreateTexture(nil, "ARTWORK")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.HighlightTex:SetSize(256, 256)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.HighlightTex:SetTexture(Addon.AwTexPath ..
    "Collections\\DragonHighlight")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.HighlightTex:SetPoint("CENTER", 0, 0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.HighlightTex:SetBlendMode("ADD")

M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow = CreateFrame("Model", "$parentGlow",
    M.CollectionsList.AnimationBackground.HighLightOfNewItem)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetWidth(256);
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetHeight(256);
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetPoint("CENTER", 5, -10)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetModel(
    "World\\Kalimdor\\silithus\\passivedoodads\\ahnqirajglow\\quirajglow.m2")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetModelScale(0.02)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetCamera(0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetPosition(0.075, 0.09, 0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetFacing(0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetFrameLevel(7)

M.CollectionsList.NewEnchantInCollection = CreateFrame("FRAME", "$parentNewEnchantInCollection", M.CollectionsList, nil)
M.CollectionsList.NewEnchantInCollection:SetPoint("CENTER", M.CollectionsList, -10, -10)
M.CollectionsList.NewEnchantInCollection:SetSize(128, 64)
M.CollectionsList.NewEnchantInCollection:SetFrameLevel(8)
M.CollectionsList.NewEnchantInCollection:EnableMouse(true)
M.CollectionsList.NewEnchantInCollection:SetAlpha(0)
M.CollectionsList.NewEnchantInCollection:Hide()

M.CollectionsList.NewEnchantInCollection:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" then
        M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:Stop()
        M.CollectionsList.NewEnchantInCollection.AnimationGroup:Stop()
    end
end)

M.CollectionsList.NewEnchantInCollection.BackgroundTexture = M.CollectionsList.NewEnchantInCollection:CreateTexture(nil,
    "BACKGROUND")
M.CollectionsList.NewEnchantInCollection.BackgroundTexture:SetSize(39, 39)
M.CollectionsList.NewEnchantInCollection.BackgroundTexture:SetTexture("Interface\\Icons\\INV_Chest_Samurai")
M.CollectionsList.NewEnchantInCollection.BackgroundTexture:SetPoint("LEFT", M.CollectionsList.NewEnchantInCollection, -10,
    -1)

M.CollectionsList.NewEnchantInCollection.Texture = M.CollectionsList.NewEnchantInCollection:CreateTexture(nil, "OVERLAY")
M.CollectionsList.NewEnchantInCollection.Texture:SetSize(200, 100)
M.CollectionsList.NewEnchantInCollection.Texture:SetTexture(Addon.AwTexPath .. "Collections\\NewEnchantUnlocked")
M.CollectionsList.NewEnchantInCollection.Texture:SetPoint("CENTER", 0, 0)

M.CollectionsList.NewEnchantInCollection.TextNormal = M.CollectionsList.NewEnchantInCollection:CreateFontString(nil,
    "OVERLAY")
M.CollectionsList.NewEnchantInCollection.TextNormal:SetSize(90, 20)
M.CollectionsList.NewEnchantInCollection.TextNormal:SetFont("Fonts\\FRIZQT__.TTF", 12)
M.CollectionsList.NewEnchantInCollection.TextNormal:SetFontObject(GameFontNormal)
M.CollectionsList.NewEnchantInCollection.TextNormal:SetPoint("CENTER", 15, 0)
M.CollectionsList.NewEnchantInCollection.TextNormal:SetShadowOffset(0, -1)
M.CollectionsList.NewEnchantInCollection.TextNormal:SetText("Enchant Effect Name")

M.CollectionsList.NewEnchantInCollection.TextAdd = M.CollectionsList.NewEnchantInCollection:CreateFontString(nil,
    "OVERLAY")
M.CollectionsList.NewEnchantInCollection.TextAdd:SetSize(300, 20)
M.CollectionsList.NewEnchantInCollection.TextAdd:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.CollectionsList.NewEnchantInCollection.TextAdd:SetFontObject(GameFontNormal)
M.CollectionsList.NewEnchantInCollection.TextAdd:SetPoint("BOTTOM", 0, -20)
M.CollectionsList.NewEnchantInCollection.TextAdd:SetShadowOffset(0, -1)
M.CollectionsList.NewEnchantInCollection.TextAdd:SetText("|cffFFFFFFYou have successfuly unlocked|r!")
-------------------------------------------------------------------------------
--                           Place item animation                            --
-------------------------------------------------------------------------------
M.EnchantFrame.BGHighlight.AG = M.EnchantFrame.BGHighlight:CreateAnimationGroup()

M.EnchantFrame.BGHighlight.AG.Alpha0 = M.EnchantFrame.BGHighlight.AG:CreateAnimation("Alpha")
M.EnchantFrame.BGHighlight.AG.Alpha0:SetStartDelay(0)
M.EnchantFrame.BGHighlight.AG.Alpha0:SetDuration(0.4)
M.EnchantFrame.BGHighlight.AG.Alpha0:SetOrder(0)
M.EnchantFrame.BGHighlight.AG.Alpha0:SetEndDelay(0)
M.EnchantFrame.BGHighlight.AG.Alpha0:SetSmoothing("IN")
M.EnchantFrame.BGHighlight.AG.Alpha0:SetChange(1)

M.EnchantFrame.BGHighlight.AG.Alpha1 = M.EnchantFrame.BGHighlight.AG:CreateAnimation("Alpha")
M.EnchantFrame.BGHighlight.AG.Alpha1:SetStartDelay(0)
M.EnchantFrame.BGHighlight.AG.Alpha1:SetDuration(1)
M.EnchantFrame.BGHighlight.AG.Alpha1:SetOrder(0)
M.EnchantFrame.BGHighlight.AG.Alpha1:SetEndDelay(0)
M.EnchantFrame.BGHighlight.AG.Alpha1:SetSmoothing("IN_OUT")
M.EnchantFrame.BGHighlight.AG.Alpha1:SetChange(-1)

-- constant animation of inactive label to attract player's attention to it
M.EnchantFrame.BreathTex.AG = M.EnchantFrame.BreathTex:CreateAnimationGroup()

M.EnchantFrame.BreathTex.AG.Alpha0 = M.EnchantFrame.BreathTex.AG:CreateAnimation("Alpha")
M.EnchantFrame.BreathTex.AG.Alpha0:SetStartDelay(0.5)
M.EnchantFrame.BreathTex.AG.Alpha0:SetDuration(0.5)
M.EnchantFrame.BreathTex.AG.Alpha0:SetOrder(1)
M.EnchantFrame.BreathTex.AG.Alpha0:SetEndDelay(0)
M.EnchantFrame.BreathTex.AG.Alpha0:SetSmoothing("IN")
M.EnchantFrame.BreathTex.AG.Alpha0:SetChange(1)

M.EnchantFrame.BreathTex.AG.Alpha1 = M.EnchantFrame.BreathTex.AG:CreateAnimation("Alpha")
M.EnchantFrame.BreathTex.AG.Alpha1:SetStartDelay(0)
M.EnchantFrame.BreathTex.AG.Alpha1:SetDuration(2)
M.EnchantFrame.BreathTex.AG.Alpha1:SetOrder(2)
M.EnchantFrame.BreathTex.AG.Alpha1:SetEndDelay(2)
M.EnchantFrame.BreathTex.AG.Alpha1:SetSmoothing("IN_OUT")
M.EnchantFrame.BreathTex.AG.Alpha1:SetChange(-1)

M.EnchantFrame.BreathTex.AG:SetScript("OnFinished", function()
    M.EnchantFrame.BreathTex.AG:Play()
end)

M.EnchantFrame.BreathTex.AG:Play()
-------------------------------------------------------------------------------
--                     New enchant unlocked animations                       --
-------------------------------------------------------------------------------
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup = M.CollectionsList.AnimationBackground
    .HighLightOfNewItem:CreateAnimationGroup()
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation = M.CollectionsList.AnimationBackground
    .HighLightOfNewItem.AnimationGroup:CreateAnimation("Rotation")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetStartDelay(0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetDuration(6)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetOrder(1)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetEndDelay(0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetSmoothing("NONE")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetDegrees(90)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetScript("OnPlay", function()
    Addon:BaseFrameFadeIn(M.CollectionsList.AnimationBackground)
end)

M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut = M.CollectionsList
    .AnimationBackground.HighLightOfNewItem.AnimationGroup:CreateAnimation("Alpha")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetStartDelay(0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetDuration(3)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetOrder(2)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetEndDelay(0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetSmoothing("NONE")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetChange(-1)

M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:SetScript("OnStop", function()
    M.CollectionsList.AnimationBackground:Hide()
end)

M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:SetScript("OnFinished", function()
    M.CollectionsList.AnimationBackground:Hide()
end)


M.CollectionsList.NewEnchantInCollection.AnimationGroup = M.CollectionsList.NewEnchantInCollection:CreateAnimationGroup()
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha = M.CollectionsList.NewEnchantInCollection.AnimationGroup
    :CreateAnimation("Alpha")
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetStartDelay(0)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetDuration(1)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetOrder(1)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetEndDelay(5)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetSmoothing("NONE")
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetChange(1)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetScript("OnPlay", function()
    PlaySound("igQuestListComplete")
    M.CollectionsList.NewEnchantInCollection:Show()
    M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:Play()
end)

M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut = M.CollectionsList.NewEnchantInCollection
    .AnimationGroup:CreateAnimation("Alpha")
M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut:SetStartDelay(0)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut:SetDuration(3)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut:SetOrder(2)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut:SetEndDelay(0)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut:SetSmoothing("NONE")
M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut:SetChange(-1)

M.CollectionsList.NewEnchantInCollection.AnimationGroup:SetScript("OnStop", function()
    M.CollectionsList.NewEnchantInCollection:Hide()
    M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:Finish()
end)

M.CollectionsList.NewEnchantInCollection.AnimationGroup:SetScript("OnFinished", function()
    M.CollectionsList.NewEnchantInCollection:Hide()
    M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:Finish()
end)
-------------------------------------------------------------------------------
--                     Disenchant Confirm Dialog Frame                       --
-------------------------------------------------------------------------------
M.ConfirmDisenchant = CreateFrame("Frame", "$parentConfirmDisenchant", M)
M.ConfirmDisenchant:ClearAllPoints()
M.ConfirmDisenchant:SetBackdrop(StaticPopup1:GetBackdrop())
M.ConfirmDisenchant:SetHeight(115)
M.ConfirmDisenchant:SetWidth(390)
M.ConfirmDisenchant:SetPoint("CENTER", M, 0, 0)
M.ConfirmDisenchant:SetFrameLevel(10)
M.ConfirmDisenchant:EnableMouse(true)
M.ConfirmDisenchant:Hide()

M.ConfirmDisenchant.Mode = "DISENCHANT"

M.ConfirmDisenchant.text = M.ConfirmDisenchant:CreateFontString(nil, "BORDER", "GameFontHighlight")
M.ConfirmDisenchant.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.ConfirmDisenchant.text:SetFontObject(GameFontNormal)
M.ConfirmDisenchant.text:SetText("Are you sure that you want\nto disenchant following item:\n\nITEMLINK")
M.ConfirmDisenchant.text:SetPoint("TOP", 0, -20)

M.ConfirmDisenchant.currencyText = M.ConfirmDisenchant:CreateFontString(nil, "BORDER", "GameFontHighlight")
M.ConfirmDisenchant.currencyText:SetFont("Fonts\\FRIZQT__.TTF", 14)
M.ConfirmDisenchant.currencyText:SetFontObject(GameFontNormal)
M.ConfirmDisenchant.currencyText:SetText("")
M.ConfirmDisenchant.currencyText:SetPoint("TOP", M.ConfirmDisenchant.text, "BOTTOM", 0, -5)

M.ConfirmDisenchant.confirmText = M.ConfirmDisenchant:CreateFontString(nil, "BORDER", "GameFontHighlight")
M.ConfirmDisenchant.confirmText:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.ConfirmDisenchant.confirmText:SetFontObject(GameFontNormal)
M.ConfirmDisenchant.confirmText:SetText("")
M.ConfirmDisenchant.confirmText:SetPoint("TOP", M.ConfirmDisenchant.currencyText, "BOTTOM", 0, -10)

M.ConfirmDisenchant.Alert = M.ConfirmDisenchant:CreateTexture()
M.ConfirmDisenchant.Alert:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
M.ConfirmDisenchant.Alert:SetSize(48, 48)
M.ConfirmDisenchant.Alert:SetPoint("LEFT", 24, 0)

M.ConfirmDisenchant.Yes = CreateFrame("Button", "$parentYes", M.ConfirmDisenchant, "StaticPopupButtonTemplate")
M.ConfirmDisenchant.Yes:SetWidth(110)
M.ConfirmDisenchant.Yes:SetHeight(19)
M.ConfirmDisenchant.Yes:SetPoint("BOTTOM", -60, 15)
M.ConfirmDisenchant.Yes:SetScript("OnClick", function()
    DisenchantItem()
    M.ConfirmDisenchant:Hide()
end)

M.ConfirmDisenchant.No = CreateFrame("Button", "$parentNo", M.ConfirmDisenchant, "StaticPopupButtonTemplate")
M.ConfirmDisenchant.No:SetWidth(110)
M.ConfirmDisenchant.No:SetHeight(19)
M.ConfirmDisenchant.No:SetPoint("BOTTOM", 60, 15)
M.ConfirmDisenchant.No:SetScript("OnClick", function()
    M.ConfirmDisenchant:Hide()
end)

M.ConfirmDisenchant.Yes.text = M.ConfirmDisenchant.Yes:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
M.ConfirmDisenchant.Yes.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.ConfirmDisenchant.Yes.text:SetText("Accept")
M.ConfirmDisenchant.Yes.text:SetPoint("CENTER", 0, 1)

M.ConfirmDisenchant.No.text = M.ConfirmDisenchant.No:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
M.ConfirmDisenchant.No.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.ConfirmDisenchant.No.text:SetText("Cancel")
M.ConfirmDisenchant.No.text:SetPoint("CENTER", 0, 1)

M.ConfirmDisenchant.Yes:SetFontString(M.ConfirmDisenchant.Yes.text)
M.ConfirmDisenchant.No:SetFontString(M.ConfirmDisenchant.No.text)

M.ConfirmDisenchant.Enchant = M:CollectionEnchantTemplate(M.ConfirmDisenchant)
M.ConfirmDisenchant.Enchant:SetPoint("BOTTOMRIGHT", M.ConfirmDisenchant.Alert, 14, -16)
M.ConfirmDisenchant.Enchant:SetSize(48, 48)
M.ConfirmDisenchant.Enchant.Icon:SetSize(36, 36)
M.ConfirmDisenchant.Enchant.Maxed:SetSize(48, 48)
M.ConfirmDisenchant.Enchant:GetHighlightTexture():ClearAllPoints()
M.ConfirmDisenchant.Enchant:GetHighlightTexture():SetSize(64, 64)
M.ConfirmDisenchant.Enchant:GetHighlightTexture():SetPoint("CENTER", 0, 0)


M.ConfirmDisenchant:SetScript("OnShow", function(self)
    PlaySound("igMainMenuOpen")
    if (self.Mode == "DISENCHANT") then
        M.ConfirmDisenchant.Yes:SetScript("OnClick", function()
            PlaySound("igMainMenuOptionCheckBoxOn")
            DisenchantItem()
            M.ConfirmDisenchant:Hide()
        end)
    elseif (self.Mode == "COLLECTIONREFORGE") then
        M.ConfirmDisenchant.Yes:SetScript("OnClick", function()
            CollectionReforge()
            M.ConfirmDisenchant:Hide()
        end)
    elseif (self.Mode == "REFUND") then
        M.ConfirmDisenchant.Yes:SetScript("OnClick", function()
            PlaySound("igMainMenuOptionCheckBoxOn")
            RefundEnchant()
            M.ConfirmDisenchant:Hide()
        end)
    end
end)
M.ConfirmDisenchant:SetScript("OnHide", function(self)
    if M.IsTryingToCast then
        ClearControlFrame()
        M.IsTryingToCast = false
    end
    PlaySound("igMainMenuClose")
end)
-------------------------------------------------------------------------------
--                            Paper Doll Changes                             --
-------------------------------------------------------------------------------

local PaperDollEnchantHandlerFrame = CreateFrame("FRAME")
PaperDollEnchantHandlerFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
PaperDollEnchantHandlerFrame:SetScript("OnEvent", function()
    UpdatePaperDoll()
end)

for i, parent in pairs(ParentButtons) do
    _G["EnchantStackDisplayButton" .. i] = CreateFrame("Button", "EnchantStackDisplayButton" .. i, parent, nil)
    _G["EnchantStackDisplayButton" .. i]:SetSize(24, 24)
    _G["EnchantStackDisplayButton" .. i]:SetPoint("BOTTOMRIGHT", 4, -4)
    _G["EnchantStackDisplayButton" .. i]:EnableMouse(true)
    _G["EnchantStackDisplayButton" .. i]:SetNormalTexture(Addon.AwTexPath .. "enchant\\EnchantBorder")
    _G["EnchantStackDisplayButton" .. i]:SetHighlightTexture(Addon.AwTexPath .. "enchant\\EnchantBorder_highlight")
    _G["EnchantStackDisplayButton" .. i]:GetHighlightTexture():ClearAllPoints()
    _G["EnchantStackDisplayButton" .. i]:GetHighlightTexture():SetSize(32, 32)
    _G["EnchantStackDisplayButton" .. i]:GetHighlightTexture():SetPoint("CENTER", 0, 0)

    _G["EnchantStackDisplayButton" .. i].Icon = _G["EnchantStackDisplayButton" .. i]:CreateTexture(nil, "BORDER", nil, 10)
    _G["EnchantStackDisplayButton" .. i].Icon:SetSize(18, 18)
    SetPortraitToTexture(_G["EnchantStackDisplayButton" .. i].Icon, "Interface\\Icons\\inv_chest_samurai")
    _G["EnchantStackDisplayButton" .. i].Icon:SetPoint("CENTER", 0, 0)

    _G["EnchantStackDisplayButton" .. i].Maxed = _G["EnchantStackDisplayButton" .. i]:CreateTexture(nil, "OVERLAY", nil,
        10)
    _G["EnchantStackDisplayButton" .. i].Maxed:SetSize(18, 18)
    _G["EnchantStackDisplayButton" .. i].Maxed:SetPoint("CENTER", 0, 0)
    _G["EnchantStackDisplayButton" .. i].Maxed:SetTexture(Addon.AwTexPath .. "enchant\\RedSign")

    _G["EnchantStackDisplayButton" .. i]:SetScript("OnEnter", StackDisplayOnEnter)

    _G["EnchantStackDisplayButton" .. i]:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    _G["EnchantStackDisplayButton" .. i]:SetScript("OnClick", function(self, button)
        if (IsModifiedClick()) then
            EnchantStackDisplayButton_OnModifiedClick(self, button);
        end
    end)

    _G["EnchantStackDisplayButton" .. i]:Hide()
end

-------------------------------------------------------------------------------
--                               Refund Thing                                --
-------------------------------------------------------------------------------
M.EnchantFrame.Enchant.Refund = CreateFrame("BUTTON", "$parentRefund", M.EnchantFrame.Enchant)
M.EnchantFrame.Enchant.Refund:Hide()
M.EnchantFrame.Enchant.Refund:SetPoint("LEFT", M.EnchantFrame.Enchant, "RIGHT", -8, 0)
M.EnchantFrame.Enchant.Refund:SetSize(24, 24)
M.EnchantFrame.Enchant.Refund:SetNormalTexture(Addon.AwTexPath .. "EnchOverhaul\\QuestionMark")
M.EnchantFrame.Enchant.Refund:SetHighlightTexture(Addon.AwTexPath .. "EnchOverhaul\\QuestionMark")
M.EnchantFrame.Enchant.Refund:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("|cffFFFFFFOops, seems like we changed that enchant!|r")
    GameTooltip:AddLine("You can exchange the enchant on this item to equal or lower\nquality for |cffFFFFFFFREE|r.")
    GameTooltip:Show()
end)

M.EnchantFrame.Enchant.Refund:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

M.EnchantFrame.Enchant.Refund.AnimG = M.EnchantFrame.Enchant.Refund:CreateAnimationGroup()
M.EnchantFrame.Enchant.Refund.AnimG.Rotation0 = M.EnchantFrame.Enchant.Refund.AnimG:CreateAnimation("Translation")
M.EnchantFrame.Enchant.Refund.AnimG.Rotation0:SetDuration(2)
M.EnchantFrame.Enchant.Refund.AnimG.Rotation0:SetOrder(1)
M.EnchantFrame.Enchant.Refund.AnimG.Rotation0:SetSmoothing("IN_OUT")
M.EnchantFrame.Enchant.Refund.AnimG.Rotation0:SetOffset(0, -5)

M.EnchantFrame.Enchant.Refund.AnimG.Rotation1 = M.EnchantFrame.Enchant.Refund.AnimG:CreateAnimation("Translation")
M.EnchantFrame.Enchant.Refund.AnimG.Rotation1:SetDuration(2)
M.EnchantFrame.Enchant.Refund.AnimG.Rotation1:SetOrder(2)
M.EnchantFrame.Enchant.Refund.AnimG.Rotation1:SetSmoothing("IN_OUT")
M.EnchantFrame.Enchant.Refund.AnimG.Rotation1:SetOffset(0, 5)

M.EnchantFrame.Enchant.Refund.AnimG:SetScript("OnFinished", function(self)
    self:Play()
end)

M.EnchantFrame.Enchant.Refund.AnimG:Play()

--
-- Help Plate stuff
--


-- M.HelpPlateButton = CreateFrame("Button", "$parentHelpPlateButton", M, "HelpPlateButtonTemplate")
-- M.HelpPlateButton.HelpPlate = "MYSTIC_ENCHANT"
-- M.HelpPlateButton:SetPoint("TOPLEFT", 48, 16)
-- M.HelpPlateButton:SetFrameLevel(1000)

-- HelpPlate["MYSTIC_ENCHANT"] = {
--     cvar = "HelpTipBits",
--     cvarBit = HelpTips.Bits.HelpPlate_MysticEnchants,
--     MainTip = "MYSTIC_ENCHANT_MAIN",
--     {
--         helpTip     = "MYSTIC_ENCHANT_LEVEL",
--         parent      = "MysticEnchantingFrame",
--         points      = {
--             { "TOPLEFT",     "MysticEnchantingFrameProgressBar", "TOPLEFT",     0, 0 },
--             { "BOTTOMRIGHT", "MysticEnchantingFrameProgressBar", "BOTTOMRIGHT", 0, 0 },
--         },
--         flyoutPoint = { "CENTER", "TOP" }
--     },
--     {
--         helpTip     = "MYSTIC_ENCHANT_SEARCH",
--         parent      = "MysticEnchantingFrame",
--         points      = {
--             { "TOPLEFT",     "MysticEnchantingFrameSearchBox", "TOPLEFT",     -6, 0 },
--             { "BOTTOMRIGHT", "MysticEnchantingFrameSearchBox", "BOTTOMRIGHT", 0,  0 },
--         },
--         flyoutPoint = { "CENTER", "TOP" }
--     },
--     {
--         helpTip     = "MYSTIC_ENCHANT_CATEGORY",
--         parent      = "MysticEnchantingFrame",
--         points      = {
--             { "TOPLEFT",     "MysticEnchantingFrameEnchantTypeList", "TOPLEFT",     10, 0 },
--             { "BOTTOMRIGHT", "MysticEnchantingFrameEnchantTypeList", "BOTTOMRIGHT", -6, 4 },
--         },
--         flyoutPoint = { "CENTER", "TOP" }
--     },
--     {
--         helpTip     = "MYSTIC_ENCHANT_ENCHANT_SLOT",
--         parent      = "MysticEnchantingFrame",
--         points      = {
--             { "TOPLEFT",     "MysticEnchantingFrameEnchantFrame", "TOPLEFT",     0, 0 },
--             { "BOTTOMRIGHT", "MysticEnchantingFrameEnchantFrame", "BOTTOMRIGHT", 0, 0 },
--         },
--         flyoutPoint = { "CENTER" }
--     },
--     {
--         helpTip     = "MYSTIC_ENCHANT_PAPERDOLL",
--         parent      = "MysticEnchantingFrame",
--         points      = {
--             { "TOPLEFT",     "MysticEnchantingFramePaperDoll", "TOPLEFT",     0, 0 },
--             { "BOTTOMRIGHT", "MysticEnchantingFramePaperDoll", "BOTTOMRIGHT", 0, 0 },
--         },
--         flyoutPoint = { "CENTER" }
--     },
--     {
--         helpTip     = "MYSTIC_ENCHANT_COLLECTION",
--         parent      = "MysticEnchantingFrame",
--         points      = {
--             { "TOPLEFT",     "MysticEnchantingFrameCollectionsList", "TOPLEFT",     0, 0 },
--             { "BOTTOMRIGHT", "MysticEnchantingFrameCollectionsList", "BOTTOMRIGHT", 0, 8 },
--         },
--         flyoutPoint = { "CENTER" }
--     },
--     {
--         helpTip     = "MYSTIC_ENCHANT_CONTROLS",
--         parent      = "MysticEnchantingFrame",
--         points      = {
--             { "TOPLEFT",     "MysticEnchantingFrameControlFrameRollButton",    "TOPLEFT",     0, 0 },
--             { "BOTTOMRIGHT", "MysticEnchantingFrameControlFrameExtractButton", "BOTTOMRIGHT", 0, 0 },
--         },
--         flyoutPoint = { "CENTER", "BOTTOM" }
--     },
--     {
--         helpTip     = "MYSTIC_ENCHANT_COST",
--         parent      = "MysticEnchantingFrame",
--         points      = {
--             { "TOPLEFT",     "MysticEnchantingFrameControlFrame",           "TOPLEFT",    0,  0 },
--             { "BOTTOMRIGHT", "MysticEnchantingFrameControlFrameRollButton", "BOTTOMLEFT", -2, 0 },
--         },
--         flyoutPoint = { "CENTER", "BOTTOM" }
--     },
--     {
--         helpTip     = "MYSTIC_ENCHANT_ENCHANT_MANAGER",
--         parent      = "MysticEnchantingFrame",
--         points      = {
--             { "TOPLEFT",     "MysticEnchantingFrameManagerButton", "TOPLEFT",     0, 0 },
--             { "BOTTOMRIGHT", "MysticEnchantingFrameManagerButton", "BOTTOMRIGHT", 0, 0 },
--         },
--         flyoutPoint = { "CENTER", "BOTTOM" }
--     },
-- }

-- HelpTips["MYSTIC_ENCHANT_MAIN"] = {
--     targetPoint = HelpTip.Point.RightEdgeCenter,
-- }

-- HelpTips["MYSTIC_ENCHANT_LEVEL"] = {
--     targetPoint = HelpTip.Point.BottomEdgeCenter,
-- }

-- HelpTips["MYSTIC_ENCHANT_SEARCH"] = {
--     targetPoint = HelpTip.Point.BottomEdgeCenter,
-- }

-- HelpTips["MYSTIC_ENCHANT_CATEGORY"] = {
--     targetPoint = HelpTip.Point.BottomEdgeCenter,
-- }

-- HelpTips["MYSTIC_ENCHANT_ENCHANT_SLOT"] = {
--     targetPoint = HelpTip.Point.BottomEdgeCenter,
-- }

-- HelpTips["MYSTIC_ENCHANT_PAPERDOLL"] = {
--     targetPoint = HelpTip.Point.RightEdgeCenter,
-- }

-- HelpTips["MYSTIC_ENCHANT_COLLECTION"] = {
--     targetPoint = HelpTip.Point.LeftEdgeCenter,
-- }

-- HelpTips["MYSTIC_ENCHANT_CONTROLS"] = {
--     targetPoint = HelpTip.Point.TopEdgeCenter,
-- }

-- HelpTips["MYSTIC_ENCHANT_COST"] = {
--     targetPoint = HelpTip.Point.TopEdgeCenter,
-- }

-- HelpTips["MYSTIC_ENCHANT_ENCHANT_MANAGER"] = {
--     targetPoint = HelpTip.Point.TopEdgeCenter,
-- }


-------------------------------------------------------------------------------
--                                 HOOKS                                     --
-------------------------------------------------------------------------------

function Ascension_OnEvent(event, ...)
    --print("Ascension Event:", event, unpack(...))

    if event == "ASCENSION_REFORGE_ENCHANTMENT_LEARNED" then
        local enchantID = unpack(...)
        if not enchantID or not GetREData(enchantID) then
            SendSystemMessage(format(
                "REFORGE_ENCHANTMENT_LEARNED: Received invalid enchant with id: [%s] Tell a developer", enchantID))
            return
        end
        if not M:IsVisible() then
            M:Display()
        end
        ReceiveNewEnchant(enchantID)
    elseif event == "ASCENSION_REFORGE_ENCHANT_WINDOW_VISIBILITY_CHANGED" then
        local show = unpack(...)
        if show then
            AT_MYSTIC_ENCHANT_ALTAR = true
            if not C_CVar.GetBool("allowMysticEnchantingUI") then
                -- tutorial here
                C_CVar.Set("allowMysticEnchantingUI", "1")
            end
            M:Display()
        else
            M:Close()
        end
    elseif event == "ASCENSION_REFORGE_ENCHANT_RESULT" then
        local GUID, enchantID = unpack(...)
        if not enchantID or enchantID == 0 or not GetREData(enchantID) then return end

        OnReforgeSuccess(GUID, enchantID)
    elseif event == "ASCENSION_REFORGE_PROGRESS_UPDATE" then
        local progress, level = unpack(...)
        UpdateProgress(level, progress)
    elseif event == "ASCENSION_CA_RE_PRESET_CHANGED" then
        ClearControlFrame()
        Timer.After(0.2, function()
            UpdatePaperDoll()
        end)
    end
end

CharacterFrame:HookScript("OnShow", function() UpdatePaperDollEnchantList() end)
M:RegisterEvent("ITEM_LOCKED")
M:RegisterEvent("PLAYER_ENTERING_WORLD")
M:RegisterEvent("UNIT_MODEL_CHANGED")
M:RegisterEvent("ADDON_LOADED")
M:RegisterEvent("COMMENTATOR_SKIRMISH_QUEUE_REQUEST") -- Ascension events

M:SetScript("OnEvent", function(self, event, ...)
    if event == "COMMENTATOR_SKIRMISH_QUEUE_REQUEST" then
        Ascension_OnEvent(select(1, ...), { select(2, ...) })
    elseif (event == "ITEM_LOCKED") then
        GetLastLockedItem(...)
    elseif (event == "PLAYER_ENTERING_WORLD" or event == "UNIT_MODEL_CHANGED") then
        UpdatePaperDoll()
        UpdateProgress(self.CDB.EnchantLevel, self.CDB.EnchantProgress)

        local unit = ...
        if (unit == "player") then
            M.PaperDoll.Model:SetUnit("player")
        end
    elseif event == "ADDON_LOADED" then
        local name = ...
        if name ~= Addon.Name then return end

        AscensionUI.DB.MysticEnchant = AscensionUI.DB.MysticEnchant or {}
        self.DB = AscensionUI.DB.MysticEnchant

        AscensionUI.CDB.MysticEnchant = AscensionUI.CDB.MysticEnchant or {}
        self.CDB = AscensionUI.CDB.MysticEnchant
    end
end)

M:SetScript("OnHide", CollectionsOnHide)
M:SetScript("OnShow", function(self)
    UpdateMysticRuneBalance()
    UpdatePaperDoll()
    if M.KnownEnchantCount == 0 then
        if CAO_Known and next(CAO_Known) then
            M.EnchantTypeList.List[2].func()
            UIDropDownMenu_SetSelectedID(M.EnchantTypeList, 2)
            UIDropDownMenu_SetText(M.EnchantTypeList, M.EnchantTypeList.List[2].text)
        else
            UpdateListInfo(MYSTIC_ENCHANTS)
            UIDropDownMenu_SetSelectedID(M.EnchantTypeList, 1)
            UIDropDownMenu_SetText(M.EnchantTypeList, M.EnchantTypeList.List[1].text)
        end
    else
        UIDropDownMenu_SetSelectedID(M.EnchantTypeList, 6)
        UIDropDownMenu_SetText(M.EnchantTypeList, M.EnchantTypeList.List[6].text)
    end
    M.EnchantTypeList.SelectedId = 1 -- deliberately 1 so search will default back to all
    RollButtonCheck(M.ControlFrame.RollButton)
    DisenchantButtonTokenCheck(M.ControlFrame.ExtractButton)
    M.Initializated = true
    EnableBreathing()
    SearchForEnchant()
end)

hooksecurefunc("PickupContainerItem", M.ClickItem)
hooksecurefunc("PickupInventoryItem", M.ClickItem)
