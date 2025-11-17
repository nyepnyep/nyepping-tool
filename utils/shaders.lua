-- Shader utilities for element selection highlighting in NMT

-- Ensure NMT table exists
if not _G.NMT then
    _G.NMT = {}
end

local SHADER_CODE = [[
    float4 color = float4(1, 1, 1, 1);

    technique TexReplace
    {
        pass P0
        {
            MaterialAmbient = color;
            MaterialDiffuse = color;
            MaterialEmissive = color;
            MaterialSpecular = color;
            Lighting = true;
        }
    }
]]

-- Get color from shader type
function NMT.getColorFromType(_type)
    if _type == "primary" then
        return NMT.settings.colorSelectedPrimary
    elseif _type == "secondary" then
        return NMT.settings.colorSelectedSecondary
    end
    return {1, 1, 1, 1}
end

-- Apply selection shader to element
function NMT.applySelectedShaderToElement(element, _type)
    if not isElement(element) or not _type then
        return false
    end

    if not NMT.shaders then
        NMT.shaders = {}
    end

    local color = NMT.getColorFromType(_type)
    if not NMT.shaders[_type] then
        NMT.shaders[_type] = dxCreateShader(SHADER_CODE)
        dxSetShaderValue(NMT.shaders[_type], "color", color[1], color[2], color[3], color[4])
    end

    for _, shader in pairs(NMT.shaders) do
        engineRemoveShaderFromWorldTexture(shader, "*", element)
    end

    engineApplyShaderToWorldTexture(NMT.shaders[_type], "*", element, true)

    return true
end

-- Remove all shaders from element
function NMT.removeAllShadersFromElement(element)
    if not isElement(element) then
        return false
    end

    if not NMT.shaders then
        return
    end

    for _, shader in pairs(NMT.shaders) do
        engineRemoveShaderFromWorldTexture(shader, "*", element)
    end
end
