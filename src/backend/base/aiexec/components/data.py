"""Forward aiexec.components.data to wfx.components.data."""

from wfx.components.data import *  # noqa: F403
from wfx.components.data import __all__ as _all

__all__ = list(_all)
