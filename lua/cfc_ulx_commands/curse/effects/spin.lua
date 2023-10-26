local EFFECT_NAME = "Spin"
local SPEED_MIN = 0.5
local SPEED_MAX = 1.5


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        -- Randomly select -1 or 1
        local spinMult = math.random( 0, 1 ) == 0 and -1 or 1

        local spinStep = math.Rand( SPEED_MIN, SPEED_MAX ) * spinMult

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "SPEEN", function( cmd )
            if cmd:CommandNumber() ~= 0 then return end

            local ang = cmd:GetViewAngles()
            ang = ang + Angle( 0, spinStep, 0 )

            cmd:SetViewAngles( ang )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 5,
    maxDuration = 20,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
