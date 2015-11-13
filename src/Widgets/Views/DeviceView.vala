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
    private Bluetooth.Services.Device device;
    private Wingpanel.Widgets.Switch connected_switch;
    public Gtk.Button back_button;
    private Gtk.Label name;
    private Gtk.Label paired;
    private Gtk.Image icon;

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        var back_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
        back_button = new Gtk.Button.with_label (_("Bluetooth"));
        back_button.get_style_context ().add_class ("back-button");
        back_button.margin = 8;
        back_box.add (back_button);

        var device_grid = new Gtk.Grid ();
        icon = new Gtk.Image ();
        name = new Gtk.Label (null);
        paired = new Gtk.Label (null);
        icon.icon_size = Gtk.IconSize.DIALOG;

        connected_switch = new Wingpanel.Widgets.Switch (_("Connection:"));

        paired.get_style_context ().add_class ("h3");
        name.get_style_context ().add_class ("h3");
        name.use_markup = true;
        name.set_halign (Gtk.Align.START);
        paired.set_halign (Gtk.Align.START);
        icon.margin = 8;

        device_grid.attach (icon, 0, 0, 2, 2);
        device_grid.attach (name, 2, 0, 1, 1);
        device_grid.attach (paired, 2, 1, 1, 1);

        this.add (back_box);
        this.add (new Wingpanel.Widgets.Separator ());
        this.add (device_grid);
        this.add (new Wingpanel.Widgets.Separator ());
        this.add (connected_switch);

        connected_switch.switched.connect (() => {
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
    }

    public void refresh (Bluetooth.Services.Device device) {
        this.device = device;
        name.set_label ("<b>" + device.name + "</b>");
        icon.set_from_icon_name (device.icon, Gtk.IconSize.DIALOG);
        paired.set_label ("Paired");
        connected_switch.set_active (device.connected);
    }
}
