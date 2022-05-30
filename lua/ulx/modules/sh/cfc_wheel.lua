CFCUlxCommands.wheel = CFCUlxCommands.wheel or {}
CFCUlxCommands.propify = CFCUlxCommands.propify or {}
local cmd = CFCUlxCommands.wheel
local propifyCmd = CFCUlxCommands.propify

local CATEGORY_NAME = "Fun"
local VEC_UP = Vector( 0, 0, 1 )
local WHEEL_MODEL = "models/props_vehicles/carparts_wheel01a.mdl"
local WHEEL_GROUND_TRACE_OFFSET
local WHEEL_JUMP_COOLDOWN = 0.3
local WHEEL_UPRIGHT_STRENGTH = 230
local WHEEL_UPRIGHT_THRESHOLD = 0.07
local WHEEL_HORIZONTAL_THRESHOLD = 0.99
local WHEEL_ASSIST_GROUND_MULT = 3
local WHEEL_TURN_ASSIST_SPINDOWN_MULT = 0.5
local WHEEL_TURN_ASSIST_REORIENT_THRESHOLD = 0.35
local WHEEL_UPRIGHT_STABILIZE = Vector( 0.9, 0, 0 )
local WHEEL_SPIN_STRENGTH = CreateConVar( "cfc_ulx_wheel_spin_strength", 30, FCVAR_NONE, "The speed that propify wheel players can move at", 0, 50000 )
local WHEEL_TURN_STRENGTH = CreateConVar( "cfc_ulx_wheel_turn_strength", 10, FCVAR_NONE, "The speed that propify wheel players can turn at", 0, 50000 )

local wheelProps = {}
local wheelPropCount = 0
cmd.wheelProps = wheelProps
cmd.wheelPropCount = wheelPropCount

cmd.relativeDirFuncsWheel = {
    [IN_FORWARD] = function( ang ) return -ang:Right() end,
    [IN_BACK] = function( ang ) return ang:Right() end,
    [IN_MOVERIGHT] = function() return -VEC_UP end,
    [IN_MOVELEFT] = function() return VEC_UP end,
    [IN_JUMP] = function() return VEC_UP end
}
local relativeDirFuncsWheel = cmd.relativeDirFuncsWheel

local IsValid = IsValid
local tableRemove = table.remove
local mAbs = math.abs

local function mSignNoZero( x )
    return ( x < 0 and -1 ) or 1
end

local function overridePrint( isUnpropifying )
    if isUnpropifying then return "#A made a flat out of #T" end
    return "#A took #T out for a spin"
end

function cmd.wheelTargets( caller, targets, shouldUnwheel )
    local props = propifyCmd.propifyTargets( caller, targets, WHEEL_MODEL, shouldUnwheel, overridePrint, cmd.propHopOverride, cmd.hopCooldownOverride )

    if table.IsEmpty( props ) then return end

    table.Add( wheelProps, props )
    wheelPropCount = #wheelProps
    cmd.wheelPropCount = wheelPropCount
end

local function getRelativeHopDirWheel( eyeAngles, key )
    local dirFunc = relativeDirFuncsWheel[key]

    if not dirFunc then return eyeAngles:Forward() end

    return dirFunc( eyeAngles )
end

function cmd.propHopOverride( ply, prop, key, state, moveDir )
    if not relativeDirFuncsWheel[key] then return end

    local isTurning = key == IN_MOVERIGHT or key == IN_MOVELEFT

    if not state then
        if key == IN_JUMP then return end

        if isTurning then
            prop.propifyWheelTurning = false
        else
            prop.propifyWheelSpinning = false
        end

        return
    end

    local phys = prop:GetPhysicsObject()

    if not IsValid( phys ) then
        propifyCmd.unpropifyPlayer( ply )

        return
    end

    if key == IN_JUMP then
        if not prop:IsOnGround() then return false end

        phys:ApplyForceCenter( moveDir * GetConVar( "cfc_ulx_propify_hop_strength" ):GetFloat() * phys:GetMass() )

        return true
    end

    local moveDirWheel = getRelativeHopDirWheel( ply:EyeAngles(), key )
    local rotStrength = isTurning and WHEEL_TURN_STRENGTH:GetFloat() or WHEEL_SPIN_STRENGTH:GetFloat()

    if isTurning then
        prop.propifyWheelTurning = moveDirWheel * rotStrength
    else
        prop.propifyWheelSpinning = moveDirWheel * rotStrength
    end

    return false
end

function cmd.hopCooldownOverride()
    return WHEEL_JUMP_COOLDOWN
end

local wheelCommand = ulx.command( CATEGORY_NAME, "ulx wheel", cmd.wheelTargets, "!wheel" )
wheelCommand:addParam{ type = ULib.cmds.PlayersArg }
wheelCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
wheelCommand:defaultAccess( ULib.ACCESS_ADMIN )
wheelCommand:help( "Turns the target(s) into a wheel." )
wheelCommand:setOpposite( "ulx unwheel", { _, _, true }, "!unwheel" )


hook.Add( "Think", "CFC_ULX_WheelKeepUpright", function()
    for i = wheelPropCount, 1, -1 do
        local wheel = wheelProps[i]
        wheel = IsValid( wheel ) and wheel
        local phys = wheel and wheel:GetPhysicsObject()
        local ply = wheel.ragdolledPly

        if not wheel or not IsValid( phys ) or not IsValid( ply ) then
            tableRemove( wheelProps, i )
            wheelPropCount = wheelPropCount - 1
            cmd.wheelPropCount = wheelPropCount

            continue
        end

        local wheelRight = wheel:GetRight()
        local wheelRightZ = wheelRight[3]
        local wheelRightZAbs = mAbs( wheelRightZ )
        local wheelRightZOriginal = wheelRightZ
        local isHorizontal = wheelRightZAbs > WHEEL_HORIZONTAL_THRESHOLD
        local plyForward = ply:GetAimVector()
        local spinTorque = wheel.propifyWheelSpinning
        local turnTorque = wheel.propifyWheelTurning
        local groundMult = wheel:IsOnGround() and WHEEL_ASSIST_GROUND_MULT or 1

        if spinTorque then
            local spindownMult = turnTorque and WHEEL_TURN_ASSIST_SPINDOWN_MULT or 1 -- Assist turning by reducing forwards spin
            local rightDotAim = wheelRight:Dot( plyForward )

            if mAbs( rightDotAim ) > WHEEL_TURN_ASSIST_REORIENT_THRESHOLD then -- Gently turn wheel towards player's aim
                spinTorque = -VEC_UP * WHEEL_TURN_STRENGTH:GetFloat() * mSignNoZero( rightDotAim )
            end

            phys:AddAngleVelocity( phys:WorldToLocalVector( spinTorque * groundMult * spindownMult ) )
        end

        if turnTorque then
            phys:AddAngleVelocity( phys:WorldToLocalVector( turnTorque * groundMult ) )
        end

        if wheelRightZAbs < WHEEL_UPRIGHT_THRESHOLD then continue end

        if isHorizontal then
            wheelRight = plyForward:Angle():Right()
            wheelRightZ = wheelRight[3]
        end

        local rightDot = isHorizontal and mSignNoZero( wheelRightZOriginal ) or VEC_UP:Dot( wheelRight )
        local angVel = phys:GetAngleVelocity()
        local forwardEff = wheelRight:Angle():Right()

        local torque = phys:WorldToLocalVector( -WHEEL_UPRIGHT_STRENGTH * rightDot * forwardEff )
        torque = torque - angVel * WHEEL_UPRIGHT_STABILIZE

        phys:AddAngleVelocity( torque )
    end
end )

timer.Create( "CFC_ULX_WheelGroundCheck", 0.2, 0, function()
    for i = wheelPropCount, 1, -1 do
        local wheel = wheelProps[i]

        if not IsValid( wheel ) then
            tableRemove( wheelProps, i )
            wheelPropCount = wheelPropCount - 1
            cmd.wheelPropCount = wheelPropCount

            continue
        end

        WHEEL_GROUND_TRACE_OFFSET = WHEEL_GROUND_TRACE_OFFSET or -VEC_UP * ( wheel:OBBMaxs()[3] + 10 )

        local wheelPos = wheel:GetPos()
        local tr = util.TraceLine( {
            start = wheelPos,
            endpos = wheelPos + WHEEL_GROUND_TRACE_OFFSET,
            filter = wheel
        } )

        if tr.Hit then
            wheel:SetGroundEntity( tr.Entity )
            wheel:AddFlags( FL_ONGROUND )
        else
            wheel:RemoveFlags( FL_ONGROUND )
        end
    end
end )
