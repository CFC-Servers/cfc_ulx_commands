local MIN_X, MIN_Y, MIN_Z = -16384, -16384, -16384 / 2
local MAX_X, MAX_Y, MAX_Z = 16384, 16384, 16384 / 2
local mapPositionData = {
    ["gm_bigcity"] = {
        fallBack = Vector( 9192, 10270, -10897 ),
        offsetX = 100,
        offsetY = 200
    },
    ["gm_bigcity_improved"] = {
        fallBack = Vector( 9192, 10270, -10897 ),
        offsetX = 100,
        offsetY = 200
    },
    ["gm_bigcity_improved_lite"] = {
        fallBack = Vector( 9192, 10270, -10897 ),
        offsetX = 100,
        offsetY = 200
    },
    ["gm_construct"] = {
        fallBack = Vector( -2069, -3316, -252 ),
        offsetX = 1000,
        offsetY = 500
    },
    ["gm_novenka"] = {
        fallBack = Vector( 9760, -13800, -700 ),
        offsetX = 800,
        offsetY = 500
    },
    ["gm_bluehills"] = {
        fallBack = Vector( -8750, -8500, -1084 ),
        offsetX = 500,
        offsetY = 500
    },
    ["gm_bluehills_test3"] = {
        fallBack = Vector( -8750, -8500, -1084 ),
        offsetX = 500,
        offsetY = 500
    }, 
    ["gm_flatgrass"] = {
        fallBack = Vector( -700, 100, -12764 ),
        offsetX = 250,
        offsetY = 500
    }, 
    ["gm_functional_flatgrass"] = {
        fallBack = Vector( 10500, -9400, -16252 ),
        offsetX = 3500,
        offsetY = 3500
    }, 
    ["gm_genesis"] = {
        fallBack = Vector( 6800, 6500, -14974 ),
        offsetX = 600,
        offsetY = 600
    }
}

local function planTrip()
    for _ = 1, 20 do
        local pos = Vector( math.random( MIN_X, MAX_X ), math.random( MIN_Y, MAX_Y ), math.random( MIN_Z, MAX_Z ) )
        
        if util.IsInWorld( pos ) then
            local trace = util.TraceLine( { start = pos, endpos = pos + Vector( 0, 0, MIN_Z ) } )
            
            return trace["HitPos"] + Vector( 0, 0, 1 )
        end
    end
    
    local mapData = mapLocationData[game.GetMap()]
    
    if not mapData then return Vector( 0, 0, 0 ) end
    
    local fallback = mapData.fallback
    local offsetX = math.random( -mapData.offsetX, mapData.offsetX )
    local offsetY = math.random( -mapData.offsetY, mapData.offsetY )
    
    return fallback + Vector( offsetX, offsetY, 0 )
end

local function sendToBrazil( caller, targets )
    for k, v in pairs( targets ) do
        v:SetPos( planTrip )
    end
    
    ulx.fancyLogAdmin( caller, "#A sent #T to Brazil", targets )
end

local brazilCommand = ulx.command( "Fun", "ulx brazil", sendToBrazil, "!brazil" )
brazilCommand:addParam{ type = ULib.cmds.PlayersArg }
brazilCommand:defaultAccess( ULib.ACCESS_ADMIN )
brazilCommand:help( "Sends target(s) to a random location on the map." )

local brazilAlias = ulx.command( "Fun", "ulx randtp", sendToBrazil, "!randtp" )
brazilAlias:addParam{ type = ULib.cmds.PlayersArg }
brazilAlias:defaultAccess( ULib.ACCESS_ADMIN )
brazilAlias:help( "Sends target(s) to a random location on the map." )