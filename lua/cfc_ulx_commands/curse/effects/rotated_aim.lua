local EFFECT_NAME = "RotatedAim"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local realAng
        local mode = math.random( 1, 2 )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            if not realAng then
                realAng = cmd:GetViewAngles()
            end

            local x = cmd:GetMouseX()
            local y = cmd:GetMouseY()

            if mode == 1 then -- Clockwise
                cmd:SetMouseX( -y )
                cmd:SetMouseY( x )
            else -- Counter-clockwise
                cmd:SetMouseX( y )
                cmd:SetMouseY( -x )
            end

            realAng.y = realAng.y - cmd:GetMouseX() * 0.022
            realAng.x = math.Clamp( realAng.x + cmd:GetMouseY() * 0.022, -89, 89 )
            realAng:Normalize()

            cmd:SetViewAngles( realAng )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 10,
    maxDuration = 20,
    onetimeDurationMult = 1.5,
    excludeFromOnetime = nil,
    incompatabileEffects = {
        "InvertedAim",
    },
} )
