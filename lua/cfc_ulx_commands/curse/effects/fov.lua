local EFFECT_NAME = "FOV"
local FOV_LOW_MIN = 40
local FOV_LOW_MAX = 50
local FOV_HIGH_MIN = 110
local FOV_HIGH_MAX = 150
local MULTI_CHANGE_CHANCE = 0.75 -- Chance to start doing multi-changes.
local MULTI_CHANGE_AMOUNT_MIN = 1 -- Minimum amount of additional times to change the offset, if the initial chance triggers.
local MULTI_CHANGE_AMOUNT_MAX = 3 -- Same as above, but maximum.
local MULTI_CHANGE_TIMING_SPREAD = 0.15 -- Timings for each multi-change will be offset by +/- this percentage of the multi-change gap. This value should be between 0 and 0.5.


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly, curseDuration )
        if CLIENT then return end

        local function randomizeFOV()
            local useHighFOV = math.random( 1, 2 ) == 1
            local fovMin = useHighFOV and FOV_HIGH_MIN or FOV_LOW_MIN
            local fovMax = useHighFOV and FOV_HIGH_MAX or FOV_LOW_MAX

            cursedPly:SetFOV( math.Rand( fovMin, fovMax ), 0, game.GetWorld() )
        end

        randomizeFOV()

        if math.Rand( 0, 1 ) > MULTI_CHANGE_CHANCE then return end

        local mcAmount = math.random( MULTI_CHANGE_AMOUNT_MIN, MULTI_CHANGE_AMOUNT_MAX )
        local mcGap = curseDuration / ( mcAmount + 1 )

        for i = 1, mcAmount do
            local delaySpread = mcGap * MULTI_CHANGE_TIMING_SPREAD * math.Rand( -1, 1 )
            local delay = mcGap * i + delaySpread

            CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "MultiChange_" .. i, delay, 1, randomizeFOV )
        end
    end,

    onEnd = function( cursedPly )
        if CLIENT then return end

        cursedPly:SetFOV( 0, 0, game.GetWorld() )
    end,

    minDuration = 20,
    maxDuration = 40,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
