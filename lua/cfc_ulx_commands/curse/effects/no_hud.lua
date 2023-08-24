local EFFECT_NAME = "NoHud"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        hook.Add( "HUDShouldDraw", HOOK_PREFIX .. "NoHudPls", function()
            return false
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "HUDShouldDraw", HOOK_PREFIX .. "NoHudPls" )
    end,

    onTick = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
