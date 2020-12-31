CFCUlxCommands.checklua = CFCUlxCommands.checklua or {}
local cmd = CFCUlxCommands.checklua

local CATEGORY_NAME = "Utility"
local AUTO_BAN_LENGTH = ( 60 * 60 ) * 6
local AUTO_BAN_REASON = "Server/Client mismatch. Please disable any third-party programs that modify your game."
local CONVARS_TO_CHECK = { "sv_allowcslua" }

if SERVER then
    util.AddNetworkString( "CFC_ULX_StatCheck" )
    util.AddNetworkString( "CFC_ULX_AutoStatCheck" )

    local awaitingResponse = {}

    local function sendAwarn( ply )
        if not awarn_warnplayer then return end

        awarn_warnplayer( nil, ply, AUTO_BAN_REASON )
    end

    local function receiveConvars( ply )
        local any = false
        local badConvars = {}

        for _, convar in pairs( CONVARS_TO_CHECK ) do
            local convarValue = net.ReadBool()

            if convarValue then
                any = true
                badCovnars[convar] = convarValue
                ulx.fancyLogAdmin( awaitingResponse[ply], true, "#T's " .. convar .. "value is " .. tostring( convarValue ), ply )
            end
        end

        return any, badConvars
    end

    local function unawaitTimerName( steamId )
        return "CFC_ULX_AutoStatsUnAwait_" .. steamId
    end

    net.Receive( "CFC_ULX_StatCheck", function( _, ply )
        if not awaitingResponse[ply] then return end
        awaitingResponse[ply] = nil

        receiveConvars( ply )
    end )

    net.Receive( "CFC_ULX_AutoStatCheck", function( _, ply )
        if not awaitingResponse[ply] then return end
        awaitingResponse[ply] = nil
        timer.Remove( unawaitTimerName( ply:GetSteamID() ) )

        local anyConvars, badConvars = receiveConvars( ply )

        if anyConvars then
            print( "Banning " .. tostring( ply ) .. " for having bad convars." )
            PrintTable( badConvars )

            ulx.ban( nil, ply, AUTO_BAN_LENGTH, AUTO_BAN_REASON )
            sendAwarn( ply )
        end
    end )

    function cmd.checkluaPlayers( callingPlayer, targetPlayers )
        for _, ply in pairs( targetPlayers ) do
            awaitingResponse[ply] = callingPlayer
            net.Start( "CFC_ULX_StatCheckCL" )
            net.Send( ply )
        end
    end

    gameevent.Listen( "player_connect" )
    hook.Add( "player_connect", "CFC_ULX_AutoStatsCheckOnConnect", function( data )
        local steamId = data.networkid

        local ply = player.GetBySteamID( steamId )
        awaitingResponse[ply] = true

        timer.Create( unawaitTimerName( steamId ), 60 * 15, 1, function()
            awaitingResponse[ply] = nil
        end )
    end )
end

if CLIENT then
    local function respondToQuery( networkString )
        net.Start( networkString )

        for _, convar in pairs( CONVARS_TO_CHECK ) do
            net.WriteBool( GetConVar( convar ):GetBool() )
        end

        net.SendToServer()
    end

    net.Receive( "CFC_ULX_StatCheck", function()
        respondToQuery( "CFC_ULX_StatCheck" )
    end )

    hook.Add( "InitPostEntity", "CFC_ULX_StatsReady", function()
        respondToQuery( "CFC_ULX_AutoStatCheck" )
    end )
end

local function doCheck( ... )
    if CLIENT then return end

    return cmd.checkluaPlayers( ... )
end

local checkluaCommand = ulx.command( CATEGORY_NAME, "ulx checklua", doCheck, "!checklua" )
checkluaCommand:addParam{ type = ULib.cmds.PlayersArg }
checkluaCommand:defaultAccess( ULib.ACCESS_ADMIN )
checkluaCommand:help( "Checks target(s) sv_allowcslua, true means they modified their client value." )
