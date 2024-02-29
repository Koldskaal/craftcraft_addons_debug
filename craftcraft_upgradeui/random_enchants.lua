local AddonName, Addon = ...
local MainFrame = CCREnchantFrame

local rates = {
    [1] = { [1] = 0.75, [2] = .25, [3] = 0, [4] = 0, [5] = 0 },          --1-24
    [2] = { [1] = 0.55, [2] = .30, [3] = 0.15, [4] = 0, [5] = 0 },       --25-34
    [3] = { [1] = 0.30, [2] = .40, [3] = 0.25, [4] = 0.05, [5] = 0 },    --35-44
    [4] = { [1] = 0.19, [2] = .30, [3] = 0.35, [4] = 0.10, [5] = 0.01 }, --45-54
    [5] = { [1] = 0.10, [2] = .20, [3] = 0.25, [4] = 0.35, [5] = 0.10 }, --55-64
    [6] = { [1] = 0.05, [2] = .10, [3] = 0.20, [4] = 0.40, [5] = 0.25 }, --65+
}
local slot_to_name = {
    ["Red"] = "Red socket",
    ["Yellow"] = "Yellow socket",
    ["Blue"] = "Blue socket",
    ["Meta"] = "Meta socket",
    ["Socket"] = "Prismatic socket",
}

local function getRateBracket(itemlvl)
    if itemlvl < 25 then
        return 1
    elseif itemlvl < 35 then
        return 2
    elseif itemlvl < 45 then
        return 3
    elseif itemlvl < 55 then
        return 4
    elseif itemlvl < 65 then
        return 5
    end

    return 6
end

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

CCREnchantFrameCloseButton:SetScript("OnClick", function() HideUIPanel(ItemSocketingFrame); end)

--- LOAD SCRIPT STUFF!!!!!!!!!!
MainFrame:SetScript("OnShow", function()
    MainFrame:LoadStuff(true)
end)

function MainFrame:LoadStuff(resend)
    if not Addon.bagID or not Addon.slotID then return end

    local tex = GetItemIcon(GetLink())
    SetPortraitToTexture("CCREnchantFramePortrait", tex);
    MainFrame.link = GetLink();
    if (not MainFrame.link) then
        print(Addon.bagID, Addon.slotID)
        print(GetLink())
        return
    end

    local enchants = {}
    _, _, enchants.ench1, enchants.ench2, enchants.ench3 = string.match(MainFrame.link,
        "item:(%d+):(%d+):(%d+):(%d+):(%d+)")

    local should_request_cache = false

    -- play here
    for i = 1, 3, 1 do
        local basestring = "CCREnchantFrameSection" .. i;
        local enchid = tonumber(enchants["ench" .. i]);
        local socket = GetSocketTypes(i);
        if i <= GetNumSockets() and socket then
            _G[basestring .. "IconBorder"]:SetVertexColor(GetItemQualityColor(0));
            _G[basestring .. "IconTexture"]:SetTexture("Interface\\Icons\\inv_misc_gem_variety_01");
            _G[basestring].enchant = enchid;
            _G[basestring .. "TitleText"]:SetText(slot_to_name[socket] .. " Slot");
            _G[basestring .. "TitleText"]:SetTextColor(GetItemQualityColor(6));
            _G["CCREnchantFrameSection" .. i .. "Button"]:Disable();
        else
            if enchid == 0 then
                _G[basestring .. "IconBorder"]:SetVertexColor(GetItemQualityColor(0));
                _G[basestring .. "IconTexture"]:SetTexture("Interface\\Icons\\inv_inscription_scroll");
                _G[basestring].enchant = nil;
                _G[basestring .. "TitleText"]:SetText("Empty");
                _G[basestring .. "TitleText"]:SetTextColor(GetItemQualityColor(0))
            else
                local cache = ENCH_CACHE[enchid];
                if not cache then
                    _G[basestring .. "IconBorder"]:SetVertexColor(GetItemQualityColor(0));
                    _G[basestring .. "IconTexture"]:SetTexture("Interface\\Icons\\inv_misc_questionmark");
                    _G[basestring .. "TitleText"]:SetText("Uknown Enchant");
                    _G[basestring .. "TitleText"]:SetTextColor(GetItemQualityColor(0));
                    _G[basestring].enchant = enchid;
                    should_request_cache = true;
                else
                    _G[basestring .. "IconBorder"]:SetVertexColor(GetItemQualityColor(cache.rarity + 1));
                    _G[basestring .. "IconTexture"]:SetTexture("Interface\\Icons\\" .. cache.icon);
                    _G[basestring .. "TitleText"]:SetText(cache.name);
                    _G[basestring .. "TitleText"]:SetTextColor(GetItemQualityColor(cache.rarity + 1));
                    _G[basestring].enchant = enchid;
                end
            end
            _G["CCREnchantFrameSection" .. i .. "Button"]:Enable();
        end
    end

    if resend and should_request_cache then
        RequestEnchantInfo(Addon.bagID, Addon.slotID);
    end

    UpdateDurabilityProgressBar(CCREnchantFrameDurability, CCREnchantFrameDurabilityText)
    local ilvl, _ = select(4, GetItemInfo(MainFrame.link))
    local brackidx = getRateBracket(ilvl)
    for i = 1, 5, 1 do
        local label = _G["DotFrame" .. i .. "Text"]
        label:SetText((rates[brackidx][i] * 100) .. "%");
    end
end

-- On time prep
for i = 1, 3, 1 do
    local basestring = "CCREnchantFrameSection" .. i;
    _G[basestring .. "IconBorder"]:SetVertexColor(GetItemQualityColor(1))
    _G[basestring .. "IconTexture"]:SetTexture("Interface\\Icons\\inv_misc_questionmark")
    _G[basestring].enchant = nil

    _G[basestring .. "TitleText"]:SetText("Empty");
    local button = Addon.GenericCreateButton(basestring .. "Button", _G[basestring], 20, 60, "GameFontNormal",
        "Reroll", "CENTER", nil, 1)
    button:SetPoint("RIGHT", _G[basestring], "RIGHT", -10, 0)
    button:Disable()

    -- button:Disable();
    button:SetScript("OnClick", function(self)
        RollRandomEnchant(Addon.bagID, Addon.slotID, i)
        -- PlaySound(7096)
        PlaySound(4614)
        self:Disable()
    end)
end





for i = 1, 5, 1 do
    -- Create the main frame
    local dotFrame = CreateFrame("Frame", "DotFrame" .. i, MainFrame)
    dotFrame:SetSize(6, 6)                                                       -- Size of the dot
    if i == 1 then
        dotFrame:SetPoint("CENTER", MainFrame, "BOTTOM", -10 + (-40 * 2.5), 100) -- Position on the screen
    else
        dotFrame:SetPoint("LEFT", _G["DotFrame" .. i - 1], "RIGHT", 40, 0)
    end

    -- Add a texture to the frame
    local dotTexture = dotFrame:CreateTexture(nil, "ARTWORK")
    dotTexture:SetAllPoints(dotFrame)
    dotTexture:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask") -- Using a built-in simple white texture
    dotTexture:SetVertexColor(GetItemQualityColor(i))

    local label = dotFrame:CreateFontString("DotFrame" .. i .. "Text", "OVERLAY", "GameFontHighlightSmall")
    label:SetText("25%")
    label:SetSize(40, 10)
    label:SetJustifyH("LEFT")
    label:SetPoint("LEFT", dotFrame, "RIGHT", 2, 1) -- Position on the screen
end

MainFrame.TimeSinceLastUpdate = 0
function MainFrame.OnUpdate(self, elapsed)
    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > 0.1) then
        MainFrame:LoadStuff(false)
        self.TimeSinceLastUpdate = 0;
    end
end

MainFrame:SetScript("OnUpdate", MainFrame.OnUpdate)
