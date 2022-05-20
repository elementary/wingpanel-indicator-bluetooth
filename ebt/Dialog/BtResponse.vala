/*
 * Copyright 2021 elementary, Inc. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Torikulhabib <torik.habib@gamail.com>
 *
 */

public class BtResponse : Granite.Dialog {
    private Gtk.Label device_label;
    private Gtk.Label filename_label;
    private Gtk.Label size_label;
    private Gtk.Image status_image;

    public BtResponse (Gtk.Application application) {
        Object (application: application,
                resizable : false
        );
    }

    construct {
        var icon_image = new Gtk.Image.from_icon_name ("bluetooth", Gtk.IconSize.DIALOG) {
            valign = Gtk.Align.END,
            halign = Gtk.Align.END
        };

        status_image = new Gtk.Image () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.END
        };
        var overlay = new Gtk.Overlay ();
        overlay.add (icon_image);
        overlay.add_overlay (status_image);

        var warning_label = new Gtk.Label (_("Incoming file")) {
            max_width_chars = 45,
            wrap = true,
            xalign = 0
        };
        warning_label.get_style_context ().add_class ("primary");

        device_label = new Gtk.Label (null) {
            max_width_chars = 45,
            use_markup = true,
            wrap = true,
            xalign = 0
        };
        filename_label = new Gtk.Label (null) {
            max_width_chars = 45,
            use_markup = true,
            wrap = true,
            xalign = 0
        };
        size_label = new Gtk.Label (null) {
            max_width_chars = 45,
            use_markup = true,
            wrap = true,
            xalign = 0
        };
        var box_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            margin_end = 15,
            width_request = 400
        };
        box_grid.attach (overlay, 0, 0, 1, 5);
        box_grid.attach (warning_label, 1, 0, 1, 1);
        box_grid.attach (device_label, 1, 1, 1, 1);
        box_grid.attach (filename_label, 1, 2, 1, 1);
        box_grid.attach (size_label, 1, 3, 1, 1);

        get_content_area ().add (box_grid);

        add_button ("Cancel", Gtk.ResponseType.CANCEL);
        var suggested_button = add_button ("Accept", Gtk.ResponseType.ACCEPT);
        suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
    }

    public void update_device (string label) {
        device_label.set_markup (_("<b>%s</b> is ready to send").printf (GLib.Markup.escape_text (label)));
    }
    public void update_filename (string filename) {
        filename_label.set_markup (_("<b>Filename:</b> %s").printf (GLib.Markup.escape_text (filename)));
    }
    public void update_size (uint64 size) {
        size_label.label = _("<b>Size:</b> %s").printf (GLib.format_size (size));
    }
    public void update_icon (string deviceicon) {
        status_image.set_from_gicon (new ThemedIcon (deviceicon == null? "bluetooth" : deviceicon), Gtk.IconSize.LARGE_TOOLBAR);
    }
}
