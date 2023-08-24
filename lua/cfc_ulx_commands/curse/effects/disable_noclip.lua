local EFFECT_NAME = "DisableNoclip"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"

local affectedPlys = {}


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        affectedPlys[cursedPly] = true

        cursedPly:SetMoveType( MOVETYPE_WALK )

        if CLIENT then return end

        -- Respawn the player if they are outside of the world.
        if not util.IsInWorld( cursedPly:GetPos() ) then
            cursedPly:Spawn()
        end
    end,

    onEnd = function( cursedPly )
        affectedPlys[cursedPly] = nil
    end,

    onTick = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )


hook.Add( "PlayerNoClip", HOOK_PREFIX .. "BlockNoclip", function( ply, desiredState )
    if not affectedPlys[ply] then return end
    if desiredState then return false end
end )
