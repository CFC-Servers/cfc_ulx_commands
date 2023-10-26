local EFFECT_NAME = "NoHud"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "HUDShouldDraw", "NoHudPls", function()
            return false
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
