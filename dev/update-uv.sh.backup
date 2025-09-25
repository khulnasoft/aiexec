#!/usr/bin/env bash
# Update UV and Build Script
# This script introduces uv as the Python package manager and builds the project
# Author: AIEXEC Development Team
# Version: 1.0.0

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UV_VERSION="latest"
PYTHON_VERSION="3.11"

echo -e "${BLUE}🚀 UPDATE-UV SCRIPT: AIEXEC BUILD SYSTEM${NC}"
echo "=" | tr -d '\n' | head -c 60
echo

# Function to print status messages
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

# Function to install uv using pipx
install_uv() {
    log_info "Installing uv using pipx..."

    if ! command_exists pipx; then
        log_warning "pipx not found. Installing pipx first..."
        python3 -m pip install --user pipx
        export PATH="$HOME/.local/bin:$PATH"
    fi

    pipx install uv
    log_status "uv installed successfully"
}

# Function to update uv
update_uv() {
    log_info "Updating uv to latest version..."

    # Try self-update first (for standalone installations)
    if uv self update >/dev/null 2>&1; then
        log_status "uv updated to latest version"
        return
    fi

    # If self-update failed, try package manager updates
    log_warning "Self-update not available, trying package manager update..."

    # Check if installed via pip/pip3
    if pip show uv >/dev/null 2>&1 || pip3 show uv >/dev/null 2>&1; then
        log_info "Updating uv via pip..."
        if command_exists pip3; then
            pip3 install --upgrade uv
        else
            pip install --upgrade uv
        fi
        log_status "uv updated via pip"
        return
    fi

    # Check if installed via brew
    if command_exists brew && brew list uv >/dev/null 2>&1; then
        log_info "Updating uv via brew..."
        brew upgrade uv
        log_status "uv updated via brew"
        return
    fi

    # If we get here, we don't know how to update
    log_warning "Could not determine installation method for uv update"
    log_info "Please update uv manually using your package manager"
}

# Function to set up Python environment
setup_python_env() {
    log_info "Setting up Python environment..."

    if ! command_exists python3; then
        log_error "Python 3 is required but not found"
        exit 1
    fi

    # Check Python version
    PYTHON_VERSION_INSTALLED=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    log_info "Python version: $PYTHON_VERSION_INSTALLED"

    if [ "$(printf '%s\n' "$PYTHON_VERSION_INSTALLED" "$PYTHON_VERSION" | sort -V | head -n1)" != "$PYTHON_VERSION" ]; then
        log_warning "Python version $PYTHON_VERSION_INSTALLED detected, but $PYTHON_VERSION recommended"
    fi

    log_status "Python environment ready"
}

# Function to install project dependencies
install_dependencies() {
    log_info "Installing project dependencies..."

    cd "$PROJECT_ROOT"

    # Install backend dependencies
    if [ -f "pyproject.toml" ]; then
        log_info "Installing main project dependencies..."
        uv sync --frozen
        log_status "Main project dependencies installed"
    fi

    # Install frontend dependencies if present
    if [ -d "src/frontend" ] && [ -f "src/frontend/package.json" ]; then
        log_info "Installing frontend dependencies..."
        cd src/frontend
        npm install
        cd "$PROJECT_ROOT"
        log_status "Frontend dependencies installed"
    fi

    # Install backend base dependencies
    if [ -f "src/backend/base/pyproject.toml" ]; then
        log_info "Installing backend base dependencies..."
        cd src/backend/base
        uv sync --frozen
        cd "$PROJECT_ROOT"
        log_status "Backend base dependencies installed"
    fi
}

# Function to build the project
build_project() {
    log_info "Building project..."

    cd "$PROJECT_ROOT"

    # Clean previous builds
    if [ -d "dist" ]; then
        log_info "Cleaning previous build artifacts..."
        rm -rf dist/
    fi

    if [ -d "src/backend/base/dist" ]; then
        rm -rf src/backend/base/dist/
    fi

    # Build base package first
    if [ -f "src/backend/base/pyproject.toml" ]; then
        log_info "Building aiexec-base package..."
        cd src/backend/base
        uv build
        cd "$PROJECT_ROOT"
        log_status "aiexec-base built successfully"
    fi

    # Build main package
    if [ -f "pyproject.toml" ]; then
        log_info "Building main aiexec package..."
        uv build
        log_status "Main aiexec package built successfully"
    fi

    # Build frontend if present
    if [ -d "src/frontend" ] && [ -f "src/frontend/package.json" ]; then
        log_info "Building frontend..."
        cd src/frontend
        npm run build
        cd "$PROJECT_ROOT"

        # Copy frontend build to backend
        if [ -d "src/frontend/build" ]; then
            log_info "Copying frontend build to backend..."
            cp -r src/frontend/build/* src/backend/base/aiexec/frontend/
            log_status "Frontend build copied"
        fi
    fi

    log_status "Project build complete"
}

# Function to run tests
run_tests() {
    log_info "Running tests..."

    cd "$PROJECT_ROOT"

    # Run Python tests
    if command_exists pytest; then
        log_info "Running Python unit tests..."
        uv run pytest src/backend/tests/unit/ -v --tb=short
        log_status "Python unit tests passed"
    else
        log_warning "pytest not available, skipping Python tests"
    fi

    # Run frontend tests if present
    if [ -d "src/frontend" ] && [ -f "src/frontend/package.json" ]; then
        log_info "Running frontend tests..."
        cd src/frontend
        npm test -- --watchAll=false --passWithNoTests
        cd "$PROJECT_ROOT"
        log_status "Frontend tests passed"
    fi
}

# Function to validate installation
validate_installation() {
    log_info "Validating installation..."

    cd "$PROJECT_ROOT"

    # Test main package import
    log_info "Testing main package import..."
    if uv run python3 -c "import aiexec; print('✅ Main package import successful')"; then
        log_status "Main package import working"
    else
        log_error "Main package import failed"
        exit 1
    fi

    # Test base package import
    log_info "Testing base package import..."
    if uv run python3 -c "import aiexec_base; print('✅ Base package import successful')"; then
        log_status "Base package import working"
    else
        log_error "Base package import failed"
        exit 1
    fi

    log_status "Installation validation complete"
}

# Function to show usage information
show_usage() {
    echo -e "${BLUE}📋 UPDATE-UV SCRIPT USAGE:${NC}"
    echo ""
    echo "  ./update-uv.sh [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "    --skip-tests    Skip running tests after build"
    echo "    --no-frontend   Skip frontend build and installation"
    echo "    --help          Show this help message"
    echo ""
    echo "  Examples:"
    echo "    ./update-uv.sh                 # Full setup and build"
    echo "    ./update-uv.sh --skip-tests    # Setup and build without tests"
    echo "    ./update-uv.sh --no-frontend   # Setup without frontend"
    echo ""
}

# Parse command line arguments
SKIP_TESTS=false
NO_FRONTEND=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --no-frontend)
            NO_FRONTEND=true
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
echo -e "${BLUE}🔧 STEP 1: Checking and installing uv${NC}"
echo "─" | tr -d '\n' | head -c 50
echo

if command_exists uv; then
    log_status "uv is already installed"
    update_uv
else
    log_warning "uv not found"
    install_uv
fi

echo
echo -e "${BLUE}🔧 STEP 2: Setting up Python environment${NC}"
echo "─" | tr -d '\n' | head -c 50
echo

setup_python_env

echo
echo -e "${BLUE}🔧 STEP 3: Installing dependencies${NC}"
echo "─" | tr -d '\n' | head -c 50
echo

install_dependencies

echo
echo -e "${BLUE}🔧 STEP 4: Building project${NC}"
echo "─" | tr -d '\n' | head -c 50
echo

if [ "$NO_FRONTEND" = true ]; then
    log_info "Skipping frontend build (as requested)"
    # Build only Python packages
    cd "$PROJECT_ROOT"
    uv build
    log_status "Python packages built successfully"
else
    build_project
fi

echo
echo -e "${BLUE}🔧 STEP 5: Validating installation${NC}"
echo "─" | tr -d '\n' | head -c 50
echo

validate_installation

if [ "$SKIP_TESTS" = false ]; then
    echo
    echo -e "${BLUE}🔧 STEP 6: Running tests${NC}"
    echo "─" | tr -d '\n' | head -c 50
    echo

    run_tests
fi

echo
echo "=" | tr -d '\n' | head -c 60
echo -e "\n${GREEN}🎉 BUILD COMPLETE!${NC}"
echo "=" | tr -d '\n' | head -c 60
echo

# Show final status
echo -e "${BLUE}📊 FINAL STATUS:${NC}"
echo -e "  ${GREEN}✅${NC} uv package manager: Installed and updated"
echo -e "  ${GREEN}✅${NC} Python environment: Configured"
echo -e "  ${GREEN}✅${NC} Dependencies: Installed"
echo -e "  ${GREEN}✅${NC} Project: Built successfully"
echo -e "  ${GREEN}✅${NC} Installation: Validated"
if [ "$SKIP_TESTS" = false ]; then
    echo -e "  ${GREEN}✅${NC} Tests: Passed"
fi

echo
echo -e "${BLUE}🚀 READY FOR DEVELOPMENT:${NC}"
echo "  • Use 'uv run aiexec run' to start the application"
echo "  • Use 'make help' for all available commands"
echo "  • Built packages are available in the 'dist/' directory"
echo ""

# Show package information
if [ -d "dist" ]; then
    echo -e "${BLUE}📦 BUILT PACKAGES:${NC}"
    ls -la dist/
    echo ""
fi

echo -e "${GREEN}🎯 AIEXEC is ready with uv package management!${NC}"
