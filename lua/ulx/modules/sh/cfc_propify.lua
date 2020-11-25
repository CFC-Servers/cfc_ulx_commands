CFCUlxCommands.propify = CFCUlxCommands.propify or {}
local cmd = CFCUlxCommands.propify

local CATEGORY_NAME = "Fun"
local PROP_DEFAULT_MODEL = "models/props_c17/oildrum001.mdl"
local PROP_MAX_SIZE = CreateConVar( "cfc_ulx_propify_max_size", 150, FCVAR_NONE, "The max radius allowed for propify models (default 150)", 0, 50000 )
local HOP_STRENGTH = CreateConVar( "cfc_ulx_propify_hop_strength", 400, FCVAR_NONE, "The strength of propify hops (default 400)", 0, 50000 )
local HOP_COOLDOWN = CreateConVar( "cfc_ulx_propify_hop_cooldown", 2, FCVAR_NONE, "The cooldown between propify hops in seconds (default 2)", 0, 50000 )

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

local function propifySpawnCheck( ply )
    if not ply.ragdoll then return end
    timer.Simple( 0.01, function()
        if not ply:IsValid() then return end
        ply:Spectate( OBS_MODE_CHASE )
        ply:SpectateEntity( ply.ragdoll )
        ply:StripWeapons()
    end )
end
hook.Add( "PlayerSpawn", "CFC_ULX_PropifySpawnCheck", propifySpawnCheck )

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

--Prevents ragdolled and propified players from pressing use on anything
local function disallowGrab( ply, _ )
    if ply.ragdoll then return false end
end
hook.Add( "PlayerUse", "CFC_ULX_PropifyDisallowGrab", disallowGrab, HOOK_HIGH )

--Prevents propify props from existing after being removed, including breakable props breaking
local function unpropifyOnRemove( prop )
    if not IsValid( prop.ragdolledPly ) then return end
    cmd.unpropifyPlayer( prop.ragdolledPly )
end
hook.Add( "EntityRemoved", "CFC_ULX_PropifyRemoveProp", unpropifyOnRemove )

--Prevents propified players from damaging other people
local function ignorePropifyDamage( victim, dmgInfo )
    if not IsValid( dmgInfo:GetAttacker().ragdolledPly ) then return end
    return true
end
hook.Add( "EntityTakeDamage", "CFC_ULX_PropifyIgnoreDamage", ignorePropifyDamage )
