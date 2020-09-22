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

public class BluetoothIndicator.Widgets.Device : Gtk.ListBoxRow {
    private const string DEFAULT_ICON = "bluetooth";
    public signal void show_device (BluetoothIndicator.Services.Device device);
    private string path_folder {get; private set; default = ""; }
    private int start_time {get; private set; default = 0; }
    private uint64 total_size {get; private set; default = 0; }
    public BluetoothIndicator.Services.Device device { get; construct; }
    public BluetoothIndicator.Services.ObjectManager manager { get; construct; }
    public BluetoothIndicator.Services.Obex.Transfer transfer { get; construct set; }
    private Gtk.Label status_label;
    private Gtk.Label name_label;
    private Gtk.Label progress_label;
    private Gtk.Label authorize_label;
    private Gtk.Label file_label;
    private Gtk.Image icon_image;
    private Gtk.Image status_image;
    private Gtk.Spinner spinner;
    private Gtk.Revealer action_revealer;
    private Gtk.Revealer progress_revealer;
    private Gtk.ProgressBar progressbar;

    public Device (BluetoothIndicator.Services.Device device, BluetoothIndicator.Services.ObjectManager manager) {
        Object (device: device, manager: manager);
    }

    construct {
        name_label = new Gtk.Label ("<b>%s</b>".printf (Markup.escape_text (device.name)));
        name_label.halign = Gtk.Align.START;
        name_label.valign = Gtk.Align.END;
        name_label.vexpand = true;
        name_label.use_markup = true;

        status_label = new Gtk.Label (_("Not Connected"));
        status_label.halign = Gtk.Align.START;
        status_label.valign = Gtk.Align.START;
        status_label.vexpand = true;

        spinner = new Gtk.Spinner ();
        spinner.halign = Gtk.Align.START;
        spinner.valign = Gtk.Align.START;
        spinner.hexpand = true;

        var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.VERTICAL);
        size_group.add_widget (status_label);
        size_group.add_widget (spinner);

        icon_image = new Gtk.Image.from_icon_name (device.icon == null ? DEFAULT_ICON : device.icon, Gtk.IconSize.DIALOG);

        status_image = new Gtk.Image.from_icon_name ("user-offline", Gtk.IconSize.MENU);
        status_image.halign = Gtk.Align.END;
        status_image.valign = Gtk.Align.END;

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        cancel_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        cancel_button.margin_end = 6;
        cancel_button.clicked.connect (cancel_receive);

        var accept_button = new Gtk.Button.with_label (_("Accept"));
        accept_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        accept_button.margin_start = 6;
        accept_button.clicked.connect (accept_receive);

        authorize_label = new Gtk.Label (null);
        authorize_label.halign = Gtk.Align.START;
        authorize_label.valign = Gtk.Align.END;
        authorize_label.use_markup = true;
        authorize_label.hexpand = true;

        var box_action = new Gtk.Grid ();
        box_action.orientation = Gtk.Orientation.HORIZONTAL;
        box_action.column_homogeneous = true;
        box_action.margin_start = 2;
        box_action.margin_end = 2;
        box_action.add (cancel_button);
        box_action.add (accept_button);

        var act_lab_grid = new Gtk.Grid ();
        act_lab_grid.attach (authorize_label, 0, 0);
        act_lab_grid.attach (box_action, 0, 1);

        action_revealer = new Gtk.Revealer ();
        action_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        action_revealer.margin_end = 6;
        action_revealer.margin_start = 6;
        action_revealer.add (act_lab_grid);

        progress_label = new Gtk.Label (null);
        progress_label.halign = Gtk.Align.START;
        progress_label.valign = Gtk.Align.END;
        progress_label.use_markup = true;
        progress_label.hexpand = true;

        progressbar = new Gtk.ProgressBar ();
        progressbar.hexpand = true;
        progressbar.margin_start = 3;
        progressbar.margin_end = 3;

        file_label = new Gtk.Label (null);
        file_label.ellipsize = Pango.EllipsizeMode.END;
        file_label.halign = Gtk.Align.START;
        file_label.valign = Gtk.Align.END;
        file_label.use_markup = true;
        file_label.hexpand = true;

        var pro_lab_grid = new Gtk.Grid ();
        pro_lab_grid.attach (progress_label, 0, 0);
        pro_lab_grid.attach (progressbar, 0, 1);
        pro_lab_grid.attach (file_label, 0, 2);

        progress_revealer = new Gtk.Revealer ();
        progress_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        progress_revealer.margin_start = 6;
        progress_revealer.margin_end = 6;
        progress_revealer.add (pro_lab_grid);

        var overlay = new Gtk.Overlay ();
        overlay.add (icon_image);
        overlay.add_overlay (status_image);

        var grid = new Gtk.Grid ();
        grid.column_spacing = 6;
        grid.margin_end = 6;
        grid.attach (overlay, 0, 0, 1, 2);
        grid.attach (name_label, 1, 0, 2, 1);
        grid.attach (status_label, 1, 1, 1, 1);
        grid.attach (spinner, 2, 1, 1, 1);

        var box_grid = new Gtk.Grid ();
        box_grid.attach (grid, 0, 0);
        box_grid.attach (action_revealer, 0, 1);
        box_grid.attach (progress_revealer, 0, 2);
        add (box_grid);

        (device as DBusProxy).g_properties_changed.connect (update_status);
        manager.agent_obex.authorize_cancel.connect (hide_action);
        update_status ();

        get_style_context ().add_class (Gtk.STYLE_CLASS_MENUITEM);
        selectable = false;
    }

    private void tranfer_progress () {
        try {
            switch (transfer.Status) {
                case "error":
                    hide_action ();
                    break;
                case "queued":
                    progress_revealer.reveal_child = false;
                    break;
                case "active":
                    var path = transfer.Filename; //Filename available on active status
                    if (path != null) {
                        path_folder = path;
                    }
                    on_transfer_progress (transfer.Transferred);
                    progress_revealer.reveal_child = true;
                    action_revealer.reveal_child = false;
                    break;
                case "complete":
                    move_to_folder (path_folder);
                    hide_action ();
                    break;
            }
        } catch (Error e) {
            hide_action ();
            critical (e.message);
        }
    }

    public void authorize_notify (string objectpath) {
        try {
            transfer = Bus.get_proxy_sync (BusType.SESSION, "org.bluez.obex", objectpath);
            ((DBusProxy) transfer).g_properties_changed.connect ((changed, invalid) => {
                tranfer_progress ();
            });
        } catch (Error e) {
            GLib.warning (e.message);
        }
        if (transfer.Name == null) {
            return;
        }
        total_size = transfer.Size;
        if (file_exist (transfer.Name, total_size)) {
            cancel_receive ();
            manager.send_notification.begin (
                device.icon,
                _("Rejected file"),
                _("File %s size %s already exist %s please send another file").printf (transfer.Name, GLib.format_size (total_size), device.name)
            );
            accept_receive (); //Continue recive if available 
        } else {
            file_label.label = _("File: %s").printf (transfer.Name);
            if (manager.settings.get_int ("bluetooth-accept-files") == 1) {
                action_revealer.reveal_child = true;
                authorize_label.label = _("Do you want to receive?");
                manager.send_notification.begin (
                    device.icon,
                    _("Incoming file"),
                    _("%s is ready to send %s size: %s").printf (device.name, transfer.Name, GLib.format_size (total_size))
                );
            } else {
                accept_receive ();
                manager.send_notification.begin (
                    device.icon,
                    _("Receiving file"),
                    _("%s sending file %s size: %s").printf (device.name, transfer.Name, GLib.format_size (total_size))
                );
            }
        }
    }

    private void move_to_folder (string file) throws GLib.Error {
        var src = File.new_for_path (file);
        var dest = change_name (GLib.Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + GLib.Path.DIR_SEPARATOR_S + src.get_basename ());
        src.move (dest, FileCopyFlags.ALL_METADATA);
        manager.send_notification.begin (
            device.icon,
            _("File transferred successfully "),
            _("From: %s Save to: %s").printf (device.name, dest.get_path ())
        );
    }

    private bool file_exist (string name, uint64 size) {
        var input_file = File.new_for_path (GLib.Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + GLib.Path.DIR_SEPARATOR_S + name);
        uint64 size_file = 0;
        if (input_file.query_exists ()) {
           try {
                FileInfo info = input_file.query_info ("standard::*",0);
                size_file = info.get_size ();
            } catch (Error e) {
                GLib.warning (e.message);
            }
        }
        return input_file.query_exists () && size == size_file;
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
        progressbar.fraction = (double) transferred / (double) total_size;
        progress_label.label = _("Receiving... %i% / %s").printf ((int)(progressbar.fraction * 100), GLib.format_size (total_size));
        int current_time = (int) (get_real_time ());
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
        progress_label.label = _("Receiving... %i% / %s rate %s/s").printf ((int)(progressbar.fraction * 100), GLib.format_size (total_size), GLib.format_size (transfer_rate));
    }

    public void cancel_receive () {
        try {
            manager.agent_obex.cancel ();
        } catch (Error e) {
            critical (e.message);
        }
    }
    public void accept_receive () {
        Idle.add (()=>{
            authorize_label.label = "";//nothing pango ellipsize should free label
            start_time = (int) get_real_time ();
            manager.agent_obex.loop.quit ();
            return false;
        });
    }
    public void hide_action () {
        progress_label.label = "";//nothing pango ellipsize should free label
        action_revealer.reveal_child = false;
        progress_revealer.reveal_child = false;
    }

    public async void toggle_device () {
        if (progress_revealer.child_revealed) {
            try {
                transfer.Cancel (); //cancel transfer
            } catch (Error e) {
                critical (e.message);
            }
        }
        if (spinner.active) {
            return;
        }

        spinner.active = true;
        status_image.icon_name = "user-away";
        try {
            if (!device.connected) {
                status_label.label = _("Connecting…");
                yield device.connect ();
            } else {
                status_label.label = _("Disconnecting…");
                yield device.disconnect ();
            }
        } catch (Error e) {
            critical (e.message);
            status_label.label = _("Unable to Connect");
            status_image.icon_name = "user-busy";
        }

        spinner.active = false;
    }

    private void update_status () {
        name_label.label = "<b>%s</b>".printf (Markup.escape_text (device.name));

        if (device.connected) {
            status_label.label = _("Connected");
            status_image.icon_name = "user-available";
        } else {
            status_label.label = _("Not Connected");
            status_image.icon_name = "user-offline";
        }

        icon_image.icon_name = device.icon == null ? DEFAULT_ICON : device.icon;
    }
}
