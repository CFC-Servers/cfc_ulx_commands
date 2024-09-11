local EFFECT_NAME = "ColorModifyContinuous"
local TRANSITION_DURATION_MIN = 2
local TRANSITION_DURATION_MAX = 5
local CHANGE_COOLDOWN_MIN = 5
local CHANGE_COOLDOWN_MAX = 30
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

        local tab = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 1,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }

        local tabPrev = {}
        local tabTarget = {}
        local transitionDuration = 0
        local transitionStartTime = 0
        local transitionNotDone = true
        local nextChangeTime = 0

        local function startChange()
            transitionDuration = math.Rand( TRANSITION_DURATION_MIN, TRANSITION_DURATION_MAX )
            transitionStartTime = CurTime()
            transitionNotDone = true
            nextChangeTime = transitionStartTime + transitionDuration + math.Rand( CHANGE_COOLDOWN_MIN, CHANGE_COOLDOWN_MAX )

            for k, min in pairs( MIN_VALUES ) do
                tabPrev[k] = tab[k]
                tabTarget[k] = math.Rand( min, MAX_VALUES[k] )
            end
        end

        startChange()

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "RenderScreenspaceEffects", "PP", function()
            local now = CurTime()

            if now >= nextChangeTime then
                startChange()
            elseif transitionNotDone then
                local progress = ( now - transitionStartTime ) / transitionDuration

                if progress >= 1 then
                    transitionNotDone = false

                    for k in pairs( MIN_VALUES ) do
                        tab[k] = tabTarget[k]
                    end
                else
                    for k in pairs( MIN_VALUES ) do
                        tab[k] = Lerp( progress, tabPrev[k], tabTarget[k] )
                    end
                end
            end

            DrawColorModify( tab )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = 1.5,
    excludeFromOnetime = true,
    incompatibileEffects = {
        "MotionSight",
    },
    groups = {
        "VisualOnly",
        "PP",
        "PPColorModify"
    },
    incompatibleGroups = {
        "HaltRenderScene",
        "PPColorModify",
    },
} )
