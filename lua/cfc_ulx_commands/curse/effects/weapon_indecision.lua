local EFFECT_NAME = "WeaponIndecision"
local INTERVAL = 0.1


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then
            CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "SelectWeapon", INTERVAL, 0, function()
                surface.PlaySound( "common/wpn_hudoff.wav" )
            end )

            return
        end

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "SelectWeapon", INTERVAL, 0, function()
            local weps = cursedPly:GetWeapons()
            local wepCount = #weps
            if wepCount == 0 then return end

            local wep = weps[math.random( wepCount )]

            cursedPly:SelectWeapon( wep:GetClass() )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatabileEffects = {
        "Butterfingers",
    },
    groups = {
        "SelectWeapon",
    },
    incompatibleGroups = {
        "SelectWeapon",
    },
} )
