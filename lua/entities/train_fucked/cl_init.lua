include( "shared.lua" )

language.Add( "train_fucked", "Train fucked!" )
killicon.Add( "train_fucked", "hud/killicons/trainfucked.vtf", Color( 255, 80, 0, 255 ) )

ENT.spawnSounds = {
    "ambient/alarms/razortrain_horn1.wav",
    "ambient/alarms/train_horn2.wav",
    "ambient/machines/usetoilet_flush1.wav",
    "ambient/machines/wall_crash1.wav",
    "ambient/alarms/train_crossing_bell_loop1.wav"
}

ENT.loopingSounds = {
    "ambient/machines/train_freight_loop1.wav",
    "ambient/machines/train_freight_loop2.wav",
    "ambient/machines/razor_train_wheels_loop1.wav",
    "ambient/machines/razor_train_wheels_loop2.wav",
}

function ENT:PlaySound( soundName, soundLevel, pitchPercent, volume, channel, weapons, soundFlags, number )
    table.insert( self.PlayingSounds, soundName )
    self:EmitSound( soundName, soundLevel, pitchPercent, volume, channel, weapons, soundFlags, number )
end

function ENT:StopSounds()
    if not self.PlayingSounds then return end
    for _, v in ipairs( self.PlayingSounds ) do
        self:StopSound( v )
    end
end

function ENT:Initialize()
    self.PlayingSounds = {}
    local soundPlay = self.spawnSounds[math.random( 1, #self.spawnSounds )]
    for _ = 1, 5 do -- Extra LOUD!
        self:PlaySound( soundPlay, 160 )
    end

    local loopSound = self.loopingSounds[math.random( 1, #self.loopingSounds )]
    self:PlaySound( loopSound, 160 )
end

function ENT:OnRemove()
    self:StopSounds()
end

function ENT:Draw()
    self:DrawModel()
end
