local OWOIFYDICT = { na = "nya", ne = "nye", ni = "nyi", no = "nyo", nu = "nyu", ove = "uv", r = "w", l = "w", U = "uwu" }

local function owoifyString( inputStr )
	for k, v in pairs( OWOIFYDICT ) do
		inputStr = string.Replace( inputStr, k, v )
	end
	
	return inputStr
end

local function onPlayerSay( ply, inputStr )	
	return owoifyString( inputStr )
end

local function stopULX_Owoify()
	print( "~ [ULX_Owoify]: Removing hook from server!`" )
	hook.Remove( "PlayerSay", "CFC_ULX_OwoifyString" )
end
	
hook.Add( "PlayerSay", "CFC_ULX_OwoifyString", onPlayerSay )
concommand.Add( "owoify_stop", stopULX_Owoify )

local owoifyCommand = ulx.command( "Fun", "ulx owoify", onPlayerSay, "!owoify" )
owoifyCommand:defaultAccess( ULib.ACCESS_ADMIN )
owoifyCommand:addParam{ type = ULib.cmds.PlayersArg }
owoifyCommand:help( "Owoifies target(s) so they are unable to chat normally." )

local owoifyCommand = ulx.command( "Fun", "ulx unowoify", onPlayerSay, "!unowoify" )
owoifyCommand:defaultAccess( ULib.ACCESS_ADMIN )
owoifyCommand:addParam{ type = ULib.cmds.PlayersArg }
owoifyCommand:help( "Unowoifies target(s) so they are able to chat normally." )