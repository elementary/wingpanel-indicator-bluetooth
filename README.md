# Wingpanel Bluetooth Indicator
[![Packaging status](https://repology.org/badge/tiny-repos/wingpanel-indicator-bluetooth.svg)](https://repology.org/metapackage/wingpanel-indicator-bluetooth)
[![l10n](https://l10n.elementary.io/widgets/wingpanel/wingpanel-indicator-bluetooth/svg-badge.svg)](https://l10n.elementary.io/projects/wingpanel/wingpanel-indicator-bluetooth)

![Screenshot](data/screenshot.png?raw=true)

## Building and Installation

You'll need the following dependencies:

    gobject-introspection
    libglib2.0-dev
    libgranite-dev
    libnotify-dev
    libwingpanel-2.0-dev
    meson
    valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install
