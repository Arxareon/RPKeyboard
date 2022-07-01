--[[ ADDON INFO ]]

--Addon namespace string & table
local addonNameSpace, ns = ...

--Addon display name
local _, addonTitle = GetAddOnInfo(addonNameSpace)

--Addon root folder
local root = "Interface/AddOns/" .. addonNameSpace .. "/"


--[[ ASSETS & RESOURCES ]]

--WidgetTools reference
local wt = WidgetToolbox[ns.WidgetToolsVersion]

--Strings & Localization
local strings = ns.LoadLocale()
strings.chat.keyword = "/rpkb"
local prefix = "RPKB"

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
	send = root .. "Textures/Send.tga",
	blank = root .. "Textures/Blank.tga",
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
local csc --Cross-session character-specific data

--Default values
local dbDefault = {
	position = {
		snapToChat = true,
		point = "BOTTOMLEFT",
		offset = { x = 30, y = 86, },
	},
}
local dbcDefault = {
	disabled = false,
}

--Symbol Sets
local symbols = {}
local currentSymbolSet


--[[ FRAMES & EVENTS ]]

--[ Main Frame ]

--Addon frame references
local frames = { rpkb = {} }

--Creating frames
frames.rpkb.main = CreateFrame("Frame", addonNameSpace, UIParent) --Main addon frame

--Registering events
frames.rpkb.main:RegisterEvent("ADDON_LOADED")
frames.rpkb.main:RegisterEvent("PLAYER_ENTERING_WORLD")
frames.rpkb.main:RegisterEvent("CHAT_MSG_ADDON")
frames.rpkb.main:RegisterEvent("CHANNEL_UI_UPDATE")

--Event handler
frames.rpkb.main:SetScript("OnEvent", function(self, event, ...)
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

--[ Logs Management ]

--Log indexes
local logSentIndex
local logReceivedIndex

---Add a sent message to the logs
---@param text any
---@param symbolSetKey any
---@param displayChannel any
---@param sendChannel any
---@param target any
local function AddSentLog(text, symbolSetKey, displayChannel, sendChannel, target)
	logSentIndex = logSentIndex + 1
	table.insert(csc.logs.sent, logSentIndex, {
		text = text,
		symbolSet = symbolSetKey,
		display = displayChannel,
		channel = sendChannel,
		target = target,
		date = date(strings.misc.dateTimeFormat),
	})
	-- wt.Dump(csc.logs.sent, "Sent")
end

---Add a received message to the logs
---@param text any
---@param symbolSetKey any
---@param displayChannel any
---@param sendChannel any
---@param sender any
local function AddReceivedLog(text, symbolSetKey, displayChannel, sendChannel, sender)
	logReceivedIndex = logReceivedIndex + 1
	table.insert(csc.logs.received, logReceivedIndex, {
		text = text,
		symbolSet = symbolSetKey,
		displayChannel = displayChannel,
		sendChannel = sendChannel,
		sender = sender,
		date = date(strings.misc.dateTimeFormat),
	})
	-- wt.Dump(csc.logs.received, "Received")
end

--[ Chat Type Handling ]

local currentDisplayChannel = "SAY"
local currentSendChannel = "CHANNEL"
local customChannelID

---Generate a string snippet signaling the current chat type for selected types that goes at the start in a chat input field
---@param chatType ChatType
---@return string
--- - ***Note:*** "#PLAYER" may be included in the string intended to be replaced with the sender player's name (e. g. when **chatType** is "WHISPER").
--- - ***Example:***
--- 	```
--- 	--Inserting the name of self
--- 	GetChatSendSnippet("SAY"):gsub("#PLAYER", UnitName("player"))
--- 	```
local function GetChatSendSnippet(chatType)
	if chatType == "SAY" then return CHAT_SAY_SEND end
	if chatType == "YELL" then return CHAT_YELL_SEND end
	if chatType == "WHISPER" then return CHAT_WHISPER_SEND:gsub("%%s", ""):gsub("[]:%s]", "") end
	if chatType == "EMOTE" then return UnitName("player") .. " " end
	if chatType == "PARTY" then return CHAT_PARTY_SEND end
	if chatType == "GUILD" then return CHAT_GUILD_SEND end
	if chatType == "OFFICER" then return CHAT_OFFICER_SEND end
	if chatType == "INSTANCE_CHAT" or chatType == "INSTANCE_CHAT_LEADER" then return CHAT_INSTANCE_CHAT_SEND end
	if chatType == "RAID" or chatType == "RAID_LEADER" then return CHAT_RAID_SEND end
	if chatType == "RAID_WARNING" then return CHAT_RAID_WARNING_SEND end
	return ""
end

---Generate a string snippet signaling the current chat type for selected types that goes at the start of a sent/received chat message
---@param chatType ChatType
---@return string
--- - ***Note:*** "#PLAYER" will be included in the string intended to be replaced with the sender player's name.
--- - ***Example:***
--- 	```
--- 	--Inserting the name of self
--- 	GetChatSendSnippet("SAY"):gsub("#PLAYER", UnitName("player"))
--- 	```
local function GetChatReceiveSnippet(chatType)
	if chatType == "SAY" then return CHAT_SAY_GET:gsub("%%s", "[#PLAYER]") end
	if chatType == "YELL" then return CHAT_YELL_GET:gsub("%%s", "[#PLAYER]") end
	if chatType == "WHISPER" then return CHAT_WHISPER_GET:gsub("%%s", "[#PLAYER]") end
	if chatType == "EMOTE" then return "#PLAYER " end
	if chatType == "PARTY" then return CHAT_PARTY_GET:gsub("%%s", "#PLAYER") end
	if chatType == "GUILD" then return CHAT_GUILD_GET:gsub("%%s", "#PLAYER") end
	if chatType == "OFFICER" then return CHAT_OFFICER_GET:gsub("%%s", "#PLAYER") end
	if chatType == "INSTANCE_CHAT" then return CHAT_INSTANCE_CHAT_GET:gsub("%%s", "#PLAYER") end
	if chatType == "INSTANCE_CHAT_LEADER" then return CHAT_INSTANCE_CHAT_LEADER_GET:gsub("%%s", "#PLAYER") end
	if chatType == "RAID" then return CHAT_RAID_GET:gsub("%%s", "#PLAYER") end
	if chatType == "RAID_LEADER" then return CHAT_RAID_LEADER_GET:gsub("%%s", "#PLAYER") end
	if chatType == "RAID_WARNING" then return CHAT_RAID_WARNING_GET:gsub("%%s", "[#PLAYER]") end
	return ": "
end

---Check if the input text is recognizable as a chat command to change the current chat type
---@param chatType ChatType
---@return string? channelName [Default: *(nil when the channel wasn't in the list)*]
local function GetChatName(chatType)
	if chatType == "SAY" then return CHAT_MSG_SAY .. "*" end
	if chatType == "YELL" then return CHAT_MSG_YELL .. "*" end
	if chatType == "WHISPER" then return CHAT_MSG_WHISPER_INFORM end
	if chatType == "EMOTE" then return CHAT_MSG_EMOTE .. "*" end
	if chatType == "PARTY" then return CHAT_MSG_PARTY end
	if chatType == "GUILD" then return CHAT_MSG_GUILD end
	if chatType == "OFFICER" then return CHAT_MSG_OFFICER end
	if chatType == "INSTANCE_CHAT" then return CHAT_MSG_INSTANCE_CHAT end
	if chatType == "INSTANCE_CHAT_LEADER" then return CHAT_MSG_INSTANCE_CHAT_LEADER end
	if chatType == "RAID" then return CHAT_MSG_RAID end
	if chatType == "RAID_LEADER" then return CHAT_MSG_RAID_LEADER end
	if chatType == "RAID_WARNING" then return CHAT_MSG_RAID_WARNING end
	return nil
end

--[ Global Tools ]

--Global RP Keyboard table
RPKBTools = {}

---Add or update a set of symbols to the RP Keyboard table
---@param data table Table containing information about the symbol set
--- - **name** string ― Displayed name of the symbol set
--- - **description**? string *optional* ― Details about the symbol set
--- - **version** string ― The current version number of this set
--- - **date**? table *optional* ― The release date of the current version of this set
--- 	- **day** string
--- 	- **month** string
--- 	- **year** string
--- - **license**? string *optional* ― The current version number of this set [Default: "All Rights Reserved"]
--- 	- ***Note:*** American spelling is used, be mindful of confusing it with "licence".
--- - **credits** table [indexed, 0-based] ― List of the authors who created and released this symbol set
--- 	- **[*index*]** table ― Details of a given author
--- 		- **name** string ― The name of the given author
--- 		- **role**? string *optional* ― The role of the given author
--- - **links**? table [indexed, 0-based] *optional* ― Collection links related to the symbol set
--- 	- **[*index*]** table ― Details of a given link
--- 		- **title** string ― Displayed title of the specific link
--- 		- **url** string ― The copyable URL of the specific link
--- - **textures** table [key, value pairs] ― Table containing subtables of all details and data of each specific symbol in the set
--- 	- **[*key*]** string ― To be recognized, the specific singular character represented by the specific symbol must be used as the key.
--- 	- **[*value*]** table
--- 		- **path** string ― Path to the specific texture file of the symbol relative to the root directory of the specific WoW client.
--- 			- ***Note:*** Use "/" as separator in file paths (Example: Interface/AddOns/RPKeyboard/Textures/Logo.tga).
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
--- 	4. **version** has been left out or it is invalid.
--- 	5. **date** is set but it is invalid or empty.
--- 	6. **day**, **month** or **year** in **date** has been left out or it is invalid.
--- 	7. **license** is set but it is invalid.
--- 	8. **credits** has been left out, it is invalid or empty.
--- 	9. **name** of a child item in **credits** has been left out or it is invalid.
--- 	10. **role** of a child item in **credits** is set but it is invalid.
--- 	11. **links** is set but it is invalid or empty.
--- 	12. **title** or **url** of a child item in **links** has been left out or it is invalid.
--- 	13. **textures** has been left out, it is invalid or empty.
--- 	14. The key of an item in **textures** is invalid (not a one character long string).
--- 	15. A direct child value in **textures** is not a table or it is empty.
--- 	16. **path** in a subtable of **textures** has been left out or it is invalid (check file format as well).
--- 	17. **size** in a subtable of **textures** is set but it is invalid (not an integer with a power of 2 value).
--- 	18. **cut** in a subtable of **textures** is set but it is invalid or empty.
--- 	19. **left**, **right**, **top** or **bottom** in **cut** is set but it is invalid (nut an integer within the required range).
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
		if type(data.date) ~= "table" then return 5 elseif next(data.date) == nil then return 5 end
		validatedSet.date = {}
		if type(data.date.day) ~= "string" or data.date.day == "" then return 6 end
		if type(data.date.month) ~= "string" or data.date.month == "" then return 6 end
		if type(data.date.year) ~= "string" or data.date.year == "" then return 6 end
		validatedSet.date.day = data.date.day
		validatedSet.date.month = data.date.month
		validatedSet.date.year = data.date.year
	end

	--Check license
	if data.license ~= nil then
		if type(data.license) ~= "string" or data.license == "" then return 7 end
		validatedSet.license = data.license
	else validatedSet.license = "All Rights Reserved" end

	--Check credits
	if type(data.credits) ~= "table" then return 8 elseif next(data.credits) == nil then return 8 end
	validatedSet.credits = {}
	for i = 0, #data.credits do
		if type(data.credits[i].name) ~= "string" or data.credits[i].url == "" then return 9 end
		validatedSet.credits[i] = {}
		validatedSet.credits[i].name = data.credits[i].name
		if data.credits[i].role ~= nil then
			if type(data.credits[i].role) ~= "string" or data.credits[i].title == "" then return 10 end
			validatedSet.credits[i].role = data.credits[i].role
		end
	end

	--Check links
	if data.links ~= nil then
		if type(data.links) ~= "table" then return 11 elseif next(data.links) == nil then return 11 end
		validatedSet.links = {}
		for i = 0, #data.links do
			if type(data.links[i].title) ~= "string" or data.links[i].title == "" then return 12 end
			if type(data.links[i].url) ~= "string" or data.links[i].url == "" then return 12 end
			validatedSet.links[i] = {}
			validatedSet.links[i].title = data.links[i].title
			validatedSet.links[i].url = data.links[i].url
		end
	end

	--Check textures
	if type(data.textures) ~= "table" then return 13 elseif next(data.textures) == nil then return 13 end
	validatedSet.textures = {}
	for key, value in pairs(data.textures) do
		if type(key) ~= "string" then return 14 elseif #key ~= 1 then return 14 end
		if type(value) ~= "table" then return 15 elseif next(value) == nil then return 15 end
		validatedSet.textures[key] = {}

		--Check path
		local path = value.path:match("Interface/AddOns/[^%c.<>:\"\\|%?*][^%c.<>:\"\\|%?*]-/[^%c.<>:\"\\|%?*][^%c.<>:\"\\|%?*]-%.")
		if path == nil then return 16 end
		local format = value.path:sub(#path + 1)
		if format ~= "jpg" and format ~= "JPG" and format ~= "jpeg" and format ~= "JPEG" and format ~= "tga" and format ~= "TGA" and format ~= "blp" and format ~= "BLP" then
			return 16
		end
		validatedSet.textures[key].path = value.path

		--Check size
		if value.size ~= nil then
			if type(value.size) ~= "number" then return 17 elseif math.floor(value.size) ~= value.size or math.frexp(value.size) ~= 0.5 then return 17 end
			validatedSet.textures[key].size = value.size
		else validatedSet.textures[key].size = 32 end

		--Check cut
		if value.cut ~= nil then
			if type(value.cut) ~= "table" then return 18 elseif next(value) == nil then return 18 end
			validatedSet.textures[key].cut = {}

			--Check left
			if value.cut.left ~= nil then
				if type(value.cut.left) ~= "number" then return 19 elseif math.floor(value.cut.left) ~= value.cut.left then return 19 end
				if value.cut.left < 0 or value.cut.left > validatedSet.textures[key].size then return 19 end
				validatedSet.textures[key].cut.left = value.cut.left
			else validatedSet.textures[key].cut.left = 0 end

			--Check right
			if value.cut.right ~= nil then
				if type(value.cut.right) ~= "number" then return 19 elseif math.floor(value.cut.right) ~= value.cut.right then return 19 end
				if value.cut.right < 0 or value.cut.right > validatedSet.textures[key].size then return 19 end
				validatedSet.textures[key].cut.right = value.cut.right
			else validatedSet.textures[key].cut.left = 0 end

			--Check top
			if value.cut.top ~= nil then
				if type(value.cut.top) ~= "number" then return 19 elseif math.floor(value.cut.top) ~= value.cut.top then return 19 end
				if value.cut.top < 0 or value.cut.top > validatedSet.textures[key].size then return 19 end
				validatedSet.textures[key].cut.top = value.cut.top
			else validatedSet.textures[key].cut.top = 0 end

			--Check bottom
			if value.cut.bottom ~= nil then
				if type(value.cut.bottom) ~= "number" then return 19 elseif math.floor(value.cut.bottom) ~= value.cut.bottom then return 19 end
				if value.cut.bottom < 0 or value.cut.bottom > validatedSet.textures[key].size then return 19 end
				validatedSet.textures[key].cut.bottom = value.cut.bottom
			else validatedSet.textures[key].cut.bottom = 0 end
		else validatedSet.textures[key].cut = { left = 0, right = 0, top = 0, bottom = 0 } end
	end

	--[ Commit ]

	--Add the set
	symbols[symbolSetKey] = validatedSet

	--Set current symbol set
	currentSymbolSet = currentSymbolSet or symbolSetKey
	frames.rpkb.selectedLanguage:SetText(symbols[currentSymbolSet].name)

	return symbolSetKey
end

---Return a copy of symbol set subtable from the RP Keyboard table if it exists
---@param symbolSetKey string The key referring to the symbol set subtable within the RP Keyboard table
---@param print? boolean Whether or not to dump the entire symbol set table to chat [Default: false]
---@return table|nil symbolSet A copy of the symbol set subtable (or nil if it doesn't exist)
RPKBTools.GetSet = function(symbolSetKey, print)
	if print == true then wt.Dump(symbols[symbolSetKey]) end
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
	if character == " " then return "|T" .. textures.blank .. ":0:0.8|t" end
	if symbols[symbolSetKey] == nil then return character end
	if symbols[symbolSetKey].textures[character] == nil and symbols[symbolSetKey].textures[character:lower()] == nil then return character end
	character = character:lower()
	return "|T" .. symbols[symbolSetKey].textures[character].path .. ":" .. (size or 0) .. ":" .. (size or 0) .. ":" .. "0:0:" .. symbols[symbolSetKey].textures[character].size .. ":" .. symbols[symbolSetKey].textures[character].size .. ":" .. symbols[symbolSetKey].textures[character].cut.left .. ":" .. symbols[symbolSetKey].textures[character].size - symbols[symbolSetKey].textures[character].cut.right .. ":" .. symbols[symbolSetKey].textures[character].cut.top .. ":" .. symbols[symbolSetKey].textures[character].size - symbols[symbolSetKey].textures[character].cut.right .. ":" .. (r or 255) .. ":" .. (g or 255) .. ":" .. (b or 255) .. "|t"
end

---Toggle the RP Keyboard chat window
---@param visible? boolean Whether to hide or show the RP Keyboard chat window [Default: flip the current frame visibility]
---@param openChat? boolean Automatically activate the chat input after the window is made visible [Default: true]
RPKBTools.Toggle = function(visible, openChat)
	if visible == nil then visible = not csc.visible end
	--Set visibility
	wt.SetVisibility(frames.rpkb.main, visible)
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

--Check the the snapping of the RP Keyboard chat window to the default chat window and refresh its position & movability
RPKBTools.UpdateSnap = function()
	--Check snap
	db.position.snapToChat = db.position.snapToChat and ChatFrame1EditBox:IsVisible()
	--Update chat frame movability
	frames.rpkb.main:SetMovable(not db.position.snapToChat)
	--Update position
	frames.rpkb.main:ClearAllPoints()
	if db.position.snapToChat then frames.rpkb.main:SetPoint("TOPLEFT", ChatFrame1EditBox, "BOTTOMLEFT")
	else frames.rpkb.main:SetPoint(db.position.point, db.position.offset.x, db.position.offset.y) end
end

--Refresh the dimensions of the RP Keyboard chat window elements
RPKBTools.UpdateDimensions = function()
	frames.rpkb.main:SetWidth(db.position.snapToChat and ChatFrame1EditBox:GetWidth() or 462)
	frames.rpkb.options:SetWidth(frames.rpkb.main:GetWidth() - 10)
	frames.rpkb.previewPanel:SetWidth(frames.rpkb.main:GetWidth() - 10)
	frames.rpkb.previewFrame:SetWidth(frames.rpkb.previewPanel:GetWidth() - 8)
	frames.rpkb.previewContent:SetWidth(frames.rpkb.previewFrame:GetWidth() - 20)
	frames.rpkb.previewText:SetWidth(frames.rpkb.previewContent:GetWidth())
	frames.rpkb.artCenter:SetWidth(frames.rpkb.main:GetWidth() - 64)
	frames.rpkb.editBox:SetWidth(frames.rpkb.main:GetWidth() - 57)
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

---Assemble and format printable chat message appearing a real chat message
---@param text string Text **your character** should communicate
--- - ***Note:*** When **displayChannel** is set to "EMOTE", **text** will be used as the custom emote text.
---@param displayChannel ChatType Format the message so it appears as if being sent through this chat channel
---@param sender? string The name (optionally followed by the name of the realm linked with a dash "-") of the player who the message originates from [Default: *self*]
---@param realm? string Realm of the sender player [Default: *the current realm*]
---@param target? string The name of the player who are to receive the message (if **displayChannel** is set to "WHISPER")
--- - ***Note:*** When **displayChannel** is set to "WHISPER" and **target** is set to nil, the message will be displayed as received from **sender** as opposed to being sent to **target** from **sender**.
---@return string? message [Default: nil (*on error*)]
RPKBTools.FormatMessage = function(text, displayChannel, sender, realm, target)
	if not text or text == "" or not displayChannel or displayChannel == "" or (sender and sender == "") or (target and target == "") then return nil end
	sender = sender or UnitName("player")
	if displayChannel == "WHISPER" and target and UnitExists(target) then
		local targetName = target:match("[^-]+")
		targetName = wt.Color(targetName, C_ClassColor.GetClassColor(select(2, UnitClass(targetName))))
		return wt.Color(CHAT_WHISPER_INFORM_GET:gsub(
			"%%s", "|Hplayer:" .. target .. ":WHISPER:" .. (realm or GetRealmName()):upper() .. "|h[" .. targetName .. "]|h"
		) .. text, ChatTypeInfo[displayChannel])
	elseif UnitExists(sender) then
		local senderName = sender:match("[^-]+")
		senderName = wt.Color(senderName, C_ClassColor.GetClassColor(select(2, UnitClass(senderName))))
		return wt.Color(GetChatReceiveSnippet(displayChannel):gsub(
			"#PLAYER", "|Hplayer:" .. sender .. ":WHISPER:" .. (realm or GetRealmName()):upper() .. "|h" .. senderName .. "|h"
		) .. text, ChatTypeInfo[displayChannel])
	end
end

---Display a message in chat that will appear in the specified way
---@param text string Contents of the message to display
---@param displayChannel ChatType Chat channel to display the the message being sent through
---@param symbolSetKey? string Apply the specified symbol set as font for the text before displaying the message if set [Default: *(no font applied)*]
--- - ***Note:*** All escape sequences included within **text** (like text color formatting) will be removed in the process.
---@param sender? string The name (optionally followed by the name of the realm linked with a dash "-") of the player who the message originates from [Default: *self*]
---@param realm? string Realm of the sender player [Default: *the current realm*]
---@param target? string The name of the player who are to receive the message (if **displayChannel** is set to "WHISPER")
--- - ***Note:*** When **displayChannel** is set to "WHISPER" and **target** is set to nil, the message will be displayed as received from **sender** as opposed to being sent to **target** from **sender**.
---@param translator? boolean Whether to append a translate button at the end of the message [Default: **symbolSet** ~= nil]
RPKBTools.PrintMessage = function(text, displayChannel, symbolSetKey, sender, realm, target, translator)
	if wt.Clear(text):trim() == "" then return end
	--Assemble the message
	local r, g, b  = wt.UnpackColor(ChatTypeInfo[displayChannel])
	local message = RPKBTools.ApplyFont(text, symbolSetKey, 14, r * 255, g * 255, b * 255)
	message = (translator ~= false and wt.Hyperlink(
		"item", addonNameSpace .. ":translate:" .. symbolSetKey .. ":" .. text, "|T" .. textures.logo .. ":0|t"
	) .. " " or "") .. RPKBTools.FormatMessage(message, displayChannel, sender, realm, target)
	--Display the message
	print(message)
	if not symbols[symbolSetKey] then print(wt.Color(addonTitle .. ": ", colors.red[0]) .. wt.Color(strings.chat.noFont:gsub("#FONT", symbolSetKey), colors.red[1])) end
end

---Transmit a message to other RP Keyboard users in the specified chat channel
---@param text string Contents of the message to send
---@param sendChannel ChatType Chat channel to transmit the massage through
---@param displayChannel? any [Default: **sendChannel**]
---@param symbolSetKey? string The specified symbol set will be applied when the targets receive the message (if they have a symbol set installed with a matching key) [Default: *(no font applied)*]
--- - ***Note:*** All escape sequences included within **text** (like text color formatting) will be removed in the process.
---@param target? string The name of the player who is to receive the message when sending a whisper.
--- - ***Note:*** When **displayChannel** is set to "WHISPER" and **target** is nil or "", the message will be sent to self.
---@return boolean success Return false on error
RPKBTools.SendMessage = function(text, sendChannel, displayChannel, symbolSetKey, target)
	if not text or text == "" or (symbolSetKey and symbolSetKey == "")  or not sendChannel or sendChannel == "" then return false end
	displayChannel = (not displayChannel or displayChannel == "") and sendChannel or displayChannel
	if not target or target == "" then target = GetUnitName("player", true) end
	--Send the message to the specified chat channel
	C_ChatInfo.SendAddonMessage(prefix, displayChannel .. "|" .. symbolSetKey .. "|" .. text, sendChannel, sendChannel == "CHANNEL" and customChannelID or target)
	--Display for self as well
	if sendChannel == "WHISPER" and UnitExists(target) then RPKBTools.PrintMessage(text, displayChannel, symbolSetKey, nil, nil, target) end
	--Add to the logs
	AddSentLog(text, symbolSetKey, displayChannel, sendChannel, target)
	return true
end


--[[ INTERFACE OPTIONS ]]

--Options frame references
frames.options = {
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
	--Button: Symbol sets page
	local symbolSetsPage = wt.CreateButton({
		parent = parentFrame,
		name = "SymbolSetsPage",
		title = strings.options.symbolSets.title,
		tooltip = { [0] = { text = strings.options.symbolSets.description:gsub("#ADDON", addonTitle), }, },
		position = { offset = { x = 10, y = -30 } },
		width = 120,
		onClick = function() InterfaceOptionsFrame_OpenToCategory(frames.options.symbolSetsPage) end,
	})
	--Button: Chat window page
	local chatWindowPage = wt.CreateButton({
		parent = parentFrame,
		name = "ChatWindowPage",
		title = strings.options.chatWindow.title,
		tooltip = { [0] = { text = strings.options.chatWindow.description:gsub("#ADDON", addonTitle), }, },
		position = {
			relativeTo = symbolSetsPage,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, }
		},
		width = 120,
		onClick = function() InterfaceOptionsFrame_OpenToCategory(frames.options.chatWindowPage) end,
	})
	--Button: Chat logs page
	wt.CreateButton({
		parent = parentFrame,
		name = "ChatLogsPage",
		title = strings.options.chatLogs.title,
		tooltip = { [0] = { text = strings.options.chatLogs.description:gsub("#ADDON", addonTitle), }, },
		position = {
			relativeTo = chatWindowPage,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, }
		},
		width = 120,
		onClick = function() InterfaceOptionsFrame_OpenToCategory(frames.options.chatLogsPage) end,
	})
	--Button: Advanced page
	wt.CreateButton({
		parent = parentFrame,
		name = "AdvancedPage",
		title = strings.options.advanced.title,
		tooltip = { [0] = { text = strings.options.advanced.description:gsub("#ADDON", addonTitle), }, },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -10, y = -30 }
		},
		width = 120,
		onClick = function() InterfaceOptionsFrame_OpenToCategory(frames.options.advancedOptionsPage) end,
	})
end
local function CreateAboutInfo(parentFrame)
	--Text: Version
	local version = wt.CreateText({
		parent = parentFrame,
		name = "Version",
		text = strings.options.main.about.version:gsub(
			"#VERSION", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "Version"), "FFFFFFFF")
		),
		position = { offset = { x = 16, y = -33 } },
		width = 84,
		template = "GameFontNormalSmall",
		justify = "LEFT",
	})
	--Text: Date
	local date = wt.CreateText({
		parent = parentFrame,
		name = "Date",
		text = strings.options.main.about.date:gsub(
			"#DATE", WrapTextInColorCode(strings.misc.date:gsub(
				"#DAY", GetAddOnMetadata(addonNameSpace, "X-Day")
			):gsub(
				"#MONTH", GetAddOnMetadata(addonNameSpace, "X-Month")
			):gsub(
				"#YEAR", GetAddOnMetadata(addonNameSpace, "X-Year")
			), "FFFFFFFF")
		),
		position = {
			relativeTo = version,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, }
		},
		width = 102,
		template = "GameFontNormalSmall",
		justify = "LEFT",
	})
	--Text: Author
	local author = wt.CreateText({
		parent = parentFrame,
		name = "Author",
		text = strings.options.main.about.author:gsub(
			"#AUTHOR", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "Author"), "FFFFFFFF")
		),
		position = {
			relativeTo = date,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, }
		},
		width = 186,
		template = "GameFontNormalSmall",
		justify = "LEFT",
	})
	--Text: License
	wt.CreateText({
		parent = parentFrame,
		name = "License",
		text = strings.options.main.about.license:gsub(
			"#LICENSE", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "X-License"), "FFFFFFFF")
		),
		position = {
			relativeTo = author,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, }
		},
		width = 156,
		template = "GameFontNormalSmall",
		justify = "LEFT",
	})
	--EditScrollBox: Changelog
	frames.options.about.changelog = wt.CreateEditScrollBox({
		parent = parentFrame,
		name = "Changelog",
		title = strings.options.main.about.changelog.title,
		tooltip = { [0] = { text = strings.options.main.about.changelog.tooltip, }, },
		position = {
			relativeTo = version,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -12 }
		},
		size = { width = parentFrame:GetWidth() - 32, height = 139 },
		text = ns.GetChangelog(),
		fontObject = "GameFontDisableSmall",
		readOnly = true,
		scrollSpeed = 45,
	})
end
local function CreateSupportInfo(parentFrame)
	--Copybox: CurseForge
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "CurseForge",
		title = strings.options.main.support.curseForge .. ":",
		position = { offset = { x = 16, y = -33 } },
		width = parentFrame:GetWidth() / 2 - 22,
		text = "curseforge.com/wow/addons/rp-keyboard",
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: Wago
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "Wago",
		title = strings.options.main.support.wago .. ":",
		position = {
			anchor = "TOP",
			offset = { x = (parentFrame:GetWidth() / 2 - 22) / 2 + 8, y = -33 }
		},
		width = parentFrame:GetWidth() / 2 - 22,
		text = "addons.wago.io/addons/rp-keyboard",
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: BitBucket
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "BitBucket",
		title = strings.options.main.support.bitBucket .. ":",
		position = { offset = { x = 16, y = -70 } },
		width = parentFrame:GetWidth() / 2 - 22,
		text = "bitbucket.org/Arxareon/rp-keyboard",
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: Issues
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "Issues",
		title = strings.options.main.support.issues .. ":",
		position = {
			anchor = "TOP",
			offset = { x = (parentFrame:GetWidth() / 2 - 22) / 2 + 8, y = -70 }
		},
		width = parentFrame:GetWidth() / 2 - 22,
		text = "bitbucket.org/Arxareon/rp-keyboard/issues",
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
end
local function CreateMainCategoryPanels(parentFrame) --Add the main page widgets to the category panel frame
	--Shortcuts
	local shortcutsPanel = wt.CreatePanel({
		parent = parentFrame,
		name = "Shortcuts",
		title = strings.options.main.shortcuts.title,
		description = strings.options.main.shortcuts.description:gsub("#ADDON", addonTitle),
		position = { offset = { x = 16, y = -82 } },
		size = { height = 64 },
	})
	CreateOptionsShortcuts(shortcutsPanel)
	--About
	local aboutPanel = wt.CreatePanel({
		parent = parentFrame,
		name = "About",
		title = strings.options.main.about.title,
		description = strings.options.main.about.description:gsub("#ADDON", addonTitle),
		position = {
			relativeTo = shortcutsPanel,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		},
		size = { height = 231 },
	})
	CreateAboutInfo(aboutPanel)
	--Support
	local supportPanel = wt.CreatePanel({
		parent = parentFrame,
		name = "Support",
		title = strings.options.main.support.title,
		description = strings.options.main.support.description:gsub("#ADDON", addonTitle),
		position = {
			relativeTo = aboutPanel,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		},
		size = { height = 111 },
	})
	CreateSupportInfo(supportPanel)
end

--Chat window page
local function CreatePositionOptions(parentFrame)
	--Checkbox: Snap to chat
	frames.options.position.snap = wt.CreateCheckbox({
		parent = parentFrame,
		name = "SnapToChat",
		title = strings.options.chatWindow.position.snap.title,
		tooltip = {
			[0] = { text = strings.options.chatWindow.position.snap.tooltip[0]:gsub("#ADDON", addonTitle), },
			[1] = {
				text = strings.options.chatWindow.position.snap.tooltip[1]:gsub("#ISSUES", strings.options.main.support.issues):gsub("#ADDON", addonTitle),
				color = { r = 0.89, g = 0.65, b = 0.40 }
			},
			[2] = { text = strings.options.chatWindow.position.snap.tooltip[2], color = { r = 0.92, g = 0.34, b = 0.23 }, },
		},
		position = { offset = { x = 8, y = -30 } },
		onClick = function(self)
			if self:GetChecked() and not ChatFrame1EditBox:IsVisible() then
				self:SetChecked(false)
				print(wt.Color(addonTitle .. ": ", colors.red[0]) .. wt.Color(strings.chat.snap.error, colors.red[1]))
			end
		end,
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.position,
			storageKey = "snapToChat",
			onSave = function()
				RPKBTools.UpdateSnap()
				RPKBTools.UpdateDimensions()
			end,
		},
	})
	--Selector: Anchor point
	local anchorItems = {}
	for i = 0, #anchors do
		anchorItems[i] = {}
		anchorItems[i].title = anchors[i].name
		anchorItems[i].onSelect = function()
			wt.PositionFrame(frames.rpkb.main, anchors[i].point, nil, nil, frames.options.position.xOffset:GetValue(), frames.options.position.yOffset:GetValue())
		end
	end
	frames.options.position.anchor = wt.CreateSelector({
		parent = parentFrame,
		name = "AnchorPoint",
		title = strings.options.chatWindow.position.anchor.title,
		tooltip = { [0] = { text = strings.options.chatWindow.position.anchor.tooltip, }, },
		position = { offset = { x = 8, y = -60 } },
		items = anchorItems,
		labels = false,
		columns = 3,
		dependencies = { [0] = { frame = frames.options.position.snap, evaluate = function(state) return not state end, }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.position,
			storageKey = "point",
			convertSave = function(value) return anchors[value].point end,
			convertLoad = function(point) return GetAnchorID(point) end,
		},
	})
	--Slider: X offset
	frames.options.position.xOffset = wt.CreateSlider({
		parent = parentFrame,
		name = "OffsetX",
		title = strings.options.chatWindow.position.xOffset.title,
		tooltip = { [0] = { text = strings.options.chatWindow.position.xOffset.tooltip, }, },
		position = {
			anchor = "TOP",
			offset = { y = -60 }
		},
		value = { min = -500, max = 500, fractional = 2 },
		onValueChanged = function(_, value)
			wt.PositionFrame(frames.rpkb.main, anchors[frames.options.position.anchor.getSelected()].point, nil, nil, value, frames.options.position.yOffset:GetValue())
		end,
		dependencies = { [0] = { frame = frames.options.position.snap, evaluate = function(state) return not state end, }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.position.offset,
			storageKey = "x",
		},
	})
	--Slider: Y offset
	frames.options.position.yOffset = wt.CreateSlider({
		parent = parentFrame,
		name = "OffsetY",
		title = strings.options.chatWindow.position.yOffset.title,
		tooltip = { [0] = { text = strings.options.chatWindow.position.yOffset.tooltip, }, },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -14, y = -60 }
		},
		value = { min = -500, max = 500, fractional = 2 },
		onValueChanged = function(_, value)
			wt.PositionFrame(frames.rpkb.main, anchors[frames.options.position.anchor.getSelected()].point, nil, nil, frames.options.position.xOffset:GetValue(), value)
		end,
		dependencies = { [0] = { frame = frames.options.position.snap, evaluate = function(state) return not state end, }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.position.offset,
			storageKey = "y",
		},
	})
end
local function CreateChatWindowCategoryPanels(parentFrame) --Add the chat window page widgets to the category panel frame
	--Position
	local positionPanel = wt.CreatePanel({
		parent = parentFrame,
		name = "Position",
		title = strings.options.chatWindow.position.title,
		description = strings.options.chatWindow.position.description:gsub("#SHIFT", strings.keys.shift),
		position = { offset = { x = 16, y = -82 } },
		size = { height = 133 },
	})
	CreatePositionOptions(positionPanel)
end

--Symbol sets page
local function CreateSymbolSetAboutInfoPanels(parentFrame)
	local bottomOffset = 12.5
	local fullHeight = max(parentFrame:GetHeight() - bottomOffset, 46)
	local panelPosition = { offset = { x = 16, y = -(fullHeight + 32) } }

	--Create Widgets
	for key, value in wt.SortedPairs(symbols) do if not _G[parentFrame:GetName() .. key] then
		local contentHeight

		--[ Container ]

		--Panel: Symbol Set
		local panel = wt.CreatePanel({
			parent = parentFrame,
			name = key,
			title = value.name,
			description = value.description,
			position = panelPosition,
			size = { height = 0 }, --The height is set after all widgets are loaded
		})

		--[ Release Info ]

		--Text: Version
		local version = wt.CreateText({
			parent = panel,
			name = "Version",
			text = strings.options.main.about.version:gsub(
				"#VERSION", WrapTextInColorCode(value.version, "FFFFFFFF")
			),
			position = { offset = { x = 16, y = -33 } },
			width = 84,
			template = "GameFontNormalSmall",
			justify = "LEFT",
		})

		--Text: Date
		wt.CreateText({
			parent = panel,
			name = "Date",
			text = strings.options.main.about.date:gsub(
				"#DATE", WrapTextInColorCode(strings.misc.date:gsub(
					"#DAY", value.date.day
				):gsub(
					"#MONTH", value.date.month
				):gsub(
					"#YEAR", value.date.year
				), "FFFFFFFF")
			),
			position = {
				relativeTo = version,
				relativePoint = "TOPRIGHT",
				offset = { x = 20, }
			},
			width = 102,
			template = "GameFontNormalSmall",
			justify = "LEFT",
		})

		--Update the content height
		contentHeight = 33 + ceil(version:GetHeight())

		--[ License ]

		--Text: License
		local license = wt.CreateText({
			parent = panel,
			name = "License",
			text = strings.options.main.about.license:gsub(
				"#LICENSE", WrapTextInColorCode(value.license, "FFFFFFFF")
			),
			position = {
				relativeTo = version,
				relativePoint = "BOTTOMLEFT",
				offset = { y = -7 }
			},
			width = parentFrame:GetWidth() / 2 - 36,
			template = "GameFontNormalSmall",
			justify = "LEFT",
		})

		--Update the content height
		contentHeight = contentHeight + 7 + ceil(license:GetHeight())

		--[ Credits ]

		local creditsText = "Credits:"
		for i = 0, #value.credits do
			if value.credits[i].role then creditsText = creditsText .. "\n    • " .. value.credits[i].role .. ": " .. WrapTextInColorCode(value.credits[i].name, "FFFFFFFF")
			else creditsText = strings.options.main.about.author:gsub(
				"#AUTHOR", WrapTextInColorCode(value.credits[i].name, "FFFFFFFF")
			) end
		end

		--Text: Credits
		local credits = wt.CreateText({
			parent = panel,
			name = "Credits",
			text = creditsText,
			position = {
				anchor = "TOP",
				offset = { x = (panel:GetWidth() / 2 - 22) / 2 + 8, y = -33 },
			},
			width = parentFrame:GetWidth() / 2 - 36,
			template = "GameFontNormalSmall",
			justify = "LEFT",
		})

		--Update the content height
		local creditsHeight = 33 + ceil(credits:GetHeight())
		if contentHeight < creditsHeight then contentHeight = creditsHeight end
		contentHeight = contentHeight + 8

		--[ Links ]

		if value.links then
			for i = 0, #value.links do
				local even = i % 2 == 0

				--Copybox
				wt.CreateCopyBox({
					parent = panel,
					name = value.links[i].title:gsub("%s+", ""),
					title = value.links[i].title .. ":",
					position = even and { offset = { x = 16, y = -contentHeight } } or {
						anchor = "TOP",
						offset = { x = (panel:GetWidth() / 2 - 22) / 2 + 8, y = -contentHeight }
					},
					width = panel:GetWidth() / 2 - 22,
					text = value.links[i].url,
					template = "GameFontNormalSmall",
					color = { r = 0.6, g = 0.8, b = 1, a = 1 },
					colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
				})

				--Update the content height
				if not even or i == #value.links then contentHeight = contentHeight + 37 end
			end
		else
			--Update the content height
			contentHeight = contentHeight + 3
		end

		--[ Symbols ]

		local symbolsText = ""
		local i = 0
		for k, _ in wt.SortedPairs(value.textures) do
			i = i + 1
			symbolsText = symbolsText .. wt.Color(k, colors.blue[1]) .. " " .. RPKBTools.GetSymbolTexture(k, key) .. "    " .. (i % 8 == 0 and "\n" or "")
		end
		symbolsText:sub(1, -3)

		--EditScrollBox: Symbols
		wt.CreateEditScrollBox({
			parent = panel,
			name = "Symbols",
			title = strings.options.symbolSets.symbols.title,
			tooltip = { [0] = { text = strings.options.symbolSets.symbols.tooltip, }, },
			position = { offset = { x = 16, y = -contentHeight } },
			size = { width = panel:GetWidth() - 32, height = 63 },
			text = symbolsText,
			fontObject = "GameFontDisableHuge",
			readOnly = true,
			scrollSpeed = 45,
		})

		--Update the content height
		contentHeight = contentHeight + 101

		--[ Update Position & Height Values ]

		panelPosition = {
			relativeTo = panel,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		}

		panel:SetHeight(contentHeight)
		fullHeight = fullHeight + 32 + contentHeight
	end end

	return fullHeight + bottomOffset
end

--Advanced page
local function CreateOptionsProfiles(parentFrame)
	--TODO: Add profiles handler widgets
end
local function CreateBackupOptions(parentFrame)
	--EditScrollBox & Popup: Import & Export
	local importPopup = wt.CreatePopup({
		addon = addonNameSpace,
		name = "IMPORT",
		text = strings.options.advanced.backup.warning,
		accept = strings.options.advanced.backup.import,
		onAccept = function()
			--Load from string to a temporary table
			local success, t = pcall(loadstring("return " .. wt.Clear(frames.options.backup.string:GetText())))
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
				--Update chat position & dimensions
				RPKBTools.UpdateSnap()
				RPKBTools.UpdateDimensions()
				--Update the interface options
				wt.LoadOptionsData(addonNameSpace)
			else print(wt.Color(addonTitle .. ":", colors.red[0]) .. " " .. wt.Color(strings.options.advanced.backup.error, colors.blue[0])) end
		end
	})
	local backupBox
	frames.options.backup.string, backupBox = wt.CreateEditScrollBox({
		parent = parentFrame,
		name = "ImportExport",
		title = strings.options.advanced.backup.backupBox.title,
		tooltip = {
			[0] = { text = strings.options.advanced.backup.backupBox.tooltip[0], },
			[1] = { text = strings.options.advanced.backup.backupBox.tooltip[1], },
			[2] = { text = "\n" .. strings.options.advanced.backup.backupBox.tooltip[2]:gsub("#ENTER", strings.keys.enter), },
			[3] = { text = strings.options.advanced.backup.backupBox.tooltip[3], color = { r = 0.89, g = 0.65, b = 0.40 }, },
			[4] = { text = "\n" .. strings.options.advanced.backup.backupBox.tooltip[4], color = { r = 0.92, g = 0.34, b = 0.23 }, },
		},
		position = { offset = { x = 16, y = -30 } },
		size = { width = parentFrame:GetWidth() - 32, height = 276 },
		maxLetters = 5400,
		fontObject = "GameFontWhiteSmall",
		scrollSpeed = 60,
		onEnterPressed = function() StaticPopup_Show(importPopup) end,
		onEscapePressed = function(self) self:SetText(wt.TableToString({ account = db, character = dbc }, frames.options.backup.compact:GetChecked(), true)) end,
		optionsData = {
			optionsKey = addonNameSpace,
			onLoad = function(self) self:SetText(wt.TableToString({ account = db, character = dbc }, frames.options.backup.compact:GetChecked(), true)) end,
		},
	})
	--Checkbox: Compact
	frames.options.backup.compact = wt.CreateCheckbox({
		parent = parentFrame,
		name = "Compact",
		title = strings.options.advanced.backup.compact.title,
		tooltip = { [0] = { text = strings.options.advanced.backup.compact.tooltip, }, },
		position = {
			relativeTo = backupBox,
			relativePoint = "BOTTOMLEFT",
			offset = { x = -8, y = -13 }
		},
		onClick = function(self)
			frames.options.backup.string:SetText(wt.TableToString({ account = db, character = dbc }, self:GetChecked(), true))
			--Set focus after text change to set the scroll to the top and refresh the position character counter
			frames.options.backup.string:SetFocus()
			frames.options.backup.string:ClearFocus()
		end,
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = cs,
			storageKey = "compactBackup",
		},
	})
	--Button: Load
	local load = wt.CreateButton({
		parent = parentFrame,
		name = "Load",
		title = strings.options.advanced.backup.load.title,
		tooltip = { [0] = { text = strings.options.advanced.backup.load.tooltip, }, },
		position = {
			anchor = "TOPRIGHT",
			relativeTo = backupBox,
			relativePoint = "BOTTOMRIGHT",
			offset = { x = 6, y = -13 }
		},
		width = 80,
		onClick = function() StaticPopup_Show(importPopup) end,
	})
	--Button: Reset
	wt.CreateButton({
		parent = parentFrame,
		name = "Reset",
		title = strings.options.advanced.backup.reset.title,
		tooltip = { [0] = { text = strings.options.advanced.backup.reset.tooltip, }, },
		position = {
			anchor = "TOPRIGHT",
			relativeTo = load,
			relativePoint = "TOPLEFT",
			offset = { x = -10 }
		},
		width = 80,
		onClick = function()
			frames.options.backup.string:SetText("") --Remove text to make sure OnTextChanged will get called
			frames.options.backup.string:SetText(wt.TableToString({ account = db, character = dbc }, frames.options.backup.compact:GetChecked(), true))
			--Set focus after text change to set the scroll to the top and refresh the position character counter
			frames.options.backup.string:SetFocus()
			frames.options.backup.string:ClearFocus()
		end,
	})
end
local function CreateAdvancedCategoryPanels(parentFrame) --Add the advanced page widgets to the category panel frame
	--Profiles
	local profilesPanel = wt.CreatePanel({
		parent = parentFrame,
		name = "Profiles",
		title = strings.options.advanced.profiles.title,
		description = strings.options.advanced.profiles.description:gsub("#ADDON", addonTitle),
		position = { offset = { x = 16, y = -82 } },
		size = { height = 64 },
	})
	CreateOptionsProfiles(profilesPanel)
	---Backup
	local backupOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Backup",
		title = strings.options.advanced.backup.title,
		description = strings.options.advanced.backup.description:gsub("#ADDON", addonTitle),
		position = {
			relativeTo = profilesPanel,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		},
		size = { height = 374 },
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
	--Update chat position & dimensions
	RPKBTools.UpdateSnap()
	RPKBTools.UpdateDimensions()
end
--Restore all the settings under the main option category to their default values
local function DefaultOptions()
	--Reset the DBs
	RPKeyboardDB = wt.Clone(dbDefault)
	RPKeyboardDBC = wt.Clone(dbcDefault)
	wt.CopyValues(dbDefault, db)
	wt.CopyValues(dbcDefault, dbc)
	--Update the interface options
	wt.LoadOptionsData(addonNameSpace)
	--Update chat position & dimensions
	RPKBTools.UpdateSnap()
	RPKBTools.UpdateDimensions()
	--Notification
	print(wt.Color(addonTitle .. ":", colors.red[0]) .. " " .. wt.Color(strings.options.defaults, colors.blue[0]))
end

--Create and add the options category panel frames to the WoW Interface Options
local function LoadInterfaceOptions()
	--Main options panel
	frames.options.mainOptionsPage = wt.CreateOptionsPanel({
		addon = addonNameSpace,
		name = "Main",
		description = strings.options.main.description:gsub("#ADDON", addonTitle):gsub("#KEYWORD", strings.chat.keyword),
		logo = textures.logo,
		titleLogo = true,
		okay = SaveOptions,
		cancel = CancelChanges,
		default = DefaultOptions,
		optionsKey = addonNameSpace,
	})
	CreateMainCategoryPanels(frames.options.mainOptionsPage) --Add categories & GUI elements to the panel
	--Symbol sets panel
	local symbolSetsPageScrollFrame
	frames.options.symbolSetsPage, symbolSetsPageScrollFrame = wt.CreateOptionsPanel({
		parent = frames.options.mainOptionsPage.name,
		addon = addonNameSpace,
		name = "SymbolSets",
		title = strings.options.symbolSets.title,
		description = strings.options.symbolSets.description:gsub("#ADDON", addonTitle):gsub("#KEYWORD", strings.chat.keyword),
		logo = textures.logo,
		scroll = {
			height = 0, --The scroll height will be adjusted on refresh
			speed = 102,
		},
		default = DefaultOptions,
		refresh = function()
			--Add GUI elements to the panel
			local height = CreateSymbolSetAboutInfoPanels(symbolSetsPageScrollFrame)
			--Set the scroll height
			symbolSetsPageScrollFrame:SetHeight(height)
		end,
	})
	--Chat window options panel
	frames.options.chatWindowPage = wt.CreateOptionsPanel({
		parent = frames.options.mainOptionsPage.name,
		addon = addonNameSpace,
		name = "ChatWindow",
		title = strings.options.chatWindow.title,
		description = strings.options.chatWindow.description:gsub("#ADDON", addonTitle),
		logo = textures.logo,
		default = DefaultOptions,
	})
	CreateChatWindowCategoryPanels(frames.options.chatWindowPage) --Add categories & GUI elements to the panel
	--Chat logs options panel
	frames.options.chatLogsPage = wt.CreateOptionsPanel({
		parent = frames.options.mainOptionsPage.name,
		addon = addonNameSpace,
		name = "ChatLogs",
		title = strings.options.chatLogs.title,
		description = strings.options.chatLogs.description:gsub("#ADDON", addonTitle),
		logo = textures.logo,
		default = DefaultOptions,
	})
	--Advanced options panel
	frames.options.advancedOptionsPage = wt.CreateOptionsPanel({
		parent = frames.options.mainOptionsPage.name,
		addon = addonNameSpace,
		name = "Advanced",
		title = strings.options.advanced.title,
		description = strings.options.advanced.description:gsub("#ADDON", addonTitle),
		logo = textures.logo,
		default = DefaultOptions,
	})
	CreateAdvancedCategoryPanels(frames.options.advancedOptionsPage) --Add categories & GUI elements to the panel
end


--[[ CHAT CONTROL ]]

--[ Chat Utilities ]

---Print visibility info
---@param load? boolean [Default: false]
local function PrintStatus(load)
	if load == true and not db.statusNotice then return end
	print(wt.Color(frames.rpkb.main:IsVisible() and strings.chat.status.enabled:gsub(
		"#ADDON", wt.Color(addonTitle, colors.red[0])
	) or strings.chat.status.disabled:gsub(
		"#ADDON", wt.Color(addonTitle, colors.red[0])
	), colors.blue[0]))
end
--Print help info
local function PrintInfo()
	print(wt.Color(strings.chat.help.thanks:gsub("#ADDON", wt.Color(addonTitle, colors.red[0])), colors.blue[0]))
	PrintStatus()
	print(wt.Color(strings.chat.help.hint:gsub( "#HELP_COMMAND", wt.Color(strings.chat.keyword .. " " .. strings.chat.help.command, colors.red[1])), colors.blue[1]))
end
--Print the command list with basic functionality info
local function PrintCommands()
	print(wt.Color(addonTitle, colors.red[0]) .. " ".. wt.Color(strings.chat.help.list .. ":", colors.blue[0]))
	--Index the commands (skipping the help command) and put replacement code segments in place
	local commands = {
		[0] = {
			command = strings.chat.options.command,
			description = strings.chat.options.description:gsub("#ADDON", addonTitle)
		},
		[1] = {
			command = strings.chat.toggle.command,
			description = strings.chat.toggle.description:gsub("#ADDON", addonTitle):gsub(
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
	wt.SetVisibility(frames.rpkb.main, not dbc.disabled)
	--Response
	print(wt.Color(dbc.disabled and strings.chat.toggle.disabled:gsub(
			"#ADDON", wt.Color(addonTitle, colors.red[0])
		) or strings.chat.toggle.enabled:gsub(
			"#ADDON", wt.Color(addonTitle, colors.red[0])
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
		InterfaceOptionsFrame_OpenToCategory(frames.options.mainOptionsPage)
		InterfaceOptionsFrame_OpenToCategory(frames.options.mainOptionsPage) --Load twice to make sure the proper page and category is loaded
	elseif command == strings.chat.toggle.command then
		ToggleCommand()
	else
		PrintInfo()
	end
end


--[[ INITIALIZATION ]]

--[ Frame Setup ]

--Set chat window frame parameters
local function SetUpChatWindowFrames()

	--[ Main Frame ]

	--Check snap
	db.position.snapToChat = db.position.snapToChat and ChatFrame1EditBox:IsVisible()

	--Position & dimensions
	if db.position.snapToChat then
		frames.rpkb.main:SetPoint("TOPLEFT", ChatFrame1EditBox, "BOTTOMLEFT")
		frames.rpkb.main:SetSize(ChatFrame1EditBox:GetWidth(), 32)
	else
		frames.rpkb.main:SetPoint(db.position.point, db.position.offset.x, db.position.offset.y)
		frames.rpkb.main:SetSize(462, 32)
	end

	--Visibility
	frames.rpkb.main:SetFrameStrata("LOW")
	wt.SetVisibility(frames.rpkb.main, csc.visible)

	--Behavior
	frames.rpkb.main:EnableMouse(true)

	--[ Toggle ]

	--Button
	frames.rpkb.toggle = CreateFrame("Button", frames.rpkb.main:GetName() .. "ToggleButton", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	frames.rpkb.toggle:SetPoint("RIGHT", frames.rpkb.main, "LEFT", -3, 2)
	frames.rpkb.toggle:SetSize(22, 22)
	if not frames.rpkb.main:IsVisible() then frames.rpkb.toggle:SetAlpha(0.4) end
	frames.rpkb.toggle:SetScript("OnClick", function()
		if IsShiftKeyDown() then return end
		RPKBTools.Toggle()
	end)

	--Logo
	wt.CreateTexture({
		parent = frames.rpkb.toggle,
		name = "Logo",
		path = textures.logo,
		size = { width = ceil(frames.rpkb.toggle:GetWidth()), height = ceil(frames.rpkb.toggle:GetHeight()) },
	})

	--Linked events
	frames.rpkb.main:SetScript("OnShow", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		frames.rpkb.toggle:SetAlpha(1)
	end)
	frames.rpkb.main:SetScript("OnHide", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		frames.rpkb.toggle:SetAlpha(0.4)
	end)

	--[ Make Movable ]

	frames.rpkb.main:SetMovable(not db.position.snapToChat)
	frames.rpkb.toggle:SetScript("OnMouseDown", function()
		if not db.position.snapToChat and IsShiftKeyDown() and not frames.rpkb.main.isMoving then
			frames.rpkb.main:StartMoving()
			frames.rpkb.main.isMoving = true
			--Stop moving when SHIFT is released
			frames.rpkb.toggle:SetScript("OnUpdate", function ()
				if IsShiftKeyDown() then return end
				frames.rpkb.main:StopMovingOrSizing()
				frames.rpkb.main.isMoving = false
				--Reset the position
				wt.PositionFrame(frames.rpkb.main, db.position.point, nil, nil, db.position.offset.x, db.position.offset.y)
				--Chat response
				-- print(wt.Color(addonTitle .. ":", colors.green[0]) .. " " .. wt.Color(strings.chat.position.cancel, colors.yellow[0]))
				-- print(wt.Color(strings.chat.position.error:gsub("#SHIFT", strings.keys.shift), colors.yellow[1]))
				--Stop checking if SHIFT is pressed
				frames.rpkb.toggle:SetScript("OnUpdate", nil)
			end)
		end
	end)
	frames.rpkb.toggle:SetScript("OnMouseUp", function()
		if not frames.rpkb.main.isMoving then return end
		frames.rpkb.main:StopMovingOrSizing()
		frames.rpkb.main.isMoving = false
		--Save the position (for account-wide use)
		db.position.point, _, _, db.position.offset.x, db.position.offset.y = frames.rpkb.main:GetPoint()
		RPKeyboardDB.position = wt.Clone(db.position) --Update in the SavedVariabes DB
		--Update the GUI options in case the window was open
		frames.options.position.anchor.setSelected(GetAnchorID(db.position.point))
		frames.options.position.xOffset:SetValue(db.position.offset.x)
		frames.options.position.yOffset:SetValue(db.position.offset.y)
		--Chat response
		-- print(wt.Color(addonTitle .. ":", colors.green[0]) .. " " .. wt.Color(strings.chat.position.save, colors.yellow[1]))
		--Stop checking if SHIFT is pressed
		frames.rpkb.toggle:SetScript("OnUpdate", nil)
	end)

	--[ Message Preview ]

	--Background panel
	frames.rpkb.previewPanel = wt.CreatePanel({
		parent = frames.rpkb.main,
		name = "Preview",
		label = false,
		position = {
			anchor = "TOP",
			relativeTo = frames.rpkb.main,
			relativePoint = "BOTTOM",
			offset = { y = 6 }
		},
		size = { width = frames.rpkb.main:GetWidth() - 10, height = 78 },
	})
	frames.rpkb.previewPanel:EnableMouse(true)
	frames.rpkb.previewPanel:Hide()

	--Scroll frame
	frames.rpkb.previewContent, frames.rpkb.previewFrame = wt.CreateScrollFrame({
		parent = frames.rpkb.previewPanel,
		position = {
			anchor = "RIGHT",
			offset = { x = -6, }
		},
		size = { width = frames.rpkb.previewPanel:GetWidth() - 12, height = frames.rpkb.previewPanel:GetHeight() - 12 },
		scrollSize = { height = 65 },
		scrollSpeed = 17,
	})
	_G[frames.rpkb.previewFrame:GetName() .. "ScrollBarScrollUpButton"]:ClearAllPoints()
	_G[frames.rpkb.previewFrame:GetName() .. "ScrollBarScrollUpButton"]:SetPoint("TOPRIGHT", frames.rpkb.previewFrame, "TOPRIGHT", 2, 1)
	_G[frames.rpkb.previewFrame:GetName() .. "ScrollBarScrollDownButton"]:ClearAllPoints()
	_G[frames.rpkb.previewFrame:GetName() .. "ScrollBarScrollDownButton"]:SetPoint("BOTTOMRIGHT", frames.rpkb.previewFrame, "BOTTOMRIGHT", 2, -1)
	_G[frames.rpkb.previewFrame:GetName() .. "ScrollBar"]:ClearAllPoints()
	_G[frames.rpkb.previewFrame:GetName() .. "ScrollBar"]:SetPoint("TOP", _G[frames.rpkb.previewFrame:GetName() .. "ScrollBarScrollUpButton"], "BOTTOM")
	_G[frames.rpkb.previewFrame:GetName() .. "ScrollBar"]:SetPoint("BOTTOM", _G[frames.rpkb.previewFrame:GetName() .. "ScrollBarScrollDownButton"], "TOP")
	_G[frames.rpkb.previewFrame:GetName() .. "ScrollBarBackground"]:SetSize(_G[frames.rpkb.previewFrame:GetName() .. "ScrollBar"]:GetWidth() + 1, _G[frames.rpkb.previewFrame:GetName() .. "ScrollBar"]:GetHeight() - 6)

	--Text
	frames.rpkb.previewText = wt.CreateText({
		parent = frames.rpkb.previewContent,
		position = {
			anchor = "TOP",
			offset = { y = 1 }
		},
		width = frames.rpkb.previewContent:GetWidth(),
		template = "ChatFontNormal",
		justify = "LEFT",
	})

	--[ Chat Options ]

	--Background panel
	frames.rpkb.options = wt.CreatePanel({
		parent = frames.rpkb.main,
		name = "Options",
		label = false,
		position = {
			anchor = "Bottom",
			relativeTo = frames.rpkb.main,
			relativePoint = "TOP",
			offset = { y = -2 }
		},
		size = { width = frames.rpkb.main:GetWidth() - 10, height = frames.rpkb.main:GetHeight() },
	})
	frames.rpkb.options:EnableMouse(true)
	frames.rpkb.options:Hide()

	--Keep chat open & focused
	local keepChatOpen = false
	DropDownList1MenuBackdrop:HookScript("OnHide", function()
		if keepChatOpen then
			frames.rpkb.editBox:SetFocus()
			if MouseIsOver(DropDownList1MenuBackdrop.NineSlice) then keepChatOpen = false end
		end
	end)

	--[ Language Selection ]

	--Button
	frames.rpkb.language = CreateFrame("Button", frames.rpkb.main:GetName() .. "LanguageSelect", frames.rpkb.options, BackdropTemplateMixin and "BackdropTemplate")
	frames.rpkb.language:SetPoint("LEFT", frames.rpkb.options, "LEFT", 6, 0)
	frames.rpkb.language:SetSize(120, 20)

	--Tooltip
	local tooltip
	frames.rpkb.language:HookScript("OnEnter", function() tooltip = wt.AddTooltip(nil, frames.rpkb.language, "ANCHOR_TOPRIGHT", strings.chatWindow.languageSelect.title, {
		[0] = { text = strings.chatWindow.languageSelect.tooltip[0], },
		[1] = { text = strings.chatWindow.languageSelect.tooltip[1], color = { r = 0.89, g = 0.65, b = 0.40 }, },
	}) end)
	frames.rpkb.language:HookScript("OnLeave", function() tooltip:Hide() end)

	--Icon
	local languageTexture = wt.CreateTexture({
		parent = frames.rpkb.language,
		name = "Logo",
		path = textures.logo,
		size = { width = 19, height = 19 },
	})

	--Text
	frames.rpkb.selectedLanguage = wt.CreateText({
		parent = frames.rpkb.language,
		position = {
			anchor = "LEFT",
			relativeTo = languageTexture,
			relativePoint = "RIGHT",
			offset = { x = 6, }
		},
		width = frames.rpkb.language:GetWidth() - languageTexture:GetWidth() - 6,
		justify = "LEFT",
		wrap = false
	})

	--Context menu
	local languageMenu = CreateFrame("Frame", frames.rpkb.language:GetName() .. "Menu", frames.rpkb.language, "UIDropDownMenuTemplate")
	UIDropDownMenu_SetWidth(languageMenu, 115)
	frames.rpkb.language:SetScript("OnClick", function()
		keepChatOpen = true
		--Assemble the menu
		local menu = {
			{
				text = strings.chatWindow.languageSelect.title,
				isTitle = true,
				notCheckable = true,
			},
		}
		for key, value in wt.SortedPairs(symbols) do
			table.insert(menu, {
				text = value.name,
				notCheckable = true,
				func = function()
					if currentSymbolSet == key then return end
					--Set the language
					currentSymbolSet = key
					frames.rpkb.selectedLanguage:SetText(symbols[key].name)
					--Update the message preview
					local r, g, b = wt.UnpackColor(ChatTypeInfo[currentDisplayChannel or currentSendChannel])
					frames.rpkb.previewText:SetText(RPKBTools.ApplyFont(frames.rpkb.editBox:GetText(), currentSymbolSet, 14, r * 255, g * 255, b * 255))
				end,
			})
		end
		--Open the menu
		EasyMenu(menu, languageMenu, frames.rpkb.language, 0, 0, "MENU")
	end)

	--[ Channel Selection ]

	--Button
	frames.rpkb.channel = CreateFrame("Button", frames.rpkb.main:GetName() .. "ChannelSelect", frames.rpkb.options, BackdropTemplateMixin and "BackdropTemplate")
	frames.rpkb.channel:SetPoint("LEFT", frames.rpkb.language, "RIGHT", 6, 0)
	frames.rpkb.channel:SetSize(120, 20)

	--Tooltip
	frames.rpkb.channel:HookScript("OnEnter", function() tooltip = wt.AddTooltip(nil, frames.rpkb.channel, "ANCHOR_TOPRIGHT", strings.chatWindow.channelSelect.title, {
		[0] = { text = strings.chatWindow.channelSelect.tooltip[0], },
		[1] = { text = strings.chatWindow.channelSelect.tooltip[1]:gsub("#ADDON", addonTitle), color = { r = 0.89, g = 0.65, b = 0.40 }, },
		[2] = { text = "\n*" .. strings.chatWindow.channelSelect.tooltip[2]:gsub("#ADDON", addonTitle), color = { r = 0.92, g = 0.34, b = 0.23 }, },
	}) end)
	frames.rpkb.channel:HookScript("OnLeave", function() tooltip:Hide() end)

	--Icon
	local displayChannelTexture = wt.CreateTexture({
		parent = frames.rpkb.channel,
		name = "Logo",
		path = textures.logo,
		size = { width = 19, height = 19 },
	})

	--Text
	frames.rpkb.selectedChannel = wt.CreateText({
		parent = frames.rpkb.channel,
		position = {
			anchor = "LEFT",
			relativeTo = displayChannelTexture,
			relativePoint = "RIGHT",
			offset = { x = 6, }
		},
		width = frames.rpkb.channel:GetWidth() - displayChannelTexture:GetWidth() - 6,
		text = GetChatName(currentDisplayChannel or currentSendChannel),
		justify = "LEFT",
		wrap = false
	})

	--Context menu
	local channelMenu = CreateFrame("Frame", frames.rpkb.channel:GetName() .. "Menu", frames.rpkb.channel, "UIDropDownMenuTemplate")
	UIDropDownMenu_SetWidth(channelMenu, 115)
	frames.rpkb.channel:SetScript("OnClick", function()
		keepChatOpen = true
		--Set display channel
		local function SetChannel(channel)
			if currentDisplayChannel == channel then return end
			--Update channels
			currentDisplayChannel = channel
			currentSendChannel = (channel == "SAY" or channel == "YELL" or channel == "EMOTE") and "CHANNEL" or channel
			--Update the UI
			frames.rpkb.selectedChannel:SetText(GetChatName(channel))
			frames.rpkb.selectedChannel:SetTextColor(wt.UnpackColor(ChatTypeInfo[channel]))
			frames.rpkb.channelIndicator:SetText(wt.Color(GetChatSendSnippet(channel), ChatTypeInfo[channel]))
			frames.rpkb.editBox:SetWidth(frames.rpkb.main:GetWidth() - frames.rpkb.channelIndicator:GetWidth() - 27)
			wt.SetVisibility(frames.rpkb.whisperTarget, channel == "WHISPER")
		end
		--Open the menu
		EasyMenu({
			{
				text = strings.chatWindow.channelSelect.title,
				isTitle = true,
				notCheckable = true,
			},
			{
				text = CHAT_MSG_SAY .. "*",
				notCheckable = true,
				func = function() SetChannel("SAY") end
			},
			{
				text = CHAT_MSG_YELL .. "*",
				notCheckable = true,
				func = function() SetChannel("YELL") end
			},
			{
				text = CHAT_MSG_EMOTE .. "*",
				notCheckable = true,
				func = function() SetChannel("EMOTE") end
			},
			{
				text = CHAT_MSG_WHISPER_INFORM,
				notCheckable = true,
				func = function() SetChannel("WHISPER") end
			},
			{
				text = CHAT_MSG_PARTY,
				notCheckable = true,
				func = function() SetChannel("PARTY") end
			},
			{
				text = CHAT_MSG_RAID,
				notCheckable = true,
				func = function() SetChannel("RAID") end
			},
			{
				text = CHAT_MSG_INSTANCE_CHAT,
				notCheckable = true,
				func = function() SetChannel("INSTANCE_CHAT") end
			},
			{
				text = CHAT_MSG_GUILD,
				notCheckable = true,
				func = function() SetChannel("GUILD") end
			},
			-- {
			-- 	text = CHAT_MSG_OFFICER,
			-- 	notCheckable = true,
			-- 	func = function() SetChannel("OFFICER") end
			-- },
			-- {
			-- 	text = CHAT_MSG_INSTANCE_CHAT_LEADER,
			-- 	notCheckable = true,
			-- 	func = function() SetChannel("INSTANCE_CHAT_LEADER") end
			-- },
			-- {
			-- 	text = CHAT_MSG_RAID_LEADER,
			-- 	notCheckable = true,
			-- 	func = function() SetChannel("RAID_LEADER") end
			-- },
			-- {
			-- 	text = CHAT_MSG_RAID_WARNING,
			-- 	notCheckable = true,
			-- 	func = function() SetChannel("RAID_WARNING") end
			-- },
		}, channelMenu, frames.rpkb.channel, 0, 0, "MENU")
	end)

	--[ Chat Input Background Art ]

	frames.rpkb.artCenter = wt.CreateTexture({
		parent = frames.rpkb.main,
		name = "ArtCenter",
		path = "Interface/ChatFrame/UI-ChatInputBorder-Mid2",
		position = {
			anchor = "TOP",
			offset = { y = 2 }
		},
		size = { width = frames.rpkb.main:GetWidth() - 64, height = 32 },
		tile = true,
	})

	frames.rpkb.artLeft = wt.CreateTexture({
		parent = frames.rpkb.main,
		name = "ArtLeft",
		path = "Interface/ChatFrame/UI-ChatInputBorder-Left2",
		position = {
			anchor = "RIGHT",
			relativeTo = frames.rpkb.artCenter,
			relativePoint = "LEFT",
		},
		size = { width = 32, height = 32 },
	})

	frames.rpkb.artRight = wt.CreateTexture({
		parent = frames.rpkb.main,
		name = "ArtRight",
		path = "Interface/ChatFrame/UI-ChatInputBorder-Right2",
		position = {
			anchor = "LEFT",
			relativeTo = frames.rpkb.artCenter,
			relativePoint = "RIGHT",
		},
		size = { width = 32, height = 32 },
	})

	--[ Chat Input Box ]

	--Display channel indicator
	frames.rpkb.channelIndicator = wt.CreateText({
		parent = frames.rpkb.main,
		name = "ChatType",
		position = {
			anchor = "LEFT",
			relativeTo = frames.rpkb.artLeft,
			relativePoint = "LEFT",
			offset = { x = 15, y = -0.5 },
		},
		template = "ChatFontNormal",
		justify = "LEFT",
	})

	--EditBox: Chat Input
	frames.rpkb.editBox = CreateFrame("EditBox", frames.rpkb.main:GetName() .. "InputBox", frames.rpkb.main, BackdropTemplateMixin and "BackdropTemplate")
	frames.rpkb.editBox:SetPoint("RIGHT", frames.rpkb.artRight, "RIGHT", -12, -0.5)
	frames.rpkb.editBox:SetSize(frames.rpkb.main:GetWidth() - 24, 17)

	--Font & text
	frames.rpkb.editBox:SetMultiLine(false)
	frames.rpkb.editBox:SetFontObject(ChatFontNormal)
	frames.rpkb.editBox:SetJustifyH("LEFT")
	frames.rpkb.editBox:SetJustifyV("MIDDLE")
	frames.rpkb.editBox:SetMaxLetters(255)

	--Art visibility
	frames.rpkb.artCenter:SetAlpha(0.3)
	frames.rpkb.artLeft:SetAlpha(0.3)
	frames.rpkb.artRight:SetAlpha(0.3)

	--Events & behavior
	frames.rpkb.editBox:SetAutoFocus(false)
	frames.rpkb.main:SetScript("OnMouseDown", function() frames.rpkb.editBox:SetFocus() end)
	frames.rpkb.editBox:SetScript("OnEditFocusGained", function(self)
		--Visibility
		frames.rpkb.main:SetFrameStrata("HIGH")
		--Art
		frames.rpkb.artCenter:SetAlpha(1)
		frames.rpkb.artLeft:SetAlpha(1)
		frames.rpkb.artRight:SetAlpha(1)
		--Display channel indicator
		frames.rpkb.channelIndicator:SetText(wt.Color(GetChatSendSnippet(currentDisplayChannel), ChatTypeInfo[currentDisplayChannel]))
		frames.rpkb.editBox:SetWidth(frames.rpkb.main:GetWidth() - frames.rpkb.channelIndicator:GetWidth() - 27)
		if currentSendChannel == "WHISPER" then frames.rpkb.whisperTarget:Show() end
		--Panels
		frames.rpkb.previewPanel:Show()
		frames.rpkb.options:Show()
	end)
	local closeChat = false
	frames.rpkb.editBox:SetScript("OnEditFocusLost", function(self)
		if not closeChat and (self:GetText() ~= "" or MouseIsOver(frames.rpkb.language) or MouseIsOver(frames.rpkb.channel) or MouseIsOver(frames.rpkb.whisperTarget)) then return
		else closeChat = false end
		if keepChatOpen then
			keepChatOpen = false
			self:SetFocus()
			return
		end
		--Visibility
		frames.rpkb.main:SetFrameStrata("LOW")
		--Art
		frames.rpkb.artCenter:SetAlpha(0.3)
		frames.rpkb.artLeft:SetAlpha(0.3)
		frames.rpkb.artRight:SetAlpha(0.3)
		--Panels
		frames.rpkb.previewText:SetText("")
		frames.rpkb.previewPanel:Hide()
		frames.rpkb.options:Hide()
		--Reset channel indicator
		frames.rpkb.channelIndicator:SetText("")
		frames.rpkb.whisperTarget:Hide()
	end)
	frames.rpkb.editBox:SetScript("OnTextChanged", function(self, user)
		if not user then return end
		--Update preview
		local r, g, b = wt.UnpackColor(ChatTypeInfo[currentDisplayChannel or currentSendChannel])
		frames.rpkb.previewText:SetText(RPKBTools.ApplyFont(self:GetText(), currentSymbolSet, 14, r * 255, g * 255, b * 255))
	end)
	frames.rpkb.editBox:SetScript("OnEnterPressed", function(self)
		if IsModifierKeyDown() then return end
		--Transmit the message
		RPKBTools.SendMessage(self:GetText(), currentSendChannel, currentDisplayChannel, currentSymbolSet, wt.Clear(frames.rpkb.whisperTarget:GetText()))
		--Clear the input
		closeChat = true
		self:SetText("")
		self:ClearFocus()
	end)
	frames.rpkb.editBox:SetScript("OnEscapePressed", function(self)
		--Clear the input
		closeChat = true
		self:SetText("")
		self:ClearFocus()
	end)

	--Tooltip
	-- editBox:HookScript("OnEnter", function()
	-- 	WidgetToolbox[ns.WidgetToolsVersion].AddTooltip(nil, editBox, "ANCHOR_RIGHT", t.label, t.tooltip)
	-- end)
	-- editBox:HookScript("OnLeave", function() customTooltip:Hide() end)

	--EditBox: Whisper targets
	frames.rpkb.whisperTarget = wt.CreateEditBox({
		parent = frames.rpkb.main,
		name = "WhisperTarget",
		title = strings.chatWindow.whisperTarget.title,
		label = false,
		tooltip = { [0] = { text = strings.chatWindow.whisperTarget.tooltip, }, },
		position = {
			anchor = "LEFT",
			relativeTo = frames.rpkb.artLeft,
			relativePoint = "LEFT",
			offset = { x = 42, y = -0.5 },
		},
		width = 80,
		onEnterPressed = function(self) self:ClearFocus() end,
		onEvent = {
			[0] = {
				event = "OnTextChanged",
				handler = function(self) self:SetText(wt.Color(wt.Clear(self:GetText()), ChatTypeInfo["WHISPER"])) end
			},
			[1] = {
				event = "OnEditFocusLost",
				handler = function()
					keepChatOpen = false
					frames.rpkb.editBox:SetFocus()
				end
			},
		},
	})
	frames.rpkb.whisperTarget:SetToplevel(true)
	frames.rpkb.whisperTarget:Hide()
	frames.rpkb.whisperTargetColon = wt.CreateText({
		parent = frames.rpkb.whisperTarget,
		name = "Colon",
		position = {
			anchor = "LEFT",
			relativeTo = frames.rpkb.whisperTarget,
			relativePoint = "RIGHT",
		},
		text = ":",
		template = "ChatFontNormal",
		justify = "LEFT",
	})

	--[ Send Button ]

	frames.rpkb.send = wt.CreateButton({
		parent = frames.rpkb.options,
		name = "Send",
		title = strings.chatWindow.send.title,
		tooltip = { [0] = { text = strings.chatWindow.send.tooltip:gsub("#ADDON", addonTitle):gsub("#ENTER", strings.keys.enter), }, },
		position = {
			anchor = "RIGHT",
			relativeTo = frames.rpkb.options,
			relativePoint = "RIGHT",
			offset = { x = -4, y = 1 }
		},
		width = 34,
		onClick = function()
			--Transmit the message
			RPKBTools.SendMessage(frames.rpkb.editBox:GetText(), currentSendChannel, currentDisplayChannel, currentSymbolSet, wt.Clear(frames.rpkb.whisperTarget:GetText()))
			--Clear the input
			frames.rpkb.editBox:SetFocus()
			frames.rpkb.editBox:SetText("")
			frames.rpkb.editBox:ClearFocus()
		end,
	})
	_G[frames.rpkb.send:GetName() .. "Text"]:SetText("|T" .. textures.send .. ":0:0:0:0:32:32:0:32:0:32:255:209:0|t")


	--[ Resizing Events ]

	ChatFrame1ResizeButton:HookScript("OnMouseUp", RPKBTools.UpdateDimensions)

	local ConfirmRedockChatOnAccept = StaticPopupDialogs["CONFIRM_REDOCK_CHAT"].OnAccept
	StaticPopupDialogs["CONFIRM_REDOCK_CHAT"].OnAccept = function()
		--Call the original Blizzard function
		ConfirmRedockChatOnAccept()
		--Custom RPKB code
		RPKBTools.UpdateDimensions()
	end
end

--Set up chat translate frame
local function SetUpTranslationFrame()

	--[ Translation Tooltip ]

	--Frame & position
	local translationTooltip = wt.CreateGameTooltip(addonNameSpace)
	translationTooltip:SetPoint("BOTTOMLEFT", ChatFrame1Background, "BOTTOMRIGHT")

	--Events & behavior
	translationTooltip:HookScript("OnMouseUp", function() translationTooltip:Hide() end)
	translationTooltip:HookScript("OnShow", function() PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) end)
	translationTooltip:HookScript("OnHide", function() PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF) end)

	--[ Hyperlink Handler ]

	wt.SetHyperlinkHandler(addonNameSpace, "translate", function(content)
		local set, text = strsplit(":", content, 2)
		set = (symbols[set] or {}).name or ""
		--Toggle tooltip
		if translationTooltip:IsVisible() and _G[translationTooltip:GetName() .. "TextLeft2"]:GetText() == text then
			translationTooltip:Hide()
		else
			wt.AddTooltip(
				translationTooltip, ChatFrame1Background, "ANCHOR_PRESERVE", "|T" .. textures.logo .. ":0|t " .. strings.translate.title:gsub("#LANGUAGE", set), {
					[0] = {
						text = text,
						font = ChatFontNormal,
					},
					[1] = {
						text = "\n" .. strings.translate.close,
						font = GameFontNormalTiny,
						color = colors.grey[0],
					},
				}
			)
		end
	end)
end

--[ Loading ]

function frames.rpkb.main:ADDON_LOADED(name)
	if name ~= addonNameSpace then return end
	frames.rpkb.main:UnregisterEvent("ADDON_LOADED")
	--Load & check the DBs
	if LoadDBs() then
		PrintInfo()
		cs.first = true
	end
	--Create cross-session account-wide variables
	if not cs.compactBackup then cs.compactBackup = true end
	--Create cross-session character-specific variables
	if not csc.visible then csc.visible = false end
	if not csc.logs then csc.logs = {} end
	-- if not csc.logs.sent then csc.logs.sent = {} end
	csc.logs.sent = {}
	-- if not csc.logs.received then csc.logs.received = {} end
	csc.logs.received = {}
	logSentIndex = not csc.logs.sent[0] and -1 or #csc.logs.sent + 1
	logReceivedIndex = not csc.logs.received[0] and -1 or #csc.logs.received + 1
	--Set key binding labels
	BINDING_HEADER_RPKB = addonTitle
	BINDING_NAME_RPKB_OPEN = strings.keybinds.open
	BINDING_NAME_RPKB_TOGGLE = strings.keybinds.toggle
	--Register messaging prefix
	C_ChatInfo.RegisterAddonMessagePrefix(prefix)
	--Set up the interface options
	LoadInterfaceOptions()
	--Set up the frames
	SetUpChatWindowFrames()
	SetUpTranslationFrame()
end
function frames.rpkb.main:PLAYER_ENTERING_WORLD()
	--Visibility notice
	if not frames.rpkb.main:IsVisible() then PrintStatus(true) end
	--Set default key bindings
	if cs.first then
		cs.first = nil
		SetBinding("CTRL-ENTER", "RPKB_TOGGLE")
		--Chat notification
		print(wt.Color(addonTitle .. ":", colors.red[0]) .. " " .. wt.Color(strings.chat.keybind.toggle:gsub(
			"#KEYBIND", wt.Color(strings.keys.ctrl .. "-" .. strings.keys.enter:lower():gsub("^%l", string.upper), colors.blue[1])
		):gsub(
			"#ACTION", wt.Color(strings.keybinds.toggle, colors.blue[1])
		), colors.blue[0]))
	end
	--Join the custom RPKB chat channel
	if not customChannelID then
		JoinChannelByName(addonNameSpace)
		customChannelID = (C_ChatInfo.GetChannelInfoFromIdentifier(addonNameSpace) or {}).localID
	end
	--Set chat window colors
	frames.rpkb.selectedChannel:SetTextColor(wt.UnpackColor(ChatTypeInfo[currentDisplayChannel]))
	frames.rpkb.whisperTargetColon:SetTextColor(wt.UnpackColor(ChatTypeInfo["WHISPER"]))
end


--[[ CHAT MANAGEMENT ]]

--Message transmission received
function frames.rpkb.main:CHAT_MSG_ADDON(addonPrefix, content, channel, sender)
	if addonPrefix ~= prefix then return end
	local displayChannel, symbolSetKey, text = strsplit("|", content, 3)
	--Add to the logs
	AddReceivedLog(text, symbolSetKey, displayChannel, channel, sender)
	--Display the message
	local senderName, senderRealm = strsplit("-", sender)
	RPKBTools.PrintMessage(text, displayChannel, symbolSetKey, senderName, senderRealm)
end

--Chat channel joined
function frames.rpkb.main:CHANNEL_UI_UPDATE()
	local lastID = C_ChatInfo.GetNumActiveChannels()
	if customChannelID == lastID then return end
	--Keep the RPKB channel at the last place
	C_ChatInfo.SwapChatChannelsByChannelIndex(customChannelID, lastID)
	customChannelID = lastID
end