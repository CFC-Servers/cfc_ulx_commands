CFCUlxCommands.cheese = CFCUlxCommands.cheese or {}
local cmd = CFCUlxCommands.cheese

local CATEGORY_NAME = "Fun"
cmd.CHEESE_MODELS = {
    "models/hunter/triangles/025x025.mdl",
    "models/hunter/triangles/05x05x05.mdl",
    "models/hunter/triangles/1x05x05.mdl",
    "models/props_c17/playgroundtick-tack-toe_block01a.mdl"
}

function cmd.cheeseTargets( caller, targets, shouldUncheese )
    local model = cmd.CHEESE_MODELS[math.random( #cmd.CHEESE_MODELS )]
    local props = CFCUlxCommands.propify.propifyTargets( caller, targets, model, shouldUncheese )

    if table.IsEmpty( props ) then return end

    for _, prop in pairs( props ) do
        local color = Color( 255, math.Rand( 150, 221 ), 6, 255 )
        prop:SetMaterial( "models/XQM/Rails/gumball_1" )
        prop:SetColor( color  )
        prop:GetPhysicsObject():SetMaterial( "dirt" )
    end
end

local cheeseCommand = ulx.command( CATEGORY_NAME, "ulx cheese", cmd.cheeseTargets, "!cheese" )
cheeseCommand:addParam{ type = ULib.cmds.PlayersArg }
cheeseCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
cheeseCommand:defaultAccess( ULib.ACCESS_ADMIN )
cheeseCommand:help( "Turns the target(s) into cheese." )
cheeseCommand:setOpposite( "ulx uncheese", { _, _, true }, "!uncheese" )
