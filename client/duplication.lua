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
    if not NMT.selectedElements then
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
                    for _, element in pairs(NMT.createdElements[element]) do
                        if isElement(element) then
                            destroyElement(element)
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

            if type(originPosition) == "userdata" and type(originPosition.transformPosition) == "function" then
                for i = 1, multiplier do
                    local newElement = NMT.createdElements[element][i]
                    if not newElement then
                        newElement = createObject(model, px, py, pz)
                        table.insert(NMT.createdElements[element], newElement)
                    end

                    setElementID(newElement, "NMT PREVIEW (" .. i .. ")")
                    setElementModel(newElement, model)
                    setObjectScale(newElement, scale)
                    setElementAlpha(newElement, 155)

                    -- Position
                    local success, positionVector = pcall(originPosition.transformPosition, originPosition, elementVector)
                    if success and positionVector and positionVector.x and positionVector.y and positionVector.z then
                        setElementPosition(newElement, positionVector.x, positionVector.y, positionVector.z)
                    end

                    -- Rotation
                    rx, ry, rz = rotateX(rx, ry, rz, addrx)
                    rx, ry, rz = rotateY(rx, ry, rz, addry)
                    rx, ry, rz = rotateZ(rx, ry, rz, addrz)
                    setElementRotation(newElement, rx, ry, rz)

                    -- Dimension
                    setElementDimension(newElement, dimension)

                    -- Update origin
                    originPosition = newElement.matrix
                end
            end
        end
    end
end

-- Toggle duplication preview
function NMT.previewDuplicates(state)
    NMT.clearDuplicates()
    removeEventHandler("onClientRender", root, renderDuplicates)
    if state then
        addEventHandler("onClientRender", root, renderDuplicates, true, "low-9999")
    end
end

-- Handle GUI toggle event
addEvent("nmt:onGUIToggle")
addEventHandler("nmt:onGUIToggle", root, function(state)
    NMT.previewDuplicates(state and guiGetSelectedTab(NMT.gui.tabPanel) == NMT.gui.tabs[2])
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
    if not NMT.selectedElements or not NMT.createdElements then
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
