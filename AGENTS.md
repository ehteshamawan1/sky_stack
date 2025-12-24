# Repository Guidelines

## Project Structure & Module Organization
This is a Flutter + Flame game. Core Dart code lives in `lib/` with features
split by domain (game, home, city_builder, core). Tests go in `test/`. Game
assets are under `assets/` (notably `assets/svg/` and `assets/sounds/`).
Platform shells live in `android/`, `ios/`, `macos/`, `windows/`, `linux/`,
and `web/`. Planning and checklists live outside the app source in
`../info_claude/` and `../info_technix/`.

## Build, Test, and Development Commands
- `flutter pub get` installs dependencies.
- `flutter run` launches the app on a connected device or emulator.
- `flutter test` runs the unit/widget tests in `test/`.
- `flutter analyze` runs static analysis using `analysis_options.yaml`.
- `flutter build apk` or `flutter build ios` produces release builds.
- `dart run build_runner build --delete-conflicting-outputs` regenerates
  Hive adapters or other codegen outputs when needed.

## Coding Style & Naming Conventions
Follow Dart/Flutter defaults: 2-space indentation, trailing commas for
formatting, and run `dart format .` before committing. Linting uses
`flutter_lints` (see `analysis_options.yaml`). Use `UpperCamelCase` for
types, `lowerCamelCase` for members, and `lower_snake_case.dart` for files.

## Testing Guidelines
Tests use `flutter_test`. Name files `*_test.dart` and keep them in `test/`.
Aim to cover core gameplay systems (scoring, spawning, collisions) and any
logic in `lib/` that can be isolated from rendering.

## Commit & Pull Request Guidelines
Recent commits use short, descriptive messages (e.g., "Phase 2 complete...",
"feat: Phase 1.1 ..."). Keep subjects imperative and scoped to a single change;
use a `feat:` prefix when introducing new functionality. PRs should include a
summary, testing notes (commands run), and screenshots or a short recording
for gameplay/UI changes. Link related issues when applicable.

## Planning Docs & Phase Tracking
Launch scope and phased plans are defined in `../info_claude/`, especially
`LAUNCH_SCOPE_V1.0.md`, `POST_LAUNCH_ROADMAP.md`, and
`CRITICAL_FIXES_PHASE_3.5.md`. Progress logs live in
`../info_claude/part*_progress_log.md`. When completing a phase task, update
the relevant checklist/log alongside code changes.

Phase 3.5 is the current gate before Phase 4. It focuses on:
- Correct game over detection (miss/overlap/topple).
- App lifecycle handling (pause engine + audio when backgrounded).
- A splash/loading screen to preload assets and reduce first-game lag.
- Performance/battery hygiene (frame timing, cache limits, cleanup).

## Security & Configuration Tips
Firebase/AdMob IDs and `google-services.json` are stored in
`../info_technix/` for reference. Do not copy or commit secrets into
`sky_stack/`. Keep environment-specific values out of source control.
