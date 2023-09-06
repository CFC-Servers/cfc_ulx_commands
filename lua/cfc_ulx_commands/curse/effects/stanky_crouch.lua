local EFFECT_NAME = "StankyCrouch"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        hook.Add( "CreateMove", HOOK_PREFIX .. "LBozo", function( cmd )
            local cmdNum = cmd:CommandNumber()

            if  cmdNum % 20 > 3 and
                cmdNum % 12 ~= 0 and
                cmdNum % 200 > 10
            then return end

            cmd:AddKey( IN_DUCK )
            cmd:AddKey( IN_WALK )
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "CreateMove", HOOK_PREFIX .. "LBozo" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
