local EFFECT_NAME = "Sunbeams"
local SUN_DARKEN = 0.8
local SUN_MULT = 0.5
local SUN_SIZE = 1


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end


        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawViewModels", "AverageDayInNewMexico", function()
            cam.Start2D()
                DrawSunbeams( SUN_DARKEN, SUN_MULT, SUN_SIZE, 0.5, 0.5 )
            cam.End2D()
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {},
    groups = {
        "VisualOnly",
    },
    incompatibleGroups = {
        "HaltRenderScene",
    },
} )
