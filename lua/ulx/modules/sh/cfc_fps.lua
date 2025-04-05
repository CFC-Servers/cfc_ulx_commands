CFCUlxCommands.fpsChecker = CFCUlxCommands.fpsChecker or {}
local cmd = CFCUlxCommands.fpsChecker
local CurTime = CurTime

local CATEGORY_NAME = "Utility"
local DEFAULT_DURATION = 10
local MAX_DURATION = 60

if SERVER then
    util.AddNetworkString( "CFC_ULX_FPSCheck" )
    util.AddNetworkString( "CFC_ULX_FPSCheck_ConsoleResults" )
end

if CLIENT then

    local color_white, color_red, color_green = Color( 255, 255, 255 ), Color( 255, 0, 0 ), Color( 0, 255, 0 )
    local header = "------------------------------------------------------------"

    local function colorForFPS( fps )
        local color = color_white
        if fps < 30 then
            color = color_red

        elseif fps > 75 then
            color = color_green

        end
        return color

    end

    net.Receive( "CFC_ULX_FPSCheck_ConsoleResults", function()
        local results = net.ReadTable()
        MsgC( color_white, header, "\n" )
        for ply, data in pairs( results ) do
            local plyColor = team.GetColor( ply:Team() )
            MsgC( plyColor, ply:Name(), color_white, "  Average FPS: ", colorForFPS( data.average ), data.average, color_white, "  Max: ", colorForFPS( data.best ), data.best, color_white, "  Worst: ", colorForFPS( data.worst ), data.worst, "\n" )
        end
        MsgC( color_white, header, "\n" )
    end )

    local function processAndSendBackFPS( allTheFPS )
        if table.Count( allTheFPS ) <= 0 then return end

        local count = 0
        local averageFPS = 0
        local bestFPS = 0
        local worstFPS = math.huge

        for _, currentFps in ipairs( allTheFPS ) do
            count = count + 1
            averageFPS = averageFPS + currentFps
            bestFPS = currentFps > bestFPS and currentFps or bestFPS
            worstFPS = currentFps < worstFPS and currentFps or worstFPS
        end

        averageFPS = averageFPS / count

        averageFPS = math.Round( averageFPS, 2 )
        bestFPS = math.Round( bestFPS, 2 )
        worstFPS = math.Round( worstFPS, 2 )

        net.Start( "CFC_ULX_FPSCheck" )
            net.WriteInt( averageFPS, 16 )
            net.WriteInt( bestFPS, 16 )
            net.WriteInt( worstFPS, 16 )
        net.SendToServer()

        print( "!fps; sent tracked fps. Average " .. averageFPS .. ". Best " .. bestFPS .. ". Worst " .. worstFPS )

        allTheFPS = nil
    end

    local timerName = "cfc_ulx_fps_tracker"
    local function trackFpsFor( trackTime )
        print( "!fps; tracking fps for " .. trackTime .. " seconds")

        local allDoneTime = CurTime() + trackTime
        local allTheFPS = {}
        local gotData

        timer.Create( timerName, 0.1, 0, function()
            if allDoneTime < CurTime() then
                if gotData then
                    processAndSendBackFPS( allTheFPS )
                else
                    print( "!fps; got no fps data, client was tabbed out" )
                end

                timer.Remove( timerName )
                return
            end

            if not system.HasFocus() then return end -- junk data

            local fps = 1 / RealFrameTime()
            table.insert( allTheFPS, fps )
            gotData = true
        end )
    end

    net.Receive( "CFC_ULX_FPSCheck", function()
        local trackTime = net.ReadInt( 16 )
        trackFpsFor( trackTime )
    end )
end

if SERVER then
    local wiggleRoom = 2

    local nextFpsCall = 0
    local recievedFpsData
    local expectingRecievers = {}

    net.Receive( "CFC_ULX_FPSCheck", function( _, ply )
        if not expectingRecievers[ply] then return end
        expectingRecievers[ply] = nil

        if nextFpsCall < CurTime() then print( nextFpsCall ) return end

        local averageFPS = net.ReadInt( 16 )
        local bestFPS = net.ReadInt( 16 )
        local worstFPS = net.ReadInt( 16 )
        recievedFpsData[ply] = { average = averageFPS, best = bestFPS, worst = worstFPS }
    end )

    function cmd.startFPSCheck( caller, targetPlys, duration )
        recievedFpsData = {}
        for _, ply in pairs( targetPlys ) do
            expectingRecievers[ply] = true

        end
        net.Start( "CFC_ULX_FPSCheck" )
            net.WriteInt( duration, 16 )
        net.Send( targetPlys )

        timer.Simple( duration + wiggleRoom, function()
            cmd.assembleAndYapFPSData( caller, targetPlys )
            recievedFpsData = nil
            expectingRecievers = {}
        end )
    end

    function cmd.checkFPS( caller, targetPlys, duration )
        if nextFpsCall > CurTime() then return end
        nextFpsCall = CurTime() + duration + ( wiggleRoom * 1.25 )

        duration = duration or DEFAULT_DURATION

        cmd.startFPSCheck( caller, targetPlys, duration )

        ulx.fancyLogAdmin( caller, "#A started an FPS check for #T", targetPlys )
    end

    function cmd.assembleAndYapFPSData( caller, targetPlys )
        if not recievedFpsData then return end
        if table.Count( recievedFpsData ) <= 0 then return end

        local count = 0
        local everyonesAverage = 0
        local bestFPS
        local worstFPS
        for _, data in pairs( recievedFpsData ) do
            count = count + 1
            everyonesAverage = everyonesAverage + data.average
            if not bestFPS or data.best > bestFPS.best then
                bestFPS = data
            end
            if not worstFPS or data.worst < worstFPS.worst then
                worstFPS = data
            end
        end
        everyonesAverage = everyonesAverage / count

        ulx.fancyLogAdmin( caller, "#A's FPS check completed. \nAverage: " .. everyonesAverage .. "\nBest: " .. bestFPS.best .. "\nWorst: " .. worstFPS.worst, targetPlys )

        if not caller:IsAdmin() then return end

        table.sort( recievedFpsData, function( a, b )
            return a.average > b.average
        end )

        net.Start( "CFC_ULX_FPSCheck_ConsoleResults" )
            net.WriteTable( recievedFpsData )
        net.Send( caller )

        timer.Simple( 0, function()
            caller:ChatPrint( "Open your console to see extended results." )
        end )
    end
end


local fpsCommand = ulx.command( CATEGORY_NAME, "ulx fps", cmd.checkFPS, "!fps" )
fpsCommand:addParam{ type = ULib.cmds.PlayersArg }
fpsCommand:addParam{ type = ULib.cmds.NumArg, default = DEFAULT_DURATION, min = 1, max = MAX_DURATION, ULib.cmds.optional, ULib.cmds.allowTimeString }
fpsCommand:defaultAccess( ULib.ACCESS_ADMIN )
fpsCommand:help( "Gets and prints the FPS of everyone" )