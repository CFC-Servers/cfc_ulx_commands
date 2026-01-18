CFCUlxCommands.timecivilize = CFCUlxCommands.timecivilize or {}
local CATEGORY_NAME = "Fun"
local PUNISHMENT = "timedcivilize"
local HELP = "Bestow a period of sophistication upon a player, after which they return to their former, primitive state."

if SERVER then
    local civilizeModule = CFCUlxCommands.civilize

    local function enable( ply )
        civilizeModule.timedCivilizedPlayers[ply] = true
        civilizeModule.enable( ply )
    end

    local function disable( ply )
        civilizeModule.timedCivilizedPlayers[ply] = nil
        civilizeModule.disable( ply )
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "bestowed a period of sophistication upon ##"
local inverseAction = "returned ## to a more primitive period"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )
