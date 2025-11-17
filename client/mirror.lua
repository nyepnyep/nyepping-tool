-- Mirror functionality for NMT

local mirrorPreviewElements = {}
local mirrorElementList = {}

-- Mirror functions
function NMT.setMirrorMainElement(element)
    if element == 0 then
        if NMT.mirrorMainElement and isElement(NMT.mirrorMainElement) then
            NMT.removeAllShadersFromElement(NMT.mirrorMainElement)
        end

        NMT.mirrorMainElement = nil
        guiSetText(NMT.gui.labelMirrorPlusMainElement, "Main element: not selected")
        guiSetText(NMT.gui.buttonSelectMirrorPlusMainElement, "Select Main Element")

        return true
    end

    if not isElement(element) then
        return false
    end

    -- Remove from selected elements if it was selected
    if NMT.selectedElements and NMT.selectedElements[element] then
        NMT.removeAllShadersFromElement(element)
        NMT.selectedElements[element] = nil

        local labels = _G.NMT_LABELS or {}
        guiSetText(NMT.gui.labelElementsToStack,
            string.format(labels["otherElementsSelected"] or "Selected element(s): %s", NMT.countSelectedElements()))
    end

    NMT.mirrorMainElement = element
    NMT.applySelectedShaderToElement(element, "primary")
    guiSetText(NMT.gui.labelMirrorPlusMainElement, string.format("Main element: %s", getElementID(element)))
    guiSetText(NMT.gui.buttonSelectMirrorPlusMainElement, "Reset main element")

    return true
end

-- Get selected mirror axes from checkboxes
function NMT.getMirrorPlusAxes()
    local axes = {
        position = {},
        rotation = {}
    }
    
    -- Position axes
    if guiCheckBoxGetSelected(NMT.gui.checkMirrorPosXPlus) then
        table.insert(axes.position, {axis = "x", factor = 1})
    end
    if guiCheckBoxGetSelected(NMT.gui.checkMirrorPosXMinus) then
        table.insert(axes.position, {axis = "x", factor = -1})
    end
    if guiCheckBoxGetSelected(NMT.gui.checkMirrorPosYPlus) then
        table.insert(axes.position, {axis = "y", factor = 1})
    end
    if guiCheckBoxGetSelected(NMT.gui.checkMirrorPosYMinus) then
        table.insert(axes.position, {axis = "y", factor = -1})
    end
    if guiCheckBoxGetSelected(NMT.gui.checkMirrorPosZPlus) then
        table.insert(axes.position, {axis = "z", factor = 1})
    end
    if guiCheckBoxGetSelected(NMT.gui.checkMirrorPosZMinus) then
        table.insert(axes.position, {axis = "z", factor = -1})
    end
    
    -- Rotation axes
    if guiCheckBoxGetSelected(NMT.gui.checkMirrorRotXPlus) then
        table.insert(axes.rotation, {axis = "x", factor = 1})
    end
    if guiCheckBoxGetSelected(NMT.gui.checkMirrorRotXMinus) then
        table.insert(axes.rotation, {axis = "x", factor = -1})
    end
    if guiCheckBoxGetSelected(NMT.gui.checkMirrorRotYPlus) then
        table.insert(axes.rotation, {axis = "y", factor = 1})
    end
    if guiCheckBoxGetSelected(NMT.gui.checkMirrorRotYMinus) then
        table.insert(axes.rotation, {axis = "y", factor = -1})
    end
    if guiCheckBoxGetSelected(NMT.gui.checkMirrorRotZPlus) then
        table.insert(axes.rotation, {axis = "z", factor = 1})
    end
    if guiCheckBoxGetSelected(NMT.gui.checkMirrorRotZMinus) then
        table.insert(axes.rotation, {axis = "z", factor = -1})
    end
    
    return axes
end

-- Rotation conversion functions
function convertRotationToMTA(rx, ry, rz)
    rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)
    local sinX = math.sin(rx)
    local cosX = math.cos(rx)
    local sinY = math.sin(ry)
    local cosY = math.cos(ry)
    local sinZ = math.sin(rz)
    local cosZ = math.cos(rz)
    
    local newRx = math.asin(cosY * sinX)
    local newRy = math.atan2(sinY, cosX * cosY)
    local newRz = math.atan2(cosX * sinZ - cosZ * sinX * sinY, cosX * cosZ + sinX * sinY * sinZ)
    
    return math.deg(newRx), math.deg(newRy), math.deg(newRz)
end

function convertRotationFromMTA(rx, ry, rz)
    rx = math.rad(rx)
    ry = math.rad(ry)
    rz = math.rad(rz)
    
    local sinX = math.sin(rx)
    local cosX = math.cos(rx)
    local sinY = math.sin(ry)
    local cosY = math.cos(ry)
    local sinZ = math.sin(rz)
    local cosZ = math.cos(rz)
    
    return math.deg(math.atan2(sinX, cosX * cosY)), math.deg(math.asin(cosX * sinY)),
        math.deg(math.atan2(cosZ * sinX * sinY + cosY * sinZ, cosY * cosZ - sinX * sinY * sinZ))
end

function NMT.calculateMirroredPosition(elementPos, mainPos, axes)
    if not axes or #axes == 0 then return elementPos end
    
    local relativePos = {
        x = elementPos.x - mainPos.x,
        y = elementPos.y - mainPos.y,
        z = elementPos.z - mainPos.z
    }
    
    local mirroredPos = {x = relativePos.x, y = relativePos.y, z = relativePos.z}
    
    -- Apply all selected position axes
    for _, axisData in ipairs(axes) do
        if axisData.axis == "x" then
            mirroredPos.x = math.abs(relativePos.x) * axisData.factor
        elseif axisData.axis == "y" then
            mirroredPos.y = math.abs(relativePos.y) * axisData.factor
        elseif axisData.axis == "z" then
            mirroredPos.z = math.abs(relativePos.z) * axisData.factor
        end
    end
    
    return {
        x = mainPos.x + mirroredPos.x,
        y = mainPos.y + mirroredPos.y,
        z = mainPos.z + mirroredPos.z
    }
end

function NMT.calculateMirroredRotation(rotation, axes)
    if not axes or #axes == 0 then return rotation end
    
    -- Convert from MTA (ZXY) to standard XYZ
    local rx, ry, rz = convertRotationFromMTA(rotation.x, rotation.y, rotation.z)
    
    -- Apply all selected rotation axes
    for _, axisData in ipairs(axes) do
        if axisData.axis == "x" then
            ry = -ry
            rz = 180 - rz
        elseif axisData.axis == "y" then
            rx = -rx
            rz = 180 - rz
        elseif axisData.axis == "z" then
            rx = 180 - rx
            ry = 180 - ry
        end
    end
    
    -- Convert back to MTA (ZXY)
    rx, ry, rz = convertRotationToMTA(rx, ry, rz)
    return {x = rx, y = ry, z = rz}
end

function NMT.clearMirrorPreview()
    for _, element in ipairs(mirrorPreviewElements) do
        if isElement(element) then
            destroyElement(element)
        end
    end
    mirrorPreviewElements = {}
end

-- Preview Mirror+ (new function for checkbox-based system)
function NMT.previewMirrorPlus()
    NMT.clearMirrorPreview()
    
    if not NMT.mirrorMainElement or not isElement(NMT.mirrorMainElement) then
        outputChatBox("NMT: Please select a main element first", 255, 0, 0)
        return
    end
    
    if not NMT.selectedElements or NMT.countSelectedElements() == 0 then
        outputChatBox("NMT: Please select elements to mirror using Q key", 255, 0, 0)
        return
    end
    
    local axes = NMT.getMirrorPlusAxes()
    if #axes.position == 0 and #axes.rotation == 0 then
        outputChatBox("NMT: Please select at least one position or rotation axis", 255, 0, 0)
        return
    end
    
    local mainX, mainY, mainZ = getElementPosition(NMT.mirrorMainElement)
    local mainPos = {x = mainX, y = mainY, z = mainZ}
    local dimension = getElementDimension(localPlayer)
    
    for element in pairs(NMT.selectedElements) do
        if isElement(element) then
            local model = getElementModel(element)
            local x, y, z = getElementPosition(element)
            local rx, ry, rz = getElementRotation(element)
            
            local mirroredPos = NMT.calculateMirroredPosition({x = x, y = y, z = z}, mainPos, axes.position)
            local mirroredRot = NMT.calculateMirroredRotation({x = rx, y = ry, z = rz}, axes.rotation)
            
            local previewElement = createObject(model, mirroredPos.x, mirroredPos.y, mirroredPos.z, 
                                               mirroredRot.x, mirroredRot.y, mirroredRot.z)
            if previewElement then
                setElementDimension(previewElement, dimension)
                setElementAlpha(previewElement, 150)
                table.insert(mirrorPreviewElements, previewElement)
            end
        end
    end
    
    outputChatBox(string.format("NMT: Previewing %d mirrored elements", #mirrorPreviewElements), 0, 255, 0)
end

-- Generate Mirror+ (new function for checkbox-based system)
function NMT.generateMirrorPlus()
    if not NMT.mirrorMainElement or not isElement(NMT.mirrorMainElement) then
        outputChatBox("NMT: Please select a main element first", 255, 0, 0)
        return
    end
    
    if not NMT.selectedElements or NMT.countSelectedElements() == 0 then
        outputChatBox("NMT: Please select elements to mirror using Q key", 255, 0, 0)
        return
    end
    
    local axes = NMT.getMirrorPlusAxes()
    if #axes.position == 0 and #axes.rotation == 0 then
        outputChatBox("NMT: Please select at least one position or rotation axis", 255, 0, 0)
        return
    end
    
    local mainX, mainY, mainZ = getElementPosition(NMT.mirrorMainElement)
    local mainPos = {x = mainX, y = mainY, z = mainZ}
    
    local elementsData = {}
    for element in pairs(NMT.selectedElements) do
        if isElement(element) then
            local model = getElementModel(element)
            local x, y, z = getElementPosition(element)
            local rx, ry, rz = getElementRotation(element)
            local scale = getObjectScale(element)
            
            local mirroredPos = NMT.calculateMirroredPosition({x = x, y = y, z = z}, mainPos, axes.position)
            local mirroredRot = NMT.calculateMirroredRotation({x = rx, y = ry, z = rz}, axes.rotation)
            
            table.insert(elementsData, {
                source = element,
                model = model,
                x = mirroredPos.x,
                y = mirroredPos.y,
                z = mirroredPos.z,
                rx = mirroredRot.x,
                ry = mirroredRot.y,
                rz = mirroredRot.z,
                scale = scale
            })
        end
    end
    
    NMT.clearMirrorPreview()
    triggerServerEvent("nmt:mirrorGenerate", localPlayer, elementsData)
end

addEvent("nmt:mirrorGenerated", true)
addEventHandler("nmt:mirrorGenerated", root, function(elements)
    local index = #mirrorElementList + 1
    mirrorElementList[index] = elements
    outputChatBox(string.format("NMT: Generated %d mirrored elements", #elements), 0, 255, 0)
end)

-- Export for use in other modules
_G.mirrorElementList = mirrorElementList
