local EFFECT_NAME = "Crouch"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        hook.Add( "CreateMove", HOOK_PREFIX .. "LBozo", function( cmd )
            cmd:AddKey( IN_DUCK )
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "CreateMove", HOOK_PREFIX .. "LBozo" )
    end,

    onTick = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
