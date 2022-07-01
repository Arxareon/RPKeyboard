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
			credits[i].role, credits[i].name = strsplit("|", value, 2)
		end
	end

    --Separate the links
    local links = GetAddOnMetadata(addonNameSpace, "X-Links") and {} or nil
	if links then
		local i = -1
		for value in GetAddOnMetadata(addonNameSpace, "X-Links"):gsub(",%s+", ","):gmatch("[^,]+") do
			i = i + 1
			links[i] = {}
			links[i].title, links[i].url = strsplit("|", value, 2)
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
			["e"] = {
				path = root .. "Textures/12_E.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["f"] = {
				path = root .. "Textures/13_F.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["g"] = {
				path = root .. "Textures/14_G.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["h"] = {
				path = root .. "Textures/15_H.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["i"] = {
				path = root .. "Textures/16_I.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["j"] = {
				path = root .. "Textures/17_J.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["k"] = {
				path = root .. "Textures/18_K.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["l"] = {
				path = root .. "Textures/19_L.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["m"] = {
				path = root .. "Textures/20_M.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["n"] = {
				path = root .. "Textures/21_N.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["o"] = {
				path = root .. "Textures/22_O.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["p"] = {
				path = root .. "Textures/23_P.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["q"] = {
				path = root .. "Textures/24_Q.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["r"] = {
				path = root .. "Textures/25_R.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["s"] = {
				path = root .. "Textures/26_S.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["t"] = {
				path = root .. "Textures/27_T.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["u"] = {
				path = root .. "Textures/28_U.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["v"] = {
				path = root .. "Textures/29_V.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["w"] = {
				path = root .. "Textures/30_W.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["x"] = {
				path = root .. "Textures/31_X.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["y"] = {
				path = root .. "Textures/32_Y.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
			["z"] = {
				path = root .. "Textures/33_Z.tga",
				cut = { left = 4, right = 4, top = 4, bottom = 4 },
			},
		},
	})

    --[ Debug ]

    -- print(symbolSetKey)
    -- local symbolSetTable = RPKBTools.GetSet(symbolSetKey, true)
end