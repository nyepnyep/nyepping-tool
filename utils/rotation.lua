-- Rotation utility functions for NMT
-- Handles rotation conversions between MTA coordinate system and standard XYZ

function rotateX(rx, ry, rz, add)
    rx, ry, rz = convertRotationFromMTA(rx, ry, rz)
    rx = rx + add
    rx, ry, rz = convertRotationToMTA(rx, ry, rz)
    return rx, ry, rz
end

function rotateY(rx, ry, rz, add)
    return rx, ry + add, rz
end

function rotateZ(rx, ry, rz, add)
    ry = ry + 90
    rx, ry, rz = convertRotationFromMTA(rx, ry, rz)
    rx = rx - add
    rx, ry, rz = convertRotationToMTA(rx, ry, rz)
    ry = ry - 90
    return rx, ry, rz
end

-- XYZ euler rotation to YXZ euler rotation
function convertRotationToMTA(rx, ry, rz)
    rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)
    local sinX = math.sin(rx)
    local cosX = math.cos(rx)
    local sinY = math.sin(ry)
    local cosY = math.cos(ry)
    local sinZ = math.sin(rz)
    local cosZ = math.cos(rz)

    local newRx = math.asin(cosY * sinX)
    local newRy = math.atan2(sinY, cosX * cosY)
    local newRz = math.atan2(cosX * sinZ - cosZ * sinX * sinY, cosX * cosZ + sinX * sinY * sinZ)

    return math.deg(newRx), math.deg(newRy), math.deg(newRz)
end

-- YXZ rotation to XYZ rotation
function convertRotationFromMTA(rx, ry, rz)
    rx = math.rad(rx)
    ry = math.rad(ry)
    rz = math.rad(rz)

    local sinX = math.sin(rx)
    local cosX = math.cos(rx)
    local sinY = math.sin(ry)
    local cosY = math.cos(ry)
    local sinZ = math.sin(rz)
    local cosZ = math.cos(rz)

    return math.deg(math.atan2(sinX, cosX * cosY)), math.deg(math.asin(cosX * sinY)),
        math.deg(math.atan2(cosZ * sinX * sinY + cosY * sinZ, cosY * cosZ - sinX * sinY * sinZ))
end

function cos(n)
    return math.cos(math.rad(n))
end

function sin(n)
    return math.sin(math.rad(n))
end
