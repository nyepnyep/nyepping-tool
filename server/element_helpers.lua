-- Element helper functions for NMT

function getElementCount(element)
    local model = getElementModel(element)
    local count = 0
    local elements = getElementsByType(getElementType(element))
    for i = 1, #elements do
        local tModel = getElementModel(elements[i])
        if tModel == model then
            count = count + 1
        end
    end
    return count
end
