#!/bin/bash

# Integration Tests Runner for Native Google Ads
# This script runs all integration tests on connected devices

echo "========================================="
echo "Native Google Ads Integration Tests"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Function to run a test
run_test() {
    local test_file=$1
    local test_name=$2
    
    echo -e "\n${YELLOW}Running: $test_name${NC}"
    echo "----------------------------------------"
    
    if flutter test integration_test/$test_file; then
        echo -e "${GREEN}✓ $test_name passed${NC}"
        return 0
    else
        echo -e "${RED}✗ $test_name failed${NC}"
        return 1
    fi
}

# Navigate to example directory
cd "$(dirname "$0")/.." || exit 1

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Check for connected devices
echo -e "\n${YELLOW}Checking for connected devices...${NC}"
flutter devices

# Ask user to select device if multiple are available
echo -e "\n${YELLOW}Make sure your test device/emulator is running${NC}"
read -p "Press Enter to continue..."

# Track test results
TESTS_PASSED=0
TESTS_FAILED=0

# Run all integration tests
echo -e "\n${GREEN}Starting Integration Tests${NC}"
echo "========================================="

# Basic plugin test
if run_test "plugin_integration_test.dart" "Basic Plugin Test"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

# Platform view tests
if run_test "platform_view_integration_test.dart" "Platform View Tests"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

# Lifecycle tests
if run_test "lifecycle_integration_test.dart" "Lifecycle Management Tests"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
fi

# Summary
echo -e "\n========================================="
echo "Test Results Summary"
echo "========================================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed successfully! 🎉${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed. Please review the output above.${NC}"
    exit 1
fi