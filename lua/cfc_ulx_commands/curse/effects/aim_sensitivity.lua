local EFFECT_NAME = "AimSensitivity"
local SENSITIVITY_LOW_MULT_MIN = 0.25
local SENSITIVITY_LOW_MULT_MAX = 0.5
local SENSITIVITY_HIGH_MULT_MIN = 1.5
local SENSITIVITY_HIGH_MULT_MAX = 3


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local useLowMult = math.random( 1, 2 ) == 1
        local multMin = useLowMult and SENSITIVITY_LOW_MULT_MIN or SENSITIVITY_HIGH_MULT_MIN
        local multMax = useLowMult and SENSITIVITY_LOW_MULT_MAX or SENSITIVITY_HIGH_MULT_MAX
        local sensitivityMult = math.Rand( multMin, multMax )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "AdjustMouseSensitivity", "LBozo", function()
            return sensitivityMult
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatabileEffects = {},
    groups = {
        "MouseSensitivity",
    },
    incompatibleGroups = {
        "MouseSensitivity",
    },
} )
