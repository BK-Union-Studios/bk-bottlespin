# bk_bottlespin

A bottle-spinning script for FiveM (qbx_core).

## Features
- Place bottles via item
- Bottle spin is synchronized for all players
- Configurable props and settings
- Pick up the bottle using the `/pbottle` command

## Installation
1. Copy the `bk_bottlespin` folder into your `resources` directory.
2. Add `ensure bk_bottlespin` to your `server.cfg`.
3. Add the item `bottle` to your inventory system (e.g. ox_inventory).

## Configuration
All settings can be adjusted in `shared/config.lua`.

## Dependencies
- qbx_core
- ox_lib (for model requests)
- ox_inventory (for item handling)