local EFFECT_NAME = "Trainfuck"

CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        CFCUlxCommands.trainfuck.trainFuck( cursedPly )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    onTick = function()
        -- Do nothing.
    end,

    minDuration = 1,
    maxDuration = 1,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
