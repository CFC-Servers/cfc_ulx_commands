net.Receive( "CFC_ULX_ConstraintResults", function()
    MsgC( unpack( net.ReadTable() ) )
end )
