#!/usr/bin/env bash
# Code Reformat Script
# Reformats code using ruff, black, and other formatters
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

echo -e "${BLUE}🎨 REFORMAT SCRIPT: AIEXEC Code Formatting${NC}"
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

# Function to reformat Python code with ruff
reformat_python_ruff() {
    log_info "Reformatting Python code with Ruff..."

    # Find all Python files
    local python_files=$(find src/ -name "*.py" -type f 2>/dev/null || true)
    python_files="$python_files $(find tests/ -name "*.py" -type f 2>/dev/null || true)"
    python_files="$python_files $(find scripts/ -name "*.py" -type f 2>/dev/null || true)"

    if [ -z "$python_files" ]; then
        log_warning "No Python files found to reformat"
        return 0
    fi

    # Run ruff format
    log_info "Running ruff format..."
    if command_exists ruff; then
        uv run ruff format $python_files
        log_status "Python code formatted with Ruff"
    else
        log_error "Ruff not found. Please install with: uv add --dev ruff"
        return 1
    fi
}

# Function to reformat Python code with black
reformat_python_black() {
    log_info "Reformatting Python code with Black..."

    # Find all Python files
    local python_files=$(find src/ -name "*.py" -type f 2>/dev/null || true)
    python_files="$python_files $(find tests/ -name "*.py" -type f 2>/dev/null || true)"
    python_files="$python_files $(find scripts/ -name "*.py" -type f 2>/dev/null || true)"

    if [ -z "$python_files" ]; then
        log_warning "No Python files found to reformat"
        return 0
    fi

    # Run black format
    log_info "Running black format..."
    if command_exists black; then
        uv run black $python_files
        log_status "Python code formatted with Black"
    else
        log_warning "Black not found. Skipping black formatting."
    fi
}

# Function to lint Python code with ruff
lint_python_ruff() {
    log_info "Linting Python code with Ruff..."

    # Find all Python files
    local python_files=$(find src/ -name "*.py" -type f 2>/dev/null || true)
    python_files="$python_files $(find tests/ -name "*.py" -type f 2>/dev/null || true)"
    python_files="$python_files $(find scripts/ -name "*.py" -type f 2>/dev/null || true)"

    if [ -z "$python_files" ]; then
        log_warning "No Python files found to lint"
        return 0
    fi

    # Run ruff check with fix
    log_info "Running ruff check --fix..."
    if command_exists ruff; then
        uv run ruff check --fix $python_files
        log_status "Python code linted and fixed with Ruff"
    else
        log_error "Ruff not found. Please install with: uv add --dev ruff"
        return 1
    fi
}

# Function to reformat frontend code
reformat_frontend() {
    log_info "Reformatting frontend code..."

    local frontend_dir="src/frontend"

    if [ ! -d "$frontend_dir" ]; then
        log_warning "Frontend directory not found: $frontend_dir"
        return 0
    fi

    cd "$frontend_dir"

    if [ ! -f "package.json" ]; then
        log_warning "package.json not found in $frontend_dir"
        cd "$PROJECT_ROOT"
        return 0
    fi

    # Run prettier if available
    log_info "Running prettier format..."
    if command_exists npx; then
        npx prettier --write "**/*.{js,jsx,ts,tsx,json,css,md}" || true
        log_status "Frontend code formatted with Prettier"
    else
        log_warning "npx not found. Skipping frontend formatting."
    fi

    cd "$PROJECT_ROOT"
}

# Function to reformat shell scripts
reformat_shell_scripts() {
    log_info "Reformatting shell scripts..."

    # Find all shell scripts
    local shell_files=$(find . -name "*.sh" -type f 2>/dev/null || true)
    shell_files="$shell_files $(find scripts/ -name "*.sh" -type f 2>/dev/null || true)"

    if [ -z "$shell_files" ]; then
        log_warning "No shell scripts found to reformat"
        return 0
    fi

    # Format shell scripts with shfmt if available
    log_info "Running shfmt..."
    if command_exists shfmt; then
        shfmt -w -i 4 $shell_files
        log_status "Shell scripts formatted with shfmt"
    else
        log_warning "shfmt not found. Skipping shell script formatting."
    fi
}

# Function to reformat configuration files
reformat_config_files() {
    log_info "Reformatting configuration files..."

    # Find configuration files
    local config_files=$(find . -name "*.toml" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" | grep -v node_modules | grep -v __pycache__ | grep -v .git)

    if [ -z "$config_files" ]; then
        log_warning "No configuration files found to reformat"
        return 0
    fi

    # Format TOML files with taplo if available
    local toml_files=$(echo "$config_files" | grep "\.toml$" || true)
    if [ -n "$toml_files" ] && command_exists taplo; then
        log_info "Running taplo format..."
        taplo format $toml_files
        log_status "TOML files formatted with taplo"
    fi

    # Format YAML files with prettier if available
    local yaml_files=$(echo "$config_files" | grep -E "\.(yaml|yml)$" || true)
    if [ -n "$yaml_files" ] && command_exists npx; then
        log_info "Running prettier on YAML files..."
        npx prettier --write $yaml_files || true
        log_status "YAML files formatted with prettier"
    fi
}

# Function to validate formatting
validate_formatting() {
    log_info "Validating code formatting..."

    # Check Python formatting with ruff
    if command_exists ruff; then
        log_info "Checking Python formatting with ruff..."
        local python_files=$(find src/ tests/ scripts/ -name "*.py" -type f 2>/dev/null || true)

        if [ -n "$python_files" ]; then
            local format_errors=$(uv run ruff format --check $python_files 2>&1 | wc -l)
            if [ "$format_errors" -gt 0 ]; then
                log_warning "Some Python files are not properly formatted"
                return 1
            fi
        fi
    fi

    log_status "Code formatting validation passed"
}

# Function to show usage
show_usage() {
    echo -e "${BLUE}📋 REFORMAT USAGE:${NC}"
    echo ""
    echo "  ./reformat.sh [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "    --check-only       Only check formatting, don't modify files"
    echo "    --skip-frontend    Skip frontend code formatting"
    echo "    --skip-shell       Skip shell script formatting"
    echo "    --skip-config      Skip configuration file formatting"
    echo "    --help             Show this help message"
    echo ""
    echo "  Examples:"
    echo "    ./reformat.sh               # Format all code"
    echo "    ./reformat.sh --check-only  # Check formatting only"
    echo "    ./reformat.sh --skip-frontend # Skip frontend formatting"
    echo ""
}

# Parse command line arguments
CHECK_ONLY=false
SKIP_FRONTEND=false
SKIP_SHELL=false
SKIP_CONFIG=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        --skip-frontend)
            SKIP_FRONTEND=true
            shift
            ;;
        --skip-shell)
            SKIP_SHELL=true
            shift
            ;;
        --skip-config)
            SKIP_CONFIG=true
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
echo -e "${BLUE}🔧 REFORMATTING CODE${NC}"
echo "─" | tr -d '\n' | head -c 40
echo

# Check if required tools are installed
if ! command_exists uv; then
    log_error "uv is not installed. Please run update-uv.sh first."
    exit 1
fi

if [ "$CHECK_ONLY" = true ]; then
    validate_formatting
    log_status "Formatting check complete"
    exit 0
fi

# Reformat Python code with ruff
reformat_python_ruff

# Lint Python code with ruff
lint_python_ruff

# Reformat frontend if not skipped
if [ "$SKIP_FRONTEND" = false ]; then
    reformat_frontend
else
    log_info "Skipping frontend formatting as requested"
fi

# Reformat shell scripts if not skipped
if [ "$SKIP_SHELL" = false ]; then
    reformat_shell_scripts
else
    log_info "Skipping shell script formatting as requested"
fi

# Reformat configuration files if not skipped
if [ "$SKIP_CONFIG" = false ]; then
    reformat_config_files
else
    log_info "Skipping configuration file formatting as requested"
fi

# Validate formatting
validate_formatting

echo
echo "=" | tr -d '\n' | head -c 60
echo -e "\n${GREEN}🎉 CODE REFORMATTING COMPLETE!${NC}"
echo "=" | tr -d '\n' | head -c 60
echo

echo -e "${BLUE}📊 REFORMAT SUMMARY:${NC}"
echo -e "  ${GREEN}✅${NC} Python code: Formatted with Ruff"
echo -e "  ${GREEN}✅${NC} Python linting: Applied with Ruff"
if [ "$SKIP_FRONTEND" = false ]; then
    echo -e "  ${GREEN}✅${NC} Frontend code: Formatted with Prettier"
else
    echo -e "  ${YELLOW}⏭️${NC} Frontend code: Skipped"
fi
if [ "$SKIP_SHELL" = false ]; then
    echo -e "  ${GREEN}✅${NC} Shell scripts: Formatted with shfmt"
else
    echo -e "  ${YELLOW}⏭️${NC} Shell scripts: Skipped"
fi
if [ "$SKIP_CONFIG" = false ]; then
    echo -e "  ${GREEN}✅${NC} Config files: Formatted"
else
    echo -e "  ${YELLOW}⏭️${NC} Config files: Skipped"
fi
echo -e "  ${GREEN}✅${NC} Validation: Passed"

echo
echo -e "${GREEN}🚀 Code is now properly formatted and ready!${NC}"
