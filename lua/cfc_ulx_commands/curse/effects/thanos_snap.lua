local EFFECT_NAME = "ThanosSnap"
local DISAPPEAR_INTERVAL = 0.15 -- Seconds between each pass across all entities.
local DISAPPEAR_CHANCE = 0.01 -- Chance for each entity to disappear each pass.
local DO_EFFECT = true -- Play a sound and particle effect when an ent disappears.
local DO_SOUND = true -- Play a sound when an ent disappears. (Only if DO_EFFECT is true.)


local trySnap

if CLIENT then
    local COLOR = Color( 255, 255, 255, 0 )
    local RENDER_MODE = RENDERMODE_TRANSCOLOR
    local MATERIAL = "engine/writestencil"
    local COLLISION_GROUP = COLLISION_GROUP_IN_VEHICLE

    trySnap = function( ent )
        if not IsValid( ent ) then return end
        if ent.PACPart then return end
        if ent:IsPlayer() then return end
        if ent:IsWeapon() then return end
        if ent:GetColor() == COLOR then return end
        if math.Rand( 0, 1 ) > DISAPPEAR_CHANCE then return end

        ent:SetColor( COLOR )
        ent:SetRenderMode( RENDER_MODE )
        ent:SetMaterial( MATERIAL )
        ent:SetCollisionGroup( COLLISION_GROUP )

        if not DO_EFFECT then return end

        local effect = EffectData()
        effect:SetOrigin( ent:WorldSpaceCenter() )
        effect:SetMagnitude( 1 )
        effect:SetScale( 1 )
        util.Effect( "ElectricSpark", effect )

        if not DO_SOUND then return end

        ent:EmitSound( "ambient/energy/spark" .. math.random( 1, 4 ) .. ".wav", 75, 100, 0.75 )
    end
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "Snap", DISAPPEAR_INTERVAL, 0, function()
            for _, ent in ipairs( ents.GetAll() ) do
                trySnap( ent )
            end
        end )
    end,

    onEnd = function( cursedPly )
        if SERVER then return end

        -- Ensure nothing is altered while receiving the game update
        CFCUlxCurse.RemoveEffectTimer( cursedPly, EFFECT_NAME, "Snap" )

        -- Force a full game update
        RunConsoleCommand( "record", "fix" )
        RunConsoleCommand( "stop" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
