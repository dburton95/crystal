-- The LENS screen
-- LENS on the START menu (in place of the old T. KRIS credits item), or
-- CRYSTAL LENS on the OPTION menu, opens a screen with the mod's choices
-- for this game and a preview of the look: its front sprite and walking
-- sprite, in full colour. Up and down pick a row, left and right (or A)
-- change it, B closes it. The CREDITS row opens the mod's credits and
-- every look's. Changes are the same as in the mod options and apply
-- straight away. -Elvie
-- --------------------------------------------------

local lens = {}

local ROW_Y, ROW_H = 22, 9 -- first row and row height, in pixels -Elvie
local LABEL_X, VALUE_X = 2, 10 -- in tiles -Elvie
local VALUE_CHARS = 9
local PIC_X, PIC_Y = 96, 80
local WALK_X, WALK_Y = 32, 104

local function cut(text, n)
  text = tostring(text or "")
  return #text > n and text:sub(1, n) or text
end

function lens.init(mod, api)
  if type(api) ~= "table" then return end
  local Font = mod.ui and mod.ui.Font
  if not (Font and mod.content and mod.content.screens) then return end
  local okFx, PaletteFX = pcall(require, "src.render.PaletteFX")
  if not okFx then PaletteFX = nil end

  -- Images by path, and walking sheets coloured once per colour set -Elvie
  local images, walks = {}, {}
  local function image(path)
    if not path then return nil end
    if images[path] == nil then
      local ok, img = pcall(love.graphics.newImage, path)
      if ok and img then img:setFilter("nearest", "nearest") end
      images[path] = ok and img or false
    end
    return images[path] or nil
  end
  -- a Game Boy sheet's four greys in the look's colours, white clear -Elvie
  local function walkImage(path, colors)
    if not (path and type(colors) == "table") then return nil end
    local key = path .. "|" .. table.concat(colors[2] or {}, ",") .. "|" .. table.concat(colors[3] or {}, ",")
    if walks[key] == nil then
      local ok, data = pcall(love.image.newImageData, path)
      if ok and data then
        data:mapPixel(function(_, _, r, g, b, a)
          if a == 0 then return r, g, b, a end
          local shade = r > 0.83 and 1 or r > 0.5 and 2 or r > 0.17 and 3 or 4
          if shade == 1 then return 0, 0, 0, 0 end
          local c = colors[shade]
          return c[1] / 255, c[2] / 255, c[3] / 255, a
        end)
        local img = love.graphics.newImage(data)
        img:setFilter("nearest", "nearest")
        walks[key] = img
      else
        walks[key] = false
      end
    end
    return walks[key] or nil
  end

  local function trueColor(x, y, w, h)
    if PaletteFX and type(PaletteFX.markTrueColor) == "function" then pcall(PaletteFX.markTrueColor, x, y, w, h) end
  end

  -- The credits page: up and down scroll, B goes back -Elvie
  mod.content.screens:register("crystal_lens_credits", {
    new = function(game)
      local self = { isOpaque = true, top = 1 }
      local lines = api.credits()
      local PAGE = 16
      function self:update()
        local input = game.input
        if input:wasPressed("b") or input:wasPressed("a") then game.stack:pop() return end
        if input:wasPressed("down") then self.top = math.min(math.max(1, #lines - PAGE + 1), self.top + 1) end
        if input:wasPressed("up") then self.top = math.max(1, self.top - 1) end
        if input:wasPressed("right") then self.top = math.min(math.max(1, #lines - PAGE + 1), self.top + PAGE) end
        if input:wasPressed("left") then self.top = math.max(1, self.top - PAGE) end
      end
      function self:draw()
        Font.drawBox(0, 0, 20, 18)
        for i = 0, PAGE - 1 do
          local line = lines[self.top + i]
          if line then Font.draw(cut(line, 18), 8, 8 + i * 8) end
        end
      end
      return self
    end,
  })

  mod.content.screens:register("crystal_lens", {
    new = function(game)
      local self = { isOpaque = true, cursor = 1, clock = 0 }
      function self:update(dt)
        self.clock = self.clock + (dt or 0)
        local input = game.input
        local rows = api.rows()
        self.cursor = math.max(1, math.min(self.cursor, #rows))
        if input:wasPressed("b") then game.stack:pop() return end
        if input:wasPressed("down") then self.cursor = self.cursor % #rows + 1 end
        if input:wasPressed("up") then self.cursor = (self.cursor - 2) % #rows + 1 end
        local row = rows[self.cursor]
        if row.page then
          if input:wasPressed("a") then mod.ui.push(game, "crystal_lens_credits") end
          return
        end
        local step = (input:wasPressed("right") or input:wasPressed("a")) and 1 or (input:wasPressed("left") and -1) or 0
        if step ~= 0 and #row.choices > 0 then
          local at = 1
          for i, choice in ipairs(row.choices) do if choice[2] == row.value then at = i end end
          at = (at - 1 + step) % #row.choices + 1
          api.set(game, row.key, row.choices[at][2])
        end
      end
      function self:draw()
        local rows = api.rows()
        Font.drawBox(0, 0, 20, 18)
        Font.draw("CRYSTAL LENS", 8, 8)
        for i, row in ipairs(rows) do
          local y = ROW_Y + (i - 1) * ROW_H
          if i == self.cursor then
            -- the engine's own cursor glyph, as its menus draw it -Elvie
            local Theme = mod.ui.Theme
            if Theme and Theme.cursor and Font.drawCode then Font.drawCode(Theme.cursor, (LABEL_X - 1) * 8, y)
            else Font.draw(">", (LABEL_X - 1) * 8, y) end
          end
          Font.draw(row.label, LABEL_X * 8, y)
          local label = row.valueLabel
          if not label then
            for _, choice in ipairs(row.choices or {}) do if choice[2] == row.value then label = choice[1] end end
          end
          Font.draw(cut(label, VALUE_CHARS), VALUE_X * 8, y)
        end
        local row = rows[self.cursor] or {}
        local preview = api.preview(row.who or "player")
        if preview then
          love.graphics.setColor(1, 1, 1, 1)
          local pic = image(preview.pic)
          if pic then
            local w, h = pic:getDimensions()
            -- feet on the box's bottom edge, centred -Elvie
            local x, y = PIC_X + math.floor((56 - w) / 2), PIC_Y + 56 - h
            trueColor(x, y, w, h)
            love.graphics.draw(pic, x, y)
          end
          local full = preview.walkFull and image(preview.walkFull)
          if full then
            -- another mod's Gen 3 walking sprite, in its own colours:
            -- standing, then a step (frames 0 and 3), feet on the same line -Elvie
            local w, h = full:getDimensions()
            local fw = math.min(w, 32)
            local frame = math.floor(self.clock * 2) % 2 == 0 and 0 or 3
            local quad = love.graphics.newQuad(0, frame * 32, fw, 32, w, h)
            local x = WALK_X - math.floor((fw - 16) / 2)
            trueColor(x, WALK_Y - 16, fw, 32)
            love.graphics.draw(full, quad, x, WALK_Y - 16)
          end
          local walk = walkImage(preview.walk, preview.colors)
          if walk then
            -- standing down, then a step, as on the map -Elvie
            local frame = math.floor(self.clock * 2) % 2 == 0 and 0 or 3
            local w, h = walk:getDimensions()
            local quad = love.graphics.newQuad(0, frame * 16, 16, 16, w, h)
            trueColor(WALK_X, WALK_Y, 16, 16)
            love.graphics.draw(walk, quad, WALK_X, WALK_Y)
          end
        else
          Font.draw("OFF", WALK_X, WALK_Y)
        end
      end
      return self
    end,
  })

  -- START and OPTION menus through prism.lua, shared with Emerald Lens and
  -- Facets: on its own it's LENS on START and CRYSTAL LENS on OPTION; with
  -- another visuals mod they share one PRISM item, the lens first -Elvie
  local prism = require("mods.crystal.prism")
  local prismScreen = prism.registerGb(mod)
  local entry = { id = "crystal_lens", label = "CRYSTAL LENS", short = "LENS",
    about = "The look of you and your rival.",
    colour = { 96, 168, 216 }, -- crystal blue -Elvie
    order = 10,
    value = function()
      local row = api.rows()[1]
      if not row then return "" end
      for _, choice in ipairs(row.choices or {}) do
        if choice[2] == row.value then return choice[1] end
      end
      return tostring(row.value or "")
    end,
    open = function(game) mod.ui.push(game, "crystal_lens") end,
  }
  local function liveGame(game)
    if type(game) == "table" then return game end
    local ok, g = pcall(function() return mod.game end)
    return ok and type(g) == "table" and g or nil
  end
  mod.hooks:wrap("ui.start_menu.items", function(nextFn, game, items)
    local out = nextFn(game, items)
    if type(out) ~= "table" then return out end
    return prism.addStartGb(mod, out, entry, liveGame(game), prismScreen)
  end)
  mod.hooks:wrap("ui.options.rows", function(nextFn, game, rows)
    local out = nextFn(game, rows)
    if type(out) ~= "table" then return out end
    return prism.addOptionGb(mod, out, entry, liveGame(game), prismScreen)
  end)
end

return lens
