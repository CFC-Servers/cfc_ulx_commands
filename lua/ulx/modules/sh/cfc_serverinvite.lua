if CLIENT then
    local function MVsendInvitedPlayers( plytable )
        net.Start( "MVsendInvitedPlayers" )
        net.WriteTable( plytable )
        net.SendToServer()
    end

    local function MVsendAccept( inviter )
        net.Start( "MVsendAccept" )
        net.WriteEntity( inviter )
        net.SendToServer()
    end

    net.Receive( "MVReceiveConformation", function()
        local inviter = net.ReadEntity()
        local acceptedPlayers = net.ReadTable()

        -- Call function here, call MVsendAccept after it.
    end)
end

if SERVER then
    util.AddNetworkString( "MVsendInvitedPlayers" )
    util.AddNetworkString( "MVsendAccept" )
    util.AddNetworkString( "MVReceiveConformation" )

    local playerTables = {}
    net.Receive( "MVsendInvitedPlayers", function( _, ply )
        local players = net.ReadTable()

        playerTables[ply] = {}

        for _, v in ipairs( players ) do
            playerTables[ply][v] = false
        end

        timer.Simple( 20, function()
            if not IsValid( ply ) then return end

            local acceptedPlayers = {}
            for invitedply, accepted in pairs( playerTables[ply] ) do
                if not accepted then continue end
                table.insert( acceptedPlayers, invitedply )
            end

            for _, v in ipairs( playerTables ) do
                net.Start( "MVReceiveConformation" )
                net.WriteEntity( ply ) -- inviter
                net.WriteTable( acceptedPlayers )
                net.Send( v )
            end
        end)
    end)

    net.Receive( "MVsendAccept", function( _, ply )
        local inviter = net.ReadEntity()
        if not playerTables[inviter] then return end
        if not playerTables[inviter][ply] then return end
        playerTables[inviter][ply] = true
    end)
end
