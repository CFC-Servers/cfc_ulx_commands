local EFFECT_NAME = "SprintExplode"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        CFCUlxCurse.AddEffectHook( cursedPly, "KeyPress", HOOK_PREFIX .. "Boom", function( ply, key )
            if ply ~= cursedPly then return end
            if key ~= IN_RUN then return end
            if not ply:Alive() then return end
            if ply:HasGodMode() then return end

            local plyTeam = ply:Team()
            if plyTeam == TEAM_SPECTATOR or plyTeam == TEAM_SPEC then return end -- TEAM_SPEC is used by TTT

            local effect = EffectData()
            effect:SetOrigin( ply:GetPos() )
            effect:SetMagnitude( 1 )
            effect:SetScale( 1 )
            util.Effect( "Explosion", effect, true, true )

            if engine.ActiveGamemode() == "terrortown" then
                ply:Kill()
            else
                ply:KillSilent()
            end
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 20,
    maxDuration = 50,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
