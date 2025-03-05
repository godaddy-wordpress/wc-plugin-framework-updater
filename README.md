# WC Plugin Framework Updater

Updater script for the [SkyVerge WooCommerce plugin framework](https://github.com/godaddy-wordpress/wc-plugin-framework).

This script helps facilitate updating the framework package, which involves replacing class namespaces throughout the code base.

## Installation

Include this package as a dev dependency:

```json
{
  "repositories": [
    {
      "type": "vcs",
      "url": "https://github.com/godaddy-wordpress/wc-plugin-framework"
    },
    {
      "type": "vcs",
      "url": "https://github.com/godaddy-wordpress/wc-plugin-framework-updater"
    }
  ],
  "require" : {
    "skyverge/wc-plugin-framework": "5.15.5"
  },
  "require-dev": {
    "skyverge/wc-plugin-framework-updater": "dev-main"
  }
}

```

## Usage

### Running manually

1. First update the framework itself to your desired version:
```
composer update skyverge/wc-plugin-framework
```
2. Then run the migration script:
```
./vendor/skyverge/wc-plugin-framework-updater/update.sh
```

### As a composer script

You can set this up to run automatically after Composer packages are updated. Update your `composer.json` file like so:

```json
{
  "scripts": {
    "post-package-update": [
      "./vendor/skyverge/wc-plugin-framework-updater/update.sh"
    ]
  }
}
```

Then all you have to do is update the framework:

```
composer update skyverge/wc-plugin-framework
```

The updater script will then run automatically.

**NOTE:** It will run after _any_ package is updated, but will exit if it detects that the framework version has not changed.

## Replacements made

The script does the following:

1. Parses the old version from your declared `FRAMEWORK_VERSION` constant.
2. Parses the new version from the framework's `composer.json` file (which is why you must update the framework itself first!).
3. Replaces all instances of `v1_2_3` (where `1_2_3` is the old version) with `v_4_5_6` (where `4_5_6` is the new version). This change is made in PHP and JS files only.
    - Excludes `node_modules/`
    - Excludes `vendor/`
4. Updates the `FRAMEWORK_VERSION` constant number.