local EFFECT_NAME = "ViewPummel"
local PUNCH_STRENGTH = 4
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        hook.Add( "Think", HOOK_PREFIX .. "Punch_" .. cursedPly:SteamID64(), function()
            local ang = Angle(
                math.Rand( -PUNCH_STRENGTH, PUNCH_STRENGTH ),
                math.Rand( -PUNCH_STRENGTH, PUNCH_STRENGTH ),
                math.Rand( -PUNCH_STRENGTH, PUNCH_STRENGTH )
            )

            cursedPly:ViewPunch( ang )
        end )
    end,

    onEnd = function( cursedPly )
        if CLIENT then return end

        hook.Remove( "Think", HOOK_PREFIX .. "Punch_" .. cursedPly:SteamID64() )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
