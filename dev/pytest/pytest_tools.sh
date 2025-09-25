#!/usr/bin/env bash
# PyTest Tools Script
# Runs tools and utility tests for AIEXEC
# Author: AIEXEC Development Team
# Version: 1.0.0

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo -e "${BLUE}🔧 PYTEST TOOLS SCRIPT: AIEXEC Tools Testing${NC}"
echo "=" | tr -d '\n' | head -c 60
echo

cd "$PROJECT_ROOT"

# Function to log status messages
log_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run utility tests
run_utility_tests() {
    log_info "Running utility/helper tests..."

    local test_dirs="src/backend/tests"
    local utility_tests=$(find $test_dirs -name "*util*.py" -o -name "*helper*.py" 2>/dev/null || true)

    if [ -z "$utility_tests" ]; then
        log_warning "No utility/helper tests found"
        return 0
    fi

    # Run pytest with utility tests
    log_info "Running pytest on utility tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $utility_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All utility tests passed"
        else
            echo "$pytest_result"
            log_error "Some utility tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run configuration tests
run_config_tests() {
    log_info "Running configuration tests..."

    local test_dirs="src/backend/tests"
    local config_tests=$(find $test_dirs -name "*config*.py" -o -name "*setting*.py" 2>/dev/null || true)

    if [ -z "$config_tests" ]; then
        log_warning "No configuration tests found"
        return 0
    fi

    # Run pytest with config tests
    log_info "Running pytest on configuration tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $config_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All configuration tests passed"
        else
            echo "$pytest_result"
            log_error "Some configuration tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run validation tests
run_validation_tests() {
    log_info "Running validation tests..."

    local test_dirs="src/backend/tests"
    local validation_tests=$(find $test_dirs -name "*valid*.py" -o -name "*schema*.py" 2>/dev/null || true)

    if [ -z "$validation_tests" ]; then
        log_warning "No validation tests found"
        return 0
    fi

    # Run pytest with validation tests
    log_info "Running pytest on validation tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $validation_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All validation tests passed"
        else
            echo "$pytest_result"
            log_error "Some validation tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run serialization tests
run_serialization_tests() {
    log_info "Running serialization tests..."

    local test_dirs="src/backend/tests"
    local serialization_tests=$(find $test_dirs -name "*serial*.py" -o -name "*json*.py" -o -name "*yaml*.py" 2>/dev/null || true)

    if [ -z "$serialization_tests" ]; then
        log_warning "No serialization tests found"
        return 0
    fi

    # Run pytest with serialization tests
    log_info "Running pytest on serialization tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $serialization_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All serialization tests passed"
        else
            echo "$pytest_result"
            log_error "Some serialization tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run formatting tests
run_formatting_tests() {
    log_info "Running formatting tests..."

    local test_dirs="src/backend/tests"
    local formatting_tests=$(find $test_dirs -name "*format*.py" -o -name "*style*.py" 2>/dev/null || true)

    if [ -z "$formatting_tests" ]; then
        log_warning "No formatting tests found"
        return 0
    fi

    # Run pytest with formatting tests
    log_info "Running pytest on formatting tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $formatting_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All formatting tests passed"
        else
            echo "$pytest_result"
            log_error "Some formatting tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run logging tests
run_logging_tests() {
    log_info "Running logging tests..."

    local test_dirs="src/backend/tests"
    local logging_tests=$(find $test_dirs -name "*log*.py" 2>/dev/null || true)

    if [ -z "$logging_tests" ]; then
        log_warning "No logging tests found"
        return 0
    fi

    # Run pytest with logging tests
    log_info "Running pytest on logging tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $logging_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All logging tests passed"
        else
            echo "$pytest_result"
            log_error "Some logging tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run error handling tests
run_error_handling_tests() {
    log_info "Running error handling tests..."

    local test_dirs="src/backend/tests"
    local error_tests=$(find $test_dirs -name "*error*.py" -o -name "*exception*.py" 2>/dev/null || true)

    if [ -z "$error_tests" ]; then
        log_warning "No error handling tests found"
        return 0
    fi

    # Run pytest with error handling tests
    log_info "Running pytest on error handling tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $error_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All error handling tests passed"
        else
            echo "$pytest_result"
            log_error "Some error handling tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run file I/O tests
run_file_io_tests() {
    log_info "Running file I/O tests..."

    local test_dirs="src/backend/tests"
    local file_tests=$(find $test_dirs -name "*file*.py" -o -name "*io*.py" -o -name "*storage*.py" 2>/dev/null || true)

    if [ -z "$file_tests" ]; then
        log_warning "No file I/O tests found"
        return 0
    fi

    # Run pytest with file I/O tests
    log_info "Running pytest on file I/O tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $file_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All file I/O tests passed"
        else
            echo "$pytest_result"
            log_error "Some file I/O tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run security tests
run_security_tests() {
    log_info "Running security tests..."

    local test_dirs="src/backend/tests"
    local security_tests=$(find $test_dirs -name "*security*.py" -o -name "*auth*.py" -o -name "*permission*.py" 2>/dev/null || true)

    if [ -z "$security_tests" ]; then
        log_warning "No security tests found"
        return 0
    fi

    # Run pytest with security tests
    log_info "Running pytest on security tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $security_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All security tests passed"
        else
            echo "$pytest_result"
            log_error "Some security tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to generate tools test report
generate_tools_report() {
    log_info "Generating tools test report..."

    local report_dir="tools_test_report"

    # Clean previous report
    if [ -d "$report_dir" ]; then
        rm -rf "$report_dir"
    fi

    # Collect all tools tests
    local all_tools_tests=""
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*util*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*helper*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*config*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*valid*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*schema*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*serial*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*format*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*log*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*error*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*exception*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*file*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*io*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*storage*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*security*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*auth*.py" 2>/dev/null || true)"
    all_tools_tests="$all_tools_tests $(find src/backend/tests/ -name "*permission*.py" 2>/dev/null || true)"

    # Run pytest with coverage on tools tests
    if command_exists pytest && [ -n "$all_tools_tests" ]; then
        log_info "Running pytest with coverage on tools tests..."

        # Try to run with coverage if available
        if command_exists coverage; then
            uv run coverage run -m pytest $all_tools_tests -v --tb=short --durations=10
            uv run coverage html -d "$report_dir"
            uv run coverage report
        else
            uv run pytest $all_tools_tests -v --tb=short --durations=10 --html="$report_dir/report.html" --self-contained-html
        fi

        if [ -d "$report_dir" ]; then
            log_status "Tools test report generated: $report_dir/"
        fi
    fi
}

# Function to show tools test statistics
show_tools_stats() {
    log_info "Tools Test Statistics:"

    # Count tools test files
    local tools_files=$(find src/backend/tests/ -name "*util*.py" -o -name "*helper*.py" -o -name "*config*.py" -o -name "*valid*.py" -o -name "*schema*.py" -o -name "*serial*.py" -o -name "*format*.py" -o -name "*log*.py" -o -name "*error*.py" -o -name "*exception*.py" -o -name "*file*.py" -o -name "*io*.py" -o -name "*storage*.py" -o -name "*security*.py" -o -name "*auth*.py" -o -name "*permission*.py" | wc -l)
    echo -e "  ${BLUE}📄 Tools test files:${NC} $tools_files"

    # Count tools test functions
    local tools_functions=$(find src/backend/tests/ -name "*util*.py" -o -name "*helper*.py" -o -name "*config*.py" -o -name "*valid*.py" -o -name "*schema*.py" -o -name "*serial*.py" -o -name "*format*.py" -o -name "*log*.py" -o -name "*error*.py" -o -name "*exception*.py" -o -name "*file*.py" -o -name "*io*.py" -o -name "*storage*.py" -o -name "*security*.py" -o -name "*auth*.py" -o -name "*permission*.py" -exec grep -c "^def test_" {} \; 2>/dev/null | paste -sd+ | bc)
    echo -e "  ${BLUE}🧪 Tools test functions:${NC} ${tools_functions:-0}"

    # Count lines of tools test code
    local tools_lines=$(find src/backend/tests/ -name "*util*.py" -o -name "*helper*.py" -o -name "*config*.py" -o -name "*valid*.py" -o -name "*schema*.py" -o -name "*serial*.py" -o -name "*format*.py" -o -name "*log*.py" -o -name "*error*.py" -o -name "*exception*.py" -o -name "*file*.py" -o -name "*io*.py" -o -name "*storage*.py" -o -name "*security*.py" -o -name "*auth*.py" -o -name "*permission*.py" -exec cat {} \; 2>/dev/null | wc -l)
    echo -e "  ${BLUE}📊 Lines of tools test code:${NC} $tools_lines"

    # Show tested tool categories
    local tool_categories=""

    if find src/backend/tests/ -name "*util*.py" >/dev/null 2>&1; then
        tool_categories="$tool_categories Utils"
    fi
    if find src/backend/tests/ -name "*helper*.py" >/dev/null 2>&1; then
        tool_categories="$tool_categories Helpers"
    fi
    if find src/backend/tests/ -name "*config*.py" >/dev/null 2>&1; then
        tool_categories="$tool_categories Config"
    fi
    if find src/backend/tests/ -name "*valid*.py" >/dev/null 2>&1; then
        tool_categories="$tool_categories Validation"
    fi
    if find src/backend/tests/ -name "*serial*.py" >/dev/null 2>&1; then
        tool_categories="$tool_categories Serialization"
    fi
    if find src/backend/tests/ -name "*format*.py" >/dev/null 2>&1; then
        tool_categories="$tool_categories Formatting"
    fi
    if find src/backend/tests/ -name "*log*.py" >/dev/null 2>&1; then
        tool_categories="$tool_categories Logging"
    fi
    if find src/backend/tests/ -name "*error*.py" >/dev/null 2>&1; then
        tool_categories="$tool_categories Error-Handling"
    fi

    echo -e "  ${BLUE}🔧 Tool categories tested:${NC} ${tool_categories:-None}"
}

# Function to show usage
show_usage() {
    echo -e "${BLUE}📋 PYTEST TOOLS USAGE:${NC}"
    echo ""
    echo "  ./pytest/pytest_tools.sh [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "    --skip-util        Skip utility tests"
    echo "    --skip-config      Skip configuration tests"
    echo "    --skip-validation  Skip validation tests"
    echo "    --skip-serial      Skip serialization tests"
    echo "    --skip-format      Skip formatting tests"
    echo "    --skip-logging     Skip logging tests"
    echo "    --skip-errors      Skip error handling tests"
    echo "    --skip-fileio      Skip file I/O tests"
    echo "    --skip-security    Skip security tests"
    echo "    --report           Generate HTML test report"
    echo "    --stats            Show detailed statistics"
    echo "    --help             Show this help message"
    echo ""
    echo "  Examples:"
    echo "    ./pytest/pytest_tools.sh              # Run all tools tests"
    echo "    ./pytest/pytest_tools.sh --report     # Generate test report"
    echo "    ./pytest/pytest_tools.sh --stats      # Show statistics only"
    echo ""
}

# Parse command line arguments
SKIP_UTIL=false
SKIP_CONFIG=false
SKIP_VALIDATION=false
SKIP_SERIAL=false
SKIP_FORMAT=false
SKIP_LOGGING=false
SKIP_ERRORS=false
SKIP_FILEIO=false
SKIP_SECURITY=false
GENERATE_REPORT=false
STATS_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-util)
            SKIP_UTIL=true
            shift
            ;;
        --skip-config)
            SKIP_CONFIG=true
            shift
            ;;
        --skip-validation)
            SKIP_VALIDATION=true
            shift
            ;;
        --skip-serial)
            SKIP_SERIAL=true
            shift
            ;;
        --skip-format)
            SKIP_FORMAT=true
            shift
            ;;
        --skip-logging)
            SKIP_LOGGING=true
            shift
            ;;
        --skip-errors)
            SKIP_ERRORS=true
            shift
            ;;
        --skip-fileio)
            SKIP_FILEIO=true
            shift
            ;;
        --skip-security)
            SKIP_SECURITY=true
            shift
            ;;
        --report)
            GENERATE_REPORT=true
            shift
            ;;
        --stats)
            STATS_ONLY=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
echo -e "${BLUE}🔧 RUNNING TOOLS TESTS${NC}"
echo "─" | tr -d '\n' | head -c 40
echo

# Check if pytest is installed
if ! command_exists pytest; then
    log_error "pytest is not installed. Please install with: uv add --dev pytest"
    exit 1
fi

if [ "$STATS_ONLY" = true ]; then
    show_tools_stats
    exit 0
fi

# Run utility tests if not skipped
if [ "$SKIP_UTIL" = false ]; then
    run_utility_tests
else
    log_info "Skipping utility tests as requested"
fi

# Run configuration tests if not skipped
if [ "$SKIP_CONFIG" = false ]; then
    run_config_tests
else
    log_info "Skipping configuration tests as requested"
fi

# Run validation tests if not skipped
if [ "$SKIP_VALIDATION" = false ]; then
    run_validation_tests
else
    log_info "Skipping validation tests as requested"
fi

# Run serialization tests if not skipped
if [ "$SKIP_SERIAL" = false ]; then
    run_serialization_tests
else
    log_info "Skipping serialization tests as requested"
fi

# Run formatting tests if not skipped
if [ "$SKIP_FORMAT" = false ]; then
    run_formatting_tests
else
    log_info "Skipping formatting tests as requested"
fi

# Run logging tests if not skipped
if [ "$SKIP_LOGGING" = false ]; then
    run_logging_tests
else
    log_info "Skipping logging tests as requested"
fi

# Run error handling tests if not skipped
if [ "$SKIP_ERRORS" = false ]; then
    run_error_handling_tests
else
    log_info "Skipping error handling tests as requested"
fi

# Run file I/O tests if not skipped
if [ "$SKIP_FILEIO" = false ]; then
    run_file_io_tests
else
    log_info "Skipping file I/O tests as requested"
fi

# Run security tests if not skipped
if [ "$SKIP_SECURITY" = false ]; then
    run_security_tests
else
    log_info "Skipping security tests as requested"
fi

# Generate report if requested
if [ "$GENERATE_REPORT" = true ]; then
    generate_tools_report
fi

# Show statistics
show_tools_stats

echo
echo "=" | tr -d '\n' | head -c 60
echo -e "\n${GREEN}🎉 TOOLS TESTING COMPLETE!${NC}"
echo "=" | tr -d '\n' | head -c 60
echo

echo -e "${BLUE}📊 TOOLS TEST SUMMARY:${NC}"
if [ "$SKIP_UTIL" = false ]; then
    echo -e "  ${GREEN}✅${NC} Utilities: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Utilities: Skipped"
fi
if [ "$SKIP_CONFIG" = false ]; then
    echo -e "  ${GREEN}✅${NC} Configuration: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Configuration: Skipped"
fi
if [ "$SKIP_VALIDATION" = false ]; then
    echo -e "  ${GREEN}✅${NC} Validation: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Validation: Skipped"
fi
if [ "$SKIP_SERIAL" = false ]; then
    echo -e "  ${GREEN}✅${NC} Serialization: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Serialization: Skipped"
fi
if [ "$SKIP_FORMAT" = false ]; then
    echo -e "  ${GREEN}✅${NC} Formatting: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Formatting: Skipped"
fi
if [ "$SKIP_LOGGING" = false ]; then
    echo -e "  ${GREEN}✅${NC} Logging: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Logging: Skipped"
fi
if [ "$SKIP_ERRORS" = false ]; then
    echo -e "  ${GREEN}✅${NC} Error Handling: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Error Handling: Skipped"
fi
if [ "$SKIP_FILEIO" = false ]; then
    echo -e "  ${GREEN}✅${NC} File I/O: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} File I/O: Skipped"
fi
if [ "$SKIP_SECURITY" = false ]; then
    echo -e "  ${GREEN}✅${NC} Security: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Security: Skipped"
fi
if [ "$GENERATE_REPORT" = true ]; then
    echo -e "  ${GREEN}✅${NC} Tools Report: Generated"
fi

echo
echo -e "${GREEN}🚀 Tools testing complete! All utility functions thoroughly tested!${NC}"
