local EFFECT_NAME = "DisableNoclip"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
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
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatibileEffects = {
        "NoclipSpam",
    },
    groups = {
        "BlockNoclip",
    },
    incompatibleGroups = {
        "Noclip",
    },
} )
