# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a World of Warcraft addon for Vanilla WoW (1.12.1) and Turtle WoW that enhances item tooltips by adding profession icons. The icons show which crafting professions can use an item as a reagent.

## Architecture

### Core Components
- **Main addon**: `src/ItemTooltipProfessionIconsVanilla.lua` - Primary logic for tooltip enhancement
- **TOC file**: `ItemTooltipProfessionIconsVanilla.toc` - Defines addon metadata and file load order

### Library Dependencies (lib/ directory)
- **LibStub** - Library management system
- **LibItemTooltip-1.0** - Hooks tooltip display events
- **LibCrafts-1.0** - Database of crafting recipes, reagents, and spells
- **LibCraftingProfessions-1.0** - Universal interface for profession data

### Data Flow
1. LibItemTooltip hooks tooltip events and extracts item IDs
2. LibCrafts queries database for recipes using the item as reagent
3. Main addon creates profession icons and attaches them to tooltip

## Development Guidelines

### File Load Order
The .toc file defines critical load order - libraries must load before the main addon:
```
lib\LibStub\LibStub.lua
lib\LibCraftingProfessions-1.0\LibCraftingProfessions-1.0.xml
lib\LibCrafts-1.0\LibCrafts-1.0.xml
lib\LibItemTooltip-1.0\LibItemTooltip-1.0.xml
src\ItemTooltipProfessionIconsVanilla.lua
```

### Key Technical Details
- Uses LibStub pattern for dependency injection
- Event-driven architecture with callback registration
- Profession icons are 16x16 pixel frames using WoW texture paths
- Supports both Vanilla WoW and Turtle WoW (includes Jewelcrafting)

### Working with Libraries
- LibCrafts uses ID-based database with WoW spell/item IDs
- LibCrafts data is organized by profession in `lib/LibCrafts-1.0/Professions/`
- Localization handled through LibCrafts locale system in `lib/LibCrafts-1.0/Locales/`

### Testing
Test in-game by:
1. Installing addon in WoW Interface/AddOns directory
2. Loading game and checking tooltip enhancements on crafting reagents
3. Verifying icons appear for items used in multiple professions
