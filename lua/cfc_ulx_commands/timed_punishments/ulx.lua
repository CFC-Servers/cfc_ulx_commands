-- Makes the ULX commands

return function( logger )
    logger = logger:scope( "UlxMaker" )

    return function( name, action, inverseAction, category, help )
        CFCUlxCommands[name] = CFCUlxCommands[name] or {}
        local cmd = CFCUlxCommands[name]
        local nameID = name .. "id"

        local ulxCommand
        local actionStr
        local inverseActionStr

        do
            actionStr = string.Replace( action, "##", "#T" )
            inverseActionStr = string.Replace( inverseAction, "##", "#T" )

            cmd[name] = function( callingPly, targetPlys, minutes, reason, shouldInverse )
                reason = reason or ""

                if shouldInverse then
                    for _, ply in ipairs( targetPlys ) do
                        TimedPunishments.Unpunish( ply:SteamID64(), name )
                    end

                    return ulx.fancyLogAdmin( callingPlayer, "#A " .. inverseActionStr, targetPlayers )
                end

                -- time > 100 years
                if minutes == 0 then minutes = 9999999999 end
                local expiration = os.time() + ( minutes * 60 )
                local issuer = callingPlayer and callingPlayer:SteamID64() or "Console"

                for _, ply in pairs( targetPlayers ) do
                    TimedPunishments.Punish( ply:SteamID64(), name, expiration, issuer, reason )
                end

                ulx.fancyLogAdmin( callingPlayer, "#A " .. actionStr .. " for #i minutes! (%s)", targetPlayers, minutes, reason )
            end
            ulxCommand = ulx.command( category, "ulx " .. name, cmd[name], "!" .. name )
            ulxCommand:addParam{ type = ULib.cmds.PlayersArg }
            ulxCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
            ulxCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine }
            ulxCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
            ulxCommand:defaultAccess( ULib.ACCESS_ADMIN )
            ulxCommand:help( help )
            ulxCommand:setOpposite( "ulx un" .. name, {_, _, _, _, true}, "!un" .. name )
        end

        do
            actionStr = string.Replace( action, "##", "%s" )
            inverseActionStr = string.Replace( inverseAction, "##", "%s" )

            cmd[nameID] = function( callingPly, target, minutes, reason, shouldInverse )
                reason = reason or ""
                local steamID64 = util.SteamIDTo64( target )

                if shouldInverse then
                    TimedPunishments.Unpunish( steamID64, name )

                    return ulx.fancyLogAdmin( callingPlayer, "#A " .. inverseActionStr, target )
                end

                -- time > 100 years
                if minutes == 0 then minutes = 9999999999 end
                local expiration = os.time() + ( minutes * 60 )
                local issuer = callingPlayer and callingPlayer:SteamID64() or "Console"

                TimedPunishments.Punish( steamID64, name, expiration, issuer, reason )

                ulx.fancyLogAdmin( callingPlayer, "#A " .. actionStr .. " for #i minutes! (%s)", target, minutes, reason )
            end

            ulxCommand = ulx.command( CATEGORY_NAME, "ulx " .. nameID, cmd[nameID], "!" .. nameID )
            ulxCommand:addParam{ type = ULib.cmds.StringArg, hint = "steamid" }
            ulxCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
            ulxCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine }
            ulxCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
            ulxCommand:defaultAccess( ULib.ACCESS_ADMIN )
            ulxCommand:help( help )
            ulxCommand:setOpposite( "ulx un" .. nameID, {_, _, _, _, true}, "!un" .. nameID )
        end

        logger:info( "Created: ", name, nameID, "un" .. name, "un" .. nameID )
    end
end
