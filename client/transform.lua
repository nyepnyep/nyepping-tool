-- Transform (position/rotation) functionality for NMT

-- Move elements along XYZ axes
function NMT.moveXYZ()
    if not NMT.selectedElements then
        return
    end

    local addx = tonumber(guiGetText(NMT.gui.editMoveX)) or 0
    local addy = tonumber(guiGetText(NMT.gui.editMoveY)) or 0
    local addz = tonumber(guiGetText(NMT.gui.editMoveZ)) or 0
    local elementVector = Vector3(addx, addy, addz)

    for element in pairs(NMT.selectedElements) do
        if isElement(element) then
            local originPosition = elementOriginPosition[element]
            if type(originPosition) == "userdata" and originPosition.transformPosition and
                type(originPosition.transformPosition) == "function" then
                local success, positionVector = pcall(originPosition.transformPosition, originPosition, elementVector)
                if success and positionVector and positionVector.x and positionVector.y and positionVector.z then
                    exports.edf:edfSetElementPosition(element, positionVector.x, positionVector.y, positionVector.z)
                end
            end
        end
    end
end

-- Rotate elements along XYZ axes
function NMT.rotateXYZ()
    if not NMT.selectedElements then
        return
    end

    local addx = tonumber(guiGetText(NMT.gui.editRotateX)) or 0
    local addy = tonumber(guiGetText(NMT.gui.editRotateY)) or 0
    local addz = tonumber(guiGetText(NMT.gui.editRotateZ)) or 0

    for element in pairs(NMT.selectedElements) do
        if isElement(element) then
            local originRotation = elementOriginRotation[element] or {0, 0, 0}
            local rx, ry, rz = originRotation[1], originRotation[2], originRotation[3]
            rx, ry, rz = rotateX(rx, ry, rz, addx)
            rx, ry, rz = rotateY(rx, ry, rz, addy)
            rx, ry, rz = rotateZ(rx, ry, rz, addz)
            exports.edf:edfSetElementRotation(element, rx, ry, rz)
        end
    end
end

-- Save transform changes
function NMT.saveXYZ()
    if not NMT.selectedElements then
        return
    end

    local data = {}
    for element in pairs(NMT.selectedElements) do
        if isElement(element) then
            local px, py, pz = exports.edf:edfGetElementPosition(element)
            local rx, ry, rz = exports.edf:edfGetElementRotation(element)
            table.insert(data, {element, px, py, pz, rx, ry, rz})
            NMT.backupElementPosition(element)
            NMT.backupElementRotation(element)
        end
    end

    exports.editor_gui:outputMessage("Updating " .. #data .. " element(s)", 0, 255, 0, 5000)
    triggerServerEvent("nmt:updateElements", localPlayer, data)
    NMT.resetGUIInput()
end

-- Reset GUI input fields and restore elements to original position/rotation
function NMT.resetGUIInput()
    -- Reset input fields
    guiSetText(NMT.gui.editMoveX, "0")
    guiSetText(NMT.gui.editMoveY, "0")
    guiSetText(NMT.gui.editMoveZ, "0")
    guiSetText(NMT.gui.editRotateX, "0")
    guiSetText(NMT.gui.editRotateY, "0")
    guiSetText(NMT.gui.editRotateZ, "0")
    
    -- Restore all selected elements to their original positions and rotations
    if NMT.selectedElements then
        for element in pairs(NMT.selectedElements) do
            if isElement(element) then
                NMT.restoreElementPosition(element)
                NMT.restoreElementRotation(element)
            end
        end
        
        outputChatBox("NMT: Restored elements to original position/rotation", 0, 255, 0)
    end
end

-- Set element properties
function NMT.setProperties()
    if not NMT.selectedElements then
        return
    end

    local model = tonumber(guiGetText(NMT.gui.editModel)) or nil
    if not model or not engineGetModelNameFromID(model) then
        return
    end

    local scale = tonumber(guiGetText(NMT.gui.editScale)) or 1
    scale = math.min(math.max(scale, 0), 100)
    local collisions = guiCheckBoxGetSelected(NMT.gui.checkboxCollisions)
    local doublesided = guiCheckBoxGetSelected(NMT.gui.checkboxDoublesided)

    local data = {}
    for element in pairs(NMT.selectedElements) do
        if isElement(element) then
            table.insert(data, element)
        end
    end

    exports.editor_gui:outputMessage("Updating " .. #data .. " element(s)", 0, 255, 0, 5000)
    triggerServerEvent("nmt:updateElements", localPlayer, data, model, scale, collisions, doublesided)
end

-- Clone selected elements
function NMT.clone()
    if not NMT.selectedElements then
        return
    end

    local data = {}
    for element in pairs(NMT.selectedElements) do
        if isElement(element) then
            table.insert(data, element)
        end
    end

    exports.editor_gui:outputMessage("Cloning " .. #data .. " element(s)", 0, 255, 0, 5000)
    triggerServerEvent("nmt:cloneElements", localPlayer, data)
end
