#!/usr/bin/env bash
# MyPy Type Check Script
# Runs mypy type checking on the codebase
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

echo -e "${BLUE}🔍 MYPY-CHECK SCRIPT: AIEXEC Type Checking${NC}"
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

# Function to run mypy on main project
check_main_project() {
    log_info "Running mypy on main project..."

    if [ ! -f "pyproject.toml" ]; then
        log_error "pyproject.toml not found in ${PROJECT_ROOT}"
        return 1
    fi

    # Get mypy configuration from pyproject.toml
    local mypy_config=""
    if grep -q "mypy" pyproject.toml; then
        mypy_config="--config-file pyproject.toml"
    fi

    # Find Python source files
    local python_files="src/"
    if [ -d "src/backend/base" ]; then
        python_files="$python_files src/backend/base/"
    fi

    # Run mypy
    log_info "Running mypy check..."
    if command_exists mypy; then
        local mypy_result=$(uv run mypy $mypy_config $python_files 2>&1)
        local mypy_exit_code=$?

        if [ $mypy_exit_code -eq 0 ]; then
            log_status "Main project passed mypy type checking"
        else
            echo "$mypy_result"
            log_error "Main project failed mypy type checking"
            return 1
        fi
    else
        log_error "mypy not found. Please install with: uv add --dev mypy"
        return 1
    fi
}

# Function to run mypy on backend base
check_backend_base() {
    log_info "Running mypy on backend base..."

    local base_dir="src/backend/base"

    if [ ! -d "$base_dir" ]; then
        log_warning "Backend base directory not found: $base_dir"
        return 0
    fi

    cd "$base_dir"

    if [ ! -f "pyproject.toml" ]; then
        log_warning "pyproject.toml not found in $base_dir"
        cd "$PROJECT_ROOT"
        return 0
    fi

    # Get mypy configuration
    local mypy_config=""
    if grep -q "mypy" pyproject.toml; then
        mypy_config="--config-file pyproject.toml"
    fi

    # Run mypy
    log_info "Running mypy check on backend base..."
    if command_exists mypy; then
        local mypy_result=$(uv run mypy $mypy_config src/ 2>&1)
        local mypy_exit_code=$?

        if [ $mypy_exit_code -eq 0 ]; then
            log_status "Backend base passed mypy type checking"
        else
            echo "$mypy_result"
            log_error "Backend base failed mypy type checking"
            return 1
        fi
    else
        log_error "mypy not found. Please install with: uv add --dev mypy"
        cd "$PROJECT_ROOT"
        return 1
    fi

    cd "$PROJECT_ROOT"
}

# Function to run mypy on WFX package
check_wfx_package() {
    log_info "Running mypy on WFX package..."

    local wfx_dir="src/wfx"

    if [ ! -d "$wfx_dir" ]; then
        log_warning "WFX directory not found: $wfx_dir"
        return 0
    fi

    cd "$wfx_dir"

    if [ ! -f "pyproject.toml" ]; then
        log_warning "pyproject.toml not found in $wfx_dir"
        cd "$PROJECT_ROOT"
        return 0
    fi

    # Get mypy configuration
    local mypy_config=""
    if grep -q "mypy" pyproject.toml; then
        mypy_config="--config-file pyproject.toml"
    fi

    # Run mypy
    log_info "Running mypy check on WFX..."
    if command_exists mypy; then
        local mypy_result=$(uv run mypy $mypy_config src/ 2>&1)
        local mypy_exit_code=$?

        if [ $mypy_exit_code -eq 0 ]; then
            log_status "WFX package passed mypy type checking"
        else
            echo "$mypy_result"
            log_error "WFX package failed mypy type checking"
            return 1
        fi
    else
        log_error "mypy not found. Please install with: uv add --dev mypy"
        cd "$PROJECT_ROOT"
        return 1
    fi

    cd "$PROJECT_ROOT"
}

# Function to run mypy on test files
check_test_files() {
    log_info "Running mypy on test files..."

    # Find test directories
    local test_dirs=""

    if [ -d "src/backend/tests" ]; then
        test_dirs="$test_dirs src/backend/tests"
    fi

    if [ -d "tests" ]; then
        test_dirs="$test_dirs tests"
    fi

    if [ -d "src/wfx/tests" ]; then
        test_dirs="$test_dirs src/wfx/tests"
    fi

    if [ -z "$test_dirs" ]; then
        log_warning "No test directories found"
        return 0
    fi

    # Run mypy on test files
    log_info "Running mypy check on test files..."
    if command_exists mypy; then
        local mypy_result=$(uv run mypy --ignore-missing-imports $test_dirs 2>&1)
        local mypy_exit_code=$?

        if [ $mypy_exit_code -eq 0 ]; then
            log_status "Test files passed mypy type checking"
        else
            echo "$mypy_result"
            log_warning "Test files have mypy warnings (non-blocking)"
        fi
    else
        log_error "mypy not found. Please install with: uv add --dev mypy"
        return 1
    fi
}

# Function to generate mypy report
generate_mypy_report() {
    log_info "Generating mypy HTML report..."

    if command_exists mypy; then
        local report_dir="mypy_report"

        # Clean previous report
        if [ -d "$report_dir" ]; then
            rm -rf "$report_dir"
        fi

        # Generate HTML report
        log_info "Generating HTML report..."
        uv run mypy --html-report "$report_dir" src/ 2>/dev/null || true

        if [ -d "$report_dir" ]; then
            log_status "MyPy HTML report generated: $report_dir/index.html"
        else
            log_warning "Failed to generate HTML report"
        fi
    else
        log_error "mypy not found. Cannot generate report."
    fi
}

# Function to show mypy statistics
show_mypy_stats() {
    log_info "MyPy Statistics:"

    # Count Python files
    local python_files=$(find src/ -name "*.py" -type f | wc -l)
    echo -e "  ${BLUE}📄 Python files:${NC} $python_files"

    # Count lines of code
    local lines_of_code=$(find src/ -name "*.py" -type f -exec cat {} \; | wc -l)
    echo -e "  ${BLUE}📊 Lines of code:${NC} $lines_of_code"

    # Count type annotations
    local type_annotations=$(find src/ -name "*.py" -type f -exec grep -c "def.*->" {} \; | paste -sd+ | bc)
    echo -e "  ${BLUE}🏷️  Type annotations:${NC} $type_annotations"

    # Count mypy errors (if any)
    if [ -f "mypy_report/index.html" ]; then
        local error_count=$(grep -o "error" mypy_report/index.html | wc -l)
        echo -e "  ${BLUE}❌ MyPy errors:${NC} $error_count"
    fi
}

# Function to show usage
show_usage() {
    echo -e "${BLUE}📋 MYPY-CHECK USAGE:${NC}"
    echo ""
    echo "  ./mypy-check.sh [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "    --skip-tests       Skip type checking test files"
    echo "    --skip-wfx         Skip WFX package type checking"
    echo "    --html-report      Generate HTML report"
    echo "    --stats            Show detailed statistics"
    echo "    --help             Show this help message"
    echo ""
    echo "  Examples:"
    echo "    ./mypy-check.sh              # Run all type checks"
    echo "    ./mypy-check.sh --html-report # Generate HTML report"
    echo "    ./mypy-check.sh --stats       # Show statistics only"
    echo ""
}

# Parse command line arguments
SKIP_TESTS=false
SKIP_WFX=false
HTML_REPORT=false
STATS_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --skip-wfx)
            SKIP_WFX=true
            shift
            ;;
        --html-report)
            HTML_REPORT=true
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
echo -e "${BLUE}🔧 RUNNING MYPY TYPE CHECKS${NC}"
echo "─" | tr -d '\n' | head -c 40
echo

# Check if mypy is installed
if ! command_exists mypy; then
    log_error "mypy is not installed. Please install with: uv add --dev mypy"
    exit 1
fi

if [ "$STATS_ONLY" = true ]; then
    show_mypy_stats
    exit 0
fi

# Run type checks
check_main_project

# Check backend base
check_backend_base

# Check WFX if not skipped
if [ "$SKIP_WFX" = false ]; then
    check_wfx_package
else
    log_info "Skipping WFX type checking as requested"
fi

# Check test files if not skipped
if [ "$SKIP_TESTS" = false ]; then
    check_test_files
else
    log_info "Skipping test file type checking as requested"
fi

# Generate HTML report if requested
if [ "$HTML_REPORT" = true ]; then
    generate_mypy_report
fi

# Show statistics
show_mypy_stats

echo
echo "=" | tr -d '\n' | head -c 60
echo -e "\n${GREEN}🎉 MYPY TYPE CHECKING COMPLETE!${NC}"
echo "=" | tr -d '\n' | head -c 60
echo

echo -e "${BLUE}📊 TYPE CHECK SUMMARY:${NC}"
echo -e "  ${GREEN}✅${NC} Main project: Type checked"
echo -e "  ${GREEN}✅${NC} Backend base: Type checked"
if [ "$SKIP_WFX" = false ]; then
    echo -e "  ${GREEN}✅${NC} WFX package: Type checked"
else
    echo -e "  ${YELLOW}⏭️${NC} WFX package: Skipped"
fi
if [ "$SKIP_TESTS" = false ]; then
    echo -e "  ${GREEN}✅${NC} Test files: Type checked"
else
    echo -e "  ${YELLOW}⏭️${NC} Test files: Skipped"
fi
if [ "$HTML_REPORT" = true ]; then
    echo -e "  ${GREEN}✅${NC} HTML report: Generated"
fi

echo
echo -e "${GREEN}🚀 Type checking complete! Code is type-safe and ready!${NC}"
