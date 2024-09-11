local EFFECT_NAME = "DrunkBlur"
local ADD_ALPHA = 0.4
local DRAW_ALPHA = 0.8
local DELAY = 1
local PASSES = 10


local DELAY_PER_PASS = DELAY / PASSES


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "RenderScreenspaceEffects", "Blur", function()
            for i = 1, PASSES do
                DrawMotionBlur( ADD_ALPHA, DRAW_ALPHA, DELAY_PER_PASS * i )
            end
        end )
    end,

    onEnd = function()
        if SERVER then return end
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatibileEffects = {
        "FilmDevelopment",
        "MotionBlur",
        "MotionSight",
        "Pixelated",
    },
    groups = {
        "VisualOnly",
    },
    incompatibleGroups = {
        "HaltRenderScene",
    },
} )
