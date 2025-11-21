-- AutoShade functionality for NMT

-- AutoShade function
function NMT.applyAutoShade()
    -- Check if there are any selected elements
    if not NMT.selectedElements or NMT.countSelectedElements() == 0 then
        return
    end

    local sides = {}
    sides["asLeft"] = guiCheckBoxGetSelected(NMT.gui.checkboxShadeLeft)
    sides["asRight"] = guiCheckBoxGetSelected(NMT.gui.checkboxShadeRight)
    sides["asBottom"] = guiCheckBoxGetSelected(NMT.gui.checkboxShadeBottom)
    
    -- Get front selection from dropdown
    local frontSelected = guiComboBoxGetSelected(NMT.gui.comboShadeFront)
    if frontSelected > 0 then
        local frontObj = NMT.autoShadeObjects.front[frontSelected]
        if frontObj then
            -- Convert Vector3 to table for network transmission
            sides["asFront"] = {
                id = frontObj.id,
                name = frontObj.name,
                model = frontObj.model,
                position = {x = frontObj.position.x, y = frontObj.position.y, z = frontObj.position.z},
                rotation = frontObj.rotation,
                scale = frontObj.scale,
                doublesided = frontObj.doublesided
            }
        end
    end
    
    -- Get back selection from dropdown
    local backSelected = guiComboBoxGetSelected(NMT.gui.comboShadeBack)
    if backSelected > 0 then
        local backObj = NMT.autoShadeObjects.back[backSelected]
        if backObj then
            -- Convert Vector3 to table for network transmission
            sides["asBack"] = {
                id = backObj.id,
                name = backObj.name,
                model = backObj.model,
                position = {x = backObj.position.x, y = backObj.position.y, z = backObj.position.z},
                rotation = backObj.rotation,
                scale = backObj.scale,
                doublesided = backObj.doublesided
            }
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