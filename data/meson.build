i18n.merge_file(
    input: 'bluetooth.metainfo.xml.in',
    output: 'io.elementary.wingpanel.bluetooth.metainfo.xml',
    po_dir: meson.project_source_root () / 'po' / 'extra',
    type: 'xml',
    install: true,
    install_dir: datadir / 'metainfo'
)

install_data(
    'gschema.xml',
    rename: 'io.elementary.desktop.wingpanel.bluetooth.gschema.xml',
    install_dir: datadir / 'glib-2.0' / 'schemas'
)
