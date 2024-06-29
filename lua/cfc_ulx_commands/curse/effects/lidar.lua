local EFFECT_NAME = "Lidar"
local DOT_MAX = 15000
local DOTS_PER_FRAME = 25
local DOT_SIZE = 5
local DOT_SPREAD = 45
local SKY_COLOR = Color( 130, 230, 230, 255 )



local DOT_SIZE_HALF = DOT_SIZE / 2
local DOT_SPREAD_HALF = DOT_SPREAD / 2

local dots = {}
local dotCount = 0
local dotHead = 1
local placingDots = false
local showDotHint = false

local utilTraceLine = util.TraceLine
local playerGetAll = player.GetAll
local renderGetSurfaceColor = render.GetSurfaceColor
local drawSimpleText = draw.SimpleText
local surfaceSetDrawColor = surface.SetDrawColor
local surfaceDrawRect = surface.DrawRect


local function spreadDirFast( ang, right, up )
    ang = Angle( ang.p, ang.y, ang.r )
    ang:RotateAroundAxis( right, math.Rand( -DOT_SPREAD_HALF, DOT_SPREAD_HALF ) )
    ang:RotateAroundAxis( up, math.Rand( -DOT_SPREAD_HALF, DOT_SPREAD_HALF ) )

    return ang:Forward()
end

local function addDot( startPos, dir, filter )
    local endPos = startPos + dir * 50000
    local tr = utilTraceLine( {
        start = startPos,
        endpos = endPos,
        filter = filter,
    } )

    if not tr.Hit then return end

    local hitPos = tr.HitPos
    local color

    if tr.HitSky then
        color = SKY_COLOR
    else
        color = renderGetSurfaceColor( hitPos - dir * 5, hitPos + dir * 5 )
        color = Color( color.x * 255, color.y * 255, color.z * 255, 255 )
    end

    local dot = dots[dotHead]
    dot.pos = hitPos
    dot.color = color

    dotHead = dotHead + 1

    -- Keep incrementing dotCount until we reach DOT_MAX.
    -- Keep incrementing dotHead until the max is reached, then wrap around to 1.
    -- This lets us replace old dots without needing to shift indices around with table.remove().
    if dotCount < DOT_MAX then
        dotCount = dotCount + 1

        if dotCount == DOT_MAX then
            dotHead = 1
        end
    elseif dotHead > dotCount then
        dotHead = 1
    end
end

local function addDots( eyePos, eyeAng )
    local eyeRight = eyeAng:Right()
    local eyeUp = eyeAng:Up()
    local filter = playerGetAll()

    for _ = 1, DOTS_PER_FRAME do
        local dir = spreadDirFast( eyeAng, eyeRight, eyeUp )

        addDot( eyePos, dir, filter )
    end
end

local function prepareDotsForDrawing()
    for i = 1, dotCount do
        local dot = dots[i]
        local pos = dot.pos

        local scrPos = pos:ToScreen()
        local visible = scrPos.visible

        dot.visible = visible

        if visible then
            dot.x = scrPos.x
            dot.y = scrPos.y
        end
    end
end

local function drawDots()
    surfaceSetDrawColor( 0, 0, 0, 255 )
    surfaceDrawRect( 0, 0, ScrW(), ScrH() )

    for i = 1, dotCount do
        local dot = dots[i]

        if dot.visible then
            local color = dot.color

            surfaceSetDrawColor( color )
            surfaceDrawRect( dot.x - DOT_SIZE_HALF, dot.y - DOT_SIZE_HALF, DOT_SIZE, DOT_SIZE )
        end
    end
end


do
    for i = 1, DOT_MAX do
        dots[i] = {}
    end
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        placingDots = false
        showDotHint = true
        dotCount = 0
        dotHead = 1

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "RenderScene", "CustomRender", function()
            local eyePos = cursedPly:EyePos()
            local eyeAng = cursedPly:EyeAngles()

            if placingDots then
                addDots( eyePos, eyeAng )
            end

            -- Vector:ToScreen() needs a 3D context, while surface.DrawRect() needs a 2D context.
            cam.Start3D()
                prepareDotsForDrawing()
            cam.End3D()

            cam.Start2D()
                drawDots()
            cam.End2D()

            if showDotHint then
                cam.Start2D()
                    drawSimpleText( "Hold E to place dots", "DermaLarge", ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                cam.End2D()
            end

            return true
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "KeyPress", "Input", function( _, key )
            if not IsFirstTimePredicted() then return end

            if key == IN_USE then
                placingDots = true
                showDotHint = false
            end
        end )

        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "KeyRelease", "Input", function( _, key )
            if not IsFirstTimePredicted() then return end

            if key == IN_USE then
                placingDots = false
            end
        end )
    end,

    onEnd = function()
        if SERVER then return end
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {},
    groups = {},
    incompatibleGroups = {},
} )
