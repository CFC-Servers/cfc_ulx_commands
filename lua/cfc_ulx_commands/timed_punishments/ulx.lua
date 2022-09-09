-- Makes the ULX commands
local IsValid = IsValid

-- Returns a generator function with logger context
return function( logger )
    logger = logger:scope( "UlxMaker" )

    -- ==== ULX Command Maker ====
    --
    -- This function will automatically generate four ulx commands:
    --  - ulx [name] (for targeting players)
    --  - ulx [name]id (for targeting Steam IDs)
    --  - ulx un[name]
    --  - ulx un[name]id
    --
    -- The created chat commands are the exact same as the created commands
    -- (i.e. "testban" would result in `ulx testban` and `!testban`)
    --
    -- Params:
    --   name:
    --     The name of the action. This is used for:
    --        - Key in CFCUlxCommands
    --        - The ulx command, (i.e. "testban" would result in `ulx testban` and `!testban`)
    --        - The punishment name in the database
    --
    --   action:
    --     A special format string to print when the action is complete.
    --     This uses a special placeholder, "##" which will be turned into "#T" for player targets and "#s" for steamid targets
    --     (i.e. "time blinded ##" would result in "#A time blinded #T for %i minutes!" for player targets)
    --
    --   inverseAction:
    --     A special format string to print when the action is undone
    --     This is the reverse of `action` with all of the same caveats
    --
    --   category:
    --     The ULX Command Category to create the commands under
    --     (i.e. "Fun", "Utility", etc.)
    --
    --   help:
    --     The ULX Command help text to display with the created commands

    return function( name, action, inverseAction, category, help )

        CFCUlxCommands[name] = CFCUlxCommands[name] or {}
        local cmd = CFCUlxCommands[name]

        -- == Player Target ==
        do
            local actionStr = "#A " .. string.Replace( action, "##", "#T" )
            local inverseActionStr = "#A " .. string.Replace( inverseAction, "##", "#T" )

            cmd[name] = function( callingPly, targetPlys, minutes, reason, shouldInverse )
                if shouldInverse then
                    for _, ply in ipairs( targetPlys ) do
                        TimedPunishments.Unpunish( ply:SteamID64(), name )
                    end

                    return ulx.fancyLogAdmin( callingPly, inverseActionStr, targetPlys )
                end

                reason = reason or ""
                local expiration = minutes == 0 and -1 or os.time() + ( minutes * 60 )
                local issuer = IsValid( callingPly ) and callingPly:SteamID64() or "Console"

                for _, ply in pairs( targetPlys ) do
                    TimedPunishments.Punish( ply:SteamID64(), name, expiration, issuer, reason )
                end

                if minutes == 0 then
                    ulx.fancyLogAdmin( callingPly, actionStr .. " permanently! (#s)", targetPlys, reason )
                else
                    local timeStr = ULib.secondsToStringTime( minutes * 60 )
                    ulx.fancyLogAdmin( callingPly, actionStr .. " for #s! (#s)", targetPlys, timeStr, reason )
                end
            end

            local consoleCommand = "ulx " .. name
            local inverseConsoleCommand = "ulx un" .. name

            local chatCommand = "!" .. name
            local inverseChatCommand = "!un" .. name

            local ulxCommand = ulx.command( category, consoleCommand, cmd[name], chatCommand )
            ulxCommand:addParam{ type = ULib.cmds.PlayersArg }
            ulxCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, ULib.cmds.optional, min = 0, default = 15 }
            ulxCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.optional, default = "No reason specified" }
            ulxCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
            ulxCommand:defaultAccess( ULib.ACCESS_ADMIN )
            ulxCommand:help( help )
            ulxCommand:setOpposite( inverseConsoleCommand, {_, _, _, _, true}, inverseChatCommand )

            logger:debug( "Created: ", consoleCommand, chatCommand )
            logger:debug( "Created: ", inverseConsoleCommand, inverseChatCommand )
        end

        -- == SteamID Target ==
        do
            local nameID = name .. "id"
            local actionStr = "#A " .. string.Replace( action, "##", "#s" )
            local inverseActionStr = "#A " .. string.Replace( inverseAction, "##", "#s" )

            cmd[nameID] = function( callingPly, target, minutes, reason, shouldInverse )
                local steamID64 = util.SteamIDTo64( target )

                if shouldInverse then
                    TimedPunishments.Unpunish( steamID64, name )

                    return ulx.fancyLogAdmin( callingPly, inverseActionStr, target )
                end

                local expiration = minutes == 0 and -1 or os.time() + ( minutes * 60 )
                local issuer = IsValid( callingPly ) and callingPly:SteamID64() or "Console"

                TimedPunishments.Punish( steamID64, name, expiration, issuer, reason )

                if minutes == 0 then
                    ulx.fancyLogAdmin( callingPly, actionStr .. " permanently! (#s)", target, reason )
                else
                    local timeStr = ULib.secondsToStringTime( minutes * 60 )
                    ulx.fancyLogAdmin( callingPly, actionStr .. " for #s! (#s)", target, timeStr, reason )
                end
            end

            local consoleCommand = "ulx " .. nameID
            local inverseConsoleCommand = "ulx un" .. nameID

            local chatCommand = "!" .. nameID
            local inverseChatCommand = "!un" .. nameID

            local ulxCommand = ulx.command( category, consoleCommand, cmd[nameID], chatCommand )
            ulxCommand:addParam{ type = ULib.cmds.StringArg, hint = "steamid" }
            ulxCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, ULib.cmds.optional, min = 0, default = 15 }
            ulxCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.optional, default = "No reason specified" }
            ulxCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
            ulxCommand:defaultAccess( ULib.ACCESS_ADMIN )
            ulxCommand:help( help )
            ulxCommand:setOpposite( inverseConsoleCommand, {_, _, _, _, true}, inverseChatCommand )

            logger:debug( "Created: ", consoleCommand, chatCommand )
            logger:debug( "Created: ", inverseConsoleCommand, inverseChatCommand )
        end
    end
end
