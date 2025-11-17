-- Element destruction handler for NMT

addEvent("nmt:destroyElements", true)
addEventHandler("nmt:destroyElements", root, function(elements)
    if type(elements) ~= "table" then
        return
    end
    
    for i = 1, #elements do
        if isElement(elements[i]) then
            destroyElement(elements[i])
        end
    end
end)
