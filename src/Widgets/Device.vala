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

public class Bluetooth.Widgets.Device : Wingpanel.Widgets.Container {
    public signal void show_device (Bluetooth.Services.Device device);

    public Bluetooth.Services.Device device;
    private Gtk.Label name_label;
    private Gtk.Image icon_image;

    public Device (Bluetooth.Services.Device device) {
        this.device = device;
        name_label = new Gtk.Label (device.name);
        icon_image = new Gtk.Image.from_icon_name (device.icon, Gtk.IconSize.MENU);
        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.HORIZONTAL;
        grid.margin_start = 6;

        grid.add (icon_image);
        grid.add (name_label);
        get_content_widget ().add (grid);

        this.clicked.connect (() => {
            show_device (this.device);
        });

        (device as DBusProxy).g_properties_changed.connect ((changed, invalid) => {
            var name_ = changed.lookup_value("Name", new VariantType("b"));
            if (name_ != null) {
                name_label.label = device.name;
            }

            var icon_ = changed.lookup_value("Icon", new VariantType("b"));
            if (icon_ != null) {
                icon_image.icon_name = device.icon;
            }
        });
    }
}
