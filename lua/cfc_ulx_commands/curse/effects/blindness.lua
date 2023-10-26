local EFFECT_NAME = "Blindness"
local FOG_START = 800
local FOG_END = 700
local FOG_START_MULT = -100
local FOG_DENSITY = 1.999


local function doFog( scale )
    scale = scale or 1

    render.FogMode( MATERIAL_FOG_LINEAR )
    render.FogColor( 0, 0, 0 )
    render.FogStart( FOG_START * FOG_START_MULT * scale )
    render.FogEnd( FOG_END * scale )
    render.FogMaxDensity( FOG_DENSITY )

    return true
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "SetupWorldFog", "DoFog", doFog )
        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "SetupSkyboxFog", "DoFog", doFog )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PreDrawSkyBox", "RemoveSkybox", function()
            return true
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatabileEffects = {},
} )
