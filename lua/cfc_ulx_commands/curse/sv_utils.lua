local inflictedPlayers = {} -- Players who either have an active one-time effect, or are timecursed (with or without an active effect).
local inflictedPlayerLookup = {} -- Lookup table for inflictedPlayers.
local effectHooks = {} -- Player -> { { hookName = string, listenerName = string }, ... }
local effectTimers = {} -- Player -> { string, ... }

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


-- Returns true if the player is currently cursed.
function CFCUlxCurse.IsCursed( ply )
    if not ply.TimedPunishments then return false end

    return ply.TimedPunishments.timedcurse ~= nil
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
    ply.CFCUlxCurseEffectExpireTime = CurTime() + duration

    ProtectedCall( function()
        effectData.onStart( ply, duration )
    end )

    addInflictedPlayer( ply )

    net.Start( "CFC_ULXCommands_Curse_StartEffect" )
    net.WriteString( effectData.name )
    net.WriteFloat( duration )
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

        ProtectedCall( function()
            prevEffect.onEnd( ply )
        end )

        CFCUlxCurse.RemoveEffectHooks( ply )
        CFCUlxCurse.RemoveEffectTimers( ply )

        net.Start( "CFC_ULXCommands_Curse_EndEffect" )
        net.WriteString( prevEffect.name )
        net.Send( ply )
    end

    if CFCUlxCurse.IsCursed( ply ) then
        local gap = math.Rand( CFCUlxCurse.EFFECT_GAP_MIN, CFCUlxCurse.EFFECT_GAP_MAX )

        ply.CFCUlxCurseNextEffectTime = CurTime() + gap
    else
        removeInflictedPlayer( ply )
    end
end

--[[
    - Adds an effect hook for a specific player.
    - For use only within the onStart() of serverside effects.
--]]
function CFCUlxCurse.AddEffectHook( cursedPly, hookName, listenerName, func )
    local plyHooks = effectHooks[cursedPly]

    if not plyHooks then
        plyHooks = {}
        effectHooks[cursedPly] = plyHooks
    end

    listenerName = listenerName .. "_" .. cursedPly:SteamID64()

    table.insert( plyHooks, {
        hookName = hookName,
        listenerName = listenerName,
    } )

    hook.Add( hookName, listenerName, func )
end

-- Removes an effect hook for a specific player.
function CFCUlxCurse.RemoveEffectHook( cursedPly, hookName, listenerName )
    local plyHooks = effectHooks[cursedPly]
    if not plyHooks then return end

    for i = #plyHooks, 1, -1 do
        local hookData = plyHooks[i]

        if hookData.hookName == hookName and hookData.listenerName == listenerName then
            hook.Remove( hookName, listenerName )
            table.remove( plyHooks, i )
        end
    end
end

--[[
    - Removes all effect hooks for a specific player.
    - This will automatically be called after an effect's onEnd() is called.
--]]
function CFCUlxCurse.RemoveEffectHooks( cursedPly )
    local plyHooks = effectHooks[cursedPly]
    if not plyHooks then return end

    for _, hookData in ipairs( plyHooks ) do
        hook.Remove( hookData.hookName, hookData.listenerName )
    end

    effectHooks[cursedPly] = nil
end

--[[
    - Creates an effect timer associated with a specific player.
    - For use only within the onStart() of serverside effects.
--]]
function CFCUlxCurse.CreateEffectTimer( cursedPly, timerName, interval, repitions, func )
    local plyTimers = effectTimers[cursedPly]

    if not plyTimers then
        plyTimers = {}
        effectTimers[cursedPly] = plyTimers
    end

    timerName = timerName .. "_" .. cursedPly:SteamID64()

    table.insert( plyTimers, timerName )
    timer.Create( timerName, interval, repitions, func )
end

-- Removes an effect timer associated with a specific player.
function CFCUlxCurse.RemoveEffectTimer( cursedPly, timerName )
    local plyTimers = effectTimers[cursedPly]
    if not plyTimers then return end

    for i = #plyTimers, 1, -1 do
        local plyTimer = plyTimers[i]

        if plyTimer == timerName then
            timer.Remove( timerName )
            table.remove( plyTimers, i )
        end
    end
end

--[[
    - Removes all effect timers associated with a specific player.
    - This will automatically be called after an effect's onEnd() is called.
--]]
function CFCUlxCurse.RemoveEffectTimers( cursedPly )
    local plyTimers = effectTimers[cursedPly]
    if not plyTimers then return end

    for _, plyTimer in ipairs( plyTimers ) do
        timer.Remove( plyTimer )
    end

    effectTimers[cursedPly] = nil
end


----- SETUP -----

hook.Add( "PlayerDisconnected", "CFC_ULXCommands_Curse_StopEffectOnLeave", function( ply )
    if not IsValid( ply ) then return end

    local prevEffect = CFCUlxCurse.GetCurrentEffect( ply )

    if prevEffect then
        ply.CFCUlxCurseEffect = nil

        ProtectedCall( function()
            prevEffect.onEnd( ply )
        end )
    end

    removeInflictedPlayer( ply )
    CFCUlxCurse.RemoveEffectHooks( ply )
    CFCUlxCurse.RemoveEffectTimers( ply )
end )


timer.Create( "CFC_ULXCommands_Curse_StartAndStopEffects", 5, 0, function()
    local now = CurTime()

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
