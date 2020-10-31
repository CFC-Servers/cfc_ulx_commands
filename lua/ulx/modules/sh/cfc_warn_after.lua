CFCUlxCommands.warnAfter = CFCUlxCommands.warnAfter or {}
local cmd = CFCUlxCommands.warnAfter

local CATEGORY_NAME = "Utility"

function cmd.warnban( calling_ply, target_ply, minutes, reason )
    ulx.ban( calling_ply, target_ply, minutes, reason )
    local command = string.format( 'awarn_warn \"%s" "%s (%s ban)" ', target_ply:SteamID(), reason, ULib.secondsToStringTime( minutes*60 ) )
    calling_ply:ConCommand( command ) 
end
local ban = ulx.command( CATEGORY_NAME, "ulx warnban", cmd.warnban, "!warnban", false, false, true )
ban:addParam{ type=ULib.cmds.PlayerArg }
ban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
ban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
ban:defaultAccess( ULib.ACCESS_ADMIN )
ban:help( "Bans target and warns them." )

local function cmd.warnkick( calling_ply, target_ply, reason )
    ulx.kick( calling_ply, target_ply, reason )
    local command = string.format( 'awarn_warn \"%s" "%s (kick)" ', target_ply:SteamID(), reason )
    calling_ply:ConCommand( command ) 
end
local kick = ulx.command( CATEGORY_NAME, "ulx warnkick", cmd.warnkick, "!warnkick" )
kick:addParam{ type=ULib.cmds.PlayerArg }
kick:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
kick:defaultAccess( ULib.ACCESS_ADMIN )
kick:help( "Kicks target and warns them." )
