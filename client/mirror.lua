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
        guiSetText(NMT.gui.labelMirrorMainElement, "Main element: not selected")
        guiSetText(NMT.gui.buttonSelectMirrorMainElement, "Select main element")
        guiSetText(NMT.gui.labelMirrorPlusMainElement, "Main element: not selected")
        guiSetText(NMT.gui.buttonSelectMirrorPlusMainElement, "Select main element")

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
    guiSetText(NMT.gui.labelMirrorMainElement, string.format("Main element: %s", getElementID(element)))
    guiSetText(NMT.gui.buttonSelectMirrorMainElement, "Reset main element")
    guiSetText(NMT.gui.labelMirrorPlusMainElement, string.format("Main element: %s", getElementID(element)))
    guiSetText(NMT.gui.buttonSelectMirrorPlusMainElement, "Reset main element")

    return true
end

-- Rotation conversion functions (from AutoShade/AMT)
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

function NMT.calculateMirroredPosition(elementPos, mainPos, direction)
    if not direction then return elementPos end
    
    local relativePos = {
        x = elementPos.x - mainPos.x,
        y = elementPos.y - mainPos.y,
        z = elementPos.z - mainPos.z
    }
    
    local mirroredPos = {x = relativePos.x, y = relativePos.y, z = relativePos.z}
    
    -- Use factor to determine target side (+ or -)
    if direction.axis == "x" then
        mirroredPos.x = math.abs(relativePos.x) * direction.factor
    elseif direction.axis == "y" then
        mirroredPos.y = math.abs(relativePos.y) * direction.factor
    elseif direction.axis == "z" then
        mirroredPos.z = math.abs(relativePos.z) * direction.factor
    end
    
    return {
        x = mainPos.x + mirroredPos.x,
        y = mainPos.y + mirroredPos.y,
        z = mainPos.z + mirroredPos.z
    }
end

function NMT.calculateMirroredRotation(rotation, direction)
    if not direction then return rotation end
    
    -- Convert from MTA (ZXY) to standard XYZ
    local rx, ry, rz = convertRotationFromMTA(rotation.x, rotation.y, rotation.z)
    
    if direction.axis == "x" then
        -- Mirror across YZ plane (X axis)
        ry = -ry          -- Flip roll
        rz = 180 - rz     -- Reverse yaw for facing
    elseif direction.axis == "y" then
        -- Mirror across XZ plane (Y axis)
        rx = -rx          -- Flip pitch
        rz = 180 - rz     -- Reverse yaw for facing
    elseif direction.axis == "z" then
        -- Mirror across XY plane (Z axis)
        rx = 180 - rx     -- Flip pitch for vertical reflection
        ry = 180 - ry     -- Flip roll for vertical reflection
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

addEvent("nmt:mirrorGenerated", true)
addEventHandler("nmt:mirrorGenerated", root, function(elements)
    local index = #mirrorElementList + 1
    mirrorElementList[index] = elements
    outputChatBox(string.format("NMT: Generated %d mirrored elements", #elements), 0, 255, 0)
end)

addEvent("nmt:sendAutoShadeData", true)
addEventHandler("nmt:sendAutoShadeData", root, function(elements)
    local index = #autoShadeElementList + 1
    autoShadeElementList[index] = elements
end)


-- Export for use in other modules
_G.mirrorElementList = mirrorElementList
