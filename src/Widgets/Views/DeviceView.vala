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

public class Bluetooth.Widgets.DeviceView : Gtk.Grid {
    public signal void go_back ();
    private Bluetooth.Services.Device device;
    private Wingpanel.Widgets.Switch connected_switch;
    private Gtk.Button back_button;
    private Gtk.Label name_label;
    private Gtk.Image icon;

    public DeviceView (Bluetooth.Services.Device device) {
        this.device = device;
        name_label.label ="<b>%s</b>".printf (device.name);
        icon.icon_name = device.icon;

        connected_switch.set_active (device.connected);
        (device as DBusProxy).g_properties_changed.connect ((changed, invalid) => {
            var connected = changed.lookup_value("Connected", new VariantType("b"));
            if (connected != null) {
                connected_switch.set_active (device.connected);
            }

            var name_ = changed.lookup_value("Name", new VariantType("b"));
            if (name_ != null) {
                name_label.label = device.name;
            }

            var icon_ = changed.lookup_value("Icon", new VariantType("b"));
            if (icon_ != null) {
                icon.icon_name = device.icon;
            }
        });
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        var back_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
        back_button = new Gtk.Button.with_label (_("Bluetooth"));
        back_button.get_style_context ().add_class ("back-button");
        back_button.margin = 6;
        back_box.add (back_button);

        var device_grid = new Gtk.Grid ();
        icon = new Gtk.Image ();
        icon.icon_size = Gtk.IconSize.DIALOG;
        icon.margin = 6;
        name_label = new Gtk.Label (null);
        name_label.get_style_context ().add_class ("h3");
        name_label.use_markup = true;
        name_label.halign = Gtk.Align.START;

        connected_switch = new Wingpanel.Widgets.Switch (_("Connection"));

        device_grid.attach (icon, 0, 0, 1, 1);
        device_grid.attach (name_label, 1, 0, 1, 1);

        this.add (back_box);
        this.add (new Wingpanel.Widgets.Separator ());
        this.add (device_grid);
        this.add (new Wingpanel.Widgets.Separator ());
        this.add (connected_switch);
        this.show_all ();

        connected_switch.switched.connect (() => {
            new Thread<void*> (null, () => {
                try {
                    if (connected_switch.get_active ()) {
                        device.connect ();
                    } else {
                        device.disconnect ();
                    }
                } catch (Error e) {
                    critical (e.message);
                }
            });
        });

        back_button.clicked.connect (() => {
            go_back ();
        });
    }
}
