# Contributing to ContactFlow

Thank you for helping improve ContactFlow.

## Development workflow

1. Fork the repository and create a focused branch.
2. Run `flutter pub get`.
3. Keep changes small, accessible, and consistent with the existing architecture.
4. Add or update tests for user-visible behavior.
5. Run the quality checks before opening a pull request.

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Pull-request checklist

- The change has a clear purpose and scope.
- New UI works at narrow and wide window sizes.
- Interactive controls have labels, tooltips, or appropriate semantics.
- Seed data remains fictional and no credentials or personal information are committed.
- Tests cover important state or navigation changes.
- Documentation reflects any changed behavior.

## Scope

ContactFlow intentionally avoids third-party dependencies unless they provide clear value that cannot be achieved with the Flutter SDK. Discuss large architectural changes before investing in an implementation.
