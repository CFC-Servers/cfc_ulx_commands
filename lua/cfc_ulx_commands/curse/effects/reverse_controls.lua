local EFFECT_NAME = "ReverseControls"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        hook.Add( "CreateMove", HOOK_PREFIX .. "LBozo", function( cmd )
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
        if SERVER then return end

        hook.Remove( "CreateMove", HOOK_PREFIX .. "LBozo" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
