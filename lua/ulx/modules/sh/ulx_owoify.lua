local OWOIFYDICT = { na = "nya", ne = "nye", ni = "nyi", no = "nyo", nu = "nyu", ove = "uv", r = "w", l = "w" }

local function owoifyString( inputStr )
	for k, v in pairs( OWOIFYDICT ) do
		inputStr = string.lower( inputStr )
		inputStr = string.Replace( inputStr, k, v )
	end
	
	return inputStr
end

local function onPlayerSay( ply, inputStr )
	--if ply ~= player.GetByID( 3 ) then return end
	
	return owoifyString( inputStr )
end

hook.Add( "PlayerSay", "CFC_ULX_OwoifyString", onPlayerSay )