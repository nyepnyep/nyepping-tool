-- Server-side settings storage for NMT
-- Stores settings per player serial using XML files

-- Load settings for a player
addEvent("nmt:loadSettings", true)
addEventHandler("nmt:loadSettings", root, function()
    local serial = getPlayerSerial(client)
    if not serial then return end
    
    -- Load from XML file named by serial
    local fileName = "settings_" .. serial:gsub("[^%w]", "_") .. ".xml"
    local config = xmlLoadFile(fileName)
    
    local settings = {}
    if config then
        settings.keyBindSelect = xmlNodeGetAttribute(config, "keyBindSelect") or "Q"
        settings.keyBindToggleGUI = xmlNodeGetAttribute(config, "keyBindToggleGUI") or "u"
        settings.selectionMode = xmlNodeGetAttribute(config, "selectionMode") or "toggle"
        settings.autoShadeMode = xmlNodeGetAttribute(config, "autoShadeMode") or "single"
        xmlUnloadFile(config)
    else
        -- Default settings
        settings.keyBindSelect = "Q"
        settings.keyBindToggleGUI = "u"
        settings.selectionMode = "toggle"
        settings.autoShadeMode = "single"
    end
    
    -- Send back to client
    triggerClientEvent(client, "nmt:receiveSettings", client, settings)
end)

-- Save settings for a player
addEvent("nmt:saveSettings", true)
addEventHandler("nmt:saveSettings", root, function(settings)
    local serial = getPlayerSerial(client)
    if not serial or type(settings) ~= "table" then return end
    
    -- Save to XML file named by serial
    local fileName = "settings_" .. serial:gsub("[^%w]", "_") .. ".xml"
    local config = xmlLoadFile(fileName)
    
    if not config then
        config = xmlCreateFile(fileName, "settings")
    end
    
    if config then
        xmlNodeSetAttribute(config, "keyBindSelect", settings.keyBindSelect or "Q")
        xmlNodeSetAttribute(config, "keyBindToggleGUI", settings.keyBindToggleGUI or "u")
        xmlNodeSetAttribute(config, "keyBindSelectionMode", settings.selectionMode or "perObject")
        xmlNodeSetAttribute(config, "autoShadeMode", settings.autoShadeMode or "single")
        xmlSaveFile(config)
        xmlUnloadFile(config)
    end
end)
