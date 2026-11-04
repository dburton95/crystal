-- The rival's text in the Game Boy games
-- Red/Blue/Yellow and Gold/Silver/Crystal call the rival he and him, and
-- Gold/Silver/Crystal describe Silver's long red hair. While a look is
-- the rival, these lines follow its genderMode (girl, boy or enby), and
-- the hair is left out for every look, since most aren't red-haired.
-- The same file is in Crystal Lens and Emerald Lens; whichever mod draws
-- the rival writes them.
--
-- Each line is found by its own words (an FNV-1a hash of the game's
-- line, breaks and box codes left out), so it works in every version,
-- and a line another mod has changed stays theirs. Only the new words
-- are here. The changes are written with the mod's own setField, so
-- they're put back with the rest of the rival. -Elvie
-- --------------------------------------------------

local rivalText = {}

-- { hash, label, girl, enby, boy } or { hash, label, all = text } -Elvie
local LINES = {
  -- Red/Blue/Yellow -Elvie
  { 0xcc8d386f, "Oak introduces the rival",
    girl = "This is my grand-\ndaughter. She's\011been your rival\011since you were a\011baby.\012...Erm, what is\nher name again?{PROMPT}",
    enby = "This is my grand-\nchild. They've\011been your rival\011since you were a\011baby.\012...Erm, what is\ntheir name again?{PROMPT}" },
  { 0xcf3e9aa4, "Oak remembers the name",
    girl = "That's right! I\nremember now! Her\011name is {RIVAL}!{PROMPT}",
    enby = "That's right! I\nremember now!\011Their name is\011{RIVAL}!{PROMPT}" },
  { 0x0e5cbde3, "Lance after the battle",
    girl = "I still can't\nbelieve my\011dragons lost to\011you, {PLAYER}!\012You are now the\nPOKéMON LEAGUE\011champion!\012...Or, you would\nhave been, but\011you have one more\011challenge ahead.\012You have to face\nanother trainer!\011Her name is...\012{RIVAL}!\nShe beat the ELITE\011FOUR before you!\012She is the real\nPOKéMON LEAGUE\011champion!{DONE}",
    enby = "I still can't\nbelieve my\011dragons lost to\011you, {PLAYER}!\012You are now the\nPOKéMON LEAGUE\011champion!\012...Or, you would\nhave been, but\011you have one more\011challenge ahead.\012You have to face\nanother trainer!\011Their name is...\012{RIVAL}!\nThey beat the\011ELITE FOUR before\011you!\012They are the real\nPOKéMON LEAGUE\011champion!{DONE}" },

  -- Gold/Silver/Crystal -Elvie
  { 0xb50ca51b, "the officer at ELM's lab",
    boy = "I heard a POKéMON\nwas stolen here…\012I was just getting\nsome information\011from PROF.ELM.\012Apparently, it was\na young male about\011your age…\012What?\012You battled a\ntrainer like that?\012Did you happen to\nget his name?{DONE}",
    girl = "I heard a POKéMON\nwas stolen here…\012I was just getting\nsome information\011from PROF.ELM.\012Apparently, it was\na young girl about\011your age…\012What?\012You battled a\ntrainer like that?\012Did you happen to\nget her name?{DONE}",
    enby = "I heard a POKéMON\nwas stolen here…\012I was just getting\nsome information\011from PROF.ELM.\012Apparently, it was\na young trainer\011about your age…\012What?\012You battled a\ntrainer like that?\012Did you happen to\nget their name?{DONE}" },
  { 0x23083b38, "the officer gets the name",
    girl = "OK! So {RIVAL}\nwas her name.\012Thanks for helping\nmy investigation!{DONE}",
    enby = "OK! So {RIVAL}\nwas their name.\012Thanks for helping\nmy investigation!{DONE}" },
  { 0x192ce42a, "a trainer who lost to the rival",
    girl = "I lost to a train-\ner named {RIVAL}.\012She was really\nstrong, but…\012It was as if she\nabsolutely had to\011win at any cost.\012I felt sorry for\nher POKéMON.{DONE}",
    enby = "I lost to a train-\ner named {RIVAL}.\012They were really\nstrong, but…\012It was as if they\nabsolutely had to\011win at any cost.\012I felt sorry for\ntheir POKéMON.{DONE}" },
  { 0x625f49bd, "the rival made fun of their POKéMON",
    girl = "Would you get\nthis?\012Some {RIVAL} girl\nmade fun of my\011POKéMON!\012Darn it! My POKé-\nMON's great!{DONE}",
    enby = "Would you get\nthis?\012Some {RIVAL} kid\nmade fun of my\011POKéMON!\012Darn it! My POKé-\nMON's great!{DONE}" },
  { 0x02a3b856, "the Rocket the rival beat",
    all = "I got wiped out on\nthe last mission\011by a kid too.\012When we were ab-\nducting POKéMON,\012this kid with\nmean-looking eyes\012just creamed me…{DONE}" },
  -- Crystal only -Elvie
  { 0x2024f7cd, "Dragon's Den",
    girl = "A girl close to\nyour age is in\011training here.\012She is much like\nCLAIR when she was\012younger. It is a\nlittle worrisome…{DONE}",
    enby = "A trainer close\nto your age is in\011training here.\012They are much like\nCLAIR when she was\012younger. It is a\nlittle worrisome…{DONE}" },
}
rivalText.LINES = LINES

local bit = bit or require("bit")
local function fnv(s)
  local h = 2166136261
  for i = 1, #s do
    h = bit.bxor(h, s:byte(i))
    -- h * 16777619 in 32 bits (2^24 + 403), without losing precision -Elvie
    h = bit.tobit(bit.lshift(h, 24) + h * 403)
  end
  return h % 4294967296
end

-- A line's words alone: line breaks and spaces as one space, and the
-- box's own codes ({DONE}, {PROMPT} and the like) left out, so a game
-- imported by a newer gen1recomp that breaks or ends a line differently
-- still matches. {PLAYER} and {RIVAL} stay, they're words. -Elvie
local NAMES = { PLAYER = true, RIVAL = true }
local function words(s)
  s = s:gsub("{(%u+)}", function(code) if not NAMES[code] then return " " end end)
  s = s:gsub("[%s\011\012]+", " ")
  return (s:gsub("^ ", ""):gsub(" $", ""))
end
local function hash(s) return fnv(words(s)) end
rivalText.hash = hash

-- The new words with the game line's own ending ({DONE} or {PROMPT}),
-- whatever the table has -Elvie
local function ending(s)
  local code = s:match("{(%u+)}$")
  return (code and not NAMES[code]) and ("{" .. code .. "}") or ""
end
function rivalText.fit(new, old)
  local body = new:gsub("{(%u+)}$", function(code) if not NAMES[code] then return "" end end)
  return body .. ending(old)
end

-- [text table] = { [hash] = { keys } } of the game's own lines, made once
-- per table and list of lines -Elvie
local indexes = setmetatable({}, { __mode = "k" })
function rivalText.index(texts, lines)
  indexes[texts] = indexes[texts] or {}
  if indexes[texts][lines] then return indexes[texts][lines] end
  local wanted = {}
  for _, line in ipairs(lines) do wanted[line[1]] = true end
  local index = {}
  for key, text in pairs(texts) do
    if type(text) == "string" then
      local h = hash(text)
      if wanted[h] then
        index[h] = index[h] or {}
        table.insert(index[h], key)
      end
    end
  end
  indexes[texts][lines] = index
  return index
end

-- Writes lines (a LINES table) for a mode. Returns how many changed. -Elvie
function rivalText.write(texts, lines, mode, setField)
  local index, n = rivalText.index(texts, lines), 0
  for _, line in ipairs(lines) do
    local new = line.all or line[mode]
    for _, key in ipairs(new and index[line[1]] or {}) do
      -- only while it's still the game's own line -Elvie
      local old = texts[key]
      if type(old) == "string" and hash(old) == line[1] then
        setField(texts, key, rivalText.fit(new, old))
        n = n + 1
      end
    end
  end
  return n
end

-- data: the game's data; gen: 1 or 2; genderMode: "girl", "boy", "enby",
-- or nil for no rival look (nothing changes); setField(record, field,
-- value) keeps what was there to put back. Returns how many lines changed. -Elvie
function rivalText.apply(data, gen, genderMode, setField)
  if type(data) ~= "table" or not genderMode then return 0 end
  local texts = gen == 2 and (data.gen2Text or data.text) or data.text
  if type(texts) ~= "table" then return 0 end
  return rivalText.write(texts, LINES, genderMode, setField)
end

return rivalText
