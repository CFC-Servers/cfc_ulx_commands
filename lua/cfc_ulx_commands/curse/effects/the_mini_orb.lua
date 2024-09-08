local EFFECT_NAME = "TheMiniOrb" -- Not mini orb. The Mini Orb. Praise be The Orb.
local SPEED_START = 10
local SPEED_MAX = 350
local SPEED_RATE = ( SPEED_MAX - SPEED_START ) / 10


local ANGLE_ZERO = Angle( 0, 0, 0 )

local orbsPerPly = {}


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if CLIENT then return end

        local spawnPos = cursedPly:EyePos() + cursedPly:GetAngles():Forward() * 250
        spawnPos = spawnPos + cursedPly:GetVelocity()

        local theMiniOrb = ents.Create( "prop_physics" )
        theMiniOrb:SetModel( "models/hunter/misc/sphere025x025.mdl" )
        theMiniOrb:SetMaterial( "models/XQM//LightLinesRed" )
        theMiniOrb:SetPos( spawnPos )
        theMiniOrb:Spawn()
        theMiniOrb:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
        theMiniOrb:EmitSound( "ambient/energy/weld1.wav", 85, 90, 1, CHAN_AUTO )

        local physObj = theMiniOrb:GetPhysicsObject()
        physObj:SetMass( 50000 )
        physObj:EnableMotion( false )

        local speed = SPEED_START
        local orbOBBMins = theMiniOrb:OBBMins()
        local orbOBBMaxs = theMiniOrb:OBBMaxs()

        orbsPerPly[cursedPly] = theMiniOrb

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "Think", "Update", function()
            if not IsValid( theMiniOrb ) then
                CFCUlxCurse.StopCurseEffect( cursedPly, EFFECT_NAME )

                return
            end

            if not cursedPly:Alive() then return end
            if cursedPly.frozen then return end

            local orbPos = theMiniOrb:GetPos()

            if util.IsOBBIntersectingOBB( cursedPly:GetPos(), ANGLE_ZERO, cursedPly:OBBMins(), cursedPly:OBBMaxs(), orbPos, ANGLE_ZERO, orbOBBMins, orbOBBMaxs, 0 ) then
                PrintMessage( HUD_PRINTCONSOLE, cursedPly:Nick() .. " got caught by The Mini Orb!" )
                cursedPly:Kill()
                theMiniOrb:EmitSound( "ambient/energy/newspark10.wav", 85, 85, 1, CHAN_AUTO )

                return
            end

            local dt = FrameTime()

            if speed < SPEED_MAX then
                speed = speed + SPEED_RATE * dt
            end

            -- Just in case.
            if physObj:IsMotionEnabled() then
                physObj:EnableMotion( false )
            end

            local plyPos = cursedPly:GetPos() + cursedPly:OBBCenter()
            local orbDir = ( plyPos - orbPos ):GetNormalized()

            theMiniOrb:SetPos( orbPos + orbDir * speed * dt )
        end )

        theMiniOrb:CallOnRemove( "CFCUlxCurse_RemoveMiniOrbCurse", function()
            if not IsValid( cursedPly ) then return end

            CFCUlxCurse.StopCurseEffect( cursedPly, EFFECT_NAME )
        end )


        -- Weird stuff happens if you forcibly die while ragdolled.
        if cursedPly.ragdoll then
            ulx.unragdollPlayer( cursedPly )
        end

        ulx.setExclusive( cursedPly, "being chased by The Mini Orb" )
    end,

    onEnd = function( cursedPly )
        if CLIENT then return end

        local theMiniOrb = orbsPerPly[cursedPly]
        orbsPerPly[cursedPly] = nil

        if IsValid( theMiniOrb ) then
            theMiniOrb:RemoveCallOnRemove( "CFCUlxCurse_RemoveMiniOrbCurse" )
            theMiniOrb:Remove()
        end

        ulx.clearExclusive( cursedPly )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {},
    groups = {
        "Death",
    },
    incompatibleGroups = {},
} )
