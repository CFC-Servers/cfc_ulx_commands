local EFFECT_NAME = "Ball"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        hook.Add( "CFC_ULXCommands_Balls_CanUnball", HOOK_PREFIX .. "BlockUnball_" .. cursedPly:SteamID64(), function( ply )
            if ply ~= cursedPly then return end

            return false
        end )

        hook.Add( "CFC_ULXCommands_Balls_OnBallEnded", HOOK_PREFIX .. "StopEffectEarly_" .. cursedPly:SteamID64(), function( ply )
            if ply ~= cursedPly then return end

            CFCUlxCurse.StopCurseEffect( ply )
        end )

        CFCUlxCommands.ball.ball( cursedPly, { cursedPly } )
    end,

    onEnd = function( cursedPly )
        if CLIENT then return end

        hook.Remove( "CFC_ULXCommands_Balls_CanUnball", HOOK_PREFIX .. "BlockUnball_" .. cursedPly:SteamID64() )
        hook.Remove( "CFC_ULXCommands_Balls_OnBallEnded", HOOK_PREFIX .. "StopEffectEarly_" .. cursedPly:SteamID64() )

        if not cursedPly.Ball then return end

        cursedPly.Ball.ManualRemove = true
        CFCUlxCommands.ball.unball( cursedPly, { cursedPly } )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
