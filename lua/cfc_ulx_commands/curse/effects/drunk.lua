local EFFECT_NAME = "Drunk"
local SPRING_LENGTH = 200
local SPRING_CONSTANT = 0.001
local SPRING_DAMPING = 0.025
local SPRING_TILT = 2 -- Multiplier for amount of screen tilt (roll) to apply, based on the current spring velocity
local SPRING_ANG_LIMIT = 70 -- 0-90, exclusive


local realAng
local springPos
local springVel = Vector( 0, 0, 0 )
local springVelMult = 1 - SPRING_DAMPING
local springDistLimit = SPRING_LENGTH * math.sin( math.rad( SPRING_ANG_LIMIT ) )
local springDistLimitSqr = springDistLimit ^ 2


local function getDrunkEyeAngles()
    local origin = EyePos()
    local realAngForward = realAng:Forward()
    local desPos = origin + realAngForward * SPRING_LENGTH

    -- Spring physics.
    local oldToDes = desPos - springPos
    local springAccel = SPRING_CONSTANT * oldToDes

    springPos = springPos + springVel
    springVel = springVel * springVelMult + springAccel

    -- Clamp spring position to a sphere centered around the desired position. Prevents the camera from pointing backwards, etc.
    local desToSpring = springPos - desPos
    local desToSpringLengthSqr = desToSpring:LengthSqr()

    if desToSpringLengthSqr > springDistLimitSqr then
        springPos = desPos + desToSpring * ( springDistLimit / math.sqrt( desToSpringLengthSqr ) )
    end

    -- Calculate the angle to look at the spring from the origin, and apply tilt based on the spring velocity.
    local springAng = ( springPos - origin ):Angle()
    springAng[3] = springAng:Right():Dot( springVel ) * SPRING_TILT

    return springAng
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local lastDrunkEyeAng
        realAng = nil
        springVel = Vector( 0, 0, 0 )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            local isClient = cmd:CommandNumber() == 0

            if not realAng then
                realAng = cmd:GetViewAngles()
                springPos = cursedPly:EyePos() + realAng:Forward() * SPRING_LENGTH
                lastDrunkEyeAng = realAng
            end

            realAng.y = realAng.y - cmd:GetMouseX() * 0.022
            realAng.x = math.Clamp( realAng.x + cmd:GetMouseY() * 0.022, -89, 89 )
            realAng:Normalize()

            if isClient then
                lastDrunkEyeAng = getDrunkEyeAngles()
            end

            cmd:SetViewAngles( lastDrunkEyeAng )
        end )
    end,

    onEnd = function( cursedPly )
        if not IsValid( cursedPly ) then return end

        local eyeAng = cursedPly:LocalEyeAngles()
        eyeAng[3] = 0

        cursedPly:SetEyeAngles( eyeAng )
    end,

    minDuration = 30,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatabileEffects = {},
} )
