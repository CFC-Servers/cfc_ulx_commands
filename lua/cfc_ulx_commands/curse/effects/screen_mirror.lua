local EFFECT_NAME = "ScreenMirror"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


local gameMat

if CLIENT then
    gameMat = CreateMaterial( "cfc_ulx_commands_curse_game_rt", "UnlitGeneric", {
        ["$basetexture"] = "_rt_PowerOfTwoFB"
    } )
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        hook.Add( "HUDPaintBackground", HOOK_PREFIX .. "LBozo", function()
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( gameMat )

            surface.DrawTexturedRectUV( 0, 0, ScrW() / 2, ScrH(), 1, 0, 0.5, 1 )
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "HUDPaintBackground", HOOK_PREFIX .. "LBozo" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
