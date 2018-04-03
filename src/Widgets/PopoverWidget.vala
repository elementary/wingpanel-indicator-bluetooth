/*-
 * Copyright (c) 2015-2018 elementary LLC. (https://elementary.io)
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

public class Bluetooth.Widgets.PopoverWidget : Gtk.Box {
    public signal void request_close ();
    public signal void device_requested (BluetoothIndicator.Services.Device device);
    public signal void discovery_requested ();

    private Wingpanel.Widgets.Switch main_switch;
    private Gtk.Box devices_box;
    private Gtk.Revealer revealer;

    public PopoverWidget (BluetoothIndicator.Services.ObjectManager object_manager, bool is_in_session) {
        orientation = Gtk.Orientation.VERTICAL;

        main_switch = new Wingpanel.Widgets.Switch (_("Bluetooth"), object_manager.get_global_state ());
        main_switch.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        devices_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        var scroll_box = new Wingpanel.Widgets.AutomaticScrollBox ();
        scroll_box.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scroll_box.add (devices_box);

        var revealer_content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        revealer_content.add (new Wingpanel.Widgets.Separator ());
        revealer_content.add (scroll_box);

        revealer = new Gtk.Revealer ();
        revealer.add (revealer_content);

        var show_settings_button = new Gtk.ModelButton ();
        show_settings_button.text = _("Bluetooth Settings…");

        add (main_switch);
        add (revealer);
        if (is_in_session) {
            add (new Wingpanel.Widgets.Separator ());
            add (show_settings_button);
        }

        update_ui_state (object_manager.get_global_state ());
        show_all ();

        main_switch.switched.connect (() => {
            object_manager.set_global_state.begin (main_switch.get_active ());
        });

        show_settings_button.clicked.connect (() => {
            request_close ();
            show_settings ();
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
                var device_child = child as Bluetooth.Widgets.Device;
                if (device_child != null && BluetoothIndicator.Services.ObjectManager.compare_devices (device_child.device, device)) {
                    device_child.destroy ();
                }
            });

            update_devices_box_visible ();
        });

        update_devices_box_visible ();
    }

    private void update_ui_state (bool state) {
        main_switch.set_active (state);
        update_devices_box_visible ();
    }

    private void update_devices_box_visible () {
        if (devices_box.get_children ().length () >= 1) {
            revealer.reveal_child = main_switch.get_active ();
        } else {
            revealer.reveal_child = false;
        }
    }

    private void add_device (BluetoothIndicator.Services.Device device) {
        var device_widget = new Bluetooth.Widgets.Device (device);
        devices_box.add (device_widget);
        devices_box.show_all ();

        update_devices_box_visible ();

        device_widget.show_device.connect ((device_service) => {
            device_requested (device_service);
        });
    }

    private void show_settings () {
        try {
            Gtk.show_uri (null, "settings://network/bluetooth", Gdk.CURRENT_TIME);
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
    }
}
