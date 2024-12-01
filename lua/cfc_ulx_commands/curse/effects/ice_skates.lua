local EFFECT_NAME = "IceSkates"
local FRICTION_MULT = 0
local MAX_SPEED = 4 --%/speed, soft limit
local MAX_ACCEL = 1 --%/speed hu/s^2
local SKATE_SOUND = "physics/plastic/plastic_box_scrape_smooth_loop2.wav"

-- Sound
local SPARKS_PITCH = 150
local SPARKS_PITCH_MAX = 200
local SPARKS_VOLUME = 0.25

local SPARKS_PERCENT_THRESHOLD = 0.25

local SPARKS_MAGNITUDE = 1.25
local SPARKS_RADIUS = 4
local SPARKS_SCALE = 1


local function sign( x )
    if x > 0 then return 1 end
    if x < 0 then return -1 end
    return 0
end

-- Similar to math.Approach, but works for vectors.
-- change is still a number representing the max length of the change.
local function approachVector( current, target, change )
    local diff = target - current
    local effectiveChange = diff:GetNormalized() * math.min( change, diff:Length() )

    return current + effectiveChange
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )

        if SERVER then
            local skateSound = CreateSound( cursedPly, SKATE_SOUND )
            skateSound:Play()
            skateSound:ChangeVolume( 0 )

            cursedPly.CFCUlxCurseIceSkateSound = skateSound
        end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerSpawn", "SetFriction", function( ply )
            if ply ~= cursedPly then return end

            ply:SetFriction( FRICTION_MULT )
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerFootstep", "MuteFootsteps", function( ply )
            if ply ~= cursedPly then return end
            return true
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "SetupMove", "GetMoveDir", function( ply, moveData )
            if ply ~= cursedPly then return end

            if not ply:IsOnGround() then
                if SERVER then
                    cursedPly:SetFriction( 1 )
                    cursedPly:SprintEnable()
                    cursedPly.CFCUlxCurseIceSkateSound:ChangeVolume( 0, 0.1 )
                end

                return
            end

            if SERVER then
                cursedPly:SetFriction( FRICTION_MULT )
                cursedPly:SprintDisable()
            end

            local curVel = moveData:GetVelocity()
            local curSpeedXY = curVel:Length2D()

            local W = moveData:KeyDown( IN_FORWARD )
            local A = moveData:KeyDown( IN_BACK )
            local S = moveData:KeyDown( IN_MOVELEFT )
            local D = moveData:KeyDown( IN_MOVERIGHT )

            local stopped = not ( W or A or S or D )
            local moveDir

            if stopped then
                moveDir = Vector()
            else
                moveDir = ply:GetForward() * sign( moveData:GetForwardSpeed() ) + ply:GetRight() * sign( moveData:GetSideSpeed() )
                moveDir:Normalize()
            end

            local speedGoal = MAX_SPEED * ply:GetMaxSpeed()
            local desiredVel = moveDir * speedGoal

            -- If they're going over the max speed, deaccelerate them faster (also to help the soft limit keep up with sidestrafing)
            local deaccelBoost = math.max( curSpeedXY - MAX_SPEED * ply:GetWalkSpeed(), 0 )

            moveData:SetVelocity( approachVector( curVel, desiredVel, ( MAX_ACCEL * ply:GetMaxSpeed() + deaccelBoost ) * FrameTime() ) )

            local speedPercent = math.min( curSpeedXY / speedGoal, 1 )

            if SERVER then
                cursedPly.CFCUlxCurseIceSkateSound:ChangePitch( SPARKS_PITCH + speedPercent * ( SPARKS_PITCH_MAX - SPARKS_PITCH ) )
                cursedPly.CFCUlxCurseIceSkateSound:ChangeVolume( SPARKS_VOLUME * speedPercent )
            end

            if speedPercent > SPARKS_PERCENT_THRESHOLD then
                local sparkEffect = EffectData()
                sparkEffect:SetOrigin( ply:GetPos() )
                sparkEffect:SetNormal( Vector( 0, 0, 1 ) )
                sparkEffect:SetMagnitude( SPARKS_MAGNITUDE * speedPercent ) --flings them further? makes them more numerous? unknown
                sparkEffect:SetRadius( SPARKS_RADIUS * speedPercent ) --makes the particle thiccer
                sparkEffect:SetScale( SPARKS_SCALE * speedPercent ) --makes them longer

                util.Effect( "Sparks", sparkEffect )
            end

        end )

    end,

    onEnd = function( cursedPly )
        if CLIENT then return end

        cursedPly:SetFriction( 1 )
        cursedPly:SprintEnable()

        cursedPly.CFCUlxCurseIceSkateSound:Stop()
        cursedPly.CFCUlxCurseIceSkateSound = nil
    end,

    minDuration = 30,
    maxDuration = 60,
    onetimeDurationMult = 2,
    excludeFromOnetime = false,
    incompatibileEffects = {},
    groups = {
        "AddedMovement",
        "Friction",
    },
    incompatibleGroups = {
        "Friction",
    },
} )
