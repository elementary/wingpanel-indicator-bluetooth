project(
    'bluetooth',
    'vala', 'c',
    version: '8.0.0',
    meson_version : '>= 0.58'
)

gettext_name = meson.project_name() + '-indicator'
gnome = import('gnome')
i18n = import('i18n')

prefix = get_option('prefix')
datadir = prefix / get_option('datadir')
libdir = prefix / get_option('libdir')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(gettext_name), language:'c')

add_project_arguments('-DG_LOG_DOMAIN="io.elementary.wingpanel.bluetooth"', language:'c')

gresource = gnome.compile_resources(
    'gresource',
    'data' / 'gresource.xml',
    source_dir: 'data'
)

wingpanel_dep = dependency('wingpanel')
wingpanel_indicatorsdir = wingpanel_dep.get_variable('indicatorsdir', pkgconfig_define: ['libdir', libdir])

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', prefix / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name() + '-indicator')
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

shared_module(
    meson.project_name(),
    'src/Indicator.vala',
    'src/Services/Adapter.vala',
    'src/Services/Device.vala',
    'src/Services/Manager.vala',
    'src/Services/ObexManager.vala',
    'src/Services/Session.vala',
    'src/Services/Transfer.vala',
    'src/Widgets/Device.vala',
    'src/Widgets/DisplayWidget.vala',
    'src/Widgets/PopoverWidget.vala',
    config_file,
    gresource,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite', version: '>=6.0.0'),
        dependency('gtk+-3.0'),
        wingpanel_dep
    ],
    install: true,
    install_dir : wingpanel_indicatorsdir
)

subdir('data')
subdir('po')

gnome.post_install(glib_compile_schemas: true)
