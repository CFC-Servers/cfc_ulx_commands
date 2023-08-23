CFCUlxCommands.curse = CFCUlxCommands.curse or {}
local cmd = CFCUlxCommands.curse

CATEGORY_NAME = "Fun"

CFCUlxCurse = CFCUlxCurse or {}

function cmd.curse( ply, shouldUncurse )
    if shouldUncurse then
        CFCUlxCurse.StopCurseEffect( ply )
    else
        local effect = CFCUlxCurse.GetRandomOnetimeEffect()

        CFCUlxCurse.ApplyCurseEffect( ply, effect )
    end
end

function cmd.cursePlayers( callingPlayer, targetPlayers, shouldUncurse )
    for _, ply in ipairs( targetPlayers ) do
        cmd.curse( ply, shouldUncurse )
    end

    local onetimeCursedPlayers = {}
    local longCursedPlayers = {}

    for _, ply in ipairs( targetPlayers ) do
        if CFCUlxCurse.IsCursed( ply ) then
            table.insert( longCursedPlayers, ply )
        else
            table.insert( onetimeCursedPlayers, ply )
        end
    end

    if shouldUncurse then
        if not table.IsEmpty( onetimeCursedPlayers ) then
            ulx.fancyLogAdmin( callingPlayer, "#A lifted #T's brief curse", onetimeCursedPlayers )
        end

        if not table.IsEmpty( longCursedPlayers ) then
            ulx.fancyLogAdmin( callingPlayer, "#A delayed #T's next curse effect", longCursedPlayers )
        end
    else
        if not table.IsEmpty( onetimeCursedPlayers ) then
            ulx.fancyLogAdmin( callingPlayer, "#A briefly cursed #T", onetimeCursedPlayers )
        end

        if not table.IsEmpty( longCursedPlayers ) then
            ulx.fancyLogAdmin( callingPlayer, "#A hastened #T's next curse effect", longCursedPlayers )
        end
    end
end

local curseCommand = ulx.command( CATEGORY_NAME, "ulx curse", cmd.cursePlayers, "!curse" )
curseCommand:addParam{ type = ULib.cmds.PlayersArg }
curseCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
curseCommand:defaultAccess( ULib.ACCESS_ADMIN )
curseCommand:help( "Applies a one-time curse effect to target(s)" )
curseCommand:setOpposite( "ulx uncurse", { _, _, true }, "!uncurse" )
