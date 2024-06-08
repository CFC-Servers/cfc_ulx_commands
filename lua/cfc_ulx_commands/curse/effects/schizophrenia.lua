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
local SPAWN_LIMIT = 5

local SOUND_CHANCE = 0.003
local SOUND_COOLDOWN = 5
local SOUND_RADIUS_MIN = 200
local SOUND_RADIUS_MAX = 1500
local SOUND_LIST = {
    "ambient/atmosphere/cave_hit1.wav",
    "ambient/atmosphere/cave_hit2.wav",
    "ambient/atmosphere/cave_hit3.wav",
    "ambient/atmosphere/cave_hit4.wav",
    "ambient/atmosphere/cave_hit5.wav",
    "ambient/atmosphere/cave_hit6.wav",
    "ambient/atmosphere/hole_hit1.wav",
    "ambient/atmosphere/hole_hit2.wav",
    "ambient/atmosphere/hole_hit3.wav",
    "ambient/atmosphere/hole_hit4.wav",
    "ambient/atmosphere/hole_hit5.wav",
    "ambient/machines/machine1_hit1.wav",
    "ambient/machines/machine1_hit2.wav",
    "ambient/materials/creak5.wav",
    "ambient/materials/dinnerplates1.wav",
    "ambient/materials/dinnerplates2.wav",
    "ambient/materials/dinnerplates3.wav",
    "ambient/materials/dinnerplates4.wav",
    "ambient/materials/dinnerplates5.wav",
    "ambient/materials/cupdrop.wav",
    "ambient/materials/clang1.wav",
    "ambient/materials/cartrap_rope1.wav",
    "ambient/materials/cartrap_rope2.wav",
    "ambient/materials/cartrap_rope3.wav",
    "ambient/materials/metal4.wav",
    "ambient/materials/metal5.wav",
    "ambient/materials/rustypipes1.wav",
    "ambient/materials/rustypipes2.wav",
    "ambient/materials/rustypipes3.wav",
    "ambient/materials/shipgroan1.wav",
    "ambient/materials/shipgroan2.wav",
    "ambient/materials/shipgroan3.wav",
    "ambient/materials/shipgroan4.wav",
    "ambient/materials/wood_creak1.wav",
    "ambient/materials/wood_creak2.wav",
    "ambient/materials/wood_creak3.wav",
    "ambient/materials/wood_creak4.wav",
    "ambient/materials/wood_creak5.wav",
    "ambient/materials/wood_creak6.wav",
    "ambient/voices/cough1.wav",
    "ambient/voices/cough2.wav",
    "ambient/voices/cough3.wav",
    "ambient/voices/cough4.wav",
    "ambient/voices/playground_memory.wav",
    "ambient/water/distant_drip1.wav",
    "ambient/water/distant_drip2.wav",
    "ambient/water/distant_drip3.wav",
    "ambient/water/distant_drip4.wav",
    "ambient/water/drip1.wav",
    "ambient/water/drip2.wav",
    "ambient/water/drip3.wav",
    "ambient/water/drip4.wav",
    "npc/headcrab/attack1.wav",
    "npc/headcrab/attack2.wav",
    "npc/headcrab/attack3.wav",
    "npc/headcrab/headbite.wav",
    "npc/headcrab/pain1.wav",
    "npc/headcrab/pain2.wav",
    "npc/headcrab/pain3.wav",
    "npc/headcrab_poison/ph_idle1.wav",
    "npc/headcrab_poison/ph_idle2.wav",
    "npc/headcrab_poison/ph_idle3.wav",
    "npc/headcrab_poison/ph_warning1.wav",
    "npc/headcrab_poison/ph_warning2.wav",
    "npc/headcrab_poison/ph_warning3.wav",
    "npc/roller/blade_cut.wav",
    "npc/roller/blade_in.wav",
    "npc/roller/blade_out.wav",
    "npc/scanner/combat_scan1.wav",
    "npc/scanner/combat_scan2.wav",
    "npc/scanner/combat_scan3.wav",
    "npc/scanner/combat_scan4.wav",
    "npc/scanner/combat_scan5.wav",
    "npc/scanner/scanner_talk1.wav",
    "npc/scanner/scanner_talk2.wav",
    "npc/turret_floor/active.wav",
    "npc/turret_floor/deploy.wav",
    "npc/turret_floor/click1.wav",
    "npc/turret_floor/ping.wav",
    "npc/turret_floor/retract.wav",
    "npc/turret_floor/shoot1.wav",
    "npc/turret_floor/shoot2.wav",
    "npc/turret_floor/shoot3.wav",
    "npc/zombie/zombie_alert1.wav",
    "npc/zombie/zombie_alert2.wav",
    "npc/zombie/zombie_alert3.wav",
    "npc/zombie/zombie_pain1.wav",
    "npc/zombie/zombie_pain2.wav",
    "npc/zombie/zombie_pain3.wav",
    "npc/zombie/zombie_pain4.wav",
    "npc/zombie/zombie_pain5.wav",
    "npc/zombie/zombie_pain6.wav",
    "npc/combine_soldier/gear1.wav",
    "npc/combine_soldier/gear2.wav",
    "npc/combine_soldier/gear3.wav",
    "npc/combine_soldier/gear4.wav",
    "npc/combine_soldier/gear5.wav",
    "npc/combine_soldier/gear6.wav",
    "npc/combine_soldier/pain1.wav",
    "npc/combine_soldier/pain2.wav",
    "npc/combine_soldier/pain3.wav",
    "npc/combine_soldier/vo/contact.wav",
    "npc/combine_soldier/vo/contactconfim.wav",
    "npc/combine_soldier/vo/contactconfirmprosecuting.wav",
    "npc/combine_soldier/vo/contained.wav",
    "npc/combine_soldier/vo/containmentproceeding.wav",
    "npc/combine_soldier/vo/cover.wav",
    "npc/combine_soldier/vo/coverhurt.wav",
    "npc/combine_soldier/vo/coverme.wav",
    "npc/combine_soldier/vo/affirmative.wav",
    "npc/crow/crow2.wav",
    "npc/crow/crow3.wav",
    "npc/antlion_guard/foot_heavy1.wav",
    "npc/antlion_guard/foot_heavy2.wav",
}


local PI_DOUBLE = math.pi * 2
local VECTOR_UP_SHORT = Vector( 0, 0, 10 )
local VECTOR_DOWN_LONG = Vector( 0, 0, -10000 )

local ghosts = {}
local nextSpawnTime = 0
local nextSoundTime = 0


local function randomInCircle( radius )
    local theta = math.Rand( 0, PI_DOUBLE )

    return Vector( math.cos( theta ) * radius, math.sin( theta ) * radius, 0 )
end

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
    if #ghosts >= SPAWN_LIMIT then return end
    if SPAWN_CHANCE ~= 1 and math.Rand( 0, 1 ) > SPAWN_CHANCE then return end

    local edgeW = ScrW() + APPEAR_MARGIN
    local edgeH = ScrH() + APPEAR_MARGIN

    local attemptsLeft = SPAWN_ATTEMPTS
    local spawnCenter = LocalPlayer():GetPos() + VECTOR_UP_SHORT

    while attemptsLeft > 0 do
        local spawnPos = spawnCenter + randomInCircle( math.Rand( SPAWN_RADIUS_MIN, SPAWN_RADIUS_MAX ) )
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

local function tryPlaySound()
    local now = CurTime()
    if now < nextSoundTime then return end
    if SOUND_CHANCE ~= 1 and math.Rand( 0, 1 ) > SOUND_CHANCE then return end

    nextSoundTime = now + SOUND_COOLDOWN

    local pos = LocalPlayer():GetPos() + randomInCircle( math.Rand( SOUND_RADIUS_MIN, SOUND_RADIUS_MAX ) )

    sound.Play( SOUND_LIST[math.random( 1, #SOUND_LIST )], pos )
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        nextSpawnTime = 0
        nextSoundTime = 0

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "Think", "Schizo", function()
            poofVisibleGhosts()
            trySpawnGhost()
            tryPlaySound()
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
