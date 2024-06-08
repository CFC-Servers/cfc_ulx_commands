local EFFECT_NAME = "ViewPummel"
local PUNCH_STRENGTH = 4


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "Think", "Punch", function()
            local ang = Angle(
                math.Rand( -PUNCH_STRENGTH, PUNCH_STRENGTH ),
                math.Rand( -PUNCH_STRENGTH, PUNCH_STRENGTH ),
                math.Rand( -PUNCH_STRENGTH, PUNCH_STRENGTH )
            )

            cursedPly:ViewPunch( ang )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = 1.5,
    excludeFromOnetime = nil,
    incompatabileEffects = {},
    groups = {},
    incompatibleGroups = {},
} )
