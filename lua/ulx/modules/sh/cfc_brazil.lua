local MIN_X, MIN_Y, MIN_Z = -16384, -16384, -16384 / 2
local MAX_X, MAX_Y, MAX_Z = 16384, 16384, 16384 / 2
local HULL_BUFFER = 5
local MAP_POSITION_DATA = {
    ["gm_bigcity"] = {
        fallback = Vector( 9192, 10270, -10897 ),
        offsetX = 100,
        offsetY = 200
    },
    ["gm_bigcity_improved"] = {
        fallback = Vector( 9192, 10270, -10897 ),
        offsetX = 100,
        offsetY = 200
    },
    ["gm_bigcity_improved_lite"] = {
        fallback = Vector( 9192, 10270, -10897 ),
        offsetX = 100,
        offsetY = 200
    },
    ["gm_construct"] = {
        fallback = Vector( -2069, -3316, -252 ),
        offsetX = 1000,
        offsetY = 500
    },
    ["gm_novenka"] = {
        fallback = Vector( 9760, -13800, -700 ),
        offsetX = 800,
        offsetY = 500
    },
    ["gm_bluehills"] = {
        fallback = Vector( -8750, -8500, -1084 ),
        offsetX = 500,
        offsetY = 500
    },
    ["gm_bluehills_test3"] = {
        fallback = Vector( -8750, -8500, -1084 ),
        offsetX = 500,
        offsetY = 500
    }, 
    ["gm_flatgrass"] = {
        fallback = Vector( -700, 100, -12764 ),
        offsetX = 250,
        offsetY = 500
    }, 
    ["gm_functional_flatgrass"] = {
        fallback = Vector( 10500, -9400, -16252 ),
        offsetX = 3500,
        offsetY = 3500
    }, 
    ["gm_genesis"] = {
        fallback = Vector( 6800, 6500, -14974 ),
        offsetX = 600,
        offsetY = 600
    }
}

local function planTrip( ply )
    for _ = 1, 20 do
        local pos = Vector( math.random( MIN_X, MAX_X ), math.random( MIN_Y, MAX_Y ), math.random( MIN_Z, MAX_Z ) )
        
        if util.IsInWorld( pos ) then
            local minHullSize, maxHullSize = ply:GetCollisionBounds()
            local minHull = Vector( minHullSize.x - HULL_BUFFER, minHullSize.y - HULL_BUFFER, 0 )
            local maxHull = Vector( maxHullSize.x + HULL_BUFFER, maxHullSize.y + HULL_BUFFER, 0.001 )
            
            local validationTrace = util.TraceHull( {
                start = pos,
                endpos = pos + Vector( 0, 0, maxHullSize.z ),
                mins = minHull,
                maxs = maxHull
            } )
            
            if not validationTrace["Hit"] then
                local floorTrace = util.TraceHull( {
                    start = pos,
                    endpos = pos + Vector( 0, 0, MIN_Z ),
                    mins = minHull,
                    maxs = maxHull
                } )
                
                return floorTrace["HitPos"] + Vector( 0, 0, 1 )
            end
        end
    end
    
    local mapData = MAP_POSITION_DATA[game.GetMap()]
    
    if not mapData then return Vector( 0, 0, 0 ) end
    
    local fallback = mapData.fallback
    local offsetX = math.random( -mapData.offsetX, mapData.offsetX )
    local offsetY = math.random( -mapData.offsetY, mapData.offsetY )
    
    return fallback + Vector( offsetX, offsetY, 0 )
end

local function sendToPos( caller, targets, message )
    for k, v in pairs( targets ) do
        v:SetPos( planTrip( v ) )
    end
    
    ulx.fancyLogAdmin( caller, message, targets )
end

local function runBrazil( caller, targets )
    sendToPos( caller, targets, "#A sent #T to Brazil" )
end

local function runRandTp( caller, targets )
    sendToPos( caller, targets, "#A randomly teleported #T" )
end

local brazilCommand = ulx.command( "Fun", "ulx brazil", runBrazil, "!brazil" )
brazilCommand:addParam{ type = ULib.cmds.PlayersArg }
brazilCommand:defaultAccess( ULib.ACCESS_ADMIN )
brazilCommand:help( "Sends target(s) to a random location on the map." )

--Serious alias for brazil command
local randTpCommand = ulx.command( "Fun", "ulx randtp", runRandTp, "!randtp" )
randTpCommand:addParam{ type = ULib.cmds.PlayersArg }
randTpCommand:defaultAccess( ULib.ACCESS_ADMIN )
randTpCommand:help( "Sends target(s) to a random location on the map." )