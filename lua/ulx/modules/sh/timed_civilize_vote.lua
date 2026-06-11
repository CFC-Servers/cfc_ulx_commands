-- Vote to civilize using ULX vote system
local PUNISHMENT = "timedcivilize"
local CATEGORY = "Fun"
local PERMANENT_EXPIRATION = -1

if SERVER then
    local function voteCivilizeDone( t, targetNick, targetSteamID, minutes, callingPly )
        local voteYesCount = t.results[1] or 0
        local voteNoCount = t.results[2] or 0
        local shouldCivilize = voteYesCount > 0

        if not shouldCivilize then
            ulx.fancyLogAdmin( callingPly, "The populace has deemed the refinement of #s unworthy. Motion dismissed: #i in favor, #i opposed", targetNick, voteYesCount, voteNoCount )
            return
        end

        -- Check if player is still on server
        local targetPly = player.GetBySteamID64( targetSteamID )
        local targetStillOnServer = IsValid( targetPly )
        if not targetStillOnServer then
            ulx.fancyLogAdmin( callingPly, "Though the populace voted to refine #s, the target has departed before civility could be imposed", targetNick )
            return
        end

        -- Get calling player's steam ID (or console if they disconnected)
        local callerStillOnServer = IsValid( callingPly )
        local issuerSteamID = callerStillOnServer and callingPly:SteamID64() or "Console"

        -- Calculate expiration time
        local isPermanent = minutes == 0
        local expirationTime = isPermanent and PERMANENT_EXPIRATION or os.time() + ( minutes * 60 )

        -- Apply the punishment
        TimedPunishments.Punish( targetSteamID, PUNISHMENT, expirationTime, issuerSteamID, "Voted civilized by players" )

        -- Log the result
        local durationStr = isPermanent and "permanently" or ULib.secondsToStringTime( minutes * 60 )
        ulx.fancyLogAdmin( callingPly, "#s has been refined by democratic decree! Civility shall be enforced for #s. Vote: #i in favor, #i opposed", targetNick, durationStr, voteYesCount, voteNoCount )
    end

    function ulx.votetimedcivilize( callingPly, targetPly, minutes )
        -- Check if another vote is already in progress
        local anotherVoteInProgress = ulx.voteInProgress
        if anotherVoteInProgress then
            ULib.tsayError( callingPly, "There is already a vote in progress. Please wait for the current one to end.", true )
            return
        end

        -- Format the duration for display
        local isPermanent = minutes == 0
        local durationStr = isPermanent and "permanently" or ULib.secondsToStringTime( minutes * 60 )

        -- Build the vote title
        local targetName = targetPly:Nick()
        local voteTitle = "Civilize " .. targetName .. " for " .. durationStr .. "?"

        -- Start the vote
        local targetSteamID = targetPly:SteamID64()
        ulx.doVote( voteTitle, { "Yes", "No" }, voteCivilizeDone, _, _, _, targetName, targetSteamID, minutes, callingPly )

        -- Log the vote initiation
        ulx.fancyLogAdmin( callingPly, "#A started a vote to civilize #T for #s", targetPly, durationStr )
    end
end

-- Create the ULX command
local voteCmd = ulx.command( CATEGORY, "ulx votetimedcivilize", ulx.votetimedcivilize, "!votetimedcivilize" )

-- Add parameters
voteCmd:addParam{ type = ULib.cmds.PlayerArg }
voteCmd:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, ULib.cmds.optional, min = 0, default = 15 }

-- Configure access and help
voteCmd:defaultAccess( ULib.ACCESS_ADMIN )
voteCmd:help( "Start a public vote to civilize a player" )
