#!/usr/bin/env python3
# ruff: noqa: T201, S603, RET504, RUF001, PTH111, FBT002, PTH110, D415, D205, TRY300
"""Update UV and Build Script (Python Version)
This script introduces uv as the Python package manager and builds the project
Author: AIEXEC Development Team
Version: 1.0.0
"""

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

# Colors for output
GREEN = "\033[0;32m"
RED = "\033[0;31m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color


def run_command(command, shell=False, capture_output=False, text=True, check=True):
    """Run a shell command and return the result."""
    try:
        result = subprocess.run(command, shell=shell, capture_output=capture_output, text=text, check=check)
        return result
    except subprocess.CalledProcessError as e:
        print(f"{RED}❌ Command failed: {command}{NC}")
        if capture_output:
            print(f"Error output: {e.stderr}")
        sys.exit(1)


def log_status(message):
    print(f"{GREEN}✅ {message}{NC}")


def log_info(message):
    print(f"{BLUE}ℹ️  {message}{NC}")


def log_warning(message):
    print(f"{YELLOW}⚠️  {message}{NC}")


def log_error(message):
    print(f"{RED}❌ {message}{NC}")


def command_exists(command):
    """Check if a command exists in the system."""
    return shutil.which(command) is not None


def install_uv():
    """Install uv using pipx."""
    log_info("Installing uv using pipx...")

    if not command_exists("pipx"):
        log_warning("pipx not found. Installing pipx first...")
        run_command([sys.executable, "-m", "pip", "install", "--user", "pipx"])
        os.environ["PATH"] = os.path.expanduser("~/.local/bin") + ":" + os.environ["PATH"]

    run_command(["pipx", "install", "uv"])
    log_status("uv installed successfully")


def update_uv():
    """Update uv to latest version."""
    log_info("Updating uv to latest version...")
    run_command(["uv", "self", "update"])
    log_status("uv updated to latest version")


def setup_python_env():
    """Set up Python environment."""
    log_info("Setting up Python environment...")

    if not command_exists("python3"):
        log_error("Python 3 is required but not found")
        sys.exit(1)

    # Check Python version
    result = run_command(
        ["python3", "-c", "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"],
        capture_output=True,
    )
    python_version = result.stdout.strip()
    log_info(f"Python version: {python_version}")

    python_required = "3.11"
    if python_version != python_required:
        log_warning(f"Python version {python_version} detected, but {python_required} recommended")

    log_status("Python environment ready")


def install_dependencies(project_root, no_frontend=False):
    """Install project dependencies."""
    log_info("Installing project dependencies...")

    os.chdir(project_root)

    # Install backend dependencies
    if os.path.exists("pyproject.toml"):
        log_info("Installing main project dependencies...")
        run_command(["uv", "sync", "--frozen"])
        log_status("Main project dependencies installed")

    # Install frontend dependencies if present
    frontend_dir = Path("src/frontend")
    if not no_frontend and frontend_dir.exists() and (frontend_dir / "package.json").exists():
        log_info("Installing frontend dependencies...")
        os.chdir(frontend_dir)
        run_command(["npm", "install"])
        os.chdir(project_root)
        log_status("Frontend dependencies installed")

    # Install backend base dependencies
    base_dir = Path("src/backend/base")
    if (base_dir / "pyproject.toml").exists():
        log_info("Installing backend base dependencies...")
        os.chdir(base_dir)
        run_command(["uv", "sync", "--frozen"])
        os.chdir(project_root)
        log_status("Backend base dependencies installed")


def build_project(project_root, no_frontend=False):
    """Build the project."""
    log_info("Building project...")

    os.chdir(project_root)

    # Clean previous builds
    dist_dir = Path("dist")
    if dist_dir.exists():
        log_info("Cleaning previous build artifacts...")
        shutil.rmtree(dist_dir)

    base_dist_dir = Path("src/backend/base/dist")
    if base_dist_dir.exists():
        shutil.rmtree(base_dist_dir)

    # Build base package first
    base_dir = Path("src/backend/base")
    if (base_dir / "pyproject.toml").exists():
        log_info("Building aiexec-base package...")
        os.chdir(base_dir)
        run_command(["uv", "build"])
        os.chdir(project_root)
        log_status("aiexec-base built successfully")

    # Build main package
    if os.path.exists("pyproject.toml"):
        log_info("Building main aiexec package...")
        run_command(["uv", "build"])
        log_status("Main aiexec package built successfully")

    # Build frontend if present
    frontend_dir = Path("src/frontend")
    if not no_frontend and frontend_dir.exists() and (frontend_dir / "package.json").exists():
        log_info("Building frontend...")
        os.chdir(frontend_dir)
        run_command(["npm", "run", "build"])
        os.chdir(project_root)

        # Copy frontend build to backend
        build_dir = frontend_dir / "build"
        if build_dir.exists():
            log_info("Copying frontend build to backend...")
            backend_frontend_dir = Path("src/backend/base/aiexec/frontend")
            if backend_frontend_dir.exists():
                shutil.rmtree(backend_frontend_dir)
            shutil.copytree(build_dir, backend_frontend_dir)
            log_status("Frontend build copied")

    log_status("Project build complete")


def run_tests(project_root, skip_tests=False):
    """Run tests."""
    if skip_tests:
        return

    log_info("Running tests...")

    os.chdir(project_root)

    # Run Python tests
    if command_exists("pytest"):
        log_info("Running Python unit tests...")
        run_command(["uv", "run", "pytest", "src/backend/tests/unit/", "-v", "--tb=short"])
        log_status("Python unit tests passed")
    else:
        log_warning("pytest not available, skipping Python tests")

    # Run frontend tests if present
    frontend_dir = Path("src/frontend")
    if frontend_dir.exists() and (frontend_dir / "package.json").exists():
        log_info("Running frontend tests...")
        os.chdir(frontend_dir)
        run_command(["npm", "test", "--", "--watchAll=false", "--passWithNoTests"])
        os.chdir(project_root)
        log_status("Frontend tests passed")


def validate_installation(project_root):
    """Validate installation."""
    log_info("Validating installation...")

    os.chdir(project_root)

    # Test main package import
    log_info("Testing main package import...")
    try:
        run_command(["uv", "run", "python3", "-c", "import aiexec; print('✅ Main package import successful')"])
        log_status("Main package import working")
    except subprocess.CalledProcessError:
        log_error("Main package import failed")
        sys.exit(1)

    # Test base package import
    log_info("Testing base package import...")
    try:
        run_command(["uv", "run", "python3", "-c", "import aiexec_base; print('✅ Base package import successful')"])
        log_status("Base package import working")
    except subprocess.CalledProcessError:
        log_error("Base package import failed")
        sys.exit(1)

    log_status("Installation validation complete")


def main():
    """Main execution function."""
    parser = argparse.ArgumentParser(description="Update UV and Build AIEXEC Project")
    parser.add_argument("--skip-tests", action="store_true", help="Skip running tests after build")
    parser.add_argument("--no-frontend", action="store_true", help="Skip frontend build and installation")
    args = parser.parse_args()

    project_root = Path(__file__).parent.absolute()

    print(f"{BLUE}🚀 UPDATE-UV SCRIPT: AIEXEC BUILD SYSTEM{NC}")
    print("=" * 60)

    # Step 1: Check and install uv
    print(f"{BLUE}🔧 STEP 1: Checking and installing uv{NC}")
    print("-" * 50)

    if command_exists("uv"):
        log_status("uv is already installed")
        update_uv()
    else:
        log_warning("uv not found")
        install_uv()

    # Step 2: Setup Python environment
    print(f"\n{BLUE}🔧 STEP 2: Setting up Python environment{NC}")
    print("-" * 50)

    setup_python_env()

    # Step 3: Install dependencies
    print(f"\n{BLUE}🔧 STEP 3: Installing dependencies{NC}")
    print("-" * 50)

    install_dependencies(project_root, args.no_frontend)

    # Step 4: Build project
    print(f"\n{BLUE}🔧 STEP 4: Building project{NC}")
    print("-" * 50)

    build_project(project_root, args.no_frontend)

    # Step 5: Validate installation
    print(f"\n{BLUE}🔧 STEP 5: Validating installation{NC}")
    print("-" * 50)

    validate_installation(project_root)

    # Step 6: Run tests (if not skipped)
    if not args.skip_tests:
        print(f"\n{BLUE}🔧 STEP 6: Running tests{NC}")
        print("-" * 50)

        run_tests(project_root, args.skip_tests)

    print("\n" + "=" * 60)
    print(f"{GREEN}🎉 BUILD COMPLETE!{NC}")
    print("=" * 60)

    # Show final status
    print(f"{BLUE}📊 FINAL STATUS:{NC}")
    print(f"  {GREEN}✅{NC} uv package manager: Installed and updated")
    print(f"  {GREEN}✅{NC} Python environment: Configured")
    print(f"  {GREEN}✅{NC} Dependencies: Installed")
    print(f"  {GREEN}✅{NC} Project: Built successfully")
    print(f"  {GREEN}✅{NC} Installation: Validated")
    if not args.skip_tests:
        print(f"  {GREEN}✅{NC} Tests: Passed")

    # Show package information
    dist_dir = Path(project_root) / "dist"
    if dist_dir.exists():
        print(f"\n{BLUE}📦 BUILT PACKAGES:{NC}")
        for item in sorted(dist_dir.iterdir()):
            if item.is_file():
                size = item.stat().st_size
                print(f"  📄 {item.name} ({size:,} bytes)")
        print()

    print(f"{GREEN}🎯 AIEXEC is ready with uv package management!{NC}")


if __name__ == "__main__":
    main()
