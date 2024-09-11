local EFFECT_NAME = "MirrorWorld"
-- Horizontally flips 3D rendering and the player's controls.
-- Adapted from code provided by TankNut.


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

local vectorMeta = FindMetaTable( "Vector" )
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

        globals.vectorToScreen = globals.vectorToScreen or vectorMeta.ToScreen
        local oldToScreen = globals.vectorToScreen

        function vectorMeta:ToScreen()
            local scrPos = oldToScreen( self )
            if not scrPos.visible then return scrPos end

            scrPos.x = ScrW() - scrPos.x

            return scrPos
        end

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
        if SERVER then return end

        vectorMeta.ToScreen = globals.vectorToScreen
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {},
    groups = {
        "ScreenOverlay",
        "Input",
        "ViewAngles",
        "AD",
    },
    incompatibleGroups = {
        "HaltRenderScene",
        "ViewAngles",
        "AD",
    },
} )
