if not CFCPvp then return end -- Command only exists when CFCPVP is on the server

CFCUlxCommands.pvpban = CFCUlxCommands.pvpban or {}
local cmd = CFCUlxCommands.pvpban
local CATEGORY_NAME = "Utility"

if SERVER then
    CFCTimedCommands.types.pvpBan = {}
    CFCTimedCommands.types.pvpBan.name = "cfc_timed_pvpbans"
    CFCTimedCommands.types.pvpBan.pretty = "timed pvp ban"
    CFCTimedCommands.createTable( CFCTimedCommands.types.pvpBan.name )

    function CFCTimedCommands.types.pvpBan.punish( ply )
        ply.isPvpBanned = true
    end

    function CFCTimedCommands.types.pvpBan.unpunish( ply )
        ply.isPvpBanned = false
    end

    function CFCTimedCommands.types.pvpBan.check( ply )
        return ply.isPvpBanned or false
    end
end

function cmd.pvpban( callingPlayer, targetPlayers, minutesToPvpBan, reason, shouldUnPvpBan )
    if shouldUnPvpBan then
        for _, ply in pairs( targetPlayers ) do
            CFCTimedCommands.unpunishPlayer( ply, CFCTimedCommands.types.pvpBan )
        end

        return ulx.fancyLogAdmin( callingPlayer, "#A unbanned #T from pvp!", targetPlayers )
    end

    -- time > 100 years
    if minutesToPvpBan == 0 then minutesToPvpBan = 9999999999 end

    for _, ply in pairs( targetPlayers ) do
        CFCPvp.setPlayerBuild( ply )
        CFCTimedCommands.punishPlayer( ply, minutesToPvpBan, reason, CFCTimedCommands.types.pvpBan )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A banned #T from pvp for #i minutes!", targetPlayers, minutesToPvpBan )
end

local pvpbanCommand = ulx.command( CATEGORY_NAME, "ulx pvpban", cmd.pvpban, "!pvpban" )
pvpbanCommand:addParam{ type = ULib.cmds.PlayersArg }
pvpbanCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
pvpbanCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine }
pvpbanCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
pvpbanCommand:defaultAccess( ULib.ACCESS_ADMIN )
pvpbanCommand:help( "Bans the target for a certain time from entering pvp" )
pvpbanCommand:setOpposite( "ulx unpvpban", {_, _, _, _, true}, "!unpvpban" )

local function checkPvpBan( ply )
    if ply.isPvpBanned then
        ply:ChatPrint( "You cannot enter pvp because you're currently banned from pvp." )
        return false
    end
    return true
end

hook.Add( "CFC_PvP_PlayerWillEnterPvp", "ULX_PVPBan_RestrictPvp", checkPvpBan )
