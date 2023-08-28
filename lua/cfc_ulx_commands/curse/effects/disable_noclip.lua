local EFFECT_NAME = "DisableNoclip"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        hook.Add( "PlayerNoClip", HOOK_PREFIX .. "BlockNoclip_" .. cursedPly:SteamID64(), function( ply, desiredState )
            if ply ~= cursedPly then return end
            if desiredState then return false end
        end )

        cursedPly:SetMoveType( MOVETYPE_WALK )

        if CLIENT then return end

        -- Respawn the player if they are outside of the world.
        if not util.IsInWorld( cursedPly:GetPos() ) then
            cursedPly:Spawn()
        end
    end,

    onEnd = function( cursedPly )
        hook.Remove( "PlayerNoClip", HOOK_PREFIX .. "BlockNoclip_" .. cursedPly:SteamID64() )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
