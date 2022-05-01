CFCUlxCommands.ropeClean = CFCUlxCommands.ropeClean or {}
local cmd = CFCUlxCommands.ropeClean

function cmd.changeName( callingPlayer, targetPlayer, newName )
    ulx.fancyLogAdmin( callingPlayer, "#A changed name for #T to " .. newName )
end

local changeName = ulx.command( CATEGORY_NAME, "ulx forcename", cmd.changeName, "!forcename" )
ropes:addParam{ type = ULib.cmds.PlayerArg }
ropes:addParam{ type = ULib.cmds.StringArg }
ropes:defaultAccess( ULib.ACCESS_ADMIN )
ropes:help( "Change name" )
