local EFFECT_NAME = "Respawn"

CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        cursedPly:Spawn()
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 1,
    maxDuration = 1,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatabileEffects = {},
    groups = {
        "Death",
    },
    incompatibleGroups = {
        "Death",
    },
} )
