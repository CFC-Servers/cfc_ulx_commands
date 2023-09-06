local EFFECT_NAME = "HealthScramble"
local TICK_INTERVAL = 10 -- Only update once every x amount of ticks.
local HEALTH_MIN = 1
local HEALTH_MAX_MULT = 2
local ARMOR_MIN = 1
local ARMOR_MAX_MULT = 1
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"
-- Similar in concept to HealthObfuscate, but actually changes the values serverside.
-- Also affects armor, if the player has any.


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        local tickCount = 1

        CFCUlxCurse.AddEffectHook( cursedPly, "Think", HOOK_PREFIX .. "TimeToGamble", function()
            -- Only update once every x amount of ticks.
            if TICK_INTERVAL ~= 1 then
                if tickCount == TICK_INTERVAL then
                    tickCount = 1
                else
                    tickCount = tickCount + 1

                    return
                end
            end

            if not cursedPly:Alive() then return end

            local maxHealth = math.ceil( cursedPly:GetMaxHealth() * HEALTH_MAX_MULT )
            cursedPly:SetHealth( math.random( HEALTH_MIN, maxHealth ) )

            if cursedPly:Armor() < 1 then return end

            local maxArmor = math.ceil( cursedPly:GetMaxArmor() * ARMOR_MAX_MULT )
            cursedPly:SetArmor( math.random( ARMOR_MIN, maxArmor ) )
        end )
    end,

    onEnd = function()
        -- Do nothing.
    end,

    minDuration = 30,
    maxDuration = 60,
    onetimeDurationMult = 4,
    excludeFromOnetime = nil,
} )
