local EFFECT_NAME = "ScreenScroll"
local SPEED_MIN = 0.03
local SPEED_MAX = 0.06


local gameMatIgnorez = CFCUlxCurse.IncludeEffectUtil( "common_materials" ).gameMatIgnorez



CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local offset = 0
        local mode = math.random( 1, 3 )
        local speed = math.Rand( SPEED_MIN, SPEED_MAX )
        speed = speed * ( math.random( 0, 1 ) == 0 and -1 or 1 )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawHUD", "LBozo", function()
            render.UpdateScreenEffectTexture()

            cam.Start2D()
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( gameMatIgnorez )

                offset = ( offset + speed * FrameTime() ) % 1

                local w = ScrW()
                local h = ScrH()

                if mode == 1 then -- Horizontal
                    surface.DrawTexturedRect( w * ( 0 + offset ), 0, w, h )
                    surface.DrawTexturedRect( w * ( -1 + offset ), 0, w, h )
                elseif mode == 2 then -- Vertical
                    surface.DrawTexturedRect( 0, h * ( 0 + offset ), w, h )
                    surface.DrawTexturedRect( 0, h * ( -1 + offset ), w, h )
                else -- Diagonal
                    surface.DrawTexturedRect( w * ( 0 + offset ), h * ( 0 + offset ), w, h )
                    surface.DrawTexturedRect( w * ( -1 + offset ), h * ( 0 + offset ), w, h )
                    surface.DrawTexturedRect( w * ( -1 + offset ), h * ( -1 + offset ), w, h )
                    surface.DrawTexturedRect( w * ( 0 + offset ), h * ( -1 + offset ), w, h )
                end
            cam.End2D()
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 10,
    maxDuration = 20,
    onetimeDurationMult = 1.5,
    excludeFromOnetime = true,
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
