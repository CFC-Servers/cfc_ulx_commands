local EFFECT_NAME = "ScreenMirror"


local gameMatIgnorez = CFCUlxCurse.IncludeEffectUtil( "common_materials" ).gameMatIgnorez


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawHUD", "LBozo", function()
            render.UpdateScreenEffectTexture()

            cam.Start2D()
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( gameMatIgnorez )

                surface.DrawTexturedRectUV( 0, 0, ScrW() / 2, ScrH(), 1, 0, 0.5, 1 )
            cam.End2D()
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {
        "MotionSight",
    },
    groups = {
        "VisualOnly",
        "ScreenOverlay",
    },
    incompatibleGroups = {
        "HaltRenderScene",
    },
} )
