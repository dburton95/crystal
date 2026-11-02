# Crystal Lens
 A player sprite mod for gen1recomp++
<img width="1023" height="769" alt="image" src="https://github.com/user-attachments/assets/9f04bc87-5af2-4607-a83b-673b197f2460" />


## Features
* A fully featured drop in Player Sprite replacement framework.
* A **LENS** screen on the START menu to pick your character, look, colours, gender and rival with a preview, and a credits page for the mod and every look (see **The LENS screen** below).
* Changes show straight away, and anything a look is missing comes from the same character's other looks.
* Comes with Kris from Crystal version as default
* Easy to write JSON files let you import your favorite character sprites and separate them by character name.

## How to add your own sprites!
* Sprites can be placed in their own folder at assets/sprites/FOLDER_NAME_HERE
  * Your folder must not have any spaces in the name. This is what the mod uses for the option key.
  * In you folder place the following.
    * back.png
    * backColor.png
    * front.png
    * frontColor.png
    * meta.json
      * As long as you have either back.png or backColor.png the other is option. The mod is designed to fallback if a sprite is missing.
* Your meta.json needs to have a single key defined. This is the name that will appear in the options menu.
* Your meta.json can also optionally set a `character` key, grouping several folders together as variants of one character (e.g. a default look and a separate battle-only look). Folders sharing the same `character` value show up under one **CHARACTER** entry in the options menu, with their own `label`s as the sub-choice between them. A folder that doesn't set `character` is treated as its own standalone, single-variant character -- exactly how every folder already works today, so this is fully backward compatible with existing sprite packs.

### Example meta.json file
A standalone character, with no other variants:
```
{
  "label": "ARALE"
  "character"
}
```

Two folders grouped as variants of the same character:
```
{
  "label": "DEFAULT LOOK",
  "character": "ARALE"
}
```
```
{
  "label": "BATTLE LOOK",
  "character": "ARALE"
}
```
Both show up under a single **ARALE** entry in the **CHARACTER** option, with **DEFAULT LOOK** and **BATTLE LOOK** as the front/battle sprite choices underneath it.

### Overworld sprites, colors, names & gender
A sprite folder can also optionally include any of these files to replace the walking, bike, and fishing overworld sprites:
* `overworldWalk.png`
* `overworldBike.png`
* `overworldFishSide.png`
* `overworldFishFront.png`
* `overworldFishBack.png`

And its `meta.json` can optionally set any of these keys:
* `overworldColors` — array of exactly four `[r, g, b]` triplets (0-255) overriding the recolor palette applied to the sprites above.
* `nameChoices` — array of strings shown as name choices at the start of a new game (Gen 1 and Gold).
* `genderMode` — one of `"boy"` (vanilla male text), `"girl"` (Crystal's re-gendered text), or `"enby"` (gender-neutral text).

All of the above — the five overworld files and the three meta.json keys — start from whichever folder is resolved as the front sprite for the currently selected **CHARACTER** (the same one the title screen image uses). Anything that folder doesn't supply comes from the character's other folders, file by file, and then Crystal's defaults. The same goes for the front and battle sprites: a folder without one uses another folder of the same character before the game's own.

The overworld sprites and their colours, the battle sprites and the trainer card follow your choice straight away. The title screen, name choices and `genderMode` (the re-gendered text) are set when the mod loads, so those need a restart after a change.

### Gen 3 and 4 looks from Emerald Lens
With [Emerald Lens](https://github.com/ElvieBlooms/emerald_lens) installed too, its Gen 3 and 4 looks join the lists here: each one shows up under its character in **FRONT SPRITE** (a label this mod already has for that character gets a `+`). Crystal Lens stays in charge of the choices. While your front sprite is one of Emerald Lens's looks, Emerald Lens draws your player (walking, biking, surfing, fishing and battle pics, in full colour) and this mod steps back; pick one of this mod's looks and it takes over again. Nothing changes until you pick one: your own looks stay the default. They can be the rival too: pick one on **RIVAL LOOK** and Emerald Lens draws the rival's battle pics and walking sprite. In Gold/Silver/Crystal the trainer card shows the Emerald Lens look as well, fitted to the card's portrait box.

Mods that want to add looks the same way can use this mod's `exports.lens.addLooks` (see the comment in `kris.lua`).

### The LENS screen
**LENS** on the START menu (above MODS, or QUIT), or **CRYSTAL LENS** on the OPTION menu, opens the same choices as the mod options, for the game you're playing, with a preview of the look: its front sprite and walking sprite, in full colour. Up and down pick a row, left and right (or A) change it, and B closes it. **CREDITS** (press A) opens the mod's credits, followed by every look and its `credit` lines from `meta.json` (optional: a string or a list of strings naming the artists).

With [Facets](https://github.com/ElvieBlooms/facets) installed too, the two share one **PRISM** item on both menus instead: a short list with CRYSTAL LENS first and FACETS under it, each with its gem and current setting. Picking one opens its screen, and B there comes back to the list. Emerald Lens joins the same way when it's installed without this mod.

### Gender and the rival
* **GENDER** matters in Crystal, the one game with a choice. **LOOK** (the default) works as before: the boy/girl choice is skipped and your character replaces Chris. **MY SAVE** keeps the choice in a new game, and your character replaces whichever player the save picked, Chris or Kris.
* **RIVAL** picks a character for Blue (Red/Blue/Yellow) or Silver (Gold/Silver/Crystal), with a **RIVAL LOOK** row when it has more than one front sprite. **OFF** keeps the game's own rival.
  * Battle pics: a folder's `rivalEarly.png`, `rivalLate.png` and `rivalChampion.png` (and their `Color` versions) for the rival's battles in order (Gen 1 has three, Gen 2 two), or else its front sprite. Each falls back through the character's folders like the player's.
  * Walking: `overworldWalk.png` from the character's folders, coloured with its `overworldColors`; a rival character without one keeps the game's walking sprite. It changes when you next enter a map.

### Gen 2 trainer card portrait
On Gold, Silver, and Crystal, a folder can also optionally include `trainerCard.png` (and `trainerCardColor.png` for the full color variant) — art purpose-built for the trainer card's 40x56 portrait box, drawn at native size and centered. If a folder doesn't provide one, the trainer card falls back to that folder's regular front sprite instead.

```
{
  "label": "MY SPRITE",
  "nameChoices": ["MY NAME", "OTHER NAME"],
  "genderMode": "enby",
  "overworldColors": [[255, 255, 255], [255, 173, 99], [1, 99, 198], [0, 0, 0]]
}
```


## What works in Gold
*  Full color overworld sprite
*  Full color bike sprite (untested but should work)
*  LENS screen and credits
*  Battle Sprite Choices
*  Full color sprites in the battle engine
*  Girl Mode and Enby Mode re-gendering of the text

## What doesn't work in Gold
*  Overworld sprite doesn't support DMG palletes yet (You can use the DMG palette. the sprite will just be the only thing in full color)

## Crystal
Crystal is now a supported game version alongside Gold and Silver. Crystal has its own native gender-choice screen (choosing between Chris and Kris) that Gold and Silver never had; since this mod's sprite already comes from your selected sprite folder, that screen is skipped automatically so it doesn't ask a second, separate question, unless **GENDER** is set to **MY SAVE**. Everything documented above for Gold applies to Crystal as well.


