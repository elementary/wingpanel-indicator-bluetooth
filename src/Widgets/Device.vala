/*
* SPDX-License-Identifier: LGPL-2.1-or-later
* SPDX-FileCopyrightText: 2015-2025 elementary, Inc. (https://elementary.io)
*/

public class BluetoothIndicator.Widgets.Device : Gtk.ListBoxRow {
    private const string DEFAULT_ICON = "bluetooth";
    private const string OBEX_AGENT = "org.bluez.obex.Agent1";
    private const string OBEX_PATH = "/org/bluez/obex/elementary";
    public signal void show_device (BluetoothIndicator.Services.Device device);
    public BluetoothIndicator.Services.Device device { get; construct; }
    public BluetoothIndicator.Services.ObexManager obex_manager { get; construct; }
    public BluetoothIndicator.Services.Obex.Transfer transfer;
    private Gtk.Label status_label;
    private Gtk.Label name_label;
    private Gtk.Label progress_label;
    private Gtk.Label file_label;
    private Gtk.Image icon_image;
    private Gtk.Image status_image;
    private Gtk.Spinner spinner;
    private Gtk.Revealer progress_revealer;
    private Gtk.ProgressBar progressbar;

    public Device (BluetoothIndicator.Services.Device device, BluetoothIndicator.Services.ObexManager obex_manager) {
        Object (device: device,
                obex_manager: obex_manager
        );
    }

    construct {
        obex_manager.transfer_added.connect (on_obex_transfer_added);
        obex_manager.transfer_removed.connect (on_obex_transfer_removed);
        obex_manager.transfer_active.connect (on_obex_transfer_active);

        name_label = new Gtk.Label (null) {
            halign = START,
            use_markup = true,
            valign = END,
            vexpand = true
        };

        status_label = new Gtk.Label (_("Not Connected")) {
            halign = START,
            valign = START,
            vexpand = true
        };

        spinner = new Gtk.Spinner () {
            halign = START,
            valign = START,
            hexpand = true
        };

        var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.VERTICAL);
        size_group.add_widget (status_label);
        size_group.add_widget (spinner);

        icon_image = new Gtk.Image.from_icon_name (device.icon == null ? DEFAULT_ICON : device.icon, Gtk.IconSize.DIALOG) {
            pixel_size = 48
        };

        status_image = new Gtk.Image.from_icon_name ("emblem-disabled", Gtk.IconSize.MENU) {
            halign = END,
            valign = END
        };

        progress_label = new Gtk.Label (null) {
            halign = START,
            valign = END,
            use_markup = true,
            hexpand = true
        };

        progressbar = new Gtk.ProgressBar () {
            hexpand = true
        };

        file_label = new Gtk.Label (null) {
            ellipsize = Pango.EllipsizeMode.MIDDLE,
            halign = START,
            valign = END,
            use_markup = true,
            hexpand = true
        };

        var content_grid = new Gtk.Grid ();
        content_grid.attach (file_label, 0, 0);
        content_grid.attach (progressbar, 0, 1);
        content_grid.attach (progress_label, 0, 2);

        progress_revealer = new Gtk.Revealer () {
            child = content_grid,
            transition_type = SLIDE_DOWN,
            margin_start = 5,
            margin_end = 5
        };

        var overlay = new Gtk.Overlay () {
            child = icon_image
        };
        overlay.add_overlay (status_image);

        var grid = new Gtk.Grid () {
            column_spacing = 5,
            margin_end = 5
        };
        grid.attach (overlay, 0, 0, 1, 2);
        grid.attach (name_label, 1, 0, 2);
        grid.attach (status_label, 1, 1);
        grid.attach (spinner, 2, 1);

        var box_grid = new Gtk.Grid ();
        box_grid.attach (grid, 0, 0);
        box_grid.attach (progress_revealer, 0, 1);

        child = box_grid;

        ((DBusProxy) device).g_properties_changed.connect (update_status);

        update_status ();
        get_style_context ().add_class (Gtk.STYLE_CLASS_MENUITEM);
        selectable = false;
        obex_manager.active_transfers.foreach ((transfer, address)=> {
            on_obex_transfer_added (address, transfer);
        });
    }

    private void on_obex_transfer_removed (BluetoothIndicator.Services.Obex.Transfer transfer) {
        hide_action ();
    }

    private void on_obex_transfer_active (string address) {
        if (address == device.address) {
            update_transfer_progress ();
        }
    }

    private void on_obex_transfer_added (string address, BluetoothIndicator.Services.Obex.Transfer transfer) {
        if (address == device.address) {
            this.transfer = transfer;
        }
    }

    private void update_transfer_progress () {
        switch (transfer.status) {
            case "error":
                hide_action ();
                break;
            case "queued":
                hide_action ();
                break;
            case "active":
                progressbar.fraction = (double) transfer.transferred / (double) transfer.size;
                progress_revealer.reveal_child = true;
                string name = transfer.name;
                if (name != null) {
                    file_label.set_markup (_("<b>Filename</b>: %s").printf (GLib.Markup.escape_text (name)));
                }
                string filename = transfer.filename;
                if (filename != null) {
                    if (bt_status (filename)) {
                        progress_label.label = _("Receiving… %s of %s").printf (
                            format_size (transfer.transferred), format_size (transfer.size)
                        );
                    } else {
                        progress_label.label = _("Sending… %s of %s").printf (
                            format_size (transfer.transferred), format_size (transfer.size)
                        );
                    }
                }
                break;
            case "complete":
                hide_action ();
                break;
        }
    }
    private bool bt_status (string filename) {
        return filename.contains ("/.cache/obexd")? true : false;
    }
    public void hide_action () {
        progress_label.label = "";//nothing pango ellipsize should free label
        progress_revealer.reveal_child = false;
    }

    public async void toggle_device () {
        if (progress_revealer.child_revealed) {
            try {
                var connection = yield GLib.Bus.get (BusType.SESSION);
                yield connection.call (
                    OBEX_AGENT,
                    OBEX_PATH,
                    OBEX_AGENT,
                    "TransferActive",
                    new Variant ("(s)",
                    transfer.session),
                    null,
                    GLib.DBusCallFlags.NONE,
                    -1
                );
            } catch (Error e) {
                critical (e.message);
            }
            return;
        }
        if (spinner.active) {
            return;
        }

        spinner.active = true;
        status_image.icon_name = "emblem-mixed";
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
            status_image.icon_name = "emblem-error";
        }

        spinner.active = false;
    }

    private void update_status () {
        string? device_name = device.alias;
        if (device_name == null) {
            if (device.icon != null) {
                switch (device.icon) {
                    case "audio-card":
                        device_name = _("Speaker");
                        break;
                    case "audio-headphones":
                        device_name = _("Headphones");
                        break;
                    case "input-gaming":
                        device_name = _("Controller");
                        break;
                    case "input-keyboard":
                        device_name = _("Keyboard");
                        break;
                    case "input-mouse":
                        device_name = _("Mouse");
                        break;
                    case "input-tablet":
                        device_name = _("Tablet");
                        break;
                    case "input-touchpad":
                        device_name = _("Touchpad");
                        break;
                    case "phone":
                        device_name = _("Phone");
                        break;
                    default:
                        device_name = device.address;
                        break;
                }
            } else {
                device_name = device.address;
            }
        }

        name_label.label = "<b>%s</b>".printf (Markup.escape_text (device_name));

        if (device.connected) {
            status_label.label = _("Connected");
            status_image.icon_name = "emblem-enabled";
        } else {
            status_label.label = _("Not Connected");
            status_image.icon_name = "emblem-disabled";
        }

        icon_image.icon_name = device.icon == null ? DEFAULT_ICON : device.icon;
    }
}
