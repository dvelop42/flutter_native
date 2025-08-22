# Contributing to Native Google Ads

First off, thank you for considering contributing to Native Google Ads! It's people like you that make Native Google Ads such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please be respectful and considerate in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title** for the issue to identify the problem
- **Describe the exact steps which reproduce the problem** in as many details as possible
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps**
- **Explain which behavior you expected to see instead and why**
- **Include screenshots and animated GIFs** if possible
- **Include your environment details**:
  - Flutter version (`flutter --version`)
  - Platform (Android/iOS)
  - Device/Emulator specifications
  - Plugin version

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title** for the issue to identify the suggestion
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior** and **explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code follows the existing code style
6. Issue that pull request!

## Development Setup

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / Xcode for platform-specific development
- Git

### Setting Up Your Development Environment

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/yourusername/native_googleads.git
   cd native_googleads
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   cd example
   flutter pub get
   ```

3. **Run tests**
   ```bash
   flutter test
   ```

4. **Run the example app**
   ```bash
   cd example
   flutter run
   ```

### Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write code following the style guide
   - Add/update tests as needed
   - Update documentation

3. **Test your changes**
   ```bash
   # Run unit tests
   flutter test
   
   # Run the example app
   cd example
   flutter run
   
   # Check code formatting
   flutter format --set-exit-if-changed .
   
   # Analyze code
   flutter analyze
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add amazing feature"
   ```
   
   Follow conventional commits specification:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `style:` for formatting changes
   - `refactor:` for code refactoring
   - `test:` for test additions/changes
   - `chore:` for maintenance tasks

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your fork and branch
   - Fill in the PR template
   - Submit for review

## Style Guide

### Dart/Flutter Code Style

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter format` to format your code
- Keep line length to 80 characters when possible
- Use meaningful variable and function names
- Add comments for complex logic
- Prefer single quotes for strings

### Documentation Style

- Use clear, concise language
- Include code examples where appropriate
- Update the README if you change functionality
- Add inline documentation for public APIs

### Testing Guidelines

- Write tests for all new functionality
- Maintain or improve code coverage
- Test both success and failure cases
- Use descriptive test names
- Group related tests

Example test structure:
```dart
group('FeatureName', () {
  test('should do something when condition is met', () {
    // Arrange
    final instance = MyClass();
    
    // Act
    final result = instance.doSomething();
    
    // Assert
    expect(result, expectedValue);
  });
});
```

## Platform-Specific Development

### Android (Kotlin)

- Follow [Kotlin coding conventions](https://kotlinlang.org/docs/coding-conventions.html)
- Test on multiple Android versions (minimum API 24)
- Update `android/` code when needed

### iOS (Swift)

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Test on multiple iOS versions (minimum iOS 13.0)
- Update `ios/` code when needed
- Ensure Swift Package Manager dependencies are properly configured

## Release Process

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md` with release notes
3. Run all tests and ensure they pass
4. Create a git tag for the version
5. Push changes and tag
6. Publish to pub.dev (maintainers only)

## Questions?

Feel free to open an issue with the `question` label or reach out to the maintainers.

## Recognition

Contributors will be recognized in:
- The project README
- Release notes for significant contributions
- GitHub contributors page

Thank you for contributing to Native Google Ads! 🎉