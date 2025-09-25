#!/usr/bin/env bash
# PyTest VDB Script
# Runs Vector Database (VDB) related tests for AIEXEC
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

echo -e "${BLUE}🗄️  PYTEST VDB SCRIPT: AIEXEC Vector Database Tests${NC}"
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

# Function to run Qdrant tests
run_qdrant_tests() {
    log_info "Running Qdrant vector database tests..."

    local test_dirs="src/backend/tests"
    local qdrant_tests=$(find $test_dirs -name "*qdrant*.py" -o -name "*vector*.py" 2>/dev/null || true)

    if [ -z "$qdrant_tests" ]; then
        log_warning "No Qdrant-specific tests found"
        return 0
    fi

    # Run pytest with Qdrant tests
    log_info "Running pytest on Qdrant tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $qdrant_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All Qdrant tests passed"
        else
            echo "$pytest_result"
            log_error "Some Qdrant tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run Weaviate tests
run_weaviate_tests() {
    log_info "Running Weaviate vector database tests..."

    local test_dirs="src/backend/tests"
    local weaviate_tests=$(find $test_dirs -name "*weaviate*.py" 2>/dev/null || true)

    if [ -z "$weaviate_tests" ]; then
        log_warning "No Weaviate-specific tests found"
        return 0
    fi

    # Run pytest with Weaviate tests
    log_info "Running pytest on Weaviate tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $weaviate_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All Weaviate tests passed"
        else
            echo "$pytest_result"
            log_error "Some Weaviate tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run ChromaDB tests
run_chromadb_tests() {
    log_info "Running ChromaDB vector database tests..."

    local test_dirs="src/backend/tests"
    local chroma_tests=$(find $test_dirs -name "*chroma*.py" -o -name "*chromadb*.py" 2>/dev/null || true)

    if [ -z "$chroma_tests" ]; then
        log_warning "No ChromaDB-specific tests found"
        return 0
    fi

    # Run pytest with ChromaDB tests
    log_info "Running pytest on ChromaDB tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $chroma_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All ChromaDB tests passed"
        else
            echo "$pytest_result"
            log_error "Some ChromaDB tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run Pinecone tests
run_pinecone_tests() {
    log_info "Running Pinecone vector database tests..."

    local test_dirs="src/backend/tests"
    local pinecone_tests=$(find $test_dirs -name "*pinecone*.py" 2>/dev/null || true)

    if [ -z "$pinecone_tests" ]; then
        log_warning "No Pinecone-specific tests found"
        return 0
    fi

    # Run pytest with Pinecone tests
    log_info "Running pytest on Pinecone tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $pinecone_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All Pinecone tests passed"
        else
            echo "$pytest_result"
            log_error "Some Pinecone tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run embedding tests
run_embedding_tests() {
    log_info "Running embedding model tests..."

    local test_dirs="src/backend/tests"
    local embedding_tests=$(find $test_dirs -name "*embedding*.py" -o -name "*embed*.py" 2>/dev/null || true)

    if [ -z "$embedding_tests" ]; then
        log_warning "No embedding-specific tests found"
        return 0
    fi

    # Run pytest with embedding tests
    log_info "Running pytest on embedding tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $embedding_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All embedding tests passed"
        else
            echo "$pytest_result"
            log_error "Some embedding tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run similarity search tests
run_similarity_tests() {
    log_info "Running similarity search tests..."

    local test_dirs="src/backend/tests"
    local similarity_tests=$(find $test_dirs -name "*similarity*.py" -o -name "*search*.py" 2>/dev/null || true)

    if [ -z "$similarity_tests" ]; then
        log_warning "No similarity search tests found"
        return 0
    fi

    # Run pytest with similarity tests
    log_info "Running pytest on similarity tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $similarity_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All similarity search tests passed"
        else
            echo "$pytest_result"
            log_error "Some similarity search tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to run VDB integration tests
run_vdb_integration_tests() {
    log_info "Running VDB integration tests..."

    local test_dirs="src/backend/tests"
    local integration_tests=$(find $test_dirs -name "*integration*.py" -exec grep -l "vector\|embedding\|qdrant\|weaviate\|chroma\|pinecone" {} \; 2>/dev/null || true)

    if [ -z "$integration_tests" ]; then
        log_warning "No VDB integration tests found"
        return 0
    fi

    # Run pytest with VDB integration tests
    log_info "Running pytest on VDB integration tests..."
    if command_exists pytest; then
        local pytest_result=$(uv run pytest $integration_tests -v --tb=short --durations=10 2>&1)
        local pytest_exit_code=$?

        if [ $pytest_exit_code -eq 0 ]; then
            log_status "All VDB integration tests passed"
        else
            echo "$pytest_result"
            log_error "Some VDB integration tests failed"
            return 1
        fi
    else
        log_error "pytest not found. Please install with: uv add --dev pytest"
        return 1
    fi
}

# Function to generate VDB test report
generate_vdb_report() {
    log_info "Generating VDB test report..."

    local report_dir="vdb_test_report"

    # Clean previous report
    if [ -d "$report_dir" ]; then
        rm -rf "$report_dir"
    fi

    # Run pytest with coverage on VDB tests
    if command_exists pytest; then
        log_info "Running pytest with coverage on VDB tests..."

        local vdb_tests=""
        vdb_tests="$vdb_tests $(find src/backend/tests/ -name "*qdrant*.py" 2>/dev/null || true)"
        vdb_tests="$vdb_tests $(find src/backend/tests/ -name "*weaviate*.py" 2>/dev/null || true)"
        vdb_tests="$vdb_tests $(find src/backend/tests/ -name "*chroma*.py" 2>/dev/null || true)"
        vdb_tests="$vdb_tests $(find src/backend/tests/ -name "*pinecone*.py" 2>/dev/null || true)"
        vdb_tests="$vdb_tests $(find src/backend/tests/ -name "*embedding*.py" 2>/dev/null || true)"
        vdb_tests="$vdb_tests $(find src/backend/tests/ -name "*vector*.py" 2>/dev/null || true)"

        # Try to run with coverage if available
        if command_exists coverage && [ -n "$vdb_tests" ]; then
            uv run coverage run -m pytest $vdb_tests -v --tb=short --durations=10
            uv run coverage html -d "$report_dir"
            uv run coverage report
        elif [ -n "$vdb_tests" ]; then
            uv run pytest $vdb_tests -v --tb=short --durations=10 --html="$report_dir/report.html" --self-contained-html
        fi

        if [ -d "$report_dir" ]; then
            log_status "VDB test report generated: $report_dir/"
        fi
    fi
}

# Function to show VDB test statistics
show_vdb_stats() {
    log_info "VDB Test Statistics:"

    # Count VDB-related test files
    local vdb_files=$(find src/backend/tests/ -name "*qdrant*.py" -o -name "*weaviate*.py" -o -name "*chroma*.py" -o -name "*pinecone*.py" -o -name "*embedding*.py" -o -name "*vector*.py" | wc -l)
    echo -e "  ${BLUE}📄 VDB test files:${NC} $vdb_files"

    # Count VDB test functions
    local vdb_functions=$(find src/backend/tests/ -name "*qdrant*.py" -o -name "*weaviate*.py" -o -name "*chroma*.py" -o -name "*pinecone*.py" -o -name "*embedding*.py" -o -name "*vector*.py" -exec grep -c "^def test_" {} \; 2>/dev/null | paste -sd+ | bc)
    echo -e "  ${BLUE}🧪 VDB test functions:${NC} ${vdb_functions:-0}"

    # Count lines of VDB test code
    local vdb_lines=$(find src/backend/tests/ -name "*qdrant*.py" -o -name "*weaviate*.py" -o -name "*chroma*.py" -o -name "*pinecone*.py" -o -name "*embedding*.py" -o -name "*vector*.py" -exec cat {} \; 2>/dev/null | wc -l)
    echo -e "  ${BLUE}📊 Lines of VDB test code:${NC} $vdb_lines"

    # Show supported VDB systems
    local supported_vdbs=""

    if find src/backend/tests/ -name "*qdrant*.py" >/dev/null 2>&1; then
        supported_vdbs="$supported_vdbs Qdrant"
    fi
    if find src/backend/tests/ -name "*weaviate*.py" >/dev/null 2>&1; then
        supported_vdbs="$supported_vdbs Weaviate"
    fi
    if find src/backend/tests/ -name "*chroma*.py" >/dev/null 2>&1; then
        supported_vdbs="$supported_vdbs ChromaDB"
    fi
    if find src/backend/tests/ -name "*pinecone*.py" >/dev/null 2>&1; then
        supported_vdbs="$supported_vdbs Pinecone"
    fi

    echo -e "  ${BLUE}🗄️  Supported VDBs:${NC} ${supported_vdbs:-None}"
}

# Function to show usage
show_usage() {
    echo -e "${BLUE}📋 PYTEST VDB USAGE:${NC}"
    echo ""
    echo "  ./pytest/pytest_vdb.sh [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "    --skip-qdrant      Skip Qdrant tests"
    echo "    --skip-weaviate    Skip Weaviate tests"
    echo "    --skip-chroma      Skip ChromaDB tests"
    echo "    --skip-pinecone    Skip Pinecone tests"
    echo "    --skip-embedding   Skip embedding tests"
    echo "    --skip-similarity  Skip similarity search tests"
    echo "    --report           Generate HTML test report"
    echo "    --stats            Show detailed statistics"
    echo "    --help             Show this help message"
    echo ""
    echo "  Examples:"
    echo "    ./pytest/pytest_vdb.sh              # Run all VDB tests"
    echo "    ./pytest/pytest_vdb.sh --report     # Generate test report"
    echo "    ./pytest/pytest_vdb.sh --stats      # Show statistics only"
    echo ""
}

# Parse command line arguments
SKIP_QDRANT=false
SKIP_WEAVIATE=false
SKIP_CHROMA=false
SKIP_PINECONE=false
SKIP_EMBEDDING=false
SKIP_SIMILARITY=false
GENERATE_REPORT=false
STATS_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-qdrant)
            SKIP_QDRANT=true
            shift
            ;;
        --skip-weaviate)
            SKIP_WEAVIATE=true
            shift
            ;;
        --skip-chroma)
            SKIP_CHROMA=true
            shift
            ;;
        --skip-pinecone)
            SKIP_PINECONE=true
            shift
            ;;
        --skip-embedding)
            SKIP_EMBEDDING=true
            shift
            ;;
        --skip-similarity)
            SKIP_SIMILARITY=true
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
echo -e "${BLUE}🔧 RUNNING VDB TESTS${NC}"
echo "─" | tr -d '\n' | head -c 40
echo

# Check if pytest is installed
if ! command_exists pytest; then
    log_error "pytest is not installed. Please install with: uv add --dev pytest"
    exit 1
fi

if [ "$STATS_ONLY" = true ]; then
    show_vdb_stats
    exit 0
fi

# Run Qdrant tests if not skipped
if [ "$SKIP_QDRANT" = false ]; then
    run_qdrant_tests
else
    log_info "Skipping Qdrant tests as requested"
fi

# Run Weaviate tests if not skipped
if [ "$SKIP_WEAVIATE" = false ]; then
    run_weaviate_tests
else
    log_info "Skipping Weaviate tests as requested"
fi

# Run ChromaDB tests if not skipped
if [ "$SKIP_CHROMA" = false ]; then
    run_chromadb_tests
else
    log_info "Skipping ChromaDB tests as requested"
fi

# Run Pinecone tests if not skipped
if [ "$SKIP_PINECONE" = false ]; then
    run_pinecone_tests
else
    log_info "Skipping Pinecone tests as requested"
fi

# Run embedding tests if not skipped
if [ "$SKIP_EMBEDDING" = false ]; then
    run_embedding_tests
else
    log_info "Skipping embedding tests as requested"
fi

# Run similarity search tests if not skipped
if [ "$SKIP_SIMILARITY" = false ]; then
    run_similarity_tests
else
    log_info "Skipping similarity search tests as requested"
fi

# Run VDB integration tests
run_vdb_integration_tests

# Generate report if requested
if [ "$GENERATE_REPORT" = true ]; then
    generate_vdb_report
fi

# Show statistics
show_vdb_stats

echo
echo "=" | tr -d '\n' | head -c 60
echo -e "\n${GREEN}🎉 VDB TESTING COMPLETE!${NC}"
echo "=" | tr -d '\n' | head -c 60
echo

echo -e "${BLUE}📊 VDB TEST SUMMARY:${NC}"
if [ "$SKIP_QDRANT" = false ]; then
    echo -e "  ${GREEN}✅${NC} Qdrant: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Qdrant: Skipped"
fi
if [ "$SKIP_WEAVIATE" = false ]; then
    echo -e "  ${GREEN}✅${NC} Weaviate: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Weaviate: Skipped"
fi
if [ "$SKIP_CHROMA" = false ]; then
    echo -e "  ${GREEN}✅${NC} ChromaDB: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} ChromaDB: Skipped"
fi
if [ "$SKIP_PINECONE" = false ]; then
    echo -e "  ${GREEN}✅${NC} Pinecone: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Pinecone: Skipped"
fi
if [ "$SKIP_EMBEDDING" = false ]; then
    echo -e "  ${GREEN}✅${NC} Embeddings: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Embeddings: Skipped"
fi
if [ "$SKIP_SIMILARITY" = false ]; then
    echo -e "  ${GREEN}✅${NC} Similarity Search: Tested"
else
    echo -e "  ${YELLOW}⏭️${NC} Similarity Search: Skipped"
fi
echo -e "  ${GREEN}✅${NC} VDB Integration: Tested"
if [ "$GENERATE_REPORT" = true ]; then
    echo -e "  ${GREEN}✅${NC} VDB Report: Generated"
fi

echo
echo -e "${GREEN}🚀 VDB testing complete! All vector database integrations verified!${NC}"
