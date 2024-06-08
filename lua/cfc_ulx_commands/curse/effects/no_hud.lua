local EFFECT_NAME = "NoHud"
local ALLOWED_HUD_ELEMENTS = {
    CHudMenu = true,
    CHudWeaponSelection = true,
    CHudChat = true,
}


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "HUDShouldDraw", "NoHudPls", function( elementName )
            if ALLOWED_HUD_ELEMENTS[elementName] then return end

            return false
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
        "HealthObfuscate",
    },
    groups = {},
    incompatibleGroups = {},
} )
