CFCUlxCommands.timepvp = CFCUlxCommands.timepvp or {}
local cmd = CFCUlxCommands.timepvp
local CATEGORY_NAME = "Utility"

if SERVER then
    CFCTimedCommands.types.timedPvp = {}
    CFCTimedCommands.types.timedPvp.name = "timedPvp"
    CFCTimedCommands.types.timedPvp.pretty = "timed pvp ban"
    CFCTimedCommands.createTable( CFCTimedCommands.types.timedPvp.name )

    function CFCTimedCommands.types.timedPvp.punish( ply )
        ply.isPvpBanned = true
    end

    function CFCTimedCommands.types.timedPvp.unpunish( ply )
        ply.isPvpBanned = false
    end

    function CFCTimedCommands.types.timedPvp.check( ply )
        return ply.isPvpBanned or false
    end
end

function cmd.timepvp( callingPlayer, targetPlayers, minutesToPvpBan, reason, shouldUnPvpBan )
    if shouldUnPvpBan then
        for _, ply in pairs( targetPlayers ) do
            CFCTimedCommands.unpunishPlayer( ply, CFCTimedCommands.types.timedPvp )
        end

        return ulx.fancyLogAdmin( callingPlayer, "#A unbanned #T from pvp!", targetPlayers )
    end

    -- time > 100 years
    if minutesToPvpBan == 0 then minutesToPvpBan = 9999999999 end

    for _, ply in pairs( targetPlayers ) do
        CFCTimedCommands.punishPlayer( ply, minutesToPvpBan, reason, CFCTimedCommands.types.timedPvp )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A banned #T from pvp for #i minutes!", targetPlayers, minutesToPvpBan )
end

local timepvpCommand = ulx.command( CATEGORY_NAME, "ulx timepvp", cmd.timepvp, "!tpvp" )
timepvpCommand:addParam{ type = ULib.cmds.PlayersArg }
timepvpCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
timepvpCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine }
timepvpCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
timepvpCommand:defaultAccess( ULib.ACCESS_ADMIN )
timepvpCommand:help( "Bans the target for a certain time from entering pvp" )
timepvpCommand:setOpposite( "ulx untimepvp", {_, _, _, _, true}, "!untpvp" )

local function checkPvpBan( ply )
    if ply.isPvpBanned then return false end
    return true
end

hook.Add( "CFC_PvP_PlayerWillEnterPvp", "ULX_PVPBan_RestrictPvp", checkPvpBan )