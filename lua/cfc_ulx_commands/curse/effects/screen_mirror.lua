local EFFECT_NAME = "ScreenMirror"


local gameMat2

if CLIENT then
    gameMat2 = CreateMaterial( "cfc_ulx_commands_curse_game_rt_2", "UnlitGeneric", {
        ["$basetexture"] = "_rt_fullframefb",
        ["$ignorez"] = 1,
    } )
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawHUD", "LBozo", function()
            render.UpdateScreenEffectTexture()

            cam.Start2D()
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( gameMat2 )

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
