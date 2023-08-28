local inflictedPlayers = {} -- Players who either have an active one-time effect, or are timecursed (with or without an active effect).
local inflictedPlayerLookup = {} -- Lookup table for inflictedPlayers.

util.AddNetworkString( "CFC_ULXCommands_Curse_StartEffect" )
util.AddNetworkString( "CFC_ULXCommands_Curse_EndEffect" )


-- Track an inflicted player, so that effect expire/next timers can be updated.
local function addInflictedPlayer( ply )
    if inflictedPlayerLookup[ply] then return end

    table.insert( inflictedPlayers, ply )
    inflictedPlayerLookup[ply] = true
end

-- Stop tracking an inflicted player.
local function removeInflictedPlayer( ply )
    if not inflictedPlayerLookup[ply] then return end

    table.RemoveByValue( inflictedPlayers, ply )
    inflictedPlayerLookup[ply] = nil

    ply.CFCUlxCurseNextEffectTime = nil
    ply.CFCUlxCurseEffectExpireTime = nil
end


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
    addInflictedPlayer( ply )

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
        removeInflictedPlayer( ply )
    end
end


----- SETUP -----

hook.Add( "PlayerDisconnected", "CFC_ULXCommands_Curse_StopEffectOnLeave", function( ply )
    if not IsValid( ply ) then return end

    removeInflictedPlayer( ply )

    local prevEffect = CFCUlxCurse.GetCurrentEffect( ply )
    if not prevEffect then return end

    ply.CFCUlxCurseEffect = nil
    prevEffect.onEnd( ply )
end )


timer.Create( "CFC_ULXCommands_Curse_StartAndStopEffects", 5, 0, function()
    local now = RealTime()

    for _, ply in ipairs( inflictedPlayers ) do
        local effectExpireTime = ply.CFCUlxCurseEffectExpireTime
        local nextEffectTime = ply.CFCUlxCurseNextEffectTime

        if effectExpireTime and effectExpireTime <= now then
            CFCUlxCurse.StopCurseEffect( ply )
        elseif nextEffectTime and nextEffectTime <= now then
            local effect = CFCUlxCurse.GetRandomEffect()

            CFCUlxCurse.ApplyCurseEffect( ply, effect )
        end
    end
end )
