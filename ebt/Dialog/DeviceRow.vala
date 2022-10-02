// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2016 elementary LLC.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Corentin Noël <corentin@elementary.io>
 *              Torikulhabib <torik.habib@gamail.com>
 */

public class DeviceRow : Gtk.ListBoxRow {
    public signal void send_file (Bluetooth.Device device);
    public Bluetooth.Device device { get; construct; }
    public unowned Bluetooth.Adapter adapter { get; construct; }
    private static Gtk.SizeGroup size_group;
    private Gtk.Button send_button;
    private Gtk.Image state;
    private Gtk.Label state_label;

    public DeviceRow (Bluetooth.Device device, Bluetooth.Adapter adapter) {
        Object (device: device, adapter: adapter);
    }

    static construct {
        size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
    }

    construct {
        var image = new Gtk.Image.from_icon_name (device.icon ?? "bluetooth", Gtk.IconSize.DND);

        state = new Gtk.Image.from_icon_name ("user-offline", Gtk.IconSize.MENU) {
            halign = Gtk.Align.END,
            valign = Gtk.Align.END
        };

        state_label = new Gtk.Label (null) {
            xalign = 0,
            use_markup = true
        };

        var overlay = new Gtk.Overlay ();
        overlay.tooltip_text = device.address;
        overlay.add (image);
        overlay.add_overlay (state);

        string? device_name = device.name;
        if (device_name == null) {
            if (device.icon != null) {
                device_name = device_icon ();
            } else {
                device_name = device.address;
            }
        }

        var label = new Gtk.Label (device_name) {
            ellipsize = Pango.EllipsizeMode.END,
            hexpand = true,
            xalign = 0
        };

        send_button = new Gtk.Button () {
            valign = Gtk.Align.CENTER,
            label = _("Send")
        };

        size_group.add_widget (send_button);

        var grid = new Gtk.Grid () {
            margin = 6,
            column_spacing = 6,
            orientation = Gtk.Orientation.HORIZONTAL
        };
        grid.attach (overlay, 0, 0, 1, 2);
        grid.attach (label, 1, 0, 1, 1);
        grid.attach (state_label, 1, 1, 1, 1);
        grid.attach (send_button, 4, 0, 1, 2);
        add (grid);
        show_all ();

        set_sensitive (adapter.powered);
        set_status (device.connected);

        ((DBusProxy)adapter).g_properties_changed.connect ((changed, invalid) => {
            var powered = changed.lookup_value ("Powered", new VariantType ("b"));
            if (powered != null) {
                set_sensitive (adapter.powered);
            }
        });

        ((DBusProxy)device).g_properties_changed.connect ((changed, invalid) => {
            var connected = changed.lookup_value ("Connected", new VariantType ("b"));
            if (connected != null) {
                set_status (device.connected);
            }

            var name = changed.lookup_value ("Name", new VariantType ("s"));
            if (name != null) {
                label.label = device.name;
            }

            var icon = changed.lookup_value ("Icon", new VariantType ("s"));
            if (icon != null) {
                image.icon_name = device.icon ?? "bluetooth";
            }
        });

        state_label.label = GLib.Markup.printf_escaped (
            "<span font_size='small'>%s</span>",
            device_icon ()
        );
        send_button.clicked.connect (() => {
            send_file (device);
            get_toplevel ().destroy ();
        });
    }

    private string device_icon () {
        switch (device.icon) {
            case "audio-card":
                return _("Speaker");
            case "input-gaming":
                return _("Controller");
            case "input-keyboard":
                return _("Keyboard");
            case "input-mouse":
                return _("Mouse");
            case "input-tablet":
                return _("Tablet");
            case "input-touchpad":
                return _("Touchpad");
            case "phone":
                return _("Phone");
            default:
                return device.address;
        }
    }

    private void set_status (bool status) {
        state.icon_name = status? "user-available" : "user-offline";
    }
}
