-------------------------------------------------------------------------------
-- Localized Lua globals.
-------------------------------------------------------------------------------
local _G = getfenv(0)

local table = _G.table
local string = _G.string

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------

-- Set up the private intra-file namespace.
local ns = select(2, ...)

-------------------------------------------------------------------------------
-- Table cache mechanism
-------------------------------------------------------------------------------
do
	local table_cache = {}

	-- Returns a table
	function ns.AcquireTable()
		local tbl = table.remove(table_cache) or {}
		return tbl
	end

	-- Cleans the table and stores it in the cache
	function ns.ReleaseTable(tbl)
		if not tbl then return end
		table.wipe(tbl)
		table.insert(table_cache, tbl)
	end
end -- do block

-------------------------------------------------------------------------------
-- Sets show and hide scripts as well as text for a tooltip for the given frame.
-------------------------------------------------------------------------------
do
	local HIGHLIGHT_FONT_COLOR = _G.HIGHLIGHT_FONT_COLOR

	local function Show_Tooltip(frame, motion)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
		GameTooltip:SetText(frame.tooltip_text, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		GameTooltip:Show()
	end

	local function Hide_Tooltip()
		GameTooltip:Hide()
	end

	function ns.SetTooltipScripts(frame, textLabel)
		frame.tooltip_text = textLabel

		frame:SetScript("OnEnter", Show_Tooltip)
		frame:SetScript("OnLeave", Hide_Tooltip)
	end
end -- do

-------------------------------------------------------------------------------
-- Generic function for creating buttons.
-------------------------------------------------------------------------------
do
	-- I hate stretchy buttons. Thanks very much to ckknight for this code
	-- (found in RockConfig)

	-- when pressed, the button should look pressed
	local function button_OnMouseDown(self)
		if self:IsEnabled() then
			self.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
			self.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
			self.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
		end
	end

	-- when depressed, return to normal
	local function button_OnMouseUp(self)
		if self:IsEnabled() then
			self.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			self.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			self.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
		end
	end

	local function button_Disable(self)
		self.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
		self.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
		self.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
		self:__Disable()
		self:EnableMouse(false)
	end

	local function button_Enable(self)
		self.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
		self.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
		self.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
		self:__Enable()
		self:EnableMouse(true)
	end

	function ns.GenericCreateButton(name, parent, height, width, font_object, label, justify_h, tip_text, noTextures)
		local button = CreateFrame("Button", name, parent)

		button:SetHeight(height)
		button:SetWidth(width)

		if noTextures == 0 then
			button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		elseif noTextures == 1 then
			local left = button:CreateTexture(nil, "BACKGROUND")
			button.left = left
			left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])

			local middle = button:CreateTexture(nil, "BACKGROUND")
			button.middle = middle
			middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])

			local right = button:CreateTexture(nil, "BACKGROUND")
			button.right = right
			right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])

			left:SetPoint("TOPLEFT")
			left:SetPoint("BOTTOMLEFT")
			left:SetWidth(12)
			left:SetTexCoord(0, 0.09375, 0, 0.6875)

			right:SetPoint("TOPRIGHT")
			right:SetPoint("BOTTOMRIGHT")
			right:SetWidth(12)
			right:SetTexCoord(0.53125, 0.625, 0, 0.6875)

			middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
			middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
			middle:SetTexCoord(0.09375, 0.53125, 0, 0.6875)

			button:SetScript("OnMouseDown", button_OnMouseDown)
			button:SetScript("OnMouseUp", button_OnMouseUp)

			button.__Enable = button.Enable
			button.__Disable = button.Disable
			button.Enable = button_Enable
			button.Disable = button_Disable

			local highlight = button:CreateTexture(nil, "OVERLAY", "UIPanelButtonHighlightTexture")
			button:SetHighlightTexture(highlight)
		elseif noTextures == 2 then
			button:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
			button:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down")
			button:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
			button:SetDisabledTexture("Interface\\Buttons\\UI-PlusButton-Disabled")
		elseif noTextures == 3 then
			button:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
			button:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
			button:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
			button:SetDisabledTexture("Interface\\Buttons\\UI-PlusButton-Disabled")
		end

		if font_object then
			local text = button:CreateFontString(nil, "ARTWORK")
			button:SetFontString(text)
			button.text = text
			text:SetPoint("LEFT", button, "LEFT", 7, 0)
			text:SetPoint("RIGHT", button, "RIGHT", -7, 0)
			text:SetJustifyH(justify_h)

			text:SetFontObject(font_object)
			text:SetText(label)
			button:SetDisabledFontObject("GameFontDisable")
			button:SetNormalFontObject("GameFontNormal")
		end

		if tip_text and tip_text ~= "" then
			ns.SetTooltipScripts(button, tip_text)
		end
		return button
	end

	function ns.GenericClearButton(name, parent, height, width, font_object, label, justify_h, tip_text, noTextures)
		local clearButton = ns.GenericCreateButton(name, parent, height, width, font_object, label, justify_h,
			tip_text, noTextures)
		clearButton:SetPoint("TOPLEFT", parent, "TOPLEFT", -2, -4)
		clearButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
		clearButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

		clearButton:SetScript("OnClick",
			function(self, button)
				for _, data in ipairs(parent) do
					data:SetChecked(false)
				end
				TradeSkillFrame_Update()
			end)

		return clearButton
	end

	local function CreateCheckButton(parent, ttText, scriptVal, row, col, maxCols)
		local function CheckButton_OnClick()
			TradeSkillFrame_Update()
		end

		local width = 272
		-- set the position of the new checkbox
		local xPos = 2 + ((col - 1) * width / maxCols)
		local yPos = -3 - ((row - 1) * 17)

		local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
		check:SetPoint("TOPLEFT", parent, "TOPLEFT", xPos, yPos)
		check:SetHeight(24)
		check:SetWidth(24)

		check.text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		check.text:SetPoint("LEFT", check, "RIGHT", 0, 0)

		check.script_val = scriptVal

		check:SetScript("OnClick", CheckButton_OnClick)

		ns.SetTooltipScripts(check, ttText, 1)

		return check
	end

	function ns.GenerateCheckBoxes(parent, source, maxCols)
		local col = 1
		local row = 2
		for section, data in ipairs(source) do
			parent[section] = CreateCheckButton(parent, data.tt, data.section, row, col, maxCols)
			parent[section].text:SetText(data.text)

			col = col + 1
			if col > maxCols then
				row = row + 1
				col = 1
			end
		end
	end

	function ns:CreateEditBox(name, parent, labelText, tooltipText, maxLetters, isNumeric, width)
		local function CheckButton_OnClick()
			TradeSkillFrame_Update()
		end
		assert(type(parent) == "table" and parent.CreateFontString, "EditBox: Parent is not a valid frame!")
		if type(name) ~= "string" then name = nil end
		if type(tooltipText) ~= "string" then tooltipText = nil end
		if type(maxLetters) ~= "number" then maxLetters = nil end

		local editbox = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
		--editbox:SetPoint("CENTER", parent, "CENTER", 0, 0)
		-- editbox.Left:SetPoint("TOPLEFT")
		-- editbox.Left:SetPoint("BOTTOMLEFT")
		-- editbox.Right:SetPoint("TOPRIGHT")
		-- editbox.Right:SetPoint("BOTTOMRIGHT")
		-- editbox.Middle:SetPoint("TOP")
		-- editbox.Middle:SetPoint("BOTTOM")
		--[[
		editbox.bg = editbox:CreateTexture(nil, "BACKGROUND")
		editbox.bg:SetAllPoints(true)
		editbox.bg:SetTexture(0, 0.5, 0, 0.25)
	]]
		editbox:SetSize(width or 180, 22)

		editbox:EnableMouse(true)
		editbox:SetAltArrowKeyMode(false)
		editbox:SetAutoFocus(false)
		editbox:SetFontObject("ChatFontSmall")
		editbox:SetTextInsets(6, 6, 2, 0)

		local label = editbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		label:SetPoint("BOTTOMLEFT", editbox, "TOPLEFT", 6, 0)
		label:SetPoint("BOTTOMRIGHT", editbox, "TOPRIGHT", -6, 0)
		label:SetJustifyH("LEFT")
		editbox.labelText = label

		-- for name, func in pairs(scripts) do
		-- 	editbox:SetScript(name, func)
		-- end

		-- editbox.orig_SetPoint = editbox.SetPoint
		-- for name, func in pairs(methods) do
		-- 	editbox[name] = func
		-- end

		editbox.labelText:SetText(labelText)
		editbox.tooltipText = tooltipText
		editbox:SetMaxLetters(maxLetters or 256)

		editbox:SetScript("OnTextChanged", CheckButton_OnClick)

		if isNumeric then
			editbox:SetNumeric(true)
			-- editbox.GetValue = editbox.GetNumber
			-- editbox.SetValue = editbox.SetNumber
		else
			-- editbox.GetValue = editbox.GetText
			-- editbox.SetValue = editbox.SetText
		end

		return editbox
	end

	function ns:ApplyDoublePanelTextures(frame)
		frame:SetAttribute("UIPanelLayout-width", 695) --orig 384
		frame:SetWidth(695)

		--Add the mid section by messing with glue and newspaper clippings
		local function CreateTex(parent, tex, layer, width, height, ...)
			local texf = parent:CreateTexture(nil, layer)
			texf:SetPoint(...)
			texf:SetTexture(tex)
			texf:SetWidth(width); texf:SetHeight(height)
			return texf
		end

		--for these textures we need to fill 311 pixels
		--Top filling in
		local top1 = CreateTex(frame, [[Interface\AddOns\CraftCraft_tradeskill_filter\Textures\Top]], "BORDER",
			311, 256,
			"TOPLEFT",
			256, 0)
		local bot1 = CreateTex(frame, [[Interface\AddOns\CraftCraft_tradeskill_filter\Textures\Bot]],
			"BORDER",
			311, 256,
			"BOTTOMLEFT", frame:GetName() .. "BottomLeftTexture", "BOTTOMRIGHT")


		local top = CreateTex(frame, [[Interface\AddOns\CraftCraft_tradeskill_filter\Textures\Top]], "BORDER",
			311, 256,
			"TOPLEFT",
			top1, "TOPRIGHT")
		frame.topTex = top
		top:Hide()

		--bottom filling in
		local bot = CreateTex(frame, [[Interface\AddOns\CraftCraft_tradeskill_filter\Textures\InspectBot]],
			"BORDER",
			311, 256,
			"BOTTOMLEFT", bot1, "BOTTOMRIGHT", 0, 0)
		bot:Hide()
		frame.botTex = bot
		frame.botinnerTex = bot1

		_G[frame:GetName() .. "BottomRightTexture"]:SetTexture([[Interface\PaperDollInfoFrame\SkillFrame-BotRight]])
	end
end -- do
