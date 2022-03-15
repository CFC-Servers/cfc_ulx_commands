CFCUlxCommands.trainfuck = CFCUlxCommands.trainfuck or {}
local cmd = CFCUlxCommands.trainfuck

CATEGORY_NAME = "Fun"

function cmd.trainFuck( ply )
    local train = ents.Create( "train_fucked" )
    train:SetPos( ply:GetPos() - ply:GetForward() * 500 + Vector( 0, 0, 150 ) )
    train:SetAngles( ply:EyeAngles() - Angle( 0, 90, 0 ) )
    train:Spawn()
    local phys = train:GetPhysicsObject()

    if IsValid( phys ) then
        if ply:GetMoveType( MOVETYPE_NOCLIP ) then
            ply:SetMoveType( MOVETYPE_WALK )
        end
        ply:ExitVehicle()

        phys:ApplyForceCenter( ( ply:GetPos() - train:GetPos() ) * 100000000 )

        local removeTime = math.random( 2, 4 )
        timer.Simple( removeTime, function()
            if not IsValid( train ) then return end
            train:Remove()
        end)
    end
end

function cmd.trainFuckPlayers( callingPlayer, targetPlayers )
    for _, ply in ipairs( targetPlayers ) do
        cmd.trainFuck( ply )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A trainfucked #T", targetPlayers )
end

local trainFuckCommand = ulx.command( CATEGORY_NAME, "ulx trainfuck", cmd.trainFuckPlayers, "!trainfuck" )
trainFuckCommand:addParam{ type = ULib.cmds.PlayersArg }
trainFuckCommand:defaultAccess( ULib.ACCESS_ADMIN )
trainFuckCommand:help( "Trainfucks target(s)" )
