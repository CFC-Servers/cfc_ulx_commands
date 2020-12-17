CFCUlxCommands.checklua = CFCUlxCommands.checklua or {}
local cmd = CFCUlxCommands.checklua

local CATEGORY_NAME = "Utility"

if SERVER then
    util.AddNetworkString( "CFC_ULX_StatCheckCL" )
    util.AddNetworkString( "CFC_ULX_StatCheckSV" )
end

local awaitingResponse = {}

net.Receive( "CFC_ULX_StatCheckSV", function( _, ply )
    if not awaitingResponse[ply] then return end
    local convar = net.ReadBool()
    ulx.fancyLogAdmin( awaitingResponse[ply], true, "#T's sv_allowcslua value is " .. tostring( convar ), ply )

    awaitingResponse[ply] = nil
end )

function cmd.checkluaPlayers( callingPlayer, targetPlayers )
    for _, ply in pairs( targetPlayers ) do
        awaitingResponse[ply] = callingPlayer
        net.Start( "CFC_ULX_StatCheckCL" )
        net.Send( ply )
    end
end

if CLIENT then
    net.Receive( "CFC_ULX_StatCheckCL", function()
        local convarBool = GetConVar( "sv_allowcslua" ):GetBool()
        net.Start( "CFC_ULX_StatCheckSV" )
        net.WriteBool( convarBool )
        net.SendToServer()
    end )
end

local checkluaCommand = ulx.command( CATEGORY_NAME, "ulx checklua", cmd.checkluaPlayers, "!checklua" )
checkluaCommand:addParam{ type = ULib.cmds.PlayersArg }
checkluaCommand:defaultAccess( ULib.ACCESS_ADMIN )
checkluaCommand:help( "Checks target(s) sv_allowcslua, true means they modified their client value." )
