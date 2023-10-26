local EFFECT_NAME = "Clumsy"
local RAGDOLL_GAP_MIN = 0.5
local RAGDOLL_GAP_MAX = 4
local RAGDOLL_DURATION_MIN = 0.25
local RAGDOLL_DURATION_MAX = 1


local tryRagdoll
local tryUnragdoll

if SERVER then
    tryRagdoll = function( ply )
        if ulx.getExclusive( ply ) then return end
        if ply.ragdoll then return end

        ulx.ragdollPlayer( ply )
    end

    tryUnragdoll = function( ply )
        if not ply.ragdoll then return end

        ulx.unragdollPlayer( ply )
    end
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        local function briefRagdoll()
            tryRagdoll( cursedPly )

            local ragdollDuration = math.Rand( RAGDOLL_DURATION_MIN, RAGDOLL_DURATION_MAX )

            CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "Unragdoll", ragdollDuration, 1, function()
                tryUnragdoll( cursedPly )

                local ragdollGap = math.Rand( RAGDOLL_GAP_MIN, RAGDOLL_GAP_MAX )

                CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "NextRagdoll", ragdollGap, 1, briefRagdoll )
            end )
        end

        briefRagdoll()
    end,

    onEnd = function( cursedPly )
        if CLIENT then return end

        if IsValid( cursedPly ) then
            tryUnragdoll( cursedPly )
        end
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatabileEffects = {},
} )
