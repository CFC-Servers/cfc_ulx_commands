local EFFECT_NAME = "HealthDrain"
local DRAIN_RATE = 5 -- Health lost per second.
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"

local DRAIN_INTERVAL = 1 / DRAIN_RATE


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        CFCUlxCurse.AddEffectHook( cursedPly, "PlayerDeath", HOOK_PREFIX .. "EndEffectEarly", function( ply )
            if ply ~= cursedPly then return end

            CFCUlxCurse.StopCurseEffect( cursedPly )
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, "PlayerSilentDeath", HOOK_PREFIX .. "EndEffectEarly", function( ply )
            if ply ~= cursedPly then return end

            CFCUlxCurse.StopCurseEffect( cursedPly )
        end )

        CFCUlxCurse.CreateEffectTimer( cursedPly, HOOK_PREFIX .. "Drain", DRAIN_INTERVAL, 0, function()
            if not IsValid( cursedPly ) then return end

            if not cursedPly:Alive() then
                CFCUlxCurse.StopCurseEffect( cursedPly )

                return
            end

            local newHealth = math.max( 0, cursedPly:Health() - 1 )

            if newHealth == 0 then
                cursedPly:KillSilent()
                CFCUlxCurse.StopCurseEffect( cursedPly )

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
} )
