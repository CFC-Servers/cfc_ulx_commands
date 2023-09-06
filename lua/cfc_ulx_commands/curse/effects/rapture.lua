local EFFECT_NAME = "Rapture"
local SPEED_MIN = 10
local SPEED_MAX = 75
local INTERVAL_MIN = 0.05
local INTERVAL_MAX = 2
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        local vel = Vector( 0, 0, 10 )
        local timerNameEff = HOOK_PREFIX .. "ChangeVelocity" .. "_" .. cursedPly:SteamID64()

        CFCUlxCurse.AddEffectHook( cursedPly, "Think", HOOK_PREFIX .. "GetYoinked", function()
            if not IsValid( cursedPly ) then return end

            cursedPly:SetVelocity( vel )
        end )

        CFCUlxCurse.CreateEffectTimer( cursedPly, HOOK_PREFIX .. "ChangeVelocity", INTERVAL_MIN, 0, function()
            vel = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * math.Rand( SPEED_MIN, SPEED_MAX )
            timer.Adjust( timerNameEff, math.Rand( INTERVAL_MIN, INTERVAL_MAX ) )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
