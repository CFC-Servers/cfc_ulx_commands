local EFFECT_NAME = "ColorModify"
local MIN_VALUES = {
    ["$pp_colour_addr"] = -0.1,
    ["$pp_colour_addg"] = -0.1,
    ["$pp_colour_addb"] = -0.1,
    ["$pp_colour_brightness"] = -0.3,
    ["$pp_colour_contrast"] = 0.75,
    ["$pp_colour_colour"] = -3,
    ["$pp_colour_mulr"] = -1,
    ["$pp_colour_mulg"] = -1,
    ["$pp_colour_mulb"] = -1
}
local MAX_VALUES = {
    ["$pp_colour_addr"] = 0.1,
    ["$pp_colour_addg"] = 0.1,
    ["$pp_colour_addb"] = 0.1,
    ["$pp_colour_brightness"] = 0.3,
    ["$pp_colour_contrast"] = 1.25,
    ["$pp_colour_colour"] = 3,
    ["$pp_colour_mulr"] = 1,
    ["$pp_colour_mulg"] = 1,
    ["$pp_colour_mulb"] = 1
}


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local tab = {}

        for k, min in pairs( MIN_VALUES ) do
            tab[k] = math.Rand( min, MAX_VALUES[k] )
        end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "RenderScreenspaceEffects", "PP", function()
            DrawColorModify( tab )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatibileEffects = {},
    groups = {
        "VisualOnly",
        "PP",
        "PPColorModify"
    },
    incompatibleGroups = {
        "PPColorModify",
    },
} )
