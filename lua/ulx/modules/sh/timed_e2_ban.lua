CFCUlxCommands.e2ban = CFCUlxCommands.e2ban or {}
local cmd = CFCUlxCommands.e2ban
local CATEGORY_NAME = "Utility"
local PUNISHMENT = "e2ban"

if SERVER then
    local function enable( ply )
        ply.isE2Banned = true

        for _, ent in ipairs( ents.FindByClass( "gmod_wire_expression2" ) ) do
            if ent.player == ply then
                ent:Remove()
            end
        end
    end

    local function disable( ply )
        ply.isE2Banned = false
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

--== Time E2Ban by Player ==--
do
    function cmd.e2ban( callingPlayer, targetPlayers, minutes, reason, shouldUnE2Ban )
        reason = reason or ""

        if shouldUnE2Ban then
            for _, ply in pairs( targetPlayers ) do
                TimedPunishments.Unpunish( ply:SteamID64(), PUNISHMENT )
            end

            return ulx.fancyLogAdmin( callingPlayer, "#A unbanned #T from E2!", targetPlayers )
        end

        -- time > 100 years
        if minutes == 0 then minutes = 9999999999 end
        local expiration = os.time() + ( minutes * 60 )
        local issuer = callingPlayer and callingPlayer:SteamID64() or "Console"

        for _, ply in pairs( targetPlayers ) do
            TimedPunishments.Punish( ply:SteamID64(), PUNISHMENT, expiration, issuer, reason )
        end

        ulx.fancyLogAdmin( callingPlayer, "#A banned #T from E2 for #i minutes! (%s)", targetPlayers, minutes, reason )
    end

    local e2BanCommand = ulx.command( CATEGORY_NAME, "ulx e2ban", cmd.e2ban, "!e2ban" )
    e2BanCommand:addParam{ type = ULib.cmds.PlayersArg }
    e2BanCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
    e2BanCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine }
    e2BanCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
    e2BanCommand:defaultAccess( ULib.ACCESS_ADMIN )
    e2BanCommand:help( "Bans the target for a certain time from using E2" )
    e2BanCommand:setOpposite( "ulx une2ban", {_, _, _, _, true}, "!une2ban" )
end

--== Time E2Ban by SteamID ==--
do
    function cmd.e2banID( callingPlayer, target, minutes, reason, shouldUnE2Ban )
        reason = reason or ""
        local steamID64 = util.SteamIDTo64( target )

        if shouldUnE2Ban then
            TimedPunishments.Unpunish( steamID64, PUNISHMENT )

            return ulx.fancyLogAdmin( callingPlayer, "#A unbanned #s from E2!", target )
        end

        -- time > 100 years
        if minutes == 0 then minutes = 9999999999 end
        local expiration = os.time() + ( minutes * 60 )
        local issuer = callingPlayer and callingPlayer:SteamID64() or "Console"

        TimedPunishments.Punish( steamID64, PUNISHMENT, expiration, issuer, reason )

        ulx.fancyLogAdmin( callingPlayer, "#A banned #s from E2 for #i minutes! (%s)", target, minutes, reason )
    end

    local e2BanCommand = ulx.command( CATEGORY_NAME, "ulx e2banid", cmd.e2banID, "!e2banid" )
    e2BanCommand:addParam{ type = ULib.cmds.StringArg, hint = "steamid" }
    e2BanCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
    e2BanCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine }
    e2BanCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
    e2BanCommand:defaultAccess( ULib.ACCESS_ADMIN )
    e2BanCommand:help( "Bans the target for a certain time from using E2" )
    e2BanCommand:setOpposite( "ulx une2banid", {_, _, _, _, true}, "!une2banid" )
end

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
