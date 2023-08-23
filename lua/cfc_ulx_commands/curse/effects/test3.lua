CFCUlxCurse.RegisterEffect( {
    name = "Test3",
    onStart = function( ply )
        MsgN( "Test3 effect started!" )
    end,
    onEnd = function( ply )
        MsgN( "Test3 effect ended!" )
    end,
    onTick = function( ply )
        MsgN( "Test3 effect ticked!" )
    end,
    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
