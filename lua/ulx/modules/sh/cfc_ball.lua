CFCUlxCommands.ball = CFCUlxCommands.ball or {}
local cmd = CFCUlxCommands.ball
local CATEGORY_NAME = "Fun"

local spawnerToPlayer = {}

function redirectBall(projectile, eyeAngles)
    local physObj = projectile:GetPhysicsObject()
    if IsValid(physObj) then
        local velocity = physObj:GetVelocity()
        local speed = velocity:Length() * 1.35
        local direction = eyeAngles:Forward()
        local newVelocity = direction * speed
        physObj:SetVelocityInstantaneous(newVelocity)
    end
end


local function makeSpawner( ply )
    local ballMaker = ents.Create( "point_combine_ball_launcher" )

    ballMaker:SetPos( ply:GetPos() )
    ballMaker:SetKeyValue( "minspeed", "5700" )
    ballMaker:SetKeyValue( "maxspeed", "6500" )
    ballMaker:SetKeyValue( "ballradius", "15" )
    ballMaker:SetKeyValue( "ballcount", "0" )
    ballMaker:SetKeyValue( "maxballbounces", "9999999999" )
    ballMaker:SetKeyValue( "launchconenoise", "360" )
    ballMaker:Spawn()

    ply.BallMaker = ballMaker
    spawnerToPlayer[ballMaker] = ply

    ballMaker:Fire( "LaunchBall" )
end

local function unball( ply )
    assert( ply:IsValid(), "Player is invalid: " .. tostring( ply ) )

    local eyeAngles = ply:EyeAngles()

    ply:SetParent()
    ply:UnSpectate()
    ply:GodEnable( false )
    ply:DisallowSpawning( false )

    ply:Spawn()

    ulx.clearExclusive( ply )

    local ball = ply.Ball
    if not ball then return end
    if not ball:IsValid() then return end

    ply:SetPos( ball:GetPos() )
    ply:SetEyeAngles( eyeAngles )
    ply:SetVelocity( ball:GetVelocity() )

    ball:Remove()
end

local function ballify( ply, ball )
    assert( ply:IsValid(), "Player is invalid: " .. tostring( ply ) )
    assert( ball:IsValid(), "Ball is invalid: " .. tostring( ball ) )

    redirectBall( ball, ply:EyeAngles() )

    ply:SetParent( ball )
    ply:Spectate( OBS_MODE_CHASE )
    ply:SpectateEntity( ball )
    ply:StripWeapons()
    ply:GodEnable( true )
    ply:DisallowSpawning( true )

    ball:CallOnRemove( "CFCUlxCommands_Balls", function()
        unball( ply )
        ulx.fancyLogAdmin( ply, "#A has been unballed!" )
    end )

    ply.Ball = ball

    ulx.setExclusive( ply, "balled" )
end

hook.Add( "OnEntityCreated", "CFCUlxCommands_Balls", function( ent )
    if ent:GetClass() ~= "prop_combine_ball" then return end

    timer.Simple( 0, function()
        if not ent:IsValid() then return end

        local spawner = ent:GetInternalVariable( "m_hSpawner" )
        if not spawner then return end
        if not spawner:IsValid() then return end

        local ply = spawnerToPlayer[spawner]
        if not ply then return end
        if not ply:IsValid() then return end

        spawner:Fire( "kill", "", 0 )
        spawnerToPlayer[spawner] = nil
        ply.BallMaker = nil


        ballify( ply, ent )
    end )
end )

hook.Add( "PlayerDisconnected", "CFCUlxCommands_Balls", function( ply )
    local spawner = ply.BallMaker
    if not spawner then return end

    spawnerToPlayer[spawner] = nil
end )


hook.Add( "CanPlayerSuicide", "CFCUlxCommands_Balls", function( ply )
    if ply.Ball and ply.Ball:IsValid() then return false end
end )

function cmd.ball( callingPlayer, targetPlayers )
    for _, ply in ipairs( targetPlayers ) do
        local exclusive = ulx.getExclusive( ply, callingPly )
        if exclusive then
            ULib.tsayError( callingPlayer, exclusive, true )
        end

        makeSpawner( ply )
    end

    if #targetPlayers == 1 and targetPlayers[1] == callingPlayer then
        return
    end

    ulx.fancyLogAdmin( callingPlayer, "#A balls'd #T", targetPlayers )
end

function cmd.unball( callingPlayer, targetPlayers )
    for _, ply in ipairs( targetPlayers ) do
        unball( ply )
    end

    if #targetPlayers == 1 and targetPlayers[1] == callingPlayer then
        return
    end

    ulx.fancyLogAdmin( callingPlayer, "#A unballs'd #T", targetPlayers )
end

local ballCommand = ulx.command( CATEGORY_NAME, "ulx ball", cmd.ball, "!ball" )
ballCommand:addParam{ type = ULib.cmds.PlayersArg }
ballCommand:defaultAccess( ULib.ACCESS_ADMIN )
ballCommand:help( "Balls's the target player(s)" )

local unballCommand = ulx.command( CATEGORY_NAME, "ulx unball", cmd.unball, "!unball" )
unballCommand:addParam{ type = ULib.cmds.PlayersArg }
unballCommand:defaultAccess( ULib.ACCESS_ADMIN )
unballCommand:help( "Un-Balls's the target player(s)" )
