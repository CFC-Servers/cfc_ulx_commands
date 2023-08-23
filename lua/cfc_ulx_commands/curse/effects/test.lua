CFCUlxCurse.RegisterEffect( {
    name = "Test",
    onStart = function( ply )
        MsgN( "Test effect started!" )
    end,
    onEnd = function( ply )
        MsgN( "Test effect ended!" )
    end,
    onTick = function( ply )
        MsgN( "Test effect ticked!" )
    end,
    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
