local EFFECT_NAME = "EntJitter"
local JITTER_SCALE = 5


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        -- Do nothing.
    end,

    onEnd = function()
        if SERVER then return end

        -- Force a full game update
        RunConsoleCommand( "record", "fix" )
        RunConsoleCommand( "stop" )
    end,

    onTick = function()
        if SERVER then return end

        for _, ent in ipairs( ents.GetAll() ) do
            if IsValid( ent ) then
                local pos = ent:GetPos() + Vector(
                    math.Rand( -JITTER_SCALE, JITTER_SCALE ),
                    math.Rand( -JITTER_SCALE, JITTER_SCALE ),
                    math.Rand( -JITTER_SCALE, JITTER_SCALE )
                )

                ent:SetNetworkOrigin( pos )
            end
        end
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
