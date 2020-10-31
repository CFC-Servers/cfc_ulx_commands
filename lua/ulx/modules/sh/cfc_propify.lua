CFCUlxCommands = CFCUlxCommands or {} --remove later

CFCUlxCommands.propify = CFCUlxCommands.propify or {}
local cmd = CFCUlxCommands.propify

local CATEGORY_NAME = "Fun"
local PROP_MAX_SIZE = 100
local PROP_DEFAULT_MODEL = "models/props_c17/oildrum001.mdl"
local HOP_STRENGTH = 400
local HOP_COOLDOWN = 2

local function propifyPlayer( ply, modelPath )
    if not util.IsValidModel( modelPath ) then return true end
    
    if ply:InVehicle() then
        local vehicle = ply:GetParent()
        ply:ExitVehicle()
    end
    
    ULib.getSpawnInfo( ply )
    
    local prop = ents.Create( "prop_physics" )
    prop:SetModel( modelPath )
    
    if prop:BoundingRadius() > PROP_MAX_SIZE then
        prop:Remove()
        return false, true
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
    
    prop:DisallowDeleting( true, function( old, new )
        if ply:IsValid() then ply.prop = new end
    end )
    ply:DisallowSpawning( true )
    
    ply.ragdoll = prop
    ulx.setExclusive( ply, "ragdolled" )
    
    return false, false, prop
end

local function unpropifyPlayer( ply )
    ply:DisallowSpawning( false )
    ply:SetParent()

    ply:UnSpectate()

    local prop = ply.ragdoll
    ply.ragdoll = nil

    if not prop:IsValid() then
        ULib.spawn( ply, true )
    else
        local pos = prop:GetPos()
        pos.z = pos.z + 10
        
        ULib.spawn( ply, true )
        ply:SetPos( pos )
        ply:SetVelocity( prop:GetVelocity() )
        ply:SetAngles( Angle( 0, prop:GetAngles().yaw, 0 ) )
        prop:DisallowDeleting( false )
        prop:Remove()
    end
    
    ulx.clearExclusive( ply )
end

function cmd.propify( caller, targets, modelPath, shouldUnpropify )
    local affectedPlys = {}
    local invalidModel = false
    local prop
    
    for _, v in pairs( targets ) do
        if not shouldUnpropify then
            if ulx.getExclusive( v, caller ) then
                ULib.tsayError( caller, ulx.getExclusive( v, caller ), true )
            elseif not v:Alive() then
                ULib.tsayError( caller, v:Nick() .. " is dead and cannot be propified!", true )
            else
                invalidModel, propTooBig, prop = propifyPlayer( v, modelPath )
                
                if not ( invalidModel or propTooBig ) then
                    table.insert( affectedPlys, v )
                end
            end
        elseif v.ragdoll then
            unpropifyPlayer( v )
            table.insert( affectedPlys, v )
        end
    end
    
    if invalidModel then
        ULib.tsayError( caller, "Invalid model!", true )
        
        return
    end
    
    if propTooBig then
        ULib.tsayError( caller, "Model too big!", true )
        
        return
    end
    
    if not shouldUnpropify then
        ulx.fancyLogAdmin( caller, "#A propified #T", affectedPlys )
    else
        ulx.fancyLogAdmin( caller, "#A unpropified #T", affectedPlys )
    end
    
    return prop
end

local propifyCommand = ulx.command( CATEGORY_NAME, "ulx propify", cmd.propify, "!propify" )
propifyCommand:addParam{ type = ULib.cmds.PlayersArg }
propifyCommand:addParam{ type = ULib.cmds.StringArg, default = PROP_DEFAULT_MODEL, ULib.cmds.optional }
propifyCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
propifyCommand:defaultAccess( ULib.ACCESS_ADMIN )
propifyCommand:help( "Turns the target(s) into a prop with the given model." )
propifyCommand:setOpposite( "ulx unpropify", { _, _, _, true }, "!unpropify" )

local function propifySpawnCheck( ply )
    if ply.ragdoll then
        timer.Simple( 0.01, function()
            if not ply:IsValid() then return end
            ply:Spectate( OBS_MODE_CHASE )
            ply:SpectateEntity( ply.ragdoll )
            ply:StripWeapons()
        end )
    end
end
hook.Add( "PlayerSpawn", "CFC_ULXPropifySpawnCheck", propifySpawnCheck )

local function propDisconnectedCheck( ply )
    if ply.ragdoll then
        ply.ragdoll:DisallowDeleting( false )
        ply.ragdoll:Remove()
    end
end
hook.Add( "PlayerDisconnected", "CFC_ULXPropDisconnectedCheck", propDisconnectedCheck, HOOK_MONITOR_HIGH )

local function removePropOnCleanup()
    local players = player.GetAll()
    for _, v in pairs( players ) do
        if v.ragdoll then
            v.propifyAfterCleanup = true
            unpropifyPlayer( v )
        end
    end
end
hook.Add( "PreCleanupMap", "CFC_ULXPropBeforeCleanup", removePropOnCleanup )

local function createPropAfterCleanup()
    local players = player.GetAll()
    for _, v in pairs( players ) do
        if v.propifyAfterCleanup then
            v.propifyAfterCleanup = nil
            timer.Simple( 0.1, function() propifyPlayer( v ) end )
        end
    end
end
hook.Add( "PostCleanupMap", "CFC_ULXPropAfterCleanup", createPropAfterCleanup )

--Player movement:
local function propHop( ply, keyNum )
    if not ply.ragdoll or not ply.ragdoll:GetClass() == "prop_physics" then return end
    
    ply.propifiedlastPressed = ply.propifiedlastPressed or 0
    
    if ply.propifiedlastPressed + HOP_COOLDOWN > CurTime() then return end
    
    ply.propifiedlastPressed = CurTime()
    
    local phys = phys = ply.ragdoll:GetPhysicsObject()
    local hopStrength = HOP_STRENGTH * phys:GetMass()
    local eyeAngles = ply:EyeAngles()

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
hook.Add( "KeyPress", "CFC_ULXPropHop", propHop )

--Prevents propified players from picking themselves up
local function disallowGrab( ply, _ )
    if ply.ragdoll then return false end
    return true
end
hook.Add( "AllowPlayerPickup", "CFC_ULXPropifyDisallowGrab", disallowGrab )

--Prevents breakable props from existing after being broken
local function removePropOnBreak( _, prop )
    if not prop.ragdolledPly then return end
    cmd.propify( __, { prop.ragdolledPly }, __, true )
end
hook.Add( "PropBreak", "CFC_ULXPropifyRemoveProp", removePropOnBreak )

--Prevents propified players from damaging other people
local function ignorePropifyDamage( victim, dmgInfo )
    if not dmgInfo:GetAttacker().ragdolledPly then return end
    return true
end
hook.Add( "EntityTakeDamage", "CFC_ULXPropifyIgnoreDamage", ignorePropifyDamage )
