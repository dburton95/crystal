# Crystal Lens
 A player sprite mod for gen1recomp++
<img width="1023" height="769" alt="image" src="https://github.com/user-attachments/assets/9f04bc87-5af2-4607-a83b-673b197f2460" />


## Features
* A fully featured drop in Player Sprite replacement framework.
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

All of the above — the five overworld files and the three meta.json keys — apply only to whichever folder is resolved as the front sprite for the currently selected **CHARACTER** (the same one the title screen image uses), not to every folder at once. Anything a folder doesn't supply falls back to Crystal's defaults. Like the title screen sprite, all of this is resolved once when the mod loads, from whichever CHARACTER (and, if it has more than one look, FRONT SPRITE variant) is selected at that time — changing either mid-session won't update it without a restart.

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
*  Credits
*  Battle Sprite Choices
*  Full color sprites in the battle engine
*  Girl Mode and Enby Mode re-gendering of the text

## What doesn't work in Gold
*  Overworld sprite doesn't support DMG palletes yet (You can use the DMG palette. the sprite will just be the only thing in full color)

## Crystal
Crystal is now a supported game version alongside Gold and Silver. Crystal has its own native gender-choice screen (choosing between Chris and Kris) that Gold and Silver never had; since this mod's sprite already comes from your selected sprite folder, that screen is skipped automatically so it doesn't ask a second, separate question. Everything documented above for Gold applies to Crystal as well.


