CFCUlxCurse.RegisterEffect( {
    name = "Test2",
    onStart = function( ply )
        MsgN( "Test2 effect started!" )
    end,
    onEnd = function( ply )
        MsgN( "Test2 effect ended!" )
    end,
    onTick = function( ply )
        MsgN( "Test2 effect ticked!" )
    end,
    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
