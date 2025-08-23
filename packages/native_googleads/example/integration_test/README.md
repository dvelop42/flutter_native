# Integration Tests for Native Google Ads

This directory contains comprehensive integration tests for the Native Google Ads Flutter plugin, specifically focused on platform view functionality.

## Test Coverage

### 1. Platform View Tests (`platform_view_integration_test.dart`)
- **Creation and Disposal**: Tests proper creation and cleanup of banner and native ad platform views
- **Multiple Concurrent Views**: Verifies multiple ads can coexist without conflicts
- **Visibility Changes**: Tests toggling ad visibility and scrolling behavior
- **Performance Benchmarks**: Measures ad creation time and ensures acceptable performance
- **Memory Management**: Validates proper disposal and no memory leaks
- **Dynamic Size Changes**: Tests runtime size adjustments for ads
- **Error Handling**: Verifies graceful handling of invalid ad units and network errors
- **Preloaded Ads**: Tests preloading and displaying ads
- **Platform-Specific Behavior**: Platform-specific verifications for Android and iOS

### 2. Lifecycle Management Tests (`lifecycle_integration_test.dart`)
- **App Lifecycle**: Tests ad behavior during pause/resume, inactive states
- **Fullscreen Ads**: Validates interstitial and rewarded ads during lifecycle changes
- **State Preservation**: Ensures ads survive navigation and state changes
- **Configuration Changes**: Tests theme and locale changes
- **Edge Cases**: Stress tests with rapid lifecycle changes

### 3. Basic Plugin Tests (`plugin_integration_test.dart`)
- Basic plugin functionality and platform version retrieval

## Running Tests

### Prerequisites
1. Flutter SDK installed and configured
2. Connected device or running emulator/simulator
3. Internet connection for ad loading

### Run All Tests
```bash
# Make the script executable
chmod +x integration_test/run_all_tests.sh

# Run all tests
./integration_test/run_all_tests.sh
```

### Run Individual Test Files
```bash
# Platform view tests
flutter test integration_test/platform_view_integration_test.dart

# Lifecycle tests
flutter test integration_test/lifecycle_integration_test.dart

# Basic plugin tests
flutter test integration_test/plugin_integration_test.dart
```

### Run on Specific Device
```bash
# List available devices
flutter devices

# Run on specific device
flutter test integration_test/platform_view_integration_test.dart -d <device_id>
```

### Run with Driver (for CI/CD)
```bash
# Run with driver for automated testing
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/platform_view_integration_test.dart
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Integration Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  integration-test-android:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Run Android integration tests
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 29
          script: |
            cd packages/native_googleads/example
            flutter test integration_test/

  integration-test-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Run iOS integration tests
        run: |
          cd packages/native_googleads/example
          flutter test integration_test/
```

## Test Configuration

The tests use Google's test ad unit IDs which always return test ads:
- Never use production ad unit IDs in tests
- Test ads don't generate revenue
- Test ads help verify integration without policy violations

## Debugging Failed Tests

1. **Check device logs**:
   ```bash
   # Android
   adb logcat | grep -i "ads"
   
   # iOS
   xcrun simctl spawn booted log stream | grep -i "ads"
   ```

2. **Enable verbose logging**:
   ```dart
   // In test setup
   debugPrint('Detailed test information');
   ```

3. **Run specific test groups**:
   ```bash
   flutter test integration_test/platform_view_integration_test.dart \
     --name="Platform View Creation and Disposal"
   ```

## Performance Metrics

Expected performance benchmarks (may vary by device):
- Banner ad creation: < 10 seconds
- Multiple ads (5 banners): < 15 seconds
- Native ad creation: < 10 seconds
- Ad disposal: < 1 second

## Known Limitations

1. **Screen rotation tests**: Currently not automated due to Flutter test limitations
2. **Real ad loading**: Tests use test ad units which may behave differently from production
3. **Memory profiling**: Deep memory analysis requires platform-specific tools

## Contributing

When adding new integration tests:
1. Follow the existing test structure
2. Use descriptive test names
3. Add appropriate timeouts for ad loading
4. Clean up resources in tearDown if needed
5. Update this README with new test coverage

## Troubleshooting

### Common Issues

1. **"No connected devices"**
   - Ensure emulator/simulator is running
   - Check `flutter doctor` output

2. **"Ad failed to load"**
   - Verify internet connection
   - Check if test ad unit IDs are correct
   - Ensure ads SDK is properly initialized

3. **"Test timeout"**
   - Increase timeout in pumpAndSettle
   - Check if ads are actually loading

4. **"Platform view not found"**
   - Verify platform-specific setup in Android/iOS projects
   - Check MainActivity/AppDelegate configuration