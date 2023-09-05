local EFFECT_NAME = "InvertedAim"
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

            cmd:SetMouseX( -cmd:GetMouseX() )
            cmd:SetMouseY( -cmd:GetMouseY() )

            realAng.y = realAng.y - cmd:GetMouseX() * 0.022
            realAng.x = math.Clamp( realAng.x + cmd:GetMouseY() * 0.022, -89, 89 )
            realAng:Normalize()

            cmd:SetViewAngles( realAng )
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "CreateMove", HOOK_PREFIX .. "LBozo" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
