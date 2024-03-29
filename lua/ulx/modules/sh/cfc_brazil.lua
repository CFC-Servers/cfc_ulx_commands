CFCUlxCommands.brazil = CFCUlxCommands.brazil or {}
local cmd = CFCUlxCommands.brazil

local CATEGORY_TYPE = "Teleport"
local MIN_X, MIN_Y, MIN_Z = -16384, -16384, -16384
local MAX_X, MAX_Y, MAX_Z = 16384, 16384, 16384
local MAX_TRIES = 20
local MAP_POSITION_DATA = {
    ["gm_bigcity"] = {
        centerZ = 14500 / 2 - 11400,
        playableHeight = 14500 / 2,
        fallback = Vector( 9192, 10270, -10897 ),
        offsetX = 900,
        offsetY = 1900
    },
    ["gm_bigcity_improved"] = {
        centerZ = 14500 / 2 - 11400,
        playableHeight = 14500 / 2,
        fallback = Vector( 9192, 10270, -10897 ),
        offsetX = 900,
        offsetY = 1900
    },
    ["gm_bigcity_improved_lite"] = {
        centerZ = 14500 / 2 - 11400,
        playableHeight = 14500 / 2,
        fallback = Vector( 9192, 10270, -10897 ),
        offsetX = 900,
        offsetY = 1900
    },
    ["gm_construct"] = {
        centerZ = 10500 / 2 - 500,
        playableHeight = 10500 / 2,
        fallback = Vector( -2069, -3316, -252 ),
        offsetX = 1000,
        offsetY = 500
    },
    ["gm_novenka"] = {
        centerZ = 12800 / 2 - 2050,
        playableHeight = 12800 / 2,
        fallback = Vector( 9760, -13800, -700 ),
        offsetX = 800,
        offsetY = 500
    },
    ["gm_bluehills_test3"] = {
        centerZ = 14400 / 2 - 1100,
        playableHeight = 14400 / 2,
        fallback = Vector( -8750, -8500, -1084 ),
        offsetX = 500,
        offsetY = 500
    },
    ["gm_flatgrass"] = {
        centerZ = 28200 / 2 - 12800,
        playableHeight = 28200 / 2,
        fallback = Vector( -700, 100, -12764 ),
        offsetX = 250,
        offsetY = 500
    },
    ["gm_functional_flatgrass"] = {
        centerZ = 28600 / 2 - 16300,
        playableHeight = 28600 / 2,
        fallback = Vector( 10500, -9400, -16252 ),
        offsetX = 3500,
        offsetY = 3500
    },
    ["gm_genesis"] = {
        centerZ = 27600 / 2 - 15300,
        playableHeight = 27600 / 2,
        fallback = Vector( 6800, 6500, -14974 ),
        offsetX = 600,
        offsetY = 600
    }
}

local function getRandomPos( caller, target )
    if not target:IsValid() then return "You can't send the console to brazil!" end
    if not target:Alive() then return target:Nick() .. " is dead!" end
    if ulx.getExclusive( target, caller ) then
        return ulx.getExclusive( target, caller )
    end

    if target:InVehicle() then
        target:ExitVehicle()
    end

    local mapData = MAP_POSITION_DATA[game.GetMap()]

    for _ = 1, MAX_TRIES do
        local pos = Vector( math.random( MIN_X, MAX_X ), math.random( MIN_Y, MAX_Y ), math.random( MIN_Z, MAX_Z ) )

        if mapData then
            pos.z = mapData.centerZ + math.random( -mapData.playableHeight, mapData.playableHeight )
        end

        if util.IsInWorld( pos ) then
            local minHull, maxHull = target:GetCollisionBounds()

            local validationTrace = util.TraceHull( {
                start = pos,
                endpos = pos,
                mins = minHull,
                maxs = maxHull
            } )

            if not validationTrace.Hit then
                local floorTrace = util.TraceHull( {
                    start = pos,
                    endpos = pos + Vector( 0, 0, MIN_Z ),
                    mins = minHull,
                    maxs = maxHull
                } )

                return nil, floorTrace.HitPos + Vector( 0, 0, 1 )
            end
        end
    end

    if not mapData then return nil, Vector( 0, 0, 0 ) end

    local fallback = mapData.fallback
    local randomOffset = VectorRand() * Vector( mapData.offsetX, mapdata.offsetY, 0 )

    return nil, fallback + randomOffset
end

local function sendToPos( caller, targets, message, doSlap )
    for _, ply in ipairs( targets ) do
        local err, pos = getRandomPos( caller, ply )

        if not err then
            ply.ulx_prevpos = ply:GetPos()
            ply.ulx_prevang = ply:EyeAngles()

            if doSlap then
                ULib.slap( ply, 0, 700, false )
                timer.Simple( 0.5, function()
                    if not IsValid( ply ) then return end
                    ply:SetPos( pos )
                end )
            else
                ply:SetPos( pos )
            end
        else
            ULib.tsayError( caller, err, true )
        end
    end

    ulx.fancyLogAdmin( caller, message, targets )
end

function cmd.runBrazil( caller, targets )
    sendToPos( caller, targets, "#A sent #T to Brazil", true )
end

function cmd.runRandTp( caller, targets )
    sendToPos( caller, targets, "#A randomly teleported #T", false )
end

local brazilCommand = ulx.command( CATEGORY_TYPE, "ulx brazil", cmd.runBrazil, "!brazil" )
brazilCommand:addParam{ type = ULib.cmds.PlayersArg }
brazilCommand:defaultAccess( ULib.ACCESS_ADMIN )
brazilCommand:help( "Sends target(s) to a random location on the map." )

--Serious alias for brazil command
local randTpCommand = ulx.command( CATEGORY_TYPE, "ulx randtp", cmd.runRandTp, "!randtp" )
randTpCommand:addParam{ type = ULib.cmds.PlayersArg }
randTpCommand:defaultAccess( ULib.ACCESS_ADMIN )
randTpCommand:help( "Sends target(s) to a random location on the map." )
