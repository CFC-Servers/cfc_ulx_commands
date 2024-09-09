local EFFECT_NAME = "ScreenShuffle"
local GRID_SIZE_MIN = 2
local GRID_SIZE_MAX = 5
local SHUFFLE_INTERVAL_MIN = 4
local SHUFFLE_INTERVAL_MAX = 15


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

        local scrW = ScrW()
        local scrH = ScrH()
        local gridSize = math.random( GRID_SIZE_MIN, GRID_SIZE_MAX )
        local shuffleInterval = math.Rand( SHUFFLE_INTERVAL_MIN, SHUFFLE_INTERVAL_MAX )

        local xStep = scrW / gridSize
        local yStep = scrH / gridSize
        local uvStep = 1 / gridSize
        local gridXY = {}
        local gridUV = {}

        for x = 1, gridSize do
            local xsXY = {}
            local xsUV = {}
            gridXY[x] = xsXY
            gridUV[x] = xsUV

            for y = 1, gridSize do
                local u1 = x * uvStep
                local v1 = y * uvStep

                xsXY[y] = {
                    x = ( x - 1 ) * xStep,
                    y = ( y - 1 ) * yStep,
                }

                xsUV[y] = {
                    u0 = u1 - uvStep,
                    v0 = v1 - uvStep,
                    v1 = v1,
                    u1 = u1,
                }
            end
        end


        local function shuffleGrid()
            for x1 = 1, gridSize do
                for y1 = 1, gridSize do
                    local x2 = math.random( 1, gridSize )
                    local y2 = math.random( 1, gridSize )

                    local temp = gridUV[x1][y1]
                    gridUV[x1][y1] = gridUV[x2][y2]
                    gridUV[x2][y2] = temp
                end
            end
        end


        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "Shuffle", shuffleInterval, 0, shuffleGrid )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawHUD", "Shuffle", function()
            render.UpdateScreenEffectTexture()

            cam.Start2D()
                surface.SetMaterial( gameMat2 )
                surface.SetDrawColor( 255, 255, 255, 255 )

                for x = 1, gridSize do
                    local xsXY = gridXY[x]
                    local xsUV = gridUV[x]

                    for y = 1, gridSize do
                        local xy = xsXY[y]
                        local uv = xsUV[y]

                        surface.DrawTexturedRectUV( xy.x, xy.y, xStep, yStep, uv.u0, uv.v0, uv.u1, uv.v1 )
                    end
                end
            cam.End2D()
        end )


        shuffleGrid()
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {
        -- Compatible with *some* ScreenOverlay effects, but not all.
        "Lidar",
        "MotionSight",
        "Pixelated",
        --"PixelatedEnts", -- Scuffed as hell, but hilarious.
        "ScreenScroll",
    },
    groups = {
        "VisualOnly",
    },
    incompatibleGroups = {},
} )
