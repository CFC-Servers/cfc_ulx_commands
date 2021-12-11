CFCUlxCommands.e2ban = CFCUlxCommands.e2ban or {}
local cmd = CFCUlxCommands.e2ban
local CATEGORY_NAME = "Utility"

if SERVER then
    CFCTimedCommands.types.cfc_timed_e2bans = {}
    CFCTimedCommands.types.cfc_timed_e2bans.name = "cfc_timed_e2bans"
    CFCTimedCommands.types.cfc_timed_e2bans.pretty = "timed e2 ban"
    CFCTimedCommands.createTable( CFCTimedCommands.types.cfc_timed_e2bans.name )

    function CFCTimedCommands.types.cfc_timed_e2bans.punish( ply )
        ply.isE2Banned = true
    end

    function CFCTimedCommands.types.cfc_timed_e2bans.unpunish( ply )
        ply.isE2Banned = false
    end

    function CFCTimedCommands.types.cfc_timed_e2bans.check( ply )
        return ply.isE2Banned or false
    end
end

function cmd.e2ban( callingPlayer, targetPlayers, minutesToE2Ban, reason, shouldUnE2Ban )
    if shouldUnE2Ban then
        for _, ply in pairs( targetPlayers ) do
            CFCTimedCommands.unpunishPlayer( ply, CFCTimedCommands.types.cfc_timed_e2bans )
        end

        return ulx.fancyLogAdmin( callingPlayer, "#A unbanned #T from E2!", targetPlayers )
    end

    -- time > 100 years
    if minutesToE2Ban == 0 then minutesToE2Ban = 9999999999 end

    for _, ply in pairs( targetPlayers ) do
        CFCTimedCommands.punishPlayer( ply, minutesToE2Ban, reason, CFCTimedCommands.types.cfc_timed_e2bans )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A banned #T from E2 for #i minutes!", targetPlayers, minutesToE2Ban )
end

local e2BanCommand = ulx.command( CATEGORY_NAME, "ulx e2ban", cmd.e2ban, "!e2ban" )
e2BanCommand:addParam{ type = ULib.cmds.PlayersArg }
e2BanCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
e2BanCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine }
e2BanCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
e2BanCommand:defaultAccess( ULib.ACCESS_ADMIN )
e2BanCommand:help( "Bans the target for a certain time from using E2" )
e2BanCommand:setOpposite( "ulx une2ban", {_, _, _, _, true}, "!une2ban" )


local function setup()
    if not MakeWireExpression2 then
        ErrorNoHalt( "Couldn't find MakeWireExpression2, E2 ban can't function")
        return
    end

    _MakeWireExpression2 = _MakeWireExpression2 or MakeWireExpression2

    MakeWireExpression2 = function( ply, ... )
        if ply.isE2Banned then
            ply:ChatPrint( "You can't spawn E2s because you're currently E2 banned" )
            return false
        end

        return _MakeWireExpression2( ply, ... )
    end
end

hook.Add( "Initialize", "E2BanSetup", setup )
