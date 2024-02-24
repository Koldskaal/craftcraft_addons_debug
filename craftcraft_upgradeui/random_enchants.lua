local AddonName, Addon = ...
local MainFrame = CCREnchantFrame


local function GetLink()
    if Addon.bagID == 255 then
        return GetInventoryItemLink("player", Addon.slotID);
    else
        return GetContainerItemLink(Addon.bagID, Addon.slotID);
    end
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
end)
