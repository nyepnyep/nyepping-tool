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
    NMT.gui.window = guiCreateWindow(0.05, 0.2, 0.25, 0.5, "nyepping tool (nmt)", true)
    guiWindowSetMovable(NMT.gui.window, true)
    guiWindowSetSizable(NMT.gui.window, false)
    guiSetVisible(NMT.gui.window, false)

    NMT.gui.tabPanel = guiCreateTabPanel(0, 0.02, 1, 0.88, true, NMT.gui.window)
    NMT.gui.tabs = {}

    -- Bottom section for selection info and deselect button
    NMT.gui.labelElementsToStack = guiCreateLabel(0.02, 0.91, 0.48, 0.07, "Selected elements: 0", true, NMT.gui.window)
    guiLabelSetVerticalAlign(NMT.gui.labelElementsToStack, "center")
    NMT.gui.buttonDeselectAll = guiCreateButton(0.5, 0.91, 0.48, 0.07, labels["performDeselectAll"], true, NMT.gui.window)
    guiSetEnabled(NMT.gui.buttonDeselectAll, false)
    addEventHandler("onClientGUIClick", NMT.gui.buttonDeselectAll, NMT.deselectAllElements, false)
    NMT.gui.tabs = {}

    -- Tab 1: Transform
    NMT.gui.tabs[1] = guiCreateTab("Transform", NMT.gui.tabPanel)

    -- Position inputs
    NMT.gui.labelMoveX = guiCreateLabel(0.02, 0.02, 0.3, 0.08, "position (x):", true, NMT.gui.tabs[1])
    guiLabelSetHorizontalAlign(NMT.gui.labelMoveX, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelMoveX, "center")
    NMT.gui.editMoveX = guiCreateEdit(0.02, 0.1, 0.3, 0.08, "0", true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIChanged", NMT.gui.editMoveX, NMT.moveXYZ, false)

    NMT.gui.labelMoveY = guiCreateLabel(0.35, 0.02, 0.3, 0.08, "position (y):", true, NMT.gui.tabs[1])
    guiLabelSetHorizontalAlign(NMT.gui.labelMoveY, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelMoveY, "center")
    NMT.gui.editMoveY = guiCreateEdit(0.35, 0.1, 0.3, 0.08, "0", true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIChanged", NMT.gui.editMoveY, NMT.moveXYZ, false)

    NMT.gui.labelMoveZ = guiCreateLabel(0.68, 0.02, 0.3, 0.08, "position (z):", true, NMT.gui.tabs[1])
    guiLabelSetHorizontalAlign(NMT.gui.labelMoveZ, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelMoveZ, "center")
    NMT.gui.editMoveZ = guiCreateEdit(0.68, 0.1, 0.3, 0.08, "0", true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIChanged", NMT.gui.editMoveZ, NMT.moveXYZ, false)

    -- Rotation inputs
    NMT.gui.labelRotateX = guiCreateLabel(0.02, 0.19, 0.3, 0.08, "rotation (x):", true, NMT.gui.tabs[1])
    guiLabelSetHorizontalAlign(NMT.gui.labelRotateX, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelRotateX, "center")
    NMT.gui.editRotateX = guiCreateEdit(0.02, 0.27, 0.3, 0.08, "0", true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIChanged", NMT.gui.editRotateX, NMT.rotateXYZ, false)

    NMT.gui.labelRotateY = guiCreateLabel(0.35, 0.19, 0.3, 0.08, "rotation (y):", true, NMT.gui.tabs[1])
    guiLabelSetHorizontalAlign(NMT.gui.labelRotateY, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelRotateY, "center")
    NMT.gui.editRotateY = guiCreateEdit(0.35, 0.27, 0.3, 0.08, "0", true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIChanged", NMT.gui.editRotateY, NMT.rotateXYZ, false)

    NMT.gui.labelRotateZ = guiCreateLabel(0.68, 0.19, 0.3, 0.08, "rotation (z):", true, NMT.gui.tabs[1])
    guiLabelSetHorizontalAlign(NMT.gui.labelRotateZ, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelRotateZ, "center")
    NMT.gui.editRotateZ = guiCreateEdit(0.68, 0.27, 0.3, 0.08, "0", true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIChanged", NMT.gui.editRotateZ, NMT.rotateXYZ, false)

    -- Properties section
    NMT.gui.labelModel = guiCreateLabel(0.02, 0.38, 0.3, 0.08, "model:", true, NMT.gui.tabs[1])
    guiLabelSetHorizontalAlign(NMT.gui.labelModel, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelModel, "center")
    NMT.gui.editModel = guiCreateEdit(0.02, 0.46, 0.3, 0.08, "3458", true, NMT.gui.tabs[1])

    NMT.gui.labelScale = guiCreateLabel(0.35, 0.38, 0.3, 0.08, "scale:", true, NMT.gui.tabs[1])
    guiLabelSetHorizontalAlign(NMT.gui.labelScale, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelScale, "center")
    NMT.gui.editScale = guiCreateEdit(0.35, 0.46, 0.3, 0.08, "1", true, NMT.gui.tabs[1])

    NMT.gui.checkboxCollisions = guiCreateCheckBox(0.02, 0.56, 0.3, 0.08, "Collisions", true, true, NMT.gui.tabs[1])
    NMT.gui.checkboxDoublesided = guiCreateCheckBox(0.35, 0.56, 0.3, 0.08, "Doublesided", true, true, NMT.gui.tabs[1])

    -- Transform section buttons
    NMT.gui.labelTransform = guiCreateLabel(0.02, 0.66, 0.46, 0.06, "Transform:", true, NMT.gui.tabs[1])
    guiLabelSetVerticalAlign(NMT.gui.labelTransform, "center")
    guiSetFont(NMT.gui.labelTransform, "default-bold-small")

    NMT.gui.buttonApplyXYZ = guiCreateButton(0.02, 0.74, 0.46, 0.08, "Apply Transform", true, NMT.gui.tabs[1])
    guiSetEnabled(NMT.gui.buttonApplyXYZ, false)
    addEventHandler("onClientGUIClick", NMT.gui.buttonApplyXYZ, NMT.saveXYZ, false)

    NMT.gui.buttonResetInput = guiCreateButton(0.02, 0.85, 0.46, 0.08, labels["resetInput"], true, NMT.gui.tabs[1])
    addEventHandler("onClientGUIClick", NMT.gui.buttonResetInput, NMT.resetGUIInput, false)

    -- Properties & Other section buttons
    NMT.gui.labelOther = guiCreateLabel(0.52, 0.66, 0.46, 0.06, "Properties & Other:", true, NMT.gui.tabs[1])
    guiLabelSetVerticalAlign(NMT.gui.labelOther, "center")
    guiSetFont(NMT.gui.labelOther, "default-bold-small")

    NMT.gui.buttonApplyProperties = guiCreateButton(0.52, 0.74, 0.46, 0.08, "Apply Properties", true, NMT.gui.tabs[1])
    guiSetEnabled(NMT.gui.buttonApplyProperties, false)
    addEventHandler("onClientGUIClick", NMT.gui.buttonApplyProperties, NMT.setProperties, false)

    NMT.gui.buttonClone = guiCreateButton(0.52, 0.85, 0.46, 0.08, labels["performClone"], true, NMT.gui.tabs[1])
    guiSetEnabled(NMT.gui.buttonClone, false)
    addEventHandler("onClientGUIClick", NMT.gui.buttonClone, NMT.clone, false)

    -- Tab 2: Continuous duplication
    NMT.gui.tabs[2] = guiCreateTab("Continuous duplication", NMT.gui.tabPanel)

    -- Position inputs
    NMT.gui.labelAddMoveX = guiCreateLabel(0.02, 0.02, 0.3, 0.08, "position (x):", true, NMT.gui.tabs[2])
    guiLabelSetHorizontalAlign(NMT.gui.labelAddMoveX, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelAddMoveX, "center")
    NMT.gui.editAddMoveX = guiCreateEdit(0.02, 0.1, 0.3, 0.08, "0", true, NMT.gui.tabs[2])

    NMT.gui.labelAddMoveY = guiCreateLabel(0.35, 0.02, 0.3, 0.08, "position (y):", true, NMT.gui.tabs[2])
    guiLabelSetHorizontalAlign(NMT.gui.labelAddMoveY, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelAddMoveY, "center")
    NMT.gui.editAddMoveY = guiCreateEdit(0.35, 0.1, 0.3, 0.08, "0", true, NMT.gui.tabs[2])

    NMT.gui.labelAddMoveZ = guiCreateLabel(0.68, 0.02, 0.3, 0.08, "position (z):", true, NMT.gui.tabs[2])
    guiLabelSetHorizontalAlign(NMT.gui.labelAddMoveZ, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelAddMoveZ, "center")
    NMT.gui.editAddMoveZ = guiCreateEdit(0.68, 0.1, 0.3, 0.08, "0", true, NMT.gui.tabs[2])

    -- Rotation inputs
    NMT.gui.labelAddRotateX = guiCreateLabel(0.02, 0.19, 0.3, 0.08, "rotation (x):", true, NMT.gui.tabs[2])
    guiLabelSetHorizontalAlign(NMT.gui.labelAddRotateX, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelAddRotateX, "center")
    NMT.gui.editAddRotateX = guiCreateEdit(0.02, 0.27, 0.3, 0.08, "0", true, NMT.gui.tabs[2])

    NMT.gui.labelAddRotateY = guiCreateLabel(0.35, 0.19, 0.3, 0.08, "rotation (y):", true, NMT.gui.tabs[2])
    guiLabelSetHorizontalAlign(NMT.gui.labelAddRotateY, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelAddRotateY, "center")
    NMT.gui.editAddRotateY = guiCreateEdit(0.35, 0.27, 0.3, 0.08, "0", true, NMT.gui.tabs[2])

    NMT.gui.labelAddRotateZ = guiCreateLabel(0.68, 0.19, 0.3, 0.08, "rotation (z):", true, NMT.gui.tabs[2])
    guiLabelSetHorizontalAlign(NMT.gui.labelAddRotateZ, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelAddRotateZ, "center")
    NMT.gui.editAddRotateZ = guiCreateEdit(0.68, 0.27, 0.3, 0.08, "0", true, NMT.gui.tabs[2])

    -- Multiplier input
    NMT.gui.labelMultiplier = guiCreateLabel(0.02, 0.36, 0.3, 0.08, "object count:", true, NMT.gui.tabs[2])
    guiLabelSetHorizontalAlign(NMT.gui.labelMultiplier, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelMultiplier, "center")
    NMT.gui.editMultiplier = guiCreateEdit(0.02, 0.44, 0.3, 0.08, "5", true, NMT.gui.tabs[2])

    -- Submits
    NMT.gui.buttonGenerate = guiCreateButton(0.02, 0.74, 0.96, 0.1, labels["performGenerate"], true, NMT.gui.tabs[2])
    addEventHandler("onClientGUIClick", NMT.gui.buttonGenerate, NMT.generateDuplicates, false)

    NMT.gui.buttonDuplicateUndo = guiCreateButton(0.02, 0.85, 0.96, 0.1, "Undo last", true, NMT.gui.tabs[2])
    addEventHandler("onClientGUIClick", NMT.gui.buttonDuplicateUndo, function()
        local duplicateElementList = _G.duplicateElementList or {}
        local index = #duplicateElementList
        if index == 0 then
            outputChatBox("NMT: Nothing to undo", 255, 0, 0)
            return
        end
        triggerServerEvent("nmt:destroyElements", localPlayer, duplicateElementList[index])
        table.remove(duplicateElementList, index)
        outputChatBox("NMT: Undone last Continuous duplication", 0, 255, 0)
    end, false)

    -- Tab 3: Between
    NMT.gui.tabs[3] = guiCreateTab("Between", NMT.gui.tabPanel)

    NMT.gui.labelBetweenInfo = guiCreateLabel(0.02, 0.05, 0.96, 0.15, "Use Q key to select 2+ elements.\nObjects will be connected in selection order\nto form outer edges, when it works at least.\nDon't go above 4 objects for now.", true, NMT.gui.tabs[3])
    guiLabelSetHorizontalAlign(NMT.gui.labelBetweenInfo, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelBetweenInfo, "center")

    NMT.gui.labelBetweenAmount = guiCreateLabel(0.02, 0.22, 0.3, 0.08, "Amount:", true, NMT.gui.tabs[3])
    guiLabelSetHorizontalAlign(NMT.gui.labelBetweenAmount, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelBetweenAmount, "center")
    NMT.gui.editBetweenAmount = guiCreateEdit(0.35, 0.22, 0.63, 0.08, "5", true, NMT.gui.tabs[3])

    NMT.gui.buttonBetweenPreview = guiCreateButton(0.02, 0.63, 0.47, 0.1, "Preview", true, NMT.gui.tabs[3])
    addEventHandler("onClientGUIClick", NMT.gui.buttonBetweenPreview, NMT.previewBetween, false)

    NMT.gui.buttonBetweenClear = guiCreateButton(0.51, 0.63, 0.47, 0.1, "Clear preview", true, NMT.gui.tabs[3])
    addEventHandler("onClientGUIClick", NMT.gui.buttonBetweenClear, NMT.clearBetweenPreview, false)

    NMT.gui.buttonBetweenGenerate = guiCreateButton(0.02, 0.74, 0.96, 0.1, "Generate", true, NMT.gui.tabs[3])
    addEventHandler("onClientGUIClick", NMT.gui.buttonBetweenGenerate, NMT.generateBetween, false)

    NMT.gui.buttonBetweenUndo = guiCreateButton(0.02, 0.85, 0.96, 0.1, "Undo last", true, NMT.gui.tabs[3])
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
    NMT.gui.tabs[4] = guiCreateTab("AutoShade+", NMT.gui.tabPanel)

    NMT.gui.labelAutoShadeInfo = guiCreateLabel(0.02, 0.02, 0.96, 0.08, "Select an element and configure sides:", true, NMT.gui.tabs[4])
    guiLabelSetVerticalAlign(NMT.gui.labelAutoShadeInfo, "center")

    -- AutoShade layout
    local c1, c2 = 0.02, 0.52
    local rowH, gap, baseY = 0.07, 0.02, 0.12
    local function ry(i) return baseY + (i-1)*(rowH+gap) end

    -- Row 1: Left | Right
    NMT.gui.checkboxShadeLeft   = guiCreateCheckBox(c1, ry(1), 0.48, rowH, "Left", false, true, NMT.gui.tabs[4])
    NMT.gui.checkboxShadeRight  = guiCreateCheckBox(c2, ry(1), 0.46, rowH, "Right", false, true, NMT.gui.tabs[4])

    -- Row 2: Bottom
    NMT.gui.checkboxShadeBottom = guiCreateCheckBox(c1, ry(2), 0.48, rowH, "Bottom", false, true, NMT.gui.tabs[4])

    -- Row 3: Front dropdown
    local row3Y = ry(3)
    NMT.gui.labelShadeFront = guiCreateLabel(c1, row3Y, 0.20, rowH, "Front:", true, NMT.gui.tabs[4])
    guiLabelSetVerticalAlign(NMT.gui.labelShadeFront, "center")
    NMT.gui.comboShadeFront = guiCreateComboBox(c1 + 0.22, row3Y, 0.76, 0.20, "None", true, NMT.gui.tabs[4])
    guiComboBoxAddItem(NMT.gui.comboShadeFront, "None")
    for _, obj in ipairs(NMT.autoShadeObjects.front) do
        guiComboBoxAddItem(NMT.gui.comboShadeFront, obj.name)
    end
    guiComboBoxSetSelected(NMT.gui.comboShadeFront, 0)

    -- Row 4: Back dropdown
    local row4Y = ry(4)
    NMT.gui.labelShadeBack = guiCreateLabel(c1, row4Y, 0.20, rowH, "Back:", true, NMT.gui.tabs[4])
    guiLabelSetVerticalAlign(NMT.gui.labelShadeBack, "center")
    NMT.gui.comboShadeBack = guiCreateComboBox(c1 + 0.22, row4Y, 0.76, 0.20, "None", true, NMT.gui.tabs[4])
    guiComboBoxAddItem(NMT.gui.comboShadeBack, "None")
    for _, obj in ipairs(NMT.autoShadeObjects.back) do
        guiComboBoxAddItem(NMT.gui.comboShadeBack, obj.name)
    end
    guiComboBoxSetSelected(NMT.gui.comboShadeBack, 0)

    -- Row 5: Shade type label
    NMT.gui.labelShadeType = guiCreateLabel(c1, ry(5), 0.94, rowH, "Shade type:", true, NMT.gui.tabs[4])
    guiLabelSetVerticalAlign(NMT.gui.labelShadeType, "center")
    guiSetFont(NMT.gui.labelShadeType, "default-bold-small")

    -- Row 6: Radios (Lighter / Darker)
    NMT.gui.radioShadeLighter = guiCreateRadioButton(c1, ry(6), 0.48, rowH, "Lighter (3458)", true, NMT.gui.tabs[4])
    guiRadioButtonSetSelected(NMT.gui.radioShadeLighter, true)
    NMT.gui.radioShadeDarker  = guiCreateRadioButton(c2, ry(6), 0.46, rowH, "Darker (8558)", true, NMT.gui.tabs[4])

    -- Apply button below grid
    local applyY = 0.74
    NMT.gui.buttonShadeApply = guiCreateButton(0.02, applyY, 0.96, 0.1, "Apply", true, NMT.gui.tabs[4])
    addEventHandler("onClientGUIClick", NMT.gui.buttonShadeApply, NMT.applyAutoShade, false)
    
    -- Undo button
    NMT.gui.buttonAutoShadeUndo = guiCreateButton(0.02, 0.85, 0.96, 0.1, "Undo last", true, NMT.gui.tabs[4])
    addEventHandler("onClientGUIClick", NMT.gui.buttonAutoShadeUndo, function()
        local autoShadeElementList = _G.autoShadeElementList or {}
        local index = #autoShadeElementList
        if index == 0 then
            outputChatBox("NMT: Nothing to undo", 255, 0, 0)
            return
        end
        triggerServerEvent("nmt:destroyElements", localPlayer, autoShadeElementList[index])
        table.remove(autoShadeElementList, index)
        outputChatBox("NMT: Undone last AutoShade application", 0, 255, 0)
    end, false)

    -- Mirror+ tab (Multi-axis mirroring)
    NMT.gui.tabs[5] = guiCreateTab("Mirror+", NMT.gui.tabPanel)

    -- Main element selection
    NMT.gui.labelMirrorPlusMainElement = guiCreateLabel(0.02, 0.05, 0.48, 0.06, "Main element: not selected", true, NMT.gui.tabs[5])
    guiLabelSetVerticalAlign(NMT.gui.labelMirrorPlusMainElement, "center")
    NMT.gui.buttonSelectMirrorPlusMainElement = guiCreateButton(0.52, 0.05, 0.46, 0.06, "Select main element", true, NMT.gui.tabs[5])
    addEventHandler("onClientGUIClick", NMT.gui.buttonSelectMirrorPlusMainElement, function()
        if NMT.mirrorMainElement and isElement(NMT.mirrorMainElement) then
            NMT.setMirrorMainElement(0)
            return
        end

        NMT.processingMirrorMainElementSelect = true
        guiSetText(NMT.gui.buttonSelectMirrorPlusMainElement, "Select an element...")
    end, false)

    -- Info text
    NMT.gui.labelMirrorPlusInfo = guiCreateLabel(0.02, 0.13, 0.96, 0.08, "Select multiple axes for position and rotation mirroring", true, NMT.gui.tabs[5])
    guiLabelSetHorizontalAlign(NMT.gui.labelMirrorPlusInfo, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelMirrorPlusInfo, "center")

    -- Position mirroring checkboxes
    NMT.gui.labelMirrorPlusPosition = guiCreateLabel(0.02, 0.23, 0.96, 0.06, "Mirror Position:", true, NMT.gui.tabs[5])
    guiSetFont(NMT.gui.labelMirrorPlusPosition, "default-bold-small")
    
    NMT.gui.checkMirrorPosXPlus = guiCreateCheckBox(0.05, 0.30, 0.28, 0.05, "X+ (Right)", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorPosXMinus = guiCreateCheckBox(0.37, 0.30, 0.28, 0.05, "X- (Left)", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorPosYPlus = guiCreateCheckBox(0.69, 0.30, 0.28, 0.05, "Y+ (Forward)", false, true, NMT.gui.tabs[5])
    
    NMT.gui.checkMirrorPosYMinus = guiCreateCheckBox(0.05, 0.36, 0.28, 0.05, "Y- (Backward)", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorPosZPlus = guiCreateCheckBox(0.37, 0.36, 0.28, 0.05, "Z+ (Up)", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorPosZMinus = guiCreateCheckBox(0.69, 0.36, 0.28, 0.05, "Z- (Down)", false, true, NMT.gui.tabs[5])

    -- Rotation mirroring checkboxes
    NMT.gui.labelMirrorPlusRotation = guiCreateLabel(0.02, 0.44, 0.96, 0.06, "Mirror Rotation:", true, NMT.gui.tabs[5])
    guiSetFont(NMT.gui.labelMirrorPlusRotation, "default-bold-small")
    
    NMT.gui.checkMirrorRotXPlus = guiCreateCheckBox(0.05, 0.51, 0.28, 0.05, "X+ (Right)", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorRotXMinus = guiCreateCheckBox(0.37, 0.51, 0.28, 0.05, "X- (Left)", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorRotYPlus = guiCreateCheckBox(0.69, 0.51, 0.28, 0.05, "Y+ (Forward)", false, true, NMT.gui.tabs[5])
    
    NMT.gui.checkMirrorRotYMinus = guiCreateCheckBox(0.05, 0.57, 0.28, 0.05, "Y- (Backward)", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorRotZPlus = guiCreateCheckBox(0.37, 0.57, 0.28, 0.05, "Z+ (Up)", false, true, NMT.gui.tabs[5])
    NMT.gui.checkMirrorRotZMinus = guiCreateCheckBox(0.69, 0.57, 0.28, 0.05, "Z- (Down)", false, true, NMT.gui.tabs[5])

    -- Buttons
    NMT.gui.buttonMirrorPlusPreview = guiCreateButton(0.02, 0.63, 0.47, 0.1, "Preview", true, NMT.gui.tabs[5])
    addEventHandler("onClientGUIClick", NMT.gui.buttonMirrorPlusPreview, NMT.previewMirrorPlus, false)

    NMT.gui.buttonMirrorPlusClear = guiCreateButton(0.51, 0.63, 0.47, 0.1, "Clear preview", true, NMT.gui.tabs[5])
    addEventHandler("onClientGUIClick", NMT.gui.buttonMirrorPlusClear, NMT.clearMirrorPreview, false)

    NMT.gui.buttonMirrorPlusGenerate = guiCreateButton(0.02, 0.74, 0.96, 0.1, "Generate", true, NMT.gui.tabs[5])
    addEventHandler("onClientGUIClick", NMT.gui.buttonMirrorPlusGenerate, NMT.generateMirrorPlus, false)

    NMT.gui.buttonMirrorPlusUndo = guiCreateButton(0.02, 0.85, 0.96, 0.1, "Undo last", true, NMT.gui.tabs[5])
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
    
    -- Settings header
    NMT.gui.labelSettingsInfo = guiCreateLabel(0.02, 0.02, 0.96, 0.06, "Configure NMT behavior and keybinds", true, NMT.gui.tabs[6])
    guiLabelSetHorizontalAlign(NMT.gui.labelSettingsInfo, "center")
    guiLabelSetVerticalAlign(NMT.gui.labelSettingsInfo, "center")
    guiSetFont(NMT.gui.labelSettingsInfo, "default-bold-small")
    
    -- Key Binds section
    local yPos = 0.10
    NMT.gui.labelKeyBinds = guiCreateLabel(0.02, yPos, 0.96, 0.05, "Key Binds:", true, NMT.gui.tabs[6])
    guiSetFont(NMT.gui.labelKeyBinds, "default-bold-small")
    
    yPos = yPos + 0.06
    NMT.gui.labelSelectKey = guiCreateLabel(0.02, yPos, 0.40, 0.05, "Select element key:", true, NMT.gui.tabs[6])
    guiLabelSetVerticalAlign(NMT.gui.labelSelectKey, "center")
    NMT.gui.editSelectKey = guiCreateEdit(0.44, yPos, 0.20, 0.05, NMT.settings.keyBindSelect, true, NMT.gui.tabs[6])
    guiEditSetMaxLength(NMT.gui.editSelectKey, 1)
    addEventHandler("onClientGUIChanged", NMT.gui.editSelectKey, function()
        local text = guiGetText(source)
        if #text > 1 then
            guiSetText(source, string.sub(text, -1))
        end
    end, false)
    
    yPos = yPos + 0.06
    NMT.gui.labelToggleGUIKey = guiCreateLabel(0.02, yPos, 0.40, 0.05, "Toggle GUI key:", true, NMT.gui.tabs[6])
    guiLabelSetVerticalAlign(NMT.gui.labelToggleGUIKey, "center")
    NMT.gui.editToggleGUIKey = guiCreateEdit(0.44, yPos, 0.20, 0.05, NMT.settings.keyBindToggleGUI, true, NMT.gui.tabs[6])
    guiEditSetMaxLength(NMT.gui.editToggleGUIKey, 1)
    addEventHandler("onClientGUIChanged", NMT.gui.editToggleGUIKey, function()
        local text = guiGetText(source)
        if #text > 1 then
            guiSetText(source, string.sub(text, -1))
        end
    end, false)
    
    -- Selection Mode section
    yPos = yPos + 0.08
    NMT.gui.labelSelectionMode = guiCreateLabel(0.02, yPos, 0.96, 0.05, "Selection Mode:", true, NMT.gui.tabs[6])
    guiSetFont(NMT.gui.labelSelectionMode, "default-bold-small")
    
    yPos = yPos + 0.06
    -- Create container for Selection Mode radio group (visible)
    NMT.gui.selectionModeContainer = guiCreateLabel(0.02, yPos, 0.96, 0.11, "", true, NMT.gui.tabs[6])
    guiLabelSetColor(NMT.gui.selectionModeContainer, 0, 0, 0, 0) -- Transparent
    
    NMT.gui.radioSelectionPerObject = guiCreateRadioButton(0, 0, 1, 0.45, "Per-object: Press key for each object", true, NMT.gui.selectionModeContainer)
    NMT.gui.radioSelectionToggle = guiCreateRadioButton(0, 0.55, 1, 0.45, "Toggle: Press once to start, click objects, press again to confirm", true, NMT.gui.selectionModeContainer)
    
    yPos = yPos + 0.11
    
    -- Set default selection mode
    if NMT.settings.selectionMode == "toggle" then
        guiRadioButtonSetSelected(NMT.gui.radioSelectionToggle, true)
    else
        guiRadioButtonSetSelected(NMT.gui.radioSelectionPerObject, true)
    end
    
    -- AutoShade Mode section
    yPos = yPos + 0.03
    NMT.gui.labelAutoShadeMode = guiCreateLabel(0.02, yPos, 0.96, 0.05, "AutoShade Behavior:", true, NMT.gui.tabs[6])
    guiSetFont(NMT.gui.labelAutoShadeMode, "default-bold-small")
    
    yPos = yPos + 0.06
    -- Create container for AutoShade Mode radio group (visible)
    NMT.gui.autoShadeModeContainer = guiCreateLabel(0.02, yPos, 0.96, 0.11, "", true, NMT.gui.tabs[6])
    guiLabelSetColor(NMT.gui.autoShadeModeContainer, 0, 0, 0, 0) -- Transparent
    
    NMT.gui.radioAutoShadeSingle = guiCreateRadioButton(0, 0, 1, 0.45, "Apply to currently selected element only", true, NMT.gui.autoShadeModeContainer)
    NMT.gui.radioAutoShadeGroup = guiCreateRadioButton(0, 0.55, 1, 0.45, "Apply to all selected elements", true, NMT.gui.autoShadeModeContainer)
    
    yPos = yPos + 0.11
    
    -- Set default autoshade mode
    if NMT.settings.autoShadeMode == "group" then
        guiRadioButtonSetSelected(NMT.gui.radioAutoShadeGroup, true)
    else
        guiRadioButtonSetSelected(NMT.gui.radioAutoShadeSingle, true)
    end
    
    -- Auto-update section (info only, controlled server-side)
    yPos = yPos + 0.08
    NMT.gui.labelAutoUpdate = guiCreateLabel(0.02, yPos, 0.96, 0.05, "Auto-updater:", true, NMT.gui.tabs[6])
    guiSetFont(NMT.gui.labelAutoUpdate, "default-bold-small")
    
    yPos = yPos + 0.06
    NMT.gui.labelAutoUpdateInfo = guiCreateLabel(0.02, yPos, 0.96, 0.08, "Loading...", true, NMT.gui.tabs[6])
    guiLabelSetColor(NMT.gui.labelAutoUpdateInfo, 200, 200, 200)
    
    -- Request auto-update status from server
    triggerServerEvent("nmt:requestAutoUpdateStatus", localPlayer)
    
    -- Apply/Save button
    yPos = yPos + 0.10
    NMT.gui.buttonSaveSettings = guiCreateButton(0.02, yPos, 0.47, 0.08, "Apply Settings", true, NMT.gui.tabs[6])
    addEventHandler("onClientGUIClick", NMT.gui.buttonSaveSettings, NMT.applySettings, false)
    
    NMT.gui.buttonResetSettings = guiCreateButton(0.51, yPos, 0.47, 0.08, "Reset to Defaults", true, NMT.gui.tabs[6])
    addEventHandler("onClientGUIClick", NMT.gui.buttonResetSettings, NMT.resetSettings, false)
end

-- Event handler to receive auto-update status from server
addEvent("nmt:receiveAutoUpdateStatus", true)
addEventHandler("nmt:receiveAutoUpdateStatus", root, function(enabled)
    if NMT.gui and NMT.gui.labelAutoUpdateInfo then
        if enabled then
            guiSetText(NMT.gui.labelAutoUpdateInfo, "Enabled (server-side)\nAutomatically checks for updates hourly\nUse /nmtupdate to check manually")
            guiLabelSetColor(NMT.gui.labelAutoUpdateInfo, 0, 255, 0)
        else
            guiSetText(NMT.gui.labelAutoUpdateInfo, "Disabled (server-side)\nUse /nmtupdate to check manually")
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

-- Bind toggle key
bindKey("u", "down", NMT.toggleGUI)

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
