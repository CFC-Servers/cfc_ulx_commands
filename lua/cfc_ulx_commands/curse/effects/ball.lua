local EFFECT_NAME = "Ball"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CFC_ULXCommands_Balls_CanUnball", "BlockUnball", function( ply )
            if ply ~= cursedPly then return end

            return false
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CFC_ULXCommands_Balls_OnBallEnded", "StopEffectEarly", function( ply )
            if ply ~= cursedPly then return end

            CFCUlxCurse.StopCurseEffect( ply, EFFECT_NAME )
        end )

        CFCUlxCommands.ball.ball( cursedPly, { cursedPly } )
    end,

    onEnd = function( cursedPly )
        if CLIENT then return end

        CFCUlxCurse.RemoveEffectHooks( cursedPly ) -- Remove hooks first, otherwise the unball will be blocked.

        if not cursedPly.Ball then return end

        cursedPly.Ball.ManualRemove = true
        CFCUlxCommands.ball.unball( cursedPly, { cursedPly } )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    blockCustomDuration = true,
} )
