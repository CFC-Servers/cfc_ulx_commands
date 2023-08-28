local EFFECT_NAME = "RotatedControlsCW"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        hook.Add( "CreateMove", HOOK_PREFIX .. "LBozo", function( cmd )
            cmd:SetForwardMove( 0 )
            cmd:SetSideMove( 0 )

            if cmd:KeyDown( IN_FORWARD ) then
                cmd:SetSideMove( 10000 )
            elseif cmd:KeyDown( IN_BACK ) then
                cmd:SetSideMove( -10000 )
            end

            if cmd:KeyDown( IN_MOVERIGHT ) then
                cmd:SetForwardMove( -10000 )
            elseif cmd:KeyDown( IN_MOVELEFT ) then
                cmd:SetForwardMove( 10000 )
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
