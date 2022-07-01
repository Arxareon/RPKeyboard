--[[ ADDON INFO ]]

--Addon namespace string & table
local addonNameSpace = ...

--Addon root folder
local root = "Interface/AddOns/" .. addonNameSpace .. "/"


--[[ FRAMES & EVENTS ]]

--Creating the main addon frame
local frame = CreateFrame("Frame", addonNameSpace, UIParent) --Main addon frame

--Registering events
frame:RegisterEvent("ADDON_LOADED")

--Event handler
frame:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, ...)
end)


--[[ INITIALIZATION ]]

--Load the symbol set
function frame:ADDON_LOADED(name)
	if name ~= addonNameSpace then return end
	frame:UnregisterEvent("ADDON_LOADED")

    --[ Register the symbol set ]

    --Separate the authors
	local credits = GetAddOnMetadata(addonNameSpace, "X-Credits") and {} or nil
	if credits then
		local i = -1
		for value in GetAddOnMetadata(addonNameSpace, "X-Credits"):gsub(",%s+", ","):gmatch("[^,]+") do
			i = i + 1
			credits[i] = {}
			credits[i].role = value:match("[^|]+")
			credits[i].name = value:gsub(".+|", "")
		end
	end

    --Separate the links
    local links = GetAddOnMetadata(addonNameSpace, "X-Links") and {} or nil
	if links then
		local i = -1
		for value in GetAddOnMetadata(addonNameSpace, "X-Links"):gsub(",%s+", ","):gmatch("[^,]+") do
			i = i + 1
			links[i] = {}
			links[i].title = value:match("[^|]+")
			links[i].url = value:gsub(".+|", "")
		end
	end

    --Add to RPKeyboard
	local symbolSetKey = RPKBTools.AddSet({
		name = GetAddOnMetadata(addonNameSpace, "Title"):gsub("RP Keyboard: ", ""),
		description = GetAddOnMetadata(addonNameSpace, "Notes"),
		version = GetAddOnMetadata(addonNameSpace, "Version"),
		date = {
            day = GetAddOnMetadata(addonNameSpace, "X-Day"),
            month = GetAddOnMetadata(addonNameSpace, "X-Month"),
            year = GetAddOnMetadata(addonNameSpace, "X-Year")
        },
		license = GetAddOnMetadata(addonNameSpace, "X-License"),
		credits = credits or { [0] = { name = GetAddOnMetadata(addonNameSpace, "Author") } },
		links = links,
		textures = {
			["!"] = { path = root .. "Textures/0_Exclamation.tga", },
			["\""] = { path = root .. "Textures/1_Quotation.tga", },
			["'"] = { path = root .. "Textures/2_Apostrophe.tga", },
			[","] = { path = root .. "Textures/3_Comma.tga", },
			["."] = { path = root .. "Textures/4_Period.tga", },
			[":"] = { path = root .. "Textures/5_Colon.tga", },
			[";"] = { path = root .. "Textures/6_Semicolon.tga", },
			["?"] = { path = root .. "Textures/7_Question.tga", },
			["a"] = { path = root .. "Textures/8_A.tga", },
			["b"] = { path = root .. "Textures/9_B.tga", },
			["c"] = { path = root .. "Textures/10_C.tga", },
			["d"] = { path = root .. "Textures/11_D.tga", },
			["e"] = { path = root .. "Textures/12_E.tga", },
			["f"] = { path = root .. "Textures/13_F.tga", },
			["g"] = { path = root .. "Textures/14_G.tga", },
			["h"] = { path = root .. "Textures/15_H.tga", },
			["i"] = { path = root .. "Textures/16_I.tga", },
			["j"] = { path = root .. "Textures/17_J.tga", },
			["k"] = { path = root .. "Textures/18_K.tga", },
			["l"] = { path = root .. "Textures/19_L.tga", },
			["m"] = { path = root .. "Textures/20_M.tga", },
			["n"] = { path = root .. "Textures/21_N.tga", },
			["o"] = { path = root .. "Textures/22_O.tga", },
			["p"] = { path = root .. "Textures/23_P.tga", },
			["q"] = { path = root .. "Textures/24_Q.tga", },
			["r"] = { path = root .. "Textures/25_R.tga", },
			["s"] = { path = root .. "Textures/26_S.tga", },
			["t"] = { path = root .. "Textures/27_T.tga", },
			["u"] = { path = root .. "Textures/28_U.tga", },
			["v"] = { path = root .. "Textures/29_V.tga", },
			["w"] = { path = root .. "Textures/30_W.tga", },
			["x"] = { path = root .. "Textures/31_X.tga", },
			["y"] = { path = root .. "Textures/32_Y.tga", },
			["z"] = { path = root .. "Textures/33_Z.tga", },
		},
	})

    --[ Debug ]

    -- print(symbolSetKey)
    -- local symbolSetTable = RPKBTools.GetSet(symbolSetKey, true)
end