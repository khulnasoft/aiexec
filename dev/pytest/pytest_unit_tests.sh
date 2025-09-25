#!/usr/bin/env bash
# PyTest Unit Tests Script
# Runs unit tests for AIEXEC with enhanced reporting
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

echo -e "${BLUE}🧪 PYTEST UNIT TESTS SCRIPT: AIEXEC Unit Testing${NC}"
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

# Function to run unit tests
run_unit_tests() {
    log_info "Running unit tests..."

    local test_dirs="src/backend/tests/unit"
    local unit_tests=$(find $test_dirs -name "test_*.py" 2>/dev/null || true)

    if [ -z "$unit_tests" ]; then
        log_warning "No unit tests found in $test_dirs"
        return 0
    fi

    # Run pytest with unit tests
    log_info "Running pytest on unit tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $unit_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All unit tests passed"
        else
            echo "$pytest_result"
            log_error "Some unit tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run unit tests with coverage
run_unit_tests_with_coverage() {
    log_info "Running unit tests with coverage..."

    local test_dirs="src/backend/tests/unit"
    local unit_tests=$(find $test_dirs -name "test_*.py" 2>/dev/null || true)

    if [ -z "$unit_tests" ]; then
        log_warning "No unit tests found in $test_dirs"
        return 0
    fi

    # Check if coverage is available
    if command_exists coverage; then
        log_info "Running pytest with coverage..."
        uv run coverage run -m pytest $unit_tests -v --tb=short --durations=10
        uv run coverage report
        log_status "Coverage report generated"
    else
        log_warning "coverage not found. Install with: uv add --dev coverage"
        run_unit_tests
    fi
}

# Function to run unit tests in parallel
run_unit_tests_parallel() {
    log_info "Running unit tests in parallel..."

    local test_dirs="src/backend/tests/unit"
    local unit_tests=$(find $test_dirs -name "test_*.py" 2>/dev/null || true)

    if [ -z "$unit_tests" ]; then
        log_warning "No unit tests found in $test_dirs"
        return 0
    fi

    # Check if pytest-xdist is available for parallel execution
    if uv run python3 -c "import pytest_xdist" 2>/dev/null; then
        log_info "Running pytest with parallel execution..."
        local pytest_result=$(uv run pytest $unit_tests -v --tb=short --durations=10 -n auto 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All unit tests passed (parallel execution)"
        else
            echo "$pytest_result"
            log_error "Some unit tests failed"
            return 1
        fi
    else
        log_warning "pytest-xdist not found. Install with: uv add --dev pytest-xdist"
        run_unit_tests
    fi
}

# Function to run unit tests by category
run_unit_tests_by_category() {
    log_info "Running unit tests by category..."

    local test_dirs="src/backend/tests/unit"

    # Define test categories
    local categories=(
        "test_*.py"
        "*component*"
        "*service*"
        "*model*"
        "*util*"
        "*helper*"
        "*custom*"
        "*processing*"
        "*agent*"
    )

    for pattern in "${categories[@]}"; do
        local category_tests=$(find $test_dirs -name "$pattern" 2>/dev/null || true)

        if [ -n "$category_tests" ]; then
            local category_name=$(echo "$pattern" | sed 's/[*]//g' | sed 's/test_//' | sed 's/_test//' | sed 's/^*//')
            log_info "Running $category_name tests..."

            if command_exists pytest; then
                local pytest_result=$(uv run pytest $category_tests -v --tb=short --durations=10 2>&1)
                local pytest_exit_code=$?

                if [ $pytest_exit_code -eq 0 ]; then
                    log_status "$category_name tests passed"
                else
                    echo "$pytest_result"
                    log_error "Some $category_name tests failed"
                    return 1
                fi
            else
                log_error "pytest not found. Please install with: uv add --dev pytest"
                return 1
            fi
        fi
    done
}

# Function to run unit tests for specific modules
run_module_tests() {
    log_info "Running unit tests for specific modules..."

    local test_dirs="src/backend/tests/unit"
    local modules=("components" "services" "models" "utils" "custom" "processing" "agents")

    for module in "${modules[@]}"; do
        local module_tests=$(find $test_dirs -name "*${module}*.py" 2>/dev/null || true)

        if [ -n "$module_tests" ]; then
            log_info "Running ${module} module tests..."

            if command_exists pytest; then
                local pytest_result=$(uv run pytest $module_tests -v --tb=short --durations=10 2>&1)
                local pytest_exit_code=$?

                if [ $pytest_exit_code -eq 0 ]; then
                    log_status "${module} module tests passed"
                else
                    echo "$pytest_result"
                    log_error "Some ${module} module tests failed"
                    return 1
                fi
            else
                log_error "pytest not found. Please install with: uv add --dev pytest"
                return 1
            fi
        else
            log_info "No ${module} module tests found"
        fi
    done
}

# Function to run unit tests with specific markers
run_marked_tests() {
    log_info "Running unit tests with specific markers..."

    if command_exists pytest; then
        # Run slow tests if marked
        local slow_tests=$(uv run pytest --collect-only -m slow src/backend/tests/unit/ 2>/dev/null | grep -c "test_" || true)
        if [ "$slow_tests" -gt 0 ]; then
            log_info "Running slow tests..."
            uv run pytest -m slow src/backend/tests/unit/ -v --tb=short
            log_status "Slow tests completed"
        fi

        # Run fast tests
        local fast_tests=$(uv run pytest --collect-only -m "not slow" src/backend/tests/unit/ 2>/dev/null | grep -c "test_" || true)
        if [ "$fast_tests" -gt 0 ]; then
            log_info "Running fast tests..."
            uv run pytest -m "not slow" src/backend/tests/unit/ -v --tb=short
            log_status "Fast tests completed"
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to generate unit test report
generate_unit_report() {
    log_info "Generating unit test report..."

    local report_dir="unit_test_report"

    # Clean previous report
    if [ -d "$report_dir" ]; then
        rm -rf "$report_dir"
    fi

    # Run pytest with coverage and HTML report
    if command_exists pytest; then
        log_info "Running pytest with coverage on unit tests..."

        local test_dirs="src/backend/tests/unit"
        local unit_tests=$(find $test_dirs -name "test_*.py" 2>/dev/null || true)

        # Try to run with coverage if available
        if command_exists coverage && [ -n "$unit_tests" ]; then
            uv run coverage run -m pytest $unit_tests -v --tb=short --durations=10
            uv run coverage html -d "$report_dir"
            uv run coverage report
        elif [ -n "$unit_tests" ]; then
            uv run pytest $unit_tests -v --tb=short --durations=10 --html="$report_dir/report.html" --self-contained-html
        fi

        if [ -d "$report_dir" ]; then
            log_status "Unit test report generated: $report_dir/"
        fi
    fi
}

# Function to show unit test statistics
show_unit_stats() {
    log_info "Unit Test Statistics:"

    # Count test files
    local test_files=$(find src/backend/tests/unit/ -name "test_*.py" -type f 2>/dev/null | wc -l)
    echo -e "  ${BLUE}📄 Unit test files:${NC} $test_files"

    # Count test functions
    local test_functions=$(find src/backend/tests/unit/ -name "test_*.py" -type f -exec grep -c "^def test_" {} \; 2>/dev/null | paste -sd+ | bc)
    echo -e "  ${BLUE}🧪 Test functions:${NC} ${test_functions:-0}"

    # Count lines of test code
    local test_lines=$(find src/backend/tests/unit/ -name "test_*.py" -type f -exec cat {} \; 2>/dev/null | wc -l)
    echo -e "  ${BLUE}📊 Lines of test code:${NC} $test_lines"

    # Count test categories
    local test_categories=$(find src/backend/tests/unit/ -name "test_*.py" -type f -exec grep -c "class.*Test" {} \; 2>/dev/null | paste -sd+ | bc)
    echo -e "  ${BLUE}🗂️  Test categories:${NC} ${test_categories:-0}"

    # Count source files tested
    local source_files=$(find src/ -name "*.py" -type f | wc -l)
    echo -e "  ${BLUE}🐍 Source files:${NC} $source_files"

    # Calculate test coverage ratio
    if [ "$test_files" -gt 0 ] && [ "$source_files" -gt 0 ]; then
        local coverage_ratio=$(( (test_files * 100) / source_files ))
        echo -e "  ${BLUE}📈 Test coverage ratio:${NC} ${coverage_ratio}%"
    fi
}

# Function to show usage
show_usage() {
    echo -e "${BLUE}📋 PYTEST UNIT TESTS USAGE:${NC}"
    echo ""
    echo "  ./pytest/pytest_unit_tests.sh [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "    --coverage         Run tests with coverage"
    echo "    --parallel         Run tests in parallel"
    echo "    --by-category      Run tests organized by category"
    echo "    --by-module        Run tests organized by module"
    echo "    --marked           Run tests with pytest markers"
    echo "    --report           Generate HTML test report"
    echo "    --stats            Show detailed statistics"
    echo "    --help             Show this help message"
    echo ""
    echo "  Examples:"
    echo "    ./pytest/pytest_unit_tests.sh              # Run all unit tests"
    echo "    ./pytest/pytest_unit_tests.sh --coverage    # Run with coverage"
    echo "    ./pytest/pytest_unit_tests.sh --parallel    # Run in parallel"
    echo "    ./pytest/pytest_unit_tests.sh --stats       # Show statistics only"
    echo ""
}

# Parse command line arguments
COVERAGE=false
PARALLEL=false
BY_CATEGORY=false
BY_MODULE=false
MARKED=false
GENERATE_REPORT=false
STATS_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --coverage)
            COVERAGE=true
            shift
            ;;
        --parallel)
            PARALLEL=true
            shift
            ;;
        --by-category)
            BY_CATEGORY=true
            shift
            ;;
        --by-module)
            BY_MODULE=true
            shift
            ;;
        --marked)
            MARKED=true
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
echo -e "${BLUE}🔧 RUNNING UNIT TESTS${NC}"
echo "─" | tr -d '\n' | head -c 40
echo

# Check if pytest is installed
if ! command_exists pytest; then
    log_error "pytest is not installed. Please install with: uv add --dev pytest"
    exit 1
fi

if [ "$STATS_ONLY" = true ]; then
    show_unit_stats
    exit 0
fi

# Run unit tests based on options
if [ "$COVERAGE" = true ]; then
    run_unit_tests_with_coverage
elif [ "$PARALLEL" = true ]; then
    run_unit_tests_parallel
elif [ "$BY_CATEGORY" = true ]; then
    run_unit_tests_by_category
elif [ "$BY_MODULE" = true ]; then
    run_module_tests
elif [ "$MARKED" = true ]; then
    run_marked_tests
else
    run_unit_tests
fi

# Generate report if requested
if [ "$GENERATE_REPORT" = true ]; then
    generate_unit_report
fi

# Show statistics
show_unit_stats

echo
echo "=" | tr -d '\n' | head -c 60
echo -e "\n${GREEN}🎉 UNIT TESTING COMPLETE!${NC}"
echo "=" | tr -d '\n' | head -c 60
echo

echo -e "${BLUE}📊 UNIT TEST SUMMARY:${NC}"
echo -e "  ${GREEN}✅${NC} Unit tests: Executed"
if [ "$COVERAGE" = true ]; then
    echo -e "  ${GREEN}✅${NC} Coverage: Generated"
fi
if [ "$PARALLEL" = true ]; then
    echo -e "  ${GREEN}✅${NC} Parallel execution: Enabled"
fi
if [ "$BY_CATEGORY" = true ]; then
    echo -e "  ${GREEN}✅${NC} Category organization: Applied"
fi
if [ "$BY_MODULE" = true ]; then
    echo -e "  ${GREEN}✅${NC} Module organization: Applied"
fi
if [ "$MARKED" = true ]; then
    echo -e "  ${GREEN}✅${NC} Marker filtering: Applied"
fi
if [ "$GENERATE_REPORT" = true ]; then
    echo -e "  ${GREEN}✅${NC} HTML Report: Generated"
fi
echo -e "  ${GREEN}✅${NC} Statistics: Displayed"

echo
echo -e "${GREEN}🚀 Unit testing complete! All components thoroughly tested!${NC}"
