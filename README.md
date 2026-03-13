# Tic-Tac-Toe

A Flutter implementation of Tic-Tac-Toe submitted as a technical test for Betclic. The app supports Human vs Human and Human vs AI game modes, with score and configurable first player (human or AI, in the appropriate game mode).

## Architecture

The codebase follows Clean Architecture principles with a clear separation between business logic and UI.

### Dependency injection

A small service locator in `lib/utils/injector.dart` is used to register and resolve dependencies. Registration happens at startup in `main.dart`. This keeps controllers testable and swappable.

### Structure

- **`lib/controllers/`** — Game management and intelligence for the AI.
- **`lib/pages/`** — Screens. They use provider to watch state, that itself uses the game controller.
- **`lib/widgets/`** — Reusable UI (e.g. board cell, winner overlay).
- **`lib/utils/`** — Injector, theme/design, preferences, and extensions.
- **`lib/models/`** — Shared abstractions used across layers.

Routing is centralized in `main.dart` with `go_router`.

## Author
Ryan Danenberg