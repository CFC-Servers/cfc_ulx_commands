AddCSLuaFile( "cfc_ulx_commands/curse/sh_utils.lua" )
AddCSLuaFile( "cfc_ulx_commands/curse/cl_utils.lua" )

include( "cfc_ulx_commands/curse/sh_utils.lua" )

if SERVER then
    include( "cfc_ulx_commands/curse/sv_utils.lua" )
else
    include( "cfc_ulx_commands/curse/cl_utils.lua" )
end


local effects_modules = file.Find( "cfc_ulx_commands/curse/effects/*.lua", "LUA" )

for _, fileName in ipairs( effects_modules ) do
    AddCSLuaFile( "cfc_ulx_commands/curse/effects/" .. fileName )
    include( "cfc_ulx_commands/curse/effects/" .. fileName )
end
