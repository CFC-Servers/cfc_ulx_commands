local EFFECT_NAME = "Smeary"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        RunConsoleCommand( "pp_fb", "100000000000000000000000000000000000000" )
        RunConsoleCommand( "pp_fb_shutter", "-0.0001" )
        RunConsoleCommand( "pp_fb_frames", "32" )
    end,

    onEnd = function()
        if SERVER then return end

        RunConsoleCommand( "pp_fb", "0" )
        RunConsoleCommand( "pp_fb_shutter", "0.5" )
        RunConsoleCommand( "pp_fb_frames", "16" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
