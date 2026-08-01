CFCUlxCommands.crucify = CFCUlxCommands.crucify or {}
local cmd = CFCUlxCommands.crucify

CATEGORY_NAME = "Fun"

function cmd.uncrucifyPlayer( ply )
    if not IsValid( ply ) then return "Invalid player!" end

    local cross = ply.cross
    ply.cross = nil

    local ragdoll = ply.ragdoll
    if IsValid( ragdoll ) then
        ulx.unragdollPlayer( ply )
    end

    if IsValid( cross ) then
        cross:Remove()
    end
end

local function crucifyPlayer( ply )
    if not IsValid( ply ) then return "Invalid player!" end

    ulx.ragdollPlayer( ply )
    local playerRagdoll = ply.ragdoll

    if not IsValid( playerRagdoll ) then return "Ragdoll failed" end

    local cross = ents.Create( "prop_physics" )
    cross:SetModel( "models/props_c17/gravestone_cross001a.mdl" )
    cross:SetPos( ply:GetPos() )

    local angles = ply:GetAngles()
    cross:SetAngles( angles )

    cross:Spawn()
    cross:Activate()

    local crossPhys = cross:GetPhysicsObject()
    crossPhys:SetMass( 1000 ) -- make it easier to move the ragdoll attached to the cross
    crossPhys:EnableMotion( false )

    ply.cross = cross
    cross.crucifiedPly = ply
    playerRagdoll.crucifiedPly = ply

    local phys_obj = playerRagdoll:GetPhysicsObjectNum( 1 )
    local boneID = 2

    while IsValid( phys_obj ) do
        phys_obj = playerRagdoll:GetPhysicsObjectNum( boneID )

        if phys_obj then
            phys_obj:SetPos( phys_obj:GetPos() + Vector( 0, 0, 80 ) + angles:Forward() * 10 )
        end
        boneID = boneID + 1
    end

    local rightHandID = playerRagdoll:LookupBone( "ValveBiped.Bip01_R_Hand" )
    local leftHandID = playerRagdoll:LookupBone( "ValveBiped.Bip01_L_Hand" )

    local rightHandPhys = playerRagdoll:TranslateBoneToPhysBone( rightHandID )
    local leftHandPhys = playerRagdoll:TranslateBoneToPhysBone( leftHandID )

    constraint.Weld( cross, playerRagdoll, 0, rightHandPhys, 0, false, false )
    constraint.Weld( cross, playerRagdoll, 0, leftHandPhys, 0, false, false )
end

function cmd.crucifyPlayers( caller, targets, shouldUncrucify )
    local affectedPlys = {}

    for _, ply in pairs( targets ) do
        if not shouldUncrucify then
            if ulx.getExclusive( ply, caller ) then
                ULib.tsayError( caller, ulx.getExclusive( ply, caller ), true )
            elseif not ply:Alive() then
                ULib.tsayError( caller, ply:Nick() .. " is dead and cannot be crucified!", true )
            else
                local err = crucifyPlayer( ply )

                if not err then
                    table.insert( affectedPlys, ply )
                else
                    ULib.tsayError( caller, err, true )
                end
            end
        elseif ply.cross then
            cmd.uncrucifyPlayer( ply )
            table.insert( affectedPlys, ply )
        end
    end

    if shouldUncrucify then
        ulx.fancyLogAdmin( caller, "#A uncrucified #T", affectedPlys )
    else
        ulx.fancyLogAdmin( caller, "#A crucified #T", affectedPlys )
    end
end

local crucifyCommand = ulx.command( CATEGORY_NAME, "ulx crucify", cmd.crucifyPlayers, "!crucify" )
crucifyCommand:addParam{ type = ULib.cmds.PlayersArg }
crucifyCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
crucifyCommand:defaultAccess( ULib.ACCESS_ADMIN )
crucifyCommand:help( "Crucifies target(s)" )
crucifyCommand:setOpposite( "ulx uncrucify", { _, _, true }, "!uncrucify" )

local function crucifyDisconnectedCheck( ply )
    if IsValid( ply.ragdoll ) then
        ply.ragdoll:DisallowDeleting( false )
        ply.ragdoll:Remove()
    end
    if IsValid( ply.cross ) then
        ply.cross:Remove()
    end
end
hook.Add( "PlayerDisconnected", "CFC_ULX_RemoveCrucifyRagdollAndCross", crucifyDisconnectedCheck, HOOK_MONITOR_HIGH )

local function uncrucifyOnCleanup()
    local players = player.GetAll()
    for _, ply in ipairs( players ) do
        if ply.cross then
            ply.crucifyAfterCleanup = true
            cmd.uncrucifyPlayer( ply )
        end
    end
end
hook.Add( "PreCleanupMap", "CFC_ULX_RemoveCrucify", uncrucifyOnCleanup )

local function crucifyAfterCleanup()
    local players = player.GetAll()
    for _, ply in ipairs( players ) do
        if ply.crucifyAfterCleanup then
            ply.crucifyAfterCleanup = nil
            timer.Simple( 0.1, function() crucifyPlayer( ply ) end )
        end
    end
end
hook.Add( "PostCleanupMap", "CFC_ULX_CrucifyAfterCleanup", crucifyAfterCleanup )

local function uncrucifyOnRemove( prop )
    if not IsValid( prop.crucifiedPly ) then return end

    cmd.uncrucifyPlayer( prop.crucifiedPly )
end
hook.Add( "EntityRemoved", "CFC_ULX_CrucifyRemoveProp", uncrucifyOnRemove )