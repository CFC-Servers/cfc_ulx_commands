local MIN_X, MIN_Y, MIN_Z = -16384, -16384, -16384
local MAX_X, MAX_Y, MAX_Z = 16384, 16384, 16384
local HULL_SIZE = Vector( 32, 32, 72 )

local function tripAdvise()
	for _ = 1, 20 do
		local pos = Vector( math.random( MIN_X, MAX_X ), math.random( MIN_Y, MAX_Y ), math.random( MIN_Z, MAX_Z ) )
		
		if util.IsInWorld( pos ) then
			local trace = util.TraceLine( { start = pos, endpos = pos + Vector( 0, 0, MIN_Z*2 ) } )
			return true, trace["HitPos"] + Vector( 0, 0, 1 )
		end
	end
	
	return false, nil
end

local function sendToBrazil( players )
	for k, v in pairs( players ) do
		local isValid, pos = tripAdvise()
		
		if isValid then
			v:SetPos( pos )
		elseif string.find( game.GetMap(), "gm_bigcity" ) ~= nil then
			v:SetPos( Vector( 9192, 10270, -10897 ) + Vector( math.random( -100, 100 ), math.random( -200, 200 ), 0 ) )
		else
			v:SetPos( Vector( 0, 0, 0 ) )
		end
	end
end

local brazilCommand = ulx.command( "Fun", "ulx brazil", sendToBrazil, "!brazil" )
brazilCommand:addParam{ type = ULib.cmds.PlayersArg }
brazilCommand:defaultAccess( ULib.ACCESS_ADMIN )
brazilCommand:help( "Sends targert(s) to a random location on the map." )

local brazilAlias = ulx.command( "Fun", "ulx randtp", sendToBrazil, "!randtp" )
brazilAlias:addParam{ type = ULib.cmds.PlayersArg }
brazilAlias:defaultAccess( ULib.ACCESS_ADMIN )
brazilAlias:help( "Sends targert(s) to a random location on the map." )