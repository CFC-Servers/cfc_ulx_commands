CFCUlxCommands.fpsFixer = CFCUlxCommands.fpsFixer or {}
local cmd = CFCUlxCommands.fpsFixer
local CurTime = CurTime

local CATEGORY_NAME = "Utility"
local DEFAULT_TARGET = 30
local MIN_TARGET = 25
local MAX_TARGET = 1000 -- 100

if CLIENT then

    local FIX_CHECK_INTERVAL = 15
    local fixes = { -- applied top-to-bottom
        {
            prettyDescription = "Disabling PAC3.", -- becomes, Fixing FPS by... Disabling PAC3.
            cmd = "pac_enable",
            fixedState = "0",
        },
        {
            prettyDescription = "Disabling Outfitter.",
            cmd = "outfitter_enabled",
            fixedState = "0",
        },
        {
            prettyDescription = "Disabling water reflections.",
            cmd = "r_WaterDrawReflection",
            fixedState = "0",
        },
        {
            prettyDescription = "Disabling Tank Tracks.",
            cmd = "tanktracktool_autotracks_disable",
            fixedState = "1",
        },
        {
            prettyDescription = "Disabling the skybox.",
            cmd = "r_3dsky",
            fixedState = "0",
        }
    }

    local function yap( msg )
        LocalPlayer():PrintMessage( HUD_PRINTCENTER, msg )
        LocalPlayer():PrintMessage( HUD_PRINTTALK, msg )
    end

    local timerName = "cfc_ulx_fpsfixer"
    local missingCvars
    local fixCvars

    local function allDone()
        missingCvars = nil
        fixCvars = nil
        timer.Stop( timerName )
    end

    local function findNewFix()
        local toFix
        missingCvars = missingCvars or {}
        fixCvars = fixCvars or {}
        for _, fix in ipairs( fixes ) do
            if missingCvars[fix] then continue end -- futureproof

            local cvar = fixCvars[fix] -- caching!
            if not cvar then
                cvar = GetConVar( fix.cmd )
                if not cvar then
                    missingCvars[fix] = true
                    print( "novar" )
                    continue
                else
                    fixCvars[fix] = cvar
                end
            end

            local isFixedAlready = cvar:GetString() == fix.fixedState
            if isFixedAlready then continue end

            toFix = fix
        end

        return toFix
    end
    local function applyAFix()
        local fix = findNewFix()
        if not fix then
            return -- :(
        end
        timer.Simple( 0.05, function()
            RunConsoleCommand( fix.cmd, fix.fixedState )
            yap( "Fixing FPS by... " .. fix.prettyDescription )
        end )
        return true
    end

    local function fixFps( targetFPS )
        if timer.Exists( timerName ) then -- run command again to cancel
            local msg = "Stopping FPS fixing..."
            yap( msg )
            allDone()
        end

        local fps_max = GetConVar( "fps_max" ) -- literally can't go above this
        local maxFps = fps_max:GetInt()
        if maxFps > 0 and maxFps < targetFPS then
            targetFPS = maxFps + -5 -- make this actually achievable
            print( "!fps; max fps limited by fps_max cvar" )
        end

        local nextCheck = CurTime() + FIX_CHECK_INTERVAL
        local gotData

        local runningSum = 0
        local addCount = 0

        timer.Create( timerName, 0.1, 0, function()
            if nextCheck < CurTime() then
                if not gotData or addCount <= 10 then
                    print( "!lag; got no fps data, probably tabbed out, waiting..." )
                    nextCheck = CurTime() + FIX_CHECK_INTERVAL

                    return
                end

                gotData = nil

                local averageFPS = runningSum / addCount
                averageFPS = math.Round( averageFPS, 2 )

                print( "!lag; tracked fps of... " .. averageFPS )

                local stop

                if averageFPS < targetFPS then
                    applied = applyAFix()
                    if applied then
                        print( "!lag; tracked fps is below target, applying next fix..." )
                    elseif not applied then
                        stop = true
                        yap( "Your FPS is unfixable... :(" )
                    end
                else
                    stop = true
                    yap( "Your FPS is fixed!" )
                end

                if stop then -- all done!
                    allDone()
                end
                return
            end

            if not system.HasFocus() then return end -- junk data

            local fpsRightNow = 1 / RealFrameTime()

            runningSum = runningSum + fpsRightNow
            addCount = addCount + 1
            gotData = true
        end )
    end

    timer.Remove( timerName )

    net.Receive( "CFC_ULX_FPSFix", function()
        local targetFPS = net.ReadInt( 16 )
        fixFps( targetFPS )

    end )
end

if not SERVER then return end

util.AddNetworkString( "CFC_ULX_FPSFix" )

function cmd.fixFPS( caller, targetPlys, fpsTarget )
    fpsTarget = fpsTarget or DEFAULT_TARGET

    if IsValid( caller ) and not caller:IsAdmin() then
        for _, targ in pairs( targetPlys ) do
            if targ ~= caller then ULib.tsayError( caller, "You can't start a lag fix on them, you're not an admin!", true ) return end
        end
    end

    net.Start( "CFC_ULX_FPSFix" )
        net.WriteInt( fpsTarget, 16 )
    net.Send( targetPlys )

    ulx.fancyLogAdmin( caller, "#A started a lag fix with a target of #s FPS on #T", fpsTarget, targetPlys )
end

local fpsCommand = ulx.command( CATEGORY_NAME, "ulx lag", cmd.fixFPS, { "!lag", "!fpsboost" } )
fpsCommand:addParam{ type = ULib.cmds.PlayerArg, target = "^", default = "^", ULib.cmds.optional }
fpsCommand:addParam{ type = ULib.cmds.NumArg, default = DEFAULT_TARGET, min = MIN_TARGET, max = MAX_TARGET, ULib.cmds.optional }
fpsCommand:defaultAccess( ULib.ACCESS_ALL )
fpsCommand:help( "Runs clientside console commands until the target FPS is achieved" )
