CFCUlxCommands.votetimedcivilize = CFCUlxCommands.votetimedcivilize or {}
local cmd = CFCUlxCommands.votetimedcivilize

local CATEGORY_NAME = "Fun"
local PUNISHMENT = "timedcivilize"
local PERMANENT_EXPIRATION = -1

local function voteCivilizeDone( t, targetNick, targetSteamID, minutes, callingPly )
    local targetPly = player.GetBySteamID64( targetSteamID )
    if not IsValid( targetPly ) then
        ulx.fancyLogAdmin( callingPly, "Though the populace voted to refine #s, the target has departed before civility could be imposed", targetNick )
        return
    end

    local voteYesCount = t.results[1] or 0
    local voteNoCount = t.results[2] or 0

    if voteYesCount <= voteNoCount then
        ulx.fancyLogAdmin( callingPly, "The populace has deemed the refinement of #T unworthy. Motion dismissed: #i in favor, #i opposed", targetPly, voteYesCount, voteNoCount )
        return
    end

    -- Fall back to console as the issuer if the caller left mid-vote
    local issuerSteamID = IsValid( callingPly ) and callingPly:SteamID64() or "Console"

    local isPermanent = minutes == 0
    local expirationTime = isPermanent and PERMANENT_EXPIRATION or os.time() + ( minutes * 60 )

    TimedPunishments.Punish( targetSteamID, PUNISHMENT, expirationTime, issuerSteamID, "Voted civilized by players" )

    if isPermanent then
        ulx.fancyLogAdmin( callingPly, "#T has been refined by democratic decree! Civility shall be enforced permanently. Vote: #i in favor, #i opposed", targetPly, voteYesCount, voteNoCount )
    else
        local durationStr = ULib.secondsToStringTime( minutes * 60 )
        ulx.fancyLogAdmin( callingPly, "#T has been refined by democratic decree! Civility shall be enforced for #s. Vote: #i in favor, #i opposed", targetPly, durationStr, voteYesCount, voteNoCount )
    end
end

function cmd.votetimedcivilize( callingPly, targetPly, minutes )
    if ulx.voteInProgress then
        ULib.tsayError( callingPly, "There is already a vote in progress. Please wait for the current one to end.", true )
        return
    end

    local isPermanent = minutes == 0
    local durationStr = isPermanent and "permanently" or ULib.secondsToStringTime( minutes * 60 )

    local targetName = targetPly:Nick()
    local voteTitle = isPermanent
        and ( "Civilize " .. targetName .. " permanently?" )
        or ( "Civilize " .. targetName .. " for " .. durationStr .. "?" )

    local targetSteamID = targetPly:SteamID64()
    ulx.doVote( voteTitle, { "Yes", "No" }, voteCivilizeDone, nil, nil, nil, targetName, targetSteamID, minutes, callingPly )

    if isPermanent then
        ulx.fancyLogAdmin( callingPly, "#A started a vote to civilize #T permanently", targetPly )
    else
        ulx.fancyLogAdmin( callingPly, "#A started a vote to civilize #T for #s", targetPly, durationStr )
    end
end

local voteCmd = ulx.command( CATEGORY_NAME, "ulx votetimedcivilize", cmd.votetimedcivilize, "!votetimedcivilize" )
voteCmd:addParam{ type = ULib.cmds.PlayerArg }
voteCmd:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, ULib.cmds.optional, min = 0, default = 15 }
voteCmd:defaultAccess( ULib.ACCESS_ADMIN )
voteCmd:help( "Start a public vote to civilize a player" )
