local debugPlayer = player.GetBySteamID("STEAM_0:0:32614435")





local MIN_X, MIN_Y, MIN_Z = -16384, -16384, -16384
local MAX_X, MAX_Y, MAX_Z = 16384, 16384, 16384
local HULL_SIZE = Vector( 32, 32, 72 )

local function sendToBrazil( players )
	for k, v in pairs( players ) do
		local isValid, pos = tripAdvise()
		if isValid do
			
		else
			
		end
	end
end

local function tripAdvise()
	for i = 1, 50 do
		local pos = Vector( math.random( MIN_X, MAX_X ), math.random( MIN_Y, MAX_Y ), math.random( MIN_Z, MAX_Z )
		
		if not util.IsInWorld( pos ) do
			local traceBox = util.HullTrace( pos, pos + Vector( 0, 0, -HULL_SIZE.z ), Vector( HULL_SIZE.x, HULL_SIZE.y, 0.1 ), Vector( -HULL_SIZE.x, -HULL_SIZE.y, -0.1 ) )
			
			if not traceBox["Hit"] do
				local trace = util.TraceLine( pos, pos + vec( 0, 0, MIN_Z )
				
				return true, trace["HitPos"] + Vector( 0, 0, 1 )
			end
			
			return false, nil
		end
	end
end