local EFFECT_NAME = "Rapture"
local SPEED_MIN = 10
local SPEED_MAX = 75
local INTERVAL_MIN = 0.05
local INTERVAL_MAX = 2


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        local vel = Vector( 0, 0, 10 )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "Think", "GetYoinked", function()
            if not IsValid( cursedPly ) then return end

            cursedPly:SetVelocity( vel )
        end )

        local timerNameEff
        timerNameEff = CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "ChangeVelocity", INTERVAL_MIN, 0, function()
            vel = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * math.Rand( SPEED_MIN, SPEED_MAX )
            timer.Adjust( timerNameEff, math.Rand( INTERVAL_MIN, INTERVAL_MAX ) )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatabileEffects = {},
} )
