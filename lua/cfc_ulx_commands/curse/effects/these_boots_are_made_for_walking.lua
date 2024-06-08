local EFFECT_NAME = "TheseBootsAreMadeForWalking"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "AndThat'sJustWhatThey'llDo", function( cmd )
            cmd:SetForwardMove( 10000 )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatabileEffects = {
        "Crab",
    },
    groups = {
        "Input",
        "WS",
    },
    incompatibleGroups = {
        "WS",
    },
} )
