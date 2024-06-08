-- One-time shuffle (all materials will be shuffled, so no chance setting)
local EFFECT_NAME = "TextureShuffle"

-- Continuous shuffle
local EFFECT_NAME_CONTINUOUS = "TextureShuffleContinuous"
local SHUFFLE_INTERVAL = 5
local SHUFFLE_CHANCE = 0.1 -- Per material
local ENT_SCRAPE_INTERVAL = 10 -- How often to scrape materials from entities, increasing the material pool


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

globals._originalTextures = globals._originalTextures or {}
globals._originalTexturesList = globals._originalTexturesList or {}
globals._scrapedMaterialsList = globals._scrapedMaterialsList or {}
globals._modifiedMaterials = globals._modifiedMaterials or {}
globals._errorMaterialNames = globals._errorMaterialNames or {}

local originalTextures = globals._originalTextures
local originalTexturesList = globals._originalTexturesList
local scrapedMaterialsList = globals._scrapedMaterialsList
local modifiedMaterials = globals._modifiedMaterials
local errorMaterialNames = globals._errorMaterialNames



local function getOriginalTexture( mat )
    local matName = mat:GetName()
    local texture = originalTextures[matName]
    if texture then return texture end

    texture = mat:GetTexture( "$basetexture" )
    originalTextures[matName] = texture
    table.insert( originalTexturesList, texture )
    table.insert( scrapedMaterialsList, mat )

    return texture
end

-- When scraping materials repeatedly via material name, opt for this to reduce memory waste from new Material objects being made.
-- Will return nil if the material could not be found.
local function getOriginalTextureFromName( matName )
    local texture = originalTextures[matName]
    if texture then return texture end

    if errorMaterialNames[matName] then return end -- Avoid calling Material() more than needed.

    local mat = Material( matName )

    if mat:IsError() then
        errorMaterialNames[matName] = true

        return -- Don't cache error materials, so they don't waste memory or fill the 'deck' with broken textures.
    end

    return getOriginalTexture( mat )
end

local function changeTexture( mat, texture )
    getOriginalTexture( mat )
    mat:SetTexture( "$basetexture", texture )
    modifiedMaterials[mat:GetName()] = mat
end

local function revertTextures()
    for matName, mat in pairs( modifiedMaterials ) do
        mat:SetTexture( "$basetexture", getOriginalTexture( mat ) )
        modifiedMaterials[matName] = nil
    end
end

local function shuffleTexture( mat )
    local texture = originalTexturesList[math.random( 1, #originalTexturesList )]
    changeTexture( mat, texture )
end

local function scrapeEntTextures( ent )
    local mats = ent:GetMaterials()

    for _, matName in ipairs( mats ) do
        getOriginalTextureFromName( matName )
    end

    local matOverride = ent:GetMaterial()

    if matOverride ~= "" then
        getOriginalTextureFromName( matOverride )
    end
end

local function scrapeBrushes()
    if globals._hasScrapedBrushes then return end

    globals._hasScrapedBrushes = true

    for _, surf in ipairs( game.GetWorld():GetBrushSurfaces() ) do
        getOriginalTexture( surf:GetMaterial() )
    end
end


-- One-time shuffle effect
CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        scrapeBrushes()

        for _, ent in ipairs( ents.GetAll() ) do
            scrapeEntTextures( ent )
        end

        for _, mat in ipairs( scrapedMaterialsList ) do
            shuffleTexture( mat )
        end
    end,

    onEnd = function()
        if SERVER then return end

        revertTextures()
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {
        EFFECT_NAME_CONTINUOUS,
    },
    groups = {
        "Textures",
    },
    incompatibleGroups = {
        "Textures",
    },
} )


-- Continuous shuffle effect
CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME_CONTINUOUS,

    onStart = function( cursedPly )
        if SERVER then return end

        scrapeBrushes()

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME_CONTINUOUS, "ShuffleTextures", SHUFFLE_INTERVAL, 0, function()
            for _, mat in ipairs( scrapedMaterialsList ) do
                if SHUFFLE_CHANCE == 1 or math.Rand( 0, 1 ) <= SHUFFLE_CHANCE then
                    shuffleTexture( mat )
                end
            end
        end )

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME_CONTINUOUS, "ScrapeEntTextures", ENT_SCRAPE_INTERVAL, 0, function()
            for _, ent in ipairs( ents.GetAll() ) do
                scrapeEntTextures( ent )
            end
        end )
    end,

    onEnd = function()
        if SERVER then return end

        revertTextures()
    end,

    minDuration = 60,
    maxDuration = 120,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatibileEffects = {
        EFFECT_NAME
    },
    groups = {
        "Textures",
    },
    incompatibleGroups = {
        "Textures",
    },
} )
