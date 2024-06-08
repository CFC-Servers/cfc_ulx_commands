local EFFECT_NAME = "RotatedControls"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local mode = math.random( 1, 2 ) -- CLockwise or counter-clockwise
        local moveAmount = ( mode == 1 and 1 or -1 ) * 10000

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            cmd:SetForwardMove( 0 )
            cmd:SetSideMove( 0 )

            if cmd:KeyDown( IN_FORWARD ) then
                cmd:SetSideMove( moveAmount )
            elseif cmd:KeyDown( IN_BACK ) then
                cmd:SetSideMove( -moveAmount )
            end

            if cmd:KeyDown( IN_MOVERIGHT ) then
                cmd:SetForwardMove( -moveAmount )
            elseif cmd:KeyDown( IN_MOVELEFT ) then
                cmd:SetForwardMove( moveAmount )
            end
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatibileEffects = {
        "ReverseControls",
        "Swagger",
    },
    groups = {
        "Input",
        "WS",
        "AD",
    },
    incompatibleGroups = {
        "WS",
        "AD",
    },
} )
