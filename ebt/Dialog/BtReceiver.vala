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

public class BtReceiver : Granite.Dialog {
    public Bluetooth.Obex.Transfer transfer;
    private Gtk.ProgressBar progressbar;
    private Gtk.Label device_label;
    private Gtk.Label directory_label;
    private Gtk.Label progress_label;
    private Gtk.Label filename_label;
    private Gtk.Label rate_label;
    private Gtk.Image device_image;
    private GLib.Notification notification;
    private string path_folder = "";
    public string session {get; set;}
    private int start_time = 0;
    private uint64 total_size = 0;

    public BtReceiver (Gtk.Application application) {
        Object (application: application,
                resizable :false
        );
    }

    construct {
        notification = new GLib.Notification ("bluetooth");
        notification.set_priority (NotificationPriority.NORMAL);

        var icon_image = new Gtk.Image.from_icon_name ("bluetooth", Gtk.IconSize.DIALOG) {
            valign = Gtk.Align.END,
            halign = Gtk.Align.END
        };

        device_image = new Gtk.Image () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.END
        };

        var overlay = new Gtk.Overlay ();
        overlay.add (icon_image);
        overlay.add_overlay (device_image);

        device_label = new Gtk.Label (null) {
            max_width_chars = 45,
            use_markup = true,
            wrap = true,
            xalign = 0
        };
        device_label.get_style_context ().add_class ("primary");

        directory_label = new Gtk.Label (null) {
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
        rate_label = new Gtk.Label (_("<b>Transfer rate:</b>")) {
            max_width_chars = 45,
            use_markup = true,
            wrap = true,
            xalign = 0
        };
        progressbar = new Gtk.ProgressBar () {
            hexpand = true
        };
        progress_label = new Gtk.Label (null) {
            max_width_chars = 45,
            hexpand = false,
            wrap = true,
            xalign = 0
        };
        var message_grid = new Gtk.Grid () {
            column_spacing = 0,
            width_request = 450,
            margin_end = 15,
            margin_start = 10
        };
        message_grid.attach (overlay, 0, 0, 1, 3);
        message_grid.attach (device_label, 1, 0, 1, 1);
        message_grid.attach (directory_label, 1, 1, 1, 1);
        message_grid.attach (filename_label, 1, 2, 1, 1);
        message_grid.attach (rate_label, 1, 3, 1, 1);
        message_grid.attach (progressbar, 1, 4, 1, 1);
        message_grid.attach (progress_label, 1, 5, 1, 1);
        get_content_area ().add (message_grid);

        add_button ("Close", Gtk.ResponseType.CLOSE);
        var suggested_button = add_button ("Reject", Gtk.ResponseType.ACCEPT);
        suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.ACCEPT) {
                try {
                    transfer.cancel ();
                } catch (Error e) {
                    GLib.warning (e.message);
                }
                destroy ();
            } else {
                hide_on_delete ();
            }
        });
        delete_event.connect (() => {
            if (transfer.status == "active") {
                return hide_on_delete ();
            } else {
                return false;
            }
        });
    }

    public void set_tranfer (string devicename, string deviceicon, string objectpath) {
        device_label.set_markup (_("<b>From</b>: %s").printf (GLib.Markup.escape_text (devicename)));
        directory_label.label = _("<b>To</b>: %s").printf (GLib.Environment.get_user_special_dir (UserDirectory.DOWNLOAD));
        device_image.set_from_gicon (new ThemedIcon (deviceicon == null? "bluetooth" : deviceicon), Gtk.IconSize.LARGE_TOOLBAR);
        start_time = (int) get_real_time ();
        try {
            transfer = Bus.get_proxy_sync (BusType.SESSION, "org.bluez.obex", objectpath);
            ((DBusProxy) transfer).g_properties_changed.connect ((changed, invalid) => {
                tranfer_progress ();
            });
            total_size = transfer.size;
            session = transfer.session;
            filename_label.set_markup (_("<b>Filename</b>: %s").printf (GLib.Markup.escape_text (transfer.name)));
        } catch (Error e) {
            GLib.warning (e.message);
        }
    }
    private void tranfer_progress () {
        try {
            switch (transfer.status) {
                case "error":
                    notification.set_icon (device_image.gicon);
                    notification.set_title (_("File transfer failed"));
                    notification.set_body (_("%s <b>File:</b> %s not received").printf (device_label.get_label (), transfer.name));
                    ((Gtk.Window) get_toplevel ()).application.send_notification ("io.elementary.bluetooth", notification);
                    destroy ();
                    break;
                case "queued":
                    break;
                case "active":
                    var path = transfer.filename; //Filename available on active status
                    if (path != null) {
                        path_folder = path;
                    }
                    on_transfer_progress (transfer.transferred);
                    break;
                case "complete":
                    move_to_folder (path_folder);
                    destroy ();
                    break;
            }
        } catch (Error e) {
            critical (e.message);
        }
    }
    private void move_to_folder (string file) throws GLib.Error {
        var src = File.new_for_path (file);
        var dest = change_name (GLib.Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + GLib.Path.DIR_SEPARATOR_S + src.get_basename ());
        src.move (dest, FileCopyFlags.ALL_METADATA);
        notification.set_icon (device_image.gicon);
        notification.set_title (_("File transferred successfully"));
        notification.set_body (_("%s <b>Save to:</b> %s").printf (device_label.get_label (), dest.get_path ()));
        ((Gtk.Window) get_toplevel ()).application.send_notification ("io.elementary.bluetooth", notification);
    }

    private File? change_name (string uri) {
        var file_check = File.new_for_path (uri);
        if (file_check.query_exists ()) { // this used rename file if name exist but size defferent
            string without_ext;
            int last_dot = uri.last_index_of (".", 0);
            int last_slash = uri.last_index_of ("/", 0);
            if (last_dot < last_slash) {
                without_ext = uri;
            } else {
                without_ext = uri.slice (0, last_dot);
            }
            string ext_name = uri.substring (last_dot);
            string time = new GLib.DateTime.now_local ().format (" (%F %H:%M:%S)");
            return File.new_for_path (without_ext + time + ext_name);
        } else {
            return file_check;
        }
    }

    private void on_transfer_progress (uint64 transferred) {
        progress_label.label = _("Receiving…  %s of %s").printf (GLib.format_size (transferred), GLib.format_size (total_size));
        progressbar.fraction = (double) transferred / (double) total_size;
        int current_time = (int) get_real_time ();
        int elapsed_time = (current_time - start_time) / 1000000;
        if (current_time < start_time + 1000000) {
            return;
        }
        if (elapsed_time == 0) {
            return;
        }
        uint64 transfer_rate = transferred / elapsed_time;
        if (transfer_rate == 0) {
            return;
        }
        rate_label.label = _("<b>Transfer rate:</b> %s").printf (GLib.format_size (transfer_rate));
        uint64 remaining_time = (total_size - transferred) / transfer_rate;
        progress_label.label = _("%s of %s received, time remaining %s").printf (GLib.format_size (transferred), GLib.format_size (total_size), format_time ((int)remaining_time));
    }

    private string format_time (int seconds) {
        if (seconds < 0) {
            seconds = 0;
        }

        if (seconds < 60) {
            return ngettext ("%'d second", "%'d seconds", seconds).printf (seconds);
        }

        int minutes;
        if (seconds < 60 * 60) {
            minutes = (seconds + 30) / 60;
            return ngettext ("%'d minute", "%'d minutes", minutes).printf (minutes);
        }

        int hours = seconds / (60 * 60);
        if (seconds < 60 * 60 * 4) {
            minutes = (seconds - hours * 60 * 60 + 30) / 60;
            string h = ngettext ("%'u hour", "%'u hours", hours).printf (hours);
            string m = ngettext ("%'u minute", "%'u minutes", minutes).printf (minutes);
            return h.concat (", ", m);
        }

        return ngettext ("approximately %'d hour", "approximately %'d hours", hours).printf (hours);
    }
}
