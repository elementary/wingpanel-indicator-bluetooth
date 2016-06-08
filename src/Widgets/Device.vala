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
    private const string DEFAULT_ICON = "bluetooth";
    public signal void show_device (Bluetooth.Services.Device device);

    public Bluetooth.Services.Device device;
    private Gtk.Label name_label;
    private Gtk.Label status_label;
    private Gtk.Spinner spinner;
    private Gtk.Image icon_image;

    public Device (Bluetooth.Services.Device device) {
        this.device = device;
        name_label = new Gtk.Label ("<b>%s</b>".printf (device.name));
        name_label.halign = Gtk.Align.START;
        name_label.use_markup = true;
        status_label = new Gtk.Label (_("Not Connected"));
        status_label.halign = Gtk.Align.START;
        spinner = new Gtk.Spinner ();
        spinner.halign = Gtk.Align.START;
        spinner.hexpand = true;
        icon_image = new Gtk.Image.from_icon_name (device.icon == null ? DEFAULT_ICON : device.icon, Gtk.IconSize.DIALOG);
        var grid = new Gtk.Grid ();

        grid.attach (icon_image, 0, 0, 1, 2);
        grid.attach (name_label, 1, 0, 2, 1);
        grid.attach (status_label, 1, 1, 1, 1);
        grid.attach (spinner, 2, 1, 1, 1);
        get_content_widget ().add (grid);

        clicked.connect (() => {
            if (!spinner.active) {
                toggle_device ();
            }
        });

        (device as DBusProxy).g_properties_changed.connect ((changed, invalid) => {
            var name_ = changed.lookup_value("Name", new VariantType("b"));
            if (name_ != null) {
                name_label.label = device.name;
            }

            if (device.connected) {
                status_label.label = _("Connected");
            } else {
                status_label.label = _("Not Connected");
            }

            var icon_ = changed.lookup_value("Icon", new VariantType("b"));
            if (icon_ != null) {
                icon_image.icon_name = device.icon;
            }
        });
    }

    private void toggle_device () {
        spinner.active = true;
        new Thread<void*> (null, () => {
            try {
                if (!device.connected) {
                    status_label.label = _("Connecting…");
                    device.connect ();
                } else {
                    status_label.label = _("Disconnecting…");
                    device.disconnect ();
                }
            } catch (Error e) {
                critical (e.message);
                status_label.label = _("Unable to Connect");
            }
            spinner.active = false;
            return null;
        });
    }
}
