# updateversion.sh

## Overview

The `updateversion.sh` script is a bash script designed to update a version file in your project with version information retrieved from Git. Additionally, it allows you to tag your Git repository based on the version information in the version file `[filename].[fileextension]`.

## Prerequisites

- Git installed on your system.
- Basic knowledge of working with Git repositories and bash scripting.

## Steps

1. **Download the Script**: Download the `updateversion.sh` script and place it in your project directory.

2. **Make the Script Executable**: Ensure that the script has executable permissions. If not, you can set the permissions using the `chmod` command:
    ```bash
    $ chmod +x updateversion.sh
    ```

3. **Run the Script**: Run the script without any parameters to see the version major, minor, patch, and commit number.
    ```bash
    $ ./updateversion.sh
    ```

4. **Update `[filename].[fileextension]`**: Run the script with file parameters to update the version file in your project directory with version information retrieved from Git:
    ```bash
    $ ./updateversion.sh -f filename.fileextension
    ```

### Optional Steps

- **Increment Major Version**: To increment the major version number by 1 and reset the minor and patch versions to 0, use the `--major +1` option:
    ```bash
    $ ./updateversion.sh -f filename.fileextension --major +1
    ```

- **Set Major Version**: To set the major version number to a specific value and reset the minor and patch versions to 0, use the `--major new_major_number` option:
    ```bash
    $ ./updateversion.sh -f filename.fileextension --major 2
    ```

- **Increment Minor Version**: To increment the minor version number by 1 and reset the patch version to 0, use the `--minor +1` option:
    ```bash
    $ ./updateversion.sh -f filename.fileextension --minor +1
    ```

- **Set Minor Version**: To set the minor version number to a specific value and reset the patch version to 0, use the `--minor new_minor_number` option:
    ```bash
    $ ./updateversion.sh -f filename.fileextension --minor 5
    ```

- **Tag the Repository**: To tag your Git repository based on the version information in the version file, use the `--tag` option:
    ```bash
    $ ./updateversion.sh --tag
    ```

- **Tag the Repository and Upload the Tag**: To tag your Git repository and upload the tag based on the version information in the version file, use the `--tag 1` option:
    ```bash
    $ ./updateversion.sh --tag 1
    ```

## Verify Changes

After running the script with the desired options, verify that the version file has been updated correctly and that the Git repository has been tagged accordingly.
