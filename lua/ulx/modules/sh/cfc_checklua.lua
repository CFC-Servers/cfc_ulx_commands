CFCUlxCommands.checklua = CFCUlxCommands.checklua or {}
local cmd = CFCUlxCommands.checklua

CATEGORY_NAME = "Utility"

local callingPlayer
local targetPlayerss

local function askForConvar( ply )
    ply.waitingOnVar = true
    net.Start( "CFC_ULX_StatCheckCL" )
    net.Send( ply )
end

net.Receive( "CFC_ULX_StatCheckSV", function( _, ply )
    if not ply.waitingOnVar then return end
    local var = net.ReadBool()
    ply.waitingOnVar = false
    ulx.fancyLogAdmin( callingPlayer, true, "#T's sv_allowcslua value is " ..  tostring( var ), targetPlayerss )
end )
                    
function cmd.checkluaPlayers( calPlayer, targetPlayers )
    for _, ply in pairs( targetPlayers ) do
        callingPlayer = calPlayer
        targetPlayerss = targetPlayers
        askForConvar( ply )
    end
end

local checkluaCommand = ulx.command( CATEGORY_NAME, "ulx checklua", cmd.checkluaPlayers, "!checklua" )
checkluaCommand:addParam{ type = ULib.cmds.PlayersArg }
checkluaCommand:defaultAccess( ULib.ACCESS_ADMIN )
checkluaCommand:help( "Checks target(s) sv_allowcslua" )

if CLIENT then
    net.Receive( "CFC_ULX_StatCheckCL", function()
        local convarBool = GetConVar("sv_allowcslua"):GetBool()
        net.Start( "CFC_ULX_StatCheckSV" )
        net.WriteBool( convarBool )
        net.SendToServer()
    end )
end
