-- Continuous duplication functionality for NMT

local duplicateElementList = {}

-- Clear duplicate preview elements
function NMT.clearDuplicates()
    if NMT.createdElements then
        for _, tbl in pairs(NMT.createdElements) do
            for _, element in pairs(tbl) do
                if isElement(element) then
                    destroyElement(element)
                end
            end
        end
    end

    NMT.createdElements = {}
end

-- Render duplicate previews
local function renderDuplicates()
    if not NMT.selectedElements or not next(NMT.selectedElements) then
        return
    end
    
    if not NMT.gui or not NMT.gui.editMultiplier then
        return
    end

    if not NMT.createdElements then
        NMT.createdElements = {}
    end

    local dimension = getElementDimension(localPlayer)
    local multiplier = tonumber(guiGetText(NMT.gui.editMultiplier)) or 1
    multiplier = math.floor(math.min(math.max(multiplier, 1), 100))

    local addpx = tonumber(guiGetText(NMT.gui.editAddMoveX)) or 0
    local addpy = tonumber(guiGetText(NMT.gui.editAddMoveY)) or 0
    local addpz = tonumber(guiGetText(NMT.gui.editAddMoveZ)) or 0

    local addrx = tonumber(guiGetText(NMT.gui.editAddRotateX)) or 0
    local addry = tonumber(guiGetText(NMT.gui.editAddRotateY)) or 0
    local addrz = tonumber(guiGetText(NMT.gui.editAddRotateZ)) or 0

    local elementVector = Vector3(addpx, addpy, addpz)

    for element in pairs(NMT.selectedElements) do
        if isElement(element) then
            if not NMT.createdElements[element] then
                NMT.createdElements[element] = {}
            else
                if #NMT.createdElements[element] ~= multiplier then
                    for _, duplicateElement in pairs(NMT.createdElements[element]) do
                        if isElement(duplicateElement) then
                            destroyElement(duplicateElement)
                        end
                    end

                    NMT.createdElements[element] = {}
                end
            end

            local model = getElementModel(element)
            local px, py, pz = getElementPosition(element)
            local rx, ry, rz = getElementRotation(element)
            local scale = getObjectScale(element)
            local originPosition = element.matrix

            -- Start from the original element's rotation for each selected element
            local currentRX, currentRY, currentRZ = rx, ry, rz
            
            for i = 1, multiplier do
                local newElement = NMT.createdElements[element][i]
                if not newElement or not isElement(newElement) then
                    newElement = createObject(model, px, py, pz)
                    if newElement then
                        NMT.createdElements[element][i] = newElement
                    else
                        break
                    end
                end

                setElementID(newElement, "NMT PREVIEW (" .. i .. ")")
                setElementModel(newElement, model)
                setObjectScale(newElement, scale)
                setElementAlpha(newElement, 155)
                setElementDimension(newElement, dimension)

                -- Position
                if type(originPosition) == "userdata" and type(originPosition.transformPosition) == "function" then
                    local success, positionVector = pcall(originPosition.transformPosition, originPosition, elementVector)
                    if success and positionVector and positionVector.x and positionVector.y and positionVector.z then
                        setElementPosition(newElement, positionVector.x, positionVector.y, positionVector.z)
                    end
                end

                -- Rotation - accumulate from the original rotation
                currentRX, currentRY, currentRZ = rotateX(currentRX, currentRY, currentRZ, addrx)
                currentRX, currentRY, currentRZ = rotateY(currentRX, currentRY, currentRZ, addry)
                currentRX, currentRY, currentRZ = rotateZ(currentRX, currentRY, currentRZ, addrz)
                setElementRotation(newElement, currentRX, currentRY, currentRZ)

                -- Update origin for next iteration
                originPosition = newElement.matrix
            end
        end
    end
end

-- Toggle duplication preview
function NMT.previewDuplicates(state)
    -- Remove existing handler (removeEventHandler doesn't error if not attached)
    removeEventHandler("onClientRender", root, renderDuplicates)
    
    if state then
        -- Add render handler for preview
        addEventHandler("onClientRender", root, renderDuplicates, true, "low-9999")
    else
        -- Clear duplicates when disabling
        NMT.clearDuplicates()
    end
end

-- Handle GUI toggle event
addEvent("nmt:onGUIToggle")
addEventHandler("nmt:onGUIToggle", root, function(state)
    NMT.previewDuplicates(state and guiGetSelectedTab(NMT.gui.tabPanel) == NMT.gui.tabs[2])
end)

-- Handle tab switching
addEventHandler("onClientGUITabSwitched", root, function(selectedTab)
    if NMT.gui and source == NMT.gui.tabPanel then
        NMT.previewDuplicates(selectedTab == NMT.gui.tabs[2])
    end
end)

-- Handle deselect all event
addEvent("nmt:onDeselectAll")
addEventHandler("nmt:onDeselectAll", root, function()
    NMT.previewDuplicates(false)
end)

-- Get first selected element
local function getFirstSelectedElement()
    for element in pairs(NMT.selectedElements) do
        return element
    end
    return nil
end

-- Generate duplicates on server
function NMT.generateDuplicates()
    if not NMT.selectedElements then
        exports.editor_gui:outputMessage("No elements selected", 255, 0, 0, 5000)
        return
    end
    
    if not NMT.createdElements then
        exports.editor_gui:outputMessage("No preview elements found. Switch to duplicate tab first.", 255, 165, 0, 5000)
        return
    end

    local data = {}

    for _, tbl in pairs(NMT.createdElements) do
        for _, element in pairs(tbl) do
            if isElement(element) then
                local model = getElementModel(element)
                local px, py, pz = getElementPosition(element)
                local rx, ry, rz = getElementRotation(element)
                local scale = getObjectScale(element)
                table.insert(data, {model, px, py, pz, rx, ry, rz, scale})
            end
        end
    end

    if #data == 0 then
        exports.editor_gui:outputMessage("No duplicates created. Set Count and offsets in the Duplicate tab.", 255, 165, 0, 5000)
        return
    end

    exports.editor_gui:outputMessage("Generating " .. #data .. " element(s)", 0, 255, 0, 5000)
    triggerServerEvent("nmt:generateElements", localPlayer, data, getFirstSelectedElement())
    NMT.clearDuplicates()
end

-- Receive duplicate data from server
addEvent("nmt:sendDuplicateData", true)
addEventHandler("nmt:sendDuplicateData", root, function(elements)
    local index = #duplicateElementList + 1
    duplicateElementList[index] = elements
end)

-- Export for use in other modules
_G.duplicateElementList = duplicateElementList
