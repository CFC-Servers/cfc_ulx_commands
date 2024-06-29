local EFFECT_NAME = "Lidar"
local VERTS_PER_MESH = 500 * 3
local MESH_LIMIT = 5000
local SCAN_INTERVAL = 0.01
local DOTS_PER_SCAN = 50
local DOT_SPREAD = 45
local DOT_SIZE = 3
local SKY_COLOR = Color( 130, 230, 230, 255 )
local WATER_COLOR = Color( 50, 100, 225, 255 )
local SLIME_COLOR = Color( 140, 120, 15, 255 )
local TRACE_MASK = MASK_SOLID + CONTENTS_WATER + CONTENTS_SLIME


local DOT_SPREAD_HALF = DOT_SPREAD / 2
local ROTATE_THIRD = 360 / 3
local VECTOR_ZERO = Vector( 0, 0, 0 )

local meshes = {}
local curMesh = nil
local curMeshData = {}
local meshCount = 0
local meshHead = 1
local curVertCount = 0
local placingDots = false
local showDotHint = false
local lidarMat = nil

local mathRand = math.Rand
local bitBand = bit.band
local utilTraceLine = util.TraceLine
local playerGetAll = player.GetAll
local renderGetSurfaceColor = render.GetSurfaceColor
local renderSetMaterial = render.SetMaterial
local drawSimpleText = draw.SimpleText
local surfaceSetDrawColor = surface.SetDrawColor


local function spreadDirFast( ang, right, up )
    ang = Angle( ang.p, ang.y, ang.r )
    ang:RotateAroundAxis( right, mathRand( -DOT_SPREAD_HALF, DOT_SPREAD_HALF ) )
    ang:RotateAroundAxis( up, mathRand( -DOT_SPREAD_HALF, DOT_SPREAD_HALF ) )

    return ang:Forward()
end

local function addDot( startPos, dir, filter )
    local endPos = startPos + dir * 50000
    local tr = utilTraceLine( {
        start = startPos,
        endpos = endPos,
        filter = filter,
        mask = TRACE_MASK,
    } )

    if not tr.Hit then return end

    local hitNormal = tr.HitNormal
    if hitNormal == VECTOR_ZERO then return end

    local hitPos = tr.HitPos
    local contents = tr.Contents
    local color

    if tr.HitSky then
        color = SKY_COLOR
    elseif bitBand( contents, CONTENTS_WATER ) ~= 0 then
        color = WATER_COLOR
    elseif bitBand( contents, CONTENTS_SLIME ) ~= 0 then
        color = SLIME_COLOR
    else
        color = renderGetSurfaceColor( hitPos - dir * 5, hitPos + dir * 5 )
        color = Color( color.x * 255, color.y * 255, color.z * 255, 255 )
    end

    local offsetAng = Vector( hitNormal.z, hitNormal.x, hitNormal.y ):Angle()
    offsetAng:RotateAroundAxis( hitNormal, mathRand( 0, 180 ) )

    for _ = 1, 3 do
        offsetAng:RotateAroundAxis( hitNormal, -ROTATE_THIRD )

        local offset = offsetAng:Forward()

        if DOT_SIZE ~= 1 then
            offset = offset * DOT_SIZE
        end

        curVertCount = curVertCount + 1
        curMeshData[curVertCount] = {
            pos = hitPos + offset,
            color = color,
            normal = hitNormal,
        }
    end
end

local function updateCurMesh()
    if curMesh then
        curMesh:Destroy()
    end

    curMesh = Mesh()
    curMesh:BuildFromTriangles( curMeshData )

    -- Split off into a new mesh
    if curVertCount <= VERTS_PER_MESH then return end

    local oldMesh = meshes[meshHead]

    if oldMesh then
        oldMesh:Destroy()
    end

    meshes[meshHead] = curMesh
    curMesh = nil
    curMeshData = {}
    curVertCount = 0

    meshHead = meshHead + 1

    -- Keep incrementing dotCount until we reach DOT_MAX.
    -- Keep incrementing dotHead until the max is reached, then wrap around to 1.
    -- This lets us replace old dots without needing to shift indices around with table.remove().
    if meshCount < MESH_LIMIT then
        meshCount = meshCount + 1

        if meshCount == MESH_LIMIT then
            meshHead = 1
        end
    elseif meshHead > meshCount then
        meshHead = 1
    end
end

local function addDots( eyePos, eyeAng )
    local eyeRight = eyeAng:Right()
    local eyeUp = eyeAng:Up()
    local filter = playerGetAll()

    for _ = 1, DOTS_PER_SCAN do
        local dir = spreadDirFast( eyeAng, eyeRight, eyeUp )

        addDot( eyePos, dir, filter )
    end

    updateCurMesh()
end

local function drawMeshes()
    surfaceSetDrawColor( 255, 255, 255, 255 )
    renderSetMaterial( lidarMat )

    for i = 1, meshCount do
        meshes[i]:Draw()
    end

    if curMesh then
        curMesh:Draw()
    end
end


if CLIENT then
    lidarMat = CreateMaterial( "cfc_ulx_commands_curse_lidar", "UnlitGeneric", {
        ["$basetexture"] = "color/white",
        ["$vertexcolor"] = 1,
    } )
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        placingDots = false
        showDotHint = true
        curMesh = nil
        curMeshData = {}
        meshCount = 0
        meshHead = 1

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "RenderScene", "CustomRender", function()
            cam.Start3D()
                drawMeshes()
            cam.End3D()

            cam.Start2D()
                render.RenderHUD( 0, 0, ScrW(), ScrH() )
            cam.End2D()

            if showDotHint then
                cam.Start2D()
                    drawSimpleText( "Hold E to place dots", "DermaLarge", ScrW() / 2, ScrH() / 2 + 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                cam.End2D()
            end

            return true
        end )

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "Scan", SCAN_INTERVAL, 0, function()
            if not placingDots then return end

            local eyePos = cursedPly:EyePos()
            local eyeAng = cursedPly:EyeAngles()

            addDots( eyePos, eyeAng )
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "KeyPress", "Input", function( _, key )
            if not IsFirstTimePredicted() then return end

            if key == IN_USE then
                placingDots = true
                showDotHint = false
            end
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "KeyRelease", "Input", function( _, key )
            if not IsFirstTimePredicted() then return end

            if key == IN_USE then
                placingDots = false
            end
        end )
    end,

    onEnd = function()
        if SERVER then return end

        for i = 1, MESH_LIMIT do
            local oldMesh = meshes[i]

            if oldMesh then
                oldMesh:Destroy()
            end

            meshes[i] = nil
        end

        if curMesh then
            curMesh:Destroy()
            curMesh = nil
        end
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {},
    groups = {
        "VisualOnly",
        "ScreenOverlay",
    },
    incompatibleGroups = {
        "ScreenOverlay",
        "PP",
    },
} )
