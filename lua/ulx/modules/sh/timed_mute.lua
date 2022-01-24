CFCUlxCommands.timemute = CFCUlxCommands.timemute or {}
local cmd = CFCUlxCommands.timemute
local CATEGORY_NAME = "Chat"
local PUNISHMENT = "timemute"

if SERVER then
    local function enable( ply )
        ply.gimp = 2
        ply:SetNWBool( "ulx_muted", true )
    end

    local function disable( ply )
        ply.gimp = nil
        ply:SetNWBool( "ulx_muted", false )
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

--== Time Mute by Player ==--
do
    function cmd.timeMute( callingPlayer, targetPlayers, minutesToMute, reason, shouldUnMute )
        reason = reason or ""

        if shouldUnMute then
            for _, ply in pairs( targetPlayers ) do
                TimedPunishments.Unpunish( ply:SteamID64(), PUNISHMENT )
            end

            return ulx.fancyLogAdmin( callingPlayer, "#A unmuted #T!", targetPlayers )
        end

        -- time > 100 years
        if minutesToMute == 0 then minutesToMute = 9999999999 end
        local expiration = os.time() + ( minutesToMute * 60 )
        local issuer = callingPlayer and callingPlayer:SteamID64() or "Console"

        for _, ply in pairs( targetPlayers ) do
            TimedPunishments.Punish( ply:SteamID64(), PUNISHMENT, expiration, issuer, reason )
        end

        ulx.fancyLogAdmin( callingPlayer, "#A muted #T for #i minutes! (%s)", targetPlayers, minutesToMute, reason )
    end

    local timeMuteCommand = ulx.command( CATEGORY_NAME, "ulx timemute", cmd.timeMute, "!tmute" )
    timeMuteCommand:addParam{ type = ULib.cmds.PlayersArg }
    timeMuteCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
    timeMuteCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine, ULib.cmds.optional }
    timeMuteCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
    timeMuteCommand:defaultAccess( ULib.ACCESS_ADMIN )
    timeMuteCommand:help( "Mutes a user for a set amount of time" )
    timeMuteCommand:setOpposite( "ulx untimemute", {_, _, _, _, true}, "!untmute" )
end

--== Time Mute by SteamID ==--
do
    function cmd.timeMuteID( callingPlayer, target, minutesToMute, reason, shouldUnmute )
        reason = reason or ""
        local steamID = util.SteamIDTo64( target )

        if shouldUnmute then
            TimedPunishments.Unpunish( staemID, PUNISHMENT )

            return ulx.fancyLogAdmin( callingPlayer, "#A un timemuted #s!", target )
        end

        -- time > 100 years
        if minutesToMute == 0 then minutesToMute = 9999999999 end
        local expiration = os.time() + ( minutesToMute * 60 )
        local issuer = callingPlayer and callingPlayer:SteamID64() or "Console"

        TimedPunishments.Punish( steamID, PUNISHMENT, expiration, issuer, reason )

        ulx.fancyLogAdmin( callingPlayer, "#A muted #s for #i minutes! (%s)", target, minutesToMute, reason )
    end

    local timedMuteCommand = ulx.command( CATEGORY_NAME, "ulx timemuteid", cmd.timeMuteID, "!tmuteid" )
    timedMuteCommand:addParam{ type = ULib.cmds.Stringarg, hint = "steamid" }
    timedMuteCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
    timedMuteCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine, ULib.cmds.optional }
    timedMuteCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
    timedMuteCommand:defaultAccess( ULib.ACCESS_ADMIN )
    timedMuteCommand:help( "Mutes a steamid for a set amount of time" )
    timedMuteCommand:setOpposite( "ulx untimemute", {_, _, _, _, true}, "!untmute" )
end
