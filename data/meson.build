i18n.merge_file(
    input: 'bluetooth.appdata.xml.in',
    output: 'io.elementary.wingpanel.bluetooth.appdata.xml',
    po_dir: join_paths(meson.source_root (), 'po', 'extra'),
    install_dir: join_paths(datadir, 'metainfo'),
    install: true
)

install_data(
    'gschema.xml',
    rename: 'io.elementary.desktop.wingpanel.bluetooth.gschema.xml',
    install_dir: join_paths(datadir, 'glib-2.0', 'schemas')
)
