-- Settings functionality for NMT

-- Load settings from server
function NMT.loadSettings()
    -- Request settings from server
    triggerServerEvent("nmt:loadSettings", localPlayer)
end

-- Receive settings from server
addEvent("nmt:receiveSettings", true)
addEventHandler("nmt:receiveSettings", root, function(savedSettings)
    if not savedSettings then return end
    
    -- Load key binds
    if savedSettings.keyBindSelect and savedSettings.keyBindSelect ~= "" then
        NMT.settings.keyBindSelect = savedSettings.keyBindSelect
    end
    
    if savedSettings.keyBindToggleGUI and savedSettings.keyBindToggleGUI ~= "" then
        NMT.settings.keyBindToggleGUI = savedSettings.keyBindToggleGUI
    end
    
    if savedSettings.deselectModifier then
        NMT.settings.deselectModifier = savedSettings.deselectModifier
    end
    
    -- Load selection mode
    if savedSettings.selectionMode then
        NMT.settings.selectionMode = savedSettings.selectionMode
    end
    
    -- Load autoshade mode
    if savedSettings.autoShadeMode then
        NMT.settings.autoShadeMode = savedSettings.autoShadeMode
    end
    
    -- Update GUI and bindings if they're ready
    if NMT.updateGUIWithSettings then
        NMT.updateGUIWithSettings()
    end
    if NMT.initializeKeyBindings then
        NMT.initializeKeyBindings()
    end
end)

-- Update GUI elements with current settings
function NMT.updateGUIWithSettings()
    if not NMT.gui then
        return
    end
    
    -- Update key bind inputs
    if NMT.gui.editSelectKey then
        guiSetText(NMT.gui.editSelectKey, NMT.settings.keyBindSelect)
    end
    if NMT.gui.editToggleGUIKey then
        guiSetText(NMT.gui.editToggleGUIKey, NMT.settings.keyBindToggleGUI)
    end
    if NMT.gui.comboDeselectModifier then
        local modifierIndex = 0
        if NMT.settings.deselectModifier == "shift" then modifierIndex = 1
        elseif NMT.settings.deselectModifier == "ctrl" then modifierIndex = 2
        elseif NMT.settings.deselectModifier == "alt" then modifierIndex = 3
        end
        guiComboBoxSetSelected(NMT.gui.comboDeselectModifier, modifierIndex)
    end
    
    -- Update selection mode radio buttons
    if NMT.gui.radioSelectionPerObject and NMT.gui.radioSelectionToggle then
        if NMT.settings.selectionMode == "toggle" then
            guiRadioButtonSetSelected(NMT.gui.radioSelectionToggle, true)
        else
            guiRadioButtonSetSelected(NMT.gui.radioSelectionPerObject, true)
        end
    end
    
    -- Update autoshade mode radio buttons
    if NMT.gui.radioAutoShadeSingle and NMT.gui.radioAutoShadeGroup then
        if NMT.settings.autoShadeMode == "group" then
            guiRadioButtonSetSelected(NMT.gui.radioAutoShadeGroup, true)
        else
            guiRadioButtonSetSelected(NMT.gui.radioAutoShadeSingle, true)
        end
    end
end

-- Initialize key bindings with loaded settings
function NMT.initializeKeyBindings()
    -- Bind selection key
    if NMT.selectKeyHandler then
        bindKey(NMT.settings.keyBindSelect, "down", NMT.selectKeyHandler)
    end
    
    -- Bind GUI toggle key
    if NMT.toggleGUI then
        bindKey(NMT.settings.keyBindToggleGUI, "down", NMT.toggleGUI)
    end
end

-- Save settings to server
function NMT.saveSettings()
    local settingsData = {
        keyBindSelect = NMT.settings.keyBindSelect,
        keyBindToggleGUI = NMT.settings.keyBindToggleGUI,
        deselectModifier = NMT.settings.deselectModifier,
        selectionMode = NMT.settings.selectionMode,
        autoShadeMode = NMT.settings.autoShadeMode
    }
    
    triggerServerEvent("nmt:saveSettings", localPlayer, settingsData)
    return true
end

-- Settings functions
function NMT.applySettings()
    -- Ensure GUI exists
    if not NMT.gui or not NMT.gui.editSelectKey or not NMT.gui.editToggleGUIKey then
        return
    end
    
    -- Get new key binds
    local newSelectKey = guiGetText(NMT.gui.editSelectKey)
    local newToggleKey = guiGetText(NMT.gui.editToggleGUIKey)
    
    -- Validate keys
    if newSelectKey == "" or newToggleKey == "" then
        return
    end
    
    -- Get deselect modifier
    local deselectModifier = "none"
    if NMT.gui.comboDeselectModifier then
        local selected = guiComboBoxGetSelected(NMT.gui.comboDeselectModifier)
        if selected == 1 then deselectModifier = "shift"
        elseif selected == 2 then deselectModifier = "ctrl"
        elseif selected == 3 then deselectModifier = "alt"
        end
    end
    NMT.settings.deselectModifier = deselectModifier
    
    -- Update selection mode
    if NMT.gui.radioSelectionPerObject and NMT.gui.radioSelectionToggle then
        if guiRadioButtonGetSelected(NMT.gui.radioSelectionPerObject) then
            NMT.settings.selectionMode = "perObject"
        elseif guiRadioButtonGetSelected(NMT.gui.radioSelectionToggle) then
            NMT.settings.selectionMode = "toggle"
        end
    end
    
    -- Reset toggle mode state when switching modes
    triggerEvent("nmt:resetToggleMode", localPlayer)
    
    -- Update AutoShade mode
    if NMT.gui.radioAutoShadeSingle and NMT.gui.radioAutoShadeGroup then
        if guiRadioButtonGetSelected(NMT.gui.radioAutoShadeSingle) then
            NMT.settings.autoShadeMode = "single"
        elseif guiRadioButtonGetSelected(NMT.gui.radioAutoShadeGroup) then
            NMT.settings.autoShadeMode = "group"
        end
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
    
    -- Save settings to server
    NMT.saveSettings()
    
    exports.editor_gui:outputMessage("Settings applied", 0, 255, 0, 3000)
end

function NMT.resetSettings()
    -- Ensure GUI exists
    if not NMT.gui or not NMT.gui.editSelectKey then
        return
    end
    
    -- Reset to defaults
    NMT.settings.keyBindSelect = "Q"
    NMT.settings.keyBindToggleGUI = "u"
    NMT.settings.deselectModifier = "none"
    NMT.settings.colorSelectedPrimary = {0, 1, 0, 1}
    NMT.settings.colorSelectedSecondary = {1, 0.6, 0, 1}
    NMT.settings.autoShadeMode = "single"
    NMT.settings.selectionMode = "toggle"
    
    -- Update GUI
    guiSetText(NMT.gui.editSelectKey, NMT.settings.keyBindSelect)
    guiSetText(NMT.gui.editToggleGUIKey, NMT.settings.keyBindToggleGUI)
    if NMT.gui.comboDeselectModifier then
        guiComboBoxSetSelected(NMT.gui.comboDeselectModifier, 0)
    end
    if NMT.gui.radioSelectionPerObject then
        guiRadioButtonSetSelected(NMT.gui.radioSelectionPerObject, true)
    end
    if NMT.gui.radioAutoShadeSingle then
        guiRadioButtonSetSelected(NMT.gui.radioAutoShadeSingle, true)
    end
    
    -- Re-apply
    NMT.applySettings()
end
