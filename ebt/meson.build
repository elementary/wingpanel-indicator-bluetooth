executable(
    'io.elementary.bluetooth',
    'Application.vala',
    'Services/Adapter.vala',
    'Services/Device.vala',
    'Services/Manager.vala',
    'Services/ObexAgent.vala',
    'Services/Session.vala',
    'Services/Transfer.vala',
    'Dialog/BtReceiver.vala',
    'Dialog/BtSender.vala',
    'Dialog/BtScan.vala',
    'Dialog/DeviceRow.vala',
    dependencies : [
        dependency ('granite'),
        dependency ('gtk+-3.0'),
    ],
    install : true
)

applications_dir = join_paths(
    get_option('prefix'),
    get_option('datadir'),
    'applications'
)

install_data(
    'io.elementary.bluetooth-daemon.desktop',
    install_dir: join_paths(get_option('sysconfdir'), 'xdg', 'autostart')
)

install_data(
    'io.elementary.bluetooth.desktop',
    install_dir: applications_dir
)
