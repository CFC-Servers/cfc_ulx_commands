local EFFECT_NAME = "InvertedAim"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local realAng

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            if not realAng then
                realAng = cmd:GetViewAngles()
            end

            cmd:SetMouseX( -cmd:GetMouseX() )
            cmd:SetMouseY( -cmd:GetMouseY() )

            realAng.y = realAng.y - cmd:GetMouseX() * 0.022
            realAng.x = math.Clamp( realAng.x + cmd:GetMouseY() * 0.022, -89, 89 )
            realAng:Normalize()

            cmd:SetViewAngles( realAng )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {
        "RotatedAim",
    },
    groups = {
        "ViewAngles",
    },
    incompatibleGroups = {
        "ViewAngles",
    },
} )
