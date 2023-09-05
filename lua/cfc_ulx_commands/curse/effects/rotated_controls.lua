local EFFECT_NAME = "RotatedControls"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        local mode = math.random( 1, 2 ) -- CLockwise or counter-clockwise
        local moveAmount = ( mode == 1 and 1 or -1 ) * 10000

        hook.Add( "CreateMove", HOOK_PREFIX .. "LBozo", function( cmd )
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
        if SERVER then return end

        hook.Remove( "CreateMove", HOOK_PREFIX .. "LBozo" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
