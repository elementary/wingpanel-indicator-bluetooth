# Wingpanel Bluetooth Indicator
[![Packaging status](https://repology.org/badge/tiny-repos/wingpanel-indicator-bluetooth.svg)](https://repology.org/metapackage/wingpanel-indicator-bluetooth)
[![l10n](https://l10n.elementary.io/widgets/wingpanel/wingpanel-indicator-bluetooth/svg-badge.svg)](https://l10n.elementary.io/projects/wingpanel/wingpanel-indicator-bluetooth)

![Screenshot](data/screenshot.png?raw=true)

## Building and Installation

It's recommended to create a clean build environment

    mkdir build
    cd build/

Run `cmake` to configure the build environment and then `make` to build

    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make

To install, use `make install`

    sudo make install
