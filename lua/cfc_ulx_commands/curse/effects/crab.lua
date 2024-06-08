local EFFECT_NAME = "Crab"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            cmd:SetForwardMove( 0 )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {
        "TheseBootsAreMadeForWalking",
    },
    groups = {
        "Input",
        "WS",
    },
    incompatibleGroups = {
        "WS",
    },
} )
