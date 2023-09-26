local EFFECT_NAME = "Jittery"
local JITTER_INTERVAL = 0.05
local JITTER_CHANCE = 1
local JITTER_RADIUS_MIN = 0
local JITTER_RADIUS_MAX = 15
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


local PI_DOUBLE = 2 * math.pi


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        CFCUlxCurse.CreateEffectTimer( cursedPly, HOOK_PREFIX .. "Teleport", JITTER_INTERVAL, 0, function()
            if JITTER_CHANCE ~= 1 and math.Rand( 0, 1 ) > JITTER_CHANCE then return end

            local theta = math.Rand( 0, PI_DOUBLE )
            local dir = Vector( math.cos( theta ), math.sin( theta ), 0 )
            local radius = math.Rand( JITTER_RADIUS_MIN, JITTER_RADIUS_MAX )
            local posOffset = dir * radius

            local curPos = cursedPly:GetPos()
            local boxMin = cursedPly:OBBMins()
            local boxMax = cursedPly:OBBMaxs()
            local traceStart = curPos + cursedPly:OBBCenter()

            local tr = util.TraceHull( {
                start = traceStart,
                endpos = traceStart + posOffset,
                filter = cursedPly,
                mins = boxMin,
                maxs = boxMax,
                mask = MASK_PLAYERSOLID,
            } )

            if tr.Hit then return end

            cursedPly:SetPos( curPos + posOffset )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
