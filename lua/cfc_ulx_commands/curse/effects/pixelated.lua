local EFFECT_NAME = "Pixelated"
local COMPRESSION_LEVEL_MIN = 2
local COMPRESSION_LEVEL_MAX = 10
local RT_SIZE = 1024


local gameMat2
local pixelRT
local pixelMat

if CLIENT then
    gameMat2 = CreateMaterial( "cfc_ulx_commands_curse_game_rt_2", "UnlitGeneric", {
        ["$basetexture"] = "_rt_fullframefb",
        ["$ignorez"] = 1,
    } )

    pixelRT = GetRenderTarget( "cfc_ulx_commands_curse_pixelated_rt", RT_SIZE, RT_SIZE )

    pixelMat = CreateMaterial( "cfc_ulx_commands_curse_pixelated", "UnlitGeneric", {
        ["$basetexture"] = pixelRT:GetName(),
        ["$ignorez"] = 1,
    } )
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local compressionMult = 1 / math.random( COMPRESSION_LEVEL_MIN, COMPRESSION_LEVEL_MAX )


        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawEffects", "Pixelate", function()
            render.UpdateScreenEffectTexture()

            cam.Start2D()
            render.SetRenderTarget( pixelRT )
                render.Clear( 0, 0, 0, 255, true, true )
                surface.SetMaterial( gameMat2 )
                surface.SetDrawColor( 255, 255, 255, 255 )

                render.PushFilterMin( TEXFILTER.POINT )
                surface.DrawTexturedRectUV( 0, 0, ScrW() * compressionMult, ScrH() * compressionMult, 0, 0, 1, 1 )
                render.PopFilterMin()
            render.SetRenderTarget()
            cam.End2D()
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawHUD", "Pixelate", function()
            cam.Start2D()
                surface.SetMaterial( pixelMat )
                surface.SetDrawColor( 255, 255, 255, 255 )

                render.PushFilterMag( TEXFILTER.POINT )
                surface.DrawTexturedRectUV( 0, 0, ScrW(), ScrH(), 0, 0, compressionMult, compressionMult )
                render.PopFilterMag()
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
        "ScreenOverlay",
    },
    incompatibleGroups = {
        "ScreenOverlay",
        "PP",
    },
} )
