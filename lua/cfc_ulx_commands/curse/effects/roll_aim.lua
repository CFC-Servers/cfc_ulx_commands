local EFFECT_NAME = "RollAim"
local ANGLE_OFFSET_MIN = 4
local ANGLE_OFFSET_MAX = 15


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        -- Randomly select -1 or 1
        local rollMult = math.random( 0, 1 ) == 0 and -1 or 1

        local rollOffset = math.Rand( ANGLE_OFFSET_MIN, ANGLE_OFFSET_MAX ) * rollMult
        local offsetAng = Angle( 0, 0, rollOffset )
        local realAng

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            local isClient = cmd:CommandNumber() == 0

            if not realAng then
                realAng = cmd:GetViewAngles()
            end

            realAng.y = realAng.y - cmd:GetMouseX() * 0.022
            realAng.x = math.Clamp( realAng.x + cmd:GetMouseY() * 0.022, -89, 89 )
            realAng:Normalize()

            if isClient then
                cmd:SetViewAngles( realAng + offsetAng )
            else
                cmd:SetViewAngles( realAng )
            end
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
        "RollAimIncremental",
    },
    groups = {
        "ViewAngles",
    },
    incompatibleGroups = {
        "ViewAngles",
    },
} )
