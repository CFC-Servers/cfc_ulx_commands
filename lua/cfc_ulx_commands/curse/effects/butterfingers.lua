local EFFECT_NAME = "Butterfingers"
local DROP_CHANCE_ON_CLICK = 0.1
local DROP_CHANCE_ON_BULLET = 0.05
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "KeyPress", "DropWeapon", function( ply, key )
            if ply ~= cursedPly then return end
            if key ~= IN_ATTACK and key ~= IN_ATTACK2 then return end
            if math.Rand( 0, 1 ) > DROP_CHANCE_ON_CLICK then return end

            local wep = ply:GetActiveWeapon()
            if not IsValid( wep ) then return end

            ply:DropWeapon( wep )
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "EntityFireBullets", "DropWeapon", function( ent )
            if ent ~= cursedPly then return end
            if math.Rand( 0, 1 ) > DROP_CHANCE_ON_BULLET then return end

            local wep = ent:GetActiveWeapon()
            if not IsValid( wep ) then return end

            -- Use a timer to prevent issues with addons expecting the gun to still be held (e.g. m9kr calling LagCompensation())
            timer.Simple( 0, function()
                if not IsValid( ent ) then return end
                if not IsValid( wep ) then return end

                ent:DropWeapon( wep )
            end )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 20,
    maxDuration = 50,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
