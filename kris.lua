local kris = {}

function kris.init(mod)

  local GameVersion = require("src.core.GameVersion")
  local isGen2 = GameVersion.generation(GameVersion.get()) == 2

  local PaletteFX = require("src.render.PaletteFX")
  local Json = require("src.link.Json")
  local originalSpriteObp = PaletteFX.spriteObp
  local advancedPack = assert(PaletteFX.gbcPack())

  -- Sprite variant discovery
  -- ----------------------------------
  local SPRITES_DIR = "assets/sprites"

  local function readMeta(key)
    if not key then return {} end
    local metaPath = SPRITES_DIR .. "/" .. key .. "/meta.json"
    if mod.assets:info(metaPath) then
      local ok, decoded = pcall(Json.decode, mod:read(metaPath))
      if ok and type(decoded) == "table" then return decoded end
    end
    return {}
  end

  local function fileVariant(key, name, trueColor)
    if not key then return nil end
    local rel = SPRITES_DIR .. "/" .. key .. "/" .. name
    if mod.assets:info(rel) then
      return { path = rel, trueColor = trueColor }
    end
    return nil
  end

  local function byLabel(a, b)
    return a.label < b.label
  end

  local function toChoicePairs(list)
    local out = {}
    for _, entry in ipairs(list) do
      table.insert(out, { entry.label, entry.key })
    end
    return out
  end

  local function defaultKey(list, preferred)
    for _, entry in ipairs(list) do
      if entry.key == preferred then return preferred end
    end
    return list[1] and list[1].key or preferred
  end

  local battleSpriteVariants = {}
  local frontSpriteVariants = {}
  local battleChoices = {}
  local frontChoices = {}

  -- Groups folders by an optional "character" field in meta.json, so the
  -- options menu can offer "pick a character, then pick that character's
  -- own variants" instead of one flat, ungrouped list. A folder that
  -- doesn't define "character" becomes its own single-variant character
  -- group (falling back to its label, then its folder key) -- this is
  -- exactly today's behavior, so every existing sprite folder keeps
  -- working unchanged. -Elvie
  -- --------------------------------------------------
  local frontFoldersByCharacter = {}
  local battleFoldersByCharacter = {}

  local function addToCharacter(byCharacter, character, entry)
    byCharacter[character] = byCharacter[character] or {}
    table.insert(byCharacter[character], entry)
  end

  for _, key in ipairs(mod.assets:list(SPRITES_DIR)) do
    local info = mod.assets:info(SPRITES_DIR .. "/" .. key)
    if info and info.type == "directory" then
      local meta = readMeta(key)
      local label = meta.label or key:upper()
      local character = (type(meta.character) == "string" and meta.character ~= "")
        and meta.character or label

      local back = fileVariant(key, "back.png", false)
      local backColor = fileVariant(key, "backColor.png", true)
      local front = fileVariant(key, "front.png", false)
      local frontColor = fileVariant(key, "frontColor.png", true)

      if back or backColor then
        battleSpriteVariants[key] = { dmg = back or backColor, fullColor = backColor or back }
        local entry = { label = label, key = key }
        table.insert(battleChoices, entry)
        addToCharacter(battleFoldersByCharacter, character, entry)
      end
      if front or frontColor then
        frontSpriteVariants[key] = { dmg = front or frontColor, fullColor = frontColor or front }
        local entry = { label = label, key = key }
        table.insert(frontChoices, entry)
        addToCharacter(frontFoldersByCharacter, character, entry)
      end
    end
  end

  table.sort(battleChoices, byLabel)
  table.sort(frontChoices, byLabel)
  for _, byCharacter in ipairs({ frontFoldersByCharacter, battleFoldersByCharacter }) do
    for _, entries in pairs(byCharacter) do
      table.sort(entries, byLabel)
    end
  end

  -- The character list itself: every character with a front and/or battle
  -- folder, deduplicated. -Elvie
  -- --------------------------------------------------
  local characterSet = {}
  for character in pairs(frontFoldersByCharacter) do characterSet[character] = true end
  for character in pairs(battleFoldersByCharacter) do characterSet[character] = true end
  local characterChoices = {}
  for character in pairs(characterSet) do
    table.insert(characterChoices, { label = character, key = character })
  end
  table.sort(characterChoices, byLabel)

  local function sanitizeKey(s)
    return (s:gsub("%W", "_"))
  end

  -- Every folder of each character, front and battle alike, in label
  -- order: what a look falls back through, sheet by sheet. -Elvie
  -- --------------------------------------------------
  local foldersOf = {}
  for _, byCharacter in ipairs({ frontFoldersByCharacter, battleFoldersByCharacter }) do
    for character, entries in pairs(byCharacter) do
      foldersOf[character] = foldersOf[character] or {}
      for _, entry in ipairs(entries) do
        local seen = false
        for _, other in ipairs(foldersOf[character]) do seen = seen or other.key == entry.key end
        if not seen then table.insert(foldersOf[character], entry) end
      end
    end
  end
  for _, entries in pairs(foldersOf) do table.sort(entries, byLabel) end

  -- The selected folder first, then the character's others. -Elvie
  local function chainFor(character, selected)
    local chain = {}
    if selected then chain[1] = selected end
    for _, entry in ipairs(foldersOf[character] or {}) do
      if entry.key ~= selected then chain[#chain + 1] = entry.key end
    end
    return chain
  end

  -- Resolves which folder to actually use for the given character and
  -- asset type: the character's only folder if it has just one, or its
  -- own sub-option's current value if it has several. -Elvie
  -- --------------------------------------------------
  local function resolveCharacterFolder(byCharacter, character, optionKeyPrefix)
    local entries = byCharacter[character]
    if not entries or #entries == 0 then return nil end
    if #entries == 1 then return entries[1].key end
    local optionKey = optionKeyPrefix .. sanitizeKey(character)
    local selected = mod.options:get(optionKey)
    for _, entry in ipairs(entries) do
      if entry.key == selected then return selected end
    end
    return entries[1].key
  end

  local function resolveFrontKey(character)
    return resolveCharacterFolder(frontFoldersByCharacter, character, "frontSpriteFor_")
  end

  local function resolveBattleKey(character)
    return resolveCharacterFolder(battleFoldersByCharacter, character, "battleSpriteFor_")
  end

  -- Resolves the default front sprite path for whichever character is
  -- currently selected, without assuming a specific folder exists. Falls
  -- back to the first available front variant if nothing resolves. -Elvie
  -- --------------------------------------------------
  local function defaultFrontPath()
    local character = mod.options:get("character")
    local selected = resolveFrontKey(character)
    local variant = selected and frontSpriteVariants[selected] and frontSpriteVariants[selected]["dmg"]
    if variant then return mod.assets:path(variant.path) end
    local fallbackKey = frontChoices[1] and frontChoices[1].key
    local fallbackVariant = fallbackKey and frontSpriteVariants[fallbackKey]
      and frontSpriteVariants[fallbackKey]["dmg"]
    return fallbackVariant and mod.assets:path(fallbackVariant.path) or nil
  end

  -- Define mod options
  -- CHARACTER comes first; its own front/battle sprite choices are added
  -- below, one pair per character, each hidden until that character is
  -- selected. -Elvie
  -- ----------------------------------
  local optionRows = {
    {
      key = "character", type = "choice", label = "CHARACTER",
      choices = toChoicePairs(characterChoices), default = defaultKey(characterChoices, "original")
    },
  }

  -- A character only gets a sprite sub-option if it actually has more than
  -- one folder to choose between -- a single-folder character resolves
  -- straight to it, so there's no pointless one-choice row in the menu. -Elvie
  -- --------------------------------------------------
  for _, character in ipairs(characterChoices) do
    local key = character.key
    local fronts = frontFoldersByCharacter[key]
    local battles = battleFoldersByCharacter[key]
    if fronts and #fronts > 1 then
      table.insert(optionRows, {
        key = "frontSpriteFor_" .. sanitizeKey(key), type = "choice", label = "FRONT SPRITE",
        choices = toChoicePairs(fronts), default = defaultKey(fronts, "original"),
        visible_if = { key = "character", equals = key },
      })
    end
    if battles and #battles > 1 then
      table.insert(optionRows, {
        key = "battleSpriteFor_" .. sanitizeKey(key), type = "choice", label = "BATTLE SPRITE",
        choices = toChoicePairs(battles), default = defaultKey(battles, "original"),
        visible_if = { key = "character", equals = key },
      })
    end
  end

  table.insert(optionRows, {
    key = "colorMode", type = "choice", label = "COLOR PALETTE",
    choices = {
      {"DMG COMPATIBLE", "dmg"},
      {"FULL COLOR", "fullColor"}},
      default = "dmg"
  })

  -- GENDER (Crystal): the look's own way, where the boy/girl choice is
  -- skipped and the look replaces Chris, or MY SAVE, where the choice
  -- stays and the look replaces whichever player the save picks. -Elvie
  table.insert(optionRows, {
    key = "gender", type = "choice", label = "GENDER",
    choices = { { "LOOK", "look" }, { "MY SAVE", "save" } }, default = "look",
  })

  -- RIVAL: a character for Blue (Red/Blue/Yellow) or Silver (Gold/Silver/
  -- Crystal), with a RIVAL LOOK row when it has more than one front
  -- sprite. OFF keeps the game's own rival. -Elvie
  local RIVAL_OFF = "_off"
  local rivalChoices = toChoicePairs(characterChoices)
  table.insert(rivalChoices, 1, { "OFF", RIVAL_OFF })
  table.insert(optionRows, {
    key = "rival", type = "choice", label = "RIVAL", choices = rivalChoices, default = RIVAL_OFF,
  })
  for _, character in ipairs(characterChoices) do
    local fronts = frontFoldersByCharacter[character.key]
    if fronts and #fronts > 1 then
      table.insert(optionRows, {
        key = "rivalLookFor_" .. sanitizeKey(character.key), type = "choice", label = "RIVAL LOOK",
        choices = toChoicePairs(fronts), default = defaultKey(fronts, "original"),
        visible_if = { key = "rival", equals = character.key },
      })
    end
  end

  mod.options:define(optionRows)

  -- Assign player sprite based on mod options
  -- -----------------------------------------
  mod.hooks:wrap("player.sprite", function(next, path, ctx)
    path = next(path,ctx)
    if ctx.demo then return path end

    local colorMode = mod.options:get("colorMode")
    local character = mod.options:get("character")
    local variants, selected

    if ctx.side == "back" then
      variants = battleSpriteVariants
      selected = resolveBattleKey(character)
    elseif ctx.side == "front" then
      variants = frontSpriteVariants
      selected = resolveFrontKey(character)
    else
      return path
    end

    -- the selected folder's pic, else the character's other folders' -Elvie
    local variant
    for _, key in ipairs(chainFor(character, selected)) do
      variant = variant or (variants[key] and variants[key][colorMode])
    end

    if variant then
      ctx.trueColor = variant.trueColor
      return mod.assets:path(variant.path)

    end
    return path
  end)

  -- Scale sprite
  -- ---------------------------------------------------
  for label, colorModes in pairs(battleSpriteVariants) do
    for colorMode, asset in pairs(colorModes) do
      local labelId = label .. "_" .. colorMode
      mod.content.battle_sprite_scales:register(labelId, {
        path = mod.assets:path(asset.path),
	scale = 1.0,
      })
    end
  end
  

  -- Recoloring the "advanced" color palette
  -- Falls back to this default unless the selected sprite folder
  -- provides its own via meta.json. -Elvie
  -- ------------------------------------------
  local DEFAULT_CRYSTAL_COLORS = {
    {255, 255, 255},
    {255, 173, 99},
    {1, 99, 198},
    {0, 0, 0}
  }

  local function isColorTable(t)
    if type(t) ~= "table" or #t ~= 4 then return false end
    for _, triplet in ipairs(t) do
      if type(triplet) ~= "table" or #triplet ~= 3 then return false end
      for _, v in ipairs(triplet) do
        if type(v) ~= "number" or v < 0 or v > 255 then return false end
      end
    end
    return true
  end

  -- Per-folder overworld, naming, and gender overrides
  -- Names and gender (the text) follow whichever folder is resolved for
  -- the selected character's front sprite, falling back to Crystal's
  -- defaults when a folder doesn't define them, and are read once at
  -- load: they need a restart. The overworld sprites and their colours
  -- follow the current choice live (see below). -Elvie
  -- --------------------------------------------------
  local DEFAULT_NAME_CHOICES = {"KRIS", "AMANDA", "JUANA", "JODI"}
  local DEFAULT_GENDER_MODE = "girl"
  local VALID_GENDER_MODES = { boy = true, girl = true, enby = true }

  local function isNonEmptyStringArray(t)
    if type(t) ~= "table" then return false end
    local count = 0
    for k, v in pairs(t) do
      if type(k) ~= "number" or type(v) ~= "string" or v == "" then return false end
      count = count + 1
    end
    return count > 0
  end

  local overworldKey = resolveFrontKey(mod.options:get("character"))
  local overworldMeta = readMeta(overworldKey)

  local nameChoices = isNonEmptyStringArray(overworldMeta.nameChoices)
    and overworldMeta.nameChoices or DEFAULT_NAME_CHOICES

  local genderMode = (type(overworldMeta.genderMode) == "string" and VALID_GENDER_MODES[overworldMeta.genderMode])
    and overworldMeta.genderMode or DEFAULT_GENDER_MODE

  -- Overworld sprite files and colours, resolved per file through the
  -- character's folders (the front sprite's folder first), then Crystal's
  -- stock assets. Rebuilt whenever the choice changes. -Elvie
  -- --------------------------------------------------
  local OVERWORLD_FILES = {
    walk = { "overworldWalk.png", "assets/overworld/crystalPlayer.png" },
    bike = { "overworldBike.png", "assets/overworld/crystalBike.png" },
    fishSide = { "overworldFishSide.png", "assets/overworld/crystalFishSide.png" },
    fishFront = { "overworldFishFront.png", "assets/overworld/crystalFishFront.png" },
    fishBack = { "overworldFishBack.png", "assets/overworld/crystalFishBack.png" },
  }

  local serial = 0
  local function resolveOverworld()
    local character = mod.options:get("character")
    local chain = chainFor(character, resolveFrontKey(character))
    local state = { files = {}, colors = DEFAULT_CRYSTAL_COLORS }
    for name, pair in pairs(OVERWORLD_FILES) do
      for _, key in ipairs(chain) do
        local variant = state.files[name] == nil and fileVariant(key, pair[1], false)
        if variant then state.files[name] = mod.assets:path(variant.path) end
      end
      state.files[name] = state.files[name] or mod.assets:path(pair[2])
    end
    for i = #chain, 1, -1 do
      local colors = readMeta(chain[i]).overworldColors
      if isColorTable(colors) then state.colors = colors end
    end
    serial = serial + 1
    state.group = "crystalPlayer" .. serial
    return state
  end
  local overworld = resolveOverworld()

  -- Kept for the sprite patches below, which set the starting sprites -Elvie
  local overworldWalk = overworld.files.walk
  local overworldBike = overworld.files.bike
  local overworldFishSide = overworld.files.fishSide
  local overworldFishFront = overworld.files.fishFront
  local overworldFishBack = overworld.files.fishBack

  -- Intercepts the sprite renderer if the sprite is assigned a matching palette source and applies the CRYSTAL_COLORS palette to the sprite. 
  -- Hands the request back to the original sprite renderer if any other sprite.
  -- The colours are the current choice's; the group changes with them so
  -- the recolour cache doesn't keep the old ones. -Elvie
  PaletteFX.spriteObp = function(spriteDef, seed)
    if spriteDef and spriteDef.paletteSource == "PLAYER_PALETTE" then
      return overworld.colors, overworld.group
      end
    
    if originalSpriteObp then
      return originalSpriteObp(spriteDef, seed)
      end
  end

  -- Same rendering interception but for Gen 2, gated on isGen2. This
  -- manifest also loads on plain Gen 1, and the engine unconditionally
  -- refuses to require any src.*.gen2.* module while a Gen 1 game is
  -- active (Loader.lua's crossGenerationDenial) -- an earlier unconditional
  -- version of this crashed mod load on Red/Blue/Yellow. Patched once here
  -- rather than in game.ready, since Palettes has no game-instance
  -- dependency and game.ready can fire more than once a session (dev
  -- hot-reload). -Elvie
  -- -----------------------------------------
  if isGen2 then
    local Palettes = require("src.world.gen2.Palettes")
    local originalSpritePalette = Palettes.spritePalette
    Palettes.spritePalette = function(data, daytime, spriteDef, objDef)
      if spriteDef and spriteDef.paletteSource == "PLAYER_PALETTE" then
        return overworld.colors
      end
      return originalSpritePalette(data, daytime, spriteDef, objDef)
    end
  end

  -- Live overworld
  -- The player is drawn with this mod's own renderers for the current
  -- choice, swapped in for the draw and put back after, so a change in
  -- the options shows straight away. -Elvie
  -- -----------------------------------------
  local SpriteRenderer = require("src.render.SpriteRenderer")
  local renderers -- { walk, bike, serial } for the current choice -Elvie
  local function rendererFor(kind)
    if not renderers or renderers.serial ~= serial then
      renderers = { serial = serial }
    end
    if renderers[kind] == nil then
      local def = { id = kind == "bike" and "SPRITE_RED_BIKE" or "SPRITE_RED", image = overworld.files[kind],
        frames = 6, walker = true, trueColor = false, paletteSource = "PLAYER_PALETTE" }
      local ok, r = pcall(SpriteRenderer.new, def, "player")
      if ok and r and isGen2 then r:setObjPalette(overworld.colors, overworld.group) end
      renderers[kind] = ok and r or false
    end
    return renderers[kind] or nil
  end

  if isGen2 then
    local Player = require("src.world.gen2.Player")
    local KIND = { SPRITE_CHRIS = "walk", SPRITE_CHRIS_BIKE = "bike" }
    -- with GENDER on MY SAVE, Kris too -Elvie
    local KRIS = { SPRITE_KRIS = "walk", SPRITE_KRIS_BIKE = "bike" }
    local originalDraw = Player.draw
    Player.draw = function(self, ...)
      local id = type(self.spriteDef) == "table" and self.spriteDef.id
      local kind = KIND[id] or (mod.options:get("gender") == "save" and KRIS[id])
      local r = kind and rendererFor(kind)
      if not r then return originalDraw(self, ...) end
      local saved = self.sprite
      self.sprite = r
      local ok, err = pcall(originalDraw, self, ...)
      self.sprite = saved
      if not ok then error(err, 0) end
    end
  else
    local Player = require("src.world.Player")
    local originalDraw = Player.draw
    Player.draw = function(self, ...)
      local s1, s2, fish = self.sprite, self.bikeSprite, self.fishTiles
      self.sprite = rendererFor("walk") or s1
      self.bikeSprite = (s2 and rendererFor("bike")) or s2
      if fish then
        local f = overworld.files
        self.fishTiles = { down = f.fishFront, up = f.fishBack, left = f.fishSide, right = f.fishSide }
      end
      local ok, err = pcall(originalDraw, self, ...)
      self.sprite, self.bikeSprite, self.fishTiles = s1, s2, fish
      if not ok then error(err, 0) end
    end
  end

  -- The rival
  -- The rival's battle pics and walking sprite, written into the game's
  -- own trainer and sprite records (the originals are kept to put back).
  -- Pics: rivalEarly.png, rivalLate.png and rivalChampion.png (each with a
  -- Color version) where a folder has them, else its front sprite. The
  -- walking sprite needs overworldWalk.png somewhere in the character's
  -- folders, coloured with its overworldColors; it changes on the next
  -- map, as the game sets up who's on a map when you enter it. -Elvie
  -- --------------------------------------------------
  -- Gen 1: OPP_RIVAL1-3 in data.trainers; Gen 2: RIVAL1-2 in
  -- data.gen2Trainers.classes, whose pic wins over the menu_gfx one -Elvie
  local RIVAL_PICS = isGen2
    and { { "RIVAL1", "rivalEarly" }, { "RIVAL2", "rivalLate" } }
    or { { "OPP_RIVAL1", "rivalEarly" }, { "OPP_RIVAL2", "rivalLate" }, { "OPP_RIVAL3", "rivalChampion" } }
  local RIVAL_SPRITE = isGen2 and "SPRITE_RIVAL" or "SPRITE_BLUE"
  local rivalColors = DEFAULT_CRYSTAL_COLORS
  local savedRecords = {} -- [record] = { field = original } -Elvie

  local function liveData()
    local ok, game = pcall(function() return mod.game end)
    return ok and type(game) == "table" and type(game.data) == "table" and game.data or nil
  end

  local function setField(record, field, value)
    savedRecords[record] = savedRecords[record] or {}
    if savedRecords[record][field] == nil then
      savedRecords[record][field] = { value = record[field] }
    end
    record[field] = value
  end

  local function restoreRecords()
    for record, fields in pairs(savedRecords) do
      for field, old in pairs(fields) do record[field] = old.value end
    end
    savedRecords = {}
  end

  local function applyRival()
    restoreRecords()
    local data = liveData()
    local character = mod.options:get("rival")
    if not data or character == nil or character == RIVAL_OFF or not foldersOf[character] then return end
    local selected = resolveCharacterFolder(frontFoldersByCharacter, character, "rivalLookFor_")
    local chain = chainFor(character, selected)
    local colorMode = mod.options:get("colorMode")
    local function pic(name)
      for _, key in ipairs(chain) do
        local dmg, color = fileVariant(key, name .. ".png", false), fileVariant(key, name .. "Color.png", true)
        local variant = (dmg or color) and ({ dmg = dmg or color, fullColor = color or dmg })[colorMode]
        if variant then return variant end
      end
      for _, key in ipairs(chain) do
        local variant = frontSpriteVariants[key] and frontSpriteVariants[key][colorMode]
        if variant then return variant end
      end
      return nil
    end
    local records = isGen2 and data.gen2Trainers and data.gen2Trainers.classes or data.trainers
    for _, pair in ipairs(RIVAL_PICS) do
      local record = type(records) == "table" and records[pair[1]]
      local variant = pic(pair[2])
      if type(record) == "table" and variant then
        setField(record, "pic", mod.assets:path(variant.path))
        setField(record, "trueColor", variant.trueColor and true or false)
      end
    end
    local sprites = isGen2 and data.gen2Sprites or data.sprites
    local sprite = type(sprites) == "table" and sprites[RIVAL_SPRITE]
    local walk
    for _, key in ipairs(chain) do walk = walk or fileVariant(key, "overworldWalk.png", false) end
    if type(sprite) == "table" and walk then
      rivalColors = DEFAULT_CRYSTAL_COLORS
      for i = #chain, 1, -1 do
        local colors = readMeta(chain[i]).overworldColors
        if isColorTable(colors) then rivalColors = colors end
      end
      setField(sprite, "image", mod.assets:path(walk.path))
      setField(sprite, "trueColor", false)
      setField(sprite, "paletteSource", "RIVAL_PALETTE")
    end
  end

  -- the rival's colours, the same way as the player's -Elvie
  local playerObp = PaletteFX.spriteObp
  PaletteFX.spriteObp = function(spriteDef, seed)
    if spriteDef and spriteDef.paletteSource == "RIVAL_PALETTE" then
      return rivalColors, "crystalRival" .. serial
    end
    return playerObp(spriteDef, seed)
  end
  if isGen2 then
    local Palettes = require("src.world.gen2.Palettes")
    local playerPalette = Palettes.spritePalette
    Palettes.spritePalette = function(data, daytime, spriteDef, objDef)
      if spriteDef and spriteDef.paletteSource == "RIVAL_PALETTE" then return rivalColors end
      return playerPalette(data, daytime, spriteDef, objDef)
    end
  end

  mod.events:on("game.ready", function()
    savedRecords = {}
    applyRival()
  end)

  mod.events:on("mod.options_changed", function(change)
    if type(change) ~= "table" or change.mod ~= mod.id then return end
    local key = type(change.key) == "string" and change.key or ""
    if key == "character" or key:sub(1, 15) == "frontSpriteFor_" then
      overworld = resolveOverworld()
    end
    if key == "rival" or key:sub(1, 14) == "rivalLookFor_" or key == "colorMode" then
      serial = serial + 1
      applyRival()
    end
  end)
    
  -- Gen 2 Trainer Card
  -- This can probably be simplified later when the field registry is available
  -- for gen 2.
  --
  -- The portrait isn't a normal image on this screen: TrainerCard draws it
  -- from 35 individual 8x8 tiles baked into specific indices of the SAME
  -- tilesheet the frame itself uses (confirmed from TrainerCard.lua's own
  -- comments -- even one of the frame's own tiles, the top-right notch, is
  -- borrowed from that 35-tile range). Replacing the whole tilesheet to
  -- swap the portrait meant also having to recreate the frame's tile
  -- layout exactly right, and any mismatch there is what produced a
  -- fragmented, scrambled look. Keeping the real vanilla tilesheet (frame,
  -- dividers, ID No tiles, all correct by construction, straight from the
  -- game's own extracted data) and overriding drawPortrait to paint the
  -- resolved front sprite directly, as a normal image, avoids that whole
  -- class of tile-index bugs entirely -- a "blank card + overlay," just
  -- implemented as a method override instead of a second image file. -Elvie
  -- -----------------------------------------------
  mod.content.screens:register("Gen2TrainerCard", {
    new = function(game, opts)
      local TrainerCard = require("src.ui.gen2.TrainerCard")
      local instance = TrainerCard.new(game, opts)

      -- Portrait tile box: (14,1) to (18,7) in 8px tiles = 40x56 pixels.
      -- A folder can optionally provide trainerCard.png/trainerCardColor.png
      -- (checked in the same folder as the front sprite) purpose-built for
      -- this box; if it doesn't, this falls back to the same front sprite
      -- used everywhere else -- same fallback pattern as the overworld
      -- files above. Drawn at native size, centered, relying on
      -- transparency around the character rather than scaling to fill --
      -- easy to swap back to scale-to-fill (boxW / iw, boxH / ih) if this
      -- looks worse in practice for art that isn't purpose-built. -Elvie
      -- -----------------------------------------------
      -- The current choice, through the character's folders: the first
      -- with a trainer card portrait, else the first with a front sprite. -Elvie
      local colorMode = mod.options:get("colorMode")
      local character = mod.options:get("character")
      local portraitVariant, frontVariant
      for _, key in ipairs(chainFor(character, resolveFrontKey(character))) do
        local dedicatedDmg = fileVariant(key, "trainerCard.png", false)
        local dedicatedColor = fileVariant(key, "trainerCardColor.png", true)
        local dedicated = (dedicatedDmg or dedicatedColor)
          and { dmg = dedicatedDmg or dedicatedColor, fullColor = dedicatedColor or dedicatedDmg }
        portraitVariant = portraitVariant or (dedicated and dedicated[colorMode])
        frontVariant = frontVariant or (frontSpriteVariants[key] and frontSpriteVariants[key][colorMode])
      end
      portraitVariant = portraitVariant or frontVariant

      instance.drawPortrait = function()
        if not portraitVariant then return end
        local image = mod.assets:image(portraitVariant.path)
        if not image then return end
        local iw, ih = image:getDimensions()
        local boxX, boxY, boxW, boxH = 14 * 8, 1 * 8, 40, 56
        local drawX = boxX + (boxW - iw) / 2
        local drawY = boxY + (boxH - ih) / 2
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(image, drawX, drawY)
      end

      return instance
    end,
  })
   
  -- New game naming options
  -- Pulled from nameChoices above instead of a fixed list, and gated on
  -- isGen2 -- Gen 2's own naming is handled separately below. -Elvie
  -- ---------------------------
  if not isGen2 then
    mod.content.field:override("boot", {
      namePresets = {
        player = nameChoices
      }
    })
  end
  
  -- Gen 2 Naming options and forcing true color of player sprite.
  -- This can likely be reduced when the field registry is
  -- hooked into gen 2 via the mod api.
  -- Pulled from nameChoices above too. -Elvie
  -- --------------------------------------------------
  mod.events:on("game.ready", function(ev)
    local game = ev.game
    local palettes = game.data.gen2Palettes
    game.data.field = game.data.field or {}
    game.data.field.boot = game.data.field.boot or {}
    game.data.field.boot.namePresets = {
      player = nameChoices
    }
    if palettes and palettes.trainers then
      palettes.trainers.CAL = nil
    end
  end)

  -- Crystal shows a native gender-choice screen when its sprite cache
  -- carries Kris data (Gold/Silver never do, so they never get the step).
  -- Appearance here comes entirely from the selected sprite folder, so
  -- this strips that step out -- a no-op on Gen 1 and Gold/Silver, where
  -- it never existed. Skipping it defaults gender to "male" (Save.lua's
  -- own fallback), which is what SPRITE_CHRIS above is patched for. -Elvie
  -- --------------------------------------------------
  mod.hooks:wrap("intro.oak_speech.build", function(next, steps, speech)
    steps = next(steps, speech)
    -- GENDER on MY SAVE keeps the choice -Elvie
    if mod.options:get("gender") == "save" then return steps end
    return mod.ui.removeStep(steps, "gender_select")
  end)

  -- Title screen player. Gated on isGen2 for the same reason as the other
  -- field patches above. Uses defaultFrontPath so it follows whichever
  -- character is actually selected. -Elvie
  -- ----------------------
  if not isGen2 then
    local krisEdition = mod.assets:path("assets/menus/krisEdition.png")
    mod.content.field:patch("boot", {
      title = {
        player = defaultFrontPath(),
        versionRibbon = krisEdition,
      },
    })
  end

  -- Hands the resolved config back to main.lua so it can choose
  -- girlMode, nbMode, or neither. -Elvie
  -- --------------------------------------------------
  return {
    nameChoices = nameChoices,
    genderMode = genderMode,
  }

end

return kris
