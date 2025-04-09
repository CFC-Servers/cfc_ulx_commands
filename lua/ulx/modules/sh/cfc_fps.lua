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
        MsgC( color_white, "Extended !fps results visible only to you.", "\n" ) -- make it clear
        MsgC( color_white, header, "\n" )
        for ply, data in SortedPairsByMemberValue( results, "average" ) do
            local plyColor = team.GetColor( ply:Team() )
            MsgC( plyColor, ply:Name(), color_white, "\nAverage FPS: ", colorForFPS( data.average ), data.average, color_white, "  Max: ", colorForFPS( data.best ), data.best, color_white, "  Worst: ", colorForFPS( data.worst ), data.worst, "\n" )
        end
        MsgC( color_white, header, "\n" )
    end )

    local timerName = "cfc_ulx_fps_tracker"
    local function trackFpsFor( trackTime )
        print( "!fps; tracking fps for " .. trackTime .. " seconds" )

        local allDoneTime = CurTime() + trackTime
        local gotData

        local runningSum = 0
        local addCount = 0
        local bestFPS = 0
        local worstFPS = math.huge

        timer.Create( timerName, 0.1, 0, function()
            if allDoneTime < CurTime() then
                if not gotData then
                    print( "!fps; got no fps data, client was probably tabbed out" )
                else
                    local averageFPS = runningSum / addCount

                    averageFPS = math.Round( averageFPS, 2 )
                    bestFPS = math.Round( bestFPS, 2 )
                    worstFPS = math.Round( worstFPS, 2 )

                    net.Start( "CFC_ULX_FPSCheck" )
                        net.WriteInt( averageFPS, 16 )
                        net.WriteInt( bestFPS, 16 )
                        net.WriteInt( worstFPS, 16 )
                    net.SendToServer()

                    -- debug print, also tells power users what's happening
                    print( "!fps; sent tracked fps. Average " .. averageFPS .. ". Best " .. bestFPS .. ". Worst " .. worstFPS )
                end

                timer.Remove( timerName )
                return
            end

            if not system.HasFocus() then return end -- junk data

            local fpsRightNow = 1 / RealFrameTime()

            runningSum = runningSum + fpsRightNow
            addCount = addCount + 1

            if fpsRightNow > bestFPS then bestFPS = fpsRightNow end
            if fpsRightNow < worstFPS then worstFPS = fpsRightNow end

            gotData = true
        end )
    end

    net.Receive( "CFC_ULX_FPSCheck", function()
        local trackTime = net.ReadInt( 16 )
        trackFpsFor( trackTime )
    end )
end

if SERVER then
    local wiggleRoom = 1
    local userFpsCallInterval = MAX_DURATION -- this command's results can get rather wordy, dont let non-admins do it all the time

    local nextFpsCall = 0
    local nextUserFPSCall = 0
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
            cmd.assembleAndYapFPSData( caller, duration, targetPlys )
        end )
    end

    function cmd.checkFPS( caller, targetPlys, duration )
        local cur = CurTime()
        if nextFpsCall > cur then
            local waitSeconds = math.ceil( math.abs( cur - nextFpsCall ) )
            ULib.tsayError( caller, "Please wait " .. waitSeconds .. " seconds for the current !fps to finish.", true )
            return
        end
        if not caller:IsAdmin() and nextUserFPSCall > CurTime() then
            local waitSeconds = math.ceil( math.abs( cur - nextUserFPSCall ) )
            ULib.tsayError( caller, "The !fps command was just ran! Wait " .. waitSeconds .. " seconds!", true )
            return
        end

        nextFpsCall = cur + duration + ( wiggleRoom * 1.25 )
        nextUserFPSCall = cur + userFpsCallInterval

        duration = duration or DEFAULT_DURATION

        cmd.startFPSCheck( caller, targetPlys, duration )

        ulx.fancyLogAdmin( caller, "#A started a #s second FPS check for #T", duration, targetPlys )
    end

    function cmd.assembleAndYapFPSData( caller, duration, targetPlys )
        if not recievedFpsData then return end
        if table.Count( recievedFpsData ) <= 0 then return end

        local count = 0
        local everyonesAverage = 0
        local bestAverageFPS
        local worstAverageFPS
        local bestFPS
        local worstFPS
        for _, data in pairs( recievedFpsData ) do
            count = count + 1
            local currAverage = data.average
            everyonesAverage = everyonesAverage + currAverage
            if not bestAverageFPS or currAverage > bestAverageFPS.average then
                bestAverageFPS = data
            end
            if not worstAverageFPS or currAverage < worstAverageFPS.average then
                worstAverageFPS = data
            end
            if not bestFPS or data.best > bestFPS.best then
                bestFPS = data
            end
            if not worstFPS or data.worst < worstFPS.worst then
                worstFPS = data
            end
        end

        everyonesAverage = everyonesAverage / count
        everyonesAverage = math.Round( everyonesAverage, 2 )

        local msg = "#A's #s second FPS check of #T completed!\nAverage FPS was: #s"
        local best
        local worst
        if count > 1 then -- this is how people expect it to work, show best/worst averages when targeting multiple people
            best = bestAverageFPS.average
            worst = worstAverageFPS.average
            msg = msg .. "\nBest average was: #s And worst average: #s"
        else -- show best/worst ever if just on one person
            best = bestFPS.best
            worst = worstFPS.worst
            msg = msg .. "\nBest was: #s And worst: #s"
        end

        ulx.fancyLogAdmin( caller, msg, duration, targetPlys, everyonesAverage, best, worst, targetPlys )

        if not caller:IsAdmin() then return end -- dont let users see the deets, someone is gonna harass people with trash pcs eventually lol

        timer.Simple( 0.01, function() -- needs to be 0.01 to be in right order
            if IsValid( caller ) then
                caller:ChatPrint( "(Open your console to see extended results.)" )
                net.Start( "CFC_ULX_FPSCheck_ConsoleResults" )
                    net.WriteTable( recievedFpsData )
                net.Send( caller )
            end

            recievedFpsData = nil
            expectingRecievers = {}
        end )
    end
end


local fpsCommand = ulx.command( CATEGORY_NAME, "ulx fps", cmd.checkFPS, "!fps" )
fpsCommand:addParam{ type = ULib.cmds.PlayersArg }
fpsCommand:addParam{ type = ULib.cmds.NumArg, default = DEFAULT_DURATION, min = 1, max = MAX_DURATION, ULib.cmds.optional, ULib.cmds.allowTimeString }
fpsCommand:defaultAccess( ULib.ACCESS_ALL )
fpsCommand:help( "Gets and prints the FPS of everyone" )