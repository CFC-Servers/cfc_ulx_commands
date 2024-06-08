local EFFECT_NAME = "HealthDrain"
local DRAIN_RATE = 5 -- Health lost per second.


local DRAIN_INTERVAL = 1 / DRAIN_RATE


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerDeath", "EndEffectEarly", function( ply )
            if ply ~= cursedPly then return end

            CFCUlxCurse.StopCurseEffect( cursedPly, EFFECT_NAME )
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerSilentDeath", "EndEffectEarly", function( ply )
            if ply ~= cursedPly then return end

            CFCUlxCurse.StopCurseEffect( cursedPly, EFFECT_NAME )
        end )

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "Drain", DRAIN_INTERVAL, 0, function()
            if not cursedPly:Alive() then
                CFCUlxCurse.StopCurseEffect( cursedPly, EFFECT_NAME )

                return
            end

            local newHealth = math.max( 0, cursedPly:Health() - 1 )

            if newHealth == 0 then
                cursedPly:KillSilent()
                CFCUlxCurse.StopCurseEffect( cursedPly, EFFECT_NAME )

                return
            end

            cursedPly:SetHealth( newHealth )
        end )
    end,

    onEnd = function()
        -- Do Nothing
    end,

    minDuration = 2 * 100 / DRAIN_RATE,
    maxDuration = 4 * 100 / DRAIN_RATE,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatibileEffects = {},
    groups = {
        "Health",
        "Death",
    },
    incompatibleGroups = {
        "Health",
    },
} )
