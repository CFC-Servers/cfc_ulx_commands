local STRUGGLE_AMOUNT = CreateConVar( "cfc_ulx_propify_struggle_amount", 30, FCVAR_REPLICATED, "How much a propified player must struggle to escape being picked up (default 30, set to 0 to disallow struggling)", 0, 50000 )

local STRUGGLE_BAR_WIDTH = 0.2
local STRUGGLE_BAR_HEIGHT = 0.04
local STRUGGLE_BAR_UP = 0.4

hook.Add( "PostRenderVGUI", "CFC_ULX_PropifyStruggleBar", function()
    local ply = LocalPlayer()

    if not IsValid( ply ) then return end

    local isGrabbed = ply:GetNWBool( "propifyGrabbed" )

    if not isGrabbed then return end

    local struggleAmountMax = STRUGGLE_AMOUNT:GetInt()

    if struggleAmountMax == 0 then return end

    local struggleAmount = ply:GetNWInt( "propifyStruggle" )
    local struggleProgress = struggleAmount / struggleAmountMax

    local scrW = ScrW()
    local scrH = ScrH()

    local x = scrW*( 0.5 - STRUGGLE_BAR_WIDTH/2 )
    local y = scrH*( 1 - STRUGGLE_BAR_UP/2 - STRUGGLE_BAR_HEIGHT/2 )

    surface.SetDrawColor( 230, 230, 230, 255 )
    surface.DrawRect( x, y, scrW*STRUGGLE_BAR_WIDTH, scrH*STRUGGLE_BAR_HEIGHT )

    surface.SetDrawColor( 255, 0, 0, 255 )
    surface.DrawRect( x, y, scrW*STRUGGLE_BAR_WIDTH*struggleProgress, scrH*STRUGGLE_BAR_HEIGHT )

    local struggleKey = input.LookupBinding( "+use" ) or "e"
    struggleKey = string.upper( struggleKey )

    surface.SetTextColor( 255, 200, 200, 255 )
    surface.SetFont( "CloseCaption_Bold" )
    surface.SetTextPos( x, y - 32 )
    surface.DrawText( "Press " .. struggleKey .. " to struggle!" )
end )

