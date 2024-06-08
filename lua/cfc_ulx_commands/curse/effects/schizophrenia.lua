local EFFECT_NAME = "Schizophrenia"
local DISAPPEAR_DELAY_MIN = 0
local DISAPPEAR_DELAY_MAX = 0.15
local DISAPPEAR_MARGIN = 100
local APPEAR_MARGIN = 200
local SPAWN_RADIUS_MIN = 100
local SPAWN_RADIUS_MAX = 3000
local SPAWN_CHANCE = 0.01
local SPAWN_COOLDOWN = 5
local SPAWN_ATTEMPTS = 10
local LIMIT = 5


local PI_DOUBLE = math.pi * 2
local VECTOR_UP_SHORT = Vector( 0, 0, 10 )
local VECTOR_DOWN_LONG = Vector( 0, 0, -10000 )

local ghosts = {}
local nextSpawnTime = 0


local function makePlayerCopy( ply, pos, ang )
    local ent = ClientsideModel( ply:GetModel() )
    ent:SetPos( pos )
    ent:SetAngles( ang )
    ent:Spawn()
    ent:SetSequence( ply:GetSequence() )
    ent:SetSkin( ply:GetSkin() )

    for i = 0, ply:GetNumBodyGroups() - 1 do
        ent:SetBodygroup( i, ply:GetBodygroup( i ) )
    end

    local plyColor = ply:GetPlayerColor()

    function ent:GetPlayerColor()
        return plyColor
    end

    table.insert( ghosts, ent )

    return ent
end

local function getRandomPlayer()
    local plys = player.GetAll()

    return plys[math.random( 1, #plys )]
end

local function delayedRemove( ent )
    local delay = math.Rand( DISAPPEAR_DELAY_MIN, DISAPPEAR_DELAY_MAX )

    timer.Simple( delay, function()
        if IsValid( ent ) then
            ent:Remove()
        end
    end )
end

local function poofVisibleGhosts()
    local edgeW = ScrW() - DISAPPEAR_MARGIN
    local edgeH = ScrH() - DISAPPEAR_MARGIN

    for i = #ghosts, 1, -1 do
        local ghost = ghosts[i]

        -- Ents made from ClientsideModel() can sometimes become invalid under various circumstances.
        if IsValid( ghost ) then
            local scrPos = ghost:GetPos():ToScreen()

            if scrPos.visible then
                local x = scrPos.x
                local y = scrPos.y

                -- If the ghost is far enough into the screen, remove it.
                if x > DISAPPEAR_MARGIN and x < edgeW and y > DISAPPEAR_MARGIN and y < edgeH then
                    table.remove( ghosts, i )
                    delayedRemove( ghost )
                end
            end
        else
            table.remove( ghosts, i )
        end
    end
end

local function trySpawnGhost()
    local now = CurTime()
    if now < nextSpawnTime then return end
    if #ghosts >= LIMIT then return end
    if SPAWN_CHANCE ~= 1 and math.Rand( 0, 1 ) > SPAWN_CHANCE then return end

    local edgeW = ScrW() + APPEAR_MARGIN
    local edgeH = ScrH() + APPEAR_MARGIN

    local attemptsLeft = SPAWN_ATTEMPTS
    local spawnCenter = LocalPlayer():GetPos() + VECTOR_UP_SHORT

    while attemptsLeft > 0 do
        local radius = math.Rand( SPAWN_RADIUS_MIN, SPAWN_RADIUS_MAX )
        local theta = math.Rand( 0, PI_DOUBLE )

        local spawnPos = spawnCenter + Vector( math.cos( theta ) * radius, math.sin( theta ) * radius, 0 )
        local tr = util.TraceLine( { start = spawnPos, endpos = spawnPos + VECTOR_DOWN_LONG } )

        if tr.Fraction ~= 0 then
            spawnPos = tr.HitPos

            local scrPos = spawnPos:ToScreen()
            local visible = scrPos.visible

            if visible then
                local x = scrPos.x
                local y = scrPos.y

                if x < -APPEAR_MARGIN or x > edgeW or y < -APPEAR_MARGIN or y > edgeH then
                    visible = false
                end
            end

            if not visible then
                nextSpawnTime = now + SPAWN_COOLDOWN
                makePlayerCopy( getRandomPlayer(), spawnPos, Angle( 0, math.Rand( -180, 180 ), 0 ) )

                break
            end
        end

        attemptsLeft = attemptsLeft - 1
    end
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        nextSpawnTime = 0

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "Think", "Schizo", function()
            poofVisibleGhosts()
            trySpawnGhost()
        end )
    end,

    onEnd = function( _ )
        for _, ghost in ipairs( ghosts ) do
            if IsValid( ghost ) then
                ghost:Remove()
            end
        end

        table.Empty( ghosts )
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatabileEffects = {},
} )
