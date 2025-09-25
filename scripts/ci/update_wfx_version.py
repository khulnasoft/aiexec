"""Script to update WFX version for nightly builds."""

import re
import sys
from pathlib import Path

from update_pyproject_name import update_pyproject_name
from update_pyproject_version import update_pyproject_version

# Add the current directory to the path so we can import the other scripts
current_dir = Path(__file__).resolve().parent
sys.path.append(str(current_dir))

BASE_DIR = Path(__file__).parent.parent.parent


def update_wfx_workspace_dep(pyproject_path: str, new_project_name: str) -> None:
    """Update the WFX workspace dependency in pyproject.toml."""
    filepath = BASE_DIR / pyproject_path
    content = filepath.read_text(encoding="utf-8")

    if new_project_name == "wfx-nightly":
        pattern = re.compile(r"wfx = \{ workspace = true \}")
        replacement = "wfx-nightly = { workspace = true }"
    else:
        msg = f"Invalid WFX project name: {new_project_name}"
        raise ValueError(msg)

    # Updates the dependency name for uv
    if not pattern.search(content):
        msg = f"wfx workspace dependency not found in {filepath}"
        raise ValueError(msg)
    content = pattern.sub(replacement, content)
    filepath.write_text(content, encoding="utf-8")


def update_wfx_for_nightly(wfx_tag: str):
    """Update WFX package for nightly build.

    Args:
        wfx_tag: The nightly tag for WFX (e.g., "v0.1.0.dev0")
    """
    wfx_pyproject_path = "src/wfx/pyproject.toml"

    # Update name to wfx-nightly
    update_pyproject_name(wfx_pyproject_path, "wfx-nightly")

    # Update version (strip 'v' prefix if present)
    version = wfx_tag.lstrip("v")
    update_pyproject_version(wfx_pyproject_path, version)

    # Update workspace dependency in root pyproject.toml
    update_wfx_workspace_dep("pyproject.toml", "wfx-nightly")

    print(f"Updated WFX package to wfx-nightly version {version}")


def main():
    """Update WFX for nightly builds.

    Usage:
    update_wfx_version.py <wfx_tag>
    """
    expected_args = 2
    if len(sys.argv) != expected_args:
        print("Usage: update_wfx_version.py <wfx_tag>")
        sys.exit(1)

    wfx_tag = sys.argv[1]
    update_wfx_for_nightly(wfx_tag)


if __name__ == "__main__":
    main()
