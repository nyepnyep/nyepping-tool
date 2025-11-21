-- Element update handlers for NMT

addEvent("nmt:updateElements", true)
addEventHandler("nmt:updateElements", root, function(data, model, scale, collisions, doublesided)
    if type(data) ~= "table" then
        return
    end

    if model then
        for _, element in pairs(data) do
            if getElementModel(element) ~= model then
                exports.edf:edfSetElementProperty(element, "model", model)
            end

            exports.edf:edfSetElementProperty(element, "scale", tonumber(scale) or 1)
            exports.edf:edfSetElementProperty(element, "collisions", tostring(collisions))
            exports.edf:edfSetElementProperty(element, "doublesided", tostring(doublesided))
        end
    else
        for _, v in pairs(data) do
            exports.edf:edfSetElementPosition(v[1], v[2], v[3], v[4])
            exports.edf:edfSetElementRotation(v[1], v[5], v[6], v[7])
        end
    end
end)
