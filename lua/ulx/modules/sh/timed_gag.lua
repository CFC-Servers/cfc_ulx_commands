CFCUlxCommands.timegag = CFCUlxCommands.timegag or {}
local cmd = CFCUlxCommands.timegag
local CATEGORY_NAME = "Chat"
local PUNISHMENT = "timegag"

if SERVER then
    local function enable( ply )
        ply.ulx_gagged = true
        ply:SetNWBool( "ulx_gagged", ply.ulx_gagged )
    end

    local function disable( ply )
        ply.ulx_gagged = false
        ply:SetNWBool( "ulx_gagged", ply.ulx_gagged )
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

--== Time Gag by Player ==--
do
    function cmd.timeGag( callingPlayer, targetPlayers, minutesToGag, reason, shouldUnGag )
        reason = reason or ""

        if shouldUnGag then
            for _, ply in pairs( targetPlayers ) do
                TimedPunishments.Unpunish( ply:SteamID64(), PUNISHMENT )
            end

            return ulx.fancyLogAdmin( callingPlayer, "#A un timegagged #T!", targetPlayers )
        end

        -- time > 100 years
        if minutesToGag == 0 then minutesToGag = 9999999999 end
        local expiration = os.time() + ( minutesToGag * 60 )
        local issuer = callingPlayer and callingPlayer:SteamID64() or "Console"

        for _, ply in pairs( targetPlayers ) do
            TimedPunishments.Punish( ply:SteamID64(), PUNISHMENT, expiration, issuer, reason )
        end

        ulx.fancyLogAdmin( callingPlayer, "#A gagged #T for #i minutes! (%s)", targetPlayers, minutesToGag, reason )
    end

    local timeGagCommand = ulx.command( CATEGORY_NAME, "ulx timegag", cmd.timeGag, "!tgag" )
    timeGagCommand:addParam{ type = ULib.cmds.PlayersArg }
    timeGagCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
    timeGagCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine, ULib.cmds.optional }
    timeGagCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
    timeGagCommand:defaultAccess( ULib.ACCESS_ADMIN )
    timeGagCommand:help( "Gags a user for a set amount of time" )
    timeGagCommand:setOpposite( "ulx untimegag", {_, _, _, _, true}, "!untgag" )
end


--== Time Gag by SteamID ==--
do
    function cmd.timeGagID( callingPlayer, target, minutesToGag, reason, shouldUnGag )
        reason = reason or ""
        local steamID = util.SteamIDTo64( target )

        if shouldUnGag then
            TimedPunishments.Unpunish( staemID, PUNISHMENT )
            return ulx.fancyLogAdmin( callingPlayer, "#A un timegagged #s!", target )
        end

        -- time > 100 years
        if minutesToGag == 0 then minutesToGag = 9999999999 end
        local expiration = os.time() + ( minutesToGag * 60 )
        local issuer = callingPlayer and callingPlayer:SteamID64() or "Console"

        TimedPunishments.Punish( steamID, PUNISHMENT, expiration, issuer, reason )

        ulx.fancyLogAdmin( callingPlayer, "#A gagged #s for #i minutes! (%s)", target, minutesToGag, reason )
    end

    local timeGagCommand = ulx.command( CATEGORY_NAME, "ulx timegagid", cmd.timeGagID, "!tgagid" )
    timeGagCommand:addParam{ type = ULib.cmds.Stringarg, hint = "steamid" }
    timeGagCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
    timeGagCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine, ULib.cmds.optional }
    timeGagCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
    timeGagCommand:defaultAccess( ULib.ACCESS_ADMIN )
    timeGagCommand:help( "Gags a steamid for a set amount of time" )
    timeGagCommand:setOpposite( "ulx untimegagid", {_, _, _, _, true}, "!untgagid" )
end
