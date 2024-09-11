local EFFECT_NAME = "MotionSight"
local DELAY = 0 -- 0 results in a 1-frame delay.


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

local gameMat2
local motionSightRT1
local motionSightRT2
local motionSightMat1
local motionSightMat2


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

        -- Disable halos since they use _rt_fullframefb and cause a feedback loop.
        globals.haloAdd = globals.haloAdd or halo.Add
        halo.Add = function() end

        local nextCaptureTime = 0

        if not motionSightRT1 then
            motionSightRT1 = GetRenderTarget( "cfc_ulx_commands_curse_motion_sight1", ScrW(), ScrH() )
            motionSightRT2 = GetRenderTarget( "cfc_ulx_commands_curse_motion_sight2", ScrW(), ScrH() )

            motionSightMat1 = CreateMaterial( "cfc_ulx_commands_curse_motion_sight1", "UnlitGeneric", {
                ["$basetexture"] = motionSightRT1:GetName(),
                ["$ignorez"] = 1,
            } )

            motionSightMat2 = CreateMaterial( "cfc_ulx_commands_curse_motion_sight2", "UnlitGeneric", {
                ["$basetexture"] = motionSightRT2:GetName(),
                ["$ignorez"] = 1,
            } )
        end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawViewModels", "SubtractiveOverlay", function()
            cam.Start2D()
                surface.SetDrawColor( 255, 255, 255, 255 )

                -- Draw the current screen to the second RT so that it receives the same aliasing/bluring as the first RT.
                -- This fixes single-pixel differences that would show up if we just used RT1 and gameMat2.
                render.UpdateScreenEffectTexture()

                render.PushRenderTarget( motionSightRT2 )
                    surface.SetMaterial( gameMat2 )
                    surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
                render.PopRenderTarget()


                -- Draw the first RT, which is a capture of the screen delayed by DELAY seconds.
                surface.SetMaterial( motionSightMat1 )
                surface.DrawTexturedRectUV( 0, 0, ScrW(), ScrH(), 0, 0, 1, 1 )

                -- Subtractively draw the second RT. Everything will be black where there has been no change between the two frames.
                render.OverrideBlend( true, BLEND_ONE, BLEND_ONE, BLENDFUNC_SUBTRACT, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD )
                surface.SetMaterial( motionSightMat2 )
                surface.DrawTexturedRectUV( 0, 0, ScrW(), ScrH(), 0, 0, 1, 1 )
                render.OverrideBlend( false )
            cam.End2D()
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "RenderScene", "CaptureTheScreen", function()
            local now = CurTime()
            if now < nextCaptureTime then return end

            nextCaptureTime = now + DELAY

            -- Capture the current screen to the first RT.
            cam.Start2D()
            render.PushRenderTarget( motionSightRT1 )
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( gameMat2 )
                surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
                render.OverrideBlend( false )
            render.PopRenderTarget()
            cam.End2D()
        end )
    end,

    onEnd = function()
        if SERVER then return end

        halo.Add = globals.haloAdd
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatibileEffects = {
        "ColorModify",
        "ColorModifyContinuous",
        "DrunkBlur",
        "FilmDevelopment",
        "MotionBlur",
        "ScreenMirror",
        "ScreenScroll",
        "ScreenShuffle",
    },
    groups = {
        "VisualOnly",
        "ScreenOverlay",
        "Wrap:Halo.Add"
    },
    incompatibleGroups = {
        "ScreenOverlay",
        "Wrap:Halo.Add",
        "HaltRenderScene",
    },
} )
