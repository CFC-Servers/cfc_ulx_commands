CFCUlxCommands.timedtrainfuck = CFCUlxCommands.timedtrainfuck or {}
local CATEGORY_NAME = "Fun"
local PUNISHMENT = "timedowoify"
local HELP = "Curse a user to be owoified at random intervals and for random amounts of time."

if SERVER then
    local function timerName( ply )
        return "CFC_ULXCommands_TimedOwoify_" .. ply:SteamID64(), "CFC_ULXCommands_TimedOwoifyTimer2_" .. ply:SteamID64()
    end

    local function newDelay()
        return math.Rand( 5, 25 * 60 )
    end
    
    local function newDuration()
        return math.Rand( 5, 5 * 60 )
    end 

    local function enable( caller, ply )
        local name = timerName( ply )[1]

        timer.Create( name, newDelay(), 0, function()
            if not IsValid( ply ) then
                return timer.Remove( name )
            end
            CFCUlxCommands.owoify.owoifyCommand( caller, ply, false )
            timer.Adjust( timerName( ply )[2] ), newDuration() )
        end )
        timer.Create( timerName( ply )[2], newDuration(), 0, function()
            local t_name = timerName( ply )[2]
            if not IsValid( ply ) then
                return timer.Remove( t_name )
            end
            CFCUlxCommands.owoify.owoifyCommand( caller, ply, true )
            timer.Adjust( timerName( ply )[1], newDelay() )
        end )
    end

    local function disable( ply )
        timer.Remove( timerName( ply )[1] )
        timer.Remove( timerName( ply )[2] )
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "cursed ## (uwu)"
local inverseAction = "lifted ##'s curse"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )
