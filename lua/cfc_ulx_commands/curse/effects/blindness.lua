

local EFFECT_NAME = "Blindness"
local FOG_START = 800
local FOG_END = 700
local FOG_START_MULT = -100
local FOG_DENSITY = 1.999
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


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

    onStart = function()
        if SERVER then return end

        hook.Add( "SetupWorldFog", HOOK_PREFIX .. "DoFog", doFog )
        hook.Add( "SetupSkyboxFog", HOOK_PREFIX .. "DoFog", doFog )

        hook.Add( "PreDrawSkyBox", HOOK_PREFIX .. "RemoveSkybox", function()
            return true
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "SetupWorldFog", HOOK_PREFIX .. "DoFog" )
        hook.Remove( "SetupSkyboxFog", HOOK_PREFIX .. "DoFog" )
        hook.Remove( "PreDrawSkyBox", HOOK_PREFIX .. "RemoveSkybox" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
