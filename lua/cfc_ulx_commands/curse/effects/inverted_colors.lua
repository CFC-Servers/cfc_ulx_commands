local EFFECT_NAME = "InvertedColors"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        hook.Add( "DrawOverlay", HOOK_PREFIX .. "LBozo", function()
            render.OverrideBlend( true, BLEND_ONE, BLEND_ONE, BLENDFUNC_SUBTRACT, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD )

            surface.SetDrawColor( 200, 200, 200, 255 )
            draw.NoTexture()

            surface.DrawRect( 0, 0, ScrW(), ScrH() )

            render.OverrideBlend( false )
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "DrawOverlay", HOOK_PREFIX .. "LBozo" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
