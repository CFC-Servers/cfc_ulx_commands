CFCUlxCommands.timedcurse = CFCUlxCommands.timedcurse or {}
local CATEGORY_NAME = "Fun"
local PUNISHMENT = "timedcurse"
local HELP = "Curse a user to receive assorted effects at random intervals"

CFCUlxCurse = CFCUlxCurse or {}

if SERVER then
    local function enable( ply )
        local effect = CFCUlxCurse.GetRandomEffect()

        CFCUlxCurse.ApplyCurseEffect( ply, effect )
    end

    local function disable( ply )
        CFCUlxCurse.StopCurseEffect( ply )
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "cursed ##"
local inverseAction = "lifted ##'s curse"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )
