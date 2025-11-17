-- Element backup and restore utilities for NMT
-- Handles backing up and restoring element positions and rotations

-- Ensure NMT table exists
if not _G.NMT then
    _G.NMT = {}
end

_G.elementOriginPosition = {}
_G.elementOriginRotation = {}

-- Backup element position
function NMT.backupElementPosition(element)
    if not isElement(element) then
        return false
    end

    local elementMatrix = element.matrix
    elementOriginPosition[element] = elementMatrix

    return elementMatrix
end

-- Backup element rotation
function NMT.backupElementRotation(element)
    if not isElement(element) then
        return false
    end

    local rx, ry, rz = exports.edf:edfGetElementRotation(element)
    elementOriginRotation[element] = {rx, ry, rz}

    return rx, ry, rz
end

-- Restore element position
function NMT.restoreElementPosition(element)
    if not isElement(element) then
        return false
    end

    local originPosition = elementOriginPosition[element]
    if not originPosition or not originPosition.getPosition or type(originPosition.getPosition) ~= "function" then
        return nil
    end

    local position = originPosition:getPosition()
    if not position then
        return nil
    end

    exports.edf:edfSetElementPosition(element, position.x, position.y, position.z)

    return position.x, position.y, position.z
end

-- Restore element rotation
function NMT.restoreElementRotation(element)
    if not isElement(element) then
        return false
    end

    local originRotation = elementOriginRotation[element] or {0, 0, 0}
    local rx, ry, rz = originRotation[1], originRotation[2], originRotation[3]
    exports.edf:edfSetElementRotation(element, rx, ry, rz)

    return rx, ry, rz
end
