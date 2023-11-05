local EFFECT_NAME = "NoInteract"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            cmd:RemoveKey( IN_ATTACK )
            cmd:RemoveKey( IN_ATTACK2 )
            cmd:RemoveKey( IN_RELOAD )
            cmd:RemoveKey( IN_USE )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 5,
    maxDuration = 20,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatabileEffects = {
        "Butterfingers",
    },
} )
