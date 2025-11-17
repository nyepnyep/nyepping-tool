-- AutoShade generation for NMT

addEvent("nmt:autoShade", true)
addEventHandler("nmt:autoShade", root, function(element, sides, elemid)
    if not client or not element or not isElement(element) then
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
    if sides["bal"] then
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
    if sides["jobb"] then
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
    if sides["alul"] then
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
    
    -- Back (Shade)
    if sides["hatul"] then
        local shade = exports.edf:edfCloneElement(element)
        local elementMatrix = element.matrix
        local viktorVektor = Vector3(-18.671627044678, 0.0048828125, -18.67325592041)
        local positionVector = elementMatrix.transformPosition(elementMatrix, viktorVektor)
        local shadeX, shadeY, shadeZ = positionVector.x, positionVector.y, positionVector.z
        local shadeRX, shadeRY, shadeRZ = getElementRotation(element)
        shadeRX, shadeRY, shadeRZ = rotateY(shadeRX, shadeRY, shadeRZ, 270)
        exports.edf:edfSetElementProperty(shade, "model", elemid)
        exports.edf:edfSetElementPosition(shade, shadeX, shadeY, shadeZ)
        exports.edf:edfSetElementRotation(shade, shadeRX, shadeRY, shadeRZ)
        shadeCount = shadeCount + 1
        exports.edf:edfSetElementProperty(shade, "id", "NMT: Shade (" .. shadeCount .. ")")
        setElementID(shade, "NMT: Shade (" .. shadeCount .. ")")
        createdCount = createdCount + 1
        table.insert(createdElements, shade)
    end
    
    -- Front (Shade)
    if sides["elol"] then
        local shade = exports.edf:edfCloneElement(element)
        local elementMatrix = element.matrix
        local viktorVektor = Vector3(18.673532485962, 0.0049999998882413, -18.67325592041)
        local positionVector = elementMatrix.transformPosition(elementMatrix, viktorVektor)
        local shadeX, shadeY, shadeZ = positionVector.x, positionVector.y, positionVector.z
        local shadeRX, shadeRY, shadeRZ = getElementRotation(element)
        shadeRX, shadeRY, shadeRZ = rotateY(shadeRX, shadeRY, shadeRZ, 90)
        exports.edf:edfSetElementProperty(shade, "model", elemid)
        exports.edf:edfSetElementPosition(shade, shadeX, shadeY, shadeZ)
        exports.edf:edfSetElementRotation(shade, shadeRX, shadeRY, shadeRZ)
        shadeCount = shadeCount + 1
        exports.edf:edfSetElementProperty(shade, "id", "NMT: Shade (" .. shadeCount .. ")")
        setElementID(shade, "NMT: Shade (" .. shadeCount .. ")")
        createdCount = createdCount + 1
        table.insert(createdElements, shade)
    end
    
    -- Front (Tower)
    if sides["box_elol"] then
        local shade = exports.edf:edfCloneElement(element)
        local elementMatrix = element.matrix
        local viktorVektor = Vector3(20.214780807495, 0, -1.0640610456467)
        local positionVector = elementMatrix.transformPosition(elementMatrix, viktorVektor)
        local shadeX, shadeY, shadeZ = positionVector.x, positionVector.y, positionVector.z
        local shadeRX, shadeRY, shadeRZ = getElementRotation(element)
        exports.edf:edfSetElementProperty(shade, "model", 16327)
        exports.edf:edfSetElementPosition(shade, shadeX, shadeY, shadeZ)
        exports.edf:edfSetElementRotation(shade, shadeRX, shadeRY+270, shadeRZ)
        shadeCount = shadeCount + 1
        exports.edf:edfSetElementProperty(shade, "id", "NMT: Tower [Tower] (" .. shadeCount .. ")")
        exports.edf:edfSetElementProperty(shade, "scale", 1.01722812)
        exports.edf:edfSetElementProperty(shade, "doublesided", "true")
        setElementID(shade, "NMT: Tower [Tower] (" .. shadeCount .. ")")
        createdCount = createdCount + 1
        table.insert(createdElements, shade)
    end
    
    -- Back (Tower)
    if sides["box_hatul"] then
        local shade = exports.edf:edfCloneElement(element)
        local elementMatrix = element.matrix
        local viktorVektor = Vector3(-20.214780807495, 0, -1.0640610456467)
        local positionVector = elementMatrix.transformPosition(elementMatrix, viktorVektor)
        local shadeX, shadeY, shadeZ = positionVector.x, positionVector.y, positionVector.z
        local shadeRX, shadeRY, shadeRZ = getElementRotation(element)
        exports.edf:edfSetElementProperty(shade, "model", 16327)
        exports.edf:edfSetElementPosition(shade, shadeX, shadeY, shadeZ)
        exports.edf:edfSetElementRotation(shade, shadeRX, shadeRY+90, shadeRZ)
        shadeCount = shadeCount + 1
        exports.edf:edfSetElementProperty(shade, "id", "NMT: Tower [Tower] (" .. shadeCount .. ")")
        exports.edf:edfSetElementProperty(shade, "scale", 1.01722812)
        exports.edf:edfSetElementProperty(shade, "doublesided", "true")
        setElementID(shade, "NMT: Tower [Tower] (" .. shadeCount .. ")")
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
    if sides["front"] then
        local shadeCountRef = {shadeCount}
        local shade = createShadeFromConfig(element, sides["front"], elemid, "Front", shadeCountRef)
        shadeCount = shadeCountRef[1]
        createdCount = createdCount + 1
        table.insert(createdElements, shade)
    end
    
    -- Back (using table config)
    if sides["back"] then
        local shadeCountRef = {shadeCount}
        local shade = createShadeFromConfig(element, sides["back"], elemid, "Back", shadeCountRef)
        shadeCount = shadeCountRef[1]
        createdCount = createdCount + 1
        table.insert(createdElements, shade)
    end
    
    triggerClientEvent(source, "nmt:sendAutoShadeData", source, createdElements)
    outputChatBox("NMT: Created " .. createdCount .. " shade object" .. (createdCount == 1 and "" or "s"), source, 0, 255, 0)
end)
