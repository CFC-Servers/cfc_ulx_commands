local EFFECT_NAME = "TopDown"
local ZOOM_MIN = 50
local ZOOM_MAX = 5000
local ZOOM_DEFAULT = 2500
local ZOOM_SPEED = 3000 -- Units per second

--[[
    - Puts your camera into isometric mode.
    - Arrow keys to zoom in/out.
--]]


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then
            cursedPly:CrosshairDisable()

            local function enforceDisableCrosshair( ply )
                if ply ~= cursedPly then return end

                ply:CrosshairDisable()

                CFCUlxCurse.CreateEffectTimer( ply, EFFECT_NAME, "DisableCrosshair", 0, 1, function()
                    ply:CrosshairDisable()
                end )
            end

            CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerSpawn", "DisableCrosshair", enforceDisableCrosshair )
            CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerLeaveVehicle", "DisableCrosshair", enforceDisableCrosshair )

            return
        end


        local orthoAng = Angle( 90, 0, 0 )
        local orthoAngDir = Vector( 0, 0, -1 )
        local orthoDist = ZOOM_DEFAULT
        local orthoDistDir = nil

        local function determineDistDir()
            orthoDistDir = ( input.IsButtonDown( KEY_UP ) and -1 or 0 ) + ( input.IsButtonDown( KEY_DOWN ) and 1 or 0 )
        end

        determineDistDir()

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CalcView", "CameraGoBrr", function( _, eyePos )
            local scrWH = ScrW() / 2
            local scrHH = ScrH() / 2

            local zoomFrac = math.Remap( orthoDist, ZOOM_MIN, ZOOM_MAX, 0.25, 1 )

            return {
                origin = eyePos - orthoAngDir * orthoDist,
                angles = orthoAng,
                drawviewer = true,
                drawviewmodel = false,

                ortho = {
                    left = -scrWH * zoomFrac,
                    top = -scrHH * zoomFrac,
                    right = scrWH * zoomFrac,
                    bottom = scrHH * zoomFrac,
                },
            }
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "Think", "Zoom", function()
            if orthoDistDir ~= 0 then
                orthoDist = math.Clamp( orthoDist + orthoDistDir * ZOOM_SPEED * FrameTime(), ZOOM_MIN, ZOOM_MAX )
            end
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerButtonDown", "CameraControls", function( _, key )
            if not IsFirstTimePredicted() then return end

            if key == KEY_UP or key == KEY_DOWN then
                determineDistDir()
            end
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerButtonUp", "CameraControls", function( _, key )
            if not IsFirstTimePredicted() then return end

            if key == KEY_UP or key == KEY_DOWN then
                determineDistDir()
            end
        end )
    end,

    onEnd = function( cursedPly )
        if SERVER then
            cursedPly:CrosshairEnable()
        end
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {
        "Isometric",
        "ResidentEvil",
    },
    groups = {
        "CalcView",
    },
    incompatibleGroups = {
        "CalcView",
    },
} )
