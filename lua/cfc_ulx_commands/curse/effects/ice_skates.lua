local EFFECT_NAME = "IceSkates"
local FRICTION_MULT = 0
local MAX_SPEED = 5 --%/speed, soft limit
local MAX_ACCEL = 1 --%/speed hu/s^2

local function sign(x)
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
			cursedPly:SetFriction( FRICTION_MULT )
			cursedPly:SprintDisable()
		end
		
        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerFootstep", "MuteFootsteps", function( ply )
            if ply ~= cursedPly then return end
            return true
        end)
        
        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "SetupMove", "GetMoveDir", function( ply, moveData, _ )
            if ply ~= cursedPly then return end
            if not ply:IsOnGround() then return end

            local curVel = moveData:GetVelocity()
            local curSpeedXY = curVel:Length2D()

            local W = moveData:KeyDown(IN_FORWARD)
            local A = moveData:KeyDown(IN_BACK)
            local S = moveData:KeyDown(IN_MOVELEFT)
            local D = moveData:KeyDown(IN_MOVERIGHT)

            local stopped = not (W or A or S or D)
            local moveDir = ply:GetForward() * sign(moveData:GetForwardSpeed()) + ply:GetRight() * sign(moveData:GetSideSpeed())
            moveDir = stopped and Vector() or moveDir:GetNormalized()

            local speedGoal = MAX_SPEED * ply:GetMaxSpeed()
            local desiredVel = moveDir * speedGoal

            -- If they're going over the max speed, deaccelerate them faster (also to help the soft limit keep up with sidestrafing)
            local deaccelBoost = math.max(curSpeedXY - MAX_SPEED*ply:GetWalkSpeed(), 0)

            moveData:SetVelocity( approachVector( curVel, desiredVel, (MAX_ACCEL*ply:GetMaxSpeed() + deaccelBoost)*FrameTime() ) )
        end )

    end,

    onEnd = function( cursedPly )
        if CLIENT then return end

        cursedPly:SetFriction( 1 )
        cursedPly:SprintEnable()
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
