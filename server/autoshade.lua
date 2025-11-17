-- AutoShade generation for NMT

-- Per-player undo history for AutoShade
local autoShadeUndoHistory = {}

addEvent("nmt:autoShade", true)
addEventHandler("nmt:autoShade", root, function(element, sides, elemid)
    -- Ensure we have a valid client
    if not client or not isElement(client) then
        outputDebugString("[NMT Server] autoShade: invalid client")
        return
    end

    outputDebugString("[NMT Server] autoShade event received from client: " .. tostring(client))

    if not element or not isElement(element) then
        outputDebugString("[NMT Server] Invalid element")
        return
    end
    if type(sides) ~= "table" then
        outputDebugString("[NMT Server] Invalid sides table")
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

    -- Helper function to create shade from config
    local function createShadeFromConfig(element, config, elemid, direction, shadeCountRef)
        local shade = exports.edf:edfCloneElement(element)
        local elementMatrix = element.matrix
        local positionVector = elementMatrix.transformPosition(elementMatrix, config.position)
        local shadeX, shadeY, shadeZ = positionVector.x, positionVector.y, positionVector.z
        local shadeRX, shadeRY, shadeRZ = getElementRotation(element)

        -- Apply rotation based on config
        if config.rotation.x then
            shadeRX, shadeRY, shadeRZ = rotateX(shadeRX, shadeRY, shadeRZ, config.rotation.x)
        end
        if config.rotation.y then
            -- Check if it's a direct offset or rotateY function
            if config.id == "tower" then
                shadeRY = shadeRY + config.rotation.y
            else
                shadeRX, shadeRY, shadeRZ = rotateY(shadeRX, shadeRY, shadeRZ, config.rotation.y)
            end
        end
        if config.rotation.z then
            shadeRX, shadeRY, shadeRZ = rotateZ(shadeRX, shadeRY, shadeRZ, config.rotation.z)
        end

        -- Set model
        local modelToUse = config.model or elemid
        exports.edf:edfSetElementProperty(shade, "model", modelToUse)
        exports.edf:edfSetElementPosition(shade, shadeX, shadeY, shadeZ)
        exports.edf:edfSetElementRotation(shade, shadeRX, shadeRY, shadeRZ)

        -- Set other properties
        if config.scale then
            exports.edf:edfSetElementProperty(shade, "scale", config.scale)
        end
        if config.doublesided then
            exports.edf:edfSetElementProperty(shade, "doublesided", "true")
        end

        -- Set ID
        shadeCountRef[1] = shadeCountRef[1] + 1
        local idName = config.id == "tower" and ("NMT: Tower [" .. direction .. "]") or ("NMT: Shade [" .. direction .. "]")
        exports.edf:edfSetElementProperty(shade, "id", idName .. " (" .. shadeCountRef[1] .. ")")
        setElementID(shade, idName .. " (" .. shadeCountRef[1] .. ")")

        return shade
    end

    -- Front (using table config)
    if sides["asFront"] then
        local shadeCountRef = {shadeCount}
        local shade = createShadeFromConfig(element, sides["asFront"], elemid, "Front", shadeCountRef)
        shadeCount = shadeCountRef[1]
        createdCount = createdCount + 1
        table.insert(createdElements, shade)
    end

    -- Back (using table config)
    if sides["asBack"] then
        local shadeCountRef = {shadeCount}
        local shade = createShadeFromConfig(element, sides["asBack"], elemid, "Back", shadeCountRef)
        shadeCount = shadeCountRef[1]
        createdCount = createdCount + 1
        table.insert(createdElements, shade)
    end

    -- Only record history and notify client if elements were actually created
    if #createdElements > 0 then
        outputDebugString("[NMT Server] AutoShade created " .. #createdElements .. " elements for client " .. tostring(client))

        autoShadeUndoHistory[client] = autoShadeUndoHistory[client] or {}
        table.insert(autoShadeUndoHistory[client], createdElements)

        outputChatBox("NMT: Created " .. createdCount .. " shade object" .. (createdCount == 1 and "" or "s"), client, 0, 255, 0)
    else
        outputDebugString("[NMT Server] No elements created")
        outputChatBox("NMT: No shades created - please select at least one side", client, 255, 165, 0)
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
        outputChatBox("NMT: Nothing to undo", player, 255, 0, 0)
        return
    end

    local lastBatch = history[#history]
    table.remove(history, #history)

    if type(lastBatch) ~= "table" or #lastBatch == 0 then
        outputChatBox("NMT: Nothing to undo", player, 255, 0, 0)
        return
    end

    -- element_destroy only expects a single table of elements
    triggerEvent("nmt:destroyElements", resourceRoot, lastBatch)
    outputChatBox("NMT: Undone last AutoShade application", player, 0, 255, 0)
end)