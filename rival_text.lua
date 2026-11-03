-- The rival's text in the Game Boy games
-- Red/Blue/Yellow and Gold/Silver/Crystal call the rival he and him, and
-- Gold/Silver/Crystal describe Silver's long red hair. While a look is
-- the rival, these lines follow its genderMode (girl, boy or enby), and
-- the hair is left out for every look, since most aren't red-haired.
-- The same file is in Crystal Lens and Emerald Lens; whichever mod draws
-- the rival writes them.
--
-- Each line is found by its own text (an FNV-1a hash of the game's
-- line), so it works in every version, and a line another mod has
-- changed stays theirs. Only the new words are here. The changes are
-- written with the mod's own setField, so they're put back with the
-- rest of the rival. -Elvie
-- --------------------------------------------------

local rivalText = {}

-- { hash, label, girl, enby, boy } or { hash, label, all = text } -Elvie
local LINES = {
  -- Red/Blue/Yellow -Elvie
  { 0x9389236b, "Oak introduces the rival",
    girl = "This is my grand-\ndaughter. She's\011been your rival\011since you were a\011baby.\012...Erm, what is\nher name again?{PROMPT}",
    enby = "This is my grand-\nchild. They've\011been your rival\011since you were a\011baby.\012...Erm, what is\ntheir name again?{PROMPT}" },
  { 0x56bf1441, "Oak remembers the name",
    girl = "That's right! I\nremember now! Her\011name is {RIVAL}!{PROMPT}",
    enby = "That's right! I\nremember now!\011Their name is\011{RIVAL}!{PROMPT}" },
  { 0xbaa69375, "Lance after the battle",
    girl = "I still can't\nbelieve my\011dragons lost to\011you, {PLAYER}!\012You are now the\nPOKéMON LEAGUE\011champion!\012...Or, you would\nhave been, but\011you have one more\011challenge ahead.\012You have to face\nanother trainer!\011Her name is...\012{RIVAL}!\nShe beat the ELITE\011FOUR before you!\012She is the real\nPOKéMON LEAGUE\011champion!{DONE}",
    enby = "I still can't\nbelieve my\011dragons lost to\011you, {PLAYER}!\012You are now the\nPOKéMON LEAGUE\011champion!\012...Or, you would\nhave been, but\011you have one more\011challenge ahead.\012You have to face\nanother trainer!\011Their name is...\012{RIVAL}!\nThey beat the\011ELITE FOUR before\011you!\012They are the real\nPOKéMON LEAGUE\011champion!{DONE}" },

  -- Gold/Silver/Crystal -Elvie
  { 0xa829444d, "the officer at ELM's lab",
    boy = "I heard a POKéMON\nwas stolen here…\012I was just getting\nsome information\011from PROF.ELM.\012Apparently, it was\na young male about\011your age…\012What?\012You battled a\ntrainer like that?\012Did you happen to\nget his name?{DONE}",
    girl = "I heard a POKéMON\nwas stolen here…\012I was just getting\nsome information\011from PROF.ELM.\012Apparently, it was\na young girl about\011your age…\012What?\012You battled a\ntrainer like that?\012Did you happen to\nget her name?{DONE}",
    enby = "I heard a POKéMON\nwas stolen here…\012I was just getting\nsome information\011from PROF.ELM.\012Apparently, it was\na young trainer\011about your age…\012What?\012You battled a\ntrainer like that?\012Did you happen to\nget their name?{DONE}" },
  { 0x8cc72034, "the officer gets the name",
    girl = "OK! So {RIVAL}\nwas her name.\012Thanks for helping\nmy investigation!{DONE}",
    enby = "OK! So {RIVAL}\nwas their name.\012Thanks for helping\nmy investigation!{DONE}" },
  { 0x54864ddd, "a trainer who lost to the rival",
    girl = "I lost to a train-\ner named {RIVAL}.\012She was really\nstrong, but…\012It was as if she\nabsolutely had to\011win at any cost.\012I felt sorry for\nher POKéMON.{DONE}",
    enby = "I lost to a train-\ner named {RIVAL}.\012They were really\nstrong, but…\012It was as if they\nabsolutely had to\011win at any cost.\012I felt sorry for\ntheir POKéMON.{DONE}" },
  { 0x16e8f7a0, "the rival made fun of their POKéMON",
    girl = "Would you get\nthis?\012Some {RIVAL} girl\nmade fun of my\011POKéMON!\012Darn it! My POKé-\nMON's great!{DONE}",
    enby = "Would you get\nthis?\012Some {RIVAL} kid\nmade fun of my\011POKéMON!\012Darn it! My POKé-\nMON's great!{DONE}" },
  { 0xebbb8747, "the Rocket the rival beat",
    all = "I got wiped out on\nthe last mission\011by a kid too.\012When we were ab-\nducting POKéMON,\012this kid with\nmean-looking eyes\012just creamed me…{DONE}" },
  -- Crystal only -Elvie
  { 0x68f73b9e, "Dragon's Den",
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
rivalText.hash = fnv

-- [text table] = { [hash] = key } of the game's own lines, made once -Elvie
local indexes = setmetatable({}, { __mode = "k" })
local wanted
local function indexOf(texts)
  if indexes[texts] then return indexes[texts] end
  if not wanted then
    wanted = {}
    for _, line in ipairs(LINES) do wanted[line[1]] = true end
  end
  local index = {}
  for key, text in pairs(texts) do
    if type(text) == "string" then
      local h = fnv(text)
      if wanted[h] then index[h] = key end
    end
  end
  indexes[texts] = index
  return index
end

-- data: the game's data; gen: 1 or 2; genderMode: "girl", "boy", "enby",
-- or nil for no rival look (nothing changes); setField(record, field,
-- value) keeps what was there to put back. Returns how many lines changed. -Elvie
function rivalText.apply(data, gen, genderMode, setField)
  if type(data) ~= "table" or not genderMode then return 0 end
  local texts = gen == 2 and (data.gen2Text or data.text) or data.text
  if type(texts) ~= "table" then return 0 end
  local index, n = indexOf(texts), 0
  for _, line in ipairs(LINES) do
    local key = index[line[1]]
    local new = line.all or line[genderMode]
    -- only while it's still the game's own line -Elvie
    if key and new and type(texts[key]) == "string" and fnv(texts[key]) == line[1] then
      setField(texts, key, new)
      n = n + 1
    end
  end
  return n
end

return rivalText
