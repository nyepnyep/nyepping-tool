-- AutoShade generation for NMT

-- Per-player undo history for AutoShade
local autoShadeUndoHistory = {}

addEvent("nmt:autoShade", true)
addEventHandler("nmt:autoShade", root, function(element, sides, elemid)
    if not client or not isElement(client) then
        return
    end

    if not element or not isElement(element) then
        return
    end
    if type(sides) ~= "table" then
        return
    end

    local shadeCount = 0
    for _, obj in pairs(getElementsByType("object")) do
        if getElementModel(obj) == 3458 or getElementModel(obj) == 8558 then
            shadeCount = shadeCount + 1
        end
    end

    local createdCount = 0
    local createdElements = {}

    -- Left
    if sides["asLeft"] then
        local shade = exports.edf:edfCloneElement(element)
        local elementMatrix = element.matrix
        local viktorVektor = Vector3(0, 1.0427426099777, -1.0366859436)
        local positionVector = elementMatrix.transformPosition(elementMatrix, viktorVektor)
        local shadeX, shadeY, shadeZ = positionVector.x, positionVector.y, positionVector.z
        local shadeRX, shadeRY, shadeRZ = getElementRotation(element)
        shadeRX, shadeRY, shadeRZ = rotateX(shadeRX, shadeRY, shadeRZ, 270)
        exports.edf:edfSetElementProperty(shade, "model", elemid)
        exports.edf:edfSetElementPosition(shade, shadeX, shadeY, shadeZ)
        exports.edf:edfSetElementRotation(shade, shadeRX, shadeRY, shadeRZ)
        shadeCount = shadeCount + 1
        exports.edf:edfSetElementProperty(shade, "id", "NMT: Shade (" .. shadeCount .. ")")
        setElementID(shade, "NMT: Shade (" .. shadeCount .. ")")
        createdCount = createdCount + 1
        table.insert(createdElements, shade)
    end

    -- Right
    if sides["asRight"] then
        local shade = exports.edf:edfCloneElement(element)
        local elementMatrix = element.matrix
        local viktorVektor = Vector3(0, -1.0276000499725, -1.042857170105)
        local positionVector = elementMatrix.transformPosition(elementMatrix, viktorVektor)
        local shadeX, shadeY, shadeZ = positionVector.x, positionVector.y, positionVector.z
        local shadeRX, shadeRY, shadeRZ = getElementRotation(element)
        shadeRX, shadeRY, shadeRZ = rotateX(shadeRX, shadeRY, shadeRZ, 90)
        exports.edf:edfSetElementProperty(shade, "model", elemid)
        exports.edf:edfSetElementPosition(shade, shadeX, shadeY, shadeZ)
        exports.edf:edfSetElementRotation(shade, shadeRX, shadeRY, shadeRZ)
        shadeCount = shadeCount + 1
        exports.edf:edfSetElementProperty(shade, "id", "NMT: Shade (" .. shadeCount .. ")")
        setElementID(shade, "NMT: Shade (" .. shadeCount .. ")")
        createdCount = createdCount + 1
        table.insert(createdElements, shade)
    end

    -- Bottom
    if sides["asBottom"] then
        local shade = exports.edf:edfCloneElement(element)
        local elementMatrix = element.matrix
        local viktorVektor = Vector3(0, 0.009341829456389, -2.0765142440796)
        local positionVector = elementMatrix.transformPosition(elementMatrix, viktorVektor)
        local shadeX, shadeY, shadeZ = positionVector.x, positionVector.y, positionVector.z
        local shadeRX, shadeRY, shadeRZ = getElementRotation(element)
        shadeRX, shadeRY, shadeRZ = rotateX(shadeRX, shadeRY, shadeRZ, 180)
        exports.edf:edfSetElementProperty(shade, "model", elemid)
        exports.edf:edfSetElementPosition(shade, shadeX, shadeY, shadeZ)
        exports.edf:edfSetElementRotation(shade, shadeRX, shadeRY, shadeRZ)
        shadeCount = shadeCount + 1
        exports.edf:edfSetElementProperty(shade, "id", "NMT: Shade (" .. shadeCount .. ")")
        setElementID(shade, "NMT: Shade (" .. shadeCount .. ")")
        createdCount = createdCount + 1
        table.insert(createdElements, shade)
    end

    -- Front (using table config)
    if sides["asFront"] then
        local config = sides["asFront"]
        local shade = exports.edf:edfCloneElement(element)
        local elementMatrix = element.matrix
        local viktorVektor = Vector3(config.position.x, config.position.y, config.position.z)
        local positionVector = elementMatrix.transformPosition(elementMatrix, viktorVektor)
        local shadeX, shadeY, shadeZ = positionVector.x, positionVector.y, positionVector.z
        local shadeRX, shadeRY, shadeRZ = getElementRotation(element)
        if config.rotation.x then
            shadeRX, shadeRY, shadeRZ = rotateX(shadeRX, shadeRY, shadeRZ, config.rotation.x)
        end
        if config.rotation.y then
            shadeRX, shadeRY, shadeRZ = rotateY(shadeRX, shadeRY, shadeRZ, config.rotation.y)
        end
        if config.rotation.z then
            shadeRX, shadeRY, shadeRZ = rotateZ(shadeRX, shadeRY, shadeRZ, config.rotation.z)
        end
        local modelToUse = config.model or elemid
        exports.edf:edfSetElementProperty(shade, "model", modelToUse)
        exports.edf:edfSetElementPosition(shade, shadeX, shadeY, shadeZ)
        exports.edf:edfSetElementRotation(shade, shadeRX, shadeRY, shadeRZ)
        if config.scale then
            exports.edf:edfSetElementProperty(shade, "scale", config.scale)
        end
        if config.doublesided then
            exports.edf:edfSetElementProperty(shade, "doublesided", "true")
        end
        shadeCount = shadeCount + 1
        local idName = config.id == "tower" and "NMT: Tower [Front]" or "NMT: Shade [Front]"
        exports.edf:edfSetElementProperty(shade, "id", idName .. " (" .. shadeCount .. ")")
        setElementID(shade, idName .. " (" .. shadeCount .. ")")
        createdCount = createdCount + 1
        table.insert(createdElements, shade)
    end

    -- Back (using table config)
    if sides["asBack"] then
        local config = sides["asBack"]
        local shade = exports.edf:edfCloneElement(element)
        local elementMatrix = element.matrix
        local viktorVektor = Vector3(config.position.x, config.position.y, config.position.z)
        local positionVector = elementMatrix.transformPosition(elementMatrix, viktorVektor)
        local shadeX, shadeY, shadeZ = positionVector.x, positionVector.y, positionVector.z
        local shadeRX, shadeRY, shadeRZ = getElementRotation(element)
        if config.rotation.x then
            shadeRX, shadeRY, shadeRZ = rotateX(shadeRX, shadeRY, shadeRZ, config.rotation.x)
        end
        if config.rotation.y then
            shadeRX, shadeRY, shadeRZ = rotateY(shadeRX, shadeRY, shadeRZ, config.rotation.y)
        end
        if config.rotation.z then
            shadeRX, shadeRY, shadeRZ = rotateZ(shadeRX, shadeRY, shadeRZ, config.rotation.z)
        end
        local modelToUse = config.model or elemid
        exports.edf:edfSetElementProperty(shade, "model", modelToUse)
        exports.edf:edfSetElementPosition(shade, shadeX, shadeY, shadeZ)
        exports.edf:edfSetElementRotation(shade, shadeRX, shadeRY, shadeRZ)
        if config.scale then
            exports.edf:edfSetElementProperty(shade, "scale", config.scale)
        end
        if config.doublesided then
            exports.edf:edfSetElementProperty(shade, "doublesided", "true")
        end
        shadeCount = shadeCount + 1
        local idName = config.id == "tower" and "NMT: Tower [Back]" or "NMT: Shade [Back]"
        exports.edf:edfSetElementProperty(shade, "id", idName .. " (" .. shadeCount .. ")")
        setElementID(shade, idName .. " (" .. shadeCount .. ")")
        createdCount = createdCount + 1
        table.insert(createdElements, shade)
    end

    -- Only record history if elements were actually created
    if #createdElements > 0 then
        autoShadeUndoHistory[client] = autoShadeUndoHistory[client] or {}
        table.insert(autoShadeUndoHistory[client], createdElements)
    end
end)

-- Undo last AutoShade for the requesting player
addEvent("nmt:autoShadeUndo", true)
addEventHandler("nmt:autoShadeUndo", root, function()
    local player = client
    if not player or not isElement(player) then
        return
    end

    local history = autoShadeUndoHistory[player]
    if not history or #history == 0 then
        return
    end

    local lastBatch = history[#history]
    table.remove(history, #history)

    if type(lastBatch) ~= "table" or #lastBatch == 0 then
        return
    end

    -- element_destroy only expects a single table of elements
    triggerEvent("nmt:destroyElements", resourceRoot, lastBatch)
end)