local EFFECT_NAME = "Jumpy"
local INTERVAL = 0.1
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        local state = false

        timer.Create( HOOK_PREFIX .. "Boing", INTERVAL, 0, function()
            state = not state

            if state then
                RunConsoleCommand( "+jump" )
            else
                RunConsoleCommand( "-jump" )
            end
        end )
    end,

    onEnd = function()
        if SERVER then return end

        timer.Remove( HOOK_PREFIX .. "Boing" )
        RunConsoleCommand( "-jump" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
