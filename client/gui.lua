-- GUI creation and management for NMT

-- Import labels from selection module (will be set after selection loads)
local function getLabels()
    return _G.NMT_LABELS or {
        ["performDeselectAll"] = "Deselect all",
        ["performDoSave"] = "Apply",
        ["performGenerate"] = "Generate",
        ["performClone"] = "Clone selected elements",
        ["otherElementsSelected"] = "Selected element(s): %s",
        ["resetInput"] = "Restore"
    }
end

-- State variables
local betweenElements = {}
local betweenPreviewElements = {}

-- Create main GUI
local function createGUI()
    local labels = getLabels()
    
    NMT.gui = {}
    -- Modern window with better positioning (moved down from title bar)
    NMT.gui.window = guiCreateWindow(0.05, 0.25, 0.28, 0.52, "Nyepping Tool", true)
    guiWindowSetMovable(NMT.gui.window, true)
    guiWindowSetSizable(NMT.gui.window, false)
    guiSetVisible(NMT.gui.window, false)

    -- Tab panel with padding from top
    NMT.gui.tabPanel = guiCreateTabPanel(0.02, 0.04, 0.96, 0.84, true, NMT.gui.window)
    NMT.gui.tabs = {}

    -- Bottom section for selection info and deselect button
    NMT.gui.labelElementsToStack = guiCreateLabel(0.02, 0.89, 0.48, 0.09, "Selected elements: 0", true, NMT.gui.window)
    guiLabelSetVerticalAlign(NMT.gui.labelElementsToStack, "center")
    guiSetFont(NMT.gui.labelElementsToStack, "default-bold-small")
    
    NMT.gui.buttonDeselectAll = guiCreateButton(0.52, 0.89, 0.46, 0.09, labels["performDeselectAll"], true, NMT.gui.window)
    guiSetEnabled(NMT.gui.buttonDeselectAll, false)
    addEventHandler("onClientGUIClick", NMT.gui.buttonDeselectAll, NMT.deselectAllElements, false)

    -- Tab 1: Transform
    NMT.gui.tabs[1] = guiCreateTab("F3+", NMT.gui.tabPanel)

    -- Position section header
    NMT.gui.labelPositionHeader = guiCreateLabel(0.02, 0.01, 0.96, 0.05, "Position", true, NMT.gui.tabs[1])
    guiSetFont(NMT.gui.labelPositionHeader, "default-bold-small")

    -- Position inputs
    NMT.gui.labelMoveX = guiCreateLabel(0.02, 0.07, 0.3, 0.06, "X", true, NMT.gui.tabs[1])
    guiLabelSetVerticalAlign(NMT.gui.labelMoveX, "center")
    NMT.gui.editMoveX = guiCreateEdit(0.02, 0.13, 0.3, 0.07, "0", true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIChanged", NMT.gui.editMoveX, NMT.moveXYZ, false)

    NMT.gui.labelMoveY = guiCreateLabel(0.35, 0.07, 0.3, 0.06, "Y", true, NMT.gui.tabs[1])
    guiLabelSetVerticalAlign(NMT.gui.labelMoveY, "center")
    NMT.gui.editMoveY = guiCreateEdit(0.35, 0.13, 0.3, 0.07, "0", true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIChanged", NMT.gui.editMoveY, NMT.moveXYZ, false)

    NMT.gui.labelMoveZ = guiCreateLabel(0.68, 0.07, 0.3, 0.06, "Z", true, NMT.gui.tabs[1])
    guiLabelSetVerticalAlign(NMT.gui.labelMoveZ, "center")
    NMT.gui.editMoveZ = guiCreateEdit(0.68, 0.13, 0.3, 0.07, "0", true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIChanged", NMT.gui.editMoveZ, NMT.moveXYZ, false)

    -- Rotation section header
    NMT.gui.labelRotationHeader = guiCreateLabel(0.02, 0.22, 0.96, 0.05, "Rotation", true, NMT.gui.tabs[1])
    guiSetFont(NMT.gui.labelRotationHeader, "default-bold-small")

    -- Rotation inputs
    NMT.gui.labelRotateX = guiCreateLabel(0.02, 0.28, 0.3, 0.06, "X", true, NMT.gui.tabs[1])
    guiLabelSetVerticalAlign(NMT.gui.labelRotateX, "center")
    NMT.gui.editRotateX = guiCreateEdit(0.02, 0.34, 0.3, 0.07, "0", true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIChanged", NMT.gui.editRotateX, NMT.rotateXYZ, false)

    NMT.gui.labelRotateY = guiCreateLabel(0.35, 0.28, 0.3, 0.06, "Y", true, NMT.gui.tabs[1])
    guiLabelSetVerticalAlign(NMT.gui.labelRotateY, "center")
    NMT.gui.editRotateY = guiCreateEdit(0.35, 0.34, 0.3, 0.07, "0", true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIChanged", NMT.gui.editRotateY, NMT.rotateXYZ, false)

    NMT.gui.labelRotateZ = guiCreateLabel(0.68, 0.28, 0.3, 0.06, "Z", true, NMT.gui.tabs[1])
    guiLabelSetVerticalAlign(NMT.gui.labelRotateZ, "center")
    NMT.gui.editRotateZ = guiCreateEdit(0.68, 0.34, 0.3, 0.07, "0", true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIChanged", NMT.gui.editRotateZ, NMT.rotateXYZ, false)

    -- Properties section header
    NMT.gui.labelPropertiesHeader = guiCreateLabel(0.02, 0.43, 0.96, 0.05, "Properties", true, NMT.gui.tabs[1])
    guiSetFont(NMT.gui.labelPropertiesHeader, "default-bold-small")

    -- Properties inputs
    NMT.gui.labelModel = guiCreateLabel(0.02, 0.49, 0.3, 0.06, "Model", true, NMT.gui.tabs[1])
    guiLabelSetVerticalAlign(NMT.gui.labelModel, "center")
    NMT.gui.editModel = guiCreateEdit(0.02, 0.55, 0.3, 0.07, "3458", true, NMT.gui.tabs[1])

    NMT.gui.labelScale = guiCreateLabel(0.35, 0.49, 0.3, 0.06, "Scale", true, NMT.gui.tabs[1])
    guiLabelSetVerticalAlign(NMT.gui.labelScale, "center")
    NMT.gui.editScale = guiCreateEdit(0.35, 0.55, 0.3, 0.07, "1", true, NMT.gui.tabs[1])

    -- Checkboxes
    NMT.gui.checkboxCollisions = guiCreateCheckBox(0.02, 0.64, 0.46, 0.06, "Collisions", true, true, NMT.gui.tabs[1])
    NMT.gui.checkboxDoublesided = guiCreateCheckBox(0.52, 0.64, 0.46, 0.06, "Doublesided", true, true, NMT.gui.tabs[1])

    -- Action buttons (2 columns)
    NMT.gui.buttonApplyXYZ = guiCreateButton(0.02, 0.72, 0.48, 0.08, "Apply Transform", true, NMT.gui.tabs[1])
    guiSetEnabled(NMT.gui.buttonApplyXYZ, false)
    addEventHandler("onClientGUIClick", NMT.gui.buttonApplyXYZ, NMT.saveXYZ, false)

    NMT.gui.buttonResetInput = guiCreateButton(0.52, 0.72, 0.46, 0.08, labels["resetInput"], true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIClick", NMT.gui.buttonResetInput, NMT.resetGUIInput, false)

    NMT.gui.buttonApplyProperties = guiCreateButton(0.02, 0.82, 0.48, 0.08, "Apply Properties", true, NMT.gui.tabs[1])
    guiSetEnabled(NMT.gui.buttonApplyProperties, false)
    addEventHandler("onClientGUIClick", NMT.gui.buttonApplyProperties, NMT.setProperties, false)

    NMT.gui.buttonClone = guiCreateButton(0.52, 0.82, 0.46, 0.08, labels["performClone"], true, NMT.gui.tabs[1])
    guiSetEnabled(NMT.gui.buttonClone, false)
    addEventHandler("onClientGUIClick", NMT.gui.buttonClone, NMT.clone, false)

    -- Tab 2: Continuous duplication
    NMT.gui.tabs[2] = guiCreateTab("Duplicate", NMT.gui.tabPanel)

    -- Position section
    NMT.gui.labelDupPosHeader = guiCreateLabel(0.02, 0.01, 0.96, 0.05, "Position Offset", true, NMT.gui.tabs[2])
    guiSetFont(NMT.gui.labelDupPosHeader, "default-bold-small")

    NMT.gui.labelAddMoveX = guiCreateLabel(0.02, 0.07, 0.3, 0.06, "X", true, NMT.gui.tabs[2])
    guiLabelSetVerticalAlign(NMT.gui.labelAddMoveX, "center")
    NMT.gui.editAddMoveX = guiCreateEdit(0.02, 0.13, 0.3, 0.07, "0", true, NMT.gui.tabs[2])

    NMT.gui.labelAddMoveY = guiCreateLabel(0.35, 0.07, 0.3, 0.06, "Y", true, NMT.gui.tabs[2])
    guiLabelSetVerticalAlign(NMT.gui.labelAddMoveY, "center")
    NMT.gui.editAddMoveY = guiCreateEdit(0.35, 0.13, 0.3, 0.07, "0", true, NMT.gui.tabs[2])

    NMT.gui.labelAddMoveZ = guiCreateLabel(0.68, 0.07, 0.3, 0.06, "Z", true, NMT.gui.tabs[2])
    guiLabelSetVerticalAlign(NMT.gui.labelAddMoveZ, "center")
    NMT.gui.editAddMoveZ = guiCreateEdit(0.68, 0.13, 0.3, 0.07, "0", true, NMT.gui.tabs[2])

    -- Rotation section
    NMT.gui.labelDupRotHeader = guiCreateLabel(0.02, 0.22, 0.96, 0.05, "Rotation Offset", true, NMT.gui.tabs[2])
    guiSetFont(NMT.gui.labelDupRotHeader, "default-bold-small")

    NMT.gui.labelAddRotateX = guiCreateLabel(0.02, 0.28, 0.3, 0.06, "X", true, NMT.gui.tabs[2])
    guiLabelSetVerticalAlign(NMT.gui.labelAddRotateX, "center")
    NMT.gui.editAddRotateX = guiCreateEdit(0.02, 0.34, 0.3, 0.07, "0", true, NMT.gui.tabs[2])

    NMT.gui.labelAddRotateY = guiCreateLabel(0.35, 0.28, 0.3, 0.06, "Y", true, NMT.gui.tabs[2])
    guiLabelSetVerticalAlign(NMT.gui.labelAddRotateY, "center")
    NMT.gui.editAddRotateY = guiCreateEdit(0.35, 0.34, 0.3, 0.07, "0", true, NMT.gui.tabs[2])

    NMT.gui.labelAddRotateZ = guiCreateLabel(0.68, 0.28, 0.3, 0.06, "Z", true, NMT.gui.tabs[2])
    guiLabelSetVerticalAlign(NMT.gui.labelAddRotateZ, "center")
    NMT.gui.editAddRotateZ = guiCreateEdit(0.68, 0.34, 0.3, 0.07, "0", true, NMT.gui.tabs[2])

    -- Multiplier
    NMT.gui.labelMultiplier = guiCreateLabel(0.02, 0.43, 0.4, 0.06, "Count", true, NMT.gui.tabs[2])
    guiLabelSetVerticalAlign(NMT.gui.labelMultiplier, "center")
    NMT.gui.editMultiplier = guiCreateEdit(0.44, 0.43, 0.54, 0.07, "5", true, NMT.gui.tabs[2])

    -- Buttons
    NMT.gui.buttonGenerate = guiCreateButton(0.02, 0.73, 0.96, 0.09, labels["performGenerate"], true, NMT.gui.tabs[2])
    addEventHandler("onClientGUIClick", NMT.gui.buttonGenerate, NMT.generateDuplicates, false)
    guiSetEnabled(NMT.gui.buttonGenerate, false)

    NMT.gui.buttonDuplicateUndo = guiCreateButton(0.02, 0.84, 0.96, 0.09, "Undo Last", true, NMT.gui.tabs[2])
    addEventHandler("onClientGUIClick", NMT.gui.buttonDuplicateUndo, function()
        local duplicateElementList = _G.duplicateElementList or {}
        local index = #duplicateElementList
        if index == 0 then
            outputChatBox("NMT: Nothing to undo", 255, 0, 0)
            return
        end
        triggerServerEvent("nmt:destroyElements", localPlayer, duplicateElementList[index])
        table.remove(duplicateElementList, index)
        outputChatBox("NMT: Undone last duplication", 0, 255, 0)
    end, false)

    -- Tab 3: Between
    NMT.gui.tabs[3] = guiCreateTab("Between", NMT.gui.tabPanel)

    NMT.gui.labelBetweenInfo = guiCreateLabel(0.02, 0.02, 0.96, 0.16, "Select 2+ elements with Q\nConnects in selection order\nRecommended limit: 4 objects", true, NMT.gui.tabs[3])
    guiLabelSetVerticalAlign(NMT.gui.labelBetweenInfo, "center")

    NMT.gui.labelBetweenAmount = guiCreateLabel(0.02, 0.20, 0.3, 0.07, "Amount", true, NMT.gui.tabs[3])
    guiLabelSetVerticalAlign(NMT.gui.labelBetweenAmount, "center")
    NMT.gui.editBetweenAmount = guiCreateEdit(0.35, 0.20, 0.63, 0.08, "5", true, NMT.gui.tabs[3])

    NMT.gui.buttonBetweenPreview = guiCreateButton(0.02, 0.62, 0.48, 0.09, "Preview", true, NMT.gui.tabs[3])
    addEventHandler("onClientGUIClick", NMT.gui.buttonBetweenPreview, NMT.previewBetween, false)

    NMT.gui.buttonBetweenClear = guiCreateButton(0.52, 0.62, 0.46, 0.09, "Clear Preview", true, NMT.gui.tabs[3])
    addEventHandler("onClientGUIClick", NMT.gui.buttonBetweenClear, NMT.clearBetweenPreview, false)

    NMT.gui.buttonBetweenGenerate = guiCreateButton(0.02, 0.73, 0.96, 0.09, "Generate", true, NMT.gui.tabs[3])
    addEventHandler("onClientGUIClick", NMT.gui.buttonBetweenGenerate, NMT.generateBetween, false)

    NMT.gui.buttonBetweenUndo = guiCreateButton(0.02, 0.84, 0.96, 0.09, "Undo Last", true, NMT.gui.tabs[3])
    addEventHandler("onClientGUIClick", NMT.gui.buttonBetweenUndo, function()
        local betweenElementList = _G.betweenElementList or {}
        local index = #betweenElementList
        if index == 0 then
            outputChatBox("NMT: Nothing to undo", 255, 0, 0)
            return
        end
        triggerServerEvent("nmt:destroyElements", localPlayer, betweenElementList[index])
        table.remove(betweenElementList, index)
        outputChatBox("NMT: Undone last Between generation", 0, 255, 0)
    end, false)

    -- Tab 4: AutoShade
    NMT.gui.tabs[4] = guiCreateTab("Shade+", NMT.gui.tabPanel)

    NMT.gui.labelAutoShadeInfo = guiCreateLabel(0.02, 0.01, 0.96, 0.06, "Select element and configure sides", true, NMT.gui.tabs[4])
    guiSetFont(NMT.gui.labelAutoShadeInfo, "default-bold-small")

    -- Layout
    local c1, c2 = 0.02, 0.52
    local rowH, gap, baseY = 0.07, 0.015, 0.09
    local function ry(i) return baseY + (i-1)*(rowH+gap) end

    -- Sides
    NMT.gui.checkboxShadeLeft = guiCreateCheckBox(c1, ry(1), 0.48, rowH, "Left", false, true, NMT.gui.tabs[4])
    NMT.gui.checkboxShadeRight = guiCreateCheckBox(c2, ry(1), 0.46, rowH, "Right", false, true, NMT.gui.tabs[4])
    NMT.gui.checkboxShadeBottom = guiCreateCheckBox(c1, ry(2), 0.48, rowH, "Bottom", false, true, NMT.gui.tabs[4])

    -- Dropdowns
    local row3Y = ry(3)
    NMT.gui.labelShadeFront = guiCreateLabel(c1, row3Y, 0.18, rowH, "Front", true, NMT.gui.tabs[4])
    guiLabelSetVerticalAlign(NMT.gui.labelShadeFront, "center")
    NMT.gui.comboShadeFront = guiCreateComboBox(c1 + 0.20, row3Y, 0.78, 0.20, "None", true, NMT.gui.tabs[4])
    guiComboBoxAddItem(NMT.gui.comboShadeFront, "None")
    for _, obj in ipairs(NMT.autoShadeObjects.front) do
        guiComboBoxAddItem(NMT.gui.comboShadeFront, obj.name)
    end
    guiComboBoxSetSelected(NMT.gui.comboShadeFront, 0)

    local row4Y = ry(4)
    NMT.gui.labelShadeBack = guiCreateLabel(c1, row4Y, 0.18, rowH, "Back", true, NMT.gui.tabs[4])
    guiLabelSetVerticalAlign(NMT.gui.labelShadeBack, "center")
    NMT.gui.comboShadeBack = guiCreateComboBox(c1 + 0.20, row4Y, 0.78, 0.20, "None", true, NMT.gui.tabs[4])
    guiComboBoxAddItem(NMT.gui.comboShadeBack, "None")
    for _, obj in ipairs(NMT.autoShadeObjects.back) do
        guiComboBoxAddItem(NMT.gui.comboShadeBack, obj.name)
    end
    guiComboBoxSetSelected(NMT.gui.comboShadeBack, 0)

    -- Type
    NMT.gui.labelShadeType = guiCreateLabel(c1, ry(5), 0.96, rowH, "Shade Type", true, NMT.gui.tabs[4])
    guiSetFont(NMT.gui.labelShadeType, "default-bold-small")

    NMT.gui.radioShadeLighter = guiCreateRadioButton(c1, ry(6), 0.48, rowH, "Lighter (3458)", true, NMT.gui.tabs[4])
    guiRadioButtonSetSelected(NMT.gui.radioShadeLighter, true)
    NMT.gui.radioShadeDarker = guiCreateRadioButton(c2, ry(6), 0.46, rowH, "Darker (8558)", true, NMT.gui.tabs[4])

    -- Buttons
    NMT.gui.buttonShadeApply = guiCreateButton(0.02, 0.73, 0.96, 0.09, "Apply", true, NMT.gui.tabs[4])
    addEventHandler("onClientGUIClick", NMT.gui.buttonShadeApply, NMT.applyAutoShade, false)

    NMT.gui.buttonAutoShadeUndo = guiCreateButton(0.02, 0.84, 0.96, 0.09, "Undo Last", true, NMT.gui.tabs[4])
    addEventHandler("onClientGUIClick", NMT.gui.buttonAutoShadeUndo, function()
        triggerServerEvent("nmt:autoShadeUndo", localPlayer)
    end, false)

    -- Tab 5: Mirror+
    NMT.gui.tabs[5] = guiCreateTab("Mirror+", NMT.gui.tabPanel)

    NMT.gui.labelMirrorPlusMainElement = guiCreateLabel(0.02, 0.02, 0.96, 0.05, "Main element: not selected", true, NMT.gui.tabs[5])
    guiLabelSetVerticalAlign(NMT.gui.labelMirrorPlusMainElement, "center")
    guiSetFont(NMT.gui.labelMirrorPlusMainElement, "default-bold-small")
    
    NMT.gui.buttonSelectMirrorPlusMainElement = guiCreateButton(0.02, 0.08, 0.96, 0.07, "Select Main Element", true, NMT.gui.tabs[5])
    addEventHandler("onClientGUIClick", NMT.gui.buttonSelectMirrorPlusMainElement, function()
        if NMT.mirrorMainElement and isElement(NMT.mirrorMainElement) then
            NMT.setMirrorMainElement(0)
            return
        end
        NMT.processingMirrorMainElementSelect = true
        guiSetText(NMT.gui.buttonSelectMirrorPlusMainElement, "Select an element...")
    end, false)

    NMT.gui.labelMirrorPlusInfo = guiCreateLabel(0.02, 0.17, 0.96, 0.06, "Select axes for position and rotation mirroring", true, NMT.gui.tabs[5])
    guiLabelSetVerticalAlign(NMT.gui.labelMirrorPlusInfo, "center")

    -- Position mirroring
    NMT.gui.labelMirrorPlusPosition = guiCreateLabel(0.02, 0.25, 0.96, 0.05, "Mirror Position", true, NMT.gui.tabs[5])
    guiSetFont(NMT.gui.labelMirrorPlusPosition, "default-bold-small")

    NMT.gui.checkMirrorPosXPlus = guiCreateCheckBox(0.05, 0.31, 0.28, 0.05, "X+", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorPosXMinus = guiCreateCheckBox(0.37, 0.31, 0.28, 0.05, "X-", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorPosYPlus = guiCreateCheckBox(0.69, 0.31, 0.28, 0.05, "Y+", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorPosYMinus = guiCreateCheckBox(0.05, 0.37, 0.28, 0.05, "Y-", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorPosZPlus = guiCreateCheckBox(0.37, 0.37, 0.28, 0.05, "Z+", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorPosZMinus = guiCreateCheckBox(0.69, 0.37, 0.28, 0.05, "Z-", false, true, NMT.gui.tabs[5])

    -- Rotation mirroring
    NMT.gui.labelMirrorPlusRotation = guiCreateLabel(0.02, 0.44, 0.96, 0.05, "Mirror Rotation", true, NMT.gui.tabs[5])
    guiSetFont(NMT.gui.labelMirrorPlusRotation, "default-bold-small")

    NMT.gui.checkMirrorRotXPlus = guiCreateCheckBox(0.05, 0.50, 0.28, 0.05, "X+", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorRotXMinus = guiCreateCheckBox(0.37, 0.50, 0.28, 0.05, "X-", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorRotYPlus = guiCreateCheckBox(0.69, 0.50, 0.28, 0.05, "Y+", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorRotYMinus = guiCreateCheckBox(0.05, 0.56, 0.28, 0.05, "Y-", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorRotZPlus = guiCreateCheckBox(0.37, 0.56, 0.28, 0.05, "Z+", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorRotZMinus = guiCreateCheckBox(0.69, 0.56, 0.28, 0.05, "Z-", false, true, NMT.gui.tabs[5])

    -- Buttons
    NMT.gui.buttonMirrorPlusPreview = guiCreateButton(0.02, 0.64, 0.48, 0.08, "Preview", true, NMT.gui.tabs[5])
    addEventHandler("onClientGUIClick", NMT.gui.buttonMirrorPlusPreview, NMT.previewMirrorPlus, false)

    NMT.gui.buttonMirrorPlusClear = guiCreateButton(0.52, 0.64, 0.46, 0.08, "Clear Preview", true, NMT.gui.tabs[5])
    addEventHandler("onClientGUIClick", NMT.gui.buttonMirrorPlusClear, NMT.clearMirrorPreview, false)

    NMT.gui.buttonMirrorPlusGenerate = guiCreateButton(0.02, 0.73, 0.96, 0.09, "Generate", true, NMT.gui.tabs[5])
    addEventHandler("onClientGUIClick", NMT.gui.buttonMirrorPlusGenerate, NMT.generateMirrorPlus, false)

    NMT.gui.buttonMirrorPlusUndo = guiCreateButton(0.02, 0.84, 0.96, 0.09, "Undo Last", true, NMT.gui.tabs[5])
    addEventHandler("onClientGUIClick", NMT.gui.buttonMirrorPlusUndo, function()
        local mirrorElementList = _G.mirrorElementList or {}
        local index = #mirrorElementList
        if index == 0 then
            outputChatBox("NMT: Nothing to undo", 255, 0, 0)
            return
        end
        triggerServerEvent("nmt:destroyElements", localPlayer, mirrorElementList[index])
        table.remove(mirrorElementList, index)
        outputChatBox("NMT: Undone last Mirror+ generation", 0, 255, 0)
    end, false)

    -- Tab 6: Settings
    NMT.gui.tabs[6] = guiCreateTab("Settings", NMT.gui.tabPanel)

    NMT.gui.labelSettingsInfo = guiCreateLabel(0.02, 0.01, 0.96, 0.05, "Settings", true, NMT.gui.tabs[6])
    guiSetFont(NMT.gui.labelSettingsInfo, "default-bold-small")

    -- Key Binds
    local yPos = 0.08
    NMT.gui.labelKeyBinds = guiCreateLabel(0.02, yPos, 0.96, 0.04, "Key Binds", true, NMT.gui.tabs[6])
    guiSetFont(NMT.gui.labelKeyBinds, "default-bold-small")

    yPos = yPos + 0.05
    NMT.gui.labelSelectKey = guiCreateLabel(0.02, yPos, 0.38, 0.045, "Select key", true, NMT.gui.tabs[6])
    guiLabelSetVerticalAlign(NMT.gui.labelSelectKey, "center")
    NMT.gui.editSelectKey = guiCreateEdit(0.42, yPos, 0.18, 0.045, NMT.settings.keyBindSelect, true, NMT.gui.tabs[6])
    guiEditSetMaxLength(NMT.gui.editSelectKey, 1)

    yPos = yPos + 0.055
    NMT.gui.labelToggleGUIKey = guiCreateLabel(0.02, yPos, 0.38, 0.045, "Toggle GUI key", true, NMT.gui.tabs[6])
    guiLabelSetVerticalAlign(NMT.gui.labelToggleGUIKey, "center")
    NMT.gui.editToggleGUIKey = guiCreateEdit(0.42, yPos, 0.18, 0.045, NMT.settings.keyBindToggleGUI, true, NMT.gui.tabs[6])
    guiEditSetMaxLength(NMT.gui.editToggleGUIKey, 1)

    -- Selection Mode
    yPos = yPos + 0.07
    NMT.gui.labelSelectionMode = guiCreateLabel(0.02, yPos, 0.96, 0.04, "Selection Mode", true, NMT.gui.tabs[6])
    guiSetFont(NMT.gui.labelSelectionMode, "default-bold-small")

    yPos = yPos + 0.05
    NMT.gui.selectionModeContainer = guiCreateLabel(0.02, yPos, 0.96, 0.10, "", true, NMT.gui.tabs[6])
    guiLabelSetColor(NMT.gui.selectionModeContainer, 0, 0, 0, 0)

    NMT.gui.radioSelectionPerObject = guiCreateRadioButton(0, 0, 1, 0.48, "Per-object (press key each time)", true, NMT.gui.selectionModeContainer)
    NMT.gui.radioSelectionToggle = guiCreateRadioButton(0, 0.52, 1, 0.48, "Toggle (press, click objects, press again)", true, NMT.gui.selectionModeContainer)

    if NMT.settings.selectionMode == "toggle" then
        guiRadioButtonSetSelected(NMT.gui.radioSelectionToggle, true)
    else
        guiRadioButtonSetSelected(NMT.gui.radioSelectionPerObject, true)
    end

    yPos = yPos + 0.11

    -- Auto-update info
    yPos = yPos + 0.03
    NMT.gui.labelAutoUpdate = guiCreateLabel(0.02, yPos, 0.96, 0.04, "Auto-updater", true, NMT.gui.tabs[6])
    guiSetFont(NMT.gui.labelAutoUpdate, "default-bold-small")

    yPos = yPos + 0.05
    NMT.gui.labelAutoUpdateInfo = guiCreateLabel(0.02, yPos, 0.96, 0.08, "Loading...", true, NMT.gui.tabs[6])
    guiLabelSetColor(NMT.gui.labelAutoUpdateInfo, 200, 200, 200)

    triggerServerEvent("nmt:requestAutoUpdateStatus", localPlayer)

    -- Apply/Reset buttons
    yPos = yPos + 0.10
    NMT.gui.buttonSaveSettings = guiCreateButton(0.02, yPos, 0.48, 0.07, "Apply Settings", true, NMT.gui.tabs[6])
    addEventHandler("onClientGUIClick", NMT.gui.buttonSaveSettings, NMT.applySettings, false)

    NMT.gui.buttonResetSettings = guiCreateButton(0.52, yPos, 0.46, 0.07, "Reset to Defaults", true, NMT.gui.tabs[6])
    addEventHandler("onClientGUIClick", NMT.gui.buttonResetSettings, NMT.resetSettings, false)
end

-- Event handler to receive auto-update status from server
addEvent("nmt:receiveAutoUpdateStatus", true)
addEventHandler("nmt:receiveAutoUpdateStatus", root, function(enabled)
    if NMT.gui and NMT.gui.labelAutoUpdateInfo then
        if enabled then
            guiSetText(NMT.gui.labelAutoUpdateInfo, "Enabled (checks hourly)\nUse /nmtupdate to check manually")
            guiLabelSetColor(NMT.gui.labelAutoUpdateInfo, 0, 255, 0)
        else
            guiSetText(NMT.gui.labelAutoUpdateInfo, "Disabled\nUse /nmtupdate to check manually")
            guiLabelSetColor(NMT.gui.labelAutoUpdateInfo, 255, 100, 0)
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

-- Bind toggle key from settings
bindKey(NMT.settings.keyBindToggleGUI, "down", NMT.toggleGUI)

addEventHandler("onClientGUIChanged", resourceRoot, function()
    if NMT and NMT.gui and (source == NMT.gui.editSelectKey or source == NMT.gui.editToggleGUIKey) then
        return
    end

    local text = guiGetText(source)
    while (text ~= "-") and (text ~= "" and not tonumber(text)) do
        text = text:sub(1, -2)
    end
    guiSetText(source, text)
end)

-- Tab switching handler
addEventHandler("onClientGUITabSwitched", resourceRoot, function(selectedTab)
    NMT.previewDuplicates(selectedTab == NMT.gui.tabs[2])
end)
