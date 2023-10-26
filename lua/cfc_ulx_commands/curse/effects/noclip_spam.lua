local EFFECT_NAME = "NoclipSpam"
local TOGGLE_INTERVAL = 0.5


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "ToggleNoclip", TOGGLE_INTERVAL, 0, function()
            RunConsoleCommand( "noclip" )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
