local AddonName, Addon = ...
local MainFrame = CCREnchantFrame

local function GetLink()
    if Addon.bagID == 255 then
        return GetInventoryItemLink("player", Addon.slotID);
    else
        return GetContainerItemLink(Addon.bagID, Addon.slotID);
    end
end

local function GetDurability()
    if Addon.bagID == 255 then
        return GetInventoryItemDurability(Addon.slotID);
    else
        return GetContainerItemDurability(Addon.bagID, Addon.slotID);
    end
end

local function UpdateDurabilityProgressBar(progressBarFrame, textFrame)
    local currentDurability, maxDurability = GetDurability();
    if not currentDurability or not maxDurability then
        -- Hide the progress bar if there's no durability (for non-equipable items)
        progressBarFrame:Hide()
        return
    end

    local durabilityPercentage = (currentDurability / maxDurability) * 100
    progressBarFrame:SetValue(durabilityPercentage)

    if (textFrame) then
        textFrame:SetText(currentDurability .. "/" .. maxDurability);
    end
    -- Optional: Update the progress bar color based on durability
    if durabilityPercentage < 20 then
        progressBarFrame:SetStatusBarColor(1, 0, 0) -- Red for low durability
        -- elseif durabilityPercentage < 50 then
        --     progressBarFrame:SetStatusBarColor(1, 0.5, 0) -- Orange for medium durability
        -- else
        --     progressBarFrame:SetStatusBarColor(0, 1, 0)   -- Green for high durability
    end

    progressBarFrame:Show()
end



MainFrame:SetScript("OnShow", function()
    local tex = GetItemIcon(GetLink())
    SetPortraitToTexture("CCREnchantFramePortrait", tex);
    MainFrame.link = GetLink();


    -- play here
    CCREnchantFrameSection1IconBorder:SetVertexColor(GetItemQualityColor(3))
    CCREnchantFrameSection2IconBorder:SetVertexColor(GetItemQualityColor(4))
    CCREnchantFrameSection3IconBorder:SetVertexColor(GetItemQualityColor(5))
    CCREnchantFrameSection2IconTexture:SetTexture("Interface\\Icons\\spell_shadow_sealofkings")
    CCREnchantFrameSection1IconTexture:SetTexture("Interface\\Icons\\ability_mage_missilebarrage")
    CCREnchantFrameSection3IconTexture:SetTexture("Interface\\Icons\\spell_nature_naturesblessing")
    CCREnchantFrameSection1.enchant = 155
    CCREnchantFrameSection2.enchant = 156
    CCREnchantFrameSection3.enchant = 157

    UpdateDurabilityProgressBar(CCREnchantFrameDurability, CCREnchantFrameDurabilityText)
end)
