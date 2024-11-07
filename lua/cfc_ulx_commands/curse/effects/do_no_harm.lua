local EFFECT_NAME = "DoNoHarm"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end
		
        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "EntityTakeDamage", "BlockDamage", function( ply, dmgInfo )
			if dmgInfo:GetAttacker() ~= cursedPly then return end
			return true
		end)
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatibileEffects = {
        "DoSomeHarm"
    },
    groups = {
        "DisableDamage"
    },
    incompatibleGroups = {},
} )
