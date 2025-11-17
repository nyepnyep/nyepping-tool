-- Settings functionality for NMT

outputDebugString("[NMT] Loading settings.lua")

-- Settings functions
function NMT.applySettings()
    -- Get new key binds
    local newSelectKey = guiGetText(NMT.gui.editSelectKey)
    local newToggleKey = guiGetText(NMT.gui.editToggleGUIKey)
    
    -- Validate keys
    if newSelectKey == "" or newToggleKey == "" then
        outputChatBox("NMT: Key binds cannot be empty", 255, 0, 0)
        return
    end
    
    -- Update selection mode
    if guiRadioButtonGetSelected(NMT.gui.radioSelectionPerObject) then
        NMT.settings.selectionMode = "perObject"
        outputChatBox("NMT: Selection mode set to Per-Object", 255, 255, 255)
    elseif guiRadioButtonGetSelected(NMT.gui.radioSelectionToggle) then
        NMT.settings.selectionMode = "toggle"
        outputChatBox("NMT: Selection mode set to Toggle", 255, 255, 255)
    end
    
    -- Reset toggle mode state when switching modes
    triggerEvent("nmt:resetToggleMode", localPlayer)
    
    -- Update AutoShade mode
    if guiRadioButtonGetSelected(NMT.gui.radioAutoShadeSingle) then
        NMT.settings.autoShadeMode = "single"
    elseif guiRadioButtonGetSelected(NMT.gui.radioAutoShadeGroup) then
        NMT.settings.autoShadeMode = "group"
    end
    
    -- Update key binds if changed
    if newSelectKey ~= NMT.settings.keyBindSelect then
        unbindKey(NMT.settings.keyBindSelect, "down", NMT.selectKeyHandler)
        NMT.settings.keyBindSelect = newSelectKey
        bindKey(NMT.settings.keyBindSelect, "down", NMT.selectKeyHandler)
    end
    
    if newToggleKey ~= NMT.settings.keyBindToggleGUI then
        unbindKey(NMT.settings.keyBindToggleGUI, "down", NMT.toggleGUI)
        NMT.settings.keyBindToggleGUI = newToggleKey
        bindKey(NMT.settings.keyBindToggleGUI, "down", NMT.toggleGUI)
    end
    
    outputChatBox("NMT: Settings applied successfully", 0, 255, 0)
    exports.editor_gui:outputMessage("Settings applied", 0, 255, 0, 3000)
end

function NMT.resetSettings()
    -- Reset to defaults
    NMT.settings.keyBindSelect = "Q"
    NMT.settings.keyBindToggleGUI = "u"
    NMT.settings.colorSelectedPrimary = {0, 1, 0, 1}
    NMT.settings.colorSelectedSecondary = {1, 0.6, 0, 1}
    NMT.settings.autoShadeMode = "single"
    NMT.settings.selectionMode = "perObject"
    
    -- Update GUI
    guiSetText(NMT.gui.editSelectKey, NMT.settings.keyBindSelect)
    guiSetText(NMT.gui.editToggleGUIKey, NMT.settings.keyBindToggleGUI)
    guiRadioButtonSetSelected(NMT.gui.radioSelectionPerObject, true)
    guiRadioButtonSetSelected(NMT.gui.radioAutoShadeSingle, true)
    
    -- Re-apply
    NMT.applySettings()
    
    outputChatBox("NMT: Settings reset to defaults", 0, 255, 0)
end

outputDebugString("[NMT] Settings functions defined: applySettings=" .. tostring(NMT.applySettings) .. ", resetSettings=" .. tostring(NMT.resetSettings))
