local EFFECT_NAME = "ResidentEvil"
local CAM_DIST_MAX = 1000
local CAM_FORCE_CHANGE_DIST = 3000
local CAM_PITCH_MIN = -30 -- Note that pitch is backwards, so this is pointing upwards.
local CAM_PITCH_MAX = 0 -- Note that pitch is backwards, so this is pointing downwards.
local CAM_HIT_PUSHBACK = 10 -- Moves the camera away from walls.
local CAM_CHANGE_COOLDOWN = 1
local LOS_DETECTION_INTERVAL = 0.1
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


local CAM_FORCE_CHANGE_DIST_SQR = CAM_FORCE_CHANGE_DIST ^ 2
local IGNORE_CLASSES = {
    -- HL2
    crossbow_bolt = true,
    prop_combine_ball = true,
    npc_satchel = true,
    npc_grenade_frag = true,
    npc_grenade_bugbait = true,

    -- M9K
    m9k_proxy = true,
    m9k_thrown_knife = true,
    m9k_thrown_m61 = true,
    m9k_thrown_sticky_grenade = true,
    m9k_thrown_harpoon = true,
    m9k_nervegasnade = true,
    m9k_thrown_nitrox = true,
    m9k_launched_flare = true,
    m9k_m202_rocket = true,
    m9k_launched_m79 = true,
    m9k_ammo_matador_90mm = true,

    -- CW2
    ent_ins2rpgrocket = true,
    cw_grenade_thrown = true,
    cw_flash_thrown = true,
    cw_smoke_thrown = true,
    cw_40mm_explosive = true,

    -- LFS
    lunasflightschool_missile = true,
}

local camPos = Vector()
local nextCamChangeTime = 0
local localPly = nil
local relocateCamera
local traceFilter

if CLIENT then
    relocateCamera = function()
        local now = CurTime()
        if now < nextCamChangeTime then return end

        nextCamChangeTime = now + CAM_CHANGE_COOLDOWN

        local dir = Angle( math.Rand( CAM_PITCH_MIN, CAM_PITCH_MAX ), math.Rand( -180, 180 ), 0 ):Forward()
        local traceStart = localPly:GetShootPos()

        local tr = util.TraceLine( {
            start = traceStart,
            endpos = traceStart + dir * CAM_DIST_MAX,
            filter = traceFilter,
            mask = MASK_SHOT, -- Would use MASK_VISIBLE_AND_NPCS, but some opaque models have broken flags (such as models/hunter/blocks/cube4x4x1.mdl)
        } )

        camPos = tr.HitPos

        if tr.Hit then
            camPos = camPos + tr.HitNormal * CAM_HIT_PUSHBACK
        end
    end

    traceFilter = function( ent )
        if ent == localPly then return false end
        if not ent:IsValid() then return true end

        local class = ent:GetClass()
        if IGNORE_CLASSES[class] then return false end
        if ent:IsPlayer() then return false end
        if ent:IsNPC() then return false end
        if ent:IsWeapon() then return false end
        if ent:IsVehicle() then return false end

        return true
    end
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then
            cursedPly:CrosshairDisable()

            local function enforceDisableCrosshair( ply )
                if ply ~= cursedPly then return end

                ply:CrosshairDisable()

                CFCUlxCurse.CreateEffectTimer( ply, HOOK_PREFIX .. "DisableCrosshair", 0, 1, function()
                    ply:CrosshairDisable()
                end )
            end

            CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerSpawn", "DisableCrosshair", enforceDisableCrosshair )
            CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerLeaveVehicle", "DisableCrosshair", enforceDisableCrosshair )

            return
        end

        localPly = LocalPlayer()
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
            local startPos = camPos
            local endPos = localPly:GetShootPos()

            if startPos:DistToSqr( endPos ) > CAM_FORCE_CHANGE_DIST_SQR then
                relocateCamera()

                return
            end

            local tr = util.TraceLine( {
                start = startPos,
                endpos = endPos,
                filter = traceFilter,
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

    minDuration = 30,
    maxDuration = 90,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
