--Addon namespace
local _, ns = ...


--[[ CHANGELOG ]]

local changelogDB = {
	[0] = {
		[0] = "#V_Version 1.0_# #H_(8/20/2022)_#",
		[1] = "#H_It's alive!_#",
	},
}

ns.GetChangelog = function()
	--Colors
	local version = "FFFFFFFF"
	local new = "FF66EE66"
	local fix = "FFEE4444"
	local change = "FF8888EE"
	local note = "FFEEEE66"
	local highlight = "FFBBBBBB"
	--Assemble the changelog
	local changelog = ""
		for i = #changelogDB, 0, -1 do
			for j = 0, #changelogDB[i] do
				changelog = changelog .. (j > 0 and "\n\n" or "") .. changelogDB[i][j]:gsub(
					"#V_(.-)_#", (i < #changelogDB and "\n\n\n" or "") .. "|c" .. version .. "%1|r"
				):gsub(
					"#N_(.-)_#", "|c".. new .. "%1|r"
				):gsub(
					"#F_(.-)_#", "|c".. fix .. "%1|r"
				):gsub(
					"#C_(.-)_#", "|c".. change .. "%1|r"
				):gsub(
					"#O_(.-)_#", "|c".. note .. "%1|r"
				):gsub(
					"#H_(.-)_#", "|c".. highlight .. "%1|r"
				)
			end
		end
	return changelog
end


--[[ LOCALIZATIONS ]]

local english = {
	options = {
		name = "#ADDON options",
		defaults = "The default options and the chat window position have been reset.",
		main = {
			description = "Customize #ADDON to fit your needs. Type #KEYWORD for chat commands.", --# flags will be replaced with code
			shortcuts = {
				title = "Shortcuts",
				description = "Access customization options by expanding the #ADDON categories on the left or by clicking a button here.", --# flags will be replaced with code
			},
			about = {
				title = "About",
				description = "Thank you for using #ADDON!", --# flags will be replaced with code
				version = "Version: #VERSION", --# flags will be replaced with code
				date = "Date: #DATE", --# flags will be replaced with code
				author = "Author: #AUTHOR", --# flags will be replaced with code
				license = "License: #LICENSE", --# flags will be replaced with code
				changelog = {
					title = "Changelog",
					tooltip = "Notes of all the changes included in the addon updates for all versions.\n\nThe changelog is only available in English for now.", --\n represents the newline character
				},
			},
			support = {
				title = "Support",
				description = "Follow the links to see how you can provide feedback, report bugs, get help and support development.",
				curseForge = "CurseForge Page",
				wago = "Wago Page",
				bitBucket = "BitBucket Repository",
				issues = "Issues & Ideas",
			},
			feedback = {
				title = "Feedback",
				description = "Visit #ADDON online if you have something to report.", --# flags will be replaced with code
			},
		},
		symbolSets = {
			title = "Symbol Sets",
			description = "The list and details of each symbol set pack currently installed and enabled for #ADDON.", --# flags will be replaced with code
			symbols = {
				title = "Symbols",
				tooltip = "List of symbols and their corresponding characters to type included in this set."
			},
		},
		chatWindow = {
			title = "Chat Window",
			description = "Customize the #ADDON chat input window.", --# flags will be replaced with code
			position = {
				title = "Position",
				description = "Drag & drop the chat window by clicking on the toggle button while holding #SHIFT to reposition it, fine-tune it here.", --# flags will be replaced with code
				snap = {
					title = "Snap to Chat",
					tooltip = {
						[0] = "Snap the #ADDON chat window below the default chat window so it moves and resizes with it.", --# flags will be replaced with code
						[1] = "Note: Other addons might interfere with the automatic resizing. If you encounter issues, please consider making a report following the support link under #ISSUES on the main options page with a list of addons you are using included!\nDisconnecting after or during resizing might also cause issues. Resize the chat again to refresh the size of the #ADDON chat window elements.", --# flags will be replaced with code, \n represents the newline character
						[2] = "If the default chat has been hidden, replaced or removed, the snap functionality will be unavailable.",
					},
				},
				anchor = {
					title = "Screen Anchor Point",
					tooltip = "Select which point of the screen should the chat window be anchored to.",
				},
				xOffset = {
					title = "Horizontal Offset",
					tooltip = "Set the amount of horizontal offset (X axis) of the chat window from the selected anchor point.",
				},
				yOffset = {
					title = "Vertical Offset",
					tooltip = "Set the amount of vertical offset (Y axis) of the chat window from the selected anchor point.",
				},
			},
		},
		chatLogs = {
			title = "Chat Logs",
			description = "The log of messages sent and received through #ADDON.", --# flags will be replaced with code
		},
		advanced = {
			title = "Advanced",
			description = "Configure #ADDON settings further, change options manually or backup your data by importing, exporting settings.", --# flags will be replaced with code
			profiles = {
				title = "Profiles",
				description = "Create, edit and apply unique options profiles to customize #ADDON separately between your characters. (Soon???)", --# flags will be replaced with 
			},
			backup = {
				title = "Backup",
				description = "Import or export #ADDON options to save, share or apply them between your accounts.", --# flags will be replaced with code
				backupBox = {
					title = "Import & Export",
					tooltip = {
						[0] = "The backup string in this box contains the currently saved addon data and frame positions.",
						[1] = "Copy it to save, share or use it for another account.",
						[2] = "If you have a string, just override the text inside this box. Select it, and paste your string here. Press #ENTER to load the data stored in it.", --# flags will be replaced with code
						[3] = "Note: If you are using a custom font file, that file can not carry over with this string. It will need to be inserted into the addon folder to be applied.",
						[4] = "Only load strings that you have verified yourself or trust the source of!",
					},
				},
				compact = {
					title = "Compact",
					tooltip = "Toggle between a compact and a readable view.",
				},
				load = {
					title = "Load",
					tooltip = "Check the current string, and attempt to load all data from it.",
				},
				reset = {
					title = "Reset",
					tooltip = "Reset the string to reflect the currently stored values.",
				},
				import = "Load the string",
				warning = "Are you sure you want to attempt to load the currently inserted string?\n\nIf you've copied it from an online source or someone else has sent it to you, only load it after checking the code inside and you know what you are doing.\n\nIf don't trust the source, you may want to cancel to prevent any unwanted events.", --\n represents the newline character
				error = "The provided backup string could not be validated and no data was loaded. It might be missing some characters, or errors may have been introduced if it was edited.",
			},
		},
	},
	chat = {
		status = {
			enabled = "#ADDON is enabled for this character.", --# flags will be replaced with code
			disabled = "#ADDON is disabled for this character.", --# flags will be replaced with code
		},
		help = {
			command = "help",
			thanks = "Thank you for using #ADDON!", --# flags will be replaced with code
			hint = "Type #HELP_COMMAND to see the full command list.", --# flags will be replaced with code
			list = "chat command list",
		},
		keybind = {
			toggle = "Keybind #KEYBIND was set to #ACTION.", --# flags will be replaced with code
		},
		options = {
			command = "options",
			description = "open the #ADDON options", --# flags will be replaced with code
		},
		toggle = {
			command = "toggle",
			description = "toggle #ADDON for this character (#STATE)", --# flags will be replaced with code
			enabled = "#ADDON has been enabled for this character.", --# flags will be replaced with code
			disabled = "#ADDON has been disabled for this character.", --# flags will be replaced with code
		},
		snap = {
			command = "snap",
			description = "snap the #ADDON chat window below the default chat.",
			enabled = "chat window snapped below the default chat window.",
			disable = "chat window is no longer snapped below the default chat window.",
			error = "chat window can't be snapped below the default chat window.",
		},
		noFont = "Couldn't display the message as the sender intended.\n\"#FONT\" font pack is not installed.", --# flags will be replaced with code, \n represents the newline character
	},
	translate = {
		title = "Written in #LANGUAGE:", --# flags will be replaced with code
		close = "Click to close."
	},
	chatWindow = {
		languageSelect = {
			title = "Language Font",
			tooltip = {
				[0] = "Select the font to apply to the typed characters to make them appear to be written with the symbols of the specific language.",
				[1] = "Note: If the recipients of the message do not have the selected font pack installed, their message will appear with regular font. They will see a note mentioning which symbol set are they missing."
			}
		},
		channelSelect = {
			title = "Chat Channel",
			tooltip = {
				[0] = "Select which channel to send to message through and how it should appear.",
				[1] = "Note: These messages will only be seen by other #ADDON users!", --# flags will be replaced with code
				[2] = "Addons can only transmit messages to party, raid, guild or other group members. This unfortunately means that not everyone around will be able to see the message even if they have #ADDON installed.", --# flags will be replaced with code
			},
		},
		whisperTarget = {
			title = "Whisper Target",
			tooltip = "When the channel to send the message through is set to #WHISPER, it will be sent to the player who's name is entered here.", --# flags will be replaced with code
		},
		send = {
			title = "Send",
			tooltip = "Send the message currently typed into the #ADDON input box to the selected channel & target which will appear with the specified font (if recipients also have that font pack installed).\n\nAlternatively, you can hit #ENTER to send the message.", --# flags will be replaced with code, \n represents the newline character
		},
	},
	keys = {
		ctrl = "CTRL",
		shift = "SHIFT",
		enter = "ENTER",
	},
	keybinds = {
		open = "Open Chat",
		toggle = "Toggle the Chat Window",
	},
	points = {
		left = "Left",
		right = "Right",
		center = "Center",
		top = {
			left = "Top Left",
			right = "Top Right",
			center = "Top Center",
		},
		bottom = {
			left = "Bottom Left",
			right = "Bottom Right",
			center = "Bottom Center",
		},
	},
	misc = {
		date = "#MONTH/#DAY/#YEAR", --# flags will be replaced with code
		dateTimeFormat = "%m/%d/%y %H:%M:%S",
		default = "Default",
		custom = "Custom",
		override = "Override",
		enabled = "enabled",
		disabled = "disabled",
		days = "days",
		hours = "hours",
		minutes = "minutes",
		seconds = "seconds",
	},
}


--[[ Load Localization ]]

--Load the proper localization table based on the client language
ns.LoadLocale = function()
	local strings
	if (GetLocale() == "") then
		--TODO: Add localization for other languages (locales: https://wowwiki-archive.fandom.com/wiki/API_GetLocale#Locales)
		--Different font locales: https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/FrameXML/Fonts.xml
	else --Default: English (UK & US)
		strings = english
		strings.misc.defaultFont = UNIT_NAME_FONT_ROMAN:gsub("\\", "/")
	end
	return strings
end