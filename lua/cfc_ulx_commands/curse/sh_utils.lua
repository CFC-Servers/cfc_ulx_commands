--[[
    - Utilities and main setup for CFC ULX curse.
    - Some brief terminology:
        - A player is 'cursed' if they have an active ulx timedcurse punishment.
        - A 'curse effect' is an effect that periodically occurs while cursed.
        - ulx curse can be used to apply a one-time effect to a player.
            - The player receives a curse effect, but they are not considered 'cursed'.
                - As such, they will not automatically receive a new effect after the first one.
            - These one-time effects often last longer than normal effects.
--]]

CFCUlxCurse = CFCUlxCurse or {}
CFCUlxCurse.EffectGlobals = CFCUlxCurse.EffectGlobals or {} -- Effects can store global vars here, preferably in a subtable indexed by the effect's lowercase name.
CFCUlxCurse.Effects = {}
CFCUlxCurse.EffectIncompatibilities = {} -- lowercase curse name -> lookup table of lowercase curse names -> true
CFCUlxCurse.EffectGroups = {} -- lowercase curse name -> list of lowercase group names
CFCUlxCurse.EffectGroupIncompatibilities = {} -- lowercase curse name -> lookup table of lowercase group names -> true

local effectNameToID = {}
local onetimeEffectIDs = {}
local effectHooks = {} -- Player -> { effectNameOne = { { hookName = string, listenerName = string, listenerNameEff = string }, ... }, effectNameTwo = ..., ... }
local effectTimers = {} -- Player -> { effectNameOne = { { timerName = string, timerNameEff = string }, ... }, effectNameTwo = ..., ... }
local includedEffectUtils = {}
local getRandomCompatibleEffect
local storeEffectIncompatibilities
local storeEffectGroups
local storeEffectGroupIncompatibilities
local areEffectsCompatible


--[[
    - Registers a curse effect.

    effectData should be a table with the following fields:
        name: (string)
            - The name of the effect. Must be unique, and is case-insensitive.
                - If an effect with the same name already exists, its values will be overwritten. This should only be done for debugging/testing purposes.
            - The name must not be "random" as it is reserved for manual selection via ulx.
            - The name must not be "all" as it is used for incompatability checks.
        onStart: (function)
            - Function to call when the effect starts.
            - Has the form   function( ply, startTime, duration )  end
        onEnd: (function)
            - Function to call when the effect ends.
            - Has the form   function( ply )  end
        minDuration: (optional) (number)
            - The minimum duration of the effect in seconds.
            - If not specified, defaults to CFCUlxCurse.EFFECT_DURATION_MIN.
        maxDuration: (optional) (number)
            - The maximum duration of the effect in seconds.
            - If not specified, defaults to CFCUlxCurse.EFFECT_DURATION_MAX.
        onetimeDurationMult: (optional)
            - Duration multiplier for if this effect is applied as a one-time effect.
            - If not specified, defaults to CFCUlxCurse.EFFECT_DURATION_ONETIME_MULT.
        excludeFromOnetime: (optional) (boolean)
            - If true, this effect will be excluded from the one-time effect draw pool (i.e. ulx curse command)
                - They can still be called manually with CFCUlxCurse.ApplyCurseEffect().
            - If not specified, defaults to false.
        blockCustomDuration: (optional) (boolean)
            - If true, the duration of this effect cannot be manually overridden by the ulx curse command.
            - If not specified, defaults to false.
        incompatibileEffects: (optional) (table)
            - A list of effect names that are incompatible (not allowed to stack) with this effect.
                - If one of the names are "all", then this effect will be incompatible with all other effects.
                - This will not affect giving the same effect multiple times, as it just restarts the effect.
            - If not specified, defaults to an empty table.
        groups: (optional) (table)
            - A list of names of groups that this effect belongs to.
            - This is to categorize things like curses that control movement vs eye angles vs purely visual effects, etc.
        incompatibleGroups: (optional) (table)
            - A list of names of groups that this effect is incompatible with.
    hideOverrideMessage: (optional) (boolean)
        - If true, hides the no-halt error message that is printed when an effect is overwritten.
        - Should only be used for debugging/testing purposes.
--]]
function CFCUlxCurse.RegisterEffect( effectData, hideOverrideMessage )
    local nameUpper = effectData.name
    if not nameUpper then return ErrorNoHaltWithStack( "Effect must have a name" ) end

    local name = string.lower( nameUpper )
    if name == "random" then return ErrorNoHaltWithStack( "Effect name cannot be \"random\"" ) end
    if name == "all" then return ErrorNoHaltWithStack( "Effect name cannot be \"all\"" ) end

    local id = effectNameToID[name]

    if effectNameToID[name] then
        if not hideOverrideMessage then
            ErrorNoHaltWithStack( "Already registered an effect with the name \"" .. nameUpper .. "\", it is now being overwritten" )
        end

        table.RemoveByValue( onetimeEffectIDs, id )
        CFCUlxCurse.Effects[id] = effectData
    else
        id = table.insert( CFCUlxCurse.Effects, effectData )
    end

    effectNameToID[name] = id
    effectData.name = name
    effectData.nameUpper = nameUpper
    effectData.incompatibileEffects = effectData.incompatibileEffects or {}
    effectData.groups = effectData.groups or {}
    effectData.incompatibleGroups = effectData.incompatibleGroups or {}

    if effectData.excludeFromOnetime ~= true then
        table.insert( onetimeEffectIDs, id )
    end

    storeEffectIncompatibilities( name, effectData.incompatibileEffects )
    storeEffectGroups( name, effectData.groups )
    storeEffectGroupIncompatibilities( name, effectData.incompatibleGroups )
end

function CFCUlxCurse.GetEffectByName( name )
    return CFCUlxCurse.Effects[effectNameToID[string.lower( name )]]
end

-- Returns the lowercase name of the effect, with a table or string as input.
function CFCUlxCurse.GetEffectName( effectDataOrName )
    if type( effectDataOrName ) == "table" then
        return effectDataOrName.name
    end

    return string.lower( effectDataOrName )
end

function CFCUlxCurse.GetEffectNames()
    local names = {}

    for _, effect in ipairs( CFCUlxCurse.Effects ) do
        table.insert( names, effect.nameUpper )
    end

    return names
end

--[[
    - Returns a list of effect datas which are compatible with a player's current effects.

    ply: (Player)
        - The player to check.
    effectDatas: (table)
        - A list of effect datas to filter.
        - If nil, defaults to CFCUlxCurse.Effects.
--]]
function CFCUlxCurse.FilterCompatibleEffects( ply, effectDatas )
    local compatEffects = {}
    effectDatas = effectDatas or CFCUlxCurse.Effects

    for _, effect in ipairs( effectDatas ) do
        if CFCUlxCurse.CanPlayerReceiveEffect( ply, effect ) then
            table.insert( compatEffects, effect )
        end
    end

    return compatEffects
end

--[[
    - Get a random curse effect, returning its data table.
    - This is the draw pool used by the ulx timedcurse command.

    ply: (optional) (Player)
        - If specified, will only return an effect that the player can receive.
        - Will return nil if the player cannot receive any effects from this pool.
--]]
function CFCUlxCurse.GetRandomEffect( ply )
    if not ply then
        local id = math.random( #CFCUlxCurse.Effects )

        return CFCUlxCurse.Effects[id]
    end

    return getRandomCompatibleEffect( ply, CFCUlxCurse.Effects )
end

--[[
    - Get a random one-time curse effect, returning its data table.
    - This is the draw pool used by the ulx curse command.

    ply: (optional) (Player)
        - If specified, will only return an effect that the player can receive.
        - Will return nil if the player cannot receive any effects from this pool.
--]]
function CFCUlxCurse.GetRandomOnetimeEffect( ply )
    if not ply then
        local id = onetimeEffectIDs[math.random( #onetimeEffectIDs )]

        return CFCUlxCurse.Effects[id]
    end

    local effectPool = {}

    for i, id in ipairs( onetimeEffectIDs ) do
        effectPool[i] = CFCUlxCurse.Effects[id]
    end

    return getRandomCompatibleEffect( ply, effectPool )
end

--[[
    - This returns by reference, only modify it if you know what you're doing.
    - The result is a lookup table of the form {
        effectNameLowerOne = {
            effectData = (table),
                - The effect's data table.
                - Like with every other place where effectData is used, this is by reference. Do not modify its values.
            expireTime = (number),
                - The time at when the effect will expire.
        },
        effectNameLowerTwo = ...,
        ...
    }

    - Example output: {
        ball = {
            effectData = (table),
            expireTime = 1234567890,
        },
        nojump = {
            effectData = (table),
            expireTime = 1234567890,
        },
    }
--]]
function CFCUlxCurse.GetCurrentEffects( ply )
    local curEffects = ply.CFCUlxCurseEffects

    if not curEffects then
        curEffects = {}
        ply.CFCUlxCurseEffects = curEffects
    end

    return curEffects
end

-- Returns whether or not a player has a given curse effect.
function CFCUlxCurse.HasEffect( ply, effectDataOrName )
    local curEffects = CFCUlxCurse.GetCurrentEffects( ply )
    local name = CFCUlxCurse.GetEffectName( effectDataOrName )

    return curEffects[name] ~= nil
end

function CFCUlxCurse.GetCurrentEffectNames( ply )
    local curEffects = CFCUlxCurse.GetCurrentEffects( ply )
    local curEffectNames = {}

    for _, effect in pairs( curEffects ) do
        table.insert( curEffectNames, effect.effectData.name )
    end

    return curEffectNames
end

--[[
    - Returns whether or not two effects are compatible.

    effectDataOrNameOne: (table or string)
        - The first effect to check.
        - Can be either the effect's data table or the effect's name.
    effectDataOrNameTwo: (table or string)
        - The second effect to check.
        - Can be either the effect's data table or the effect's name.
--]]
function CFCUlxCurse.AreEffectsCompatible( effectDataOrNameOne, effectDataOrNameTwo )
    local nameOne = CFCUlxCurse.GetEffectName( effectDataOrNameOne )
    local nameTwo = CFCUlxCurse.GetEffectName( effectDataOrNameTwo )
    local incompatsOne = CFCUlxCurse.EffectIncompatibilities[nameOne]

    return areEffectsCompatible( nameOne, nameTwo, incompatsOne )
end

--[[
    - Returns whether or not a player can receive an effect.

    ply: (Player)
        - The player to check.
    effectDataOrName: (table or string)
        - The effect to check.
        - Can be either the effect's data table or the effect's name.
--]]
function CFCUlxCurse.CanPlayerReceiveEffect( ply, effectDataOrName )
    local incomingName = CFCUlxCurse.GetEffectName( effectDataOrName )
    local curEffects = CFCUlxCurse.GetCurrentEffects( ply )

    if curEffects[incomingName] then return true end -- Effect is already active
    if table.IsEmpty( curEffects ) then return true end -- Player has no active effects

    local incomingIncompats = CFCUlxCurse.EffectIncompatibilities[incomingName]
    if incomingIncompats.all then return false end

    for name in pairs( curEffects ) do
        if not areEffectsCompatible( incomingName, name, incomingIncompats ) then
            return false
        end
    end

    return true
end

--[[
    - Adds an effect hook for a specific player.
    - For use only within the onStart() of effects.
--]]
function CFCUlxCurse.AddEffectHook( cursedPly, effectName, hookName, listenerName, func, priority )
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

    local listenerNameEff = "CFC_ULXCommands_Curse_" .. effectName .. "_" .. listenerName .. "_" .. cursedPly:SteamID64()

    table.insert( plyHooks, {
        hookName = hookName,
        listenerName = listenerName,
        listenerNameEff = listenerNameEff,
    } )

    hook.Add( hookName, listenerNameEff, func, priority )
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
            hook.Remove( hookName, hookData.listenerNameEff )
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
        hook.Remove( hookData.hookName, hookData.listenerNameEff )
    end

    plyHooksByEffect[effectName] = nil
end

--[[
    - Creates a timer associated with a specific player and effect.
    - For use only within the onStart() of effects.
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

    local timerNameEff = "CFC_ULXCommands_Curse_" .. effectName .. "_" .. timerName .. "_" .. cursedPly:SteamID64()

    table.insert( plyTimers, {
        timerName = timerName,
        timerNameEff = timerNameEff,
    } )

    timer.Create( timerNameEff, interval, repitions, func )

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
        local timerData = plyTimers[i]

        if timerData.timerName == timerName then
            timer.Remove( timerData.timerNameEff )
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

    for _, timerData in ipairs( plyTimers ) do
        timer.Remove( timerData.timerNameEff )
    end

    plyTimersByEffect[effectName] = nil
end

-- Networks and includes a shared effect utility file, returning the result.
function CFCUlxCurse.IncludeEffectUtil( fileName )
    local utilResult = includedEffectUtils[fileName]
    if utilResult then return utilResult end

    local path = "cfc_ulx_commands/curse/effects/utils/" .. fileName .. ".lua"

    if SERVER then
        AddCSLuaFile( path )
    end

    utilResult = include( path )
    includedEffectUtils[fileName] = utilResult

    return utilResult
end


----- PRIVATE FUNCTIONS -----

getRandomCompatibleEffect = function( ply, effectDatas )
    local compatEffects = CFCUlxCurse.FilterCompatibleEffects( ply, effectDatas )
    local numCompatEffects = #compatEffects
    if numCompatEffects == 0 then return nil end

    local id = math.random( numCompatEffects )

    return compatEffects[id]
end

storeEffectIncompatibilities = function( name, incompatibileEffects )
    incompatibileEffects = incompatibileEffects or {}

    local myIncompats = {}
    CFCUlxCurse.EffectIncompatibilities[name] = myIncompats

    for i, otherName in ipairs( incompatibileEffects ) do
        incompatibileEffects[i] = string.lower( otherName )
    end

    if incompatibileEffects.all then
        myIncompats.all = true

        return
    end

    for _, otherName in ipairs( incompatibileEffects ) do
        myIncompats[otherName] = true
    end
end

storeEffectGroups = function( name, groups )
    groups = groups or {}

    local myGroups = {}
    CFCUlxCurse.EffectGroups[name] = myGroups

    for i, groupName in ipairs( groups ) do
        groupName = string.lower( groupName )
        groups[i] = groupName
        myGroups[i] = groupName
    end
end

storeEffectGroupIncompatibilities = function( name, incompatibleGroups )
    incompatibleGroups = incompatibleGroups or {}

    local myGroupIncompats = {}
    CFCUlxCurse.EffectGroupIncompatibilities[name] = myGroupIncompats

    for i, groupName in ipairs( incompatibleGroups ) do
        groupName = string.lower( groupName )
        incompatibleGroups[i] = groupName
        myGroupIncompats[groupName] = true
    end
end

-- Requires incompatsOne to be passed for optimization
areEffectsCompatible = function( nameOne, nameTwo, incompatsOne )
    if nameOne == nameTwo then return true end

    local incompatsTwo = CFCUlxCurse.EffectIncompatibilities[nameTwo]

    if incompatsOne.all then return false end
    if incompatsTwo.all then return false end

    if incompatsOne[nameTwo] then return false end
    if incompatsTwo[nameOne] then return false end

    local groupsOne = CFCUlxCurse.EffectGroups[nameOne]
    local groupsTwo = CFCUlxCurse.EffectGroups[nameTwo]
    local groupIncompatsOne = CFCUlxCurse.EffectGroupIncompatibilities[nameOne]
    local groupIncompatsTwo = CFCUlxCurse.EffectGroupIncompatibilities[nameTwo]

    for _, groupOne in ipairs( groupsOne ) do
        if groupIncompatsTwo[groupOne] then return false end
    end

    for _, groupTwo in ipairs( groupsTwo ) do
        if groupIncompatsOne[groupTwo] then return false end
    end

    return true
end
