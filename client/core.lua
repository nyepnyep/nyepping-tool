-- NMT (Nyeps Mapping Tool) - Client Core
-- Main initialization and global settings

_G.NMT = {}

-- Default settings
NMT.settings = {
    keyBindSelect = "Q",
    keyBindToggleGUI = "u",
    colorSelectedPrimary = {0, 1, 0, 1},     -- Green
    colorSelectedSecondary = {1, 0.6, 0, 1}, -- Orange
    autoShadeMode = "single",  -- "single" or "group"
    selectionMode = "toggle" -- "perObject" or "toggle"
}

-- AutoShade object configurations
NMT.autoShadeObjects = {
    front = {
        {
            id = "shade",
            name = "Shade",
            model = nil, -- Uses elemid parameter (3458 or 8558)
            position = Vector3(18.673532485962, 0.0049999998882413, -18.67325592041),
            rotation = {y = 90}
        },
        {
            id = "tower",
            name = "Tower",
            model = 16327,
            position = Vector3(20.214780807495, 0, -1.0640610456467),
            rotation = {y = 270},
            scale = 1.01722812,
            doublesided = true
        }
    },
    back = {
        {
            id = "shade",
            name = "Shade",
            model = nil,
            position = Vector3(-18.671627044678, 0.0048828125, -18.67325592041),
            rotation = {y = 270}
        },
        {
            id = "tower",
            name = "Tower",
            model = 16327,
            position = Vector3(-20.214780807495, 0, -1.0640610456467),
            rotation = {y = 90},
            scale = 1.01722812,
            doublesided = true
        }
    }
}

-- Initialize on resource start
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
    -- Load saved settings from server (async)
    if NMT.loadSettings then
        NMT.loadSettings()
    end
    
    exports.editor_gui:outputMessage("You are now nyepping (NMT)", 255, 137, 0, 5000)
    outputChatBox("You are now nyepping (NMT)", 255, 137, 0)
    outputChatBox("Q: select elements, U: menu", 255, 255, 255)
end)

-- Fallback: Initialize with defaults if no settings received after GUI created
addEvent("nmt:guiCreated", true)
addEventHandler("nmt:guiCreated", root, function()
    -- Wait a bit for settings to load, then initialize with current settings
    setTimer(function()
        if NMT.updateGUIWithSettings then
            NMT.updateGUIWithSettings()
        end
        
        if NMT.initializeKeyBindings then
            NMT.initializeKeyBindings()
        end
    end, 500, 1)
end)