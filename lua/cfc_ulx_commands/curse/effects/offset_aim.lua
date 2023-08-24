local EFFECT_NAME = "OffsetAim"
local ANGLE_OFFSET_MIN = 2
local ANGLE_OFFSET_MAX = 15
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        -- Randomly select -1 or 1
        local pitchMult = math.random( 0, 1 ) == 0 and -1 or 1
        local yawMult = math.random( 0, 1 ) == 0 and -1 or 1

        local pitchOffset = math.Rand( ANGLE_OFFSET_MIN, ANGLE_OFFSET_MAX ) * pitchMult
        local yawOffset = math.Rand( ANGLE_OFFSET_MIN, ANGLE_OFFSET_MAX ) * yawMult
        local offsetAng = Angle( pitchOffset, yawOffset, 0 )
        local realAng

        hook.Add( "CreateMove", HOOK_PREFIX .. "LBozo", function( cmd )
            local isClient = cmd:CommandNumber() == 0

            if not realAng then
                realAng = cmd:GetViewAngles()
            end

            realAng.y = realAng.y - cmd:GetMouseX() * 0.022
            realAng.x = math.Clamp( realAng.x + cmd:GetMouseY() * 0.022, -89, 89 )
            realAng:Normalize()

            if isClient then
                cmd:SetViewAngles( realAng )
            else
                cmd:SetViewAngles( realAng + offsetAng )
            end
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "CreateMove", HOOK_PREFIX .. "LBozo" )
    end,

    onTick = function()
        -- Do nothing.
    end,

    minDuration = 30,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
