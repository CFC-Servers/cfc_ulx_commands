CFCUlxCommands.constrainChecker = CFCUlxCommands.constrainChecker or {}
local cmd = CFCUlxCommands.constrainChecker
local CATEGORY_NAME = "Utility"
local IsValid, math_Clamp, math_Remap, math_Round = IsValid, math.Clamp, math.Remap, math.Round
local HSV_RED_ANGLE, HSV_GREEN_ANGLE = 0, 120
local WHITE = Color( 255, 255, 255 )
local CONSTRAINT_THRESHOLD = 150
if SERVER then
    util.AddNetworkString( "CFC_ULX_ConstraintResults" )
end

-- Returns the owner of the entity if it is checkable, otherwise returns false
local function getAbsoluteOwner( ent )
    if not IsValid( ent ) then return false end
    if ent.IsConstraint and ent:IsConstraint() then return false end

    local owner = ent.CPPIGetOwner and ent:CPPIGetOwner() or ent:GetOwner()
    if not IsValid( owner ) then return false end

    return owner
end

-- Returns a lookup table from players to the entities they own
local function getCheckableEnts( plys )
    local allEnts = ents.GetAll()
    local perPlyEnts = {}

    for _, ply in ipairs( plys ) do
        perPlyEnts[ply] = {}
    end

    for _, ent in ipairs( allEnts ) do
        local owner = getAbsoluteOwner( ent )

        if owner then
            local ownedEnts = perPlyEnts[owner]

            if ownedEnts then
                table.insert( ownedEnts, ent )
            end
        end
    end

    return perPlyEnts
end

local function countConstraintsForPly( ownedEnts )
    local constraintCounts = {}
    local totalConstraints = 0

    for _, ent in ipairs( ownedEnts ) do
        local entConstraints = ent.Constraints or {}

        for _, constr in pairs( entConstraints ) do
            local constrType = constr.Type or "UNKNOWN_CONSTRAINT"

            -- Add by 0.5 to compensate for double-counting, as each constraint exists on two entities
            -- NOTE: Some constraints do only exist on only ONE entity but are rare! This will be rounded up later.
            constraintCounts[constrType] = ( constraintCounts[constrType] or 0 ) + 0.5
            totalConstraints = totalConstraints + 0.5
        end
    end

    constraintCounts.Total = totalConstraints

    return constraintCounts
end

--[[
    - Returns a table that shows, per player, the amount of constraints per type they own
    - ex:
        {
            ply1 = {
                Total = 7,
                Weld = 5,
                Axis = 2,
            },
            ply2 = {
                Total = 3,
                Weld = 3,
            },
        }
--]]
local function countConstraints( plys )
    local perPlyEnts = getCheckableEnts( plys )
    local perPlyConstraints = {}

    for _, ply in ipairs( plys ) do
        local ownedEnts = perPlyEnts[ply]

        perPlyConstraints[ply] = countConstraintsForPly( ownedEnts )
    end

    return perPlyConstraints
end

local function getPlyCountsMsgData( ply, constraintCounts )
    local decorLength = 25
    local nl = "\n"
    local divider = string.rep( "=", decorLength ) .. nl
    local nameDivider = string.rep( "-", decorLength ) .. nl
    local totalCount = math_Round( constraintCounts.Total )
    local totalLabel = "TOTAL: " .. totalCount .. nl
    local plyTeamColor = team.GetColor( ply:Team() )

    local valueInThreshold = math_Clamp( totalCount, 0, CONSTRAINT_THRESHOLD )
    local severity = math_Remap( valueInThreshold, CONSTRAINT_THRESHOLD, 0, HSV_RED_ANGLE, HSV_GREEN_ANGLE )
    local colorSeverity = HSVToColor( severity, 1, 0.8 )
    if totalCount == 0 then
        colorSeverity = WHITE
        nameDivider = ""
    end

    local blockData = {
        WHITE, nl .. divider,
        plyTeamColor, ply:Name(), WHITE, " | ", colorSeverity, totalLabel, WHITE,
        nameDivider,
        divider
    }

    for constrType, count in pairs( constraintCounts ) do
        if constrType ~= "Total" and type( count ) == "number" then
            local data = constrType .. ": " .. math_Round( count ) .. nl
            table.insert( blockData, #blockData, data )
        end
    end

    return blockData
end

local function getMsgCArgs( constraintData )
    local args = {}
    for _, data in pairs( constraintData ) do
        table.Add( args, getPlyCountsMsgData( data.ply, data.counts ) )
    end

    return args
end

function cmd.checkConstraints( caller, targetPlys, showPlysWithNoConstraints )
    local perPlyConstraints = countConstraints( targetPlys )

    ulx.fancyLogAdmin( caller, true, "#A checked the constraints of #T", targetPlys ) -- Alert staff console of the command being used

    -- Convert constraint data to list and remove players with no constraints if necessary
    local constraintCountsList = {}
    for _, ply in pairs( targetPlys ) do
        local plyCounts = perPlyConstraints[ply]
        if showPlysWithNoConstraints or plyCounts.Total > 0 then
            table.insert( constraintCountsList, {
                ply = ply,
                counts = plyCounts
            } )
        end
    end
    table.sort( constraintCountsList, function( a, b )
        return a.counts.Total > b.counts.Total
    end )

    -- Create args for MsgC using constraint count list and send to client
    -- TODO move visualization code clientside
    if not IsValid( caller ) then
        MsgC( unpack( constraintMessageArgs ) )
        return
    end
    net.Start( "CFC_ULX_ConstraintResults" )
        net.WriteTable( getMsgCArgs( constraintCountsList ) )
    net.Send( caller )

    timer.Simple( 0, function()
        caller:ChatPrint( "Open your console to see the results." )
    end )
end


local constraintCheckerCommand = ulx.command( CATEGORY_NAME, "ulx constraints", cmd.checkConstraints, "!constraints" )
constraintCheckerCommand:addParam{ type = ULib.cmds.PlayersArg }
constraintCheckerCommand:addParam{ type = ULib.cmds.BoolArg, default = 0, ULib.cmds.optional }
constraintCheckerCommand:defaultAccess( ULib.ACCESS_ADMIN )
constraintCheckerCommand:help( "Prints out the number of constraints the player(s) have." )
