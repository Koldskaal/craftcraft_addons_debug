-- Create a frame to hold the grid
local gframe = CreateFrame("Frame", "MyGridFrame", UIParent)
gframe:SetSize(300, 400)
gframe:SetPoint("CENTER")
gframe:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4
    }
})
gframe:SetBackdropColor(0, 0, 0, 1)

local searchText = ""
local searchBox = CreateFrame("EditBox", "MySearchEditBox", gframe)
searchBox:SetFontObject("GameFontWhite")
searchBox:SetSize(200, 30)
searchBox:SetPoint("TOPLEFT", 16, -8)
searchBox:SetAutoFocus(false)
searchBox:SetBackdrop({
    bgFile = "",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = "true",
    tileSize = 32,
    edgeSize = 10,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
searchBox:EnableKeyboard(true)


-- Create a scroll frame to contain the weapon buttons
local scrollFrame = CreateFrame("ScrollFrame", "MyWeaponScrollFrame", gframe, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 8, -8 - 25)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 8)

-- Create a child frame for the scroll frame
local childFrame = CreateFrame("Frame", "MyWeaponScrollChild", scrollFrame)
scrollFrame:SetScrollChild(childFrame)
childFrame:SetSize(280, 1)
childFrame.buttons = {}
childFrame.glows = {}

-- Make the addon frame draggable
gframe:SetMovable(true)
gframe:EnableMouse(true)
gframe:RegisterForDrag("LeftButton")
gframe:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
gframe:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Define the grid properties
local numRows = 20
local numColumns = 7
local iconSize = 32
local padding = 4
local spacing = 4

local hovering = false
local name = ""
local modifier = ""
local modifierPrev = ""
local butt = ""

-- Create a function to calculate the position of an icon in the grid
local function CalculateIconPosition(index)
    local row = math.ceil(index / numColumns)
    local column = (index - 1) % numColumns + 1
    local x = padding + (column - 1) * (iconSize + spacing)
    local y = -padding - (row - 1) * (iconSize + spacing)
    return x, y
end

local function SetTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    butt = self
    hovering = true
    name = GetSpellInfo(self:GetID())
    if IsControlKeyDown() then
        GameTooltip:SetText(name .. modifier)
    elseif IsShiftKeyDown() then
        GameTooltip:SetText(name .. modifier)
    else
        GameTooltip:SetText(name)
    end
end

-- Create a function to populate the grid with icons
local function PopulateGrid()
    local name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon
    local i

    for i = 1, numRows * numColumns do
        name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(400000 + i - 1)
        if name then
            local iconButton = CreateFrame("Button", nil, childFrame)
            iconButton:SetSize(iconSize, iconSize)
            iconButton:SetID(400000 + i - 1)
            iconButton:SetNormalTexture(icon)
            iconButton:SetText("BUTTON")
            iconButton:SetScript("OnClick", function(frame)
                if IsControlKeyDown() then
                    SendChatMessage(".addCA custom " .. frame:GetID(), "GUILD");
                elseif IsShiftKeyDown() then
                    SendChatMessage(".removeCA custom " .. frame:GetID(), "GUILD");
                else
                    SendChatMessage(".toggleCA custom " .. frame:GetID(), "GUILD");
                end
            end)
            local glowTexture = iconButton:CreateTexture(nil, "OVERLAY")
            glowTexture:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            glowTexture:SetPoint("TOPLEFT", iconButton, "TOPLEFT", -12, 12)
            glowTexture:SetPoint("BOTTOMRIGHT", iconButton, "BOTTOMRIGHT", 12, -12)
            glowTexture:SetBlendMode("ADD")
            -- glowTexture:SetAllPoints(iconButton)
            glowTexture:SetAlpha(0)

            iconButton:SetScript("OnEnter", function(self)
                SetTooltip(self)
            end)
            iconButton:SetScript("OnLeave", function()
                GameTooltip:Hide()
                hovering = false
            end)

            -- Calculate and set the position of the icon in the grid
            local x, y = CalculateIconPosition(i)
            iconButton:SetPoint("TOPLEFT", childFrame, "TOPLEFT", x, y)
            table.insert(childFrame.buttons, iconButton)
            table.insert(childFrame.glows, glowTexture)
        end
    end
end
gframe:SetScript("OnUpdate", function()
    if hovering then
        if IsControlKeyDown() then
            modifier = " (ADD)"
        elseif IsShiftKeyDown() then
            modifier = " (REMOVE)"
        else
            modifier = ""
        end

        if modifier ~= modifierPrev then
            modifierPrev = modifier
            SetTooltip(butt)
        end
    end
end)

searchBox:SetScript("OnEnterPressed", function(self, event)
    searchText = string.lower(self:GetText())
    if searchText and searchText ~= "" then
        -- Implement your search functionality here
        print("Searching for: " .. searchText)
    end
    for index, value in ipairs(childFrame.buttons) do
        name = GetSpellInfo(value:GetID())
        if string.find(string.lower(name), searchText) then
            value:GetNormalTexture():SetDesaturated(false)
            if searchText and searchText ~= "" then
                childFrame.glows[index]:SetAlpha(1)
            else
                childFrame.glows[index]:SetAlpha(0)
            end
        else
            value:GetNormalTexture():SetDesaturated(true)
            childFrame.glows[index]:SetAlpha(0)
        end
    end

    self:ClearFocus() -- Remove focus from the edit box
end)
searchBox:SetScript("OnTextChanged", function(self, event)
    searchText = string.lower(self:GetText())
    for index, value in ipairs(childFrame.buttons) do
        name = GetSpellInfo(value:GetID())
        if string.find(string.lower(name), searchText) then
            value:GetNormalTexture():SetDesaturated(false)
            if searchText and searchText ~= "" then
                childFrame.glows[index]:SetAlpha(1)
            else
                childFrame.glows[index]:SetAlpha(0)
            end
        else
            value:GetNormalTexture():SetDesaturated(true)
            childFrame.glows[index]:SetAlpha(0)
        end
    end
end)

searchBox:RegisterEvent("OnKeyDown")
searchBox:RegisterEvent("MODIFIER_STATE_CHANGED")
searchBox:SetScript("OnEvent", function(self, event, key, pressed)
    if key == "LALT" or key == "RALT" then
        if pressed == 1 then
            -- self:SetText("") -- Clear the text
            -- self:SetFocus()
        else
            -- self:Hide()
        end
    end
end)


PopulateGrid()
gframe:Hide()

SLASH_LOOTS1 = "/la"
SlashCmdList["LOOTS"] = function()
    if gframe:IsShown() then
        gframe:Hide()
    else
        gframe:Show()
    end
end
