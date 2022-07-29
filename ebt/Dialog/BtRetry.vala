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

public class BtRetry : Granite.Dialog {
    private Gtk.Label device_label;
    private Gtk.Label filename_label;
    private Gtk.Label result_label;

    public BtRetry (Gtk.Widget widget) {
        Object (transient_for: (Gtk.Window) widget.get_toplevel (),
                destroy_with_parent: true,
                resizable : false
        );
    }

    construct {
        var icon_image = new Gtk.Image.from_icon_name ("process-error", Gtk.IconSize.DIALOG) {
            valign = Gtk.Align.END,
            halign = Gtk.Align.END
        };

        var status_image = new Gtk.Image () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.END
        };
        status_image.set_from_gicon (new ThemedIcon ("bluetooth"), Gtk.IconSize.LARGE_TOOLBAR);

        var overlay = new Gtk.Overlay ();
        overlay.add (icon_image);
        overlay.add_overlay (status_image);

        var warning_label = new Gtk.Label (_("File transfer failed or was declined")) {
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
        result_label = new Gtk.Label (null) {
            max_width_chars = 45,
            use_markup = true,
            wrap = true,
            xalign = 0
        };
        var box_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            margin_end = 15,
            margin_start = 10,
            width_request = 400
        };
        box_grid.attach (overlay, 0, 0, 1, 3);
        box_grid.attach (warning_label, 1, 0, 1, 1);
        box_grid.attach (device_label, 1, 1, 1, 1);
        box_grid.attach (filename_label, 1, 2, 1, 1);
        box_grid.attach (result_label, 1, 3, 1, 1);

        get_content_area ().add (box_grid);

        add_button ("Cancel", Gtk.ResponseType.CANCEL);
        var suggested_button = add_button ("Retry", Gtk.ResponseType.ACCEPT);
        suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
    }

    public void update_device (string label) {
        device_label.set_markup (_("<b>Send to:</b> %s").printf (GLib.Markup.escape_text (label)));
    }
    public void update_filename (string filename) {
        filename_label.set_markup (_("<b>Filename:</b> %s").printf (GLib.Markup.escape_text (filename)));
    }
    public void update_result (string result) {
        result_label.set_markup (_("<b>Result:</b> File not send to %s").printf (GLib.Markup.escape_text (result)));
    }
}
