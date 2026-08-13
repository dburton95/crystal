local kris = {}

function kris.init(mod)


  local PaletteFX = require("src.render.PaletteFX")
  local originalSpriteObp = PaletteFX.spriteObp
  local advancedPack = assert(PaletteFX.gbcPack())
  

  -- Define mod options
  -- ----------------------------------
  mod.options:define({
    {
      key = "battleSprite", type = "choice", label = "BATTLE SPRITE",
        choices = {
      	  {"ORIGINAL", "original"},
	  {"DARIO", "dario"},
	  {"ARALE", "arale"},
	  {"SYGNA", "sygna"},
	  {"SYGNA ZOOM", "sygnaZoom"},
	  {"ROCKET A", "rocketA"},
	  {"ROCKET A ZOOM", "rocketAZoom"},
	  {"ROCKET B", "rocketB"},
	  {"ROCKET B ZOOM", "rocketBZoom"},
	  {"HG/SS", "hgss"},
	}, default = "original"
    },
    {
      key = "frontSprite", type = "choice", label = "TRAINER CARD",
        choices = {
          {"ORIGINAL", "original"},
	  {"ROCKET A", "rocketA"},
	  {"ROCKET B", "rocketB"},
      {"SYGNA", "sygna"},
      {"SYGNA ALT", "sygnaAlt"},
	}, default = "original"
    },
    {
     key = "colorMode", type = "choice", label = "COLOR PALETTE",
       choices = {
         {"DMG COMPATIBLE", "dmg"},
	 {"FULL COLOR", "fullColor"}},
	 default = "dmg"}
  })

  local battleSpriteVariants = {
    dario = {
      dmg = { path = "assets/back/stadiumBack.png", trueColor = false},
      fullColor = { path = "assets/back/stadiumBackColor.png", trueColor = true},
    },
    arale = {
      dmg = {path = "assets/back/stadiumBack.png", trueColor =false},
      fullColor = {path = "assets/back/stadiumBackAlt.png", trueColor = true},
    },
    original = {
      dmg = {path = "assets/back/originalBack.png", trueColor = false},
      fullColor = {path = "assets/back/originalBackColor.png", trueColor = true},
    },
    sygna = {
      dmg = {path = "assets/back/sygnaBack.png", trueColor = false},
      fullColor = {path = "assets/back/sygnaBackColor.png", trueColor = true},
    },
    sygnaZoom = {
      dmg = {path = "assets/back/sygnaZoom.png", trueColor = false},
      fullColor = {path = "assets/back/sygnaZoomColor.png", trueColor = true},
    },
    rocketA = {
      dmg = {path = "assets/back/rocketBackA.png", trueColor = false},
      fullColor = {path = "assets/back/rocketBackColorA.png", trueColor = true},
    },
    rocketAZoom = {
      dmg = {path = "assets/back/rocketZoomA.png", trueColor = false},
      fullColor = {path = "assets/back/rocketZoomColorA.png", trueColor = true},
    },
    rocketB = {
      dmg = {path = "assets/back/rocketBackB.png", trueColor = false},
      fullColor = {path = "assets/back/rocketBackColorB.png", trueColor = true},
    },
    rocketBZoom = {
      dmg = {path = "assets/back/rocketZoomB.png", trueColor = false},
      fullColor = {path = "assets/back/rocketZoomColorB.png", trueColor = true},
    },
    hgss = {
      dmg = {path = "assets/back/hgssBack.png", trueColor = false},
      fullColor = {path = "assets/back/hgssBackColor.png", trueColor = true},
    },
  }

  local frontSpriteVariants = {
    original = {
      dmg = {path = "assets/front/originalFront.png", trueColor = false},
      fullColor = {path = "assets/front/originalFrontColor.png", trueColor = true},
    },
    rocketA = {
      dmg = {path = "assets/front/rocketFrontA.png", trueColor = false},
      fullColor = {path = "assets/front/rocketFrontColorA.png", trueColor = true},
    },
    rocketB = {
      dmg = {path = "assets/front/rocketFrontB.png", trueColor = false},
      fullColor = {path = "assets/front/rocketFrontColorB.png", trueColor = true},
    },
    sygna = {
      dmg = {path = "assets/front/sygnaFront.png", trueColor = false},
      fullColor = {path = "assets/front/sygnaFrontColor.png", trueColor = true},
    },
    sygnaAlt = {
      dmg = {path = "assets/front/sygnaFrontAlt.png", trueColor = false},
      fullColor = {path = "assets/front/sygnaFrontColorAlt.png", trueColor = true},
    },
  }

  -- Assign player sprite based on mod options
  -- -----------------------------------------
  mod.hooks:wrap("player.sprite", function(next, path, ctx)
    path = next(path,ctx)
    if ctx.demo then return path end

    local colorMode = mod.options:get("colorMode")
    local variants, selected

    if ctx.side == "back" then
      variants = battleSpriteVariants
      selected = mod.options:get("battleSprite")
    elseif ctx.side == "front" then
      variants = frontSpriteVariants
      selected = mod.options:get("frontSprite")
    else
      return path
    end

    local variant = variants[selected] and variants[selected][colorMode]

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
  -- ------------------------------------------
  local CRYSTAL_COLORS = {
    {255, 255, 255},
    {255, 173, 99},
    {1, 99, 198},
    {0, 0, 0}
  }
  
  -- Intercepts the sprite renderer if the sprite is assigned a matching palette source and applies the CRYSTAL_COLORS palette to the sprite. 
  -- Hands the request back to the original sprite renderer if any other sprite.
  PaletteFX.spriteObp = function(spriteDef, seed)
    if spriteDef and spriteDef.paletteSource == "PLAYER_PALETTE" then
      return CRYSTAL_COLORS, "crystalPlayer"
      end
    
    if originalSpriteObp then
      return originalSpriteObp(spriteDef, seed)
      end
  end
  
    
  -- Sprite replacements
  -- RED
  -- --------------------------
  mod.content.sprites:patch("SPRITE_RED", {
    image = mod.assets:path("assets/overworld/crystalPlayer.png"),
    trueColor = false,
    paletteSource = "PLAYER_PALETTE"
  })
  
  mod.content.sprites:patch("SPRITE_RED_BIKE", {
    image = mod.assets:path("assets/overworld/crystalBike.png"),
    trueColor = false,
    paletteSource = "PLAYER_PALETTE"
  })
  
  mod.content.field:patch("playerPics", {
    front = mod.assets:path("assets/front/originalFront.png")
  })
  
  local CRYSTAL_FISH_SIDE = mod.assets:path("assets/overworld/crystalFishSide.png")
  local CRYSTAL_FISH_FRONT = mod.assets:path("assets/overworld/crystalFishFront.png")
  local CRYSTAL_FISH_BACK = mod.assets:path("assets/overworld/crystalFishBack.png")

  mod.content.field:patch("overworldFx", {
  redFishSide  = { path = CRYSTAL_FISH_SIDE },
  redFishFront = { path = CRYSTAL_FISH_FRONT },
  redFishBack  = { path = CRYSTAL_FISH_BACK },
})

  -- Sprite replacements
  -- GOLD
  -- -------------------------
  mod.content.sprites:patch("SPRITE_CHRIS", {
    image = mod.assets:path("assets/overworld/crystalPlayerColor.png"),
    trueColor = true,
  }) 

  mod.content.sprites:patch("SPRITE_CHRIS_BIKE", {
    image = mod.assets:path("assets/overworld/crystalBikeColor.png"),
    trueColor = true,
  })
  
  -- New game naming options
  -- ---------------------------
  mod.content.field:override("boot", {
    namePresets = {
      player = {"KRIS", "AMANDA", "JUANA", "JODI" }
    }
  })

  -- Title screen player
  -- ----------------------
  local titleVariant = frontSpriteVariants[mod.options:get("frontSprite")]
    and frontSpriteVariants[mod.options:get("frontSprite")]["dmg"]
  local titlePlayer = titleVariant and mod.assets:path(titleVariant.path)
    or mod.assets:path("assets/front/originalFront.png")
  mod.content.field:patch("boot", {
    title = {player = titlePlayer},
  })


end

return kris
