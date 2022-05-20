// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2016-2018 elementary LLC.
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
 *              Oleksandr Lynok <oleksandr.lynok@gmail.com>
 *              Torikulhabib <torik.habib@gamail.com>
 */

public class BtScan : Granite.Dialog {
    public signal void send_file (Bluetooth.Device device);
    private Gtk.ListBox list_box;
    public Bluetooth.ObjectManager manager { get; construct;}

    public BtScan (Gtk.Application application, Bluetooth.ObjectManager manager) {
        Object (application: application,
                manager: manager,
                resizable: false
        );
    }

    construct {
        var icon_image = new Gtk.Image.from_icon_name ("bluetooth", Gtk.IconSize.DIALOG) {
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER
        };

        var title_label = new Gtk.Label (_("Bluetooth File Transfer")) {
            max_width_chars = 45,
            use_markup = true,
            wrap = true,
            xalign = 0
        };
        title_label.get_style_context ().add_class ("primary");

        var info_label = new Gtk.Label (_("Select a Bluetooth Device Below to Send Files")) {
            max_width_chars = 45,
            use_markup = true,
            wrap = true,
            xalign = 0
        };

        var empty_alert = new Granite.Widgets.AlertView (
            _("No Devices Found"),
            _("Please ensure that your devices are visible and ready for pairing."),
            ""
        );
        empty_alert.show_all ();
        list_box = new Gtk.ListBox () {
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.BROWSE
        };
        list_box.set_sort_func ((Gtk.ListBoxSortFunc) compare_rows);
        list_box.set_header_func ((Gtk.ListBoxUpdateHeaderFunc) title_rows);
        list_box.set_placeholder (empty_alert);

        var scrolled = new Gtk.ScrolledWindow (null, null) {
            expand = true,
        };
        scrolled.add (list_box);

        var overlay = new Gtk.Overlay ();
        overlay.add (scrolled);

        var overlaybar = new Granite.Widgets.OverlayBar (overlay) {
            label = _("Discovering")
        };

        var frame = new Gtk.Frame (null) {
            margin_left = 10,
            margin_right = 10,
            width_request = 350,
            height_request = 350
        };
        frame.add (overlay);
        var image_label = new Gtk.Grid () {
            margin_bottom = 5
        };
        image_label.attach (icon_image, 0, 0, 1, 2);
        image_label.attach (title_label, 1, 0, 1, 1);
        image_label.attach (info_label, 1, 1, 1, 1);
        var frame_device = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            valign = Gtk.Align.CENTER
        };
        frame_device.add (image_label);
        frame_device.add (frame);
        get_content_area ().add (frame_device);

        manager.device_added.connect (add_device);
        manager.device_removed.connect (device_removed);
        manager.status_discovering.connect (() => {
            overlaybar.active = manager.check_discovering ();
        });

        add_button ("Close", Gtk.ResponseType.CLOSE);
        response.connect ((response_id) => {
            manager.stop_discovery.begin ();
            destroy ();
        });
    }
    public override void show () {
        base.show ();
        var devices = manager.get_devices ();
        foreach (var device in devices) {
            add_device (device);
        }
        manager.start_discovery.begin ();
    }

    private void add_device (Bluetooth.Device device) {
        bool device_exist = false;
        foreach (var row in list_box.get_children ()) {
            if (((DeviceRow) row).device == device) {
                device_exist = true;
            }
        }
        if (device_exist) {
            return;
        }
        var row = new DeviceRow (device, manager.get_adapter_from_path (device.adapter));
        list_box.add (row);
        if (list_box.get_selected_row () == null) {
            list_box.select_row (row);
            list_box.row_activated (row);
        }
        row.send_file.connect ((device)=> {
            manager.stop_discovery.begin ();
            send_file (device);
        });
    }

    public void device_removed (Bluetooth.Device device) {
        foreach (var row in list_box.get_children ()) {
            if (((DeviceRow) row).device == device) {
                list_box.remove (row);
                break;
            }
        }
    }
    [CCode (instance_pos = -1)]
    private int compare_rows (DeviceRow row1, DeviceRow row2) {
        unowned Bluetooth.Device device1 = row1.device;
        unowned Bluetooth.Device device2 = row2.device;
        if (device1.paired && !device2.paired) {
            return -1;
        }

        if (!device1.paired && device2.paired) {
            return 1;
        }

        if (device1.connected && !device2.connected) {
            return -1;
        }

        if (!device1.connected && device2.connected) {
            return 1;
        }

        if (device1.name != null && device2.name == null) {
            return -1;
        }

        if (device1.name == null && device2.name != null) {
            return 1;
        }

        var name1 = device1.name ?? device1.address;
        var name2 = device2.name ?? device2.address;
        return name1.collate (name2);
    }
    [CCode (instance_pos = -1)]
    private void title_rows (DeviceRow row1, DeviceRow? row2) {
        if (row2 == null) {
            var label = new Gtk.Label (_("Available Devices"));
            label.xalign = 0;
            label.margin = 3;
            label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            row1.set_header (label);
        } else {
            row1.set_header (null);
        }
    }
}
