CFCUlxCommands.timegag = CFCUlxCommands.timegag or {}
local cmd = CFCUlxCommands.timegag
local CATEGORY_NAME = "Chat"

if SERVER then
    CFCTimedCommands.types.timedGag = {}
    CFCTimedCommands.types.timedGag.name = "timedGag"
    CFCTimedCommands.types.timedGag.pretty = "timed gag"
    CFCTimedCommands.createTable( CFCTimedCommands.types.timedGag.name )

    function CFCTimedCommands.types.timedGag.punish( ply )
        ply.ulx_gagged = true
        ply:SetNWBool( "ulx_gagged", ply.ulx_gagged )
    end

    function CFCTimedCommands.types.timedGag.unpunish( ply )
        ply.ulx_gagged = false
        ply:SetNWBool( "ulx_gagged", ply.ulx_gagged )
    end

    function CFCTimedCommands.types.timedGag.check( ply )
        return ply:GetNWBool( "ulx_gagged", false )
    end
end

function cmd.timeGag( callingPlayer, targetPlayers, minutesToGag, reason, shouldUnGag )
    if shouldUnGag then
        for _, ply in pairs( targetPlayers ) do
            CFCTimedCommands.unpunishPlayer( ply, CFCTimedCommands.types.timedGag )
        end

        return ulx.fancyLogAdmin( callingPlayer, "#A ungagged #T!", targetPlayers )
    end

    -- time > 100 years
    if minutesToGag == 0 then minutesToGag = 9999999999 end

    for _, ply in pairs( targetPlayers ) do
        CFCTimedCommands.punishPlayer( ply, minutesToGag, reason, CFCTimedCommands.types.timedGag )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A gagged #T for #i minutes!", targetPlayers, minutesToGag )
end

local timeGagCommand = ulx.command( CATEGORY_NAME, "ulx timegag", cmd.timeGag, "!tgag" )
timeGagCommand:addParam{ type = ULib.cmds.PlayersArg }
timeGagCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
timeGagCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine }
timeGagCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
timeGagCommand:defaultAccess( ULib.ACCESS_ADMIN )
timeGagCommand:help( "Gags a user for a set amount of time" )
timeGagCommand:setOpposite( "ulx untimegag", {_, _, _, _, true}, "!untgag" )