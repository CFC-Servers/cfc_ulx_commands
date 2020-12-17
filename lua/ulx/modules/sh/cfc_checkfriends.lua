CFCUlxCommands.checkfriends = CFCUlxCommands.checkfriends or {}
local cmd = CFCUlxCommands.checkfriends

local CATEGORY_NAME = "Utility"

if SERVER then
    util.AddNetworkString( "CFC_ULX_CheckFriendsSend" )
    util.AddNetworkString( "CFC_ULX_CheckFriendsReceive" )
end

local awaitingResponse = {}

net.Receive( "CFC_ULX_CheckFriendsReceive", function( _, ply )
    if awaitingResponse[ply] == nil then return end
    local friendTable = net.ReadTable()

    local caller = awaitingResponse[ply]
    if table.IsEmpty(friendTable) then
        ulx.fancyLogAdmin( caller, true, "#A checked #T's friends, they have currently no friends playing on this server" , ply )
        return
    end
    
    caller:PrintMessage( 2 , "\n=======================" )
    caller:PrintMessage( 2 , ply:Name() .. "'s friends:" )
    caller:PrintMessage( 2 , "-----------------------" )
    for target, status in pairs( friendTable ) do
        caller:PrintMessage( 2 , target:Name() .. " : " .. status )
    end
    caller:PrintMessage( 2 , "=======================" )

    awaitingResponse[ply] = nil
    ulx.fancyLogAdmin( caller, true, "#A checked #T's friends." , ply )
end )

function cmd.checkfriendsPlayers( callingPlayer, targetPlayers )
    for _, ply in pairs( targetPlayers ) do
        awaitingResponse[ply] = callingPlayer
        net.Start( "CFC_ULX_CheckfriendsSend" )
        net.Send( ply )
    end
end

if CLIENT then
    local friendTable = {}
    local function getFriendStatus( ply )
        if ply == LocalPlayer() then return end

        local friendStatus = ply:GetFriendStatus()
        if friendStatus == "none" then return end

        return friendStatus
    end

    net.Receive( "CFC_ULX_CheckFriendsSend", function()
        friendTable = {}
        local onlinePlayers = player.GetHumans()
        for _, ply in pairs( onlinePlayers ) do
            friendTable[ply] = getFriendStatus( ply )
        end

        net.Start( "CFC_ULX_CheckFriendsReceive" )
        net.WriteTable( friendTable )
        net.SendToServer()
    end )
end

local checkfriendsCommand = ulx.command( CATEGORY_NAME, "ulx checkfriends", cmd.checkfriendsPlayers, "!checkfriends" )
checkfriendsCommand:addParam{ type = ULib.cmds.PlayersArg }
checkfriendsCommand:defaultAccess( ULib.ACCESS_ADMIN )
checkfriendsCommand:help( "Checks the targetted player(s) friends and prints the results in the console." )
