local EFFECT_NAME = "OffsetAim"
local ANGLE_OFFSET_MIN = 2
local ANGLE_OFFSET_MAX = 15
local MULTI_CHANGE_CHANCE = 0.5 -- Chance to start doing multi-changes.
local MULTI_CHANGE_AMOUNT_MIN = 1 -- Minimum amount of additional times to change the offset, if the initial chance triggers.
local MULTI_CHANGE_AMOUNT_MAX = 3 -- Same as above, but maximum.
local MULTI_CHANGE_TIMING_SPREAD = 0.15 -- Timings for each multi-change will be offset by +/- this percentage of the multi-change gap. This value should be between 0 and 0.5.
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( _, curseDuration )
        if SERVER then return end

        local offsetAng
        local realAng

        local function randomizeOffset()
            -- Randomly select -1 or 1
            local pitchMult = math.random( 1, 2 ) == 1 and -1 or 1
            local yawMult = math.random( 1, 2 ) == 1 and -1 or 1

            local pitchOffset = math.Rand( ANGLE_OFFSET_MIN, ANGLE_OFFSET_MAX ) * pitchMult
            local yawOffset = math.Rand( ANGLE_OFFSET_MIN, ANGLE_OFFSET_MAX ) * yawMult

            offsetAng = Angle( pitchOffset, yawOffset, 0 )
        end

        randomizeOffset()

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

        if math.Rand( 0, 1 ) > MULTI_CHANGE_CHANCE then return end

        local mcAmount = math.random( MULTI_CHANGE_AMOUNT_MIN, MULTI_CHANGE_AMOUNT_MAX )
        local mcGap = curseDuration / ( mcAmount + 1 )

        for i = 1, mcAmount do
            local delaySpread = mcGap * MULTI_CHANGE_TIMING_SPREAD * math.Rand( -1, 1 )
            local delay = mcGap * i + delaySpread

            timer.Create( HOOK_PREFIX .. "MultiChange_" .. i, delay, 1, randomizeOffset )
        end
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "CreateMove", HOOK_PREFIX .. "LBozo" )

        for i = 1, MULTI_CHANGE_AMOUNT_MAX do
            timer.Remove( HOOK_PREFIX .. "MultiChange_" .. i )
        end
    end,

    minDuration = 30,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
