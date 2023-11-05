local EFFECT_NAME = "EntMagnet"
local PULL_STRENGTH = 5 * 10^7
local PULL_ACCELERATION_MAX = 5000


local mathMin = math.min


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "Think", "Reposition", function()
            local plyPos = cursedPly:GetPos() + cursedPly:OBBCenter()
            local dt = FrameTime()

            for _, ent in ipairs( ents.GetAll() ) do
                if IsValid( ent ) then
                    local entPos = ent:GetPos()
                    local entVel = ent.CFCUlxCurseMagnetVel or Vector( 0, 0, 0 )
                    local entToPly = plyPos - entPos
                    local entToPlyLength = entToPly:Length()

                    if entToPlyLength ~= 0 then
                        local entToPlyDir = entToPly / entToPlyLength
                        local accel = mathMin( PULL_STRENGTH / ( entToPlyLength * entToPlyLength ), PULL_ACCELERATION_MAX ) * dt
                        entVel = entVel + entToPlyDir * accel

                        ent:SetNetworkOrigin( entPos + entVel * dt )
                        ent.CFCUlxCurseMagnetVel = entVel
                    end
                end
            end
        end )
    end,

    onEnd = function( cursedPly )
        if SERVER then return end

        for _, ent in ipairs( ents.GetAll() ) do
            ent.CFCUlxCurseMagnetVel = nil
        end

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
        "EntJitter",
    },
} )
