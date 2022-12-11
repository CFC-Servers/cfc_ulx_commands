CFCUlxCommands.timedtrainfuck = CFCUlxCommands.timedtrainfuck or {}
local CATEGORY_NAME = "Fun"
local PUNISHMENT = "timedtrainfuck"
local HELP = "Curse a user to be trainfucked at random intervals"

if SERVER then
    local function timerName( ply )
        return "CFC_ULXCommands_TimedTrainFuck_" .. ply:SteamID64()
    end

    local function newDelay()
        return math.Rand( 5, 25 * 60 )
    end

    local function enable( ply )
        local name = timerName( ply )

        timer.Create( name, newDelay(), 0, function()
            if not IsValid( ply ) then
                return timer.Remove( name )
            end

            CFCUlxCommands.trainfuck.trainFuck( ply )
            timer.Adjust( name, newDelay() )
        end )
    end

    local function disable( ply )
        timer.Remove( timerName( ply ) )
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "cursed ## (choo choo)"
local inverseAction = "lifted ##'s curse"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )
