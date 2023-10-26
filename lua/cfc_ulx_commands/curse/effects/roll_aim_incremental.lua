local EFFECT_NAME = "RollAimIncremental"
local ANGLE_SPEED_MIN = 0.0001
local ANGLE_SPEED_MAX = 0.001


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        -- Randomly select -1 or 1
        local rollMult = math.random( 0, 1 ) == 0 and -1 or 1

        local rollStep = math.Rand( ANGLE_SPEED_MIN, ANGLE_SPEED_MAX ) * rollMult
        local offsetAng = Angle( 0, 0, rollStep )
        local realAng

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            local isClient = cmd:CommandNumber() == 0
            if not isClient then return end

            if not realAng then
                realAng = cmd:GetViewAngles()
            end

            realAng.y = realAng.y - cmd:GetMouseX() * 0.022
            realAng.x = math.Clamp( realAng.x + cmd:GetMouseY() * 0.022, -89, 89 )
            realAng:Normalize()

            realAng = realAng + offsetAng

            cmd:SetViewAngles( realAng )
        end )
    end,

    onEnd = function( cursedPly )
        if SERVER then return end

        local eyeAngles = cursedPly:LocalEyeAngles()
        eyeAngles.roll = 0

        CFCUlxCurse.RemoveEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo" )
        cursedPly:SetEyeAngles( eyeAngles )
    end,

    minDuration = 20,
    maxDuration = 50,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
