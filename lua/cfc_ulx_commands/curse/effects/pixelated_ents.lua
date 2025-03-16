local EFFECT_NAME = "PixelatedEnts"
local COMPRESSION_LEVEL_MIN = 2
local COMPRESSION_LEVEL_MAX = 10
local RT_SIZE = 1024
local BAD_CLASSES = {
    ["class C_BaseFlex"] = true,
    ["viewmodel"] = true,
    ["manipulate_bone"] = true,
    ["physgun_beam"] = true,
    ["gmod_hands"] = true,
    ["quad_prop"] = true,
}


local gameMatIgnorez = CFCUlxCurse.IncludeEffectUtil( "common_materials" ).gameMatIgnorez
local pixelRT
local pixelMat

if CLIENT then
    pixelRT = GetRenderTarget( "cfc_ulx_commands_curse_pixelated_ents_rt", RT_SIZE, RT_SIZE )

    pixelMat = CreateMaterial( "cfc_ulx_commands_curse_pixelated_ents", "UnlitGeneric", {
        ["$basetexture"] = pixelRT:GetName(),
        ["$ignorez"] = 1,
    } )
end


local function resetStencil()
    render.SetStencilWriteMask( 0xFF )
    render.SetStencilTestMask( 0xFF )
    render.SetStencilReferenceValue( 0 )
    render.SetStencilCompareFunction( STENCIL_ALWAYS )
    render.SetStencilPassOperation( STENCIL_KEEP )
    render.SetStencilFailOperation( STENCIL_KEEP )
    render.SetStencilZFailOperation( STENCIL_KEEP )
    render.ClearStencil()
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local compressionMult = 1 / math.random( COMPRESSION_LEVEL_MIN, COMPRESSION_LEVEL_MAX )


        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawEffects", "Pixelate", function()
            -- Get a pixelated copy of the 3D scene.
            render.UpdateScreenEffectTexture()

            cam.Start2D()
            render.PushRenderTarget( pixelRT, 0, 0, ScrW(), ScrH() )
                render.Clear( 0, 0, 0, 255, true, true )
                surface.SetMaterial( gameMatIgnorez )
                surface.SetDrawColor( 255, 255, 255, 255 )

                render.PushFilterMin( TEXFILTER.POINT )
                surface.DrawTexturedRectUV( 0, 0, ScrW() * compressionMult, ScrH() * compressionMult, 0, 0, 1, 1 )
                render.PopFilterMin()
            render.PopRenderTarget()
            cam.End2D()
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawHUD", "Pixelate", function()
            -- Make a stencil of all entities.
            resetStencil()

            render.SetStencilEnable( true )
            render.SetStencilReferenceValue( 1 )
            render.SetStencilCompareFunction( STENCIL_ALWAYS )
            render.SetStencilPassOperation( STENCIL_REPLACE )

            cam.Start3D()
                for _, ent in ipairs( ents.GetAll() ) do
                    if IsValid( ent ) and ent.DrawModel and not ent:IsEffectActive( EF_NODRAW ) and not BAD_CLASSES[ent:GetClass()] then
                        ent:DrawModel()
                    end
                end
            cam.End3D()

            -- Draw the pixelated rt to the screen, respecting the stencil.
            render.SetStencilCompareFunction( STENCIL_EQUAL )

            cam.Start2D()
                surface.SetMaterial( pixelMat )
                surface.SetDrawColor( 255, 255, 255, 255 )

                render.PushFilterMag( TEXFILTER.POINT )
                surface.DrawTexturedRectUV( 0, 0, ScrW(), ScrH(), 0, 0, compressionMult, compressionMult )
                render.PopFilterMag()
            cam.End2D()

            render.SetStencilEnable( false )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {
        "Pixelated",
    },
    groups = {
        "VisualOnly",
        "ScreenOverlay",
    },
    incompatibleGroups = {
        "HaltRenderScene",
        "PP",
    },
} )
