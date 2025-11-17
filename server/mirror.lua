-- Mirror generation for NMT

addEvent("nmt:mirrorGenerate", true)
addEventHandler("nmt:mirrorGenerate", root, function(elementsData)
    if type(elementsData) ~= "table" then
        return
    end
    
    local generatedElements = {}
    
    for _, data in ipairs(elementsData) do
        local base = isElement(data.source) and data.source or nil
        if base then
            local newElement = exports.edf:edfCloneElement(base)
            if newElement then
                -- Ensure model matches requested (in case EDF clone carries different model)
                if getElementModel(newElement) ~= data.model then
                    exports.edf:edfSetElementProperty(newElement, "model", data.model)
                end
                local newID = "NMT Mirror " .. data.model .. " (" .. getElementCount(newElement) .. ")"
                setElementID(newElement, newID)
                exports.edf:edfSetElementProperty(newElement, "id", newID)
                exports.edf:edfSetElementPosition(newElement, data.x, data.y, data.z)
                exports.edf:edfSetElementRotation(newElement, data.rx, data.ry, data.rz)
                exports.edf:edfSetElementProperty(newElement, "scale", data.scale or 1)
                table.insert(generatedElements, newElement)
            end
        end
    end
    
    triggerClientEvent(source, "nmt:mirrorGenerated", source, generatedElements)
end)
