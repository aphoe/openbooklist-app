# Project Guidelines: OpenBookList App

A mobile application built with Flutter and Dart, following a clean, layered architecture.

## Essential Commands
- **Install dependencies:** `flutter pub get`
- **Run application:** `flutter run`
- **Run tests:** `flutter test`
- **Generate code:** `dart run build_runner build --delete-conflicting-outputs`
- **Format code:** `dart format .`
- **Analyze code:** `flutter analyze`
- **Update icons:** `dart run flutter_launcher_icons`
- **Update splash:** `dart run flutter_native_splash:create`

## Tech Stack
- **Framework:** Flutter
- **Language:** Dart
- **State Management:** ValueNotifier, ChangeNotifier (built-in) or Provider
- **Routing:** `go_router`
- **Serialization:** `json_serializable`
- **Testing:** `flutter_test`, `checks`

## Coding Standards & Conventions
### Code Style
- **Naming:** `PascalCase` for classes, `camelCase` for variables/methods, `snake_case` for files.
- **Formatting:** Max line length 80 characters; use `dart format`.
- **Immutability:** Use `const` constructors for widgets whenever possible.
- **Documentation:** Use `///` doc comments for all public APIs.
- **Logging:** Use `dart:developer`'s `log()` instead of `print()`.

### Architecture
- **Structure:** Layered architecture: `presentation` (UI), `domain` (Logic), `data` (Models/Repos), `core` (Utils).
- **Widgets:** Prefer small, reusable `StatelessWidget` compositions over deep nesting or private helper methods.
- **Error Handling:** Explicitly handle exceptions; never let code fail silently.

### Testing
- **Pattern:** Follow Arrange-Act-Assert (AAA).
- **Mocks:** Prefer fakes or stubs over generated mocks where possible.
- **Async:** Use `async`/`await` for all asynchronous operations with proper error handling.

## Boundaries
- **NEVER** use `!` (bang operator) unless null-safety is guaranteed.
- **NEVER** perform network calls or expensive logic inside `build()` methods.
- **ASK FIRST** before adding new third-party dependencies to `pubspec.yaml`.
