--Addon name, namespace
local addonNameSpace, ns = ...
local _, addon = GetAddOnInfo(addonNameSpace)

--WidgetTools reference
local wt = WidgetToolbox[ns.WidgetToolsVersion]


--[[ ASSETS & RESOURCES ]]

local root = "Interface/AddOns/" .. addonNameSpace .. "/"

--Strings & Localization
local strings = ns.LoadLocale()
strings.chat.keyword = "/rpkb"

--Colors
local colors = {
	grey = {
		[0] = { r = 0.54, g = 0.54, b = 0.54 },
		[1] = { r = 0.69, g = 0.69, b = 0.69 },
		[2] = { r = 0.79, g = 0.79, b = 0.79 },
	},
	red = {
		[0] = { r = 1, g = 0.22, b = 0 },
		[1] = { r = 1, g = 0.47, b = 0.33 },
	},
	blue = {
		[0] = { r = 0.27, g = 0.75, b = 1 },
		[1] = { r = 0.51, g = 0.88, b = 1 },
	},
}

--Fonts
local fonts = {
	[0] = { name = strings.misc.default, path = strings.misc.defaultFont },
	-- [1] = { name = "Arbutus Slab", path = root .. "Fonts/ArbutusSlab.ttf" },
	-- [2] = { name = "Caesar Dressing", path = root .. "Fonts/CaesarDressing.ttf" },
	-- [3] = { name = "Germania One", path = root .. "Fonts/GermaniaOne.ttf" },
	-- [4] = { name = "Mitr", path = root .. "Fonts/Mitr.ttf" },
	-- [5] = { name = "Oxanium", path = root .. "Fonts/Oxanium.ttf" },
	-- [6] = { name = "Pattaya", path = root .. "Fonts/Pattaya.ttf" },
	-- [7] = { name = "Reem Kufi", path = root .. "Fonts/ReemKufi.ttf" },
	-- [8] = { name = "Source Code Pro", path = root .. "Fonts/SourceCodePro.ttf" },
	-- [9] = { name = strings.misc.custom, path = root .. "Fonts/CUSTOM.ttf" },
}

--Textures
local textures = {
	logo = root .. "Textures/Logo.tga",
}

--Anchor Points
local anchors = {
	[0] = { name = strings.points.top.left, point = "TOPLEFT" },
	[1] = { name = strings.points.top.center, point = "TOP" },
	[2] = { name = strings.points.top.right, point = "TOPRIGHT" },
	[3] = { name = strings.points.left, point = "LEFT" },
	[4] = { name = strings.points.center, point = "CENTER" },
	[5] = { name = strings.points.right, point = "RIGHT" },
	[6] = { name = strings.points.bottom.left, point = "BOTTOMLEFT" },
	[7] = { name = strings.points.bottom.center, point = "BOTTOM" },
	[8] = { name = strings.points.bottom.right, point = "BOTTOMRIGHT" },
}


--[[ DATA TABLES ]]

--[ Addon DBs ]

--References
local db --Account-wide options
local dbc --Character-specific options
local cs --Cross-session account-wide data
local csc --Cross-session account-wide data

--Default values
local dbDefault = {
}
local dbcDefault = {
	disabled = false,
}

--[ Symbol Sets ]

local symbols = {
}


--[[ FRAMES & EVENTS ]]

--[ Main Frame ]

--Addon frame references
local frames = {}

--Creating frames
frames.rpkb = CreateFrame("Frame", addonNameSpace, UIParent) --Main addon frame

--Registering events
frames.rpkb:RegisterEvent("ADDON_LOADED")
frames.rpkb:RegisterEvent("PLAYER_ENTERING_WORLD")

--Event handler
frames.rpkb:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, ...)
end)


--[[ UTILITIES ]]

---Find the ID of the font provided
---@param fontPath string
---@return integer
local function GetFontID(fontPath)
	local id = 0
	for i = 0, #fonts do
		if fonts[i].path == fontPath then
			id = i
			break
		end
	end
	return id
end

---Find the ID of the anchor point provided
---@param point AnchorPoint
---@return integer
local function GetAnchorID(point)
	local id = 0
	for i = 0, #anchors do
		if anchors[i].point == point then
			id = i
			break
		end
	end
	return id
end

--[ DB Management ]

--Check the validity of the provided key value pair
local function CheckValidity(k, v)
	if type(v) == "number" then
		--Non-negative
		if k == "size" then return v > 0 end
		--Range constraint: 0 - 1
		if k == "r" or k == "g" or k == "b" or k == "a" or k == "text" or k == "background" then return v >= 0 and v <= 1 end
	end return true
end

---Restore old data to an account-wide and character-specific DB by matching removed items to known old keys
---@param data table
---@param characterData table
---@param recoveredData? table
---@param recoveredCharacterData? table
local function RestoreOldData(data, characterData, recoveredData, recoveredCharacterData)
	-- if recoveredData ~= nil then for k, v in pairs(recoveredData) do
	-- 	if k == "" then data. = v
	-- 	elseif k == "" then data. = v
	-- 	end
	-- end end
	-- if recoveredCharacterData ~= nil then for k, v in pairs(recoveredCharacterData) do
	-- 	if k == "" then characterData. = v
	-- 	elseif k == "" then characterData. = v
	-- 	end
	-- end end
end

---Load the addon databases from the SavedVariables tables specified in the TOC
---@return boolean firstLoad True is returned when the addon SavedVariables tabled didn't exist prior to loading, false otherwise
local function LoadDBs()
	local firstLoad = false
	--First load
	if RPKeyboardDB == nil then
		RPKeyboardDB = wt.Clone(dbDefault)
		firstLoad = true
	end
	if RPKeyboardDBC == nil then RPKeyboardDBC = wt.Clone(dbcDefault) end
	if RPKeyboardCS == nil then RPKeyboardCS = {} end
	if RPKeyboardCSC == nil then RPKeyboardCSC = {} end
	--Load the DBs
	db = wt.Clone(RPKeyboardDB) --Account-wide options DB copy
	dbc = wt.Clone(RPKeyboardDBC) --Character-specific options DB copy
	cs = RPKeyboardCS --Cross-session account-wide data direct reference
	csc = RPKeyboardCSC --Cross-session character-specific data direct reference
	--DB checkup & fix
	wt.RemoveEmpty(db, CheckValidity)
	wt.RemoveEmpty(dbc, CheckValidity)
	wt.AddMissing(db, dbDefault)
	wt.AddMissing(dbc, dbcDefault)
	RestoreOldData(db, dbc, wt.RemoveMismatch(db, dbDefault), wt.RemoveMismatch(dbc, dbcDefault))
	--Apply any potential fixes to the SavedVariables DBs
	RPKeyboardDB = wt.Clone(db)
	RPKeyboardDBC = wt.Clone(dbc)
	return firstLoad
end

--[ Chat Type Handling ]

local currentChatType = "SAY"

---Generate a string snippet signaling the current chat type for selected types that goes at the start in a chat input field
---@param chatType ChatTypeId
---@return string
local function GetChatSendSnippet(chatType)
	if chatType == "SAY" then return CHAT_SAY_SEND end
	if chatType == "YELL" then return CHAT_YELL_SEND end
	if chatType == "WHISPER" then return CHAT_WHISPER_SEND:gsub("%%s", "Player-Realm") end --TODO: Figure out how/whether to handle whispers
	if chatType == "EMOTE" then return UnitName("player") .. " " end
	return ""
end

---Generate a string snippet signaling the current chat type for selected types that goes at the start of a sent/received chat message
---@param chatType ChatTypeId
---@return string
local function GetChatGetSnippet(chatType)
	if chatType == "SAY" then return CHAT_SAY_GET:sub(3) end
	if chatType == "YELL" then return CHAT_YELL_GET:sub(3) end
	if chatType == "WHISPER" then return CHAT_WHISPER_GET:sub(3) end
	if chatType == "EMOTE" then return " " end
	return ": "
end

---Check if the input text is recognizable as a chat command to change the current chat type
---@param command string Text to analyze in serach of a chat type change command
---@param appendSpace? boolean Whether or not to only check for commands with space appended [Default: false]
---@param removeSendSnippet? boolean Whether or not to remove the send snippet from the beginning [Default: true]
---@return boolean changed Whether the current chat type was changed or not
local function ChangeChatType(command, appendSpace, removeSendSnippet)
	local oldChatType = currentChatType
	local c = command
	if removeSendSnippet ~= false then c = c:gsub(GetChatSendSnippet(currentChatType) .. "(.*)", "%1") end
	c = c:lower()
	local s = appendSpace == true and " " or ""
	print(s, c, c == "/y" .. s or c == "/yell" .. s) --FIXME: Check why won't the string comparison work
	if c == "/s" .. s or c == "/say" .. s then
		currentChatType = "SAY"
	elseif c == "/y" .. s or c == "/yell" .. s then
		currentChatType = "YELL"
	elseif c == "/e" .. s or c == "/emote" .. s then
		currentChatType = "EMOTE"
	end
	return oldChatType ~= currentChatType
end

--[ Symbol Set Management ]

---comment
local function UpdateSets()

end

--[ Global Tools ]

--Global RP Keyboard table
RPKBTools = {}

---Add or update a set of symbols to the RP Keyboard table
---@param data table Table containing information about the symbol set
--- - **name** string ― Displayed name of the symbol set
--- - **description**? string *optional* ― Details about the symbol set
--- - **version** string ― The current version number of this set
--- - **date**? string *optional* ― The current version number of this set
--- - **license**? string *optional* ― The current version number of this set [Default: "All Rights Reserved"]
--- 	- ***Note:*** American spelling is used, be mindful of confusing it with "licence".
--- - **authors** table [indexed, 0-based] ― List of the authors who created and released this symbol set
--- 	- ***Value:*** string ― Name of the author
--- - **links**? table [indexed, 0-based] *optional* ― Collection links related to the symbol set
--- 	- ***Value:*** table ― Details of a given link
--- 		- **title** string ― Displayed title of the specific link
--- 		- **url** string ― The copiable URL of the specific link
--- - **textures** table [key, value pairs] ― Table containing subtables of all details and data of each specific symbol in the set
--- 	- ***Key:*** string ― To be recognized, the specific singlar character represented by the specific symbol must be used as the key.
--- 	- ***Value:*** table
--- 		- **path** string ― Path of the specific texture file of the symbolrelative to the root directory of the specific WoW client.
--- 			- ***Note:*** Use "/" as separator in file paths. (Example: Interface/AddOns/RPKeyboard/Textures/Logo.tga)
--- 			- ***Note - File format:*** Texture files must be in JPEG (no transparency, not recommended), TGA or BLP format.
--- 			- ***Note - Color:*** Flat white colored textures are preferred, so the symbols may be recolored to any color within the game.
--- 		- **size**? integer *optional* ― RP Keyboard handles square textures with powers of 2 dimensions. [Value: powers of 2, Default: 32]
--- 		- **cut**? table *optional* ― Cut the edges of the texture image at the specified widths
--- 			- **left**? integer ― The width of the strip to cut from the left edge rightwards [Range 0, **size**; Default: 0]
--- 			- **right**? integer ― The width of the strip to cut from the right edge leftwards [Range 0, **size**; Default: 0]
--- 			- **top**? integer ― The width of the strip to cut from the top edge downwards [Range 0, **size**; Default: 0]
--- 			- **bottom**? integer ― The width of the strip to cut from the bottom edge upwards [Range 0, **size**; Default: 0]
---@param override? boolean Whether to override the symbol set if one already exist with the given key [Default: false]
---@return string|integer symbolSetKey String key referring to the symbol set subtable added to the RP Keyboard table or a number on error
--- - ***Error codes:*** The specific number is returned when one of these errors occurs:
--- 	1. **name** has been left out or it is invalid.
--- 	2. A symbol set with this **name** already exists (and **override** is false).
--- 	3. **description** is set but it is invalid.
--- 	5. **version** has been left out or it is invalid.
--- 	5. **date** is set but it is invalid.
--- 	6. **license** is set but it is invalid.
--- 	7. **authors** has been left out, it is invalid or empty.
--- 	8. A child item in **authors** is invalid.
--- 	9. **links** is set but it is invalid or empty.
--- 	10. **title** or **url** of a child item in **links** has been left out or it is invalid.
--- 	11. **textures** has been left out, it is invalid or empty.
--- 	12. The key of an item in **textures** is invalid (not a one character long string).
--- 	13. A direct child value in **textures** is not a table or it is empty.
--- 	14. **path** in a subtable of **textures** has been left out or it is invalid (check file format as well).
--- 	15. **size** in a subtable of **textures** is set but it is invalid (not an integer with a power of 2 value).
--- 	16. **cut** in a subtable of **textures** is set but it is invalid or empty.
--- 	17. **left**, **right**, **top** or **bottom** in **cut** is set but it is invalid (nut an integer within the required range).
RPKBTools.AddSet = function(data, override)

	--[ Validate the symbol set]

	local validatedSet = {}

	--Check name
	if type(data.name) ~= "string" or data.name == "" then return 1 end
	local symbolSetKey = data.name:gsub("%s+", "")

	--Check for an existing set
	if symbols[symbolSetKey] ~= nil and override ~= true then return 2 end
	validatedSet.name = data.name

	--Check description
	if data.description ~= nil then
		if type(data.description) ~= "string" or data.description == "" then return 3 end
		validatedSet.description = data.description
	end

	--Check version
	if type(data.version) ~= "string" or data.version == "" then return 4 end
	validatedSet.version = data.version

	--Check date
	if data.date ~= nil then
		if type(data.date) ~= "string" or data.date == "" then return 5 end
		validatedSet.date = data.date
	end

	--Check license
	if data.license ~= nil then
		if type(data.license) ~= "string" or data.license == "" then return 6 end
		validatedSet.license = data.license
	else validatedSet.license = "All Rights Reserved" end

	--Check authors
	if type(data.authors) ~= "table" then return 7 elseif next(data.authors) == nil then return 7 end
	validatedSet.authors = {}
	for i = 0, #data.authors do
		if type(data.authors[i]) ~= "string" or data.authors[i] == "" then return 8 else
			validatedSet.authors[i] = data.authors[i]
		end
	end

	--Check links
	if data.links ~= nil then
		if type(data.links) ~= "table" then return 9 elseif next(data.authors) == nil then return 9 end
		validatedSet.links = {}
		for i = 0, #data.links do
			if type(data.links[i].title) ~= "string" or data.links[i].title == "" or type(data.links[i].url) ~= "string" or data.links[i].url == "" then return 10 end
			validatedSet.links[i] = {}
			validatedSet.links[i].title = data.links[i].title
			validatedSet.links[i].url = data.links[i].url
		end
	end

	--Check textures
	if type(data.textures) ~= "table" then return 11 elseif next(data.textures) == nil then return 11 end
	validatedSet.textures = {}
	for key, value in pairs(data.textures) do
		if type(key) ~= "string" then return 12 elseif #key ~= 1 then return 12 end
		if type(value) ~= "table" then return 13 elseif next(value) == nil then return 13 end
		validatedSet.textures[key] = {}

		--Check path
		local path = value.path:match("Interface/AddOns/[^%c.<>:\"\\|%?*][^%c.<>:\"\\|%?*]-/[^%c.<>:\"\\|%?*][^%c.<>:\"\\|%?*]-%.")
		if path == nil then return 14 end
		local format = value.path:sub(#path + 1)
		if format ~= "jpg" and format ~= "JPG" and format ~= "jpeg" and format ~= "JPEG" and format ~= "tga" and format ~= "TGA" and format ~= "blp" and format ~= "BLP" then
			return 14
		end
		validatedSet.textures[key].path = value.path

		--Check size
		if value.size ~= nil then
			if type(value.size) ~= "number" then return 15 elseif math.floor(value.size) ~= value.size or math.frexp(value.size) ~= 0.5 then return 15 end
			validatedSet.textures[key].size = value.size
		else validatedSet.textures[key].size = 32 end

		--Check cut
		if value.cut ~= nil then
			if type(value.cut) ~= "table" then return 16 elseif next(value) == nil then return 16 end
			validatedSet.textures[key].cut = {}

			--Check left
			if value.cut.left ~= nil then
				if type(value.cut.left) ~= "number" then return 17 elseif math.floor(value.cut.left) ~= value.cut.left then return 17 end
				if value.cut.left < 0 or value.cut.left > validatedSet.textures[key].size then return 17 end
				validatedSet.textures[key].cut.left = value.cut.left
			else validatedSet.textures[key].cut.left = 0 end

			--Check right
			if value.cut.right ~= nil then
				if type(value.cut.right) ~= "number" then return 17 elseif math.floor(value.cut.right) ~= value.cut.right then return 17 end
				if value.cut.right < 0 or value.cut.right > validatedSet.textures[key].size then return 17 end
				validatedSet.textures[key].cut.right = value.cut.right
			else validatedSet.textures[key].cut.left = 0 end

			--Check top
			if value.cut.top ~= nil then
				if type(value.cut.top) ~= "number" then return 17 elseif math.floor(value.cut.top) ~= value.cut.top then return 17 end
				if value.cut.top < 0 or value.cut.top > validatedSet.textures[key].size then return 17 end
				validatedSet.textures[key].cut.top = value.cut.top
			else validatedSet.textures[key].cut.top = 0 end

			--Check bottom
			if value.cut.bottom ~= nil then
				if type(value.cut.bottom) ~= "number" then return 17 elseif math.floor(value.cut.bottom) ~= value.cut.bottom then return 17 end
				if value.cut.bottom < 0 or value.cut.bottom > validatedSet.textures[key].size then return 17 end
				validatedSet.textures[key].cut.bottom = value.cut.bottom
			else validatedSet.textures[key].cut.bottom = 0 end
		else validatedSet.textures[key].cut = { left = 0, right = 0, top = 0, bottom = 0 } end
	end

	--[ Commit ]

	--Add the set
	symbols[symbolSetKey] = validatedSet

	--Update the UI
	UpdateSets()

	return symbolSetKey
end

---Return a copy of symbol set subtable from the RP Keyboard table if it exists
---@param symbolSetKey string The key referring to the symbol set subtable within the RP Keyboard table
---@return table|nil symbolSet A copy of the symbol set subtable (or nil if it doesn't exist)
RPKBTools.GetSet = function(symbolSetKey)
	return wt.Clone(symbols[symbolSetKey])
end

---Assemble and return a texture escape sequence of the specific character from the specified symbol set
---@param character string The specific character to search for in the symbol set
---@param symbolSetKey string The key referring to the symbol set subtable within the RP Keyboard table
---@param size? integer Font size to use use for the symbols [Default: 0 *(surrounding text height)*]
---@param r? number Font color red component [Range: 0, 255; Default: 255]
---@param g? number Font color green component [Range: 0, 255; Default: 255]
---@param b? number Font color blue component [Range: 0, 255; Default: 255]
---@return string texture Formatted symbol texture (**character** is returned when there is no symbol found representing it)
RPKBTools.GetSymbolTexture = function(character, symbolSetKey, size, r, g, b)
	if symbols[symbolSetKey] == nil then return character end
	if symbols[symbolSetKey].textures[character] == nil then return character end
	return "|T" .. symbols[symbolSetKey].textures[character].path .. ":" .. (size or 0) .. ":" .. (size or 0) .. ":" .. "0:0:" .. symbols[symbolSetKey].textures[character].size .. ":" .. symbols[symbolSetKey].textures[character].size .. ":" .. symbols[symbolSetKey].textures[character].cut.left .. ":" .. symbols[symbolSetKey].textures[character].size - symbols[symbolSetKey].textures[character].cut.right .. ":" .. symbols[symbolSetKey].textures[character].cut.top .. ":" .. symbols[symbolSetKey].textures[character].size - symbols[symbolSetKey].textures[character].cut.right .. ":" .. (r or 255) .. ":" .. (g or 255) .. ":" .. (b or 255) .. "|t"
end

---Toggle the RP Keyboard chat window
---@param visible? boolean Whether to hide or show the RP Keyboard chat window [Default: flip the current frame visibility]
---@param openChat? boolean Automatically activate the chat input after the window is made visible [Default: true]
RPKBTools.Toggle = function(visible, openChat)
	if visible == nil then visible = not csc.visible end
	--Set visibility
	wt.SetVisibility(frames.rpkb, visible)
	csc.visible = visible
	--Open chat
	if visible and openChat ~= false then frames.rpkb.editBox:SetFocus() end
end

--Open the RP Keyboard chat window to write a message
RPKBTools.OpenChat = function()
	--Enable the chat window
	RPKBTools.Toggle(true)
	--Focus the Editbox
	frames.rpkb.editBox:SetFocus()
end

---Format the text to appear with the specified symbol set
--- - ***Note:*** All escape sequences included within **text** (like text color formatting) will be removed in the process.
---@param text string Change the recognized characters of this text to the corresponding symbols
---@param symbolSetKey string Key referring to the symbol set subtable within the RP Keyboard table to sample
---@param size? integer Font size to use use for the symbols [Default: 0 *(surrounding text height)*]
---@param r? number Font color red component [Range: 0, 255; Default: 255]
---@param g? number Font color green component [Range: 0, 255; Default: 255]
---@param b? number Font color blue component [Range: 0, 255; Default: 255]
---@return string s
RPKBTools.ApplyFont = function(text, symbolSetKey, size, r, g, b)
	if symbols[symbolSetKey] == nil then return text end
	text = wt.Clear(text)
	local s = ""
	for i = 1, #text do
		local char = text:sub(i, i)
		--Replace with a texture (if there is one)
		s = s .. RPKBTools.GetSymbolTexture(char, symbolSetKey, size, r, g, b)
	end
	return s
end

---Assemble and format printable chat message appearing a real chat message coming from the palyer
---@param text string Text **your character** should communicate
--- - ***Note:*** When **chatType** is set to "EMOTE", **text** will be used as the custom emote text.
---@param chatType ChatTypeId Format the message so it appears as if sent as a message of this type
---@return string? message [Default: nil (*on error*)]
RPKBTools.FormatMessage = function(text, chatType)
	if text == "" then return nil end
	local player = UnitName("player")
	return wt.Color(
		"|Hplayer:" .. player .. ":WHISPER:" .. GetRealmName():upper() .. "|h" .. (chatType == "EMOTE" and "" or "[") .. wt.Color(
			player, C_ClassColor.GetClassColor(select(2, UnitClass("player")))
		) .. (chatType == "EMOTE" and "" or "]") .. "|h" .. GetChatGetSnippet(chatType) .. text, ChatTypeInfo[chatType]
	)
end

---Trasmit a message for other RP Keyboard users nearby in the specified chat channel
---@param text string Contents of the message to send
---@param chatType ChatTypeId Chat channel to send the message through
---@param symbolSetKey? string Apply the specified symbol set as font for the text before sending the message if set [Default: nil *(no font applied)*]
--- - ***Note:*** All escape sequences included within **text** (like text color formatting) will be removed in the process.
---@param translator? boolean Whether to append a translate button at the end of the message [Default: **symbolSet** ~= nil]
RPKBTools.SendMessage = function (text, chatType, symbolSetKey, translator)
	if wt.Clear(text):trim() == "" then return end
	local message = text
	if symbolSetKey ~= nil then
		message = RPKBTools.ApplyFont(text, symbolSetKey, 14, ChatTypeInfo[chatType].r * 255, ChatTypeInfo[chatType].g * 255, ChatTypeInfo[chatType].b * 255)
		if translator ~= false then message = message .. " " .. wt.Hyperlink("item", addonNameSpace .. ":translate:" .. text, "|T" .. textures.logo .. ":0|t") end
	end
	message = RPKBTools.FormatMessage(message, chatType)
	print(message)
	--TODO: Add message tramission
end


--[[ INTERFACE OPTIONS ]]

--Options frame references
local options = {
	about = {},
	presets = {},
	position = {},
	visibility = {
		fade = {},
	},
	background = {
		colors = {},
		size = {},
	},
	text = {
		font = {},
	},
	enhancement = {},
	removals = {},
	notifications = {},
	backup = {},
}

--[ Options Widgets ]

--Main page
local function CreateOptionsShortcuts(parentFrame)
	--Button: Advanced page
	wt.CreateButton({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -10, y = -30 }
		},
		width = 120,
		label = strings.options.advanced.title,
		tooltip = { [0] = { text = strings.options.advanced.description:gsub("#ADDON", addon) }, },
		onClick = function() InterfaceOptionsFrame_OpenToCategory(options.advancedOptionsPage) end,
	})
end
local function CreateAboutInfo(parentFrame)
	--Text: Version
	local version = wt.CreateText({
		frame = parentFrame,
		name = "Version",
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -33 }
		},
		width = 84,
		justify = "LEFT",
		template = "GameFontNormalSmall",
		text = strings.options.main.about.version:gsub("#VERSION", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "Version"), "FFFFFFFF")),
	})
	--Text: Date
	local date = wt.CreateText({
		frame = parentFrame,
		name = "Date",
		position = {
			anchor = "TOPLEFT",
			relativeTo = version,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, y = 0 }
		},
		width = 102,
		justify = "LEFT",
		template = "GameFontNormalSmall",
		text = strings.options.main.about.date:gsub(
			"#DATE", WrapTextInColorCode(strings.misc.date:gsub(
				"#DAY", GetAddOnMetadata(addonNameSpace, "X-Day")
			):gsub(
				"#MONTH", GetAddOnMetadata(addonNameSpace, "X-Month")
			):gsub(
				"#YEAR", GetAddOnMetadata(addonNameSpace, "X-Year")
			), "FFFFFFFF")
		),
	})
	--Text: Author
	local author = wt.CreateText({
		frame = parentFrame,
		name = "Author",
		position = {
			anchor = "TOPLEFT",
			relativeTo = date,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, y = 0 }
		},
		width = 186,
		justify = "LEFT",
		template = "GameFontNormalSmall",
		text = strings.options.main.about.author:gsub("#AUTHOR", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "Author"), "FFFFFFFF")),
	})
	--Text: License
	wt.CreateText({
		frame = parentFrame,
		name = "License",
		position = {
			anchor = "TOPLEFT",
			relativeTo = author,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, y = 0 }
		},
		width = 156,
		justify = "LEFT",
		template = "GameFontNormalSmall",
		text = strings.options.main.about.license:gsub("#LICENSE", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "X-License"), "FFFFFFFF")),
	})
	--EditScrollBox: Changelog
	options.about.changelog = wt.CreateEditScrollBox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = version,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -12 }
		},
		size = { width = parentFrame:GetWidth() - 32, height = 139 },
		fontObject = "GameFontDisableSmall",
		text = ns.GetChangelog(),
		label = strings.options.main.about.changelog.label,
		tooltip = { [0] = { text = strings.options.main.about.changelog.tooltip }, },
		scrollSpeed = 45,
		readOnly = true,
	})
end
local function CreateSupportInfo(parentFrame)
	--Copybox: CurseForge
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "CurseForge",
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -33 }
		},
		width = parentFrame:GetWidth() / 2 - 22,
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		text = "curseforge.com/wow/addons/rp-keyboard",
		label = strings.options.main.support.curseForge .. ":",
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: Wago
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "Wago",
		position = {
			anchor = "TOP",
			offset = { x = (parentFrame:GetWidth() / 2 - 22) / 2 + 8, y = -33 }
		},
		width = parentFrame:GetWidth() / 2 - 22,
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		text = "addons.wago.io/addons/rp-keyboard",
		label = strings.options.main.support.wago .. ":",
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: BitBucket
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "BitBucket",
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -70 }
		},
		width = parentFrame:GetWidth() / 2 - 22,
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		text = "bitbucket.org/Arxareon/rp-keyboard",
		label = strings.options.main.support.bitBucket .. ":",
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: Issues
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "Issues",
		position = {
			anchor = "TOP",
			offset = { x = (parentFrame:GetWidth() / 2 - 22) / 2 + 8, y = -70 }
		},
		width = parentFrame:GetWidth() / 2 - 22,
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		text = "bitbucket.org/Arxareon/rp-keyboard/issues",
		label = strings.options.main.support.issues .. ":",
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
end
local function CreateMainCategoryPanels(parentFrame) --Add the main page widgets to the category panel frame
	--Shortcuts
	local shortcutsPanel = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -82 }
		},
		size = { height = 64 },
		title = strings.options.main.shortcuts.title,
		description = strings.options.main.shortcuts.description:gsub("#ADDON", addon),
	})
	CreateOptionsShortcuts(shortcutsPanel)
	--About
	local aboutPanel = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = shortcutsPanel,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -32 }
		},
		size = { height = 231 },
		title = strings.options.main.about.title,
		description = strings.options.main.about.description:gsub("#ADDON", addon),
	})
	CreateAboutInfo(aboutPanel)
	--Support
	local supportPanel = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = aboutPanel,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -32 }
		},
		size = { height = 111 },
		title = strings.options.main.support.title,
		description = strings.options.main.support.description:gsub("#ADDON", addon),
	})
	CreateSupportInfo(supportPanel)
end

--Symbols page
local function CreateSymbolAboutInfo(parentFrame)
	--Text: Version
	local version = wt.CreateText({
		frame = parentFrame,
		name = "Version",
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -33 }
		},
		width = 84,
		justify = "LEFT",
		template = "GameFontNormalSmall",
		text = strings.options.main.about.version:gsub("#VERSION", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "Version"), "FFFFFFFF")),
	})
	--Text: Date
	local date = wt.CreateText({
		frame = parentFrame,
		name = "Date",
		position = {
			anchor = "TOPLEFT",
			relativeTo = version,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, y = 0 }
		},
		width = 102,
		justify = "LEFT",
		template = "GameFontNormalSmall",
		text = strings.options.main.about.date:gsub(
			"#DATE", WrapTextInColorCode(strings.misc.date:gsub(
				"#DAY", GetAddOnMetadata(addonNameSpace, "X-Day")
			):gsub(
				"#MONTH", GetAddOnMetadata(addonNameSpace, "X-Month")
			):gsub(
				"#YEAR", GetAddOnMetadata(addonNameSpace, "X-Year")
			), "FFFFFFFF")
		),
	})
	--Text: Author
	local author = wt.CreateText({
		frame = parentFrame,
		name = "Author",
		position = {
			anchor = "TOPLEFT",
			relativeTo = date,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, y = 0 }
		},
		width = 186,
		justify = "LEFT",
		template = "GameFontNormalSmall",
		text = strings.options.main.about.author:gsub("#AUTHOR", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "Author"), "FFFFFFFF")),
	})
	--Text: License
	wt.CreateText({
		frame = parentFrame,
		name = "License",
		position = {
			anchor = "TOPLEFT",
			relativeTo = author,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, y = 0 }
		},
		width = 156,
		justify = "LEFT",
		template = "GameFontNormalSmall",
		text = strings.options.main.about.license:gsub("#LICENSE", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "X-License"), "FFFFFFFF")),
	})
end
local function CreateSymbolsCategoryPanels(parentFrame) --Add the main page widgets to the category panel frame
	--Shortcuts
	local shortcutsPanel = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -82 }
		},
		size = { height = 64 },
		title = strings.options.main.shortcuts.title,
		description = strings.options.main.shortcuts.description:gsub("#ADDON", addon),
	})
	CreateOptionsShortcuts(shortcutsPanel)
end

--Advanced page
local function CreateOptionsProfiles(parentFrame)
	--TODO: Add profiles handler widgets
end
local function CreateBackupOptions(parentFrame)
	--EditScrollBox & Popup: Import & Export
	local importPopup = wt.CreatePopup(addonNameSpace, {
		name = "IMPORT",
		text = strings.options.advanced.backup.warning,
		accept = strings.options.advanced.backup.import,
		onAccept = function()
			--Load from string to a temporary table
			local success, t = pcall(loadstring("return " .. wt.Clear(options.backup.string:GetText())))
			if success and type(t) == "table" then
				--Run DB checkup on the loaded table
				wt.RemoveEmpty(t.account, CheckValidity)
				wt.RemoveEmpty(t.character, CheckValidity)
				wt.AddMissing(t.account, db)
				wt.AddMissing(t.character, dbc)
				RestoreOldData(t.account, t.character, wt.RemoveMismatch(t.account, db), wt.RemoveMismatch(t.character, dbc))
				--Copy values from the loaded DBs to the addon DBs
				wt.CopyValues(t.account, db)
				wt.CopyValues(t.character, dbc)
				--Update the interface options
				wt.LoadOptionsData()
			else print(wt.Color(addon .. ":", colors.red[0]) .. " " .. wt.Color(strings.options.advanced.backup.error, colors.blue[0])) end
		end
	})
	local backupBox
	options.backup.string, backupBox = wt.CreateEditScrollBox({
		parent = parentFrame,
		name = "ImportExport",
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -30 }
		},
		size = { width = parentFrame:GetWidth() - 32, height = 276 },
		maxLetters = 5400,
		fontObject = "GameFontWhiteSmall",
		label = strings.options.advanced.backup.backupBox.label,
		tooltip = {
			[0] = { text = strings.options.advanced.backup.backupBox.tooltip[0] },
			[1] = { text = strings.options.advanced.backup.backupBox.tooltip[1] },
			[2] = { text = "\n" .. strings.options.advanced.backup.backupBox.tooltip[2]:gsub("#ENTER", strings.keys.enter) },
			[3] = { text = strings.options.advanced.backup.backupBox.tooltip[3], color = { r = 0.89, g = 0.65, b = 0.40 } },
			[4] = { text = "\n" .. strings.options.advanced.backup.backupBox.tooltip[4], color = { r = 0.92, g = 0.34, b = 0.23 } },
		},
		scrollSpeed = 60,
		onEnterPressed = function() StaticPopup_Show(importPopup) end,
		onEscapePressed = function(self) self:SetText(wt.TableToString({ account = db, character = dbc }, options.backup.compact:GetChecked(), true)) end,
		onLoad = function(self) self:SetText(wt.TableToString({ account = db, character = dbc }, options.backup.compact:GetChecked(), true)) end,
	})
	--Checkbox: Compact
	options.backup.compact = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = backupBox,
			relativePoint = "BOTTOMLEFT",
			offset = { x = -8, y = -13 }
		},
		label = strings.options.advanced.backup.compact.label,
		tooltip = { [0] = { text = strings.options.advanced.backup.compact.tooltip }, },
		onClick = function(self)
			options.backup.string:SetText(wt.TableToString({ account = db, character = dbc }, self:GetChecked(), true))
			--Set focus after text change to set the scroll to the top and refresh the position character counter
			options.backup.string:SetFocus()
			options.backup.string:ClearFocus()
		end,
		optionsData = {
			storageTable = cs,
			key = "compactBackup",
		},
	})
	--Button: Load
	local load = wt.CreateButton({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			relativeTo = backupBox,
			relativePoint = "BOTTOMRIGHT",
			offset = { x = 6, y = -13 }
		},
		width = 80,
		label = strings.options.advanced.backup.load.label,
		tooltip = { [0] = { text = strings.options.advanced.backup.load.tooltip }, },
		onClick = function() StaticPopup_Show(importPopup) end,
	})
	--Button: Reset
	wt.CreateButton({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			relativeTo = load,
			relativePoint = "TOPLEFT",
			offset = { x = -10, y = 0 }
		},
		width = 80,
		label = strings.options.advanced.backup.reset.label,
		tooltip = { [0] = { text = strings.options.advanced.backup.reset.tooltip }, },
		onClick = function()
			options.backup.string:SetText("") --Remove text to make sure OnTextChanged will get called
			options.backup.string:SetText(wt.TableToString({ account = db, character = dbc }, options.backup.compact:GetChecked(), true))
			--Set focus after text change to set the scroll to the top and refresh the position character counter
			options.backup.string:SetFocus()
			options.backup.string:ClearFocus()
		end,
	})
end
local function CreateAdvancedCategoryPanels(parentFrame) --Add the advanced page widgets to the category panel frame
	--Profiles
	local profilesPanel = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -82 }
		},
		size = { height = 64 },
		title = strings.options.advanced.profiles.title,
		description = strings.options.advanced.profiles.description:gsub("#ADDON", addon),
	})
	CreateOptionsProfiles(profilesPanel)
	---Backup
	local backupOptions = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = profilesPanel,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -32 }
		},
		size = { height = 374 },
		title = strings.options.advanced.backup.title,
		description = strings.options.advanced.backup.description:gsub("#ADDON", addon),
	})
	CreateBackupOptions(backupOptions)
end

--[ Options Category Panels ]

--Save the pending changes
local function SaveOptions()
	--Update the SavedVariabes DBs
	RPKeyboardDB = wt.Clone(db)
	RPKeyboardDBC = wt.Clone(dbc)
end
--Cancel all potential changes made in all option categories
local function CancelChanges()
	LoadDBs()
end
--Restore all the settings under the main option category to their default values
local function DefaultOptions()
	--Reset the DBs
	RPKeyboardDB = wt.Clone(dbDefault)
	RPKeyboardDBC = wt.Clone(dbcDefault)
	wt.CopyValues(dbDefault, db)
	wt.CopyValues(dbcDefault, dbc)
	--Update the interface options
	wt.LoadOptionsData()
	--Notification
	print(wt.Color(addon .. ":", colors.red[0]) .. " " .. wt.Color(strings.options.defaults, colors.blue[0]))
end

--Create and add the options category panel frames to the WoW Interface Options
local function LoadInterfaceOptions()
	--Main options panel
	options.mainOptionsPage = wt.CreateOptionsPanel({
		name = addonNameSpace .. "Main",
		title = addon,
		description = strings.options.main.description:gsub("#ADDON", addon):gsub("#KEYWORD", strings.chat.keyword),
		logo = textures.logo,
		titleLogo = true,
		okay = SaveOptions,
		cancel = CancelChanges,
		default = DefaultOptions,
	})
	CreateMainCategoryPanels(options.mainOptionsPage) --Add categories & GUI elements to the panel
	--Advanced options panel
	options.advancedOptionsPage = wt.CreateOptionsPanel({
		parent = options.mainOptionsPage.name,
		name = addonNameSpace .. "Advanced",
		title = strings.options.advanced.title,
		description = strings.options.advanced.description:gsub("#ADDON", addon),
		logo = textures.logo,
		default = DefaultOptions,
		autoSave = false,
		autoLoad = false,
	})
	CreateAdvancedCategoryPanels(options.advancedOptionsPage) --Add categories & GUI elements to the panel
end


--[[ CHAT CONTROL ]]

--[ Chat Utilities ]

---Print visibility info
---@param load? boolean [Default: false]
local function PrintStatus(load)
	if load == true and not db.statusNotice then return end
	print(wt.Color(frames.rpkb:IsVisible() and strings.chat.status.enabled:gsub(
		"#ADDON", wt.Color(addon, colors.red[0])
	) or strings.chat.status.disabled:gsub(
		"#ADDON", wt.Color(addon, colors.red[0])
	), colors.blue[0]))
end
--Print help info
local function PrintInfo()
	print(wt.Color(strings.chat.help.thanks:gsub("#ADDON", wt.Color(addon, colors.red[0])), colors.blue[0]))
	PrintStatus()
	print(wt.Color(strings.chat.help.hint:gsub( "#HELP_COMMAND", wt.Color(strings.chat.keyword .. " " .. strings.chat.help.command, colors.red[1])), colors.blue[1]))
end
--Print the command list with basic functionality info
local function PrintCommands()
	print(wt.Color(addon, colors.red[0]) .. " ".. wt.Color(strings.chat.help.list .. ":", colors.blue[0]))
	--Index the commands (skipping the help command) and put replacement code segments in place
	local commands = {
		[0] = {
			command = strings.chat.options.command,
			description = strings.chat.options.description:gsub("#ADDON", addon)
		},
		[1] = {
			command = strings.chat.toggle.command,
			description = strings.chat.toggle.description:gsub("#ADDON", addon):gsub(
				"#STATE", wt.Color(dbc.disabled and strings.misc.disabled or strings.misc.enabled, colors.red[1])
			)
		},
	}
	--Print the list
	for i = 0, #commands do
		print("    " .. wt.Color(strings.chat.keyword .. " " .. commands[i].command, colors.red[1]) .. wt.Color(" - " .. commands[i].description, colors.blue[1]))
	end
end

--[ Slash Command Handlers ]

local function ToggleCommand()
	dbc.disabled = not dbc.disabled
	wt.SetVisibility(frames.rpkb, not dbc.disabled)
	--Response
	print(wt.Color(dbc.disabled and strings.chat.toggle.disabled:gsub(
			"#ADDON", wt.Color(addon, colors.red[0])
		) or strings.chat.toggle.enabled:gsub(
			"#ADDON", wt.Color(addon, colors.red[0])
		), colors.blue[0]))
	--Update in the SavedVariabes DB
	RPKeyboardDBC.disabled = dbc.disabled
end

SLASH_RPKB1 = strings.chat.keyword
function SlashCmdList.RPKB(line)
	local command, parameter = strsplit(" ", line)
	if command == strings.chat.help.command then
		PrintCommands()
	elseif command == strings.chat.options.command then
		InterfaceOptionsFrame_OpenToCategory(options.mainOptionsPage)
		InterfaceOptionsFrame_OpenToCategory(options.mainOptionsPage) --Load twice to make sure the proper page and category is loaded
	elseif command == strings.chat.toggle.command then
		ToggleCommand()
	else
		PrintInfo()
	end
end


--[[ INITIALIZATION ]]

--[ Frame Setup ]

--Set chat frame parameters
local function SetUpChatFrame()

	--[ Main Frame ]

	--Position & dimensions
	frames.rpkb:SetPoint("TOPLEFT", ChatFrame1EditBox, "BOTTOMLEFT")
	frames.rpkb:SetSize(ChatFrame1EditBox:GetWidth(), 32)

	--Visibility
	frames.rpkb:SetFrameStrata("LOW")
	wt.SetVisibility(frames.rpkb, csc.visible)

	--Behavior
	frames.rpkb:EnableMouse(true)

	--[ Toggle ]

	--Button
	frames.toggle = CreateFrame("Button", frames.rpkb:GetName() .. "ToggleButton", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	frames.toggle:SetPoint("TOP", ChatFrameMenuButton, "BOTTOM", 0, -37)
	frames.toggle:SetSize(21, 21)
	if not frames.rpkb:IsVisible() then frames.toggle:SetAlpha(0.4) end
	frames.toggle:SetScript("OnClick", function() RPKBTools.Toggle() end)

	--Logo
	wt.CreateTexture({
		parent = frames.toggle,
		path = textures.logo,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 0, y = 0 }
		},
		size = { width = frames.toggle:GetWidth(), height = frames.toggle:GetHeight() },
	})

	--Linked events
	frames.rpkb:SetScript("OnShow", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		frames.toggle:SetAlpha(1)
	end)
	frames.rpkb:SetScript("OnHide", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		frames.toggle:SetAlpha(0.4)
	end)

	--[ Message Preview ]

	--Background panel
	local preview = wt.CreatePanel({
		parent = frames.rpkb,
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -26 }
		},
		size = { width = frames.rpkb:GetWidth() - 10, height = 78 },
		title = "Preview",
		showTitle = false,
	})
	preview:Hide()

	--Scroll frame
	local previewContent, previewFrame = wt.CreateScrollFrame({
		parent = preview,
		position = { anchor = "CENTER", },
		size = { width = preview:GetWidth() - 12, height = preview:GetHeight() - 12 },
		scrollSize = { height = 65 },
		scrollSpeed = 17,
	})
	_G[previewFrame:GetName() .. "ScrollBarScrollUpButton"]:ClearAllPoints()
	_G[previewFrame:GetName() .. "ScrollBarScrollUpButton"]:SetPoint("TOPRIGHT", previewFrame, "TOPRIGHT", 2, 1)
	_G[previewFrame:GetName() .. "ScrollBarScrollDownButton"]:ClearAllPoints()
	_G[previewFrame:GetName() .. "ScrollBarScrollDownButton"]:SetPoint("BOTTOMRIGHT", previewFrame, "BOTTOMRIGHT", 2, -1)
	_G[previewFrame:GetName() .. "ScrollBar"]:ClearAllPoints()
	_G[previewFrame:GetName() .. "ScrollBar"]:SetPoint("TOP", _G[previewFrame:GetName() .. "ScrollBarScrollUpButton"], "BOTTOM")
	_G[previewFrame:GetName() .. "ScrollBar"]:SetPoint("BOTTOM", _G[previewFrame:GetName() .. "ScrollBarScrollDownButton"], "TOP")
	_G[previewFrame:GetName() .. "ScrollBarBackground"]:SetSize(_G[previewFrame:GetName() .. "ScrollBar"]:GetWidth() + 1, _G[previewFrame:GetName() .. "ScrollBar"]:GetHeight() - 6)

	--Text
	local previewText = wt.CreateText({
		frame = previewContent,
		position = {
			anchor = "TOP",
			offset = { x = 0, y = 1 }
		},
		width = previewContent:GetWidth(),
		justify = "LEFT",
		template = "ChatFontNormal",
	})

	--[ Background Art ]

	local artCenter = wt.CreateTexture({
		parent = frames.rpkb,
		path = "Interface/ChatFrame/UI-ChatInputBorder-Mid2",
		position = {
			anchor = "TOP",
			offset = { x = 0, y = 2 }
		},
		size = { width = frames.rpkb:GetWidth() - 64, height = 32 },
		tile = true,
	})

	local artLeft = wt.CreateTexture({
		parent = frames.rpkb,
		path = "Interface/ChatFrame/UI-ChatInputBorder-Left2",
		position = {
			anchor = "RIGHT",
			relativeTo = artCenter,
			relativePoint = "LEFT",
			offset = { x = 0, y = 0 }
		},
		size = { width = 32, height = 32 },
	})

	local artRight = wt.CreateTexture({
		parent = frames.rpkb,
		path = "Interface/ChatFrame/UI-ChatInputBorder-Right2",
		position = {
			anchor = "LEFT",
			relativeTo = artCenter,
			relativePoint = "RIGHT",
			offset = { x = 0, y = 0 }
		},
		size = { width = 32, height = 32 },
	})

	--[ Chat Type Indicator ]

	frames.rpkb.chatType = wt.CreateText({
		frame = frames.rpkb,
		name = "ChatType",
		position = {
			anchor = "LEFT",
			relativeTo = artLeft,
			relativePoint = "LEFT",
			offset = { x = 15, y = 0 },
		},
		width = 80,
		justify = "LEFT",
		template = "ChatFontNormal",
	})

	--[ Editbox ]

	--Frame
	frames.rpkb.editBox = CreateFrame("EditBox", frames.rpkb:GetName() .. "InputBox", frames.rpkb, BackdropTemplateMixin and "BackdropTemplate")
	frames.rpkb.editBox:SetPoint("RIGHT", artRight, "RIGHT", -12, 0)
	frames.rpkb.editBox:SetSize(frames.rpkb:GetWidth() - 57, 17)

	--Font & text
	frames.rpkb.editBox:SetMultiLine(false)
	frames.rpkb.editBox:SetFontObject(ChatFontNormal)
	frames.rpkb.editBox:SetJustifyH("LEFT")
	frames.rpkb.editBox:SetJustifyV("MIDDLE")
	frames.rpkb.editBox:SetMaxLetters(255)

	--Art visibility
	artCenter:SetAlpha(0.3)
	artLeft:SetAlpha(0.3)
	artRight:SetAlpha(0.3)

	--Events & behavior
	frames.rpkb.editBox:SetAutoFocus(false)
	frames.rpkb:SetScript("OnMouseDown", function() frames.rpkb.editBox:SetFocus() end)
	frames.rpkb.editBox:SetScript("OnEditFocusGained", function(self)
		--Visibility
		frames.rpkb:SetFrameStrata("HIGH")
		--Art
		artCenter:SetAlpha(1)
		artLeft:SetAlpha(1)
		artRight:SetAlpha(1)
		--Chat type
		frames.rpkb.chatType:SetText(wt.Color(GetChatSendSnippet(currentChatType), ChatTypeInfo[currentChatType]))
		--Preview
		preview:Show()
	end)
	frames.rpkb.editBox:SetScript("OnEditFocusLost", function(self)
		if self:GetText() ~= "" then return end
		--Visibility
		frames.rpkb:SetFrameStrata("LOW")
		--Art
		artCenter:SetAlpha(0.3)
		artLeft:SetAlpha(0.3)
		artRight:SetAlpha(0.3)
		--Preview
		previewText:SetText("")
		preview:Hide()
		--Chat type
		frames.rpkb.chatType:SetText("")
	end)
	frames.rpkb.editBox:SetScript("OnTextChanged", function(self, user)
		if not user then return end
		--Update preview
		previewText:SetText(
			RPKBTools.ApplyFont(self:GetText(), "Sample", 14, ChatTypeInfo[currentChatType].r * 255, ChatTypeInfo[currentChatType].g * 255, ChatTypeInfo[currentChatType].b * 255)
		)
	end)
	frames.rpkb.editBox:SetScript("OnEnterPressed", function(self)
		if IsModifierKeyDown() then return end
		--Trasmit the message
		RPKBTools.SendMessage(self:GetText(), currentChatType, "Sample")
		--Clear the input
		self:SetText("")
		self:ClearFocus()
	end)
	frames.rpkb.editBox:SetScript("OnEscapePressed", function(self)
		--Clear the input
		self:SetText("")
		self:ClearFocus()
	end)

	--Tooltip
	-- editBox:HookScript("OnEnter", function()
	-- 	WidgetToolbox[ns.WidgetToolsVersion].AddTooltip(nil, editBox, "ANCHOR_RIGHT", t.label, t.tooltip)
	-- end)
	-- editBox:HookScript("OnLeave", function() customTooltip:Hide() end)

	--[ Resizing Events ]

	ChatFrame1ResizeButton:HookScript("OnMouseUp", function()
		frames.rpkb:SetWidth(ChatFrame1EditBox:GetWidth())
		preview:SetWidth(frames.rpkb:GetWidth() - 10)
		previewFrame:SetWidth(preview:GetWidth() - 8)
		previewContent:SetWidth(previewFrame:GetWidth() - 20)
		previewText:SetWidth(previewContent:GetWidth())
		artCenter:SetWidth(frames.rpkb:GetWidth() - 64)
		frames.rpkb.editBox:SetWidth(frames.rpkb:GetWidth() - 57)
	end)

	local ConfirmRedockChatOnAccept = StaticPopupDialogs["CONFIRM_REDOCK_CHAT"].OnAccept
	StaticPopupDialogs["CONFIRM_REDOCK_CHAT"].OnAccept = function()
		--Call the original Blizzard function
		ConfirmRedockChatOnAccept()
		--Resize RPKB elements
		frames.rpkb:SetWidth(ChatFrame1EditBox:GetWidth())
		preview:SetWidth(frames.rpkb:GetWidth() - 10)
		previewFrame:SetWidth(preview:GetWidth() - 8)
		previewContent:SetWidth(previewFrame:GetWidth() - 20)
		previewText:SetWidth(previewContent:GetWidth())
		artCenter:SetWidth(frames.rpkb:GetWidth() - 64)
		frames.rpkb.editBox:SetWidth(frames.rpkb:GetWidth() - 57)
	end
end

--Set up chat translate frame
local function SetUpTranslateFrame()

	--[ Tooltip ]

	--Frame & position
	local tooltip = wt.CreateGameTooltip(addonNameSpace)
	tooltip:SetPoint("BOTTOMLEFT", ChatFrame1Background, "BOTTOMRIGHT")

	--Events & behavior
	tooltip:HookScript("OnMouseUp", function() tooltip:Hide() end)
	tooltip:HookScript("OnShow", function() PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) end)
	tooltip:HookScript("OnHide", function() PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF) end)

	--[ Hyprlink Handler ]

	wt.SetHyperlinkHandler(addonNameSpace, "translate", function(text)
		--Toggle tooltip
		if tooltip:IsVisible() then
			tooltip:Hide()
		else
			wt.AddTooltip(tooltip, ChatFrame1Background, "ANCHOR_PRESERVE", "|T" .. textures.logo .. ":0|t " .. strings.translate.title, {
				[0] = {
					text = text,
					font = ChatFontNormal,
				},
				[1] = {
					text = "\n" .. strings.translate.close,
					font = GameFontNormalTiny,
					color = colors.grey[0],
				},
			})
		end
	end)
end

--[ Loading ]

function frames.rpkb:ADDON_LOADED(name)
	if name ~= addonNameSpace then return end
	frames.rpkb:UnregisterEvent("ADDON_LOADED")
	--Load & check the DBs
	if LoadDBs() then
		PrintInfo()
		cs.first = true
	end
	--Create cross-session account-wide variables
	if cs.compactBackup == nil then cs.compactBackup = true end
	--Create cross-session character-specific variables
	if csc.visible == nil then csc.visible = false end
	--Set key binding labels
	BINDING_HEADER_RPKB = addon
	BINDING_NAME_RPKB_OPEN = strings.keybinds.open
	BINDING_NAME_RPKB_TOGGLE = strings.keybinds.toggle
	--Set up the interface options
	LoadInterfaceOptions()
	--Set up the frames
	SetUpChatFrame()
	SetUpTranslateFrame()
	--TDODO: Remove TEMP:
	RPKBTools.AddSet({
		name = "Sample",
		description = "This is a sample set.",
		version = "1.0",
		date = "MM/DD/YYYY",
		license = "License",
		authors = {
			[0] = "Author",
		},
		links = {
			[0] = {
				title = "Link",
				url = "URL"
			},
		},
		textures = {
			["!"] = {
				path = root .. "Textures/0_Exclamation.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["\""] = {
				path = root .. "Textures/1_Quotation.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["'"] = {
				path = root .. "Textures/2_Apostrophe.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			[","] = {
				path = root .. "Textures/3_Comma.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["."] = {
				path = root .. "Textures/4_Period.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			[":"] = {
				path = root .. "Textures/5_Colon.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			[";"] = {
				path = root .. "Textures/6_Semicolon.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["?"] = {
				path = root .. "Textures/7_Question.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["a"] = {
				path = root .. "Textures/8_A.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["b"] = {
				path = root .. "Textures/9_B.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["c"] = {
				path = root .. "Textures/10_C.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["d"] = {
				path = root .. "Textures/11_D.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
		},
	})
end
function frames.rpkb:PLAYER_ENTERING_WORLD()
	--Visibility notice
	if not frames.rpkb:IsVisible() then PrintStatus(true) end
	--Set default key bindings
	if cs.first then
		cs.first = nil
		SetBinding("CTRL-ENTER", "RPKB_TOGGLE")
		--Chat notification
		print(wt.Color(addon .. ":", colors.red[0]) .. " " .. wt.Color(strings.chat.keybind.toggle:gsub(
			"#KEYBIND", wt.Color(strings.keys.ctrl .. "-" .. strings.keys.enter:lower():gsub("^%l", string.upper), colors.blue[1])
		):gsub(
			"#ACTION", wt.Color(strings.keybinds.toggle, colors.blue[1])
		), colors.blue[0]))
	end
end


--[[ CHAT MESSAGING ]]

