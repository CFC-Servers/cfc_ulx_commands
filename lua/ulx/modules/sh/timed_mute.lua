CFCUlxCommands.timemute = CFCUlxCommands.timemute or {}
local cmd = CFCUlxCommands.timemute
local CATEGORY_NAME = "Chat"

if SERVER then
    CFCTimedCommands.types.timedMute = {}
    CFCTimedCommands.types.timedMute.name = "timedMute"
    CFCTimedCommands.types.timedMute.pretty = "timed mute"
    CFCTimedCommands.createTable( CFCTimedCommands.types.timedMute.name )

    function CFCTimedCommands.types.timedMute.punish( ply )
        ply.gimp = 2
        ply:SetNWBool( "ulx_muted", true )
    end

    function CFCTimedCommands.types.timedMute.unpunish( ply )
        ply.gimp = nil
        ply:SetNWBool( "ulx_muted", false )
    end

    function CFCTimedCommands.types.timedMute.check( ply )
        return ply:GetNWBool( "ulx_muted", false )
    end
end

function cmd.timeMute( callingPlayer, targetPlayers, minutesToMute, reason, shouldUnMute )
    if shouldUnMute then
        for _, ply in pairs( targetPlayers ) do
            CFCTimedCommands.unpunishPlayer( ply, CFCTimedCommands.types.timedMute )
        end

        return ulx.fancyLogAdmin( callingPlayer, "#A unmuted #T!", targetPlayers )
    end

    -- time > 100 years
    if minutesToMute == 0 then minutesToMute = 9999999999 end

    for _, ply in pairs( targetPlayers ) do
        CFCTimedCommands.punishPlayer( ply, minutesToMute, reason, CFCTimedCommands.types.timedMute )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A muted #T for #i minutes!", targetPlayers, minutesToMute )
end

local timeMuteCommand = ulx.command( CATEGORY_NAME, "ulx timemute", cmd.timeMute, "!tmute" )
timeMuteCommand:addParam{ type = ULib.cmds.PlayersArg }
timeMuteCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
timeMuteCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine }
timeMuteCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
timeMuteCommand:defaultAccess( ULib.ACCESS_ADMIN )
timeMuteCommand:help( "Mutes a user for a set amount of time" )
timeMuteCommand:setOpposite( "ulx untimemute", {_, _, _, _, true}, "!untmute" )