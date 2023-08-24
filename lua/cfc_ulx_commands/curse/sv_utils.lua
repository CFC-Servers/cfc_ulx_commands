util.AddNetworkString( "CFC_ULXCommands_Curse_StartEffect" )
util.AddNetworkString( "CFC_ULXCommands_Curse_EndEffect" )


--[[
    - Apply a curse effect to a player.
    - If the player is not cursed, this will apply as a one-time effect.
--]]
function CFCUlxCurse.ApplyCurseEffect( ply, effectData )
    CFCUlxCurse.StopCurseEffect( ply )
    ply.CFCUlxCurseNextEffectTime = nil

    local isOnetime = not CFCUlxCurse.IsCursed( ply )
    local minDuration = effectData.minDuration or CFCUlxCurse.EFFECT_DURATION_MIN
    local maxDuration = effectData.maxDuration or CFCUlxCurse.EFFECT_DURATION_MAX
    local durationMult = isOnetime and ( effectData.onetimeDurationMult or CFCUlxCurse.EFFECT_DURATION_ONETIME_MULT ) or 1
    local duration = math.Rand( minDuration, maxDuration ) * durationMult

    ply.CFCUlxCurseEffect = effectData
    ply.CFCUlxCurseEffectExpireTime = RealTime() + duration
    effectData.onStart( ply )

    net.Start( "CFC_ULXCommands_Curse_StartEffect" )
    net.WriteString( effectData.name )
    net.Send( ply )
end

--[[
    - Stops the player's current curse effect.
    - If the player is cursed, they will automatically be given a new effect after some delay.
--]]
function CFCUlxCurse.StopCurseEffect( ply )
    local prevEffect = CFCUlxCurse.GetCurrentEffect( ply )

    if prevEffect then
        ply.CFCUlxCurseEffect = nil
        ply.CFCUlxCurseEffectExpireTime = nil
        prevEffect.onEnd( ply )

        net.Start( "CFC_ULXCommands_Curse_EndEffect" )
        net.WriteString( prevEffect.name )
        net.Send( ply )
    end

    if CFCUlxCurse.IsCursed( ply ) then
        local gap = math.Rand( CFCUlxCurse.EFFECT_GAP_MIN, CFCUlxCurse.EFFECT_GAP_MAX )

        ply.CFCUlxCurseNextEffectTime = RealTime() + gap
    else
        ply.CFCUlxCurseNextEffectTime = nil
    end
end


----- SETUP -----

hook.Add( "Think", "CFC_ULXCommands_Curse_EffectTick", function()
    local now = RealTime()

    for _, ply in ipairs( player.GetAll() ) do
        local effectExpireTime = ply.CFCUlxCurseEffectExpireTime
        local nextEffectTime = ply.CFCUlxCurseNextEffectTime

        if effectExpireTime and effectExpireTime <= now then
            CFCUlxCurse.StopCurseEffect( ply )
        elseif nextEffectTime and nextEffectTime <= now then
            local effect = CFCUlxCurse.GetRandomEffect()

            CFCUlxCurse.ApplyCurseEffect( ply, effect )
        else
            local effect = CFCUlxCurse.GetCurrentEffect( ply )

            if effect then
                effect.onTick( ply )
            end
        end
    end
end )

hook.Add( "PlayerDisconnected", "CFC_ULXCommands_Curse_StopEffectOnLeave", function( ply )
    if not IsValid( ply ) then return end

    local prevEffect = CFCUlxCurse.GetCurrentEffect( ply )
    if not prevEffect then return end

    ply.CFCUlxCurseEffect = nil
    ply.CFCUlxCurseEffectExpireTime = nil
    prevEffect.onEnd( ply )
end )
