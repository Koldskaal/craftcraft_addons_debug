local TradeTabs = CreateFrame("Frame", "TradeTabs")

local RUNEFORGING = 53428 -- Runeforging spellid
local private = select(2, ...)

function TradeTabs:OnEvent(event, ...)
	self:UnregisterEvent(event)
	if not IsLoggedIn() then
		self:RegisterEvent(event)
	elseif InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:Initialize()
	end
end

function TradeTabs:Initialize()
	if self.initialized or not IsAddOnLoaded("Blizzard_TradeSkillUI") then return end -- Shouldn't need this, but I'm paranoid

	local parent = TradeSkillFrame
	local tradeSpells = private.ordered_professions
	local i = 1
	local prev

	-- if player is a DK, insert runeforging at the top
	if select(2, UnitClass("player")) == "DEATHKNIGHT" then
		prev = self:CreateTab(i, parent, RUNEFORGING)
		prev:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 1, -44)
		i = i + 1
	end

	for f, slot in ipairs(tradeSpells) do
		local tab = self:CreateTab(i, parent, slot)
		i = i + 1

		local point, relPoint, x, y = "TOPRIGHT", "BOTTOMRIGHT", 0, -17
		if not prev then
			prev, relPoint, x, y = parent, "TOPRIGHT", 1, -44
		end
		tab:SetPoint(point, prev, relPoint, x, y)

		prev = tab
	end

	self.initialized = true
end

local function onEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(self.tooltip)
	self:GetParent():LockHighlight()
end

local function onLeave(self)
	GameTooltip:Hide()
	self:GetParent():UnlockHighlight()
end

local function updateSelection(self)
	local name = GetTradeSkillLine()
	if self.spell == name then
		self:SetChecked(true)
		self.clickStopper:Show()
	else
		self:SetChecked(false)
		self.clickStopper:Hide()
	end
end

local function createClickStopper(button)
	local f = CreateFrame("Frame", nil, button)
	f:SetAllPoints(button)
	f:EnableMouse(true)
	f:SetScript("OnEnter", onEnter)
	f:SetScript("OnLeave", onLeave)
	button.clickStopper = f
	f.tooltip = button.tooltip
	f:Hide()
end


function TradeTabs:CreateTab(index, parent, spellID)
	local spell, _, texture = GetSpellInfo(spellID)
	local button = CreateFrame("CheckButton", "TradeTabsTab" .. index, parent,
		"SpellBookSkillLineTabTemplate,SecureActionButtonTemplate")
	button.tooltip = spell
	button.spellID = spellID
	button.spell = spell

	button:Show()
	button:SetAttribute("type", "spell")
	button:SetAttribute("spell", spell)

	button:SetNormalTexture(texture)

	button:SetScript("OnEvent", updateSelection)
	button:RegisterEvent("TRADE_SKILL_SHOW")
	button:RegisterEvent("TRADE_SKILL_CLOSE")
	button:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")

	createClickStopper(button)
	updateSelection(button)
	return button
end

TradeTabs:RegisterEvent("TRADE_SKILL_SHOW")
TradeTabs:SetScript("OnEvent", TradeTabs.OnEvent)

TradeTabs:Initialize()
