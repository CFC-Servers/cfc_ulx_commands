CFCUlxCommands.curse = CFCUlxCommands.curse or {}
local cmd = CFCUlxCommands.curse
local multiCurseLimit = 100

CATEGORY_NAME = "Fun"

do -- Load curse effects
    AddCSLuaFile( "cfc_ulx_commands/curse/sh_loader.lua" )
    include( "cfc_ulx_commands/curse/sh_loader.lua" )
end


local function getDurationStrings( durationSeconds, effectOverride )
    local hasCustomDuration = durationSeconds > 0 and ( not effectOverride or not effectOverride.blockCustomDuration )
    local durationAppend = ""
    local briefly = " briefly"

    if hasCustomDuration then
        local durationStr = durationSeconds >= 60 and
            ULib.secondsToStringTime( durationSeconds ) or
            math.Round( durationSeconds ) .. " seconds"

        durationAppend = " for " .. durationStr
        briefly = ""
    end

    return durationAppend, briefly
end

local function getOneTimeEffects()
    local out = {}

    for _, effect in ipairs( CFCUlxCurse.Effects ) do
        if not effect.excludeFromOnetime then
            table.insert( out, effect )
        end
    end

    return out
end


-- Returns true if the curse effect could not be applied/removed.
function cmd.curse( ply, effectOverride, durationSeconds, shouldUncurse )
    if shouldUncurse then
        if effectOverride then
            if not CFCUlxCurse.HasEffect( ply, effectOverride ) then return true end

            CFCUlxCurse.StopCurseEffect( ply, effectOverride.name )
        else
            CFCUlxCurse.StopCurseEffects( ply )
        end
    else
        if effectOverride then
            local canReceive = CFCUlxCurse.CanPlayerReceiveEffect( ply, effectOverride )
            if not canReceive then return true end
        end

        local effect = effectOverride or CFCUlxCurse.GetRandomOnetimeEffect( ply )
        if not effect then return true end

        CFCUlxCurse.ApplyCurseEffect( ply, effect, durationSeconds )
    end
end

function cmd.cursePlayers( callingPlayer, targetPlayers, effectName, durationMinutes, shouldUncurse, isSilent )
    local effectOverride
    isSilent = isSilent or false

    local isSpecificEffect =
        type( effectName ) == "string" and
        effectName ~= "random" and
        ( not shouldUncurse or effectName ~= "all" )
    local amount = isSpecificEffect and not shouldUncurse and tonumber( effectName ) or nil

    if amount == 1 then
        amount = false
        isSpecificEffect = false
        effectName = "random"
    end

    if amount then
        if amount < 1 or amount > multiCurseLimit or math.floor( amount ) ~= amount then
            ULib.tsayError( callingPlayer, "Invalid amount: " .. amount )

            return
        end

        isSpecificEffect = false
    end

    if isSpecificEffect then
        effectOverride = CFCUlxCurse.GetEffectByName( effectName )

        if not effectOverride then
            ULib.tsayError( callingPlayer, "Invalid curse effect name: " .. effectName )

            return
        end
    end

    local durationSeconds = durationMinutes and durationMinutes * 60 or 0
    local smallestAmount = amount
    local largestAmount = 0

    if amount then
        -- Curse each person with multiple random effects. Doesn't allow uncursing.
        for i = #targetPlayers, 1, -1 do
            local plyAmount = amount
            local ply = targetPlayers[i]
            local availableEffects = CFCUlxCurse.FilterCompatibleEffects( ply, getOneTimeEffects() )

            -- Only allow a given effect to be applied at most one time during the following loop.
            -- This rule doesn't count for effects the player already has, allowing them to be refreshed one time. (new duration, new seed, etc.)

            for _ = 1, amount do
                local effectsLeft = #availableEffects

                if effectsLeft == 0 then
                    plyAmount = plyAmount - 1
                else
                    local effectInd = math.random( 1, effectsLeft )
                    local effect = availableEffects[effectInd]
                    local applyFailed = cmd.curse( ply, effect, durationSeconds, shouldUncurse )

                    if applyFailed then
                        plyAmount = plyAmount - 1
                    else
                        table.remove( availableEffects, effectInd )
                        availableEffects = CFCUlxCurse.FilterCompatibleEffects( ply, availableEffects ) -- Filter out effects that might be incompatible with the new one.
                    end
                end
            end

            if plyAmount == 0 then
                table.remove( targetPlayers, i )
            else
                smallestAmount = math.min( smallestAmount, plyAmount )
                largestAmount = math.max( largestAmount, plyAmount )
            end
        end
    else
        -- (un)curse each person with a single effect.
        for i = #targetPlayers, 1, -1 do
            local ply = targetPlayers[i]
            local applyFailed = cmd.curse( ply, effectOverride, durationSeconds, shouldUncurse )

            if applyFailed then
                table.remove( targetPlayers, i )
            end
        end
    end

    if not targetPlayers[1] then -- targetPlayers is empty
        if shouldUncurse then
            ULib.tsayError( callingPlayer, "target(s) aren't cursed with that effect" )
        else
            ULib.tsayError( callingPlayer, "target(s) were unable to receive the effect(s)" )
        end

        return
    end

    if smallestAmount == largestAmount and smallestAmount == 1 then
        amount = false
    end

    if amount then
        local amountStr

        if smallestAmount == largestAmount then
            amountStr = tostring( smallestAmount )
        else
            amountStr = smallestAmount .. " to " .. largestAmount
        end

        local durationAppend, briefly = getDurationStrings( durationSeconds, false )

        ulx.fancyLogAdmin( callingPlayer, isSilent, "#A" .. briefly .. " cursed #T with " .. amountStr .. " random effects" .. durationAppend, targetPlayers )

        return
    end

    local onetimeCursedPlayers = {}
    local longCursedPlayers = {}

    for _, ply in ipairs( targetPlayers ) do
        if CFCUlxCurse.IsTimeCursed( ply ) then
            table.insert( longCursedPlayers, ply )
        else
            table.insert( onetimeCursedPlayers, ply )
        end
    end

    if shouldUncurse then -- Uncurse
        if not table.IsEmpty( onetimeCursedPlayers ) then
            if effectOverride then
                ulx.fancyLogAdmin( callingPlayer, isSilent, "#A lifted #T's brief " .. effectOverride.nameUpper .. " curse", onetimeCursedPlayers )
            else
                ulx.fancyLogAdmin( callingPlayer, isSilent, "#A lifted #T's brief curse(s)", onetimeCursedPlayers )
            end
        end

        if not table.IsEmpty( longCursedPlayers ) then
            if effectOverride then
                ulx.fancyLogAdmin( callingPlayer, isSilent, "#A lifted #T's brief " .. effectOverride.nameUpper .. " curse", longCursedPlayers )
            else
                ulx.fancyLogAdmin( callingPlayer, isSilent, "#A temporarily lifted #T's curse(s)", longCursedPlayers )
            end
        end
    else
        local durationAppend, briefly = getDurationStrings( durationSeconds, effectOverride )

        if effectOverride then -- Manually selected effect
            local effectPrettyName = effectOverride.nameUpper

            ulx.fancyLogAdmin( callingPlayer, isSilent, "#A" .. briefly .. " cursed #T with " .. effectPrettyName .. durationAppend, targetPlayers )
        else -- Random effect
            ulx.fancyLogAdmin( callingPlayer, isSilent, "#A" .. briefly .. " cursed #T with a random effect" .. durationAppend, targetPlayers )
        end
    end
end


local function silentCursePlayers( callingPlayer, targetPlayers, effectName, durationMinutes, shouldUncurse )
    cmd.cursePlayers( callingPlayer, targetPlayers, effectName, durationMinutes, shouldUncurse, true )
end


local curseOptions = table.Copy( CFCUlxCurse.GetEffectNames() )
table.insert( curseOptions, "random" )

for i = 1, 10 do
    table.insert( curseOptions, tostring( i ) )
end


local curseCommand = ulx.command( CATEGORY_NAME, "ulx curse", cmd.cursePlayers, "!curse" )
curseCommand:addParam{ type = ULib.cmds.PlayersArg }
curseCommand:addParam{ type = ULib.cmds.StringArg, default = "random", ULib.cmds.optional, completes = curseOptions }
curseCommand:addParam{ type = ULib.cmds.NumArg, min = 0, max = 24 * 60, default = 0, ULib.cmds.optional, ULib.cmds.allowTimeString, hint = "duration" }
curseCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
curseCommand:defaultAccess( ULib.ACCESS_ADMIN )
curseCommand:help( "Applies a one-time curse effect to target(s)" )
curseCommand:setOpposite( "ulx uncurse", { _, _, _, _, true }, "!uncurse" )

local silentCurseCommand = ulx.command( CATEGORY_NAME, "ulx scurse", silentCursePlayers, "!scurse" )
silentCurseCommand:addParam{ type = ULib.cmds.PlayersArg }
silentCurseCommand:addParam{ type = ULib.cmds.StringArg, default = "random", ULib.cmds.optional, completes = curseOptions }
silentCurseCommand:addParam{ type = ULib.cmds.NumArg, min = 0, max = 24 * 60, default = 0, ULib.cmds.optional, ULib.cmds.allowTimeString, hint = "duration" }
silentCurseCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
silentCurseCommand:defaultAccess( ULib.ACCESS_ADMIN )
silentCurseCommand:help( "Silently applies a one-time curse effect to target(s)" )
silentCurseCommand:setOpposite( "ulx unscurse", { _, _, _, _, true }, "!unscurse" )
