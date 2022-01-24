if not CFCPvp then return end -- Command only exists when CFCPVP is on the server

CFCUlxCommands.pvpban = CFCUlxCommands.pvpban or {}
local cmd = CFCUlxCommands.pvpban
local CATEGORY_NAME = "Utility"
local PUNISHMENT = "pvpban"

if SERVER then
    local function enable( ply )
        ply.isPvpBanned = true
        CFCPvp.setPlayerBuild( ply )
    end

    local function disable( ply )
        ply.isPvpBanned = false
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

--== Time PvpBan by Player ==--
do
    function cmd.pvpban( callingPlayer, targetPlayers, minutesToPvpBan, reason, shouldUnPvpBan )
        reason = reason or ""

        if shouldUnPvpBan then
            for _, ply in pairs( targetPlayers ) do
                TimedPunishments.Unpunish( ply:SteamID64(), PUNISHMENT )
            end

            return ulx.fancyLogAdmin( callingPlayer, "#A unbanned #T from pvp!", targetPlayers )
        end

        -- time > 100 years
        if minutesToPvpBan == 0 then minutesToPvpBan = 9999999999 end
        local expiration = os.time() + ( minutesToGag * 60 )
        local issuer = callingPlayer and callingPlayer:SteamID64() or "Console"

        for _, ply in pairs( targetPlayers ) do
            TimedPunishments.Punish( ply:SteamID64(), PUNISHMENT, expiration, issuer, reason )
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
end

--== Time PvpBan by SteamID ==--
do
    function cmd.pvpbanID( callingPlayer, target, minutesToPvpBan, reason, shouldUnPvpBan )
        reason = reason or ""
        local steamID = util.SteamIDTo64( target )

        if shouldUnPvpBan then
            TimedPunishments.Unpunish( ply:SteamID64(), PUNISHMENT )
            return ulx.fancyLogAdmin( callingPlayer, "#A un pvpbanned #s!", target )
        end

        -- time > 100 years
        if minutesToPvpBan == 0 then minutesToPvpBan = 9999999999 end
        local expiration = os.time() + ( minutesToGag * 60 )
        local issuer = callingPlayer and callingPlayer:SteamID64() or "Console"

        TimedPunishments.Punish( ply:SteamID64(), PUNISHMENT, expiration, issuer, reason )

        ulx.fancyLogAdmin( callingPlayer, "#A banned #s from pvp for #i minutes! (%s)", target, minutesToPvpBan, reason )
    end

    local pvpbanCommand = ulx.command( CATEGORY_NAME, "ulx pvpbanid", cmd.pvpbanID, "!pvpbanid" )
    pvpbanCommand:addParam{ type = ULib.cmds.StringArg, hint = "steamid" }
    pvpbanCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
    pvpbanCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine }
    pvpbanCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
    pvpbanCommand:defaultAccess( ULib.ACCESS_ADMIN )
    pvpbanCommand:help( "Bans the target for a certain time from entering pvp" )
    pvpbanCommand:setOpposite( "ulx unpvpbanid", {_, _, _, _, true}, "!unpvpbanid" )
end

local function checkPvpBan( ply )
    if ply.isPvpBanned then
        ply:ChatPrint( "You cannot enter pvp because you're currently banned from pvp." )
        return false
    end
end

hook.Add( "CFC_PvP_PlayerWillEnterPvp", "ULX_PVPBan_RestrictPvp", checkPvpBan )
