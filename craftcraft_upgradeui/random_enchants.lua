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
end)
