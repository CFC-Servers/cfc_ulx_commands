local inflictedPlayers = {} -- Players who either have an active one-time effect, or are timecursed (with or without an active effect).
local inflictedPlayerLookup = {} -- Lookup table for inflictedPlayers.
local effectHooks = {} -- Player -> { effectNameOne = { { hookName = string, listenerName = string }, ... }, effectNameTwo = ..., ... }
local effectTimers = {} -- Player -> { effectNameOne = { string, ... }, effectNameTwo = ..., ... }

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
    ply.CFCUlxCurseCurrentTimedCurseName = nil
end


-- Returns true if the player is currently cursed.
function CFCUlxCurse.IsCursed( ply )
    if not ply.TimedPunishments then return false end

    return ply.TimedPunishments.timedcurse ~= nil
end

--[[
    - Apply a curse effect to a player.
    - If the player is not cursed, this will apply as a one-time effect.
    - duration, if provided, is in seconds.
--]]
function CFCUlxCurse.ApplyCurseEffect( ply, effectDataOrName, duration )
    local effectName
    local effectData

    if type( effectDataOrName ) == "string" then
        effectName = string.lower( effectDataOrName )
        effectData = CFCUlxCurse.GetEffectByName( effectName )
    else
        effectName = effectDataOrName.name
        effectData = effectDataOrName
    end

    CFCUlxCurse.StopCurseEffect( ply, effectName )

    if CFCUlxCurse.IsCursed( ply ) and ply.CFCUlxCurseCurrentTimedCurseName == nil then
        ply.CFCUlxCurseCurrentTimedCurseName = effectName
        ply.CFCUlxCurseNextEffectTime = nil
    end

    local randomizeDuration = not duration or duration <= 0 or effectData.blockCustomDuration

    if randomizeDuration then
        local isOnetime = not CFCUlxCurse.IsCursed( ply )
        local minDuration = effectData.minDuration or CFCUlxCurse.EFFECT_DURATION_MIN
        local maxDuration = effectData.maxDuration or CFCUlxCurse.EFFECT_DURATION_MAX
        local durationMult = isOnetime and ( effectData.onetimeDurationMult or CFCUlxCurse.EFFECT_DURATION_ONETIME_MULT ) or 1

        duration = math.Rand( minDuration, maxDuration ) * durationMult
    end

    local effect = {
        effectData = effectData,
        expireTime = CurTime() + duration,
    }

    CFCUlxCurse.GetCurrentEffects( ply )[effectName] = effect

    ProtectedCall( function()
        effectData.onStart( ply, duration )
    end )

    addInflictedPlayer( ply )

    net.Start( "CFC_ULXCommands_Curse_StartEffect" )
    net.WriteString( effectName )
    net.WriteFloat( duration )
    net.Send( ply )
end

--[[
    - Stops the player's current curse effect.
    - If the player is cursed, they will automatically be given a new effect after some delay.
--]]
function CFCUlxCurse.StopCurseEffect( ply, effectName )
    effectName = string.lower( effectName )

    local curEffects = CFCUlxCurse.GetCurrentEffects( ply )
    local effectToStop = curEffects[effectName]

    if not effectToStop then return end

    local effectData = effectToStop.effectData

    curEffects[effectName] = nil

    ProtectedCall( function()
        effectData.onEnd( ply )
    end )

    CFCUlxCurse.RemoveEffectHooks( ply, effectName )
    CFCUlxCurse.RemoveEffectTimers( ply, effectName )

    net.Start( "CFC_ULXCommands_Curse_EndEffect" )
    net.WriteString( effectName )
    net.Send( ply )

    if CFCUlxCurse.IsCursed( ply ) then
        if effectName == ply.CFCUlxCurseCurrentTimedCurseName then
            local gap = math.Rand( CFCUlxCurse.EFFECT_GAP_MIN, CFCUlxCurse.EFFECT_GAP_MAX )

            ply.CFCUlxCurseCurrentTimedCurseName = nil
            ply.CFCUlxCurseNextEffectTime = CurTime() + gap
        end
    elseif table.IsEmpty( curEffects ) then
        removeInflictedPlayer( ply )
    end
end

--[[
    - Stops multiple curse effects on a player.

    ply: (Player)
        - The player to stop the effects on.
    effectNames: (optional) (string or table)
        - The name(s) of the effect(s) to stop.
        - If not provided, all effects will be stopped.
--]]
function CFCUlxCurse.StopCurseEffects( ply, effectNames )
    if not effectNames then
        for effectName in pairs( CFCUlxCurse.GetCurrentEffects( ply ) ) do
            CFCUlxCurse.StopCurseEffect( ply, effectName )
        end
    elseif type( effectNames ) == "table" then
        for _, effectName in ipairs( effectNames ) do
            CFCUlxCurse.StopCurseEffect( ply, effectName )
        end
    else
        CFCUlxCurse.StopCurseEffect( ply, effectNames )
    end
end

--[[
    - Adds an effect hook for a specific player.
    - For use only within the onStart() of serverside effects.
--]]
function CFCUlxCurse.AddEffectHook( cursedPly, effectName, hookName, listenerName, func )
    effectName = string.lower( effectName )

    local plyHooksByEffect = effectHooks[cursedPly]

    if not plyHooksByEffect then
        plyHooksByEffect = {}
        effectHooks[cursedPly] = plyHooksByEffect
    end

    local plyHooks = plyHooksByEffect[effectName]

    if not plyHooks then
        plyHooks = {}
        plyHooksByEffect[effectName] = plyHooks
    end

    listenerName = "CFC_ULXCommands_Curse_" .. effectName .. "_" .. listenerName .. "_" .. cursedPly:SteamID64()

    table.insert( plyHooks, {
        hookName = hookName,
        listenerName = listenerName,
    } )

    hook.Add( hookName, listenerName, func )
end

-- Removes an effect's hook for a specific player.
function CFCUlxCurse.RemoveEffectHook( cursedPly, effectName, hookName, listenerName )
    effectName = string.lower( effectName )

    local plyHooksByEffect = effectHooks[cursedPly]
    if not plyHooksByEffect then return end

    local plyHooks = plyHooksByEffect[effectName]
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
    - Removes all hooks for a specific player that were created by a specific effect.
    - This will automatically be called after an effect's onEnd() is called.
--]]
function CFCUlxCurse.RemoveEffectHooks( cursedPly, effectName )
    effectName = string.lower( effectName )

    local plyHooksByEffect = effectHooks[cursedPly]
    if not plyHooksByEffect then return end

    local plyHooks = plyHooksByEffect[effectName]
    if not plyHooks then return end

    for _, hookData in ipairs( plyHooks ) do
        hook.Remove( hookData.hookName, hookData.listenerName )
    end

    plyHooksByEffect[effectName] = nil
end

--[[
    - Creates a timer associated with a specific player and effect.
    - For use only within the onStart() of serverside effects.
    - Returns the full effective timer name, for use with timer.Adjust().
--]]
function CFCUlxCurse.CreateEffectTimer( cursedPly, effectName, timerName, interval, repitions, func )
    effectName = string.lower( effectName )

    local plyTimersByEffect = effectTimers[cursedPly]

    if not plyTimersByEffect then
        plyTimersByEffect = {}
        effectTimers[cursedPly] = plyTimersByEffect
    end

    local plyTimers = plyTimersByEffect[effectName]

    if not plyTimers then
        plyTimers = {}
        plyTimersByEffect[effectName] = plyTimers
    end

    timerName = "CFC_ULXCommands_Curse_" .. effectName .. "_" .. timerName .. "_" .. cursedPly:SteamID64()

    table.insert( plyTimers, timerName )
    timer.Create( timerName, interval, repitions, func )

    return timerName
end

-- Removes a timer associated with a specific player and effect.
function CFCUlxCurse.RemoveEffectTimer( cursedPly, effectName, timerName )
    effectName = string.lower( effectName )

    local plyTimersByEffect = effectTimers[cursedPly]
    if not plyTimersByEffect then return end

    local plyTimers = plyTimersByEffect[effectName]
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
    - Removes all timers associated with a specific player and effect.
    - This will automatically be called after an effect's onEnd() is called.
--]]
function CFCUlxCurse.RemoveEffectTimers( cursedPly, effectName )
    effectName = string.lower( effectName )

    local plyTimersByEffect = effectTimers[cursedPly]
    if not plyTimersByEffect then return end

    local plyTimers = plyTimersByEffect[effectName]
    if not plyTimers then return end

    for _, plyTimer in ipairs( plyTimers ) do
        timer.Remove( plyTimer )
    end

    plyTimersByEffect[effectName] = nil
end


----- SETUP -----

hook.Add( "PlayerDisconnected", "CFC_ULXCommands_Curse_StopEffectsOnLeave", function( ply )
    if not IsValid( ply ) then return end

    local curEffects = CFCUlxCurse.GetCurrentEffects( ply )

    for effectName, effect in pairs( curEffects ) do
        local effectData = effect.effectData

        ProtectedCall( function()
            effectData.onEnd( ply )
        end )

        CFCUlxCurse.RemoveEffectHooks( ply, effectName )
        CFCUlxCurse.RemoveEffectTimers( ply, effectName )
    end

    table.Empty( curEffects )
    removeInflictedPlayer( ply )
end )


timer.Create( "CFC_ULXCommands_Curse_StartAndStopEffects", 5, 0, function()
    local now = CurTime()

    for _, ply in ipairs( inflictedPlayers ) do
        local curEffects = CFCUlxCurse.GetCurrentEffects( ply )
        local nextEffectTime = ply.CFCUlxCurseNextEffectTime

        for effectName, effect in pairs( curEffects ) do
            local expireTime = effect.expireTime

            if expireTime <= now then
                CFCUlxCurse.StopCurseEffect( ply, effectName )
            end
        end

        if nextEffectTime and nextEffectTime <= now then
            local effect = CFCUlxCurse.GetRandomEffect( ply )

            CFCUlxCurse.ApplyCurseEffect( ply, effect )
        end
    end
end )
