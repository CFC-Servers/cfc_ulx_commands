local EFFECT_NAME = "AimSensitivity"
local SENSITIVITY_MULT_MIN = 0.25
local SENSITIVITY_MULT_MAX = 2
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        local sensitivityMult = math.Rand( SENSITIVITY_MULT_MIN, SENSITIVITY_MULT_MAX )
        local realAng

        hook.Add( "CreateMove", HOOK_PREFIX .. "LBozo", function( cmd )
            if not realAng then
                realAng = cmd:GetViewAngles()
            end

            realAng.y = realAng.y - cmd:GetMouseX() * 0.022 * sensitivityMult
            realAng.x = math.Clamp( realAng.x + cmd:GetMouseY() * 0.022 * sensitivityMult, -89, 89 )
            realAng:Normalize()

            cmd:SetViewAngles( realAng )
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "CreateMove", HOOK_PREFIX .. "LBozo" )
    end,

    onTick = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
