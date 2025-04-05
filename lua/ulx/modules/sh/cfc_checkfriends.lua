CFCUlxCommands.checkfriends = CFCUlxCommands.checkfriends or {}
local cmd = CFCUlxCommands.checkfriends

local CATEGORY_NAME = "Utility"

if SERVER then
    util.AddNetworkString( "CFC_ULX_CheckFriendsSend" )
    util.Addtring( "CFC_ULX_CheckFriendsReceive" )
end

local awaitingResponse = {}

local function sendResponse( ply, friendTable, caller )
    if not IsValid( caller ) then -- console
        print( "\n=======================" )
        print( ply:Name() .. "'s friends:" )
        print( "-----------------------" )
        for target, status in pairs( friendTable ) do
            print( target:Name() .. " : " .. status )
        end
        print( "=======================" )

        return
    end

    caller:PrintMessage( 2, "\n=======================" )
    caller:PrintMessage( 2, ply:Name() .. "'s friends:" )
    caller:PrintMessage( 2, "-----------------------" )
    for target, status in pairs( friendTable ) do
        caller:PrintMessage( 2, target:Name() .. " : " .. status )
    end
    caller:PrintMessage( 2, "=======================" )
end

net.Receive( "CFC_ULX_CheckFriendsReceive", function( _, ply )
    if awaitingResponse[ply] == nil then return end
    local friendTable = net.ReadTable()

    local caller = awaitingResponse[ply]
    if table.IsEmpty( friendTable ) then
        if IsValid( caller ) then
            caller:PrintMessage( 2, ply:Name() .. " does currently not have any friends on the server." )
        else
            print( ply:Name() .. " does currently not have any friends on the server." )
        end
        return
    end

    sendResponse( ply, friendTable, caller )

    awaitingResponse[ply] = nil
end )

function cmd.checkfriendsPlayers( callingPlayer, targetPlayers )
    for _, ply in ipairs( targetPlayers ) do
        awaitingResponse[ply] = callingPlayer
        net.Start( "CFC_ULX_CheckfriendsSend" )
        net.Send( ply )
    end

    ulx.fancyLogAdmin( callingPlayer, true, "#A checked #T's friends.", targetPlayers )
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
        for _, ply in ipairs( onlinePlayers ) do
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
