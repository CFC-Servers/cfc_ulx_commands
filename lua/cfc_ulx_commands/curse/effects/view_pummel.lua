local EFFECT_NAME = "ViewPummel"
local PUNCH_STRENGTH = 4
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        CFCUlxCurse.AddEffectHook( cursedPly, "Think", HOOK_PREFIX .. "Punch", function()
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
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
