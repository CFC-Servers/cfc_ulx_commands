local EFFECT_NAME = "ReverseControls"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            if cmd:KeyDown( IN_FORWARD ) then
                cmd:SetForwardMove( -10000 )
            elseif cmd:KeyDown( IN_BACK ) then
                cmd:SetForwardMove( 10000 )
            end

            if cmd:KeyDown( IN_MOVERIGHT ) then
                cmd:SetSideMove( -10000 )
            elseif cmd:KeyDown( IN_MOVELEFT ) then
                cmd:SetSideMove( 10000 )
            end
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
