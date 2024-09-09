local EFFECT_NAME = "Cyberspace"
local EFFECT_NAME_SUPER = "SuperCyberspace" -- Same as Cyberspace, but allows ents to be seen through the world. Still beholdent to the sight radius.
local BACKGROUND_COLOR = Color( 0, 35, 75 )
local WIREFRAME_COLOR = Color( 75, 150, 180 )
local GRID_COLOR = Color( 0, 50, 115 )
local SIGHT_RADIUS = 500
local BACKGROUND_RADIUS = SIGHT_RADIUS * 2
local SPHERE_DETAIL = 50
local VERT_SCRAPE_TIME_LIMIT = 1 / 60
local MESH_BUILD_INTERVAL = 0.5
local GRID_SPACING = 20
local BAD_CLASSES = {
    ["class C_BaseFlex"] = true,
    ["viewmodel"] = true,
    ["manipulate_bone"] = true,
    ["physgun_beam"] = true,
    ["gmod_hands"] = true,
    ["quad_prop"] = true,
}


local VERT_GROUP_SIZE_LIMIT = 65535 - 3 * 100
local GRID_LINE_COUNT = math.ceil( SIGHT_RADIUS / GRID_SPACING )
local VECTOR_DOWN_SIGHT = Vector( 0, 0, -SIGHT_RADIUS )

local ignorezMat
local wireframeMat

if CLIENT then
    ignorezMat = CreateMaterial( "cfc_ulx_commands_curse_cyberspace_ignorez", "UnlitGeneric", {
        ["$ignorez"] = 1,
        ["$color2"] = "[" .. tostring( BACKGROUND_COLOR:ToVector() ) .. "]",
    } )

    wireframeMat = CreateMaterial( "cfc_ulx_commands_curse_cyberspace_wireframe", "UnlitGeneric", {
        ["$model"] = 1,
        ["$wireframe"] = 1,
        ["$color2"] = "[" .. tostring( WIREFRAME_COLOR:ToVector() ) .. "]",
    } )
end


local worldMeshes = {}
local curVertGroup = {}
local curVertGroupSize = 0
local vertGroups = { curVertGroup }
local worldBrushes
local curBrushInd = 0
local worldMeshesDone = false
local worldVertsDone = false
local nextWorldMeshBuildTime = 0


local function nearestMultiple( x, mult )
    if mult == 0 then return x end

    local positiveMultiple = math.ceil( x / mult ) * mult
    local negativeMultiple = math.floor( x / mult ) * mult

    if math.abs( x - positiveMultiple ) < math.abs( x - negativeMultiple ) then
        return positiveMultiple
    else
        return negativeMultiple
    end
end

local function scrapeWorldVerts()
    local now = SysTime()

    while SysTime() - now < VERT_SCRAPE_TIME_LIMIT do
        curBrushInd = curBrushInd + 1
        local brush = worldBrushes[curBrushInd]

        if not brush then
            worldVertsDone = true
            break
        end

        if curVertGroupSize >= VERT_GROUP_SIZE_LIMIT then
            curVertGroup = {}
            curVertGroupSize = 0
            table.insert( vertGroups, curVertGroup )
        end

        local verts = brush:GetVertices()
        local vertCount = #verts

        if vertCount == 3 then
            for i = 1, 3 do
                local vert = verts[i]

                curVertGroupSize = curVertGroupSize + 1
                curVertGroup[curVertGroupSize] = {
                    pos = vert,
                }
            end
        elseif vertCount > 3 then -- Should be impossible to have a brush with less than three, but for just in case.
            local firstVert = verts[1]
            local prevVert = verts[3]

            curVertGroupSize = curVertGroupSize + 1
            curVertGroup[curVertGroupSize] = {
                pos = firstVert,
            }

            local vert2 = verts[2]

            curVertGroupSize = curVertGroupSize + 1
            curVertGroup[curVertGroupSize] = {
                pos = vert2,
            }

            curVertGroupSize = curVertGroupSize + 1
            curVertGroup[curVertGroupSize] = {
                pos = prevVert,
            }

            for i = 4, vertCount do
                local vert = verts[i]

                curVertGroupSize = curVertGroupSize + 1
                curVertGroup[curVertGroupSize] = {
                    pos = firstVert,
                }

                curVertGroupSize = curVertGroupSize + 1
                curVertGroup[curVertGroupSize] = {
                    pos = prevVert,
                }

                curVertGroupSize = curVertGroupSize + 1
                curVertGroup[curVertGroupSize] = {
                    pos = vert,
                }

                prevVert = vert
            end
        end
    end
end

local function buildWorldMeshes()
    local now = CurTime()
    if now < nextWorldMeshBuildTime then return end

    nextWorldMeshBuildTime = now + MESH_BUILD_INTERVAL

    if #vertGroups == 0 then
        worldMeshesDone = true
        return
    end

    local vertGroup = table.remove( vertGroups, 1 )
    local mesh = Mesh()
    mesh:BuildFromTriangles( vertGroup )

    table.insert( worldMeshes, mesh )
end

local function drawBackgroundSphere()
    render.SetColorMaterial()
    render.SetMaterial( ignorezMat )
    render.DrawSphere( EyePos(), -BACKGROUND_RADIUS, SPHERE_DETAIL, SPHERE_DETAIL, BACKGROUND_COLOR )
end

local function drawWorld()
    if not worldMeshesDone then
        if worldVertsDone then
            buildWorldMeshes()
        else
            scrapeWorldVerts()
        end

        return
    end

    render.SetMaterial( wireframeMat )

    for _, mesh in ipairs( worldMeshes ) do
        mesh:Draw()
    end
end

local function drawGridLines()
    local startPos = EyePos()
    startPos[1] = nearestMultiple( startPos[1], GRID_SPACING )
    startPos[2] = nearestMultiple( startPos[2], GRID_SPACING )
    local endPos = startPos + VECTOR_DOWN_SIGHT

    local tr = util.TraceLine( {
        start = startPos,
        endpos = endPos,
        mask = MASK_SOLID_BRUSHONLY,
        collisiongroup = COLLISION_GROUP_DEBRIS,
    } )

    if not tr.HitWorld then return end
    if not tr.Hit then return end

    local hitPos = tr.HitPos
    local hitNormal = tr.HitNormal
    local ang = hitNormal:Angle()
    local xDir = ang:Right()
    local yDir = ang:Up()

    local edgeX = hitPos + xDir * SIGHT_RADIUS
    local edgeXN = hitPos - xDir * SIGHT_RADIUS
    local edgeY = hitPos + yDir * SIGHT_RADIUS
    local edgeYN = hitPos - yDir * SIGHT_RADIUS

    render.DrawLine( edgeXN, edgeX, GRID_COLOR, true )
    render.DrawLine( edgeYN, edgeY, GRID_COLOR, true )

    for i = 1, GRID_LINE_COUNT do
        local x = i * GRID_SPACING
        local y = i * GRID_SPACING

        render.DrawLine( edgeXN + y * yDir, edgeX + y * yDir, GRID_COLOR, true )
        render.DrawLine( edgeYN + x * xDir, edgeY + x * xDir, GRID_COLOR, true )
        render.DrawLine( edgeXN - y * yDir, edgeX - y * yDir, GRID_COLOR, true )
        render.DrawLine( edgeYN - x * xDir, edgeY - x * xDir, GRID_COLOR, true )
    end
end

local function drawEnts()
    render.BrushMaterialOverride( wireframeMat )
    render.MaterialOverride( wireframeMat )
    render.SetShadowsDisabled( true )

    for _, ent in ipairs( ents.GetAll() ) do
        if
            ent.DrawModel and
            IsValid( ent ) and
            not BAD_CLASSES[ent:GetClass()] and
            not ent:IsWeapon() and
            not ent:IsEffectActive( EF_BONEMERGE ) and
            not ent:IsEffectActive( EF_NODRAW )
          then
            ent:DrawModel()
        end
    end
end

local function drawCoveringSphere()
    render.SetColorMaterial()
    render.DrawSphere( EyePos(), -SIGHT_RADIUS, SPHERE_DETAIL, SPHERE_DETAIL, BACKGROUND_COLOR )
end

local function onCurseStart( effectName, cursedPly )
    if SERVER then return end

    if not worldBrushes then
        worldBrushes = game.GetWorld():GetBrushSurfaces()
    end

    local firstPass = false

    CFCUlxCurse.AddEffectHook( cursedPly, effectName, "RenderScene", "CustomRender", function()
        firstPass = true
        render.SetShadowsDisabled( true )
    end )

    CFCUlxCurse.AddEffectHook( cursedPly, effectName, "PreDrawTranslucentRenderables", "CustomRender", function()
        return true -- Block normal entity rendering
    end )

    CFCUlxCurse.AddEffectHook( cursedPly, effectName, "PreDrawOpaqueRenderables", "CustomRender", function( _, skybox, skybox3d )
        if not firstPass then return true end -- Only draw our stuff once per frame, since this is called multiple times
        if skybox or skybox3d then return true end

        firstPass = false

        drawBackgroundSphere()
        drawWorld()
        drawGridLines()
        drawEnts()
        drawCoveringSphere()

        return true -- Block normal entity rendering
    end )
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        onCurseStart( EFFECT_NAME, cursedPly )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {
        "Isometric",
        "TopDown",
    },
    groups = {
        "VisualOnly",
        "ScreenOverlay",
    },
    incompatibleGroups = {
        "ScreenOverlay",
        "PP",
    },
} )

CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME_SUPER,

    onStart = function( cursedPly )
        onCurseStart( EFFECT_NAME_SUPER, cursedPly )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME_SUPER, "RenderScene", "ESP_Mode", function()
            render.WorldMaterialOverride( wireframeMat )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
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
