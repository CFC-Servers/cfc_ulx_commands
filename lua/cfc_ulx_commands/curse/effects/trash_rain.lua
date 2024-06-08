local EFFECT_NAME = "TrashRain"
local TRASH_SPAWN_HEIGHT_MIN = 500
local TRASH_SPAWN_HEIGHT_MAX = 650
local TRASH_SPAWN_RADIUS_MIN = 0
local TRASH_SPAWN_RADIUS_MAX = 150
local TRASH_SPAWN_INTERVAL = 0.05
local TRASH_SPAWN_CHANCE_MIN = 0.01
local TRASH_SPAWN_CHANCE_MAX = 0.25
local TRASH_MAX = 50
local TRASH_FLOOD_START_CHANCE = 0.0005
local TRASH_FLOOD_SPAWN_CHANCE = 0.75
local TRASH_FLOOD_DURATION_MIN = 0.5
local TRASH_FLOOD_DURATION_MAX = 3
local TRASH_FLOOD_COOLDOWN = 10
local TRASH_VELOCITY_SPEED_MIN = 2000
local TRASH_VELOCITY_SPEED_MAX = 2500
local TRASH_VELOCITY_SPREAD = 10 -- In degrees 0-89.9
local TRASH_LIFETIME = 10
local TRASH_FADE_DURATION = 1
local TRASH_UPDATE_INTERVAL = 0.05
local TRASH_MODELS = {
    "models/props_interiors/Radiator01a.mdl",
    "models/props_c17/oildrum001.mdl",
    "models/props_c17/FurnitureSink001a.mdl",
    "models/props_junk/garbage_milkcarton001a.mdl",
    "models/props_lab/harddrive02.mdl",
    "models/props_interiors/pot01a.mdl",
    "models/props_combine/breenglobe.mdl",
    "models/props_wasteland/controlroom_chair001a.mdl",
    "models/props_junk/TrafficCone001a.mdl",
    "models/props_wasteland/prison_lamp001c.mdl",
    "models/props_junk/MetalBucket02a.mdl",
    "models/props_c17/chair02a.mdl",
}


local TRASH_MODEL_COUNT = #TRASH_MODELS

local trashEnts = {}
local fadingTrashEnts = {}
local trashSpawnChance = 0
local trashCanFlood = true
local localPly = nil
local spawnTrash
local startFadingTrash
local tryStartTrashFlood
local trySpawnTrash
local updateTrash


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        localPly = cursedPly
        trashSpawnChance = math.Rand( TRASH_SPAWN_CHANCE_MIN, TRASH_SPAWN_CHANCE_MAX )
        trashCanFlood = true

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "UpdateTrash", TRASH_UPDATE_INTERVAL, 0, updateTrash )
        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "SpawnTrash", TRASH_SPAWN_INTERVAL, 0, function()
            tryStartTrashFlood()
            trySpawnTrash()
        end )
    end,

    onEnd = function()
        if SERVER then return end

        for i = #trashEnts, 1, -1 do
            local ent = trashEnts[i]
            trashEnts[i] = nil

            if IsValid( ent ) then
                ent:Remove()
            end
        end

        for i = #fadingTrashEnts, 1, -1 do
            local ent = fadingTrashEnts[i]
            fadingTrashEnts[i] = nil

            if IsValid( ent ) then
                ent:Remove()
            end
        end
    end,

    minDuration = 40,
    maxDuration = 80,
    onetimeDurationMult = 2,
    excludeFromOnetime = nil,
    incompatibileEffects = {},
    groups = {
        "VisualOnly",
    },
    incompatibleGroups = {},
} )


if SERVER then
    for _, model in pairs( TRASH_MODELS ) do
        util.PrecacheModel( model )
    end

    return
end


spawnTrash = function()
    local pos = LocalPlayer():GetPos()
    local ang = Angle( math.Rand( -180, 180 ), math.Rand( -180, 180 ), math.Rand( -180, 180 ) )
    local model = TRASH_MODELS[math.random( TRASH_MODEL_COUNT )]

    local height = math.Rand( TRASH_SPAWN_HEIGHT_MIN, TRASH_SPAWN_HEIGHT_MAX )
    local radius = math.Rand( TRASH_SPAWN_RADIUS_MIN, TRASH_SPAWN_RADIUS_MAX )
    local theta = math.Rand( 0, 360 )
    local vel = Angle( math.Rand( 89.9 - TRASH_VELOCITY_SPREAD, 89.9 ), math.Rand( -180, 180 ), 0 ):Forward()
    vel = vel * math.Rand( TRASH_VELOCITY_SPEED_MIN, TRASH_VELOCITY_SPEED_MAX )

    pos = pos + Vector( math.cos( theta ) * radius, math.sin( theta ) * radius, height )

    local ent = ents.CreateClientProp( model )
    ent:SetPos( pos )
    ent:SetAngles( ang )
    ent:SetRenderMode( RENDERMODE_TRANSCOLOR )
    ent:Spawn()
    ent:GetPhysicsObject():SetVelocity( vel )

    ent.CFCUlxCurseFadeStartTime = CurTime() + TRASH_LIFETIME
    table.insert( trashEnts, ent )

    if #trashEnts > TRASH_MAX then
        startFadingTrash( trashEnts[1] )
    end
end

startFadingTrash = function( ent )
    if ent.CFCUlxCurseFading then return end

    ent.CFCUlxCurseFading = true
    ent.CFCUlxCurseFadeStartTime = CurTime()

    table.RemoveByValue( trashEnts, ent )
    table.insert( fadingTrashEnts, ent )
end

tryStartTrashFlood = function()
    if not trashCanFlood then return end
    if TRASH_FLOOD_START_CHANCE == 0 or math.Rand( 0, 1 ) > TRASH_FLOOD_START_CHANCE then return end

    local prevTrashSpawnChance = trashSpawnChance

    trashCanFlood = false
    trashSpawnChance = TRASH_FLOOD_SPAWN_CHANCE

    CFCUlxCurse.CreateEffectTimer( localPly, EFFECT_NAME, "StopTrashFlood", math.Rand( TRASH_FLOOD_DURATION_MIN, TRASH_FLOOD_DURATION_MAX ), 1, function()
        trashSpawnChance = prevTrashSpawnChance
    end )

    CFCUlxCurse.CreateEffectTimer( localPly, EFFECT_NAME, "TrashFloodCooldownFinished", TRASH_FLOOD_COOLDOWN, 1, function()
        trashCanFlood = true
    end )
end

trySpawnTrash = function()
    if trashSpawnChance ~= 1 and math.Rand( 0, 1 ) > trashSpawnChance then return end

    spawnTrash()
end

updateTrash = function()
    local now = CurTime()

    for i = #trashEnts, 1, -1 do
        local ent = trashEnts[i]

        if not ent:IsValid() then
            table.remove( trashEnts, i )
        elseif now > ent.CFCUlxCurseFadeStartTime then
            startFadingTrash( ent )
        end
    end

    for i = #fadingTrashEnts, 1, -1 do
        local ent = fadingTrashEnts[i]

        if not ent:IsValid() then
            table.remove( fadingTrashEnts, i )
        else
            local elapsed = now - ent.CFCUlxCurseFadeStartTime

            if elapsed >= TRASH_FADE_DURATION then
                table.remove( fadingTrashEnts, i )
                ent:Remove()
            else
                local alpha = 255 * ( 1 - elapsed / TRASH_FADE_DURATION )
                ent:SetColor( Color( 255, 255, 255, alpha ) )
            end
        end
    end
end
