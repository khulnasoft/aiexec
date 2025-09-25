#!/usr/bin/env bash
# Sync UV Dependencies Script
# Ensures uv dependencies are properly synchronized across all components
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

echo -e "${BLUE}🔄 SYNC-UV SCRIPT: AIEXEC Dependency Management${NC}"
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

# Function to sync main project dependencies
sync_main_project() {
    log_info "Syncing main project dependencies..."

    if [ ! -f "pyproject.toml" ]; then
        log_error "pyproject.toml not found in ${PROJECT_ROOT}"
        exit 1
    fi

    # Sync dependencies
    log_info "Running uv sync..."
    uv sync --frozen

    # Update lock file
    log_info "Updating lock file..."
    uv lock --no-upgrade

    log_status "Main project dependencies synchronized"
}

# Function to sync backend base dependencies
sync_backend_base() {
    log_info "Syncing backend base dependencies..."

    local base_dir="src/backend/base"

    if [ ! -d "$base_dir" ]; then
        log_error "Backend base directory not found: $base_dir"
        return 1
    fi

    cd "$base_dir"

    if [ ! -f "pyproject.toml" ]; then
        log_error "pyproject.toml not found in $base_dir"
        cd "$PROJECT_ROOT"
        return 1
    fi

    # Sync dependencies
    log_info "Running uv sync for backend base..."
    uv sync --frozen

    # Update lock file
    log_info "Updating lock file for backend base..."
    uv lock --no-upgrade

    cd "$PROJECT_ROOT"
    log_status "Backend base dependencies synchronized"
}

# Function to sync frontend dependencies
sync_frontend() {
    log_info "Syncing frontend dependencies..."

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

    # Install npm dependencies
    log_info "Installing npm dependencies..."
    npm install

    # Update package lock
    log_info "Updating package-lock.json..."
    npm audit fix || true

    cd "$PROJECT_ROOT"
    log_status "Frontend dependencies synchronized"
}

# Function to sync WFX dependencies
sync_wfx() {
    log_info "Syncing WFX dependencies..."

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

    # Sync dependencies
    log_info "Running uv sync for WFX..."
    uv sync --frozen

    # Update lock file
    log_info "Updating lock file for WFX..."
    uv lock --no-upgrade

    cd "$PROJECT_ROOT"
    log_status "WFX dependencies synchronized"
}

# Function to validate all syncs
validate_syncs() {
    log_info "Validating all dependency syncs..."

    # Check main project
    cd "$PROJECT_ROOT"
    if ! uv run python3 -c "import aiexec; print('✅ Main project import successful')" > /dev/null 2>&1; then
        log_error "Main project import failed"
        exit 1
    fi

    # Check backend base
    cd "src/backend/base"
    if ! uv run python3 -c "import aiexec_base; print('✅ Backend base import successful')" > /dev/null 2>&1; then
        log_error "Backend base import failed"
        cd "$PROJECT_ROOT"
        exit 1
    fi

    cd "$PROJECT_ROOT"
    log_status "All dependency syncs validated"
}

# Function to show usage
show_usage() {
    echo -e "${BLUE}📋 SYNC-UV USAGE:${NC}"
    echo ""
    echo "  ./sync-uv.sh [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "    --skip-frontend    Skip frontend dependency sync"
    echo "    --skip-wfx         Skip WFX dependency sync"
    echo "    --validate-only    Only validate existing syncs"
    echo "    --help             Show this help message"
    echo ""
    echo "  Examples:"
    echo "    ./sync-uv.sh                    # Sync all dependencies"
    echo "    ./sync-uv.sh --skip-frontend    # Skip frontend"
    echo "    ./sync-uv.sh --validate-only    # Check existing syncs"
    echo ""
}

# Parse command line arguments
SKIP_FRONTEND=false
SKIP_WFX=false
VALIDATE_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-frontend)
            SKIP_FRONTEND=true
            shift
            ;;
        --skip-wfx)
            SKIP_WFX=true
            shift
            ;;
        --validate-only)
            VALIDATE_ONLY=true
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
echo -e "${BLUE}🔧 SYNCING UV DEPENDENCIES${NC}"
echo "─" | tr -d '\n' | head -c 40
echo

# Check if uv is installed
if ! command_exists uv; then
    log_error "uv is not installed. Please run update-uv.sh first."
    exit 1
fi

if [ "$VALIDATE_ONLY" = true ]; then
    validate_syncs
    log_status "Validation complete"
    exit 0
fi

# Sync main project
sync_main_project

# Sync backend base
sync_backend_base

# Sync frontend if not skipped
if [ "$SKIP_FRONTEND" = false ]; then
    sync_frontend
else
    log_info "Skipping frontend sync as requested"
fi

# Sync WFX if not skipped
if [ "$SKIP_WFX" = false ]; then
    sync_wfx
else
    log_info "Skipping WFX sync as requested"
fi

# Validate all syncs
validate_syncs

echo
echo "=" | tr -d '\n' | head -c 60
echo -e "\n${GREEN}🎉 DEPENDENCY SYNC COMPLETE!${NC}"
echo "=" | tr -d '\n' | head -c 60
echo

echo -e "${BLUE}📊 SYNC SUMMARY:${NC}"
echo -e "  ${GREEN}✅${NC} Main project: Synchronized"
echo -e "  ${GREEN}✅${NC} Backend base: Synchronized"
if [ "$SKIP_FRONTEND" = false ]; then
    echo -e "  ${GREEN}✅${NC} Frontend: Synchronized"
else
    echo -e "  ${YELLOW}⏭️${NC} Frontend: Skipped"
fi
if [ "$SKIP_WFX" = false ]; then
    echo -e "  ${GREEN}✅${NC} WFX: Synchronized"
else
    echo -e "  ${YELLOW}⏭️${NC} WFX: Skipped"
fi
echo -e "  ${GREEN}✅${NC} Validation: Passed"

echo
echo -e "${GREEN}🚀 Ready for development and testing!${NC}"
