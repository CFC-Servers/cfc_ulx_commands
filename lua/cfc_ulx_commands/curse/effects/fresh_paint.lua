local EFFECT_NAME = "FreshPaint"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        for _, ent in ipairs( ents.GetAll() ) do
            if IsValid( ent ) then
                local color = Color(
                    math.Rand( 0, 255 ),
                    math.Rand( 0, 255 ),
                    math.Rand( 0, 255 ),
                    math.Rand( 0, 255 )
                )

                ent:SetColor( color )
            end
        end
    end,

    onEnd = function()
        if SERVER then return end

        -- Force a full game update
        RunConsoleCommand( "record", "fix" )
        RunConsoleCommand( "stop" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
