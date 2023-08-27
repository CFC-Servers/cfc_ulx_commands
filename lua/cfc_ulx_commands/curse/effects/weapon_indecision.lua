local EFFECT_NAME = "WeaponIndecision"
local INTERVAL = 0.1
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        timer.Create( HOOK_PREFIX .. "SelectWeapon_" .. cursedPly:SteamID64(), INTERVAL, 0, function()
            if not IsValid( cursedPly ) then return end

            if CLIENT then
                surface.PlaySound( "common/wpn_hudoff.wav" )

                return
            end

            local weps = cursedPly:GetWeapons()
            local wepCount = #weps
            if wepCount == 0 then return end

            local wep = weps[math.random( wepCount )]

            cursedPly:SelectWeapon( wep:GetClass() )
        end )
    end,

    onEnd = function( cursedPly )
        timer.Remove( HOOK_PREFIX .. "SelectWeapon_" .. cursedPly:SteamID64() )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
