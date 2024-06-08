local EFFECT_NAME = "Swagger"
local SWAGGER_INTERVAL = 0.1
local SWAGGER_CHANGE_CHANCE = 0.3


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local swaggerDir = 0

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            cmd:SetSideMove( 10000 * swaggerDir )
        end )

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "SwaggerChange", SWAGGER_INTERVAL, 0, function()
            if SWAGGER_CHANGE_CHANCE ~= 1 and math.Rand( 0, 1 ) > SWAGGER_CHANGE_CHANCE then return end

            swaggerDir = math.random( -1, 1 )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatabileEffects = {
        "RotatedControls",
        "ReverseControls",
    },
    groups = {
        "Input",
        "AD",
    },
    incompatibleGroups = {
        "AD",
    },
} )
