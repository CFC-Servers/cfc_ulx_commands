local EFFECT_NAME = "ScreenMirror"


local gameMat

if CLIENT then
    gameMat = CreateMaterial( "cfc_ulx_commands_curse_game_rt", "UnlitGeneric", {
        ["$basetexture"] = "_rt_PowerOfTwoFB"
    } )
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "HUDPaintBackground", "LBozo", function()
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( gameMat )

            surface.DrawTexturedRectUV( 0, 0, ScrW() / 2, ScrH(), 1, 0, 0.5, 1 )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatabileEffects = {
        "ScreenScroll",
    },
} )
