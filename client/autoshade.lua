-- AutoShade functionality for NMT

-- Initialize global list before it's accessed by GUI
if not _G.autoShadeElementList then
    _G.autoShadeElementList = {}
end
local autoShadeElementList = _G.autoShadeElementList

-- AutoShade function
function NMT.applyAutoShade()
    -- Check if there are any selected elements
    if not NMT.selectedElements or NMT.countSelectedElements() == 0 then
        outputChatBox("NMT: Please select one or more object elements using Q key", 255, 0, 0)
        return
    end

    local sides = {}
    sides["asLeft"] = guiCheckBoxGetSelected(NMT.gui.checkboxShadeLeft)
    sides["asRight"] = guiCheckBoxGetSelected(NMT.gui.checkboxShadeRight)
    sides["asBottom"] = guiCheckBoxGetSelected(NMT.gui.checkboxShadeBottom)
    
    -- Get front selection from dropdown
    local frontSelected = guiComboBoxGetSelected(NMT.gui.comboShadeFront)
    if frontSelected > 0 then -- 0 is "None"
        local frontObj = NMT.autoShadeObjects.front[frontSelected]
        if frontObj then
            sides["asFront"] = frontObj
        end
    end
    
    -- Get back selection from dropdown
    local backSelected = guiComboBoxGetSelected(NMT.gui.comboShadeBack)
    if backSelected > 0 then -- 0 is "None"
        local backObj = NMT.autoShadeObjects.back[backSelected]
        if backObj then
            sides["asBack"] = backObj
        end
    end

    local elemid = 3458
    if guiRadioButtonGetSelected(NMT.gui.radioShadeDarker) then
        elemid = 8558
    end

    -- Apply AutoShade to all selected elements
    for element in pairs(NMT.selectedElements) do
        if isElement(element) and getElementType(element) == "object" then
            triggerServerEvent("nmt:autoShade", resourceRoot, element, sides, elemid)
        end
    end
end

-- Receive autoshade data from server
addEvent("nmt:sendAutoShadeData", true)
addEventHandler("nmt:sendAutoShadeData", root, function(elements)
    local index = #autoShadeElementList + 1
    autoShadeElementList[index] = elements
end)
