local EFFECT_NAME = "SeeingDouble"
local DUPLICATE_INTERVAL = 0.05
local DUPLICATE_CHANCE = 0.25
local DUPLICATE_AMOUNT_MIN = 1
local DUPLICATE_AMOUNT_MAX = 10


local duplicates = {}


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end


        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "Duplicate", DUPLICATE_INTERVAL, 0, function()
            if DUPLICATE_CHANCE ~= 1 and math.Rand( 0, 1 ) > DUPLICATE_CHANCE then return end

            local props = ents.FindByClass( "prop_physics" )
            local propCount = #props

            if propCount == 0 then return end

            local duplicateCount = #duplicates
            local combinedCount = propCount + duplicateCount

            for _ = 1, math.random( DUPLICATE_AMOUNT_MIN, DUPLICATE_AMOUNT_MAX ) do
                local ind = math.random( 1, combinedCount )
                local copyingADuplicate = ind > propCount
                local entToCopy = copyingADuplicate and duplicates[ind - propCount] or props[ind]

                if IsValid( entToCopy ) then
                    local obbSize = entToCopy:OBBMaxs() - entToCopy:OBBMins()
                    local pos = entToCopy:GetPos()
                    local axisChoice = math.random( 1, 3 )
                    local sign = math.random( 0, 1 ) == 0 and -1 or 1

                    if axisChoise == 1 then
                        pos = pos + entToCopy:GetForward() * sign * obbSize.x
                    elseif axisChoice == 2 then
                        pos = pos + entToCopy:GetRight() * sign * obbSize.y
                    else
                        pos = pos + entToCopy:GetUp() * sign * obbSize.z
                    end

                    local duplicate = ents.CreateClientProp( entToCopy:GetModel() )
                    duplicate:SetModel( entToCopy:GetModel() )
                    duplicate:SetPos( pos )
                    duplicate:SetAngles( entToCopy:GetAngles() )
                    duplicate:Spawn()
                    duplicate:SetSkin( entToCopy:GetSkin() )
                    duplicate:SetColor( entToCopy:GetColor() )
                    duplicate:SetRenderMode( entToCopy:GetRenderMode() )
                    duplicate:GetPhysicsObject():EnableMotion( false )

                    for i = 0, entToCopy:GetNumBodyGroups() - 1 do
                        duplicate:SetBodygroup( i, entToCopy:GetBodygroup( i ) )
                    end

                    for i = 0, #entToCopy:GetMaterials() - 1 do
                        duplicate:SetSubMaterial( i, entToCopy:GetSubMaterial( i ) )
                    end

                    -- For some reason, :GetMaterial() doesn't work correctly on clientside props. :GetSubMaterial() and the rest do, though.
                    local material = entToCopy.cfcUlxCurse_SeeingDouble_Material or entToCopy:GetMaterial()

                    duplicate:SetMaterial( material )
                    duplicate:SetParent( entToCopy:GetParent() )
                    duplicate.cfcUlxCurse_SeeingDouble_Material = material

                    table.insert( duplicates, duplicate )
                elseif copyingADuplicate then
                    table.remove( duplicates, ind - propCount )
                end
            end
        end )
    end,

    onEnd = function()
        if SERVER then return end

        for i = #duplicates, 1, -1 do
            local ent = duplicates[i]

            if IsValid( ent ) then
                ent:Remove()
            end

            duplicates[i] = nil
        end
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {},
    groups = {
        "VisualOnly",
    },
    incompatibleGroups = {},
} )
