local AddonName, Addon = ...
local MainFrame = CCUpgradeFrame
Addon.spellID = 100012
local bagID
local slotID
local shouldShow = false
local MAX_REAGENT_NUM = 8
local upgradeamount = 1

local function GetQualityString(quality)
    local qualityColor = ITEM_QUALITY_COLORS[quality or 1] -- Default to poor quality color if no quality specified
    local qualityName = _G["ITEM_QUALITY" .. quality .. "_DESC"] or "Poor"

    return qualityColor.hex .. qualityName .. "|r"
end

function MainFrame:CreateUI()
    -- Create the main frame
    self:SetPoint("TOP", ItemSocketingFrame)

    -- Create the item slot
    local itemSlot = CreateFrame("Button", "MySingleItemAddonItemSlot", self)
    MainFrame.itemSlot = itemSlot
    itemSlot:SetSize(30, 30)
    itemSlot:SetPoint("TOPRIGHT", -40, -40)
    -- itemSlot:SetAllPoints()
    itemSlot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local texture = itemSlot:CreateTexture([["Interface\Buttons\ButtonHilight-Square"]], "ARTWORK")
    texture:SetAllPoints() -- Set the texture size to match the button size
    itemSlot:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ARTWORK")
    local b = itemSlot:CreateTexture(nil, 'BACKGROUND')
    b:SetWidth(40)
    b:SetHeight(40)
    b:SetPoint('CENTER', itemSlot)
    b:SetTexture("Interface\\Buttons\\UI-EmptySlot")
    b:SetBlendMode('ADD')
    local border = itemSlot:CreateTexture(nil, 'OVERLAY')
    border:SetWidth(55)
    border:SetHeight(55)
    border:SetPoint('CENTER', itemSlot)
    border:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
    border:SetBlendMode('ADD')
    border:Hide()
    itemSlot.border = border

    itemSlot:SetScript("OnClick", function(self, button)
        if not MainFrame:IsVisible() then return end
        -- Handle clicks on the item slot
        if button == "LeftButton" and GetCursorInfo() then
            self:SetItemSlot()
            MainFrame:DisplayItemProperties()
            ClearCursor()
            -- elseif button == "RightButton" then
            --     texture:SetTexture(nil) -- Set the texture path
            --     itemSlot.bagID = nil
            --     itemSlot.slotID = nil
            --     itemSlot.link = nil
            --     MainFrame:DisplayItemProperties()
            --     itemSlot.border:Hide()
        end
    end)

    itemSlot:SetScript("OnReceiveDrag", function(self, button)
        self:SetItemSlot()
        MainFrame:DisplayItemProperties()
        ClearCursor()
    end)

    itemSlot:SetScript("OnEnter", function(self)
        if itemSlot.link then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:SetHyperlink(itemSlot.link)
        end
    end)
    itemSlot:SetScript("OnLeave", function(self)
        if itemSlot.link then
            GameTooltip:Hide()
        end
    end)

    function itemSlot:SetItemSlot()
        local type, id, info = GetCursorInfo()
        if type == "item" then
            local _, _, _, _, _, itemType = GetItemInfo(info)
            if (not (itemType == "Armor" or itemType == "Weapon")) then
                if not itemSlot.bagID then
                    CloseSocketInfo();
                end
                return
            end
            -- An item is being dragged onto the item slot
            -- print("Item dragged into the item slot:", info)
            itemSlot.bagID = bagID
            itemSlot.slotID = slotID
            itemSlot.link = info
            -- print(itemSlot.link)
            -- print(itemSlot.bagID, itemSlot.slotID)

            -- Display the icon in the item slot
            local tex = GetItemIcon(info)
            if tex then
                texture:SetTexture(tex)
            end

            local itemName, itemLink, quality, _, _, itemType, _, _, _, itemIcon = GetItemInfo(info)
            itemSlot:SetBorderQuality(quality)
            SetPortraitToTexture("CCUpgradeFramePortrait", tex);
            local scrollBarOffset = 28;
            if (CCUpgradeScrollFrame:GetVerticalScrollRange() ~= 0) then
                scrollBarOffset = 0;
            end
            CCUpgradeScrollFrame:SetWidth(269 + scrollBarOffset);
            -- CCUpgradeDescription:SetMinimumWidth(ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH + scrollBarOffset, 1);
            -- CCUpgradeDescription:SetOwner(CCUpgradeScrollChild, "ANCHOR_PRESERVE");
            -- CCUpgradeDescription:SetHyperlink(itemLink)
        end
    end

    function itemSlot:RefreshItem(force)
        local info;
        if (itemSlot.bagID == 255) then
            info = GetInventoryItemLink("player", itemSlot.slotID)
        else
            info = GetContainerItemLink(itemSlot.bagID, itemSlot.slotID)
        end


        if (not info) then
            HideUIPanel(ItemSocketingFrame);
            return
        end
        itemSlot.link = info
        -- print(itemSlot.bagID, itemSlot.slotID)

        -- Display the icon in the item slot
        local tex = GetItemIcon(info)
        if tex then
            texture:SetTexture(tex)
        end
        local itemName, itemLink, quality, _, _, itemType, _, _, _, itemIcon = GetItemInfo(info)
        itemSlot:SetBorderQuality(quality)
        -- SetPortraitToTexture("CCUpgradeFramePortrait", tex);
        MainFrame:DisplayItemProperties()
        local scrollBarOffset = 28;
        if (CCUpgradeScrollFrame:GetVerticalScrollRange() ~= 0) then
            scrollBarOffset = 0;
        end
        CCUpgradeScrollFrame:SetWidth(269 + scrollBarOffset);
        -- CCUpgradeDescription:SetMinimumWidth(ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH + scrollBarOffset, 1);
        -- CCUpgradeDescription:SetOwner(CCUpgradeScrollChild, "ANCHOR_PRESERVE");
        -- CCUpgradeDescription:SetHyperlink(itemLink)
        ItemSocketingFrame_Update();
    end

    function itemSlot:SetBorderQuality(quality)
        local border = self.border

        if quality and quality > 1 then
            local r, g, b = GetItemQualityColor(quality)
            border:SetVertexColor(r, g, b, 0.5)
            border:Show()
            return
        end

        border:Hide()
    end

    -- Create a label for displaying item properties
    local itemNameLabel = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local font, _, flags = itemNameLabel:GetFont()
    itemNameLabel:SetFont(font, 16, flags)
    itemNameLabel:SetPoint("BOTTOM", self, "TOP", -10, -120)
    itemNameLabel:SetText("Drag an item bitch")
    self.itemNameLabel = itemNameLabel

    local itemUpgradeLabel = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemUpgradeLabel:SetPoint("TOP", itemNameLabel, "BOTTOM", 0, -20)
    itemUpgradeLabel:SetText("")
    self.itemUpgradeLabel = itemUpgradeLabel
    local itemUpgradeQualityLabel = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemUpgradeQualityLabel:SetPoint("TOP", itemUpgradeLabel, "BOTTOM", 0, -10)
    itemUpgradeQualityLabel:SetText("")
    self.itemUpgradeQualityLabel = itemUpgradeQualityLabel

    local upgradeAmountLabel = CCUpgradeAmount:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
    upgradeAmountLabel:SetAllPoints()
    upgradeAmountLabel:SetText(upgradeamount)
    self.upgradeAmountLabel = upgradeAmountLabel

    local warningLevelLabel = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    warningLevelLabel:SetPoint("TOP", itemUpgradeQualityLabel, "BOTTOM", 0, -20)
    warningLevelLabel:SetText("Player level too low for this upgrade")
    warningLevelLabel:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
    self.warningLevelLabel = warningLevelLabel

    local upgradeButton = Addon.GenericCreateButton("MySingleItemAddonItemSlot", self, 162, 22, "GameFontNormal",
        "Enhance", "CENTER", nil, 1)
    upgradeButton:SetSize(80, 22)
    upgradeButton:SetPoint("BOTTOMRIGHT", -38, 80)
    upgradeButton:Disable()
    upgradeButton:SetScript("OnClick", function()
        local _, _, quality, ilvl = GetItemInfo(itemSlot.link)
        for i = 1, upgradeamount, 1 do
            ilvl, quality = NextItemUpgrade(ilvl, quality)
        end
        CastItemUpgrade(itemSlot.bagID, itemSlot.slotID, ilvl, quality);
    end)
    self.upgradeButton = upgradeButton

    PanelTemplates_SetNumTabs(CCUpgradeTabFrame, 2);
    PanelTemplates_SetTab(CCUpgradeTabFrame, 2);

    CCUpgradeFrameCloseButton:SetScript("OnClick", function() HideUIPanel(ItemSocketingFrame); end)
end

function MainFrame:SetReagents()
    local link = MainFrame.itemSlot.link
    if not link then return end -- temporary

    local itemID = tonumber(string.match(link, "item:(%d+):"))
    local iname, _, q, ilvl = GetItemInfo(link)
    local invtype = select(9, GetItemInfo(link));

    local target_ilvl = ilvl
    for i = 1, upgradeamount, 1 do
        target_ilvl, q = NextItemUpgrade(target_ilvl, q)
    end

    -- Reagents
    local mats = GenerateMaterialRequirements(iname, ilvl, q, ITEM_INVTYPE_IDS[invtype], target_ilvl)

    -- extra ones for testing
    -- table.insert(mats, { material = mats[1].material, count = mats[1].count })
    -- table.insert(mats, { material = mats[#mats].material, count = mats[#mats].count })

    local numReagents = #mats
    local ready = true;

    for i = 1, numReagents, 1 do
        local mat = mats[i]
        -- itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture
        local reagentName, _, _, _, _, _, _, _, _, reagentTexture = GetItemInfo(mat.material)
        local reagentCount = mat.count
        local playerReagentCount = GetItemCount(mat.material)
        local reagent = _G["CCUpgradeMatsReagent" .. i]
        reagent:SetID(mat.material)
        local name = _G["CCUpgradeMatsReagent" .. i .. "Name"];
        local count = _G["CCUpgradeMatsReagent" .. i .. "Count"];
        if (not reagentName or not reagentTexture) then
            reagent:Hide();
        else
            reagent:Show();
            SetItemButtonTexture(reagent, reagentTexture);
            name:SetText(reagentName);
            -- Grayout items
            if (playerReagentCount < reagentCount) then
                SetItemButtonTextureVertexColor(reagent, 0.5, 0.5, 0.5);
                name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
                creatable = nil;
                ready = false;
            else
                SetItemButtonTextureVertexColor(reagent, 1.0, 1.0, 1.0);
                name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
            end
            if (playerReagentCount >= 100) then
                playerReagentCount = "*";
            end
            count:SetText(playerReagentCount .. " /" .. reagentCount);
        end
    end
    -- Place reagent label
    local reagentToAnchorTo = numReagents;
    if ((numReagents > 0) and (mod(numReagents, 2) == 0)) then
        reagentToAnchorTo = reagentToAnchorTo - 1;
    end

    for i = numReagents + 1, MAX_REAGENT_NUM, 1 do
        _G["CCUpgradeMatsReagent" .. i]:Hide();
    end

    if ready then self.upgradeButton:Enable(); else self.upgradeButton:Disable(); end
end

function MainFrame:DisplayItemProperties()
    local link = MainFrame.itemSlot.link
    if link then
        -- An item is in the item slot
        local itemName, itemLink, quality, ilvl, _, itemType, _, _, _, itemIcon = GetItemInfo(link)
        if (not (itemType == "Armor" or itemType == "Weapon")) then
            return
        end
        -- Display item properties in the label
        local itemPropertiesLabel = self.itemNameLabel
        local color = ITEM_QUALITY_COLORS[quality or 1] -- Default to poor quality color if no quality specified
        itemPropertiesLabel:SetTextColor(color.r, color.g, color.b)
        itemPropertiesLabel:SetText(itemName)
        local next_ilvl = ilvl
        local next_quality = quality
        for i = 1, upgradeamount, 1 do
            next_ilvl, next_quality = NextItemUpgrade(next_ilvl, next_quality)
        end
        if next_ilvl == ilvl then
            self.itemUpgradeLabel:SetText("|cffffffffItem Level " .. ilvl .. "|r")
        else
            self.itemUpgradeLabel:SetText("|cffffffffItem Level " ..
                ilvl .. "|r >> " .. "|cff00ff00" .. next_ilvl .. "|r")
        end

        if quality == next_quality then
            self.itemUpgradeQualityLabel:SetText(GetQualityString(quality))
        else
            self.itemUpgradeQualityLabel:SetText(GetQualityString(quality) .. " >> " .. GetQualityString(next_quality))
        end

        if (next_ilvl > UnitLevel("player") + 5 and UnitLevel("player") ~= 60) then
            self.upgradeButton:Disable();
            self.warningLevelLabel:Show();
            self.warningLevelLabel:SetText("Requires level " .. (next_ilvl - 5));
        else
            self.upgradeButton:Enable()
            self.warningLevelLabel:Hide();
        end


        MainFrame:SetReagents()
    else
        self.itemNameLabel:SetText("Drag an item bitch")
        self.itemUpgradeLabel:SetText("")
        self.upgradeButton:Disable()
    end
end

function HooksSetup()
    hooksecurefunc('ContainerFrameItemButton_OnClick', function(frame)
        bagID = frame:GetParent():GetID()
        slotID = frame:GetID()
    end)

    hooksecurefunc('ContainerFrameItemButton_OnDrag', function(frame)
        bagID = frame:GetParent():GetID()
        slotID = frame:GetID()
    end)

    hooksecurefunc('PaperDollItemSlotButton_OnClick', function(frame)
        bagID = 255
        slotID = frame:GetID()
    end)
    ITEM_SOCKETABLE = ""
    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        if not shouldShow then return end
        local name, link = self:GetItem()
        local _, _, _, _, _, itemType = GetItemInfo(link)

        if (itemType == "Armor" or itemType == "Weapon") then
            self:AddLine(GREEN_FONT_COLOR_CODE .. "<Shift Right Click to Modify>")
        end
    end)


    local old_ContainerFrameItemButton_OnModifiedClick = ContainerFrameItemButton_OnModifiedClick
    function ContainerFrameItemButton_OnModifiedClick(frame, button)
        if IsShiftKeyDown() and button == "RightButton" then
            bagID = frame:GetParent():GetID()
            slotID = frame:GetID()
            if (not GetContainerItemInfo(bagID, slotID)) then return end
            local _, _, _, _, _, itemType = GetItemInfo(select(7, GetContainerItemInfo(bagID, slotID)))
            if (not (itemType == "Armor" or itemType == "Weapon")) then
                return
            end
            CloseSocketInfo()
            ItemSocketingFrame_Update();

            SocketContainerItem(bagID, slotID);
            if not GetSocketItemInfo() then
                PanelTemplates_DisableTab(CCUpgradeTabFrame, 1)
            else
                PanelTemplates_EnableTab(CCUpgradeTabFrame, 1)
            end
            CloseSocketInfo()

            if (not ItemSocketingFrame:IsShown()) then
                ShowUIPanel(ItemSocketingFrame);
            end

            PanelTemplates_SetTab(CCUpgradeTabFrame, 2);
            MainFrame:Show()
            upgradeamount = 1;
            PickupContainerItem(bagID, slotID);

            MainFrame.itemSlot:Click("LeftButton");
            SocketContainerItem(bagID, slotID);
            UpdageUpgradeAmount();
            return
        end
        old_ContainerFrameItemButton_OnModifiedClick(frame, button)
    end

    local old_PaperDollItemSlotButton_OnModifiedClick = PaperDollItemSlotButton_OnModifiedClick
    function PaperDollItemSlotButton_OnModifiedClick(frame, button)
        if IsShiftKeyDown() and button == "RightButton" then
            bagID = 255
            slotID = frame:GetID()
            if (not GetInventoryItemID("player", slotID)) then return end

            CloseSocketInfo()
            ItemSocketingFrame_Update();

            SocketInventoryItem(frame:GetID());
            if not GetSocketItemInfo() then
                PanelTemplates_DisableTab(CCUpgradeTabFrame, 1)
            else
                PanelTemplates_EnableTab(CCUpgradeTabFrame, 1)
            end
            CloseSocketInfo()

            if (not ItemSocketingFrame:IsShown()) then
                ShowUIPanel(ItemSocketingFrame);
            end

            PanelTemplates_SetTab(CCUpgradeTabFrame, 2);
            MainFrame:Show()
            upgradeamount = 1;

            PickupInventoryItem(frame:GetID());

            MainFrame.itemSlot:Click("LeftButton");
            SocketInventoryItem(frame:GetID());
            UpdageUpgradeAmount();
            return
        end


        old_PaperDollItemSlotButton_OnModifiedClick(frame, button)
    end

    local old_ContainerFrameItemButton_OnEnter = ContainerFrameItemButton_OnEnter
    function ContainerFrameItemButton_OnEnter(self)
        shouldShow = true
        old_ContainerFrameItemButton_OnEnter(self)
    end

    local old_PaperDollItemSlotButton_OnEnter = PaperDollItemSlotButton_OnEnter
    function PaperDollItemSlotButton_OnEnter(self)
        shouldShow = true
        old_PaperDollItemSlotButton_OnEnter(self)
    end

    local originalHideFunc = GameTooltip.Hide
    GameTooltip.Hide = function(self)
        shouldShow = false
        originalHideFunc(self)
    end

    function MainFrame.OnEvent(self, event, ...)
        if (event == "UNIT_SPELLCAST_START") then
            local unit, spellName = ...
            if (unit == "player") and spellName == "Tempering" then
                MainFrame.upgradeButton:Disable();
                MainFrame.TimeSinceLastUpdate = -1000 -- Delay update till cast
            end
        end

        if (event == "UNIT_SPELLCAST_SUCCEEDED") then
            local unit, spellName = ...
            if (unit == "player") and spellName == "Tempering" then
                self.TimeSinceLastUpdate = 0
                PlaySound(3084);
                upgradeamount = 1;
                UpdageUpgradeAmount();
            end
        end

        if (event == "UNIT_SPELLCAST_STOP") then
            local unit, spellName = ...
            if (unit == "player") and spellName == "Tempering" then
                MainFrame.itemSlot:RefreshItem(true)
                self.TimeSinceLastUpdate = 0.3
            end
        end

        if event == 'GET_ITEM_INFO_RECIEVED' then
            print("ITEM RECEIVED")
        end
    end

    MainFrame.TimeSinceLastUpdate = 0
    function MainFrame.OnUpdate(self, elapsed)
        self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
        if (self.TimeSinceLastUpdate > 0.1) then
            MainFrame.itemSlot:RefreshItem()
            self.TimeSinceLastUpdate = 0;
        end
    end
end

function CCUpgradeFrameDecrement_OnClick()
    upgradeamount = upgradeamount - 1;
    if (upgradeamount < 1) then upgradeamount = 1; end

    UpdageUpgradeAmount()
end

function CCUpgradeFrameIncrement_OnClick()
    upgradeamount = upgradeamount + 1;
    if (upgradeamount < 1) then upgradeamount = 1; end

    UpdageUpgradeAmount()
end

function UpdageUpgradeAmount()
    local link = MainFrame.itemSlot.link
    if link then
        -- An item is in the item slot
        local _, _, quality, ilvl = GetItemInfo(link)
        for i = 1, upgradeamount, 1 do
            ilvl, quality = NextItemUpgrade(ilvl, quality)
        end

        if (65 <= ilvl) then
            CCUpgradeIncrementButton:Disable()
        else
            CCUpgradeIncrementButton:Enable()
        end
    end

    if upgradeamount == 1 then
        CCUpgradeDecrementButton:Disable()
    else
        CCUpgradeDecrementButton:Enable()
    end

    MainFrame.upgradeAmountLabel:SetText(upgradeamount)
end

MainFrame:CreateUI()
HooksSetup()
MainFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
MainFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
MainFrame:RegisterEvent("UNIT_SPELLCAST_START")
MainFrame:SetScript("OnEvent", MainFrame.OnEvent)
MainFrame:SetScript("OnUpdate", MainFrame.OnUpdate)
