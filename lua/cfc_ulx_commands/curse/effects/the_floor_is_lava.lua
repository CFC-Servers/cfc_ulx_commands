local EFFECT_NAME = "TheFloorIsLava"
local GRACE_DURATION = 5 -- Must be an integer.
local DAMAGE_PER_TICK = 10 -- 0 to instakill.
local DAMAGE_TICK_RATE = 0.2 -- In seconds.


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        local underGrace = false
        local world = game.GetWorld()
        local nextDamageTime = 0


        local function applyGracePeriod()
            underGrace = true

            local timeLeft = GRACE_DURATION

            cursedPly:PrintMessage( HUD_PRINTCENTER, "The floor is lava!\nGrace period ends in " .. timeLeft )

            CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "GracePeriod", 1, GRACE_DURATION, function()
                timeLeft = timeLeft - 1

                if timeLeft == 0 then
                    underGrace = false
                    cursedPly:PrintMessage( HUD_PRINTCENTER, "The floor is lava!" )
                else
                    cursedPly:PrintMessage( HUD_PRINTCENTER, "The floor is lava!\nGrace period ends in " .. timeLeft )
                end
            end )
        end

        local function kill()
            PrintMessage( HUD_PRINTCONSOLE, cursedPly:Nick() .. " burned to a crisp playing The Floor is Lava!" )
            cursedPly:Kill()
        end


        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerSpawn", "ApplyGracePeriod", function( ply )
            if ply ~= cursedPly then return end

            applyGracePeriod()
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "Think", "Kill", function()
            local now = CurTime()
            if now < nextDamageTime then return end
            if underGrace then return end
            if not cursedPly:Alive() then return end
            if cursedPly.frozen then return end
            if cursedPly:WaterLevel() > 0 then return end
            if not cursedPly:OnGround() then return end
            if cursedPly:GetGroundEntity() ~= world then return end

            if DAMAGE_PER_SECOND == 0 then
                kill()

                return
            end

            cursedPly:Ignite( 100 )
            cursedPly:SetHealth( math.max( 0, cursedPly:Health() - DAMAGE_PER_TICK ) )
            cursedPly:EmitSound( "player/pl_burnpain" .. math.random( 1, 3 ) ..  ".wav" )

            nextDamageTime = now + DAMAGE_TICK_RATE

            if cursedPly:Health() <= 0 then
                kill()
            end
        end )


        applyGracePeriod()

        -- Unragdoll the player and prevent ragdolling, since unragdolling counts as a respawn.
        if cursedPly.ragdoll then
            ulx.unragdollPlayer( cursedPly )
        end

        ulx.setExclusive( cursedPly, "playing The Floor is Lava" )
    end,

    onEnd = function( cursedPly )
        if CLIENT then return end

        ulx.clearExclusive( cursedPly )
        cursedPly:Extinguish()
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {},
    groups = {
        "Death",
    },
    incompatibleGroups = {},
} )
