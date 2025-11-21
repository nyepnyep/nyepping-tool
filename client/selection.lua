-- Element selection functionality for NMT

-- Labels for GUI
local labels = {
    ["performDeselectAll"] = "Deselect all",
    ["performDoSave"] = "Apply",
    ["performGenerate"] = "Generate",
    ["performClone"] = "Clone selected elements",
    ["otherElementsSelected"] = "Selected element(s): %s",
    ["resetInput"] = "Restore"
}

-- Toggle mode state
local toggleModeActive = false

-- Select an element
function NMT.selectElement(element)
    if not isElement(element) then
        return false
    end

    if not NMT.selectedElements then
        NMT.selectedElements = {}
    end

    local function updateGUI()
        local enabled = NMT.countSelectedElements() > 0
        local buttons = {NMT.gui.buttonDeselectAll, NMT.gui.buttonApplyXYZ, NMT.gui.buttonApplyProperties,
                         NMT.gui.buttonGenerate, NMT.gui.buttonClone}
        for _, button in pairs(buttons) do
            guiSetEnabled(button, enabled)
        end

        guiSetText(NMT.gui.labelElementsToStack,
            string.format(labels["otherElementsSelected"], NMT.countSelectedElements()))
    end

    if NMT.selectedElements[element] then
        NMT.selectedElements[element] = nil
        NMT.restoreElementPosition(element)
        NMT.restoreElementRotation(element)
        NMT.removeAllShadersFromElement(element)
        updateGUI()
        return
    end

    NMT.selectedElements[element] = true
    NMT.applySelectedShaderToElement(element, "secondary")
    NMT.backupElementPosition(element)
    NMT.backupElementRotation(element)
    NMT.moveXYZ()
    NMT.rotateXYZ()

    updateGUI()

    return true
end

-- Deselect all elements
function NMT.deselectAllElements()
    if not NMT.selectedElements then
        return
    end

    for element in pairs(NMT.selectedElements) do
        NMT.removeAllShadersFromElement(element)
        NMT.restoreElementPosition(element)
        NMT.restoreElementRotation(element)
    end

    NMT.selectedElements = {}
    elementOriginPosition = {}
    elementOriginRotation = {}

    local buttons = {NMT.gui.buttonDeselectAll, NMT.gui.buttonApplyProperties, NMT.gui.buttonApplyXYZ,
                     NMT.gui.buttonGenerate, NMT.gui.buttonClone}
    for _, button in pairs(buttons) do
        guiSetEnabled(button, false)
    end

    guiSetText(NMT.gui.labelElementsToStack, string.format(labels["otherElementsSelected"], NMT.countSelectedElements()))
    triggerEvent("nmt:onDeselectAll", localPlayer)
    exports.editor_gui:outputMessage("Deselected and restored elements", 255, 255, 0, 5000)
end

-- Count selected elements
function NMT.countSelectedElements()
    if not NMT.selectedElements then
        return 0
    end

    local k = 0
    for element in pairs(NMT.selectedElements) do
        k = k + 1
    end
    return k
end

-- Handle editor element selection
addEvent("onClientElementSelect")
addEventHandler("onClientElementSelect", root, function()
    local editorSelectedElement = source
    if not isElement(editorSelectedElement) then
        return false
    end

    if NMT.processingMirrorMainElementSelect then
        NMT.setMirrorMainElement(editorSelectedElement)
        NMT.processingMirrorMainElementSelect = nil
        return true
    end

    -- Toggle mode: select elements when clicking on them
    if toggleModeActive then
        NMT.selectElement(editorSelectedElement)
    end

    return true
end)

-- Key handler for selection
function NMT.selectKeyHandler()
    -- Check for deselect modifier
    local deselectModifier = NMT.settings.deselectModifier or "none"
    
    if deselectModifier ~= "none" then
        local modifierPressed = false
        
        if deselectModifier == "shift" and (getKeyState("lshift") or getKeyState("rshift")) then
            modifierPressed = true
        elseif deselectModifier == "ctrl" and (getKeyState("lctrl") or getKeyState("rctrl")) then
            modifierPressed = true
        end
        
        if modifierPressed then
            if NMT.deselectAllElements then
                NMT.deselectAllElements()
                local modName = deselectModifier:sub(1,1):upper() .. deselectModifier:sub(2)
                exports.editor_gui:outputMessage("Deselected all elements (" .. modName .. " + " .. NMT.settings.keyBindSelect:upper() .. ")", 255, 255, 0, 3500)
            end
            return
        end
    end
    
    -- Ignore if any modifier keys are pressed (to avoid conflicts) BUT only if they're not the configured deselect modifier
    local hasShift = getKeyState("lshift") or getKeyState("rshift")
    local hasCtrl = getKeyState("lctrl") or getKeyState("rctrl")
    local hasAlt = getKeyState("lalt") or getKeyState("ralt")
    
    -- Only ignore modifiers that aren't the deselect modifier (Alt always blocks since it's not an option)
    if (hasShift and deselectModifier ~= "shift") or (hasCtrl and deselectModifier ~= "ctrl") or hasAlt then
        return
    end
    
    -- Toggle mode: pressing the key toggles selection mode on/off
    if NMT.settings.selectionMode == "toggle" then
        toggleModeActive = not toggleModeActive
        if toggleModeActive then
            exports.editor_gui:outputMessage("Selection mode: ON (click elements)", 0, 255, 0, 5000)
        else
            exports.editor_gui:outputMessage("Selection mode: OFF", 255, 255, 0, 3000)
        end
        return
    end

    -- Per-object mode: select the currently selected element
    local editorSelectedElement = exports.editor_main:getSelectedElement()
    if not editorSelectedElement or not isElement(editorSelectedElement) then
        return false
    end

    NMT.selectElement(editorSelectedElement)
end

-- Reset toggle mode when settings change
addEvent("nmt:resetToggleMode", true)
addEventHandler("nmt:resetToggleMode", root, function()
    toggleModeActive = false
end)

-- Export labels for use in other modules
_G.NMT_LABELS = labels
