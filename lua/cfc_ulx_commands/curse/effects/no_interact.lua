local EFFECT_NAME = "NoInteract"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        hook.Add( "CreateMove", HOOK_PREFIX .. "LBozo", function( cmd )
            cmd:RemoveKey( IN_ATTACK )
            cmd:RemoveKey( IN_ATTACK2 )
            cmd:RemoveKey( IN_RELOAD )
            cmd:RemoveKey( IN_USE )
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "CreateMove", HOOK_PREFIX .. "LBozo" )
    end,

    minDuration = 5,
    maxDuration = 20,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
