local EFFECT_NAME = "ChromaticAberration"
local SLICES_MIN = 5
local SLICES_MAX = 10
local SPREAD_SCALE_MIN = 0.002
local SPREAD_SCALE_MAX = 0.007


local CHANNELS = {
    Color( 255, 0, 0, 255 ),
    Color( 0, 255, 0, 255 ),
    Color( 0, 0, 255, 255 ),
}

local gameMatVertexColor = CFCUlxCurse.IncludeEffectUtil( "common_materials" ).gameMatVertexColor


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local scrW = ScrW()
        local scrH = ScrH()

        local slices = math.random( SLICES_MIN, SLICES_MAX )
        local spreadScale = math.Rand( SPREAD_SCALE_MIN, SPREAD_SCALE_MAX )


        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawHUD", "LBozo", function()
            render.UpdateScreenEffectTexture()

            cam.Start2D()
                surface.SetDrawColor( 0, 0, 0, 255 )
                surface.DrawRect( 0, 0, scrW, scrH )

                surface.SetMaterial( gameMatVertexColor )
                render.OverrideBlend( true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ZERO, BLENDFUNC_ADD )

                for _, channel in ipairs( CHANNELS ) do
                    surface.SetDrawColor( channel )

                    for i = 0, slices - 1 do
                        local spreadX = math.Rand( -spreadScale, spreadScale )

                        surface.DrawTexturedRectUV( scrW * spreadX, scrH * i / slices, scrW, scrH / slices, 0, i / slices, 1, ( i + 1 ) / slices )
                    end
                end

                render.OverrideBlend( false )
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
