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
    private Gtk.Revealer revealer;

    private Gee.HashMap <string, Bluetooth.Widgets.Device> devices;

    public MainView (Bluetooth.Services.ObjectManager object_manager, bool is_in_session) {
        orientation = Gtk.Orientation.VERTICAL;

        devices = new Gee.HashMap <string, Bluetooth.Widgets.Device> ();

        main_switch = new Wingpanel.Widgets.Switch (_("Bluetooth"), object_manager.get_global_state ());
        main_switch.get_style_context ().add_class ("h4");

        devices_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        devices_box.add (new Wingpanel.Widgets.Separator ());

        var scroll_box = new Wingpanel.Widgets.AutomaticScrollBox ();
        scroll_box.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scroll_box.add (devices_box);

        revealer = new Gtk.Revealer ();
        revealer.add (scroll_box);

        show_settings_button = new Wingpanel.Widgets.Button (_("Bluetooth Settings…"));
        discovery_button = new Wingpanel.Widgets.Button (_("Discover Devices…"));

        add (main_switch);
        add (revealer);
        if (is_in_session) {
            add (new Wingpanel.Widgets.Separator ());
            add (discovery_button);
            add (show_settings_button);
        }

        update_ui_state (object_manager.get_global_state ());
        show_all ();

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
            if (devices.has_key (device.modalias)) {
                var widget = devices.get (device.modalias);
                widget.no_show_all = true;
                widget.visible = false;
            }

            update_devices_box_visible ();
        });

        update_devices_box_visible ();
    }

    private void update_ui_state (bool state) {
        main_switch.set_active (state);
        revealer.reveal_child = state;
        discovery_button.sensitive = state;
    }

    private void update_devices_box_visible () {
        bool has_visible_device = false;
        foreach (var device in devices.values) {
            if (!device.no_show_all) {
                has_visible_device = true;
                break;
            }
        }

        devices_box.no_show_all = !has_visible_device;
        devices_box.visible = has_visible_device;
    }

    private void add_device (Bluetooth.Services.Device device) {
        Bluetooth.Widgets.Device device_widget;

        if (!devices.has_key (device.modalias)) {
            device_widget = new Bluetooth.Widgets.Device (device);
            devices_box.add (device_widget);

            device_widget.show_device.connect ((device_service) => {
                device_requested (device_service);
            });

            devices.set (device.modalias, device_widget);
        } else {
            device_widget = devices.get (device.modalias);
        }

        device_widget.no_show_all = false;
        device_widget.visible = true;

        update_devices_box_visible ();
    }

    private void show_settings () {
        try {
            Gtk.show_uri (null, "settings://network/bluetooth", Gdk.CURRENT_TIME);
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
    }
}
