local AddonName, Addon = ...
local M = Addon.MysticEnchant
local EnchantManager = CreateFrame("Frame")
Addon.EnchantManager = EnchantManager

M.Manager = CreateFrame("FRAME", M:GetName() .. ".Manager", M, "UIPanelDialogTemplate")
-------------------------------------------------------------------------------
--                              Manager Frame                                --
-------------------------------------------------------------------------------
local MAX_SETS = 100
local SET_SPELLS = { 84789, 84790, 84791, 84792, 84793, 84799, 84800, 84801, 84802, 84803, 85799, 85801, 85803, 85805, 85807, 85809, 85811, 85813, 85815, 85817, 85819, 85821, 85823, 85825, 85827, 85829, 85831, 85833, 85835, 85837, 85839, 85841, 85843, 85845, 85847, 85849, 85851, 85853, 85855, 85857, 85859, 85861, 85863, 85865, 85867, 85869, 85871, 85873, 85875, 85877, 85879, 85881, 85883, 85885, 85887, 85889, 85891, 85893, 85895, 85897, 85899, 85901, 85903, 85905, 85907, 85909, 85911, 85913, 85915, 85917, 85919, 85921, 85923, 85925, 85927, 85929, 85931, 85933, 85935, 85937, 85939, 85941, 85943, 85945, 85947, 85949, 85951, 85953, 85955, 85957, 85959, 85961, 85963, 85965, 85967, 85969, 85971, 85973, 85975, 85977, 85979, 85981, 85983, 85985, 85987, 85989, 85991, 85993, 85995, 85997, 85999, 86002, 86004, 86006, 86008, 86011, 86014, 86016, 86018, 86020, 86022, 86025, 86028, 86031, 86034, 86037, 86041, 86043, 86045, 86048, 86050, 86052, 86054, 86056, 86058, 86060, 86062, 86064, 86066, 86068, 86070, 86072, 86074, 86077, 86079, 86081, 86083, 86085, 86087, 86090, 86092, 86094, 86096, 86098, 86100, 86102, 86104, 86108, 86111, 86113, 86116, 86120, 86122, 86124, 86127, 86129, 86132, 86135, 86138, 86140, 86142, 86146, 86148, 86150, 86153, 86155, 86158, 86161, 86164, 86167, 86171, 86173, 86175, 86178, 86180, 86182, 86184, 86186, 86188, 86190, 86193, 86195, 86197, 86199, 86201, 86203, 86205, 86207, 86209, 86211, 86213, 86215, 86217, 86220, 86222, 86224, 86226, 86228, 86230, 86232, 86234, 86238, 86241, 86243, 86249, 86251, 86253, 86256, 86259, 86262, 86265, 86268, 86271, 86276, 86278, 86280, 86283, 86286, 86288, 86290, 86292, 86297, 86300, 86302, 86304, 86306, 86308, 86310, 86312, 86314, 86316, 86318, 86320, 86323, 86326, 86328, 86330, 86332, 86334, 86337, 86339, 86341, 86343, 86345 }
local SAVE_SPELLS = { 84804, 84812, 84813, 84814, 84815, 84816, 84817, 84818, 84819, 84820, 85800, 85802, 85804, 85806, 85808, 85810, 85812, 85814, 85816, 85818, 85820, 85822, 85824, 85826, 85828, 85830, 85832, 85834, 85836, 85838, 85840, 85842, 85844, 85846, 85848, 85850, 85852, 85854, 85856, 85858, 85860, 85862, 85864, 85866, 85868, 85870, 85872, 85874, 85876, 85878, 85880, 85882, 85884, 85886, 85888, 85890, 85892, 85894, 85896, 85898, 85900, 85902, 85904, 85906, 85908, 85910, 85912, 85914, 85916, 85918, 85920, 85922, 85924, 85926, 85928, 85930, 85932, 85934, 85936, 85938, 85940, 85942, 85944, 85946, 85948, 85950, 85952, 85954, 85956, 85958, 85960, 85962, 85964, 85966, 85968, 85970, 85972, 85974, 85976, 85978, 85980, 85982, 85984, 85986, 85988, 85990, 85992, 85994, 85996, 85998, 86001, 86003, 86005, 86007, 86009, 86013, 86015, 86017, 86019, 86021, 86023, 86026, 86030, 86033, 86035, 86038, 86042, 86044, 86046, 86049, 86051, 86053, 86055, 86057, 86059, 86061, 86063, 86065, 86067, 86069, 86071, 86073, 86075, 86078, 86080, 86082, 86084, 86086, 86089, 86091, 86093, 86095, 86097, 86099, 86101, 86103, 86106, 86109, 86112, 86115, 86119, 86121, 86123, 86126, 86128, 86130, 86134, 86137, 86139, 86141, 86145, 86147, 86149, 86152, 86154, 86156, 86160, 86163, 86165, 86168, 86172, 86174, 86176, 86179, 86181, 86183, 86185, 86187, 86189, 86191, 86194, 86196, 86198, 86200, 86202, 86204, 86206, 86208, 86210, 86212, 86214, 86216, 86219, 86221, 86223, 86225, 86227, 86229, 86231, 86233, 86236, 86239, 86242, 86245, 86250, 86252, 86254, 86257, 86260, 86264, 86267, 86269, 86275, 86277, 86279, 86282, 86285, 86287, 86289, 86291, 86293, 86299, 86301, 86303, 86305, 86307, 86309, 86311, 86313, 86315, 86317, 86319, 86321, 86325, 86327, 86329, 86331, 86333, 86335, 86338, 86340, 86342, 86344, 86346 }
-- M.Manager.SavePresetSpellNames = {}
-- M.Manager.LoadPresetSpellNames = {}

-- for i = 1, #SAVE_SPELLS do
--     local name = GetSpellInfo(SAVE_SPELLS[i])
--     M.Manager.SavePresetSpellNames[name] = i
-- end

-- for i = 1, #SET_SPELLS do
--     local name = GetSpellInfo(SET_SPELLS[i])
--     M.Manager.LoadPresetSpellNames[name] = i
-- end

local WARN_ORB_COST_FORMAT =
"Some of your equipped items have not had the target preset enchant applied before.\nApplying this preset will cost |cffFFFFFF%s |TInterface\\Icons\\inv_custom_CollectionRCurrency.blp:14:14|t|r\nDo you wish to spend these orbs, or only enchant items that are free?"
local PRESET_APPLY_FORMAT =
"You are about to apply: |cffFFFF00[%s]|r\nThis will overwrite your current Mystic Enchants\nThis cannot be undone"

local TOOLTIP_NOTIF_PRESET_OVERWRITE = "This enchant will be applied to your gear."

local PresetReplacementQualityBorders = {
    Addon.AwTexPath .. "enchant\\EnchantBorder_white",
    Addon.AwTexPath .. "enchant\\EnchantBorder_green",
    Addon.AwTexPath .. "enchant\\EnchantBorder_blue",
    Addon.AwTexPath .. "enchant\\EnchantBorder",
    Addon.AwTexPath .. "enchant\\EnchantBorder_Yellow",
    [0] = Addon.AwTexPath .. "enchant\\EnchantBorder_white", -- Quality 0 = missing enchant
}
-------------------------------------------------------------------------------
--                                 Dialogs                                   --
-------------------------------------------------------------------------------
StaticPopupDialogs["ASC_WARN_PRESET_ORB_COST"] = {
    text = WARN_ORB_COST_FORMAT,
    button1 = "Load All",
    button3 = "Load Free",
    button2 = CANCEL,
    whileDead = true,
    timeout = 0,
    hideOnEscape = true,
    OnAccept = function(self)
        local id = M.Manager.PreviewPaperDoll.ID or 1
        RequestChangeRandomEnchantmentPreset(id - 1, true)
    end,
    OnAlt = function(self)
        local id = M.Manager.PreviewPaperDoll.ID or 1
        RequestChangeRandomEnchantmentPreset(id - 1, false)
    end,
    OnCancel = function(self)
        self:Hide()
    end,
}

StaticPopupDialogs["ASC_WARN_PRESET_APPLY"] = {
    text = PRESET_APPLY_FORMAT,
    button1 = APPLY,
    button2 = CANCEL,
    whileDead = true,
    timeout = 0,
    hideOnEscape = true,
    OnAccept = function(self)
        local id = M.Manager.PreviewPaperDoll.ID or 1
        RequestChangeRandomEnchantmentPreset(id - 1, false)
    end,
    OnCancel = function(self)
        self:Hide()
    end,
}
-------------------------------------------------------------------------------
--                                 Utility                                   --
-------------------------------------------------------------------------------
function ActivateEnchantSet(id)
    EnchantManager.CDB.active = id
    M.Manager:SpellCheck()
end

local function SeperateMessage(str, char)
    local index, sub_str
    index = string.find(str, char)

    if (index) then
        sub_str = string.sub(str, 1, index - 1)
        str = string.sub(str, index + 1)
    end

    return sub_str, str
end

local function HandleParentArrow(self, value, arrowLeft, arrowRight)
    local min, max = self:GetMinMaxValues()

    if (value <= min) then
        arrowLeft:Disable()
    else
        arrowLeft:Enable()
    end

    if (value >= max) then
        arrowRight:Disable()
    else
        arrowRight:Enable()
    end
end

local function HandleScroll(self, delta, inverted)
    if (self.ScrollBar:IsVisible()) and (self.ScrollBar:IsEnabled() == 1) then
        local value = self.ScrollBar:GetValue()
        if not (inverted) then
            inverted = 1
        end
        self.ScrollBar:SetValue(value + (inverted * delta * 32))
    end
end

local function RefreshPreset(ID)
    if (EnchantManager.CDB.presets[ID]) then
        EnchantManager.CDB.presets[ID].REData = nil
    end
    M.Manager:ShowPresetData(ID)
end

local function GetApplyPresetOrbCost()
    local cost = 0
    local currentPreset = M.Manager.PreviewPaperDoll.ID
    local toApplyData = M.Manager:GetPresetData(currentPreset)

    for slotId, presetEnchantId in ipairs(toApplyData) do
        local instanceId = GetSlotItemInstanceId(slotId - 1)
        if instanceId and instanceId ~= 0 then
            if not HasRandomEnchantInHistory(instanceId, presetEnchantId) then
                local RE = GetREData(presetEnchantId)

                if RE and RE.enchantID ~= 0 then
                    cost = cost + M:GetEnchantOrbCost(presetEnchantId)
                end
            end
        end
    end
    return cost
end
-------------------------------------------------------------------------------
--                                  Button                                   --
-------------------------------------------------------------------------------
local function ManagerButtonTemplate(name, parent)
    local btn = CreateFrame("Button", name, parent, nil)
    btn:SetSize(210, 54)
    btn:SetMotionScriptsWhileDisabled(true)

    btn.Border = btn:CreateTexture(name .. ".Border", "BACKGROUND")
    btn.Border:SetTexture(Addon.AwTexPath .. "CAOverhaul\\2\\SpecButton")
    btn.Border:SetSize(256, 64)
    btn.Border:SetPoint("CENTER", 0, 0)

    btn.H = btn:CreateTexture(name .. ".H", "OVERLAY")
    btn.H:SetAtlas("pvpqueue-button-casual-highlight")
    btn.H:SetSize(240, 54)
    btn.H:SetPoint("CENTER", -3, 3)
    --btn.H:SetVertexColor(0,1,0)
    btn:SetHighlightTexture(btn.H)

    btn.checked = btn:CreateTexture(name .. ".H", "OVERLAY")
    btn.checked:SetAtlas("pvpqueue-button-casual-selected")
    btn.checked:SetSize(240, 54)
    btn.checked:SetPoint("CENTER", -3, 3)
    btn.checked:SetBlendMode("ADD")
    btn.checked:Hide()

    btn.Text = btn:CreateFontString(name .. ".Text")
    btn.Text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    btn.Text:SetFontObject(GameFontNormal)
    btn.Text:SetPoint("CENTER", 20, 10)
    btn.Text:SetShadowOffset(1, -1)
    btn.Text:SetText("Enchants Set")
    btn.Text:SetSize(160, 16)
    btn.Text:SetJustifyH("LEFT")

    btn.Text_Add = btn:CreateFontString(name .. ".Text_Add")
    btn.Text_Add:SetFont("Fonts\\FRIZQT__.TTF", 10)
    btn.Text_Add:SetFontObject(GameFontNormal)
    btn.Text_Add:SetPoint("CENTER", 20, -6)
    btn.Text_Add:SetShadowOffset(1, -1)
    btn.Text_Add:SetText("|cff00FF00Active")
    btn.Text_Add:SetSize(160, 16)
    btn.Text_Add:SetJustifyH("LEFT")

    btn.SpecIcon = CreateFrame("FRAME", name .. ".SpecIcon", btn, "PopupButtonTemplate")
    btn.SpecIcon:SetSize(32, 32)
    btn.SpecIcon:SetPoint("LEFT", 0, 2)

    btn.KnownBorder = btn.SpecIcon:CreateTexture(name .. ".KnownBorder", "ARTWORK")
    btn.KnownBorder:SetTexture(Addon.AwTexPath .. "CAOverhaul\\Known_Highlight")
    btn.KnownBorder:SetSize(80, 80)
    btn.KnownBorder:SetPoint("CENTER", btn.SpecIcon, 0, 0)
    btn.KnownBorder:SetBlendMode("ADD")

    btn.SpecIcon.Icon = btn.SpecIcon:CreateTexture(nil, "ARTWORK")
    btn.SpecIcon.Icon:SetTexture("Interface\\Icons\\inv_misc_book_16")
    btn.SpecIcon.Icon:SetSize(36, 36)
    btn.SpecIcon.Icon:SetPoint("CENTER", 0, -1)

    btn.SpecIcon.Settings = CreateFrame("Button", name .. ".SpecIcon.Settings", btn.SpecIcon)
    btn.SpecIcon.Settings:SetPoint("BOTTOMRIGHT", 12, -8)
    btn.SpecIcon.Settings:SetSize(26, 26)
    btn.SpecIcon.Settings:SetNormalTexture(Addon.AwTexPath .. "CAOverhaul\\GearIcon")
    btn.SpecIcon.Settings:SetHighlightTexture(Addon.AwTexPath .. "CAOverhaul\\GearIcon_H")
    btn.SpecIcon.Settings:SetScript("OnClick", function(self)
        local ID = self:GetParent():GetParent().ID
        M.Manager.PopupController.buttonID = ID
        M.Manager.PopupController.frame:Hide()

        if EnchantManager.CDB.presets[ID] and EnchantManager.CDB.presets[ID].name then
            M.Manager.PopupController:EditExisting(EnchantManager.CDB.presets[ID].name,
                EnchantManager.CDB.presets[ID].icon)
        else
            M.Manager.PopupController:CreateNew()
        end
    end)

    btn.SpecIcon.Settings:SetScript("OnEnter", function(self)
        if (self:IsEnabled() == 1) then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
            GameTooltip:AddLine("|cffFFFFFFCustomize Enchants Set|r")
            GameTooltip:AddLine("Click here to change icon or name of your Enchants Set.")
            GameTooltip:Show()
        end
    end)

    btn.SpecIcon.Settings:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    function btn:ToEnabled()
        btn:Enable()
        btn.Text:SetFontObject(GameFontNormal)
        btn.Text_Add:SetText("|cff00FF00Known|r")

        btn.SpecIcon.Settings:Enable()
        btn.SpecIcon.Settings:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
        btn.SpecIcon.Icon:SetDesaturated(false)
        btn.SpecIcon.Icon:SetVertexColor(1, 1, 1, 1)
        btn.KnownBorder:Hide()
        btn.isActive = false
    end

    function btn:Activate()
        btn.Text:SetFontObject(GameFontHighlight)
        btn.Text_Add:SetText("Active|r")
        btn.KnownBorder:Show()
        btn.isActive = true
    end

    function btn:ToDisabled()
        btn:Disable()
        btn.Text:SetFontObject(GameFontDisable)
        if self.ID and self.ID <= 2 then
            btn.Text_Add:SetText("|cffFF0000Unlocks at level " .. GetMaxLevel() .. "|r")
        else
            btn.Text_Add:SetText("|cffFF0000" .. UNLOCKED_BY_ITEM .. "|r")
        end


        btn.SpecIcon.Settings:Disable()
        btn.SpecIcon.Settings:GetNormalTexture():SetVertexColor(1, 0, 0, 1)
        btn.SpecIcon.Icon:SetVertexColor(1, 0, 0, 1)
        btn.KnownBorder:Hide()
        btn.isActive = false
    end

    --[[function btn:SetSpell(sID)
        local name = GetSpellInfo(sID)
        if not(name) then
            print("EnchantManager. ERROR. Couldn't find spell "..sID)
            btn:ToDisabled()
            return
        end

        btn:SetAttribute("type1", "macro") -- left click causes macro
        btn:SetAttribute("macrotext1", "/cast "..name.."\n/run ActivateEnchantSet("..btn.ID..")") -- text for macro on left click
    end]]
    --

    btn:SetScript("OnClick", function(self)
        M.Manager:ShowPresetData(self.ID)
        PlaySound("igMainMenuOptionCheckBoxOn")
        --M.PreviewPaperDoll.ActivateButton:SetSpell(SET_SPELLS[self.ID]) -- WIP
    end)

    btn:SetScript("OnMouseDown", function(self)
        self.Text:SetPoint("CENTER", 21, 8)
        self.Text_Add:SetPoint("CENTER", 21, -8)
    end)

    btn:SetScript("OnMouseUp", function(self)
        self.Text:SetPoint("CENTER", 20, 10)
        self.Text_Add:SetPoint("CENTER", 20, -6)
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(self.Text:GetText(), 1, 1, 1)

        if self:IsEnabled() == 1 then
            if self.isActive then
                GameTooltip:AddLine("This is your current preset", nil, nil, nil, true)
            else
                GameTooltip:AddLine("Click to change to this preset", nil, nil, nil, true)
            end
        else
            GameTooltip:AddLine(
                "Unlock this preset by purchasing Mystic Enchanting: Unlock Preset\nThese can be bought for Donation Points at Ascension.gg/store\nor purchased from the Auction House")
        end
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    return btn
end

local function PreviewEnchantTemplate(parent, slotId)
    local frame = M:CollectionEnchantTemplate(parent)
    frame:SetID(slotId)
    frame:Show()
    frame:SetFrameLevel(10)

    local pulse = frame:CreateTexture(nil, "OVERLAY")
    frame.Pulse = pulse
    pulse:SetPoint("CENTER")
    pulse:SetSize(36, 36)

    local anim = pulse:CreateAnimationGroup()
    pulse.Anim = anim
    anim:SetLooping("REPEAT")

    local scale1 = anim:CreateAnimation("Scale")
    scale1:SetScale(1, 1)
    scale1:SetDuration(0)
    scale1:SetOrder(1)

    local scale2 = anim:CreateAnimation("Scale")
    scale2:SetScale(2, 2)
    scale2:SetDuration(1.2)
    scale2:SetSmoothing("OUT")
    scale2:SetOrder(2)

    local alpha = anim:CreateAnimation("Alpha")
    alpha:SetChange(-1)
    alpha:SetDuration(1.2)
    alpha:SetSmoothing("OUT")

    function frame:ToDisabled()
        self.Spell = nil
        self.Name = nil
        self.RE = nil
        self:SlotButtonSetQuality(4)
        SetPortraitToTexture(self.Icon, "Interface\\Icons\\Inv_misc_questionmark")
        self.Icon:SetDesaturated(true)
    end

    function frame:SetEnchant(sID)
        self.Pulse.Anim:Stop()
        self.Pulse:Hide()
        if (sID == 0) then
            frame:ToDisabled()
            return
        else
            frame.Icon:SetDesaturated(false)
        end

        local RE = GetREData(sID)
        local spellID = RE.spellID
        local quality = RE.quality

        if not (spellID) then
            print("ERROR. no SID found " .. spellID)
            return
        end

        local name, _, icon = GetSpellInfo(spellID)

        if not icon then
            icon = "Interface\\Icons\\Inv_misc_questionmark"
        end

        self.RE = sID
        self.Spell = spellID
        self.Name = name and M.EnchantQualitySettings[quality][1] .. name .. "|r"

        local currentEnchant = GetREInSlot(255, self:GetID())
        local currentRE = GetREData(currentEnchant)
        if sID == currentEnchant then
            self.IsNewEnchant = nil
            self.CurrentRE = nil
        else
            self.IsNewEnchant = true
            self.CurrentRE = currentRE
            self.Pulse:SetTexture(M.PaperDollEnchantQualitySettings[quality])
            self.Pulse:Show()
            self.Pulse.Anim:Play()
        end
        self:SlotButtonSetQuality(quality)
        SetPortraitToTexture(self.Icon, icon)
    end

    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self.Spell then
            GameTooltip:SetHyperlink("spell:" .. self.Spell)

            if self.IsNewEnchant then
                if self.CurrentRE and self.CurrentRE.spellID ~= 0 then
                    local reName = GetSpellInfo(self.CurrentRE.spellID)
                    local quality = self.CurrentRE.quality
                    reName = M.EnchantQualitySettings[quality][1] .. reName .. "|r"

                    GameTooltip:AddLine("\nApplying this preset will overwrite " .. reName .. " with " .. self.Name, 1, 1,
                        1, true)
                else
                    GameTooltip:AddLine("\nApplying this preset will apply " .. self.Name .. " to this slot", 1, 1, 1,
                        true)
                end

                local instanceId = GetSlotItemInstanceId(self:GetID() - 1)
                if instanceId and instanceId ~= 0 and self.RE then
                    if not HasRandomEnchantInHistory(instanceId, self.RE) then
                        local cost = M:GetEnchantOrbCost(self.RE)
                        if cost and cost > 0 then
                            GameTooltip:AddLine("This item does not have " .. self.Name .. " in it's history")
                            GameTooltip:AddLine("Applying this preset will cost |cffFFFFFF" ..
                                cost ..
                                "|r |TInterface\\Icons\\inv_custom_CollectionRCurrency.blp:14:14|t Mystic Orbs for this slot")
                        end
                    end
                end
            else
                GameTooltip:AddLine("\nThis slot already has " .. self.Name .. " applied", 1, 1, 1, true)
            end
        else
            GameTooltip:SetText("This preset has no enchant for this slot", nil, nil, nil, true)
            if self.Name then
                GameTooltip:AddLine(self.Name .. " applied in this slot will not change.", 1, 1, 1, true)
            end
        end

        GameTooltip:Show()
    end)

    frame:ToDisabled()

    return frame
end
-------------------------------------------------------------------------------
--                                  Logic                                    --
-------------------------------------------------------------------------------
function M.Manager:LoadButtons()
    for k, data in pairs(EnchantManager.CDB.presets) do
        if data.name and data.icon then
            _G[M:GetName() .. ".Manager.contentFrame.button" .. k].Text:SetText(data.name)
            _G[M:GetName() .. ".Manager.contentFrame.button" .. k].SpecIcon.Icon:SetTexture(data.icon)
        end
    end
end

function M.Manager:SpellCheck()
    local totalActive = {}

    M.Manager:LoadButtons()

    for i = 1, MAX_SETS do
        if (IsSpellKnown(SET_SPELLS[i])) then
            _G[M:GetName() .. ".Manager.contentFrame.button" .. i]:ToEnabled()
            if (EnchantManager.CDB.active == i) then
                _G[M:GetName() .. ".Manager.contentFrame.button" .. i]:Activate()
            end
            table.insert(totalActive, i)
        else
            _G[M:GetName() .. ".Manager.contentFrame.button" .. i]:ToDisabled()
        end
    end

    M.Manager.PreviewPaperDoll.LoadButton:SetEnabled(#totalActive > 0)
    M.Manager.PreviewPaperDoll.SaveButton:SetEnabled(#totalActive > 0)

    if (#totalActive == 1) then
        _G[M:GetName() .. ".Manager.contentFrame.button" .. (totalActive[1])]:Activate()
        EnchantManager.CDB.active = 1
        return
    end

    if (EnchantManager.CDB.active == 0) and (#totalActive > 1) then -- more than 1 spec active and no active found
        StaticPopupDialogs["ASC_ERROR"].text =
        "System wasn't able to find your currently active Enchant Set.\nTo prevent data loss, please choose Enchant Set you're currently in."
        StaticPopup_Show("ASC_ERROR")
        return
    end
end

function M.Manager:GetPresetData(setID)
    if (EnchantManager.CDB.presets[setID] and EnchantManager.CDB.presets[setID].REData) then
        return EnchantManager.CDB.presets[setID].REData
    end

    if not (EnchantManager.CDB.presets[setID]) then
        EnchantManager.CDB.presets[setID] = {}
    end

    if not (EnchantManager.CDB.presets[setID].REData) then
        EnchantManager.CDB.presets[setID].REData = {}
    end

    for i = 0, 18 do -- probably rework in future, can't test it
        EnchantManager.CDB.presets[setID].REData[i + 1] = GetREPresetDataSlot((setID - 1), i)
    end

    return EnchantManager.CDB.presets[setID].REData
end

function M.Manager:ShowPresetData(index)
    local slotHead = 0
    local slotNeck = 0
    local slotShoulders = 0
    local slotChest = 0
    local slotWaist = 0
    local slotLegs = 0
    local slotFeet = 0
    local slotWrists = 0
    local slotHands = 0
    local slotRing1 = 0
    local slotRing2 = 0
    local slotT1 = 0
    local slotT2 = 0
    local slotBack = 0
    local slotMainH = 0
    local slotOffH = 0
    local slotRanged = 0

    slotHead, slotNeck, slotShoulders, _, slotChest, slotWaist, slotLegs, slotFeet, slotWrists, slotHands, slotRing1, slotRing2, slotT1, slotT2, slotBack, slotMainH, slotOffH, slotRanged =
        unpack(M.Manager:GetPresetData(index))

    if (EnchantManager.CDB.presets[index] and EnchantManager.CDB.presets[index].name) then
        M.Manager.PreviewPaperDoll.title:SetText("Preview " .. EnchantManager.CDB.presets[index].name)
    else
        M.Manager.PreviewPaperDoll.title:SetText("Preview Enchant Set " .. index)
    end

    if M.Manager.PreviewPaperDoll.ID and (_G[M:GetName() .. ".Manager.contentFrame.button" .. M.Manager.PreviewPaperDoll.ID].checked:IsVisible()) then
        _G[M:GetName() .. ".Manager.contentFrame.button" .. M.Manager.PreviewPaperDoll.ID].checked:Hide()
    end

    M.Manager.PreviewPaperDoll.ID = index

    M.Manager.PreviewPaperDoll.HeadEnchant:SetEnchant(slotHead)
    M.Manager.PreviewPaperDoll.NeckEnchant:SetEnchant(slotNeck)
    M.Manager.PreviewPaperDoll.ShouldersEnchant:SetEnchant(slotShoulders)
    M.Manager.PreviewPaperDoll.BackEnchant:SetEnchant(slotBack)
    M.Manager.PreviewPaperDoll.ChestEnchant:SetEnchant(slotChest)
    M.Manager.PreviewPaperDoll.WristEnchant:SetEnchant(slotWrists)
    M.Manager.PreviewPaperDoll.HandsEnchant:SetEnchant(slotHands)
    M.Manager.PreviewPaperDoll.WaistEnchant:SetEnchant(slotWaist)
    M.Manager.PreviewPaperDoll.LegsEnchant:SetEnchant(slotLegs)
    M.Manager.PreviewPaperDoll.FeetEnchant:SetEnchant(slotFeet)
    M.Manager.PreviewPaperDoll.Finger1Enchant:SetEnchant(slotRing1)
    M.Manager.PreviewPaperDoll.Finger2Enchant:SetEnchant(slotRing2)
    M.Manager.PreviewPaperDoll.T1Enchant:SetEnchant(slotT1)
    M.Manager.PreviewPaperDoll.T2Enchant:SetEnchant(slotT2)
    M.Manager.PreviewPaperDoll.OffHandEnchant:SetEnchant(slotOffH)
    M.Manager.PreviewPaperDoll.RangedEnchant:SetEnchant(slotRanged)
    M.Manager.PreviewPaperDoll.MainHandEnchant:SetEnchant(slotMainH)
    M.Manager.PreviewPaperDoll:Show()

    _G[M:GetName() .. ".Manager.contentFrame.button" .. index].checked:Show()
end

--[[function M.Manager:RecievePresetData(setID, slotInfo)
    if not(EnchantManager.CDB.presets[setID]) then
        EnchantManager.CDB.presets[setID] = {}
    end

    EnchantManager.CDB.presets[setID].REData = slotInfo
end]]
--

function M.Manager:GetActivePreset(index)
    EnchantManager.CDB.active = index or 1 -- default to 1, server does as well

    M.Manager:SpellCheck()
end

-------------------------------------------------------------------------------
--                                    UI                                     --
-------------------------------------------------------------------------------
M.Manager:SetScript("OnShow", function(self)
    self:SpellCheck()
    self:ShowPresetData(EnchantManager.CDB.active)
end)

M.Manager:SetPoint("BOTTOMRIGHT", -13, 32)
M.Manager:SetSize(275, 416)
M.Manager:EnableMouse(true)
M.Manager:SetFrameLevel(6)
M.Manager:Hide()


M.Manager.title:SetText("Enchant Presets")

M.Manager.contentFrame = CreateFrame("FRAME", M:GetName() .. ".Manager.contentFrame", M.Manager, nil)
M.Manager.contentFrame:SetPoint("CENTER", 0, 0)
M.Manager.contentFrame:SetSize(231, 381)

for i = 1, MAX_SETS do
    local btn = ManagerButtonTemplate(M:GetName() .. ".Manager.contentFrame.button" .. i, M.Manager.contentFrame)

    if (i == 1) then
        btn:SetPoint("TOP", 3, -2)
    else
        btn:SetPoint("BOTTOM", _G[M:GetName() .. ".Manager.contentFrame.button" .. (i - 1)], 0, -50)
    end

    btn.ID = i

    btn.Text:SetText("Enchants Set " .. i)
end

M.Manager.scroll = CreateFrame("ScrollFrame", M:GetName() .. ".Manager.scroll", M.Manager)
M.Manager.scroll:SetSize(M.Manager.contentFrame:GetSize())
M.Manager.scroll:SetPoint("BOTTOMLEFT", 8, 7)
M.Manager.scroll:EnableMouseWheel(true)

M.Manager.scroll:SetScript("OnMouseWheel", function(self, delta)
    HandleScroll(self, delta, -1)
end)

M.Manager.scroll.topArt = M.Manager.scroll:CreateTexture(nil, "ARTWORK")
M.Manager.scroll.topArt:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
M.Manager.scroll.topArt:SetSize(31, 256)
M.Manager.scroll.topArt:SetPoint("TOPLEFT", M.Manager.scroll, "TOPRIGHT", 0, 0)
M.Manager.scroll.topArt:SetTexCoord(0, 0.484375, 0, 1)

M.Manager.scroll.centerArt = M.Manager.scroll:CreateTexture(nil, "ARTWORK")
M.Manager.scroll.centerArt:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
M.Manager.scroll.centerArt:SetSize(31, 256)
M.Manager.scroll.centerArt:SetPoint("LEFT", M.Manager.scroll, "RIGHT", 0, 0)
M.Manager.scroll.centerArt:SetTexCoord(0, 0.484375, 0.1, 1)

M.Manager.scroll.botArt = M.Manager.scroll:CreateTexture(nil, "ARTWORK")
M.Manager.scroll.botArt:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
M.Manager.scroll.botArt:SetSize(31, 106)
M.Manager.scroll.botArt:SetPoint("BOTTOMLEFT", M.Manager.scroll, "BOTTOMRIGHT", 0, 0)
M.Manager.scroll.botArt:SetTexCoord(0.515625, 1.0, 0, 0.4140625)

M.Manager.scroll.ScrollBar = CreateFrame("Slider", nil, M.Manager.scroll, "UIPanelScrollBarTemplate")
M.Manager.scroll.ScrollBar:SetPoint("TOPLEFT", M.Manager.scroll, "TOPRIGHT", 8, -20)
M.Manager.scroll.ScrollBar:SetPoint("BOTTOMLEFT", M.Manager.scroll, "BOTTOMRIGHT", 0, 18)

local max = (((_G[M:GetName() .. ".Manager.contentFrame.button1"]:GetHeight() - 3.5) * MAX_SETS) - M.Manager.scroll:GetHeight()) or
    128

M.Manager.scroll.ScrollBar:SetMinMaxValues(1, max)
M.Manager.scroll.ScrollBar:SetValueStep(1)
M.Manager.scroll.ScrollBar.scrollStep = 1
M.Manager.scroll.ScrollBar:SetValue(0)
M.Manager.scroll.ScrollBar:SetWidth(16)
M.Manager.scroll.ScrollBar:SetScript("OnValueChanged",
    function(self, value)
        M.Manager.scroll:SetVerticalScroll(value)
        HandleParentArrow(self, value, _G[M:GetName() .. ".Manager.scrollScrollUpButton"],
            _G[M:GetName() .. ".Manager.scrollScrollDownButton"])
    end)
_G[M:GetName() .. ".Manager.scrollScrollUpButton"]:Disable()

M.Manager.scroll.ScrollBar:EnableMouseWheel(true)
M.Manager.scroll.ScrollBar:SetScript("OnMouseWheel", function(self, delta)
    HandleScroll(M.Manager.scroll, delta, -1)
end)

M.Manager.scroll:SetScrollChild(M.Manager.contentFrame)

M.ManagerButton = CreateFrame("Button", "$parentManagerButton", M, "StaticPopupButtonTemplate")
M.ManagerButton:SetSize(160, 22)
M.ManagerButton:SetPoint("RIGHT", M, "BOTTOMRIGHT", -15, 24)
M.ManagerButton:SetText("Enchant Presets")
M.ManagerButton:SetScript("OnClick", function(self)
    if (M.Manager:IsVisible()) then
        M.Manager:Hide()
    else
        M.Manager:Show()
    end
end)

M.ManagerButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, -24)
    if (self.tooltipTitle) then
        GameTooltip:AddLine(self.tooltipTitle, 1, 1, 1, true)
    end

    if (self.tooltipText) then
        GameTooltip:AddLine(self.tooltipText, nil, nil, nil, true)
    end

    GameTooltip:Show()
end)
M.ManagerButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)
M.ManagerButton.tooltipTitle = M.ManagerButton:GetText()
M.ManagerButton.tooltipText = ENCHANT_PRESET_DESC

MagicButton_OnLoad(M.ManagerButton)
M.ManagerButton.RightSeparator:Hide()
-------------------------------------------------------------------------------
--                               Preview Frame                               --
-------------------------------------------------------------------------------
M.Manager.PreviewPaperDoll = CreateFrame("FRAME", M:GetName() .. ".Manager.PreviewPaperDoll", M.Manager,
    "UIPanelDialogTemplate")
M.Manager.PreviewPaperDoll:SetPoint("BOTTOMRIGHT", M.ControlFrame, "BOTTOMRIGHT", 4, -5)
M.Manager.PreviewPaperDoll:SetPoint("TOPLEFT", M.PaperDoll, "TOPLEFT", -8, 24)
_G[M:GetName() .. ".Manager.PreviewPaperDollDialogBG"]:Hide()
M.Manager.PreviewPaperDoll.title:SetText("Enchant Set Preview")
--M.Manager.PreviewPaperDoll:Hide()
--M.Manager.PreviewPaperDoll:SetScript("OnShow", PaperDollOnShow)
M.Manager.PreviewPaperDoll.enchTable = {}

M.Manager.PreviewPaperDoll.LoadButton = CreateFrame("Button", nil, M.Manager.PreviewPaperDoll,
    "StaticPopupButtonTemplate")
M.Manager.PreviewPaperDoll.LoadButton:SetMotionScriptsWhileDisabled(true)
M.Manager.PreviewPaperDoll.LoadButton:SetPoint("BOTTOMRIGHT", -4, 8)
M.Manager.PreviewPaperDoll.LoadButton:SetPoint("TOPLEFT", M.Manager.PreviewPaperDoll, "BOTTOM", 0, 32)
M.Manager.PreviewPaperDoll.LoadButton:SetText("Load Preset")
M.Manager.PreviewPaperDoll.LoadButton:SetScript("OnClick", function(self)
    if self:IsEnabled() == 0 then return end
    local cost = GetApplyPresetOrbCost()
    if cost and cost > 0 then -- calculate orb cost here
        local dialog = StaticPopup_Show("ASC_WARN_PRESET_ORB_COST", cost)
        local currentOrbs = GetItemCount(98570)
        if cost > currentOrbs then
            dialog.button1:Disable()
        else
            dialog.button1:Enable()
        end
    else
        local index = M.Manager.PreviewPaperDoll.ID
        local name = EnchantManager.CDB.presets[index].name or ("Enchant Set " .. index)
        StaticPopup_Show("ASC_WARN_PRESET_APPLY", name)
    end
end)

M.Manager.PreviewPaperDoll.LoadButton:SetScript("OnEnter", function(self)
    if self:IsEnabled() == 1 then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("You do not know any Mystic Enchant Presets.", nil, nil, nil, true)
    GameTooltip:AddLine("You must unlock Mystic Enchanting Presets to Load Presets", 1, 1, 1, true)
    GameTooltip:Show()
end)

M.Manager.PreviewPaperDoll.LoadButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

MagicButton_OnLoad(M.Manager.PreviewPaperDoll.LoadButton)

M.Manager.PreviewPaperDoll.SaveButton = CreateFrame("Button", nil, M.Manager.PreviewPaperDoll,
    "StaticPopupButtonTemplate")
M.Manager.PreviewPaperDoll.SaveButton:SetMotionScriptsWhileDisabled(true)
M.Manager.PreviewPaperDoll.SaveButton:SetPoint("BOTTOMLEFT", M.Manager.PreviewPaperDoll, "BOTTOMLEFT", 4, 8)
M.Manager.PreviewPaperDoll.SaveButton:SetPoint("TOPRIGHT", M.Manager.PreviewPaperDoll, "BOTTOM", 0, 32)
M.Manager.PreviewPaperDoll.SaveButton:SetText("Save Preset")
M.Manager.PreviewPaperDoll.SaveButton:SetScript("OnClick", function(self)
    if self:IsEnabled() == 0 then return end
    local ID = self:GetParent().ID
    RequestSaveRandomEnchantmentPreset(ID - 1)
end)

M.Manager.PreviewPaperDoll.SaveButton:SetScript("OnEnter", function(self)
    if self:IsEnabled() == 1 then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("You do not know any Mystic Enchant Presets.", nil, nil, nil, true)
    GameTooltip:AddLine("You must unlock Mystic Enchanting Presets to Save Presets", 1, 1, 1, true)
    GameTooltip:Show()
end)

M.Manager.PreviewPaperDoll.SaveButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

M.Manager.PreviewPaperDoll.HeadEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_HEAD)
M.Manager.PreviewPaperDoll.HeadEnchant:SetPoint("CENTER", M.PaperDoll.Slot1.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.HeadEnchant)

M.Manager.PreviewPaperDoll.NeckEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_NECK)
M.Manager.PreviewPaperDoll.NeckEnchant:SetPoint("CENTER", M.PaperDoll.Slot2.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.NeckEnchant)

M.Manager.PreviewPaperDoll.ShouldersEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_SHOULDER)
M.Manager.PreviewPaperDoll.ShouldersEnchant:SetPoint("CENTER", M.PaperDoll.Slot3.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.ShouldersEnchant)

M.Manager.PreviewPaperDoll.BackEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_BACK)
M.Manager.PreviewPaperDoll.BackEnchant:SetPoint("CENTER", M.PaperDoll.Slot4.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.BackEnchant)

M.Manager.PreviewPaperDoll.ChestEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_CHEST)
M.Manager.PreviewPaperDoll.ChestEnchant:SetPoint("CENTER", M.PaperDoll.Slot5.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.ChestEnchant)

M.Manager.PreviewPaperDoll.WristEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_WRIST)
M.Manager.PreviewPaperDoll.WristEnchant:SetPoint("CENTER", M.PaperDoll.Slot8.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.WristEnchant)

M.Manager.PreviewPaperDoll.HandsEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_HAND)
M.Manager.PreviewPaperDoll.HandsEnchant:SetPoint("CENTER", M.PaperDoll.Slot9.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.HandsEnchant)

M.Manager.PreviewPaperDoll.WaistEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_WAIST)
M.Manager.PreviewPaperDoll.WaistEnchant:SetPoint("CENTER", M.PaperDoll.Slot10.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.WaistEnchant)

M.Manager.PreviewPaperDoll.LegsEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_LEGS)
M.Manager.PreviewPaperDoll.LegsEnchant:SetPoint("CENTER", M.PaperDoll.Slot11.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.LegsEnchant)

M.Manager.PreviewPaperDoll.FeetEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_FEET)
M.Manager.PreviewPaperDoll.FeetEnchant:SetPoint("CENTER", M.PaperDoll.Slot12.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.FeetEnchant)

M.Manager.PreviewPaperDoll.Finger1Enchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_FINGER1)
M.Manager.PreviewPaperDoll.Finger1Enchant:SetPoint("CENTER", M.PaperDoll.Slot13.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.Finger1Enchant)

M.Manager.PreviewPaperDoll.Finger2Enchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_FINGER2)
M.Manager.PreviewPaperDoll.Finger2Enchant:SetPoint("CENTER", M.PaperDoll.Slot14.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.Finger2Enchant)

M.Manager.PreviewPaperDoll.T1Enchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_TRINKET1)
M.Manager.PreviewPaperDoll.T1Enchant:SetPoint("CENTER", M.PaperDoll.Slot15.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.T1Enchant)

M.Manager.PreviewPaperDoll.T2Enchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_TRINKET2)
M.Manager.PreviewPaperDoll.T2Enchant:SetPoint("CENTER", M.PaperDoll.Slot16.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.T2Enchant)

M.Manager.PreviewPaperDoll.OffHandEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_OFFHAND)
M.Manager.PreviewPaperDoll.OffHandEnchant:SetPoint("CENTER", M.PaperDoll.Slot17.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.OffHandEnchant)

M.Manager.PreviewPaperDoll.RangedEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_RANGED)
M.Manager.PreviewPaperDoll.RangedEnchant:SetPoint("CENTER", M.PaperDoll.Slot18.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.RangedEnchant)

M.Manager.PreviewPaperDoll.MainHandEnchant = PreviewEnchantTemplate(M.Manager.PreviewPaperDoll, INVSLOT_MAINHAND)
M.Manager.PreviewPaperDoll.MainHandEnchant:SetPoint("CENTER", M.PaperDoll.Slot19.Enchant, 0, 0)
table.insert(M.Manager.PreviewPaperDoll.enchTable, M.Manager.PreviewPaperDoll.MainHandEnchant)
-------------------------------------------------------------------------------
--                           Set up icon selector                            --
-------------------------------------------------------------------------------
M.Manager.PopupController = IconSelectCreateFrame(M:GetName() .. ".Manager.PopupController", M.Manager,
    { "TOPRIGHT", M.Manager, "TOPLEFT", -8, 0 })
M.Manager.PopupController.frame:SetFrameLevel(10)

function M.Manager.PopupController:UpdateValues(text, texture) -- this one is called when user clicks OK button or enter
    if not (EnchantManager.CDB.presets[M.Manager.PopupController.buttonID]) then
        EnchantManager.CDB.presets[M.Manager.PopupController.buttonID] = {}
    end

    EnchantManager.CDB.presets[M.Manager.PopupController.buttonID].name = text
    EnchantManager.CDB.presets[M.Manager.PopupController.buttonID].icon = texture
    M.Manager:LoadButtons()
end

-------------------------------------------------------------------------------
--                                   Setup                                   --
-------------------------------------------------------------------------------
function EnchantManager.ASCENSION_CA_RE_PRESET_CHANGED(event, ...)
    local newSet = ...
    -- this event can happen before the player has fully entered the world.
    if not PLAYER_ENTERED_WORLD then
        Timer.WaitFor(0.2, function() return PLAYER_ENTERED_WORLD end, function()
            M.Manager:GetActivePreset(newSet + 1)
            RefreshPreset(newSet + 1)
        end)
    else
        M.Manager:GetActivePreset(newSet + 1)
        Timer.After(0.2, function()
            RefreshPreset(newSet + 1)
        end)
    end
end

EnchantManager:RegisterEvent("ADDON_LOADED")
EnchantManager:RegisterEvent("COMMENTATOR_SKIRMISH_QUEUE_REQUEST")
EnchantManager:RegisterEvent("LEARNED_SPELL_IN_TAB")
EnchantManager:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
EnchantManager:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == AddonName then
            AscensionUI.CDB.EnchantManager = AscensionUI.CDB.EnchantManager or {}
            EnchantManager.CDB = AscensionUI.CDB.EnchantManager
            EnchantManager.CDB.active = EnchantManager.CDB.active or 1
            EnchantManager.CDB.presets = EnchantManager.CDB.presets or {} -- name, icon, REData
        end
    elseif (event == "LEARNED_SPELL_IN_TAB") then
        M.Manager:SpellCheck()
    elseif (event == "COMMENTATOR_SKIRMISH_QUEUE_REQUEST") then
        local subEvent = ...
        if (EnchantManager[subEvent]) then
            EnchantManager[subEvent](...)
        end
    elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then
        local unit, spellName = ...
        if (unit == "player") and (M.Manager.SavePresetSpellNames[spellName]) then
            Timer.After(0.5, function()
                RefreshPreset(M.Manager.SavePresetSpellNames[spellName])
            end)
        end
    end
end)
EnchantManager:Show()
-------------------------------------------------------------------------------
--                              Communication                                --
-------------------------------------------------------------------------------

--[[local ManagerHandler = MSGR_Create("ASC_MYSTIC_ENCHANTMENTS") -- don't remove, a good example of how this can be done.

function ManagerHandler.SendPresetData(msg)
    print("SendPresetData run")
    print(msg)

    local setID = 0
    local setInfo = {}
    local setName = ""

    while SeperateMessage(msg, ":") do
        val, msg = SeperateMessage(msg, ":")
        val = tonumber(val)

        print(val)
    end

    setName = msg
    print(setName)

end

function ManagerHandler.SendActivePreset(msg)
    if not(tonumber(msg)) then
        print("ERROR. Index is not a number "..msg)
        return
    end

    msg = tonumber(msg)+1

    M.Manager:GetActivePreset(msg)
end

function ManagerHandler:Handle(msg)
    local f = string.match(msg, "^(%S+) ")

    if (ManagerHandler[f]) then
        local arg = string.match(msg, f.." (.*)$")
        ManagerHandler[f](arg)
    else
        print("ERROR. Opcode "..f.." not found in ManagerHandler")
    end
end

ManagerHandler:Init()]]
--
