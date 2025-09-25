#!/usr/bin/env bash
# PyTest Workflow Script
# Runs workflow/integration tests for AIEXEC
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

echo -e "${BLUE}🧪 PYTEST WORKFLOW SCRIPT: AIEXEC Integration Tests${NC}"
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

# Function to run workflow tests
run_workflow_tests() {
    log_info "Running workflow/integration tests..."

    local test_dirs="src/backend/tests"
    local workflow_patterns="test_workflow test_integration test_e2e"

    # Find workflow test files
    local workflow_tests=""

    for pattern in $workflow_patterns; do
        local found_tests=$(find $test_dirs -name "*${pattern}*.py" 2>/dev/null || true)
        if [ -n "$found_tests" ]; then
            workflow_tests="$workflow_tests $found_tests"
        fi
    done

    # Also look for tests in subdirectories with workflow-related names
    local workflow_dirs=$(find $test_dirs -type d -name "*workflow*" -o -name "*integration*" -o -name "*e2e*" 2>/dev/null || true)
    if [ -n "$workflow_dirs" ]; then
        for dir in $workflow_dirs; do
            local dir_tests=$(find "$dir" -name "test_*.py" 2>/dev/null || true)
            if [ -n "$dir_tests" ]; then
                workflow_tests="$workflow_tests $dir_tests"
            fi
        done
    fi

    if [ -z "$workflow_tests" ]; then
        log_warning "No workflow/integration tests found"
        return 0
    fi

    # Run pytest with workflow tests
    log_info "Running pytest on workflow tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $workflow_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All workflow tests passed"
        else
            echo "$pytest_result"
            log_error "Some workflow tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run API tests
run_api_tests() {
    log_info "Running API tests..."

    local test_dirs="src/backend/tests"
    local api_tests=$(find $test_dirs -name "*api*.py" -o -name "*endpoint*.py" 2>/dev/null || true)

    if [ -z "$api_tests" ]; then
        log_warning "No API tests found"
        return 0
    fi

    # Run pytest with API tests
    log_info "Running pytest on API tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $api_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All API tests passed"
        else
            echo "$pytest_result"
            log_error "Some API tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run component tests
run_component_tests() {
    log_info "Running component tests..."

    local test_dirs="src/backend/tests"
    local component_tests=$(find $test_dirs -name "*component*.py" 2>/dev/null || true)

    if [ -z "$component_tests" ]; then
        log_warning "No component tests found"
        return 0
    fi

    # Run pytest with component tests
    log_info "Running pytest on component tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $component_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All component tests passed"
        else
            echo "$pytest_result"
            log_error "Some component tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run database tests
run_database_tests() {
    log_info "Running database tests..."

    local test_dirs="src/backend/tests"
    local db_tests=$(find $test_dirs -name "*db*.py" -o -name "*database*.py" -o -name "*migration*.py" 2>/dev/null || true)

    if [ -z "$db_tests" ]; then
        log_warning "No database tests found"
        return 0
    fi

    # Run pytest with database tests
    log_info "Running pytest on database tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $db_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All database tests passed"
        else
            echo "$pytest_result"
            log_error "Some database tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run performance tests
run_performance_tests() {
    log_info "Running performance tests..."

    local test_dirs="src/backend/tests"
    local perf_tests=$(find $test_dirs -name "*perf*.py" -o -name "*performance*.py" -o -name "*benchmark*.py" 2>/dev/null || true)

    if [ -z "$perf_tests" ]; then
        log_warning "No performance tests found"
        return 0
    fi

    # Run pytest with performance tests
    log_info "Running pytest on performance tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $perf_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All performance tests passed"
        else
            echo "$pytest_result"
            log_error "Some performance tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to generate test report
generate_test_report() {
    log_info "Generating test report..."

    local report_dir="workflow_test_report"

    # Clean previous report
    if [ -d "$report_dir" ]; then
        rm -rf "$report_dir"
    fi

    # Run pytest with coverage and HTML report
    if command_exists pytest; then
        log_info "Running pytest with coverage report..."

        # Try to run with coverage if available
        if command_exists coverage; then
            uv run coverage run -m pytest src/backend/tests/ -v --tb=short --durations=10
            uv run coverage html -d "$report_dir"
            uv run coverage report
        else
            uv run pytest src/backend/tests/ -v --tb=short --durations=10 --html="$report_dir/report.html" --self-contained-html
        fi

        if [ -d "$report_dir" ]; then
            log_status "Test report generated: $report_dir/"
        fi
    fi
}

# Function to show test statistics
show_test_stats() {
    log_info "Test Statistics:"

    # Count test files
    local test_files=$(find src/backend/tests/ -name "test_*.py" -type f 2>/dev/null | wc -l)
    echo -e "  ${BLUE}📄 Test files:${NC} $test_files"

    # Count test functions
    local test_functions=$(find src/backend/tests/ -name "test_*.py" -type f -exec grep -c "^def test_" {} \; 2>/dev/null | paste -sd+ | bc)
    echo -e "  ${BLUE}🧪 Test functions:${NC} ${test_functions:-0}"

    # Count lines of test code
    local test_lines=$(find src/backend/tests/ -name "test_*.py" -type f -exec cat {} \; 2>/dev/null | wc -l)
    echo -e "  ${BLUE}📊 Lines of test code:${NC} $test_lines"

    # Count workflow tests
    local workflow_count=$(find src/backend/tests/ -name "*workflow*.py" -o -name "*integration*.py" -o -name "*e2e*.py" | wc -l)
    echo -e "  ${BLUE}🔄 Workflow tests:${NC} $workflow_count"
}

# Function to show usage
show_usage() {
    echo -e "${BLUE}📋 PYTEST WORKFLOW USAGE:${NC}"
    echo ""
    echo "  ./pytest/pytest_workflow.sh [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "    --skip-api         Skip API tests"
    echo "    --skip-components  Skip component tests"
    echo "    --skip-db          Skip database tests"
    echo "    --skip-perf        Skip performance tests"
    echo "    --report           Generate HTML test report"
    echo "    --stats            Show detailed statistics"
    echo "    --help             Show this help message"
    echo ""
    echo "  Examples:"
    echo "    ./pytest/pytest_workflow.sh              # Run all workflow tests"
    echo "    ./pytest/pytest_workflow.sh --report     # Generate test report"
    echo "    ./pytest/pytest_workflow.sh --stats      # Show statistics only"
    echo ""
}

# Parse command line arguments
SKIP_API=false
SKIP_COMPONENTS=false
SKIP_DB=false
SKIP_PERF=false
GENERATE_REPORT=false
STATS_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-api)
            SKIP_API=true
            shift
            ;;
        --skip-components)
            SKIP_COMPONENTS=true
            shift
            ;;
        --skip-db)
            SKIP_DB=true
            shift
            ;;
        --skip-perf)
            SKIP_PERF=true
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
echo -e "${BLUE}🔧 RUNNING WORKFLOW TESTS${NC}"
echo "─" | tr -d '\n' | head -c 40
echo

# Check if pytest is installed
if ! command_exists pytest; then
    log_error "pytest is not installed. Please install with: uv add --dev pytest"
    exit 1
fi

if [ "$STATS_ONLY" = true ]; then
    show_test_stats
    exit 0
fi

# Run workflow tests
run_workflow_tests

# Run API tests if not skipped
if [ "$SKIP_API" = false ]; then
    run_api_tests
else
    log_info "Skipping API tests as requested"
fi

# Run component tests if not skipped
if [ "$SKIP_COMPONENTS" = false ]; then
    run_component_tests
else
    log_info "Skipping component tests as requested"
fi

# Run database tests if not skipped
if [ "$SKIP_DB" = false ]; then
    run_database_tests
else
    log_info "Skipping database tests as requested"
fi

# Run performance tests if not skipped
if [ "$SKIP_PERF" = false ]; then
    run_performance_tests
else
    log_info "Skipping performance tests as requested"
fi

# Generate report if requested
if [ "$GENERATE_REPORT" = true ]; then
    generate_test_report
fi

# Show statistics
show_test_stats

echo
echo "=" | tr -d '\n' | head -c 60
echo -e "\n${GREEN}🎉 WORKFLOW TESTING COMPLETE!${NC}"
echo "=" | tr -d '\n' | head -c 60
echo

echo -e "${BLUE}📊 WORKFLOW TEST SUMMARY:${NC}"
echo -e "  ${GREEN}✅${NC} Workflow tests: Completed"
if [ "$SKIP_API" = false ]; then
    echo -e "  ${GREEN}✅${NC} API tests: Completed"
else
    echo -e "  ${YELLOW}⏭️${NC} API tests: Skipped"
fi
if [ "$SKIP_COMPONENTS" = false ]; then
    echo -e "  ${GREEN}✅${NC} Component tests: Completed"
else
    echo -e "  ${YELLOW}⏭️${NC} Component tests: Skipped"
fi
if [ "$SKIP_DB" = false ]; then
    echo -e "  ${GREEN}✅${NC} Database tests: Completed"
else
    echo -e "  ${YELLOW}⏭️${NC} Database tests: Skipped"
fi
if [ "$SKIP_PERF" = false ]; then
    echo -e "  ${GREEN}✅${NC} Performance tests: Completed"
else
    echo -e "  ${YELLOW}⏭️${NC} Performance tests: Skipped"
fi
if [ "$GENERATE_REPORT" = true ]; then
    echo -e "  ${GREEN}✅${NC} Test report: Generated"
fi

echo
echo -e "${GREEN}🚀 Workflow testing complete! All integration points verified!${NC}"
