local EFFECT_NAME = "Lidar"

local MESH_LIMIT = 8000
local VERTS_PER_MESH = 500 * 3
local VERTS_PER_EXPIRABLE_MESH = 50 * 3

local MESH_EXPIRE_TIME = 2
local SCAN_INTERVAL = 0.01
local DOTS_PER_SCAN = 50
local DOT_SPREAD = 60
local DOT_SIZE = 3
local DOT_HITBOX_SIZE = 2

local BONUS_SCAN_SPREAD = 5
local BONUS_SCAN_PLAYER = 2 -- If a player or NPC is hit, adds a few bonus scans, to make it easier to see them.

local BALL_SPEED = 300
local BALL_DURATION = 120
local BALL_MODEL = "models/hunter/misc/sphere075x075.mdl"
local BALL_SCAN_INTERVAL = 0.03
local BALL_COLOR = Color( 0, 230, 255, 255 )
local BALL_RADIUS = 36 / 2

local SCAN_NORMAL_SOUND = "physics/metal/soda_can_impact_soft1.wav"
local SCAN_PLAYER_SOUND = "buttons/button17.wav"

local SKY_COLOR = Color( 130, 230, 230, 255 )
local WATER_COLOR = Color( 50, 100, 225, 255 )
local SLIME_COLOR = Color( 140, 120, 15, 255 )
local PLAYER_COLOR = Color( 255, 0, 0, 255 )
local NPC_COLOR = Color( 200, 0, 255, 255 )

local TRACE_MASK = MASK_SOLID + CONTENTS_WATER + CONTENTS_SLIME
local TRACE_MASK_HITBOXES = MASK_SHOT + CONTENTS_WATER + CONTENTS_SLIME


local DOT_SPREAD_HALF = DOT_SPREAD / 2
local BONUS_SCAN_SPREAD_HALF = BONUS_SCAN_SPREAD / 2
local ROTATE_THIRD = 360 / 3
local VECTOR_ZERO = Vector( 0, 0, 0 )

local meshes = {}
local expirableMeshes = {}
local curMesh = nil
local curMeshChanged = false
local curMeshData = {}
local curExpirableMesh = nil
local curExpirableMeshChanged = false
local curExpirableMeshData = {}
local curExpirableMeshExpireTime = math.huge
local meshCount = 0
local expirableMeshCount = 0
local meshHead = 1
local curVertCount = 0
local curExpirableVertCount = 0
local placingDots = false
local showDotHint = false
local lidarMat = nil
local ballEnt = nil

local addBonusDots

local mathRand = math.Rand
local bitBand = bit.band
local utilTraceLine = util.TraceLine
local renderGetSurfaceColor = CLIENT and render.GetSurfaceColor
local renderSetMaterial = CLIENT and render.SetMaterial
local drawSimpleText = CLIENT and draw.SimpleText
local surfaceSetDrawColor = CLIENT and surface.SetDrawColor


if SERVER then
    util.PrecacheModel( "BALL_MODEL" )
end


local function spreadDirFast( ang, right, up, spreadHalf )
    ang = Angle( ang.p, ang.y, ang.r )
    ang:RotateAroundAxis( right, mathRand( -spreadHalf, spreadHalf ) )
    ang:RotateAroundAxis( up, mathRand( -spreadHalf, spreadHalf ) )

    return ang:Forward()
end

local function addDot( startPos, dir, filter, allowBonusScans )
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
    local hitEnt = tr.Entity
    local contents = tr.Contents
    local color
    local putOnExpirableMesh = false
    local size = DOT_SIZE
    local snd = SCAN_NORMAL_SOUND

    hitEnt = IsValid( hitEnt ) and hitEnt or nil

    if hitEnt and ( hitEnt:IsPlayer() or hitEnt:IsNPC() ) then
        local tr2 = utilTraceLine( {
            start = startPos,
            endpos = endPos,
            filter = filter,
            mask = TRACE_MASK_HITBOXES,
        } )

        local newEnt = tr2.Entity

        if tr2.Hit then
            if newEnt == hitEnt then
                size = DOT_HITBOX_SIZE

                if allowBonusScans then
                    addBonusDots( dir, startPos, filter, BONUS_SCAN_PLAYER )
                end
            end

            hitPos = tr2.HitPos
            hitNormal = tr2.HitNormal
            hitEnt = newEnt
        end
    end

    if tr.HitSky then
        color = SKY_COLOR
    elseif bitBand( contents, CONTENTS_WATER ) ~= 0 then
        color = WATER_COLOR
    elseif bitBand( contents, CONTENTS_SLIME ) ~= 0 then
        color = SLIME_COLOR
    elseif hitEnt and hitEnt:IsPlayer() then
        color = PLAYER_COLOR
        putOnExpirableMesh = true
        snd = SCAN_PLAYER_SOUND
    elseif hitEnt and hitEnt:IsNPC() then
        color = NPC_COLOR
        snd = SCAN_PLAYER_SOUND
    else
        color = renderGetSurfaceColor( hitPos - dir * 5, hitPos + dir * 5 )
        color = Color( color.x * 255, color.y * 255, color.z * 255, 255 )
    end

    local offsetAng = Vector( hitNormal.z, hitNormal.x, hitNormal.y ):Angle()
    offsetAng:RotateAroundAxis( hitNormal, mathRand( 0, 180 ) )

    for _ = 1, 3 do
        offsetAng:RotateAroundAxis( hitNormal, -ROTATE_THIRD )

        local offset = offsetAng:Forward()

        if size ~= 1 then
            offset = offset * size
        end

        if putOnExpirableMesh then
            curExpirableMeshChanged = true
            curExpirableVertCount = curExpirableVertCount + 1
            curExpirableMeshData[curExpirableVertCount] = {
                pos = hitPos + offset,
                color = color,
                normal = hitNormal,
            }
        else
            curMeshChanged = true
            curVertCount = curVertCount + 1
            curMeshData[curVertCount] = {
                pos = hitPos + offset,
                color = color,
                normal = hitNormal,
            }
        end
    end

    EmitSound( snd, hitPos, 0, CHAN_AUTO, 0.1, 75, 0, mathRand( 80, 110 ) )
end

local function updateCurMesh()
    if not curMeshChanged then return end

    if curMesh then
        curMesh:Destroy()
    end

    curMesh = Mesh()
    curMesh:BuildFromTriangles( curMeshData )
    curMeshChanged = false

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

local function updateCurExpirableMesh()
    if not curExpirableMeshChanged then return end

    if curExpirableMesh then
        curExpirableMesh:Destroy()
    end

    curExpirableMesh = Mesh()
    curExpirableMesh:BuildFromTriangles( curExpirableMeshData )
    curExpirableMeshChanged = false
    curExpirableMeshExpireTime = CurTime() + MESH_EXPIRE_TIME

    -- Split off into a new mesh
    if curExpirableVertCount <= VERTS_PER_EXPIRABLE_MESH then return end

    expirableMeshCount = expirableMeshCount + 1
    expirableMeshes[expirableMeshCount] = {
        mesh = curExpirableMesh,
        expireTime = CurTime() + MESH_EXPIRE_TIME,
    }

    curExpirableMesh = nil
    curExpirableMeshData = {}
    curExpirableVertCount = 0
end

local function addDots( eyePos, eyeAng )
    local eyeRight = eyeAng:Right()
    local eyeUp = eyeAng:Up()
    local filter = LocalPlayer()

    for _ = 1, DOTS_PER_SCAN do
        local dir = spreadDirFast( eyeAng, eyeRight, eyeUp, DOT_SPREAD_HALF )

        addDot( eyePos, dir, filter, true )
    end

    updateCurMesh()
    updateCurExpirableMesh()
end

local function expireCurExpirableMesh()
    if not curExpirableMesh then return end
    if CurTime() < curExpirableMeshExpireTime then return end

    curExpirableMesh:Destroy()
    curExpirableMesh = nil
    curExpirableMeshData = {}
    curExpirableVertCount = 0
    curExpirableMeshChanged = false
end

local function drawMeshes()
    local now = CurTime()

    surfaceSetDrawColor( 255, 255, 255, 255 )
    renderSetMaterial( lidarMat )

    for i = 1, meshCount do
        meshes[i]:Draw()
    end

    for i = expirableMeshCount, 1, -1 do
        local meshInfo = expirableMeshes[i]
        local meshObj = meshInfo.mesh

        if meshInfo.expireTime < now then
            meshObj:Destroy()
            table.remove( expirableMeshes, i )
            expirableMeshCount = expirableMeshCount - 1
        else
            meshObj:Draw()
        end
    end

    if curMesh then
        curMesh:Draw()
    end

    if curExpirableMesh then
        curExpirableMesh:Draw()
    end
end

local function spawnBall( pos, dir )
    if IsValid( ballEnt ) then
        ballEnt:Remove()
    end

    ballEnt = ents.CreateClientProp( BALL_MODEL )
    ballEnt:SetPos( pos )
    ballEnt:Spawn()

    local physObj = ballEnt:GetPhysicsObject()
    physObj:EnableGravity( false )
    physObj:SetVelocity( dir * BALL_SPEED )

    CFCUlxCurse.CreateEffectTimer( LocalPlayer(), EFFECT_NAME, "RemoveBall", BALL_DURATION, 0, function()
        if not IsValid( ballEnt ) then return end

        ballEnt:Remove()
    end )
end

local function drawBall()
    if not IsValid( ballEnt ) then return end

    render.SetColorMaterial()
    render.DrawSphere( ballEnt:GetPos(), BALL_RADIUS, 50, 50, BALL_COLOR )
end

addBonusDots = function( dir, startPos, filter, amount )
    local ang = dir:Angle()
    local right = ang:Right()
    local up = ang:Up()

    for _ = 1, amount do
        local bonusDir = spreadDirFast( ang, right, up, BONUS_SCAN_SPREAD_HALF )

        addDot( startPos, bonusDir, filter, false )
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
        curVertCount = 0
        curExpirableMesh = nil
        curExpirableMeshData = {}
        curExpirableVertCount = 0
        curExpirableMeshExpireTime = math.huge
        meshCount = 0
        expirableMeshCount = 0
        meshHead = 1

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "RenderScene", "CustomRender", function()
            cam.Start3D()
                drawMeshes()
                drawBall()
            cam.End3D()

            cam.Start2D()
                render.RenderHUD( 0, 0, ScrW(), ScrH() )
            cam.End2D()

            if showDotHint then
                cam.Start2D()
                    drawSimpleText( "Hold E to place dots", "DermaLarge", ScrW() / 2, ScrH() / 2 + 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    drawSimpleText( "Press Alt + E to spawn a scanner sphere", "DermaLarge", ScrW() / 2, ScrH() / 2 + 50 + 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                cam.End2D()
            end

            return true
        end )

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "Scan", SCAN_INTERVAL, 0, function()
            expireCurExpirableMesh()

            if placingDots then
                local eyePos = cursedPly:EyePos()
                local eyeAng = cursedPly:EyeAngles()

                addDots( eyePos, eyeAng )
            end
        end )

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "BallScan", BALL_SCAN_INTERVAL, 0, function()
            if not IsValid( ballEnt ) then return end

            local pos = ballEnt:GetPos()
            local ang = Angle( math.Rand( -45, 45 ), math.Rand( -180, 180 ), 0 )

            addDots( pos, ang )
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "KeyPress", "Input", function( _, key )
            if not IsFirstTimePredicted() then return end

            if key == IN_USE then
                placingDots = true
                showDotHint = false

                if input.IsKeyDown( KEY_LALT ) then
                    spawnBall( cursedPly:EyePos(), cursedPly:EyeAngles():Forward() )
                end
            end
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "KeyRelease", "Input", function( _, key )
            if not IsFirstTimePredicted() then return end

            if key == IN_USE then
                placingDots = false
            end
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "Tick", "MaintainBallSpeed", function()
            if not IsValid( ballEnt ) then return end

            local physObj = ballEnt:GetPhysicsObject()
            local vel = physObj:GetVelocity()
            local speed = vel:Length()

            if speed == 0 then
                ballEnt:Remove()

                return
            end

            physObj:SetVelocity( BALL_SPEED * vel / speed )
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

        for i = 1, expirableMeshCount do
            local meshInfo = expirableMeshes[i]
            local meshObj = meshInfo.mesh

            meshObj:Destroy()
        end

        if curMesh then
            curMesh:Destroy()
            curMesh = nil
        end

        if curExpirableMesh then
            curExpirableMesh:Destroy()
            curExpirableMesh = nil
        end

        if IsValid( ballEnt ) then
            ballEnt:Remove()
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
