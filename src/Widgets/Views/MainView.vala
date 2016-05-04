/*-
 * Copyright (c) 2015 Wingpanel Developers (http://launchpad.net/wingpanel)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class Bluetooth.Widgets.MainView : Gtk.Box {
    public signal void request_close ();
    public signal void device_requested (Bluetooth.Services.Device device);
    public signal void discovery_requested ();

    private Wingpanel.Widgets.Button show_settings_button;
    private Wingpanel.Widgets.Button discovery_button;
    private Wingpanel.Widgets.Switch main_switch;
    private Gtk.Box devices_box;

    public MainView (Bluetooth.Services.ObjectManager object_manager, bool is_in_session) {
        main_switch = new Wingpanel.Widgets.Switch (_("Bluetooth"), object_manager.get_global_state ());
        show_settings_button = new Wingpanel.Widgets.Button (_("Bluetooth Settings…"));
        discovery_button = new Wingpanel.Widgets.Button (_("Discover Devices…"));
        devices_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        devices_box.add (new Wingpanel.Widgets.Separator ());

        main_switch.get_style_context ().add_class ("h4");
        devices_box.set_orientation (Gtk.Orientation.VERTICAL);

        update_ui_state (object_manager.get_global_state ());
        this.set_orientation (Gtk.Orientation.VERTICAL);
        this.add (main_switch);
        this.add (devices_box);
        if (is_in_session) {
            this.add (new Wingpanel.Widgets.Separator ());
            this.add (discovery_button);
            this.add (show_settings_button);
        }

        this.show_all ();
        main_switch.switched.connect (() => {
            object_manager.set_global_state (main_switch.get_active ());
        });

        show_settings_button.clicked.connect (() => {
            request_close ();
            show_settings ();
        });

        discovery_button.clicked.connect (() => {
            request_close ();

            try {
                var appinfo = AppInfo.create_from_commandline ("bluetooth-wizard", null, AppInfoCreateFlags.SUPPORTS_URIS);
                appinfo.launch_uris (null, null);
            } catch (Error e) {
                warning ("%s\n", e.message);
            }
        });

        //Adapter's Connections
        object_manager.global_state_changed.connect ((state, paired) => {
            update_ui_state (state);
        });

        foreach (var device in object_manager.get_devices ()) {
            add_device (device);
        }

        object_manager.device_added.connect ((device) => {
            add_device (device);
        });

        object_manager.device_removed.connect ((device) => {
            devices_box.get_children ().foreach ((child) => {
                if (child is Bluetooth.Widgets.Device) {
                    ((Bluetooth.Widgets.Device) child).destroy ();
                }
            });

            devices_box.no_show_all = (devices_box.get_children ().length () <= 1);
            devices_box.visible = !devices_box.no_show_all;
        });

        devices_box.no_show_all = (devices_box.get_children ().length () <= 1);
        devices_box.visible = !devices_box.no_show_all;
    }

    private void update_ui_state (bool state) {
        main_switch.set_active (state);
        devices_box.set_sensitive (state);
        discovery_button.set_sensitive (state);
    }

    private void add_device (Bluetooth.Services.Device device) {
        var device_widget = new Bluetooth.Widgets.Device (device);
        devices_box.add (device_widget);

        devices_box.no_show_all = (devices_box.get_children ().length () <= 1);
        devices_box.visible = !devices_box.no_show_all;

        device_widget.show_device.connect ((device_service) => {
            device_requested (device_service);
        });
    }

    private void show_settings () {
        var list = new List<string> ();
        list.append ("bluetooth");

        try {
            var appinfo = AppInfo.create_from_commandline ("switchboard", null, AppInfoCreateFlags.SUPPORTS_URIS);
            appinfo.launch_uris (list, null);
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
    }
}
