local _G                  = getfenv(0)
local string              = _G.string
local table               = _G.table
local pairs               = _G.pairs
local ns                  = select(2, ...)

local SetTextColor        = ns.SetTextColor
local GenericCreateButton = ns.GenericCreateButton
local SetTooltipScripts   = ns.SetTooltipScripts


local MainPanel = TradeSkillFrame

function MainPanel:FiterInit()
    local FilterPanel = CreateFrame("Frame", nil, MainPanel)
    FilterPanel:SetWidth(300)
    FilterPanel:SetHeight(290)
    FilterPanel:SetFrameStrata("HIGH")
    FilterPanel:SetPoint("TOPRIGHT", MainPanel, "TOPRIGHT", -45, -125)
    FilterPanel:EnableMouse(true)
    FilterPanel:EnableKeyboard(true)
    FilterPanel:SetMovable(false)
    FilterPanel:SetHitRectInsets(5, 5, 5, 5)
    FilterPanel.scrollSize = 800

    FilterPanel.scrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", FilterPanel, "UIPanelScrollFrameTemplate");
    FilterPanel.scrollFrame:SetHeight(FilterPanel:GetHeight())
    FilterPanel.scrollBar = _G[FilterPanel.scrollFrame:GetName() .. "ScrollBar"];
    FilterPanel.scrollFrame:SetWidth(FilterPanel:GetWidth());
    FilterPanel.scrollFrame:SetPoint("TOPLEFT", 0, -10);
    FilterPanel.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10);

    FilterPanel.scrollChild = CreateFrame("Frame", "$parent_ScrollChild", FilterPanel.scrollFrame);
    FilterPanel.scrollChild:SetHeight(FilterPanel.scrollSize);
    FilterPanel.scrollChild:SetWidth(FilterPanel.scrollFrame:GetWidth() - 28);
    FilterPanel.scrollChild:SetAllPoints(FilterPanel.scrollFrame);
    FilterPanel.scrollFrame:SetScrollChild(FilterPanel.scrollChild);
    FilterPanel:Hide()

    -- FilterPanel:SetScript("OnShow", UpdateFilterMarks)

    FilterPanel.submenus = {}

    function FilterPanel:OrderSubmenus()
        local prevMenu = nil
        for name, submenu in ipairs(self.submenus) do
            if submenu:IsShown() then
                if (prevMenu == nil) then
                    submenu:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 0, 0)
                else
                    submenu:SetPoint("TOPLEFT", prevMenu, "BOTTOMLEFT", 0, 0)
                end
                prevMenu = submenu
            end
        end
    end

    function FilterPanel:CreateSubMenu(name, height)
        local submenu = CreateFrame("Frame", nil, self.scrollChild)

        submenu:SetWidth(self.scrollChild:GetWidth())
        submenu:SetHeight(height)
        submenu:EnableMouse(true)
        submenu:EnableKeyboard(true)
        submenu:SetMovable(false)


        --submenu:Hide()
        self.submenus[name] = submenu
        table.insert(self.submenus, submenu)

        -- self[name] = submenu

        return submenu
    end

    MainPanel.filter_menu = FilterPanel
    MainPanel.hide_header = false

    -------------------------------------------------------------------------------
    -- Create the Item level filter
    -------------------------------------------------------------------------------
    local filter_frame = FilterPanel:CreateSubMenu("itemlevel", 40)
    local min = ns.CreateEditBox("min", "min", filter_frame, "Min lvl", "Min lvl", 2, true, 80)
    local minresbutton = CreateFrame("Button", "minres", min)
    minresbutton:SetWidth(38); minresbutton:SetHeight(38)
    minresbutton:SetNormalTexture([[Interface\Buttons\CancelButton-Up]])
    minresbutton:SetPushedTexture([[Interface\Buttons\CancelButton-Down]])
    minresbutton:SetHighlightTexture([[Interface\Buttons\CancelButton-Highlight]], "ADD")
    minresbutton:SetScript("OnClick", function(self)
        min:SetText("")
        min:ClearFocus()
    end)
    minresbutton:SetPoint("LEFT", min, "RIGHT", -5, -2)
    local max = ns.CreateEditBox("max", "max", filter_frame, "Max lvl", "Max lvl", 2, true, 80)
    local maxresbutton = CreateFrame("Button", "minres", max)
    maxresbutton:SetWidth(38); maxresbutton:SetHeight(38)
    maxresbutton:SetNormalTexture([[Interface\Buttons\CancelButton-Up]])
    maxresbutton:SetPushedTexture([[Interface\Buttons\CancelButton-Down]])
    maxresbutton:SetHighlightTexture([[Interface\Buttons\CancelButton-Highlight]], "ADD")
    maxresbutton:SetScript("OnClick", function(self)
        max:SetText("")
        max:ClearFocus()
    end)
    maxresbutton:SetPoint("LEFT", max, "RIGHT", -5, -2)
    min:SetPoint("TOPLEFT", filter_frame, "TOPLEFT", 20, -20)
    max:SetPoint("TOPLEFT", min, "TOPRIGHT", 60, 0)
    filter_frame.min = min
    filter_frame.max = max
    function filter_frame:Filter(itemLink)
        local itemID = string.match(itemLink, "item:(%d*)")
        local itemName, itemLink, itemQuality, itemLevel, itemMinLevel = GetItemInfo(itemID)
        local min = filter_frame.min:GetNumber()
        local max = filter_frame.max:GetNumber()

        if (max == 0 and min == 0) then return false end
        if (min > 0 and max == 0) then
            return not (itemMinLevel >= min)
        end
        if (max > 0 and min == 0) then
            return not (itemMinLevel <= max)
        end

        if (max < min) then return false end

        return not (itemMinLevel >= min and itemMinLevel <= max)
    end

    -------------------------------------------------------------------------------
    -- Create the Quality toggle and CheckButtons
    -------------------------------------------------------------------------------
    local checkbox_frame = FilterPanel:CreateSubMenu("quality", 80)
    local quality_toggle = ns.GenericClearButton(nil, checkbox_frame, 20, 105, "GameFontNormal", "Quality" .. ":",
        "LEFT",
        "Clear quality", 0)
    checkbox_frame.quality_toggle = quality_toggle

    ns.GenerateCheckBoxes(checkbox_frame, ns.item_qualities, 2)
    function checkbox_frame:Filter(itemLink)
        local itemID = string.match(itemLink, "item:(%d*)")
        local _, _, itemQuality = GetItemInfo(itemID)
        local skipQuality = false
        local allNil = true
        for _, value in ipairs(self) do
            if (value:GetChecked() ~= nil) then allNil = false end

            if (value.script_val == itemQuality and value:GetChecked() == nil) then
                skipQuality = true
            end
        end
        if (allNil) then skipQuality = false end

        return skipQuality
    end

    -------------------------------------------------------------------------------
    -- Create the Stats toggle and CheckButtons
    -------------------------------------------------------------------------------
    local checkbox_frame = FilterPanel:CreateSubMenu("stats", 140)

    local stat_toggle = ns.GenericClearButton(nil, checkbox_frame, 20, 105, "GameFontNormal", "Stats:", "LEFT",
        "Clear stats", 0)

    ns.GenerateCheckBoxes(checkbox_frame, ns.item_stats, 3)
    function checkbox_frame:Filter(itemLink)
        local skipStats = false
        local itemStats = GetItemStats(itemLink)
        if (itemStats == nil) then return false end
        local allNil = true
        for _, value in ipairs(self) do
            if (value:GetChecked() ~= nil) then allNil = false end

            if (itemStats[value.script_val] == nil and value:GetChecked()) then
                skipStats = true
            end
        end
        if (allNil) then skipStats = false end

        return skipStats
    end

    checkbox_frame.stat_toggle = stat_toggle

    FilterPanel:OrderSubmenus()
end

local function Toggle_OnClick(self, button, down)
    -- The first time this button is clicked, everything in the expanded section of the MainPanel must be created.

    SetTooltipScripts(self, MainPanel.is_expanded and "Open fitler panel" or "Close filter panel")

    MainPanel:ToggleState()
    MainPanel.filter_toggle:SetTextures()
end

do                                                           -- intialization of expansion frame
    TradeSkillFrame:SetAttribute("UIPanelLayout-width", 695) --orig 384
    TradeSkillFrame:SetWidth(695)

    -- Move the skill rank string

    TradeSkillRankFrameSkillRank:ClearAllPoints()
    TradeSkillRankFrameSkillRank:SetPoint("CENTER", TradeSkillRankFrame, 0, 1)

    --Move the "Have Available" checkbox
    TradeSkillFrameAvailableFilterCheckButton:ClearAllPoints()
    TradeSkillFrameAvailableFilterCheckButton:SetPoint("TOPLEFT", 70, -50)

    --Tradeskill skills list
    TradeSkillSkill1:ClearAllPoints()
    TradeSkillSkill1:SetPoint("TOPLEFT", 22, -100)
    TradeSkillListScrollFrame:ClearAllPoints()
    TradeSkillListScrollFrame:SetPoint("TOPLEFT", 22, -96)

    --Move the editbox and expand it
    TradeSkillFrameEditBox:ClearAllPoints()
    TradeSkillFrameEditBox:SetPoint("TOPLEFT", 77, -72)
    TradeSkillFrameEditBox:SetWidth(150)
    --Add a reset button to the editbox
    local resbutton = CreateFrame("Button", "TradeSkillFrameEditBoxResetButton", TradeSkillFrameEditBox)
    resbutton:SetWidth(38); resbutton:SetHeight(38)
    resbutton:SetNormalTexture([[Interface\Buttons\CancelButton-Up]])
    resbutton:SetPushedTexture([[Interface\Buttons\CancelButton-Down]])
    resbutton:SetHighlightTexture([[Interface\Buttons\CancelButton-Highlight]], "ADD")
    resbutton:SetScript("OnClick", function(self)
        if TradeSkillFrameEditBox:HasFocus() then
            TradeSkillFrameEditBox:SetText("")
        else
            TradeSkillFrameEditBox:SetText(SEARCH)
        end
    end)
    resbutton:SetPoint("LEFT", TradeSkillFrameEditBox, "RIGHT", -5, -2)

    local filter_toggle = GenericCreateButton(nil, TradeSkillFrame, 24, 24, nil, nil,
        nil,
        "Filter", 2)
    filter_toggle.text = filter_toggle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    filter_toggle.text:SetPoint("RIGHT", filter_toggle, "LEFT", 0, 0)
    filter_toggle.text:SetText("Filter")

    filter_toggle:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -44, -67)
    filter_toggle:SetScript("OnClick", Toggle_OnClick)
    filter_toggle:SetHighlightTexture([[Interface\CHATFRAME\UI-ChatIcon-BlinkHilight]])
    filter_toggle:SetText("Filter")
    SetTooltipScripts(filter_toggle, MainPanel.is_expanded and "Open fitler panel" or "Close filter panel")

    function filter_toggle:SetTextures()
        if MainPanel.is_expanded then
            self:SetNormalTexture([[Interface\BUTTONS\UI-SpellbookIcon-PrevPage-Up]])
            self:SetPushedTexture([[Interface\BUTTONS\UI-SpellbookIcon-PrevPage-Down]])
            self:SetDisabledTexture([[Interface\BUTTONS\UI-SpellbookIcon-PrevPage-Disabled]])
        else
            self:SetNormalTexture([[Interface\BUTTONS\UI-SpellbookIcon-NextPage-Up]])
            self:SetPushedTexture([[Interface\BUTTONS\UI-SpellbookIcon-NextPage-Down]])
            self:SetDisabledTexture([[Interface\BUTTONS\UI-SpellbookIcon-NextPage-Disabled]])
        end
    end

    TradeSkillInvSlotDropDown:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -185, -100)
    TradeSkillSubClassDropDown:SetPoint("TOPLEFT", TradeSkillInvSlotDropDown, "TOPRIGHT", -20, 0)
    TradeSkillInvSlotDropDown:Hide()
    TradeSkillSubClassDropDown:Hide()

    filter_toggle:SetTextures()
    MainPanel.filter_toggle = filter_toggle


    TRADE_SKILLS_DISPLAYED = 19

    CreateFrame("Button", "TradeSkillSkill9", TradeSkillFrame, "TradeSkillSkillButtonTemplate"):SetPoint("TOPLEFT",
        TradeSkillSkill8, "BOTTOMLEFT")
    CreateFrame("Button", "TradeSkillSkill10", TradeSkillFrame, "TradeSkillSkillButtonTemplate"):SetPoint("TOPLEFT",
        TradeSkillSkill9, "BOTTOMLEFT")
    CreateFrame("Button", "TradeSkillSkill11", TradeSkillFrame, "TradeSkillSkillButtonTemplate"):SetPoint("TOPLEFT",
        TradeSkillSkill10, "BOTTOMLEFT")
    CreateFrame("Button", "TradeSkillSkill12", TradeSkillFrame, "TradeSkillSkillButtonTemplate"):SetPoint("TOPLEFT",
        TradeSkillSkill11, "BOTTOMLEFT")
    CreateFrame("Button", "TradeSkillSkill13", TradeSkillFrame, "TradeSkillSkillButtonTemplate"):SetPoint("TOPLEFT",
        TradeSkillSkill12, "BOTTOMLEFT")
    CreateFrame("Button", "TradeSkillSkill14", TradeSkillFrame, "TradeSkillSkillButtonTemplate"):SetPoint("TOPLEFT",
        TradeSkillSkill13, "BOTTOMLEFT")
    CreateFrame("Button", "TradeSkillSkill15", TradeSkillFrame, "TradeSkillSkillButtonTemplate"):SetPoint("TOPLEFT",
        TradeSkillSkill14, "BOTTOMLEFT")
    CreateFrame("Button", "TradeSkillSkill16", TradeSkillFrame, "TradeSkillSkillButtonTemplate"):SetPoint("TOPLEFT",
        TradeSkillSkill15, "BOTTOMLEFT")
    CreateFrame("Button", "TradeSkillSkill17", TradeSkillFrame, "TradeSkillSkillButtonTemplate"):SetPoint("TOPLEFT",
        TradeSkillSkill16, "BOTTOMLEFT")
    CreateFrame("Button", "TradeSkillSkill18", TradeSkillFrame, "TradeSkillSkillButtonTemplate"):SetPoint("TOPLEFT",
        TradeSkillSkill17, "BOTTOMLEFT")
    CreateFrame("Button", "TradeSkillSkill19", TradeSkillFrame, "TradeSkillSkillButtonTemplate"):SetPoint("TOPLEFT",
        TradeSkillSkill18, "BOTTOMLEFT")

    --Tradeskill skills list
    TradeSkillSkill1:ClearAllPoints()
    TradeSkillSkill1:SetPoint("TOPLEFT", 22, -100)
    TradeSkillListScrollFrame:ClearAllPoints()
    TradeSkillListScrollFrame:SetPoint("TOPLEFT", 22, -96)
    TradeSkillListScrollFrame:SetHeight(310)



    --The stuff which shows reagents and what produced
    TradeSkillDetailScrollFrame:ClearAllPoints();
    TradeSkillDetailScrollFrame:SetPoint("TOPLEFT", TradeSkillListScrollFrame, "TOPRIGHT", 35, -2)
    TradeSkillDetailScrollFrame:SetWidth(298)
    TradeSkillDetailScrollFrame:SetHeight(310)

    --Move the exit button to bottom left
    TradeSkillCancelButton:ClearAllPoints()
    TradeSkillCancelButton:SetPoint("CENTER", TradeSkillFrame, "TOPLEFT", 613, -422)

    --Texture mucking about now
    for i, region in ipairs({ TradeSkillFrame:GetRegions() }) do
        if region:IsObjectType("Texture") then
            if region:GetTexture() == [[Interface\ClassTrainerFrame\UI-ClassTrainer-HorizontalBar]] then
                region:Hide()
            end
        end
    end


    --Add the mid section by messing with glue and newspaper clippings
    local function CreateTex(parent, tex, layer, width, height, ...)
        local texf = parent:CreateTexture(nil, layer)
        texf:SetPoint(...)
        texf:SetTexture(tex)
        texf:SetWidth(width); texf:SetHeight(height)
        return texf
    end

    --Scrollbar fix
    CreateTex(TradeSkillListScrollFrame, [[Interface\ClassTrainerFrame\UI-ClassTrainer-ScrollBar]], "BACKGROUND", 30,
        97.4,
        "LEFT", TradeSkillListScrollFrame, "RIGHT", -3, 0):SetTexCoord(0, 0.46875, 0.2, 0.9609375)

    --for these textures we need to fill 311 pixels
    --Top filling in
    local top1 = CreateTex(TradeSkillFrame, [[Interface\AddOns\CraftCraft_tradeskill_filter\Textures\Top]], "BORDER",
        311, 256,
        "TOPLEFT",
        256, 0)
    local bot1 = CreateTex(TradeSkillFrame, [[Interface\AddOns\CraftCraft_tradeskill_filter\Textures\Bot]],
        "BORDER",
        311, 256,
        "BOTTOMLEFT", TradeSkillFrameBottomLeftTexture, "BOTTOMRIGHT")


    local top = CreateTex(TradeSkillFrame, [[Interface\AddOns\CraftCraft_tradeskill_filter\Textures\Top]], "BORDER",
        311, 256,
        "TOPLEFT",
        top1, "TOPRIGHT")
    MainPanel.topTex = top
    top:Hide()

    --bottom filling in
    local bot = CreateTex(TradeSkillFrame, [[Interface\AddOns\CraftCraft_tradeskill_filter\Textures\Bot]],
        "BORDER",
        311, 256,
        "BOTTOMLEFT", bot1, "BOTTOMRIGHT", 0, 0)
    bot:Hide()
    MainPanel.botTex = bot
    MainPanel.botinnerTex = bot1

    TradeSkillFrameBottomRightTexture:SetTexture([[Interface\PaperDollInfoFrame\SkillFrame-BotRight]])

    MainPanel:FiterInit()

    local orig = TradeSkillFrame_SetSelection
    local function SetSelectionHelper(...)
        if IsTradeSkillLinked() then
            bot:SetTexture([[Interface\AddOns\DoubleWideProfession\Textures\InspectBot]])
        else
            if (MainPanel.is_expanded) then
                bot:SetTexture([[Interface\AddOns\DoubleWideProfession\Textures\InspectBot]])
                TradeSkillFrameBottomRightTexture:SetTexture([[Interface\PaperDollInfoFrame\SkillFrame-BotRight]])
            else
                bot:SetTexture([[Interface\AddOns\DoubleWideProfession\Textures\InspectBot]])
                TradeSkillFrameBottomRightTexture:SetTexture([[Interface\PaperDollInfoFrame\SkillFrame-BotRight]])
            end
        end
        return ...
    end

    function TradeSkillFrame_SetSelection(...)
        return SetSelectionHelper(orig(...))
    end
end -- do block

MainPanel.is_expanded = false

function MainPanel:ToggleState()
    if self.is_expanded then
        PlaySound("igCharacterInfoClose")
    else
        PlaySound("igCharacterInfoOpen")
    end
    self.is_expanded = not self.is_expanded

    if self.is_expanded then
        TradeSkillFrameBottomRightTexture:SetTexture([[Interface\PaperDollInfoFrame\SkillFrame-BotRight]])
        self:SetAttribute("UIPanelLayout-width", 695 + 311) --orig 384
        self:SetWidth(695 + 311)
        --Move the exit button to bottom left
        TradeSkillCancelButton:ClearAllPoints()
        TradeSkillCancelButton:SetPoint("CENTER", self, "TOPLEFT", 613 + 311, -422)
        MainPanel.topTex:Show()
        MainPanel.botTex:Show()
        MainPanel.filter_menu:Show()
        TradeSkillInvSlotDropDown:Show()
        TradeSkillSubClassDropDown:Show()
    else
        TradeSkillFrameBottomRightTexture:SetTexture([[Interface\PaperDollInfoFrame\SkillFrame-BotRight]])
        self:SetAttribute("UIPanelLayout-width", 384 + 311) --orig 384

        self:SetWidth(384 + 311)
        -- MainPanel.botTex:SetTexture([[Interface\PaperDollInfoFrame\SkillFrame-BotRight]])
        MainPanel.topTex:Hide()
        MainPanel.botTex:Hide()
        MainPanel.filter_menu:Hide()
        TradeSkillCancelButton:ClearAllPoints()
        TradeSkillCancelButton:SetPoint("CENTER", self, "TOPLEFT", 305 + 311, -422)
        TradeSkillInvSlotDropDown:Hide()
        TradeSkillSubClassDropDown:Hide()
    end
end

local shown = false
function MainPanel.OnEvent(self, event, ...)
    if (event == "PLAYER_ENTER_COMBAT") then
        shown = MainPanel:IsShown();
        MainPanel:Hide();
    end
    if (event == "PLAYER_LEAVE_COMBAT") then
        if (shown) then
            MainPanel:Show();
        end
    end
end

MainPanel:RegisterEvent("PLAYER_ENTER_COMBAT")
MainPanel:RegisterEvent("PLAYER_LEAVE_COMBAT")
-- MainPanel:SetScript("OnEvent", MainPanel.OnEvent)
-- MainPanel:HookScript("OnShow", function() if InCombatLockdown() then MainPanel:Hide() end end);
