local EFFECT_NAME = "Rubberband"
local RUBBERBAND_INTERVAL = 0.1
local RUBBERBAND_CHANCE = 0.05
local RUBBERBAND_COOLDOWN = 0.2
local RUBBERBAND_AMOUNT_MIN = 0.1
local RUBBERBAND_AMOUNT_MAX = 1
local RUBBERBAND_RECORD_CHANCE = 0.5


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        local snapshot = {}
        local onCooldown = false


        local function recordSnapshot()
            local alive = cursedPly:Alive()

            snapshot.Pos = cursedPly:GetPos()
            snapshot.Vel = cursedPly:GetVelocity()
            snapshot.Health = alive and cursedPly:Health() or cursedPly:GetMaxHealth()
            snapshot.Armor = cursedPly:Armor()
        end

        local function applySnapshot()
            if not cursedPly:Alive() then return end

            cursedPly:SetPos( snapshot.Pos )
            cursedPly:SetVelocity( snapshot.Vel - cursedPly:GetVelocity() )
            cursedPly:SetHealth( snapshot.Health )
            cursedPly:SetArmor( snapshot.Armor )
        end


        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "StartSnapback", RUBBERBAND_INTERVAL, 0, function()
            if onCooldown then return end
            if not cursedPly:Alive() then return end
            if RUBBERBAND_CHANCE ~= 1 and math.Rand( 0, 1 ) > RUBBERBAND_CHANCE then return end

            onCooldown = true

            if RUBBERBAND_RECORD_CHANCE == 1 or math.Rand( 0, 1 ) <= RUBBERBAND_RECORD_CHANCE then
                recordSnapshot()
            end

            local delay = math.Rand( RUBBERBAND_AMOUNT_MIN, RUBBERBAND_AMOUNT_MAX )

            CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "ApplySnapback", delay, 1, function()
                applySnapshot()

                CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "EndCooldown", RUBBERBAND_COOLDOWN, 1, function()
                    onCooldown = false
                end )
            end )
        end )

        recordSnapshot()
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {
        "Ball",
        "Jittery",
    },
    groups = {
        "Teleportation",
    },
    incompatibleGroups = {
        "Teleportation",
    },
} )
