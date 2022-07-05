CFCUlxCommands.decals = CFCUlxCommands.decals or {}
local cmd = CFCUlxCommands.decals

local entsToClear = {
    ["class C_ClientRagdoll"] = true,
}

if CLIENT then
    net.Receive( "ulx_clean_decals", function()
        for _,ent in pairs( ents.GetAll() ) do
            if entsToClear[ent:GetClass()] then
                ent:Remove()
            end
        end
    end )
else
    util.AddNetworkString( "ulx_clean_decals" )
end

function cmd.decals( callingPlayer )
    for _, ply in ipairs( player.GetHumans() ) do
        ply:ConCommand( "r_cleardecals" )

        net.Start( "ulx_clean_decals" )
        net.Broadcast()
    end

    ulx.fancyLogAdmin( callingPlayer, "#A cleaned up decals." )
end

local decalsCommand = ulx.command( "Utility", "ulx decals", cmd.decals, "!decals" )
decalsCommand:defaultAccess( ULib.ACCESS_ADMIN )
decalsCommand:help( "Cleans up all decals and ragdolls in the server." )
