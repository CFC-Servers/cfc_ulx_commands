local EFFECT_NAME = "SpineBreak"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        local realAng
        hook.Add( "CreateMove", HOOK_PREFIX .. "LBozo", function( cmd )
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
        if SERVER then return end

        hook.Remove( "CreateMove", HOOK_PREFIX .. "LBozo" )
    end,

    minDuration = 30,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
