local EFFECT_NAME = "AimSensitivity"
local SENSITIVITY_LOW_MULT_MIN = 0.25
local SENSITIVITY_LOW_MULT_MAX = 0.5
local SENSITIVITY_HIGH_MULT_MIN = 1.5
local SENSITIVITY_HIGH_MULT_MAX = 3
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        local useLowMult = math.random( 1, 2 ) == 1
        local multMin = useLowMult and SENSITIVITY_LOW_MULT_MIN or SENSITIVITY_HIGH_MULT_MIN
        local multMax = useLowMult and SENSITIVITY_LOW_MULT_MAX or SENSITIVITY_HIGH_MULT_MAX
        local sensitivityMult = math.Rand( multMin, multMax )

        hook.Add( "AdjustMouseSensitivity", HOOK_PREFIX .. "LBozo", function()
            return sensitivityMult
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "AdjustMouseSensitivity", HOOK_PREFIX .. "LBozo" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
