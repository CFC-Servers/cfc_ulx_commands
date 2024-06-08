local EFFECT_NAME = "SanFransisco"
local AMPLITUDE_MIN = 3
local AMPLITUDE_MAX = 8
local AMPLITUDE_MIN_GROWTH = 2 -- Per second
local AMPLITUDE_MAX_GROWTH = 4 -- Per second
local AMPLITUDE_MIN_LIMIT = AMPLITUDE_MIN * 15
local AMPLITUDE_MAX_LIMIT = AMPLITUDE_MAX * 15
local FREQUENCY = 40
local DURATION_MIN = 0.1
local DURATION_MAX = 1
local INTERVAL_MIN = 0.05
local INTERVAL_MAX = 0.75


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local amplitudeMin = AMPLITUDE_MIN
        local amplitudeMax = AMPLITUDE_MAX

        local timerNameEff
        timerNameEff = CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "ShakeyShakey", INTERVAL_MIN, 0, function()
            local amplitude = math.Rand( amplitudeMin, amplitudeMax )
            local duration = math.Rand( DURATION_MIN, DURATION_MAX )
            local interval = math.Rand( INTERVAL_MIN, INTERVAL_MAX )

            util.ScreenShake( Vector(), amplitude, FREQUENCY, duration, 1 )
            timer.Adjust( timerNameEff, interval )

            amplitudeMin = math.min( amplitudeMin + AMPLITUDE_MIN_GROWTH * interval, AMPLITUDE_MIN_LIMIT )
            amplitudeMax = math.min( amplitudeMax + AMPLITUDE_MAX_GROWTH * interval, AMPLITUDE_MAX_LIMIT )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = 1.5,
    excludeFromOnetime = nil,
    incompatabileEffects = {},
    groups = {
        "VisualOnly",
    },
    incompatibleGroups = {},
} )
