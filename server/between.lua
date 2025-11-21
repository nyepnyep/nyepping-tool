-- Between generation for NMT

addEvent("nmt:betweenGenerate", true)
addEventHandler("nmt:betweenGenerate", root, function(element1, element2, duplication)
    local model1 = getElementModel(element1)
    local px1, py1, pz1 = getElementPosition(element1)
    local rx1, ry1, rz1 = getElementRotation(element1)
    local model2 = getElementModel(element2)
    local px2, py2, pz2 = getElementPosition(element2)
    local rx2, ry2, rz2 = getElementRotation(element2)
    local newX, newY, newZ = (px2 - px1) / (duplication + 1), (py2 - py1) / (duplication + 1), (pz2 - pz1) / (duplication + 1)
    local newRX, newRY, newRZ = (rx2 - rx1) / (duplication + 1), (ry2 - ry1) / (duplication + 1), (rz2 - rz1) / (duplication + 1)
    local elements = {}
    for i = 1, duplication do
        local newElement = exports.edf:edfCloneElement(element1)
        if i % 2 == 0 then
            setElementModel(newElement, model1)
        else
            setElementModel(newElement, model2)
        end
        local newID = "NMT " .. getElementModel(newElement) .. " (" .. getElementCount(newElement) .. ")"
        exports.edf:edfSetElementProperty(newElement, "id", newID)
        setElementID(newElement, newID)
        exports.edf:edfSetElementPosition(newElement, px1 + newX * i, py1 + newY * i, pz1 + newZ * i)
        exports.edf:edfSetElementRotation(newElement, rx1 + newRX * i, ry1 + newRY * i, rz1 + newRZ * i)
        elements[#elements + 1] = newElement
    end
    triggerClientEvent(source, "nmt:sendBetweenData", source, elements)
end)

-- Generate elements between multiple pairs (outer edges only)
addEvent("nmt:betweenGenerateMultiple", true)
addEventHandler("nmt:betweenGenerateMultiple", root, function(pairs, duplication)
    local allElements = {}
    
    for _, pair in ipairs(pairs) do
        local element1, element2 = pair[1], pair[2]
        
        if isElement(element1) and isElement(element2) then
        
            local model1 = getElementModel(element1)
            local px1, py1, pz1 = getElementPosition(element1)
            local rx1, ry1, rz1 = getElementRotation(element1)
            local model2 = getElementModel(element2)
            local px2, py2, pz2 = getElementPosition(element2)
            local rx2, ry2, rz2 = getElementRotation(element2)
            local newX, newY, newZ = (px2 - px1) / (duplication + 1), (py2 - py1) / (duplication + 1), (pz2 - pz1) / (duplication + 1)
            local newRX, newRY, newRZ = (rx2 - rx1) / (duplication + 1), (ry2 - ry1) / (duplication + 1), (rz2 - rz1) / (duplication + 1)
            
            for i = 1, duplication do
                local newElement = exports.edf:edfCloneElement(element1)
                if i % 2 == 0 then
                    setElementModel(newElement, model1)
                else
                    setElementModel(newElement, model2)
                end
                local newID = "NMT " .. getElementModel(newElement) .. " (" .. getElementCount(newElement) .. ")"
                exports.edf:edfSetElementProperty(newElement, "id", newID)
                setElementID(newElement, newID)
                exports.edf:edfSetElementPosition(newElement, px1 + newX * i, py1 + newY * i, pz1 + newZ * i)
                exports.edf:edfSetElementRotation(newElement, rx1 + newRX * i, ry1 + newRY * i, rz1 + newRZ * i)
                allElements[#allElements + 1] = newElement
            end
        end
    end
    
    triggerClientEvent(source, "nmt:sendBetweenData", source, allElements)
end)
