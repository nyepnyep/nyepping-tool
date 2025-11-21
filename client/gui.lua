-- GUI creation and management for NMT (CEF Implementation)

-- State variables
local betweenElements = {}
local betweenPreviewElements = {}

-- Create main GUI
local function createGUI()
    NMT.gui = {}
    
    -- 1. Create hidden legacy GUI elements for compatibility with other scripts
    -- We create a hidden window to hold them
    local hiddenWindow = guiCreateWindow(-1000, -1000, 100, 100, "Hidden", false)
    guiSetVisible(hiddenWindow, false) -- Keep it invisible
    
    -- Helper to create hidden inputs
    local function createHiddenEdit(name, default)
        NMT.gui[name] = guiCreateEdit(0, 0, 0, 0, default or "0", false, hiddenWindow)
    end
    local function createHiddenCheckbox(name, selected)
        NMT.gui[name] = guiCreateCheckBox(0, 0, 0, 0, "cb", selected or false, false, hiddenWindow)
    end
    local function createHiddenLabel(name, text)
        NMT.gui[name] = guiCreateLabel(0, 0, 0, 0, text or "", false, hiddenWindow)
    end
    
    -- Transform Tab Inputs
    createHiddenEdit("editMoveX", "0")
    createHiddenEdit("editMoveY", "0")
    createHiddenEdit("editMoveZ", "0")
    createHiddenEdit("editRotateX", "0")
    createHiddenEdit("editRotateY", "0")
    createHiddenEdit("editRotateZ", "0")
    createHiddenEdit("editModel", "8558")
    createHiddenEdit("editScale", "1")
    createHiddenCheckbox("checkboxCollisions", true)
    createHiddenCheckbox("checkboxDoublesided", true)
    
    -- Duplicate Tab Inputs
    createHiddenEdit("editAddMoveX", "0")
    createHiddenEdit("editAddMoveY", "0")
    createHiddenEdit("editAddMoveZ", "0")
    createHiddenEdit("editAddRotateX", "0")
    createHiddenEdit("editAddRotateY", "0")
    createHiddenEdit("editAddRotateZ", "0")
    createHiddenEdit("editMultiplier", "5")
    
    -- Between Tab Inputs
    createHiddenEdit("editBetweenAmount", "5")
    
    -- Shade Tab Inputs
    createHiddenCheckbox("checkboxShadeLeft", false)
    createHiddenCheckbox("checkboxShadeRight", false)
    createHiddenCheckbox("checkboxShadeBottom", false)
    
    -- Shade Combos
    NMT.gui.comboShadeFront = guiCreateComboBox(0, 0, 0, 0, "None", false, hiddenWindow)
    guiComboBoxAddItem(NMT.gui.comboShadeFront, "None")
    for _, obj in ipairs(NMT.autoShadeObjects.front) do guiComboBoxAddItem(NMT.gui.comboShadeFront, obj.name) end
    guiComboBoxSetSelected(NMT.gui.comboShadeFront, 0)
    
    NMT.gui.comboShadeBack = guiCreateComboBox(0, 0, 0, 0, "None", false, hiddenWindow)
    guiComboBoxAddItem(NMT.gui.comboShadeBack, "None")
    for _, obj in ipairs(NMT.autoShadeObjects.back) do guiComboBoxAddItem(NMT.gui.comboShadeBack, obj.name) end
    guiComboBoxSetSelected(NMT.gui.comboShadeBack, 0)
    
    -- Shade Radios
    NMT.gui.radioShadeLighter = guiCreateRadioButton(0, 0, 0, 0, "Lighter", false, hiddenWindow)
    NMT.gui.radioShadeDarker = guiCreateRadioButton(0, 0, 0, 0, "Darker", false, hiddenWindow)
    guiRadioButtonSetSelected(NMT.gui.radioShadeLighter, true)
    
    -- Mirror+ Inputs
    createHiddenCheckbox("checkMirrorPosXPlus", false)
    createHiddenCheckbox("checkMirrorPosXMinus", false)
    createHiddenCheckbox("checkMirrorPosYPlus", false)
    createHiddenCheckbox("checkMirrorPosYMinus", false)
    createHiddenCheckbox("checkMirrorPosZPlus", false)
    createHiddenCheckbox("checkMirrorPosZMinus", false)
    
    createHiddenCheckbox("checkMirrorRotXPlus", false)
    createHiddenCheckbox("checkMirrorRotXMinus", false)
    createHiddenCheckbox("checkMirrorRotYPlus", false)
    createHiddenCheckbox("checkMirrorRotYMinus", false)
    createHiddenCheckbox("checkMirrorRotZPlus", false)
    createHiddenCheckbox("checkMirrorRotZMinus", false)
    
    -- Settings Inputs
    createHiddenEdit("editSelectKey", NMT.settings.keyBindSelect)
    createHiddenEdit("editToggleGUIKey", NMT.settings.keyBindToggleGUI)
    NMT.gui.radioSelectionPerObject = guiCreateRadioButton(0, 0, 0, 0, "Per", false, hiddenWindow)
    NMT.gui.radioSelectionToggle = guiCreateRadioButton(0, 0, 0, 0, "Toggle", false, hiddenWindow)
    if NMT.settings.selectionMode == "toggle" then
        guiRadioButtonSetSelected(NMT.gui.radioSelectionToggle, true)
    else
        guiRadioButtonSetSelected(NMT.gui.radioSelectionPerObject, true)
    end
    
    -- Labels used for status updates
    createHiddenLabel("labelElementsToStack", "Selected elements: 0")
    createHiddenLabel("labelMirrorPlusMainElement", "Main element: not selected")
    createHiddenLabel("labelAutoUpdateInfo", "Loading...")
    
    -- Buttons (needed for enabling/disabling logic in selection.lua)
    NMT.gui.buttonDeselectAll = guiCreateButton(0, 0, 0, 0, "", false, hiddenWindow)
    NMT.gui.buttonApplyXYZ = guiCreateButton(0, 0, 0, 0, "", false, hiddenWindow)
    NMT.gui.buttonApplyProperties = guiCreateButton(0, 0, 0, 0, "", false, hiddenWindow)
    NMT.gui.buttonGenerate = guiCreateButton(0, 0, 0, 0, "", false, hiddenWindow)
    NMT.gui.buttonClone = guiCreateButton(0, 0, 0, 0, "", false, hiddenWindow)
    
    -- Mock Tab Panel for compatibility
    NMT.gui.tabPanel = guiCreateTabPanel(0, 0, 0, 0, false, hiddenWindow)
    NMT.gui.tabs = {}
    NMT.gui.tabs[1] = guiCreateTab("F3+", NMT.gui.tabPanel)
    NMT.gui.tabs[2] = guiCreateTab("Duplicate", NMT.gui.tabPanel)
    NMT.gui.tabs[3] = guiCreateTab("Between", NMT.gui.tabPanel)
    NMT.gui.tabs[4] = guiCreateTab("Shade+", NMT.gui.tabPanel)
    NMT.gui.tabs[5] = guiCreateTab("Mirror+", NMT.gui.tabPanel)
    NMT.gui.tabs[6] = guiCreateTab("Settings", NMT.gui.tabPanel)
    
    -- 2. Create CEF Browser
    local screenW, screenH = guiGetScreenSize()
    local width, height = 480, 800
    local x, y = (screenW - width) / 2, (screenH - height) / 2
    
    -- Main window container for the browser
    NMT.gui.window = guiCreateWindow(x, y, width, height, "Nyepping Tool", false)
    guiWindowSetSizable(NMT.gui.window, true)
    guiSetVisible(NMT.gui.window, false)
    
    -- Browser element
    NMT.gui.browser = guiCreateBrowser(0, 25, width, height - 25, true, false, false, NMT.gui.window)
    
    -- Handle resizing
    addEventHandler("onClientGUISize", NMT.gui.window, function()
        local w, h = guiGetSize(source, false)
        guiSetSize(NMT.gui.browser, w, h - 25, false)
    end)
    local theBrowser = guiGetBrowser(NMT.gui.browser)
    
    addEventHandler("onClientBrowserCreated", theBrowser, function()
        loadBrowserURL(source, "http://mta/local/index.html")
    end)
    
    -- 3. CEF Event Handlers
    
    -- Input changes
    addEvent("nmt:inputChanged", true)
    addEventHandler("nmt:inputChanged", root, function(id, value)
        -- Map HTML IDs to NMT.gui elements
        local map = {
            moveX = "editMoveX", moveY = "editMoveY", moveZ = "editMoveZ",
            rotateX = "editRotateX", rotateY = "editRotateY", rotateZ = "editRotateZ",
            model = "editModel", scale = "editScale",
            collisions = "checkboxCollisions", doublesided = "checkboxDoublesided",
            addMoveX = "editAddMoveX", addMoveY = "editAddMoveY", addMoveZ = "editAddMoveZ",
            addRotateX = "editAddRotateX", addRotateY = "editAddRotateY", addRotateZ = "editAddRotateZ",
            multiplier = "editMultiplier", betweenAmount = "editBetweenAmount",
            shadeLeft = "checkboxShadeLeft", shadeRight = "checkboxShadeRight", shadeBottom = "checkboxShadeBottom",
            mirrorPosXPlus = "checkMirrorPosXPlus", mirrorPosXMinus = "checkMirrorPosXMinus",
            mirrorPosYPlus = "checkMirrorPosYPlus", mirrorPosYMinus = "checkMirrorPosYMinus",
            mirrorPosZPlus = "checkMirrorPosZPlus", mirrorPosZMinus = "checkMirrorPosZMinus",
            mirrorRotXPlus = "checkMirrorRotXPlus", mirrorRotXMinus = "checkMirrorRotXMinus",
            mirrorRotYPlus = "checkMirrorRotYPlus", mirrorRotYMinus = "checkMirrorRotYMinus",
            mirrorRotZPlus = "checkMirrorRotZPlus", mirrorRotZMinus = "checkMirrorRotZMinus",
            selectKey = "editSelectKey", toggleGuiKey = "editToggleGUIKey"
        }
        
        if map[id] and NMT.gui[map[id]] then
            local el = NMT.gui[map[id]]
            if getElementType(el) == "gui-edit" then
                guiSetText(el, tostring(value))
            elseif getElementType(el) == "gui-checkbox" then
                -- Convert string/number to boolean
                local boolValue = value == true or value == "true" or value == 1 or value == "1"
                guiCheckBoxSetSelected(el, boolValue)
            end
        end
        
        -- Special handling
        if id == "shadeFront" then guiComboBoxSetSelected(NMT.gui.comboShadeFront, value) end
        if id == "shadeBack" then guiComboBoxSetSelected(NMT.gui.comboShadeBack, value) end
        if id == "shadeType" then
            guiRadioButtonSetSelected(NMT.gui.radioShadeLighter, value == "lighter")
            guiRadioButtonSetSelected(NMT.gui.radioShadeDarker, value == "darker")
        end
        if id == "selectionMode" then
            guiRadioButtonSetSelected(NMT.gui.radioSelectionPerObject, value == "per-object")
            guiRadioButtonSetSelected(NMT.gui.radioSelectionToggle, value == "toggle")
        end
        
        -- Trigger logic
        if id:find("move") or id:find("rotate") then
            if not id:find("add") then NMT.moveXYZ(); NMT.rotateXYZ() end
        end
    end)
    
    -- Action events
    local actions = {
        ["nmt:applyTransform"] = NMT.saveXYZ,
        ["nmt:applyProperties"] = NMT.setProperties,
        ["nmt:clone"] = NMT.clone,
        ["nmt:resetInput"] = NMT.resetGUIInput,
        ["nmt:generate"] = NMT.generateDuplicates,
        ["nmt:duplicateUndo"] = function() 
            local list = _G.duplicateElementList or {}
            if #list > 0 then triggerServerEvent("nmt:destroyElements", localPlayer, list[#list]); table.remove(list, #list) end 
        end,
        ["nmt:betweenPreview"] = NMT.previewBetween,
        ["nmt:betweenClear"] = NMT.clearBetweenPreview,
        ["nmt:betweenGenerate"] = NMT.generateBetween,
        ["nmt:betweenUndo"] = function()
            local list = _G.betweenElementList or {}
            if #list > 0 then triggerServerEvent("nmt:destroyElements", localPlayer, list[#list]); table.remove(list, #list) end
        end,
        ["nmt:shadeApply"] = NMT.applyAutoShade,
        ["nmt:shadeUndo"] = function() triggerServerEvent("nmt:autoShadeUndo", localPlayer) end,
        ["nmt:selectMirrorMain"] = function()
            if NMT.mirrorMainElement and isElement(NMT.mirrorMainElement) then 
                NMT.setMirrorMainElement(0)
                return 
            end
            NMT.processingMirrorMainElementSelect = true
            -- Update button and label to show selection is in progress
            if NMT.gui and NMT.gui.labelMirrorPlusMainElement then
                guiSetText(NMT.gui.labelMirrorPlusMainElement, "Main element: Click an element to select...")
            end
            exports.editor_gui:outputMessage("Click an element to set as mirror main", 255, 165, 0, 5000)
        end,
        ["nmt:mirrorPreview"] = NMT.previewMirrorPlus,
        ["nmt:mirrorClear"] = NMT.clearMirrorPreview,
        ["nmt:mirrorGenerate"] = NMT.generateMirrorPlus,
        ["nmt:mirrorUndo"] = function()
            local list = _G.mirrorElementList or {}
            if #list > 0 then triggerServerEvent("nmt:destroyElements", localPlayer, list[#list]); table.remove(list, #list) end
        end,
        ["nmt:saveSettings"] = NMT.applySettings,
        ["nmt:resetSettings"] = NMT.resetSettings,
        ["nmt:deselectAll"] = NMT.deselectAllElements
    }
    
    for event, func in pairs(actions) do
        addEvent(event, true)
        addEventHandler(event, root, func)
    end
    
    addEvent("nmt:tabSwitched", true)
    addEventHandler("nmt:tabSwitched", root, function(index)
        -- Sync hidden tab panel for compatibility
        if NMT.gui.tabs[index + 1] then
            guiSetSelectedTab(NMT.gui.tabPanel, NMT.gui.tabs[index + 1])
        end
        NMT.previewDuplicates(index == 1) -- Tab 1 is Duplicate in HTML (0-indexed in JS)
    end)
    
    -- 4. Sync Loop (Update UI from Lua state)
    setTimer(function()
        if not guiGetVisible(NMT.gui.window) then return end
        
        -- Sync Selection Count
        local countText = guiGetText(NMT.gui.labelElementsToStack)
        executeBrowserJavascript(theBrowser, "document.getElementById('selectedCount').innerText = '" .. countText .. "'")
        
        -- Sync Mirror Main Element
        local mirrorText = guiGetText(NMT.gui.labelMirrorPlusMainElement)
        executeBrowserJavascript(theBrowser, "document.getElementById('mirrorMainElement').innerText = '" .. mirrorText .. "'")
        
        -- Sync Auto Update
        local updateText = guiGetText(NMT.gui.labelAutoUpdateInfo)
        executeBrowserJavascript(theBrowser, "document.getElementById('autoUpdateInfo').innerText = '" .. updateText .. "'")
        
        -- Sync Button States (Enabled/Disabled)
        local enabled = guiGetEnabled(NMT.gui.buttonDeselectAll)
        executeBrowserJavascript(theBrowser, "document.getElementById('deselectAll').disabled = " .. tostring(not enabled))
        executeBrowserJavascript(theBrowser, "document.getElementById('applyTransform').disabled = " .. tostring(not enabled))
        executeBrowserJavascript(theBrowser, "document.getElementById('applyProperties').disabled = " .. tostring(not enabled))
        executeBrowserJavascript(theBrowser, "document.getElementById('clone').disabled = " .. tostring(not enabled))
        
        -- Sync Duplicate Generate Button
        local dupEnabled = guiGetEnabled(NMT.gui.buttonGenerate)
        executeBrowserJavascript(theBrowser, "document.getElementById('generate').disabled = " .. tostring(not dupEnabled))
        
    end, 200, 0)
    
    -- Trigger event to notify that GUI has been created
    triggerEvent("nmt:guiCreated", localPlayer)
    
    -- Ensure toggle key is bound after a short delay
    setTimer(function()
        if NMT.initializeKeyBindings then
            NMT.initializeKeyBindings()
        end
    end, 1000, 1)
end

-- Event handler to receive auto-update status from server
addEvent("nmt:receiveAutoUpdateStatus", true)
addEventHandler("nmt:receiveAutoUpdateStatus", root, function(enabled)
    if NMT.gui and NMT.gui.labelAutoUpdateInfo then
        if enabled then
            guiSetText(NMT.gui.labelAutoUpdateInfo, "Enabled (checks hourly)\nUse /nmtupdate to check manually")
        else
            guiSetText(NMT.gui.labelAutoUpdateInfo, "Disabled\nUse /nmtupdate to check manually")
        end
    end
end)

-- Initialize GUI on resource start
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), createGUI)

-- Toggle GUI visibility
function NMT.toggleGUI()
    local visible = guiGetVisible(NMT.gui.window)
    guiSetVisible(NMT.gui.window, not visible)
    triggerEvent("nmt:onGUIToggle", localPlayer, not visible)
end

addEventHandler("onClientGUIChanged", resourceRoot, function()
    -- Legacy handler, kept empty or minimal if needed
end)
