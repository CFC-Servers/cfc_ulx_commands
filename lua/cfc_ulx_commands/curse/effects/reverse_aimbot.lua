local EFFECT_NAME = "ReverseAimbot"
local PUSH_STRENGTH = 35
local PUSH_THRESHOLD_LOW = 0.93
local PUSH_DISTANCE_LOW = 50
local PUSH_THRESHOLD_HIGH = 0.9999
local PUSH_DISTANCE_HIGH = 1000


local VECTOR_ZERO = Vector( 0, 0, 0 )


local function getHeadPos( ply )
    local boneID = ply:GetHitBoxBone( 0, 0 )
    if not boneID then return ply:GetPos() end

    return ply:GetBoneMatrix( boneID ):GetTranslation()
end

local function aimAwayFromHeads( localPly, viewAng )
    local viewDir = viewAng:Forward()
    local eyePos = EyePos()

    local pitch = viewAng.p
    local yaw = viewAng.y
    local roll = viewAng.r

    viewAng.r = 0

    for _, ply in player.Iterator() do
        if ply ~= localPly then
            local toHead = getHeadPos( ply ) - eyePos
            local dot = toHead:Dot( viewDir )

            if dot > 0 then
                local toHeadLength = toHead:Length()

                if toHeadLength ~= 0 then
                    dot = dot / toHeadLength

                    local threshold = math.Clamp( math.Remap( toHeadLength, PUSH_DISTANCE_LOW, PUSH_DISTANCE_HIGH, PUSH_THRESHOLD_LOW, PUSH_THRESHOLD_HIGH ), 0.5, 0.99995 )

                    if dot >= threshold then
                        local _, toHeadAngLocal = WorldToLocal( VECTOR_ZERO, toHead:Angle(), VECTOR_ZERO, viewAng )
                        local strengthEff = PUSH_STRENGTH * dot / toHeadLength

                        local p = 1 / toHeadAngLocal.p
                        local y = 1 / toHeadAngLocal.y

                        pitch = pitch - p * strengthEff
                        yaw = yaw - y * strengthEff
                    end
                end
            end
        end
    end

    return Angle( pitch, yaw, roll )
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            cmd:SetViewAngles( aimAwayFromHeads( cursedPly, cmd:GetViewAngles() ) )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatabileEffects = {},
    groups = {
        "ViewAngles",
    },
    incompatibleGroups = {
        "ViewAngles",
    },
} )
