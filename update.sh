#!/bin/bash

echo "Running WC Plugin Framework Updater..."

ROOT_DIR=$(pwd)
echo "Detected plugin root: ${ROOT_DIR}"

# parse the old version from the `FRAMEWORK_VERSION` constant
OLD_VERSION=$1
OLD_VERSION="$(find "${ROOT_DIR}" -maxdepth 1 -type f \( -name '*.php' \) -exec sed -nE "s/const FRAMEWORK_VERSION = '([0-9.]+)';/\1/p" {} \; | xargs)"
echo "Detected old version: ${OLD_VERSION}"

SV_FRAMEWORK_DIR="${ROOT_DIR}/vendor/skyverge/wc-plugin-framework"
if [ ! -d "${SV_FRAMEWORK_DIR}" ]; then
  echo "${SV_FRAMEWORK_DIR} does not exist."
fi

# parse the new version from the framework package's composer.json file
SV_FRAMEWORK_COMPOSER_FILE="${SV_FRAMEWORK_DIR}/composer.json"
NEW_VERSION=$(jq -e -r .version "${SV_FRAMEWORK_COMPOSER_FILE}")

echo "Detected new version: ${NEW_VERSION}"

if [[ "$OLD_VERSION" == "$NEW_VERSION" ]]; then
  echo "Version has not changed - exiting."
  exit 0
fi

read -p "Proceed with replacements? [y/n]" -n 1 -r
echo    # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

echo "Continuing to replacements..."

# replace `.` with `_` to build our namespace string
OLD_VERSION_WITH_UNDERSCORES=${OLD_VERSION//./_}
OLD_NAMESPACE_STRING="v${OLD_VERSION_WITH_UNDERSCORES}"

NEW_VERSION_WITH_UNDERSCORES=${NEW_VERSION//./_}
NEW_NAMESPACE_STRING="v${NEW_VERSION_WITH_UNDERSCORES}"

# replace namespace in entire code base EXCEPT node_modules and vendor; we're looking in PHP and JS files only
echo "Replacing instances of ${OLD_NAMESPACE_STRING} with ${NEW_NAMESPACE_STRING} in path: ${ROOT_DIR}"
NODE_MODULES_PATH="${ROOT_DIR}/node_modules"
VENDOR_PATH="${ROOT_DIR}/vendor"

find "${ROOT_DIR}/" -not \( -path "${NODE_MODULES_PATH}" -prune \) -not \( -path "${VENDOR_PATH}" -prune \)  -type f \( -name '*.php' -o -name '*.js' \) -exec sed -i "s/${OLD_NAMESPACE_STRING}/${NEW_NAMESPACE_STRING}/g" {} \;

# replace framework version number
echo "Updating FRAMEWORK_VERSION constant..."
find "${ROOT_DIR}/" -maxdepth 1 -type f \( -name '*.php' \) -exec sed -i "s/const FRAMEWORK_VERSION = '${OLD_VERSION}';/const FRAMEWORK_VERSION = '${NEW_VERSION}';/g" {} \;

echo "Update complete!"