local EFFECT_NAME = "EntJitter"
local JITTER_SCALE = 5


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "Think", "Reposition", function()
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
        end )
    end,

    onEnd = function( cursedPly )
        if SERVER then return end

        -- Ensure nothing is altered while receiving the game update
        CFCUlxCurse.RemoveEffectHook( cursedPly, EFFECT_NAME, "Think", "Reposition" )

        -- Force a full game update
        RunConsoleCommand( "record", "fix" )
        RunConsoleCommand( "stop" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatabileEffects = {
        "EntMagnet",
    },
} )
