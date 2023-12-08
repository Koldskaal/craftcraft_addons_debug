local AddonName, Addon = ...
local MainFrame = CCUpgradeFrame
Addon.spellID = 100012
local bagID
local slotID

function MainFrame:CreateUI()
    -- Create the main frame
    self:SetPoint("TOP", ItemSocketingFrame)

    -- Create the item slot
    local itemSlot = CreateFrame("Button", "MySingleItemAddonItemSlot", self)
    MainFrame.itemSlot = itemSlot
    itemSlot:SetSize(60, 60)
    itemSlot:SetPoint("TOP", -10, -120)
    -- itemSlot:SetAllPoints()
    itemSlot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local texture = itemSlot:CreateTexture([["Interface\Buttons\ButtonHilight-Square"]], "ARTWORK")
    texture:SetAllPoints() -- Set the texture size to match the button size
    itemSlot:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ARTWORK")
    local b = itemSlot:CreateTexture(nil, 'BACKGROUND')
    b:SetWidth(90)
    b:SetHeight(90)
    b:SetPoint('CENTER', itemSlot)
    b:SetTexture("Interface\\Buttons\\UI-EmptySlot")
    b:SetBlendMode('ADD')
    local border = itemSlot:CreateTexture(nil, 'OVERLAY')
    border:SetWidth(105)
    border:SetHeight(105)
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
        end
    end

    function itemSlot:RefreshItem(force)
        local info;
        if (itemSlot.bagID == 255) then
            info = GetInventoryItemLink("player", itemSlot.slotID)
        else
            info = GetContainerItemLink(itemSlot.bagID, itemSlot.slotID)
        end
        if (info == itemSlot.link and not force) then return end
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
    itemNameLabel:SetPoint("BOTTOM", itemSlot, "TOP", 0, 10)
    itemNameLabel:SetText("Drag an item bitch")
    self.itemNameLabel = itemNameLabel

    local itemUpgradeLabel = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemUpgradeLabel:SetPoint("TOP", itemSlot, "BOTTOM", 0, -10)
    itemUpgradeLabel:SetText("")
    self.itemUpgradeLabel = itemUpgradeLabel

    local upgradeButton = CreateFrame("Button", "MySingleItemAddonItemSlot", self, "UIPanelButtonTemplate")
    upgradeButton:SetSize(200, 50)
    upgradeButton:SetPoint("BOTTOM", -10, 100)
    upgradeButton:SetText("Enhance")
    upgradeButton:Disable()
    upgradeButton:SetScript("OnClick", function()
        local itemName, itemLink, qual, ilvl, _, itemType, _, _, _, itemIcon = GetItemInfo(itemSlot.link)
        CastItemUpgrade(itemSlot.bagID, itemSlot.slotID, qual, ilvl + 5)
        upgradeButton:Disable()
        MainFrame.TimeSinceLastUpdate = -1000 -- Delay update till cast
    end)
    self.upgradeButton = upgradeButton

    PanelTemplates_SetNumTabs(CCUpgradeTabFrame, 2);
    PanelTemplates_SetTab(CCUpgradeTabFrame, 2);

    CCUpgradeFrameCloseButton:SetScript("OnClick", function() HideUIPanel(ItemSocketingFrame); end)
end

function MainFrame:DisplayItemProperties()
    local link = MainFrame.itemSlot.link
    if link then
        -- An item is in the item slot
        local itemName, itemLink, _, ilvl, _, itemType, _, _, _, itemIcon = GetItemInfo(link)
        if (not (itemType == "Armor" or itemType == "Weapon")) then
            return
        end
        -- Display item properties in the label
        local itemPropertiesLabel = self.itemNameLabel
        itemPropertiesLabel:SetText(itemName)
        self.itemUpgradeLabel:SetText("Item Level: " .. ilvl .. " >> " .. "|cff00ff00" .. ilvl + 5 .. "|r")

        self.upgradeButton:Enable()
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
            PickupContainerItem(bagID, slotID);

            MainFrame.itemSlot:Click("LeftButton");
            SocketContainerItem(bagID, slotID);
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
            PickupInventoryItem(frame:GetID());

            MainFrame.itemSlot:Click("LeftButton");
            SocketInventoryItem(frame:GetID());
            return
        end


        old_PaperDollItemSlotButton_OnModifiedClick(frame, button)
    end

    function MainFrame.OnEvent(self, event, ...)
        if (event == "UNIT_SPELLCAST_SUCCEEDED") then
            local unit, spellName = ...
            if (unit == "player") and spellName == "Tempering" then
                self.TimeSinceLastUpdate = 0
                PlaySound(3084)
            end
        end

        if (event == "UNIT_SPELLCAST_STOP") then
            local unit, spellName = ...
            if (unit == "player") and spellName == "Tempering" then
                MainFrame.itemSlot:RefreshItem(true)
                -- self.TimeSinceLastUpdate = 0.3
            end
        end
    end

    MainFrame.TimeSinceLastUpdate = 0
    function MainFrame.OnUpdate(self, elapsed)
        self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
        if (self.TimeSinceLastUpdate > 0.1) then
            MainFrame.itemSlot:RefreshItem()

            self.TimeSinceLastUpdate = -1000;
        end
    end
end

MainFrame:CreateUI()
HooksSetup()
MainFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
MainFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
MainFrame:SetScript("OnEvent", MainFrame.OnEvent)
MainFrame:SetScript("OnUpdate", MainFrame.OnUpdate)
