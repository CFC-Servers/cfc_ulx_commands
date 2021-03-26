CFCUlxCommands.propify = CFCUlxCommands.propify or {}
local cmd = CFCUlxCommands.propify

local CATEGORY_NAME = "Fun"
local PROP_DEFAULT_MODEL = "models/props_c17/oildrum001.mdl"
local PROP_MAX_SIZE = CreateConVar( "cfc_ulx_propify_max_size", 150, FCVAR_NONE, "The max radius allowed for propify models (default 150)", 0, 50000 )
local HOP_STRENGTH = CreateConVar( "cfc_ulx_propify_hop_strength", 400, FCVAR_NONE, "The strength of propify hops (default 400)", 0, 50000 )
local HOP_COOLDOWN = CreateConVar( "cfc_ulx_propify_hop_cooldown", 2, FCVAR_NONE, "The cooldown between propify hops in seconds (default 2)", 0, 50000 )
local STRUGGLE_AMOUNT = CreateConVar( "cfc_ulx_propify_struggle_amount", 30, FCVAR_REPLICATED, "How much a propified player must struggle to escape being picked up (default 30, set to 0 to disallow struggling)", 0, 50000 )
local STRUGGLE_DECAY = CreateConVar( "cfc_ulx_propify_struggle_decay", 0.25, FCVAR_NONE, "How many seconds it takes for a propified players' struggle power to decrease by one (default 0.25)", 0, 50000 )
local STRUGGLE_LIMIT = CreateConVar( "cfc_ulx_propify_struggle_limit", 0.1, FCVAR_NONE, "How frequently, in seconds, a propified player can increase their struggle power (default 0.1)", 0, 50000 )
local STRUGGLE_SAFETY = CreateConVar( "cfc_ulx_propify_struggle_safety", 5, FCVAR_NONE, "How long a propified player is invulnerable for after successfully escaping a grab (default 5)", 0, 50000 )
local STRUGGLE_STRENGTH = CreateConVar( "cfc_ulx_propify_struggle_strength", 500, FCVAR_NONE, "The strength that a propified player launches at when escaping a grab (default 500)", 0, 50000 )
local STRUGGLE_FLEE_RANDOM = CreateConVar( "cfc_ulx_propify_struggle_flee_random", 45, FCVAR_NONE, "How many degrees in any direction that a propified player will randomly launch towards when escaping a grab (default 45)", 0, 180 )

local function propifyPlayer( caller, ply, modelPath )
    local canPropify = hook.Run( "CFC_ULX_PropifyPlayer", caller, ply, false ) ~= false
    if not canPropify then return ply:GetNick() .. " cannot be propified!" end
    if not util.IsValidModel( modelPath ) then return "Invalid model!" end

    if ply:InVehicle() then
        local vehicle = ply:GetParent()
        ply:ExitVehicle()
    end

    ULib.getSpawnInfo( ply )

    local prop = ents.Create( "prop_physics" )
    prop:SetModel( modelPath )

    if prop:BoundingRadius() > PROP_MAX_SIZE:GetFloat() then
        prop:Remove()
        return "Model too big!"
    end

    prop.ragdolledPly = ply
    ply:SetNWBool( "propifyGrabbed", false )
    ply:SetNWInt( "propifyStruggle", 0 )

    prop:SetPos( ply:WorldSpaceCenter() )
    prop:SetAngles( ply:GetAngles() )
    prop:Spawn()
    prop:Activate()
    prop:GetPhysicsObject():SetVelocity( ply:GetVelocity() )

    ply:Spectate( OBS_MODE_CHASE )
    ply:SpectateEntity( prop )
    ply:StripWeapons()

    prop:DisallowDeleting( true, _, true )
    ply:DisallowSpawning( true )

    ply.ragdoll = prop
    ulx.setExclusive( ply, "ragdolled" )

    return nil, prop
end

function cmd.unpropifyPlayer( ply )
    if not ply then return end

    ply:DisallowSpawning( false )
    ply:SetParent()

    ply:UnSpectate()

    local prop = ply.ragdoll
    ply.ragdoll = nil
    ply.propifyCanStruggle = nil
    ply:SetNWBool( "propifyGrabbed", false )
    timer.Remove( "CFC_ULX_PropifyStruggleDecay_" .. ply:SteamID() )

    if not IsValid( prop ) then
        ULib.spawn( ply, true )
    else
        local pos = prop:GetPos()
        pos.z = pos.z + 10

        ULib.spawn( ply, true )
        ply:SetPos( pos )
        ply:SetVelocity( prop:GetVelocity() )
        ply:SetAngles( Angle( 0, prop:GetAngles().yaw, 0 ) )
        prop.ragdolledPly = nil
        prop.propifyStruggle = nil
        prop:DisallowDeleting( false )
        prop:Remove()
    end

    ulx.clearExclusive( ply )
end

function cmd.propifyTargets( caller, targets, modelPath, shouldUnpropify )
    local affectedPlys = {}
    local props = {}

    for _, ply in pairs( targets ) do
        if not shouldUnpropify then
            if ulx.getExclusive( ply, caller ) then
                ULib.tsayError( caller, ulx.getExclusive( ply, caller ), true )
            elseif not ply:Alive() then
                ULib.tsayError( caller, ply:Nick() .. " is dead and cannot be propified!", true )
            else
                local err, prop = propifyPlayer( caller, ply, modelPath )

                if not err then
                    table.insert( affectedPlys, ply )
                    table.insert( props, prop )
                else
                    ULib.tsayError( caller, err, true )
                end
            end
        elseif ply.ragdoll then
            cmd.unpropifyPlayer( ply )
            table.insert( affectedPlys, ply )
        end
    end

    if not IsValid( caller ) then return props end

    if not shouldUnpropify then
        ulx.fancyLogAdmin( caller, "#A propified #T", affectedPlys )
    else
        ulx.fancyLogAdmin( caller, "#A unpropified #T", affectedPlys )
    end

    return props
end

local propifyCommand = ulx.command( CATEGORY_NAME, "ulx propify", cmd.propifyTargets, "!propify" )
propifyCommand:addParam{ type = ULib.cmds.PlayersArg }
propifyCommand:addParam{ type = ULib.cmds.StringArg, default = PROP_DEFAULT_MODEL, ULib.cmds.optional }
propifyCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
propifyCommand:defaultAccess( ULib.ACCESS_ADMIN )
propifyCommand:help( "Turns the target(s) into a prop with the given model." )
propifyCommand:setOpposite( "ulx unpropify", { _, _, _, true }, "!unpropify" )

local function propDisconnectedCheck( ply )
    if not ply.ragdoll then return end
    ply.ragdoll:DisallowDeleting( false )
    ply.ragdoll:Remove()
end
hook.Add( "PlayerDisconnected", "CFC_ULX_RemovePropifyRagdoll", propDisconnectedCheck, HOOK_MONITOR_HIGH )

local function removePropOnCleanup()
    local players = player.GetAll()
    for _, ply in pairs( players ) do
        if ply.ragdoll then
            ply.propifyAfterCleanup = true
            cmd.unpropifyPlayer( ply )
        end
    end
end
hook.Add( "PreCleanupMap", "CFC_ULX_RemovePropify", removePropOnCleanup )

local function createPropAfterCleanup()
    local players = player.GetAll()
    for _, ply in pairs( players ) do
        if ply.propifyAfterCleanup then
            ply.propifyAfterCleanup = nil
            timer.Simple( 0.1, function() propifyPlayer( ply ) end )
        end
    end
end
hook.Add( "PostCleanupMap", "CFC_ULX_PropAfterCleanup", createPropAfterCleanup )

--Player movement:
local function propHop( ply, keyNum )
    if not IsValid( ply.ragdoll ) then return end
    if ply.ragdoll.propifyNoHop then return end

    local prop = ply.ragdoll
    local isRagdoll = prop:GetClass() == "prop_ragdoll"
    ply.propifyLastHop = ply.propifyLastHop or 0

    if ply.propifyLastHop + HOP_COOLDOWN:GetFloat() > CurTime() then return end

    ply.propifyLastHop = CurTime()

    local phys = prop:GetPhysicsObject()
    local hopStrength = HOP_STRENGTH:GetFloat() * phys:GetMass()
    local eyeAngles = ply:EyeAngles()

    if isRagdoll then
        local boneID = prop:LookupBone( "ValveBiped.Bip01_Spine2" )

        if boneID then
            local physID = prop:TranslateBoneToPhysBone( boneID )
            phys = prop:GetPhysicsObjectNum( physID )
        end
    end

    if not phys then return end

    if keyNum == IN_FORWARD then
        phys:ApplyForceCenter( eyeAngles:Forward() * hopStrength )
    elseif keyNum == IN_BACK then
        phys:ApplyForceCenter( -eyeAngles:Forward() * hopStrength )
    elseif keyNum == IN_MOVERIGHT then
        phys:ApplyForceCenter( eyeAngles:Right() * hopStrength )
    elseif keyNum == IN_MOVELEFT then
        phys:ApplyForceCenter( -eyeAngles:Right() * hopStrength )
    elseif keyNum == IN_JUMP then
        phys:ApplyForceCenter( Vector( 0, 0, hopStrength ) )
    end
end
hook.Add( "KeyPress", "CFC_ULX_PropHop", propHop )

--Prevents ragdolled and propified players from pressing use on themselves, props, and vehicles
local function handleUse( ply, ent )
    if not ply.ragdoll then return end

    local isInitialCheck = false

    if ent == ply.ragdoll then
        isInitialCheck = true

        local _, boundMax = ent:GetModelBounds()
        local traceSettings = {
            start = ply:EyePos() + Vector( 0, 0, boundMax.z + 6 ), --Account for camera/eye position disconnect in prop specate
            endpos = ply:EyePos() + ply:EyeAngles():Forward()*250,
            filter = {
            	ply.ragdoll,
            	ply,
        	},
        }

        local trace = util.TraceLine( traceSettings )
        ent = trace.Entity
    end

    if not IsValid( ent ) then return false end

    local class = ent:GetClass()

    if class == "prop_physics" or ent:IsVehicle() then return false end

    if isInitialCheck then
        ent:Use( ply )

        return false
    end
end
hook.Add( "PlayerUse", "CFC_ULX_PropifyUse", handleUse, HOOK_HIGH )

local function detectPropifyPickup( ply, ent )
    local ragdolledPly = ent.ragdolledPly

    if not ragdolledPly then return end

    local struggleAmountMax = STRUGGLE_AMOUNT:GetInt()

    if struggleAmountMax == 0 then return end
    if ent.propifyCantGrab then return false end

    ragdolledPly:SetNWBool( "propifyGrabbed", true )
    ragdolledPly.propifyCanStruggle = true
    ent.propifyGrabber = ply

    local timerName = "CFC_ULX_PropifyStruggleDecay_" .. ragdolledPly:SteamID()

    timer.Create( timerName, STRUGGLE_DECAY:GetFloat(), 0, function()
        local stillPropified = IsValid( ent )
        local struggleAmount = 0

        if stillPropified then
            struggleAmount = ragdolledPly:GetNWInt( "propifyStruggle" )
        else
            timer.Remove( timerName )
            return
        end

        if struggleAmount == 0 then return end

        struggleAmount = math.max( struggleAmount - 1, 0 )

        ragdolledPly:SetNWInt( "propifyStruggle", struggleAmount )
    end )
end
hook.Add( "AllowPlayerPickup", "CFC_ULX_PropifyDetectPickup", detectPropifyPickup )
hook.Add( "GravGunPickupAllowed", "CFC_ULX_PropifyDetectPickup", detectPropifyPickup )

local function detectPropifyDrop( ply, ent )
    if not IsValid( ent ) then return end

    local ragdolledPly = ent.ragdolledPly

    if not IsValid( ragdolledPly ) then return end

    if ragdolledPly:GetNWBool( "propifyGrabbed" ) then
        ragdolledPly:SetNWBool( "propifyGrabbed", false )
        ent.ragdolledPly.propifyCanStruggle = nil
        ent.propifyGrabber = nil
    end
end
hook.Add( "OnPlayerPhysicsDrop", "CFC_ULX_PropifyDetectDrop", detectPropifyDrop )
hook.Add( "GravGunOnDropped", "CFC_ULX_PropifyDetectDrop", detectPropifyDrop )

local function struggle( ply, button )
    if button ~= IN_USE then return end

    if not ply.propifyCanStruggle then return end

    local struggleAmountMax = STRUGGLE_AMOUNT:GetInt()
    local struggleAmount = ply:GetNWInt( "propifyStruggle" )
    local prop = ply.ragdoll

    struggleAmount = math.min( struggleAmount + 1, struggleAmountMax )
    ply:SetNWInt( "propifyStruggle", struggleAmount )

    if struggleAmount >= struggleAmountMax then
        local grabber = prop.propifyGrabber

        DropEntityIfHeld( prop )

        timer.Remove( "CFC_ULX_PropifyStruggleDecay_" .. ply:SteamID() )

        prop:EmitSound( "physics/body/body_medium_impact_hard" .. math.random( 1, 6 ) .. ".wav" )

        local physObj = prop:GetPhysicsObject()

        if IsValid( physObj ) then
            local escapeStrength = STRUGGLE_STRENGTH:GetFloat() * physObj:GetMass()
            local escapeDir = grabber:EyeAngles()
            local escapeRand = STRUGGLE_FLEE_RANDOM:GetFloat()
            escapeDir:RotateAroundAxis( escapeDir:Up(), math.Rand( -1, 1 )*escapeRand )
            escapeDir:RotateAroundAxis( escapeDir:Right(), math.Rand( -1, 1 )*escapeRand )

            physObj:ApplyForceCenter( escapeDir:Forward() * escapeStrength )
        end

        prop.propifyCantGrab = true
        ply.propifyCanStruggle = nil
        prop.propifyGrabber = nil
        grabber:SetNWInt( "propifyStruggle", 0 )

        timer.Simple( STRUGGLE_SAFETY:GetFloat(), function()
            if IsValid( prop ) then
                prop.propifyCantGrab = nil
            end
        end )
    else
        prop:EmitSound( "physics/body/body_medium_impact_soft" .. math.random( 1, 7 ) .. ".wav" )

        timer.Simple( STRUGGLE_LIMIT:GetFloat(), function()
            local prop = ply.ragdoll

            if not IsValid( prop ) or not ply:GetNWBool( "propifyGrabbed" ) then return end

            ply.propifyCanStruggle = true
        end )
    end
end
hook.Add( "KeyPress", "CFC_ULX_PropifyStruggle", struggle )

--Prevents propify props from existing after being removed, including breakable props breaking
local function unpropifyOnRemove( prop )
    if not IsValid( prop.ragdolledPly ) then return end
    if not IsValid( prop.ragdolledPly.ragdoll ) then return end

    cmd.unpropifyPlayer( prop.ragdolledPly )
end
hook.Add( "EntityRemoved", "CFC_ULX_PropifyRemoveProp", unpropifyOnRemove )

--Prevents propified players from damaging other people
local function ignorePropifyDamage( victim, dmgInfo )
    if not IsValid( dmgInfo:GetAttacker().ragdolledPly ) then return end
    return true
end
hook.Add( "EntityTakeDamage", "CFC_ULX_PropifyIgnoreDamage", ignorePropifyDamage )
