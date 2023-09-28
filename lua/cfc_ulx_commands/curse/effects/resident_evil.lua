local EFFECT_NAME = "ResidentEvil"
local CAM_DIST_MAX = 1000
local CAM_PITCH_MIN = -30 -- Note that pitch is backwards, so this is pointing upwards.
local CAM_PITCH_MAX = 0 -- Note that pitch is backwards, so this is pointing downwards.
local CAM_HIT_PUSHBACK = 10 -- Moves the camera away from walls.
local CAM_CHANGE_COOLDOWN = 1
local LOS_DETECTION_INTERVAL = 0.1
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


local camPos = Vector()
local nextCamChangeTime = 0
local relocateCamera

if CLIENT then
    relocateCamera = function()
        local now = CurTime()
        if now < nextCamChangeTime then return end

        nextCamChangeTime = now + CAM_CHANGE_COOLDOWN

        local ply = LocalPlayer()
        local dir = Angle( math.Rand( CAM_PITCH_MIN, CAM_PITCH_MAX ), math.Rand( -180, 180 ), 0 ):Forward()
        local traceStart = ply:GetShootPos()

        local tr = util.TraceLine( {
            start = traceStart,
            endpos = traceStart + dir * CAM_DIST_MAX,
            filter = ply,
            mask = MASK_SHOT, -- Would use MASK_VISIBLE_AND_NPCS, but some opaque models have broken flags (such as models/hunter/blocks/cube4x4x1.mdl)
        } )

        camPos = tr.HitPos

        if tr.Hit then
            camPos = camPos + tr.HitNormal * CAM_HIT_PUSHBACK
        end
    end
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then
            cursedPly:CrosshairDisable()

            return
        end

        relocateCamera()

        hook.Add( "CalcView", HOOK_PREFIX .. "FunnyCam", function( ply, _, _, fov )
            local view = {
                origin = camPos,
                angles = ( ply:GetShootPos() - camPos ):Angle(),
                fov = fov,
                drawviewer = true
            }

            return view
        end )

        timer.Create( HOOK_PREFIX .. "CheckLineOfSight", LOS_DETECTION_INTERVAL, 0, function()
            local tr = util.TraceLine( {
                start = camPos,
                endpos = cursedPly:GetShootPos(),
                mask = MASK_SHOT,
            } )

            if tr.Hit and tr.Entity ~= cursedPly then
                relocateCamera()
            end
        end )
    end,

    onEnd = function( cursedPly )
        if SERVER then
            cursedPly:CrosshairEnable()

            return
        end

        hook.Remove( "CalcView", HOOK_PREFIX .. "FunnyCam" )
        timer.Remove( HOOK_PREFIX .. "CheckLineOfSight" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
