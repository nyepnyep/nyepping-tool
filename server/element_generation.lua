-- Element generation handlers for NMT

addEvent("nmt:generateElements", true)
addEventHandler("nmt:generateElements", root, function(data, baseElement)
    if type(data) ~= "table" or not isElement(baseElement) then
        return
    end

    local generatedElements = {}
    for _, v in pairs(data) do
        local newElement = exports.edf:edfCloneElement(baseElement)
        if newElement then
            local newID = "NMT " .. getElementModel(newElement) .. " (" .. getElementCount(newElement) .. ")"
            setElementID(newElement, newID)
            exports.edf:edfSetElementProperty(newElement, "id", newID)
            exports.edf:edfSetElementProperty(newElement, "model", v[1])
            exports.edf:edfSetElementPosition(newElement, v[2], v[3], v[4])
            exports.edf:edfSetElementRotation(newElement, v[5], v[6], v[7])
            exports.edf:edfSetElementProperty(newElement, "scale", v[8])
            table.insert(generatedElements, newElement)
        end
    end

    triggerClientEvent(source, "nmt:sendDuplicateData", source, generatedElements)
    outputChatBox("NMT: Generated " .. #data .. " element" .. (#data == 1 and "" or "s"), source, 0, 255, 0)
end)

-- From MZT: Clone selected elements
addEvent("nmt:cloneElements", true)
addEventHandler("nmt:cloneElements", root, function(data)
    if type(data) ~= "table" then
        return
    end

    for _, element in pairs(data) do
        local newElement = exports.edf:edfCloneElement(element)
        if newElement then
            local newID = "NMT " .. getElementModel(newElement) .. " (" .. getElementCount(newElement) .. ")"
            setElementID(newElement, newID)
        end
    end

    outputChatBox("NMT: Cloned " .. #data .. " element" .. (#data == 1 and "" or "s"), source, 0, 255, 0)
end)
