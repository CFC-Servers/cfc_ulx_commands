local EFFECT_NAME = "DoSomeHarm"
local DAMAGE_BLOCK_CHANCE = 0.75

CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end
		
        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "EntityTakeDamage", "BlockDamage", function( ply, dmgInfo )
			if dmgInfo:GetAttacker() ~= cursedPly or math.random() > DAMAGE_BLOCK_CHANCE then return end
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
        "DoNoHarm"
    },
    groups = {
        "DisableDamage"
    },
    incompatibleGroups = {},
} )
