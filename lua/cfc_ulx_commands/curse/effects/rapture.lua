local EFFECT_NAME = "Rapture"
local SPEED_MIN = 10
local SPEED_MAX = 75
local INTERVAL_MIN = 0.05
local INTERVAL_MAX = 2


local function startBlockingNoclip( cursedPly )
    cursedPly:SetMoveType( MOVETYPE_WALK )

    local function blockNoclip( ply, desiredState )
        if ply ~= cursedPly then return end
        if desiredState then return false end
    end

    if CLIENT then
        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerNoClip", "BlockNoclip", blockNoclip )

        return
    end

    CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerNoClip", "BlockNoclip", blockNoclip )

    -- Respawn the player if they are outside of the world.
    if not util.IsInWorld( cursedPly:GetPos() ) then
        cursedPly:Spawn()
    end
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        startBlockingNoclip( cursedPly )

        if CLIENT then return end

        local vel = Vector( 0, 0, 10 )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "Think", "GetYoinked", function()
            cursedPly:SetVelocity( vel )
        end )

        local timerNameEff
        timerNameEff = CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "ChangeVelocity", INTERVAL_MIN, 0, function()
            local speed = math.Rand( SPEED_MIN, SPEED_MAX )
            local velZ

            if cursedPly:IsOnGround() then
                velZ = math.Rand( 0, 1 )
            else
                velZ = math.Rand( -1, 1 )
            end

            vel = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), velZ ) * speed
            timer.Adjust( timerNameEff, math.Rand( INTERVAL_MIN, INTERVAL_MAX ) )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatibileEffects = {},
    groups = {
        "AddedMovement",
    },
    incompatibleGroups = {},
} )
