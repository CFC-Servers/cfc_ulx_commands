local EFFECT_NAME = "ViewPummel"
local PUNCH_STRENGTH = 4


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        -- Do nothing.
    end,

    onEnd = function()
        -- Do nothing.
    end,

    onTick = function( cursedPly )
        if CLIENT then return end

        local ang = Angle(
            math.Rand( -PUNCH_STRENGTH, PUNCH_STRENGTH ),
            math.Rand( -PUNCH_STRENGTH, PUNCH_STRENGTH ),
            math.Rand( -PUNCH_STRENGTH, PUNCH_STRENGTH )
        )

        cursedPly:ViewPunch( ang )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
