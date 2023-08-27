local EFFECT_NAME = "EntJitter"
local JITTER_SCALE = 5
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        hook.Add( "Think", HOOK_PREFIX .. "Reposition", function()
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

    onEnd = function()
        if SERVER then return end

        hook.Remove( "Think", HOOK_PREFIX .. "Reposition" )

        -- Force a full game update
        RunConsoleCommand( "record", "fix" )
        RunConsoleCommand( "stop" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
