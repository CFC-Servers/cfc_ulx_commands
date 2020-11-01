CFCUlxCommands.Cheese = CFCUlxCommands.Cheese or {}
local cmd = CFCUlxCommands.Cheese

cmd.CHEESE_MODELS = {
    "models/hunter/triangles/025x025.mdl",
    "models/hunter/triangles/05x05x05.mdl",
    "models/hunter/triangles/1x05x05.mdl",
    "models/props_c17/playgroundtick-tack-toe_block01a.mdl"
}
local CATEGORY_NAME = "Fun"

function cmd.CheeseTargets( caller, targets, shouldUncheese )
    local model = cmd.CHEESE_MODELS[ math.random( #cmd.CHEESE_MODELS ) ]
    local prop = CFCUlxCommands.Propify.PropifyTargets( caller, targets, model, shouldUncheese )
    
    if not prop then return end
    
    local color = Color( 255, math.Rand( 150, 221 ), 6, 255 )
    prop:SetMaterial( "models/XQM/Rails/gumball_1" )
    prop:SetColor( color  )
    prop:GetPhysicsObject():SetMaterial( "dirt" )
end

local cheeseCommand = ulx.command( CATEGORY_NAME, "ulx cheese", cmd.CheeseTargets, "!cheese" )
cheeseCommand:addParam{ type = ULib.cmds.PlayersArg }
cheeseCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
cheeseCommand:defaultAccess( ULib.ACCESS_ADMIN )
cheeseCommand:help( "Turns the target(s) into cheese." )
cheeseCommand:setOpposite( "ulx uncheese", { _, _, true }, "!uncheese" )
