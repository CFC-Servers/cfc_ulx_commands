CFCUlxCommands.friendcheck = CFCUlxCommands.friendcheck or {}
local cmd = CFCUlxCommands.friendcheck

CATEGORY_NAME = "Utility"

if SERVER then
    util.AddNetworkString( "CFC_ULX_FriendCheckSend" )
    util.AddNetworkString( "CFC_ULX_FriendCheckRecieve" )
end

local awaitingResponse = {}
local targettedPlayers

net.Receive( "CFC_ULX_FriendCheckRecieve", function( _, ply )
    if not ply.waitingOnFriendCheck then return end
    local friendTable = net.ReadTable()
    ply.waitingOnFriendCheck = false

    local caller = awaitingResponse[ply]
    
    caller:PrintMessage( 2 , "\n=======================" )
    caller:PrintMessage( 2 , ply:Name() .. "'s friends:" )
    caller:PrintMessage( 2 , "-----------------------" )
    for target, status in pairs( friendTable ) do
        caller:PrintMessage( 2 , target:Name() .. " : " .. status )
    end
    caller:PrintMessage( 2 , "=======================" )

    awaitingResponse[ply] = nil
end )

function cmd.friendcheckPlayers( callingPlayer, targetPlayers )
    targettedPlayers = targetPlayers
    for _, ply in pairs( targetPlayers ) do
        ply.waitingOnFriendCheck = true
        awaitingResponse[ply] = callingPlayer
        net.Start( "CFC_ULX_FriendCheckSend" )
        net.Send( ply )
    end
    ulx.fancyLogAdmin( callingPlayer, true, "#A checked #T's friends." , targettedPlayers )
end

if CLIENT then
    local friendTable = {}
    function getFriendStatus( ply )
        if ply == LocalPlayer() then return end

        local friendStatus = ply:GetFriendStatus()
        if friendStatus == "none" then return end

        friendTable[ply] = friendStatus
    end

    net.Receive( "CFC_ULX_FriendCheckSend", function()
        friendTable = {}
        local onlinePlayers = player.GetHumans()
        for _, ply in pairs( onlinePlayers ) do
            getFriendStatus( ply )
        end

        net.Start( "CFC_ULX_FriendCheckRecieve" )
        net.WriteTable( friendTable )
        net.SendToServer()
    end )
end

local friendcheckCommand = ulx.command( CATEGORY_NAME, "ulx friendcheck", cmd.friendcheckPlayers, "!friendcheck" )
friendcheckCommand:addParam{ type = ULib.cmds.PlayersArg }
friendcheckCommand:defaultAccess( ULib.ACCESS_ADMIN )
friendcheckCommand:help( "Checks the targetted player(s) friends and prints the results in the console." )
