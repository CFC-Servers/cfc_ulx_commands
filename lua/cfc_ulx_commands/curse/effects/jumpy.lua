local EFFECT_NAME = "Jumpy"
local INTERVAL = 0.1


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local state = false

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "Boing", INTERVAL, 0, function()
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

        RunConsoleCommand( "-jump" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatabileEffects = {
        "JumpExplode",
        "NoJump",
    },
    groups = {},
    incompatibleGroups = {},
} )
