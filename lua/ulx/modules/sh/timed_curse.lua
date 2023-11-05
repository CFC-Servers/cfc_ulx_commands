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
        local timedEffectName = ply.CFCUlxCurseCurrentTimedCurseName

        if timedEffectName then
            CFCUlxCurse.StopCurseEffect( ply, timedEffectName )
        end
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "time-cursed ##"
local inverseAction = "lifted ##'s timed curse"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )
