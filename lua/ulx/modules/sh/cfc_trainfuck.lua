CFCUlxCommands.trainfuck = CFCUlxCommands.trainfuck or {}
local cmd = CFCUlxCommands.trainfuck

CATEGORY_NAME = "Fun"

local trainSounds = {
    "ambient/alarms/razortrain_horn1.wav",
    "ambient/machines/usetoilet_flush1.wav",
    "ambient/machines/wall_crash1.wav",
    "garrysmod/balloon_pop_cute.wav",
    "garrysmod/save_load1.wav"
}

function cmd.trainFuckPlayers( callingPlayer, targetPlayers )
    for _, ply in ipairs( targetPlayers ) do
        local soundPlay = trainSounds[math.random( 1, 5 )]
        local train = ents.Create( "train_fucked" )

        train:SetPos( ply:GetPos() - ply:GetForward() * 500 + Vector( 0, 0, 150 ) )
        train:SetAngles( ply:EyeAngles() - Angle( 0, 90, 0 ) )
        train:Spawn()
        train:EmitSound( soundPlay, 150 )
        local phys = train:GetPhysicsObject()

        if IsValid( phys ) then
            if ply:GetMoveType( MOVETYPE_NOCLIP ) then
                ply:SetMoveType( MOVETYPE_WALK )
            end
            ply:ExitVehicle()

            phys:ApplyForceCenter( ( ply:GetPos() - train:GetPos() ) * 1000000000 )

            timer.Simple( 1.5, function()
                train:StopSound( soundPlay )
                train:Remove()
            end)
        end
    end

    ulx.fancyLogAdmin( callingPlayer, "#A trainfucked #T", targetPlayers )
end

local trainFuckCommand = ulx.command( CATEGORY_NAME, "ulx trainfuck", cmd.trainFuckPlayers, "!trainfuck" )
trainFuckCommand:addParam{ type = ULib.cmds.PlayersArg }
trainFuckCommand:defaultAccess( ULib.ACCESS_ADMIN )
trainFuckCommand:help( "Trainfucks target(s)" )
