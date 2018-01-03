project('bluetooth', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="' + meson.project_name() + '-indicator"', language:'c')

asresources = gnome.compile_resources(
    'as-resources', 'data/io.elementary.wingpanel.bluetooth.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

wingpanel_dep = dependency('wingpanel-2.0')

shared_module(
    meson.project_name(),
    'src/Indicator.vala',
    'src/Services/Adapter.vala',
    'src/Services/Device.vala',
    'src/Services/Manager.vala',
    'src/Widgets/Views/DiscoveryView.vala',
    'src/Widgets/Views/MainView.vala',
    'src/Widgets/Device.vala',
    'src/Widgets/DisplayWidget.vala',
    'src/Widgets/PopoverWidget.vala',
    asresources,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('libnotify'),
        wingpanel_dep
    ],
    install: true,
    install_dir : wingpanel_dep.get_pkgconfig_variable('indicatorsdir')
)

subdir('po')
