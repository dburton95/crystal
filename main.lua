return function(mod)
  local kris = require("mods.crystal.kris")
  local girlMode = require("mods.crystal.girlMode")
  local nbMode = require("mods.crystal.nbMode")
  local credits = require("mods.crystal.credits")

  local cfg = kris.init(mod)

  if cfg.genderMode == "girl" then
    girlMode.init(mod)
  elseif cfg.genderMode == "enby" then
    nbMode.init(mod)
  end
  -- "boy": neither runs, vanilla male text stands untouched

  credits.init(mod)
end
