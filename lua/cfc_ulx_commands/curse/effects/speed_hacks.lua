local EFFECT_NAME = "SpeedHacks"
local SPEED_UPDATE_INTERVAL = 0.05 -- Set to 0 to run on Think hook.
local SPEED_OSCILLATION_RATE = 2
local SPEED_MULT_MIN = 0.3
local SPEED_MULT_MAX = 1.5
local SPEED_MULT_SUPER = 20
local SPEED_SUPER_CHANCE = 0.005
local SPEED_SUPER_DURATION = 0.4
local SPEED_SUPER_COOLDOWN = 5
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


local SPEED_MULT_MIN_MAX_GAP = SPEED_MULT_MAX - SPEED_MULT_MIN

-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

globals.BASE_SPEEDS_PER_PLAYER = globals.BASE_SPEEDS_PER_PLAYER or {}
local baseSpeedsPerPlayer = globals.BASE_SPEEDS_PER_PLAYER


local function setSpeedMult( ply, mult, slowWalkBase, walkBase, runBase, ladderBase )
    if not slowWalkBase then
        local baseSpeeds = baseSpeedsPerPlayer[ply] or {}

        slowWalkBase = baseSpeeds.slowWalkBase or 100
        walkBase = baseSpeeds.walkBase or 200
        runBase = baseSpeeds.runBase or 400
        ladderBase = baseSpeeds.ladderBase or 200
    end

    ply:SetSlowWalkSpeed( slowWalkBase * mult )
    ply:SetWalkSpeed( walkBase * mult )
    ply:SetRunSpeed( runBase * mult )
    ply:SetLadderClimbSpeed( ladderBase * mult )
    ply:SetCrouchedWalkSpeed( mult )
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        local hasSuperSpeed = false
        local superSpeedOnCooldown = false
        local superSpeedEndTime = 0
        local superSpeedCooldownEndTime = 0

        local slowWalkBase = cursedPly:GetSlowWalkSpeed()
        local walkBase = cursedPly:GetWalkSpeed()
        local runBase = cursedPly:GetRunSpeed()
        local ladderBase = cursedPly:GetLadderClimbSpeed()

        baseSpeedsPerPlayer[cursedPly] = {
            slowWalkBase = slowWalkBase,
            walkBase = walkBase,
            runBase = runBase,
            ladderBase = ladderBase,
        }

        local function _setSpeedMult( mult )
            setSpeedMult( cursedPly, mult, slowWalkBase, walkBase, runBase, ladderBase )
        end

        local function updateSpeed()
            local now = CurTime()

            if hasSuperSpeed then
                if now < superSpeedEndTime then return end

                hasSuperSpeed = false
                superSpeedOnCooldown = true
                superSpeedCooldownEndTime = now + SPEED_SUPER_COOLDOWN
            elseif superSpeedOnCooldown then
                if now >= superSpeedCooldownEndTime then
                    superSpeedOnCooldown = false
                end
            elseif math.Rand( 0, 1 ) <= SPEED_SUPER_CHANCE then
                hasSuperSpeed = true
                superSpeedEndTime = now + SPEED_SUPER_DURATION
                _setSpeedMult( SPEED_MULT_SUPER )

                return
            end

            local zeroToOne = ( math.cos( now * SPEED_OSCILLATION_RATE ) + 1 ) / 2
            local speedMult = SPEED_MULT_MIN + zeroToOne * SPEED_MULT_MIN_MAX_GAP

            _setSpeedMult( speedMult )
        end

        if SPEED_UPDATE_INTERVAL <= 0 then
            CFCUlxCurse.AddEffectHook( cursedPly, "Think", HOOK_PREFIX .. "GottaGoFastnt", updateSpeed )
        else
            CFCUlxCurse.CreateEffectTimer( cursedPly, HOOK_PREFIX .. "GottaGoFastnt", SPEED_UPDATE_INTERVAL, 0, updateSpeed )
        end
    end,

    onEnd = function( cursedPly )
        if CLIENT then return end

        if IsValid( cursedPly ) then
            setSpeedMult( cursedPly, 1 )
        end

        baseSpeedsPerPlayer[cursedPly] = nil
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
