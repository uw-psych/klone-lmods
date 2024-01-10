# lmod-rclone

This script downloads and installs [`rclone`](https://github.com/rclone/rclone) as an [Lmod](https://lmod.readthedocs.io/en/latest/index.html) module from the [official releases](https://github.com/rclone/rclone/releases) page.

The script is intended to be used on the [UW Hyak](https://hyak.uw.edu) `klone` cluster. It will install the module contents under `/sw/contrib/<group>-src/` and the modulefile under `/sw/contrib/modulefiles/<group>`.

```
Usage: ./install-module.sh [options]
    --app-version <version> Version of the app (default: [auto])
    --modules-dir <dir>     Install module contents under <dir>
    --modulefiles-dir <dir> Install modulefile to <dir>
    --install-dir <dir>     Install module contents to an alternative directory <dir>
	--help | -h 			Print this help message

Description:
    This script downloads and installs rclone as a Lmod module.

    It will download the latest version from GitHub unless --app-version is specified.

    If --modulefiles-dir does not begin with /sw/contrib, then the modulefile will not be installed, as this script is intended to be used on klone.

Examples:
    ./install-module.sh --modules-dir /sw/contrib/escience-src --modulefiles-dir /sw/contrib/modulefiles/escience
```

