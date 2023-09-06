local EFFECT_NAME = "NoclipSpam"
local TOGGLE_INTERVAL = 0.5
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        timer.Create( HOOK_PREFIX .. "ToggleNoclip", TOGGLE_INTERVAL, 0, function()
            RunConsoleCommand( "noclip" )
        end )
    end,

    onEnd = function()
        if SERVER then return end

        timer.Remove( HOOK_PREFIX .. "ToggleNoclip" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
