local EFFECT_NAME = "DisableNoclip"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


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

        CFCUlxCurse.AddEffectHook( cursedPly, "PlayerNoClip", HOOK_PREFIX .. "BlockNoclip", blockNoclip )

        -- Respawn the player if they are outside of the world.
        if not util.IsInWorld( cursedPly:GetPos() ) then
            cursedPly:Spawn()
        end
    end,

    onEnd = function()
        if CLIENT then
            hook.Remove( "PlayerNoClip", HOOK_PREFIX .. "BlockNoclip" )
        end
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
