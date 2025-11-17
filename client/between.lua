-- Between functionality for NMT (filling space between objects)

local betweenPreviewElements = {}
local betweenElementList = {}

-- Preview objects between selected elements
function NMT.previewBetween()
    NMT.clearBetweenPreview()
    
    if not NMT.selectedElements or NMT.countSelectedElements() < 2 then
        outputChatBox("NMT: Please select at least 2 elements using Q key", 255, 0, 0)
        return
    end
    
    local amount = tonumber(guiGetText(NMT.gui.editBetweenAmount))
    if not amount or amount < 1 then
        outputChatBox("NMT: Please enter a valid amount", 255, 0, 0)
        return
    end

    local elements = {}
    for element in pairs(NMT.selectedElements) do
        table.insert(elements, element)
    end
    
    -- Connect elements in outer edge pattern (loop)
    for i = 1, #elements do
        local element1 = elements[i]
        local element2 = elements[i % #elements + 1]
        
        local model1 = getElementModel(element1)
        local px1, py1, pz1 = getElementPosition(element1)
        local rx1, ry1, rz1 = getElementRotation(element1)
        local px2, py2, pz2 = getElementPosition(element2)
        local rx2, ry2, rz2 = getElementRotation(element2)

        local newX = (px2 - px1) / (amount + 1)
        local newY = (py2 - py1) / (amount + 1)
        local newZ = (pz2 - pz1) / (amount + 1)
        local newRX = (rx2 - rx1) / (amount + 1)
        local newRY = (ry2 - ry1) / (amount + 1)
        local newRZ = (rz2 - rz1) / (amount + 1)

        for j = 1, amount do
            local pX = px1 + newX * j
            local pY = py1 + newY * j
            local pZ = pz1 + newZ * j
            local rotX = rx1 + newRX * j
            local rotY = ry1 + newRY * j
            local rotZ = rz1 + newRZ * j

            local preview = createObject(model1, pX, pY, pZ, rotX, rotY, rotZ)
            setElementDimension(preview, getElementDimension(localPlayer))
            setElementAlpha(preview, 150)
            table.insert(betweenPreviewElements, preview)
        end
    end
    
    outputChatBox("NMT: Preview created with " .. #betweenPreviewElements .. " objects", 0, 255, 0)
end

-- Clear between preview
function NMT.clearBetweenPreview()
    for i = 1, #betweenPreviewElements do
        if isElement(betweenPreviewElements[i]) then
            destroyElement(betweenPreviewElements[i])
        end
    end
    betweenPreviewElements = {}
end

-- Generate between objects on server
function NMT.generateBetween()
    if not NMT.selectedElements or NMT.countSelectedElements() < 2 then
        outputChatBox("NMT: Please select at least 2 elements using Q key", 255, 0, 0)
        return
    end
    
    local amount = tonumber(guiGetText(NMT.gui.editBetweenAmount))
    if not amount or amount < 1 then
        outputChatBox("NMT: Please enter a valid amount", 255, 0, 0)
        return
    end

    local elements = {}
    for element in pairs(NMT.selectedElements) do
        table.insert(elements, element)
    end
    
    local pairs = {}
    for i = 1, #elements do
        local element1 = elements[i]
        local element2 = elements[i % #elements + 1]
        table.insert(pairs, {element1, element2})
    end
    
    triggerServerEvent("nmt:betweenGenerateMultiple", localPlayer, pairs, amount)
    NMT.clearBetweenPreview()
end

-- Receive between data from server
addEvent("nmt:sendBetweenData", true)
addEventHandler("nmt:sendBetweenData", root, function(elements)
    local index = #betweenElementList + 1
    betweenElementList[index] = elements
end)

-- Undo command
addCommandHandler("dnmt", function()
    local index = #betweenElementList
    if index == 0 then
        outputChatBox("NMT: Nothing to undo", 255, 0, 0)
        return
    end
    triggerServerEvent("nmt:destroyElements", localPlayer, betweenElementList[index])
    table.remove(betweenElementList, index)
end)

-- Export for use in other modules
_G.betweenElementList = betweenElementList
