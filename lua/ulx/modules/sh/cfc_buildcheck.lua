CFCUlxCommands.buildCheck = CFCUlxCommands.buildCheck or {}
local cmd = CFCUlxCommands.buildCheck
local CATEGORY_NAME = "Utility"
local IsValid = IsValid
local rawget = rawget
local rawset = rawset
local IsValid = IsValid

if SERVER then
    util.AddNetworkString( "CFC_ULX_BuildCheckResults" )
end

if CLIENT then
    -- TODO: Choose the colors
    local INTRO_COLOR = Color( 145, 145, 245 )
    local HEADER_COLOR = Color( 145, 245, 145 )
    local CLASS_COLOR = Color( 245, 245, 145 )
    local DEFAULT_COLOR = Color( 245, 245, 245 )

    -- These are vectors so we can lerp them
    local MOST_COUNT_COLOR = Vector( 1, 0, 0 ) -- If a single count makes up 100% of the total count
    local MID_COUNT_COLOR = Vector( 1, 1, 0 ) -- If a single count makes up 50% of the total count
    local LEAST_COUNT_COLOR = Vector( 0, 1, 0 ) -- If a single count make sup 0% of the total count

    -- TODO: Create some way of scaling the total counts
    local function getTotalColor( total, category )
    end

    -- Returns a dynamic color between MOST_COUNT and
    -- LEAST_COUNT colors based on how much of the total is
    -- made up by the given count
    local function getCountColor( total, count )
        local fraction = count / total

        local min, max
        if fraction <= 0.5 then
            fraction = math.Remap( fraction, 0, 0.5, 0, 1 )
            min = LEAST_COUNT_COLOR
            max = MID_COUNT_COLOR
        else
            min = MID_COUNT_COLOR
            max = MOST_COUNT_COLOR
        end

        return LerpVector( fraction, min, max ):ToColor()
    end

    -- MsgC with prefix and auto-newlining
    consolePrint = function( prefix, ... )
        MsgC( prefix )
        MsgC( ... )
        MsgC( "\n" )
    end

    -- consolePrint with no prefix
    local msg = function( ... )
        consolePrint( "", ... )
    end

    -- consolePrint with indentation
    local subPrefix = "    "
    local subMsg = function( ... )
        consolePrint( subPrefix, ... )
    end

    -- Writes a table of <identifier>=<count>
    local function writeCountData( header, data )
        msg( HEADER_COLOR, header, ":" )

        local total = data.total

        for identifier, count in SortedPairsByValue( data.items, true ) do
            local col = getCountColor( total, count )
            subMsg( CLASS_COLOR, identifier, ": ", col, count )
        end

        subMsg( CLASS_COLOR, "Total: ", INTRO_COLOR, total, "\n" )
    end

    local function writePlayerData( plyName, data )
        -- Padded with newlines for surround spacing
        msg( "\n\n", INTRO_COLOR, "Building summary for: '" .. plyName .. "'", "\n" )

        writeCountData( "Props by model", data.props )
        writeCountData( "Constraints by class", data.constraints )
        writeCountData( "Ents by class", data.ents )
        writeCountData( "Alerts", data.alerts )
    end

    net.Receive( "CFC_ULX_BuildCheckResults", function()
        local dataLen = net.ReadUInt( 32 )
        local json = util.Decompress( net.ReadData( dataLen ) )
        local data = util.JSONToTable( json )

        PrintTable( data )

        for plyName, data in pairs( data.players ) do
            writePlayerData( plyName, data )
        end

        -- Write the unknown data last
        writePlayerData( "Unowned", data.unknown )
    end )
end

-- TODO: alerts is a countTable ( { total = 0, items = { <alert> = <count>} )
local function addEntAlerts( ent, alerts )
end

-- TODO: plyData.alerts is a countTable ( { total = 0, items = { <alert> = <count>} )
local function addPlyAlerts( plyData )
end

-- Returns <category>,<identifier>
-- i.e. a prop returns "props",<model name>
-- a constraint returns "constraints",<class name>
-- TODO: Rename this to indicate it returns the identifier too
local function entCategory( ent )
    local class = ent:GetClass()

    if class == "prop_physics" then
        return "props", ent:GetModel()
    end

    if ent:IsConstraint() then
        return "constraints", class
    end

    return "ents", class
end

local function tallyEnt( ent, trackedPlayers, playerData, unknownData )
    -- TODO: Make a more robust method to get owners (i.e. for wire holograms, npcs, grenades, etc.)
    local owner = ent.CPPIGetOwner and ent:CPPIGetOwner()
    local validOwner = IsValid( owner )

    if not validOwner and trackedPlayers[owner] then return end

    local plyData = validOwner and rawget( playerData, owner ) or unknownData
    local category, identifier = entCategory( ent )

    local categoryData = rawget( plyData, category )
    local categoryTotal = rawget( categoryData, "total" )
    local itemData = rawget( categoryData, "items" )

    local count = rawget( itemData, identifier ) or 0
    rawset( itemData, identifier, count + 1 )
    rawset( categoryData, "total", categoryTotal + 1 )

    local alerts = rawget( plyData, "alerts" )
    addEntAlerts( ent, alerts )
end

local function countTable()
    return {
        total = 0,
        items = {}
    }
end

local function categoryTable()
    return {
        constraints = countTable(),
        props = countTable(),
        ents = countTable(),
        alerts = countTable()
    }
end

function cmd.buildCheck( caller, targets )
    if not caller:IsAdmin() then
        local now = CurTime()
        local lastcall = caller.lastBuildCheck or 0
        if lastCall > ( now - 5 ) then
            return -- TODO: Hey nerd that's too soon, chill will ya'
        end

        caller.lastBuildCheck = now
    end

    local targetsCount = #targets
    local buildData = {
        unknown = categoryTable(),
        players = {}
    }

    for i = 1, targetsCount do
        local ply = rawget( targets, i )
        buildData.players[ply] = categoryTable()
    end

    local allEnts = ents.GetAll()
    local entsCount = #allEnts

    local unknownData = buildData.unknown
    local playerData = buildData.players
    PrintTable( playerData )

    for i = 1, entsCount do
        local ent = rawget( allEnts, i )
        tallyEnt( ent, targets, playerData, unknownData )
    end

    for ply, data in pairs( playerData ) do
        if not isstring( ply ) then
            -- Check for player alerts
            addPlyAlerts( data )

            -- Convert keys to the player's name and steamid
            local plyString = ply:Nick() .. "<" .. ply:SteamID() .. ">"
            playerData[plyString] = data
            playerData[ply] = nil
        end
    end

    PrintTable( buildData )

    local json = util.TableToJSON( buildData )
    local compress = util.Compress( json )

    -- TODO: Figure out a more reasonable number for this UInt
    net.Start( "CFC_ULX_BuildCheckResults" )
    net.WriteUInt( #compress, 32 )
    net.WriteData( compress, #compress )
    net.Send( caller )

    -- TODO: Fancylogadmin some highlights from the data here
end

local command = ulx.command( CATEGORY_NAME, "ulx buildcheck", cmd.buildCheck, "!buildcheck" )
command:addParam{ type = ULib.cmds.PlayersArg }
command:defaultAccess( ULib.ACCESS_ADMIN )
command:help( "Returns building information about the target player(s)" )
