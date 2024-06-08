local EFFECT_NAME = "WorldFlip"
-- Horizontally flips 3D rendering and the player's controls.
-- Adapted from code provided by TankNut.


local gameMat2


if CLIENT then
    gameMat2 = CreateMaterial( "cfc_ulx_commands_curse_game_rt_2", "UnlitGeneric", {
        ["$basetexture"] = "_rt_fullframefb"
    } )
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawViewModels", "FlipTheScreen", function()
            cam.Start2D()
                render.UpdateScreenEffectTexture()

                surface.SetMaterial( gameMat2 )
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.DrawTexturedRectUV( 0, 0, ScrW(), ScrH(), 1, 0, 0, 1 )
            cam.End2D()
        end )

        local oldYaw

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            local viewAng = cmd:GetViewAngles()

            oldYaw = oldYaw or viewAng.y

            local newYaw = viewAng.y
            local diff = math.NormalizeAngle( newYaw - oldYaw )

            oldYaw = newYaw - diff * 2
            viewAng.y = oldYaw

            cmd:SetViewAngles( viewAng )
            cmd:SetSideMove( -cmd:GetSideMove() )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatabileEffects = {
        "ScreenMirror",
        "ScreenScroll",
    },
    groups = {
        "Input",
        "ViewAngles",
        "AD",
    },
    incompatibleGroups = {
        "ViewAngles",
        "AD",
    },
} )
