# klone-lmods

Lmod modules for Klone.

## Usage

Installers for the modules are available in the `installers` directory. The installer downloads the binaries or source code for the latest version of the module and installs it in the `/sw/contrib/${GROUP_NAME}-src` directory. It then creates a module file in the `/sw/contrib/modulefiles/${GROUP_NAME}` directory. The module file will load the module and set the appropriate environment variables.

The default group name is `escience`, but this can be changed by setting the `GROUP_NAME` environment variable.

To install a module, run the following command:

```bash
cd installers/app-to-install # e.g. installers/rclone
./install-module.sh
```

To load the module, run the following command:

```bash
module -I load ${GROUP_NAME}/app-to-install/app-version # e.g. module -I load escience/rclone/1.65.1
