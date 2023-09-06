local EFFECT_NAME = "SanFransisco"
local AMPLITUDE_MIN = 3
local AMPLITUDE_MAX = 8
local AMPLITUDE_MIN_GROWTH = 2 -- Per second
local AMPLITUDE_MAX_GROWTH = 4 -- Per second
local FREQUENCY = 40
local DURATION_MIN = 0.1
local DURATION_MAX = 1
local INTERVAL_MIN = 0.05
local INTERVAL_MAX = 0.75
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        local amplitudeMin = AMPLITUDE_MIN
        local amplitudeMax = AMPLITUDE_MAX

        timer.Create( HOOK_PREFIX .. "ShakeyShakey", INTERVAL_MIN, 0, function()
            local amplitude = math.Rand( amplitudeMin, amplitudeMax )
            local duration = math.Rand( DURATION_MIN, DURATION_MAX )
            local interval = math.Rand( INTERVAL_MIN, INTERVAL_MAX )

            util.ScreenShake( Vector(), amplitude, FREQUENCY, duration, 1 )
            timer.Adjust( HOOK_PREFIX .. "ShakeyShakey", interval )

            amplitudeMin = amplitudeMin + AMPLITUDE_MIN_GROWTH * interval
            amplitudeMax = amplitudeMax + AMPLITUDE_MAX_GROWTH * interval
        end )
    end,

    onEnd = function()
        if SERVER then return end

        timer.Remove( HOOK_PREFIX .. "ShakeyShakey" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = 1.5,
    excludeFromOnetime = nil,
} )
