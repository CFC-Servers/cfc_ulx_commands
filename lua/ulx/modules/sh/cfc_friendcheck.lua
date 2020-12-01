CFCUlxCommands.friendcheck = CFCUlxCommands.friendcheck or {}
local cmd = CFCUlxCommands.friendcheck

CATEGORY_NAME = "Utility"

if SERVER then
    util.AddNetworkString( "CFC_ULX_FriendCheckSend" )
    util.AddNetworkString( "CFC_ULX_FriendCheckRecieve" )
end

local awaitingResponse = {}

net.Receive( "CFC_ULX_FriendCheckRecieve", function( _, ply )
    if not ply.waitingOnFriendCheck then return end
    local friendTable = net.ReadTable()
    ply.waitingOnFriendCheck = false

    PrintTable( friendTable )
    ulx.fancyLogAdmin( awaitingResponse[ply], true, "#T's sv_allowcslua value is " .. tostring( convar ), ply )

    awaitingResponse[ply] = nil
end )

function cmd.friendcheckPlayers( callingPlayer, targetPlayers )
    for _, ply in pairs( targetPlayers ) do
        ply.waitingOnFriendCheck = true
        awaitingResponse[ply] = callingPlayer
        net.Start( "CFC_ULX_FriendCheckSend" )
        net.Send( ply )
    end
end

if CLIENT then
    net.Receive( "CFC_ULX_FriendCheckSend", function()
        local friendTable

        for _, ply in pairs( player.GetHumans() ) do
            local friendStatus = ply:GetFriendStatus()
            if friendStatus == "none" then return end
            table.insert( friendTable, ply, friendStatus )
        end

        net.Start( "CFC_ULX_FriendCheckRecieve" )
        net.WriteTable( friendTable )
        net.SendToServer()
    end )
end

local friendcheckCommand = ulx.command( CATEGORY_NAME, "ulx friendcheck", cmd.friendcheckPlayers, "!friendcheck" )
friendcheckCommand:addParam{ type = ULib.cmds.PlayersArg }
friendcheckCommand:defaultAccess( ULib.ACCESS_ADMIN )
friendcheckCommand:help( "Checks the targetted player(s) friends." )
