local EFFECT_NAME = "StaggeredAim"
local AIM_UPDATE_INTERVAL_MIN = 0.1
local AIM_UPDATE_INTERVAL_MAX = 0.3


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly, startTime )
        local realAng
        local heldAng
        local nextUpdateTime = 0
        local interval = util.SharedRandom( math.Round( startTime, 2 ), AIM_UPDATE_INTERVAL_MIN, AIM_UPDATE_INTERVAL_MAX )
        -- ^ Round to two decimals to avoid float imprecision issues.

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "StartCommand", "LBozo", function( ply, cmd )
            if ply ~= cursedPly then return end

            if not realAng then
                realAng = cmd:GetViewAngles()
                heldAng = Angle( realAng.p, realAng.y, realAng.r )
            end

            if cmd:CommandNumber() ~= 0 then
                realAng.y = realAng.y - cmd:GetMouseX() * 0.022
                realAng.x = math.Clamp( realAng.x + cmd:GetMouseY() * 0.022, -89, 89 )
                realAng:Normalize()
            end

            local now = CurTime()

            if now >= nextUpdateTime then
                heldAng = Angle( realAng.p, realAng.y, realAng.r )
                nextUpdateTime = now + interval
            end

            cmd:SetViewAngles( heldAng )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 30,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {},
    groups = {
        "ViewAngles",
    },
    incompatibleGroups = {
        "ViewAngles",
    },
} )
