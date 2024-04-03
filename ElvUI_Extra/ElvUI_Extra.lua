--[[
	This is a framework showing how to create a plugin for ElvUI.
	It creates some default options and inserts a GUI table to the ElvUI Config.
	If you have questions then ask in the Tukui lua section: https://www.tukui.org/forum/viewforum.php?f=10
]]

local E, L, V, P, G = unpack(ElvUI);                                                           --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUI_Extra = E:NewModule('ElvUI_Extra', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0")                                                       --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addonName, addonTable = ...                                                              --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2



--Default options
P["ElvUI_Extra"] = {
	["OnlyFriendlyTarget"] = true,
}

--Function we can call when a setting changes.
--In this case it just checks if "OnlyFriendlyTarget" is enabled and registers our event to it.
function ElvUI_Extra:Update()
	local enabled = E.db.ElvUI_Extra.OnlyFriendlyTarget
	local t = ElvUF_Target
	if enabled then
		ElvUI_Extra:RegisterEvent("PLAYER_TARGET_CHANGED")
	else
		ElvUI_Extra:UnregisterEvent("PLAYER_TARGET_CHANGED")
		t:SetAlpha(1.00);
	end
end

function ElvUI_Extra:PLAYER_TARGET_CHANGED()
	local t = ElvUF_Target
	local isPlayer, unitExists = UnitIsPlayer("target"), UnitExists("target");
	if unitExists and isPlayer and t ~= nil then
		t:SetAlpha(1.00);
	end
	if unitExists and not isPlayer and t ~= nil then
		t:SetAlpha(0.00);
	end
end

--This function inserts our GUI table into the ElvUI Config. You can read about AceConfig here: http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
function ElvUI_Extra:InsertOptions()
	E.Options.args.ElvUI_Extra = {
		order = 100,
		type = "group",
		name = "ElvUI_Extra",
		args = {
			OnlyFriendlyTarget = {
				order = 1,
				type = "toggle",
				name = "Show only friendly targetframe.",
				desc = "Toggle this option to only show a target frame when the player targets another player.",
				width = "full",
				get = function(info)
					return E.db.ElvUI_Extra.OnlyFriendlyTarget
				end,
				set = function(info, value)
					E.db.ElvUI_Extra.OnlyFriendlyTarget = value
					ElvUI_Extra:Update() --We changed a setting, call our Update function
				end,
			},
		},
	}
end

function ElvUI_Extra:Initialize()
	--Register plugin so options are properly inserted when config is loaded
	EP:RegisterPlugin(addonName, ElvUI_Extra.InsertOptions)
	ElvUI_Extra:Update()
end

E:RegisterModule(ElvUI_Extra:GetName()) --Register the module with ElvUI. ElvUI will now call ElvUI_Extra:Initialize() when ElvUI is ready to load our plugin.
