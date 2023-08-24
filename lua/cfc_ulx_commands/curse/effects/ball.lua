local EFFECT_NAME = "Ball"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"

local affectedPlys = {}


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        affectedPlys[cursedPly] = true

        if CLIENT then return end

        CFCUlxCommands.ball.ball( cursedPly, { cursedPly } )
    end,

    onEnd = function( cursedPly )
        affectedPlys[cursedPly] = nil

        if CLIENT then return end
        if not cursedPly.Ball then return end

        cursedPly.Ball.ManualRemove = true
        CFCUlxCommands.ball.unball( cursedPly, { cursedPly } )
    end,

    onTick = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )


if CLIENT then return end

hook.Add( "CFC_ULXCommands_Balls_CanUnball", HOOK_PREFIX .. "BlockUnball", function( ply )
    if not affectedPlys[ply] then return end

    return false
end )

hook.Add( "CFC_ULXCommands_Balls_OnBallEnded", HOOK_PREFIX .. "StopEffectEarly", function( ply )
    if not affectedPlys[ply] then return end

    CFCUlxCurse.StopCurseEffect( ply ) -- TODO: Verify name
end )

