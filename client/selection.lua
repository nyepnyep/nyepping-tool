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
    -- Debug output
    outputDebugString("NMT: selectKeyHandler called. Mode: " .. tostring(NMT.settings.selectionMode))
    
    -- Toggle mode: pressing the key toggles selection mode on/off
    if NMT.settings.selectionMode == "toggle" then
        toggleModeActive = not toggleModeActive
        if toggleModeActive then
            outputChatBox("NMT: Selection mode active - click elements to select, press " .. NMT.settings.keyBindSelect .. " again to finish", 0, 255, 0)
            exports.editor_gui:outputMessage("Selection mode: ON (click elements)", 0, 255, 0, 5000)
        else
            outputChatBox("NMT: Selection mode disabled", 255, 255, 0)
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

-- Bind selection key on resource start
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
    bindKey(NMT.settings.keyBindSelect, "down", NMT.selectKeyHandler)
end)

-- Reset toggle mode when settings change
addEvent("nmt:resetToggleMode", true)
addEventHandler("nmt:resetToggleMode", root, function()
    toggleModeActive = false
end)

-- Export labels for use in other modules
_G.NMT_LABELS = labels
