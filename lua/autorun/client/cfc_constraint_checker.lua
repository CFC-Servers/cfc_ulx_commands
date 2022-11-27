local NETWORK_NAME = "CFC_ulx-constraint_checker"
net.Receive( NETWORK_NAME, function()
    MsgC( unpack( net.ReadTable() ) )
end )
