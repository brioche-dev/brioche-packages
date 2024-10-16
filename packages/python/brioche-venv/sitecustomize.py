# This module is loaded by default by `site.py` and modifies several things
# under `sys` to look just like a normal venv

import os
import sys
import site

if "BRIOCHE_OVERRIDE_SYS_EXECUTABLE" in os.environ:
    # Substitute `sys.executable` and normalize the path
    sys.executable = os.path.normpath(os.environ["BRIOCHE_OVERRIDE_SYS_EXECUTABLE"])

if "BRIOCHE_VIRTUAL_ENV" in os.environ:
    # Get the current list of site packages
    original_site_packages = site.getsitepackages()

    # Get the root of the venv
    virtual_env = os.path.normpath(os.environ["BRIOCHE_VIRTUAL_ENV"])

    # Update the standard prefix paths
    sys.prefix = virtual_env
    sys.exec_prefix = virtual_env
    site.PREFIXES = [virtual_env]

    # Remove the original site packages
    sys.path = [path for path in sys.path if path not in original_site_packages]

    # Get the new list of site packages
    new_site_packages = site.getsitepackages()

    # Add the new site packages to `sys.path`. This uses `site.addsitedir`
    # for consistency with what `site.py` does`
    for path in new_site_packages:
        site.addsitedir(path)
