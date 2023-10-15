local EFFECT_NAME = "CantStopWontStop"
local FRICTION_MULT = -0.2
local VELOCITY_MULT = Vector( 0, 0, 12.5 ) -- Additive multiplier against the player's velocity every tick.
local FALL_DAMAGE_STRENGTH = 70 / 3000 -- Multiplies against downwards speed when they fit the ground.
local WALL_DAMAGE_STRENGTH = 10 / 2000 -- Multiplies against the player's horizontal speed when they hit a wall.
local WALL_DAMAGE_THRESHOLD = 5 -- Don't count a wall damage event unless it does at least this much damage.
local WALL_DAMAGE_COOLDOWN = 0.5
local WALL_DETECTION_LENGTH = 20
local WALL_DETECTION_HULL_MULT = Vector( 1, 1, 0.75 / 2 )
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


local VECTOR_ZERO = Vector()


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        cursedPly:SetMoveType( MOVETYPE_WALK )

        local function blockNoclip( ply, desiredState )
            if ply ~= cursedPly then return end
            if desiredState then return false end
        end

        if CLIENT then
            hook.Add( "PlayerNoClip", HOOK_PREFIX .. "BlockNoclip", blockNoclip )

            return
        end

        local canWallDamage = true

        cursedPly:SetFriction( FRICTION_MULT )

        CFCUlxCurse.AddEffectHook( cursedPly, "PlayerNoClip", HOOK_PREFIX .. "BlockNoclip", blockNoclip )

        CFCUlxCurse.AddEffectHook( cursedPly, "PlayerSpawn", HOOK_PREFIX .. "SetFriction", function( ply )
            if ply ~= cursedPly then return end

            ply:SetFriction( FRICTION_MULT )
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, "Think", HOOK_PREFIX .. "GottaGoFast", function()
            local dt = FrameTime()
            local curVel = cursedPly:GetVelocity()

            cursedPly:SetVelocity( curVel * VELOCITY_MULT * dt )
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, "Think", HOOK_PREFIX .. "WallsArePainful", function()
            if not canWallDamage then return end
            if not cursedPly:Alive() then return end

            local vel = cursedPly:GetVelocity()
            rawset( vel, 3, 0 )

            if vel == VECTOR_ZERO then return end

            local speed = vel:Length2D()
            local impactDamage = speed * WALL_DAMAGE_STRENGTH
            if impactDamage < WALL_DAMAGE_THRESHOLD then return end

            local velDir = vel / speed
            local boxMax = cursedPly:OBBMaxs() * WALL_DETECTION_HULL_MULT
            local boxMin = -boxMax
            local traceStart = cursedPly:GetPos() + cursedPly:OBBCenter()

            local tr = util.TraceHull( {
                start = traceStart,
                endpos = traceStart + velDir * WALL_DETECTION_LENGTH,
                filter = cursedPly,
                mins = boxMin,
                maxs = boxMax,
                mask = MASK_PLAYERSOLID,
            } )

            if not tr.Hit then return end

            canWallDamage = false
            cursedPly:TakeDamage( impactDamage, game.GetWorld(), DMG_CRUSH )
            cursedPly:EmitSound( "physics/body/body_medium_impact_hard" .. math.random( 1, 6 ) .. ".wav" )

            CFCUlxCurse.CreateEffectTimer( cursedPly, HOOK_PREFIX .. "WallDamageCooldownFinished", WALL_DAMAGE_COOLDOWN, 1, function()
                canWallDamage = true
            end )
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, "EntityTakeDamage", HOOK_PREFIX .. "OwMyBones", function( victim, dmgInfo )
            if victim ~= cursedPly then return end
            if not dmgInfo:IsFallDamage() then return end

            local zSpeed = math.abs( victim:GetVelocity()[3] )

            dmgInfo:SetDamage( FALL_DAMAGE_STRENGTH * zSpeed )
        end )

        -- Respawn the player if they are outside of the world.
        if not util.IsInWorld( cursedPly:GetPos() ) then
            cursedPly:Spawn()
        end
    end,

    onEnd = function( cursedPly )
        if CLIENT then
            hook.Remove( "PlayerNoClip", HOOK_PREFIX .. "BlockNoclip" )

            return
        end

        cursedPly:SetFriction( 1 )
    end,

    minDuration = 30,
    maxDuration = 60,
    onetimeDurationMult = 2,
    excludeFromOnetime = true,
} )
