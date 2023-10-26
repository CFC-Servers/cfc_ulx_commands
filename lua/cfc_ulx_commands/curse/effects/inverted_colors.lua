local EFFECT_NAME = "InvertedColors"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "DrawOverlay", "LBozo", function()
            render.OverrideBlend( true, BLEND_ONE, BLEND_ONE, BLENDFUNC_SUBTRACT, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD )

            surface.SetDrawColor( 200, 200, 200, 255 )
            draw.NoTexture()

            surface.DrawRect( 0, 0, ScrW(), ScrH() )

            render.OverrideBlend( false )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
