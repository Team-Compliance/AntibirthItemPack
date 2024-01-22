local DSSMenuManager = {}

function DSSMenuManager.GetSaveData()
    if not AntibirthItemPack.RunPersistentData.DssMenuConfig then
        AntibirthItemPack.RunPersistentData.DssMenuConfig = {}
    end

    return AntibirthItemPack.RunPersistentData.DssMenuConfig
end

function DSSMenuManager.StoreSaveData()
    AntibirthItemPack:OnGameExit()
end

--
-- End of generic data storage manager
--

--
-- Start of menu code
--

-- Change this variable to match your mod. The standard is "Dead Sea Scrolls (Mod Name)"
local DSSModName = "Dead Sea Scrolls (Antibirth Item Pack)"

-- DSSCoreVersion determines which menu controls the mod selection menu that allows you to enter other mod menus.
-- Don't change it unless you really need to and make sure if you do that you can handle mod selection and global mod options properly.
local DSSCoreVersion = 7

-- Every MenuProvider function below must have its own implementation in your mod, in order to handle menu save data.
local MenuProvider = {}

function MenuProvider.SaveSaveData()
    DSSMenuManager.StoreSaveData()
end

function MenuProvider.GetPaletteSetting()
    return DSSMenuManager.GetSaveData().MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    DSSMenuManager.GetSaveData().MenuPalette = var
end

function MenuProvider.GetHudOffsetSetting()
    if not REPENTANCE then
        return DSSMenuManager.GetSaveData().HudOffset
    else
        return Options.HUDOffset * 10
    end
end

function MenuProvider.SaveHudOffsetSetting(var)
    if not REPENTANCE then
        DSSMenuManager.GetSaveData().HudOffset = var
    end
end

function MenuProvider.GetGamepadToggleSetting()
    return DSSMenuManager.GetSaveData().GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    DSSMenuManager.GetSaveData().GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return DSSMenuManager.GetSaveData().MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    DSSMenuManager.GetSaveData().MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return DSSMenuManager.GetSaveData().MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    DSSMenuManager.GetSaveData().MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return DSSMenuManager.GetSaveData().MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    DSSMenuManager.GetSaveData().MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return DSSMenuManager.GetSaveData().MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    DSSMenuManager.GetSaveData().MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return DSSMenuManager.GetSaveData().MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    DSSMenuManager.GetSaveData().MenusPoppedUp = var
end

local DSSInitializerFunction = require("lua.lib.dssmenucore")
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)

local itemTogglesMenu = {
    {str = 'choose what items', fsize = 2, nosel = true},
    {str = 'show up', fsize = 2, nosel = true},
    {str = '', fsize = 2, nosel = true},
}

local itemConfig = Isaac.GetItemConfig()
---@type ItemConfig_Item[]
local orderedItems = {}
for _, collectible in pairs(AntibirthItemPack.CollectibleType) do
    local collectibleConf = itemConfig:GetCollectible(collectible)
    table.insert(orderedItems, collectibleConf)
end
table.sort(orderedItems, function (a, b)
    return a.Name < b.Name
end)

local function SplitStr(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

for _, collectible in pairs(orderedItems) do
    local split = SplitStr(string.lower(collectible.Name))

    local tooltipStr = {"enable", ""}
    for _, word in ipairs(split) do
        if tooltipStr[#tooltipStr]:len() + word:len() > 15 then
            tooltipStr[#tooltipStr] = tooltipStr[#tooltipStr]:sub(0, tooltipStr[#tooltipStr]:len()-1)
            tooltipStr[#tooltipStr+1] = word .. " "
        else
            tooltipStr[#tooltipStr] = tooltipStr[#tooltipStr] .. word .. " "
        end
    end
    tooltipStr[#tooltipStr] = tooltipStr[#tooltipStr]:sub(0, tooltipStr[#tooltipStr]:len()-1)

    local itemSprite = Sprite()
    itemSprite:Load("gfx/ui/dss_item.anm2", false)
    itemSprite:ReplaceSpritesheet(0, collectible.GfxFileName)
    itemSprite:LoadGraphics()
    itemSprite:SetFrame("Idle", 0)

    local collectibleOption = {
        str = string.lower(collectible.Name),

        -- The "choices" tag on a button allows you to create a multiple-choice setting
        choices = {'enabled', 'disabled'},
        -- The "setting" tag determines the default setting, by list index. EG "1" here will result in the default setting being "choice a"
        setting = 1,

        -- "variable" is used as a key to story your setting; just set it to something unique for each setting!
        variable = 'ToggleItem' .. collectible.Name,

        -- When the menu is opened, "load" will be called on all settings-buttons
        -- The "load" function for a button should return what its current setting should be
        -- This generally means looking at your mod's save data, and returning whatever setting you have stored
        load = function()
            if not AntibirthItemPack.RunPersistentData.DisabledItems then
                AntibirthItemPack.RunPersistentData.DisabledItems = {}
            end

            for _, disabledItem in ipairs(AntibirthItemPack.RunPersistentData.DisabledItems) do
                if disabledItem == collectible.ID then
                    return 2
                end
            end
            return 1
        end,

        -- When the menu is closed, "store" will be called on all settings-buttons
        -- The "store" function for a button should save the button's setting (passed in as the first argument) to save data!
        store = function(var)
            if not AntibirthItemPack.RunPersistentData.DisabledItems then
                AntibirthItemPack.RunPersistentData.DisabledItems = {}
            end

            for index, disabledItem in ipairs(AntibirthItemPack.RunPersistentData.DisabledItems) do
                if disabledItem == collectible.ID then
                    if var == 1 then
                        table.remove(AntibirthItemPack.RunPersistentData.DisabledItems, index)
                    end
                    return
                end
            end

            if var == 2 then
                table.insert(AntibirthItemPack.RunPersistentData.DisabledItems, collectible.ID)
            end
        end,

        -- A simple way to define tooltips is using the "strset" tag, where each string in the table is another line of the tooltip
        tooltip = {
            buttons = {
                {spr = {
                    sprite = itemSprite,
                    centerx = 16,
                    centery = 16,
                    width = 32,
                    height = 32,
                    float = {1, 6},
                    shadow = true,
                    nosel = true
                }},
                {strset = tooltipStr},
            }
        }
    }

    itemTogglesMenu[#itemTogglesMenu+1] = collectibleOption
end


-- Creating a menu like any other DSS menu is a simple process.
-- You need a "Directory", which defines all of the pages ("items") that can be accessed on your menu, and a "DirectoryKey", which defines the state of the menu.
local itemSprite = Sprite()
itemSprite:Load("gfx/ui/dss_item.anm2", false)

local exampledirectory = {
    -- The keys in this table are used to determine button destinations.
    main = {
        -- "title" is the big line of text that shows up at the top of the page!
        title = 'antibirth item pack',

        -- "buttons" is a list of objects that will be displayed on this page. The meat of the menu!
        buttons = {
            -- The simplest button has just a "str" tag, which just displays a line of text.
            
            -- The "action" tag can do one of three pre-defined actions:
            --- "resume" closes the menu, like the resume game button on the pause menu. Generally a good idea to have a button for this on your main page!
            --- "back" backs out to the previous menu item, as if you had sent the menu back input
            --- "openmenu" opens a different dss menu, using the "menu" tag of the button as the name
            {str = 'resume game', action = 'resume'},

            -- The "dest" option, if specified, means that pressing the button will send you to that page of your menu.
            -- If using the "openmenu" action, "dest" will pick which item of that menu you are sent to.
            {str = 'settings', dest = 'settings'},

            {str = 'item toggles', dest = 'items'},

            -- A few default buttons are provided in the table returned from DSSInitializerFunction.
            -- They're buttons that handle generic menu features, like changelogs, palette, and the menu opening keybind
            -- They'll only be visible in your menu if your menu is the only mod menu active; otherwise, they'll show up in the outermost Dead Sea Scrolls menu that lets you pick which mod menu to open.
            -- This one leads to the changelogs menu, which contains changelogs defined by all mods.
            dssmod.changelogsButton,
        },

        -- A tooltip can be set either on an item or a button, and will display in the corner of the menu while a button is selected or the item is visible with no tooltip selected from a button.
        -- The object returned from DSSInitializerFunction contains a default tooltip that describes how to open the menu, at "menuOpenToolTip"
        -- It's generally a good idea to use that one as a default!
        tooltip = dssmod.menuOpenToolTip
    },

    settings = {
        title = 'settings',
        buttons = {
            -- These buttons are all generic menu handling buttons, provided in the table returned from DSSInitializerFunction
            -- They'll only show up if your menu is the only mod menu active
            -- You should generally include them somewhere in your menu, so that players can change the palette or menu keybind even if your mod is the only menu mod active.
            -- You can position them however you like, though!
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            dssmod.paletteButton,
            dssmod.menuHintButton,
            dssmod.menuBuzzerButton,

        }
    },

    items = {
        title = 'item toggles',

        buttons = itemTogglesMenu
    }
}

local exampledirectorykey = {
    Item = exampledirectory.main, -- This is the initial item of the menu, generally you want to set it to your main item
    Main = 'main', -- The main item of the menu is the item that gets opened first when opening your mod's menu.

    -- These are default state variables for the menu; they're important to have in here, but you don't need to change them at all.
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

--#region AgentCucco pause manager for DSS

local OldTimer
local OldTimerBossRush
local OldTimerHush
local OverwrittenPause = false
local AddedPauseCallback = false
local function OverridePause(self, player, hook, action)
	if not AddedPauseCallback then return nil end

	if OverwrittenPause then
		OverwrittenPause = false
		AddedPauseCallback = false
		return
	end

	if action == ButtonAction.ACTION_SHOOTRIGHT then
		OverwrittenPause = true
		for _, ember in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.FALLING_EMBER, -1)) do
			if ember:Exists() then
				ember:Remove()
			end
		end
		if REPENTANCE then
			for _, rain in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.RAIN_DROP, -1)) do
				if rain:Exists() then
					rain:Remove()
				end
			end
		end
		return 0.75
	end
end
AntibirthItemPack:AddCallback(ModCallbacks.MC_INPUT_ACTION, OverridePause, InputHook.IS_ACTION_PRESSED)

local function FreezeGame(unfreeze)
	if unfreeze then
		OldTimer = nil
        OldTimerBossRush = nil
        OldTimerHush = nil
        if not AddedPauseCallback then
			AddedPauseCallback = true
		end
	else
		if not OldTimer then
			OldTimer = Game().TimeCounter
		end
        if not OldTimerBossRush then
            OldTimerBossRush = Game().BossRushParTime
		end
        if not OldTimerHush then
			OldTimerHush = Game().BlueWombParTime
		end
		
        Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, UseFlag.USE_NOANIM)
		
		Game().TimeCounter = OldTimer
		Game().BossRushParTime = OldTimerBossRush
		Game().BlueWombParTime = OldTimerHush
	end
end

local function RunDSSMenu(tbl)
    FreezeGame()
    dssmod.runMenu(tbl)
end

local function CloseDSSMenu(tbl, fullClose, noAnimate)
    FreezeGame(true)
    dssmod.closeMenu(tbl, fullClose, noAnimate)
end

--#endregion

DeadSeaScrollsMenu.AddMenu("Antibirth Item Pack", {
    -- The Run, Close, and Open functions define the core loop of your menu
    -- Once your menu is opened, all the work is shifted off to your mod running these functions, so each mod can have its own independently functioning menu.
    -- The DSSInitializerFunction returns a table with defaults defined for each function, as "runMenu", "openMenu", and "closeMenu"
    -- Using these defaults will get you the same menu you see in Bertran and most other mods that use DSS
    -- But, if you did want a completely custom menu, this would be the way to do it!
    
    -- This function runs every render frame while your menu is open, it handles everything! Drawing, inputs, etc.
    Run = RunDSSMenu,
    -- This function runs when the menu is opened, and generally initializes the menu.
    Open = dssmod.openMenu,
    -- This function runs when the menu is closed, and generally handles storing of save data / general shut down.
    Close = CloseDSSMenu,

    -- If UseSubMenu is set to true, when other mods with UseSubMenu set to false / nil are enabled, your menu will be hidden behind an "Other Mods" button.
    -- A good idea to use to help keep menus clean if you don't expect players to use your menu very often!
    UseSubMenu = false,

    Directory = exampledirectory,
    DirectoryKey = exampledirectorykey
})