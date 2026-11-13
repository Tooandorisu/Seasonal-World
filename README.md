# Seasonal World

Seasonal environments for Gen1Recomp. The first release candidate brings Christmas to Kanto in Pokémon Red, Blue, and Yellow.

Christmas coverage includes all Kanto towns, Indigo Plateau, all 25 numbered routes, Viridian Forest, Vermilion Dock, and all four outdoor areas of the Safari Zone. Look for snowy paths and rooftops, frosted tall grass, Christmas lights, and trees with gifts. Face a Christmas tree and press **A** for a greeting.

## Install

1. Import `seasonal_world-1.0.0-rc.1.zip` in Gen1Recomp. For a manual install, extract the `seasonal_world` folder into `mods`.
2. Enable **Seasonal World - Christmas Test**, then close Gen1Recomp completely and reopen it. Keep one copy of Seasonal World installed when updating.
3. Set **SEASON → CHRISTMAS TEST** in the mod settings to preview Christmas immediately.

## Settings

| Setting | What it does |
|---|---|
| **SEASON → AUTO (DATE)** | Enables Christmas from December 1 through January 6 using your device's local date. This is the default. |
| **SEASON → CHRISTMAS TEST** | Enables Christmas on any date. |
| **SEASON → OFF** | Turns off Christmas decorations, snow, and Christmas tree interactions and collision. |
| **SNOWFALL** | Toggles falling snow. |
| **SNOW COVER** | Toggles snow on the ground, rooftops, and scenery. |

The Christmas effects run in the standard flat 2D view. Active world-rendering pipelines and tilt hide the effects. TileShift is optional. Alternate tilesets can shift roof and light alignment.

## RC 1 mobile test

With **CHRISTMAS TEST** active, try crossing each map boundary in both directions.

| Location | What to check |
|---|---|
| Route 2 ↔ Pewter City | The Christmas tree is already visible from Route 2 when it comes into view and stays in place as you cross. |
| Route 23 ↔ Indigo Plateau | The tree stays in place across the boundary, with snow on the trees along both sides. |
| Routes 8 and 12 ↔ Lavender Town | Check the snowy cliff tops from Route 8 and look for Lavender's Christmas tree as you approach from Route 12. |
| Route 16 ↔ Route 17 | Snow continues onto Cycling Road. Check the rails and both eaves of the house where you get Fly. |
| Route 24 ↔ Route 25 | Snow continues from Nugget Bridge toward Bill's house. Check the roof trim and windows. |
| Safari Zone | Walk past the tree near the Center entrance and press **A** while facing it. Check the ponds, posts, exits, and rest-house roofs. |

Try **OFF** outside beside a Christmas tree. The tree, snow, and trunk collision should disappear. If you report a visual issue, include the map or crossing, your game version, the tileset mods you use, and a screenshot if possible.

See [CHANGELOG.md](CHANGELOG.md) for version history.

Created by Tooandorisu.
