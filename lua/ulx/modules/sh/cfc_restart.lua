CATEGORY_NAME = "CFC"

local function restartServer()
    local restartToken = file.Read( "cfc/restart/token.txt", "DATA" )

    http.Post( RestartUrl, { ["RestartToken"] = restartToken }, handleSuccessfulRestart, handleFailedRestart )
end

local function restartCommand( delay )

local cfcRestart = ulx.command( CATEGORY_NAME, "ulx cfcrestart", restartCommand, "!cfcrestart" )
cfcRestart:addParam{ type=ULib.cmds.NumArg, hint="seconds, 0 for immediate", ULib.cmds.allowTimeString, min=0 }
cfcRestart:defaultAccess( ULib.ACCESS_SUPERADMIN )
cfcRestart:help( "Restarts the server after a given delay" )
