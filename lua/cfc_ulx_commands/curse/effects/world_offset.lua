local EFFECT_NAME = "WorldOffset"
local OFFSET_MIN = Vector( -200, -200, 0 )
local OFFSET_MAX = Vector( 200, 200, 0 )
-- Offsets rendering of the world entity. Does not affect the rendering of other entities.


local pushed = false


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local worldMatrix = Matrix()
        worldMatrix:Translate( Vector(
            math.Rand( OFFSET_MIN.x, OFFSET_MAX.x ),
            math.Rand( OFFSET_MIN.y, OFFSET_MAX.y ),
            math.Rand( OFFSET_MIN.z, OFFSET_MAX.z )
        ) )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "NeedsDepthPass", "OffsetTheWorld", function()
            if pushed then return end

            cam.PushModelMatrix( worldMatrix, true )
            pushed = true
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawOpaqueRenderables", "StopOffset", function( depth, skybox, skybox3d )
            if depth or skybox or skybox3d then return end -- When these are all false, this is the soonest hook after the world renders.

            if pushed then
                cam.PopModelMatrix()
                pushed = false
            end
        end )
    end,

    onEnd = function()
        if SERVER then return end

        if pushed then
            cam.PopModelMatrix()
            pushed = false
        end
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {},
    groups = {},
    incompatibleGroups = {},
} )
