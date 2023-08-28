local EFFECT_NAME = "AimSensitivity"
local SENSITIVITY_MULT_MIN = 0.25
local SENSITIVITY_MULT_MAX = 2
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        local sensitivityMult = math.Rand( SENSITIVITY_MULT_MIN, SENSITIVITY_MULT_MAX )

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
