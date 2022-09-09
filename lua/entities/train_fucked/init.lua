AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include( "shared.lua" )

local IsValid = IsValid

function ENT:Initialize()
    self:SetModel( "models/props_trainstation/train001.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE_DEBRIS )
    self:PhysWake()
end

function ENT:PhysicsCollide( colData )
    local ply = colData.HitEntity
    if not IsValid( ply ) then return end
    if not ply:IsPlayer() then return end

    ply:SetVelocity( self:GetVelocity() )

    timer.Simple( 0, function()
        if not IsValid( ply ) then return end
        if not IsValid( self ) then return end

        local dmg = DamageInfo()
        dmg:SetAttacker( self )
        dmg:SetInflictor( self )
        dmg:SetDamage( 1000 )

        ply:KillSilent()
        hook.Run( "DoPlayerDeath", ply, self, dmg )
        if not ply.TrainfuckTookDamage then
            hook.Run( "PlayerDeath", ply, self, self )
        end
        ply.TrainfuckTookDamage = nil
    end)
end

hook.Add( "PlayerShouldTakeDamage", "TrainfuckWasDamaged", function( ply, ent )
    if ent:GetClass() ~= "train_fucked" then return end
    ply.TrainfuckTookDamage = true
end)
