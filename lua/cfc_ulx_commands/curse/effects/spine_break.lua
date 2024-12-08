local EFFECT_NAME = "SpineBreak"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local realAng
        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            if not realAng then
                realAng = cmd:GetViewAngles()
            end

            realAng.y = realAng.y - cmd:GetMouseX() * 0.022
            realAng.x = realAng.x + cmd:GetMouseY() * 0.022
            realAng:Normalize()

            cmd:SetViewAngles( realAng )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 30,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatibileEffects = {},
    groups = {
        "ViewAngles",
    },
    incompatibleGroups = {
        "ViewAngles",
    },
} )
