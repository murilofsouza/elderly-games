# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All commands run from inside `elderly_games/`:

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on a specific device
flutter run -d <device-id>

# Build for iOS
flutter build ios

# Build for Android
flutter build apk

# Run tests
flutter test

# Run a single test file
flutter test test/some_test.dart

# Analyze code (lint)
flutter analyze
```

## Architecture

This is a Flutter app ("Jogos para Idosos") targeted at elderly users, currently containing one game: a Memory Card game (Jogo da Memoria).

### App Entry Point

`lib/main.dart` — Bootstraps the app and renders `HomeScreen`, which shows a list of available games. Currently only navigates to `PhaseSelectionScreen` for the memory game.

### Memory Game (`lib/memory_game/`)

The memory game is self-contained in this folder with the following structure:

| File | Responsibility |
|------|----------------|
| `models.dart` | Data classes: `PhaseConfig`, `MemoryCard`, `GameCard`, `PhaseResult`, `MemoryGameProgress`, `MemoryTheme` enum |
| `game_data.dart` | Static configuration: 8 phase definitions (`phases` list) and card pools (`frutasCards`, `animaisCards`), plus `getCardsForTheme()` helper |
| `storage.dart` | `MemoryGameStorage` — static async methods using `shared_preferences` to persist and load player progress |
| `phase_selection_screen.dart` | Grid of 8 phase cards; locked/unlocked state; star ratings; navigates into `GameScreen` |
| `game_screen.dart` | Full game logic: card flip state, match detection, combo tracking, timer, hint/skip mechanics, floating score animation, confetti-free game loop |
| `result_screen.dart` | Post-game summary with score breakdown, star rating, confetti animation (`CustomPainter`), and save-on-init via `MemoryGameStorage` |
| `widgets/memory_card.dart` | `MemoryCardWidget` — 3D flip animation using `AnimationController` + `Matrix4.rotateY`, renders front (emoji + name) and back (green gradient) |

### Key Design Decisions

- **No state management library** — all state is local `StatefulWidget` + `setState`. `MemoryGameStorage` is called imperatively.
- **Persistence** — `shared_preferences` stores `currentPhase` (int) and `best` results (JSON string keyed by phase number).
- **Scoring** — base points per pair multiplied by `PhaseConfig.multiplier`; combo bonuses stack; hint costs 5pts, skip costs 15pts, all scaled by multiplier.
- **Phase unlocking** — `MemoryGameStorage.updatePhaseResult` increments `currentPhase` when completing the player's highest unlocked phase.
- **Star rating** — 3 stars = 0 errors, 2 stars = 1-2 errors, 1 star = completed, 0 stars = timed out.
- **Preview** — Phases 1-3 show all cards face-up for 3 seconds before the game starts (`PhaseConfig.hasPreview`).
- **Cards** — Currently emoji-based (spec calls for real photos in the future). `MemoryCard.id` identifies pairs; `GameCard` wraps it with runtime flip/match state.

### Theme / Styling

- Primary green: `Color(0xFF2E7D32)` / dark variant `Color(0xFF1B5E20)`
- Background: `Color(0xFFF5F5F0)`
- Material 3 enabled; base font sizes are 16-18 to accommodate elderly users.
- Minimum card size: 70dp (clamped 70-120dp based on screen constraints).

### Spec Reference

`MEMORY_GAME_SPEC.md` (in the repo root) contains the full product specification including planned features not yet implemented (sounds, daily streak bonus, real photo assets).
