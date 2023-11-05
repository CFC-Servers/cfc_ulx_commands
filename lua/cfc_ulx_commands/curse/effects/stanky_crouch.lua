local EFFECT_NAME = "StankyCrouch"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "CreateMove", "LBozo", function( cmd )
            local cmdNum = cmd:CommandNumber()

            if  cmdNum % 20 > 3 and
                cmdNum % 12 ~= 0 and
                cmdNum % 200 > 10
            then return end

            cmd:AddKey( IN_DUCK )
            cmd:AddKey( IN_WALK )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatabileEffects = {
        "Crouch",
    },
} )
