local CATEGORY_TYPE = "Teleport"
local MIN_X, MIN_Y, MIN_Z = -16384, -16384, -16384
local MAX_X, MAX_Y, MAX_Z = 16384, 16384, 16384
local HULL_BUFFER = 2
local MAP_POSITION_DATA = {
    ["gm_bigcity"] = {
        centerZ = 14500 / 2 - 11400,
        height = 14500 / 2,
        fallback = Vector( 9192, 10270, -10897 ),
        offsetX = 900,
        offsetY = 1900
    },
    ["gm_bigcity_improved"] = {
        centerZ = 14500 / 2 - 11400,
        height = 14500 / 2,
        fallback = Vector( 9192, 10270, -10897 ),
        offsetX = 900,
        offsetY = 1900
    },
    ["gm_bigcity_improved_lite"] = {
        centerZ = 14500 / 2 - 11400,
        height = 14500 / 2,
        fallback = Vector( 9192, 10270, -10897 ),
        offsetX = 900,
        offsetY = 1900
    },
    ["gm_construct"] = {
        centerZ = 10500 / 2 - 500,
        height = 10500 / 2,
        fallback = Vector( -2069, -3316, -252 ),
        offsetX = 1000,
        offsetY = 500
    },
    ["gm_novenka"] = {
        centerZ = 12800 / 2 - 2050,
        height = 12800 / 2,
        fallback = Vector( 9760, -13800, -700 ),
        offsetX = 800,
        offsetY = 500
    },
    ["gm_bluehills_test3"] = {
        centerZ = 14400 / 2 - 1100,
        height = 14400 / 2,
        fallback = Vector( -8750, -8500, -1084 ),
        offsetX = 500,
        offsetY = 500
    }, 
    ["gm_flatgrass"] = {
        centerZ = 28200 / 2 - 12800,
        height = 28200 / 2,
        fallback = Vector( -700, 100, -12764 ),
        offsetX = 250,
        offsetY = 500
    }, 
    ["gm_functional_flatgrass"] = {
        centerZ = 28600 / 2 - 16300,
        height = 28600 / 2,
        fallback = Vector( 10500, -9400, -16252 ),
        offsetX = 3500,
        offsetY = 3500
    }, 
    ["gm_genesis"] = {
        centerZ = 27600 / 2 - 15300,
        height = 27600 / 2,
        fallback = Vector( 6800, 6500, -14974 ),
        offsetX = 600,
        offsetY = 600
    }
}

local function planTrip( ply )
    for _ = 1, 20 do
        local mapData = MAP_POSITION_DATA[game.GetMap()]
        local pos
        
        if mapData then
            pos = Vector( math.random( MIN_X, MAX_X ), math.random( MIN_Y, MAX_Y ), mapData.centerZ + math.random( -mapData.height, mapData.height ) )
        else
            pos = Vector( math.random( MIN_X, MAX_X ), math.random( MIN_Y, MAX_Y ), math.random( MIN_Z, MAX_Z ) )
        end
        
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

local brazilCommand = ulx.command( CATEGORY_TYPE, "ulx brazil", runBrazil, "!brazil" )
brazilCommand:addParam{ type = ULib.cmds.PlayersArg }
brazilCommand:defaultAccess( ULib.ACCESS_ADMIN )
brazilCommand:help( "Sends target(s) to a random location on the map." )

--Serious alias for brazil command
local randTpCommand = ulx.command( CATEGORY_TYPE, "ulx randtp", runRandTp, "!randtp" )
randTpCommand:addParam{ type = ULib.cmds.PlayersArg }
randTpCommand:defaultAccess( ULib.ACCESS_ADMIN )
randTpCommand:help( "Sends target(s) to a random location on the map." )