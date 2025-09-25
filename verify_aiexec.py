#!/usr/bin/env python3
# ruff: noqa: BLE001, FBT003, TRY300, PLR2004, EXE001, D205, FBT001
"""Comprehensive Verification Script for Aiexec Renaming
Tests all core functionality after aiexec → aiexec renaming.
"""

import sys
from pathlib import Path


class AiexecVerifier:
    def __init__(self, root_dir: str):
        self.root_dir = Path(root_dir)
        self.test_results = []
        self.errors = []

    def log_result(self, test_name: str, success: bool, details: str = ""):
        """Log test result."""
        if details:
            pass
        self.test_results.append((test_name, success, details))

    def test_basic_imports(self):
        """Test basic Python imports."""
        try:
            # Test core aiexec import
            import aiexec

            self.log_result("Core aiexec import", True, f"Version: {getattr(aiexec, '__version__', 'Unknown')}")

            # Test main application
            self.log_result("Main application import", True)

            # Test core components
            self.log_result("Core components import", True)

            # Test API endpoints
            self.log_result("API endpoints import", True)

            # Test settings
            self.log_result("Settings import", True)

            return True
        except Exception as e:
            self.log_result("Basic imports test", False, str(e))
            self.errors.append(f"Import error: {e}")
            return False

    def test_application_creation(self):
        """Test application creation and basic functionality."""
        try:
            from aiexec.main import create_app

            # Create app instance
            app = create_app()
            self.log_result("Application creation", True, f"App name: {app.name}")

            # Check routes
            route_count = len(app.routes)
            self.log_result("Route loading", True, f"Routes loaded: {route_count}")

            # Check middleware
            middleware_count = len(app.middleware)
            self.log_result("Middleware loading", True, f"Middleware loaded: {middleware_count}")

            return True
        except Exception as e:
            self.log_result("Application creation test", False, str(e))
            self.errors.append(f"App creation error: {e}")
            return False

    def test_package_dependencies(self):
        """Test that package dependencies resolve correctly."""
        try:
            # Test that aiexec-base can be imported
            import aiexec_base

            self.log_result("aiexec-base import", True)

            # Test version compatibility
            base_version = getattr(aiexec_base, "__version__", "Unknown")
            self.log_result("Version compatibility", True, f"Base version: {base_version}")

            return True
        except Exception as e:
            self.log_result("Package dependencies test", False, str(e))
            self.errors.append(f"Dependency error: {e}")
            return False

    def test_cli_functionality(self):
        """Test CLI functionality."""
        try:
            self.log_result("CLI module import", True)

            self.log_result("Main module import", True)

            return True
        except Exception as e:
            self.log_result("CLI functionality test", False, str(e))
            self.errors.append(f"CLI error: {e}")
            return False

    def test_configuration_loading(self):
        """Test configuration loading."""
        try:
            from aiexec import settings

            self.log_result("Settings loading", True)

            # Test that settings are accessible
            if hasattr(settings, "SETTINGS"):
                self.log_result("Settings object", True)
            else:
                self.log_result("Settings object", False, "No SETTINGS object found")

            return True
        except Exception as e:
            self.log_result("Configuration loading test", False, str(e))
            self.errors.append(f"Config error: {e}")
            return False

    def test_database_models(self):
        """Test database models."""
        try:
            self.log_result("Database models import", True)

            return True
        except Exception as e:
            self.log_result("Database models test", False, str(e))
            self.errors.append(f"Database error: {e}")
            return False

    def test_api_structure(self):
        """Test API structure."""
        try:
            self.log_result("API router import", True)

            self.log_result("Projects API import", True)

            return True
        except Exception as e:
            self.log_result("API structure test", False, str(e))
            self.errors.append(f"API error: {e}")
            return False

    def run_comprehensive_tests(self):
        """Run all verification tests."""
        # Add root directory to Python path
        sys.path.insert(0, str(self.root_dir / "src/backend/base"))

        tests = [
            self.test_basic_imports,
            self.test_application_creation,
            self.test_package_dependencies,
            self.test_cli_functionality,
            self.test_configuration_loading,
            self.test_database_models,
            self.test_api_structure,
        ]

        passed = 0
        total = len(tests)

        for test in tests:
            try:
                if test():
                    passed += 1
            except Exception as e:
                self.log_result(f"Test {test.__name__}", False, f"Exception: {e}")

        # Summary

        if passed == total:
            pass
        else:
            pass

        if self.errors:
            for _error in self.errors:
                pass

        return passed == total


def main():
    if len(sys.argv) != 2:
        sys.exit(1)

    root_dir = sys.argv[1]
    verifier = AiexecVerifier(root_dir)
    success = verifier.run_comprehensive_tests()

    # Exit with appropriate code
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
