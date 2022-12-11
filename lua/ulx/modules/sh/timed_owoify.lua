CFCUlxCommands.timedowoify = CFCUlxCommands.timedowoify or {}
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
        local delayTimer, durationTimer = timerName( ply )

        timer.Create( name, newDelay(), 0, function()
            if not IsValid( ply ) then
                return timer.Remove( name )
            end
            CFCUlxCommands.owoify.owoifyCommand( caller, ply, false )
            timer.Adjust( durationTimer ), newDuration() )
        end )
        timer.Create( durationTimer, newDuration(), 0, function()
            local delayTimer, t_name = timerName( ply )
            if not IsValid( ply ) then
                return timer.Remove( t_name )
            end
            CFCUlxCommands.owoify.owoifyCommand( caller, ply, true )
            timer.Adjust( delayTimer, newDelay() )
        end )
    end

    local function disable( ply )
        local delayTimer, durationTimer = timerName( ply )
        timer.Remove( delayTimer )
        timer.Remove( durationTimer )
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "cursed ## (uwu)"
local inverseAction = "lifted ##'s curse"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )
