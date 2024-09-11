local EFFECT_NAME = "FilmDevelopment"
local ADD_ALPHA = 0.0105
local DRAW_ALPHA = 1 - ADD_ALPHA
local DELAY = 0.1
local PASSES = 10


local DELAY_PER_PASS = DELAY / PASSES


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local showClearScreenHint = true
        local clearingScreen = false


        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "RenderScreenspaceEffects", "Blur", function()
            if clearingScreen then
                surface.SetDrawColor( 0, 0, 0, 255 )
                surface.DrawRect( 0, 0, ScrW(), ScrH() )

                return
            end

            for i = 1, PASSES do
                DrawMotionBlur( ADD_ALPHA, DRAW_ALPHA, DELAY_PER_PASS * i )
            end
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "HUDPaint", "DrawHints", function()
            draw.SimpleText( "Hold E for a second or two", "DermaLarge", ScrW() / 2, ScrH() / 2 + 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText( "to clear the screen", "DermaLarge", ScrW() / 2, ScrH() / 2 + 50 + 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "KeyPress", "Input", function( _, key )
            if not IsFirstTimePredicted() then return end

            if key == IN_USE then
                if showClearScreenHint then
                    CFCUlxCurse.RemoveEffectHook( cursedPly, EFFECT_NAME, "HUDPaint", "DrawHints" )
                    showClearScreenHint = false
                end

                clearingScreen = true
            end
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "KeyRelease", "Input", function( _, key )
            if not IsFirstTimePredicted() then return end

            if key == IN_USE then
                clearingScreen = false
            end
        end )
    end,

    onEnd = function()
        if SERVER then return end
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = 1,
    excludeFromOnetime = true,
    incompatibileEffects = {},
    groups = {
        "VisualOnly",
        "MotionBlur",
    },
    incompatibleGroups = {
        "HaltRenderScene",
        "MotionBlur",
    },
} )
