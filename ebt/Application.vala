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

public class BluetoothApp : Gtk.Application {
    public const OptionEntry[] OPTIONS_BLUETOOTH = {
        { "silent", 's', 0, OptionArg.NONE, out silent, "Run the Application in background", null},
        { "send", 'f', 0, OptionArg.NONE, out send, "Open file to send via bluetooth", null },
        { "", 0, 0, OptionArg.STRING_ARRAY, out arg_files, "Get files", null },
        { null }
    };

    public Bluetooth.ObjectManager object_manager;
    public Bluetooth.Obex.Agent agent_obex;
    public Bluetooth.Obex.Transfer transfer;
    public BtResponse bt_response = null;
    public BtReceiver bt_receiver;
    public BtSender bt_sender;
    public BtScan bt_scan = null;
    public GLib.List<BtReceiver> bt_receivers;
    public GLib.List<BtSender> bt_senders;
    public static bool silent;
    public static bool send;
    public static bool active_once;
    [CCode (array_length = false, array_null_terminated = true)]
    public static string[]? arg_files = {};

    construct {
        application_id = "io.elementary.bluetooth";
        flags |= ApplicationFlags.HANDLES_COMMAND_LINE;
        Intl.setlocale (LocaleCategory.ALL, "");
    }

    public override int command_line (ApplicationCommandLine command) {
        string [] args_cmd = command.get_arguments ();
        unowned string [] args = args_cmd;
        var opt_context = new OptionContext (null);
        opt_context.add_main_entries (OPTIONS_BLUETOOTH, null);
        try {
            opt_context.parse (ref args);
        } catch (Error err) {
            warning (err.message);
        }

        File [] files = null;
        foreach (unowned string arg_file in arg_files) {
            if (GLib.FileUtils.test (arg_file, GLib.FileTest.EXISTS)) {
                files += (File.new_for_path (arg_file));
            }
        }
        activate ();
        if (send) {
            if (files != null) {
                if (bt_scan == null) {
                    bt_scan = new BtScan (this, object_manager);
                    bt_scan.show_all ();
                } else {
                    bt_scan.present ();
                }
                bt_scan.destroy.connect (() => {
                    bt_scan = null;
                });
                bt_scan.send_file.connect ((device) => {
                    if (!insert_sender (files, device)) {
                        bt_sender = new BtSender (this);
                        bt_sender.add_files (files, device);
                        bt_senders.append (bt_sender);
                        bt_sender.show_all ();
                        bt_sender.destroy.connect (()=> {
                            bt_senders.foreach ((sender)=>{
                                if (sender.device == bt_sender.device) {
                                    bt_senders.remove_link (bt_senders.find (sender));
                                }
                            });
                        });
                    }
                });
                arg_files = {};
            }

            send = false;
        }

        return 0;
    }

    protected override void activate () {
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme =
            granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme =
            granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        if (silent) {
            hold ();
            bt_receivers = new GLib.List<BtReceiver> ();
            bt_senders = new GLib.List<BtSender> ();
            object_manager = new Bluetooth.ObjectManager ();
            object_manager.notify["has-object"].connect (() => {
                if (object_manager.has_object) {
                    if (!active_once) {
                        agent_obex = new Bluetooth.Obex.Agent ();
                        agent_obex.transfer_view.connect (dialog_active);
                        agent_obex.response_accepted.connect (response_accepted);
                        agent_obex.response_canceled.connect (dialog_destroy);
                        agent_obex.response_notify.connect (response_notify);
                        active_once = true;
                    }
                    create_contract ();
                } else {
                    remove_contract ();
                }
            });
            silent = false;
        }
        if (bt_response != null ) {
            bt_response.show_all ();
        }
    }

    private bool insert_sender (File[] files, Bluetooth.Device device) {
        bool exist = false;
        bt_senders.foreach ((sender)=>{
            if (sender.device == device) {
                sender.insert_files (files);
                sender.present ();
                exist = true;
            }
        });
        return exist;
    }
    private void dialog_active (string session_path) {
        bt_receivers.foreach ((reciever)=>{
            if (reciever.transfer.session == session_path) {
                reciever.show_all ();
            }
        });
        bt_senders.foreach ((sender)=>{
            if (sender.transfer.session == session_path) {
                sender.show_all ();
            }
        });
    }

    private void response_accepted (string address, GLib.ObjectPath objectpath) {
        try {
            transfer = Bus.get_proxy_sync (BusType.SESSION, "org.bluez.obex", objectpath);
        } catch (Error e) {
            GLib.warning (e.message);
        }
        if (transfer.name == null) {
            return;
        }

        dialog_destroy ();
        bt_receiver = new BtReceiver (this);
        bt_receivers.append (bt_receiver);
        bt_receiver.destroy.connect (()=> {
            bt_receivers.foreach ((receiver)=>{
                if (receiver.transfer.session == bt_receiver.session) {
                    bt_receivers.remove_link (bt_receivers.find (receiver));
                }
            });
        });
        Bluetooth.Device device = object_manager.get_device (address);
        unowned var devicename = device.name;
        unowned var deviceicon = device.icon;
        bt_receiver.set_tranfer (devicename == null? device_icon (device) : devicename, deviceicon, objectpath);
    }

    private void response_notify (string address, GLib.ObjectPath objectpath) {
        Bluetooth.Device device = object_manager.get_device (address);
        unowned var devicename = device.name;
        unowned var deviceicon = device.icon;
        try {
            transfer = Bus.get_proxy_sync (BusType.SESSION, "org.bluez.obex", objectpath);
        } catch (Error e) {
            GLib.warning (e.message);
        }
        var notification = new GLib.Notification ("bluetooth");
        notification.set_icon (new ThemedIcon (deviceicon));
        if (reject_if_exist (transfer.name, transfer.size)) {
            notification.set_title (_("Rejected file"));
            notification.set_body ( _("<b>File:</b> %s <b>Size: </b>%s already exist").printf (transfer.name, GLib.format_size (transfer.size)));
            send_notification ("io.elementary.bluetooth", notification);
            Idle.add (()=>{activate_action ("btcancel", new Variant.string ("Cancel")); return false;});
            return;
        }
        if (bt_response == null) {
            bt_response = new BtResponse (this);
        }
        bt_response.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.ACCEPT) {
                activate_action ("btaccept", new Variant.string ("Accept"));
            } else {
                activate_action ("btcancel", new Variant.string ("Cancel"));
            }
            dialog_destroy ();
        });
        bt_response.destroy.connect (() => {
            bt_response = null;
        });
        if (object_manager.settings.get_int ("bluetooth-accept-files") == 0) {
            notification.set_priority (NotificationPriority.URGENT);
            notification.set_title (_("Incoming file"));
            notification.set_body (_("<b>%s</b> is ready to send file: %s size: %s").printf (devicename == null? device_icon (device) : devicename, transfer.name, GLib.format_size (transfer.size)));
            notification.add_button (_("Accept"), GLib.Action.print_detailed_name ("app.btaccept", new Variant ("s", "Accept")));
            notification.add_button (_("Cancel"), GLib.Action.print_detailed_name ("app.btcancel", new Variant ("s", "Cancel")));
            bt_response.update_device (devicename == null? device_icon (device) : devicename);
            bt_response.update_filename (transfer.name);
            bt_response.update_size (transfer.size);
            bt_response.update_icon (deviceicon);
        } else {
            notification.set_title (_("Receiving file"));
            notification.set_body (_("%s sending file: %s size: %s").printf (devicename, transfer.name, GLib.format_size (transfer.size)));
            Idle.add (()=>{ activate_action ("btaccept", new Variant.string ("Accept")); return false;});
        }
        send_notification ("io.elementary.bluetooth", notification);
    }

    private string device_icon (Bluetooth.Device device) {
        switch (device.icon) {
            case "audio-card":
                return _("Speaker");
            case "input-gaming":
                return _("Controller");
            case "input-keyboard":
                return _("Keyboard");
            case "input-mouse":
                return _("Mouse");
            case "input-tablet":
                return _("Tablet");
            case "input-touchpad":
                return _("Touchpad");
            case "phone":
                return _("Phone");
            default:
                return device.address;
        }
    }

    private void dialog_destroy () {
        if (bt_response != null) {
            bt_response.destroy ();
        }
    }
    private bool reject_if_exist (string name, uint64 size) {
        var input_file = File.new_for_path (GLib.Environment.get_user_special_dir (UserDirectory.DOWNLOAD) + GLib.Path.DIR_SEPARATOR_S + name);
        uint64 size_file = 0;
        if (input_file.query_exists ()) {
           try {
                FileInfo info = input_file.query_info ("standard::*", 0);
                size_file = info.get_size ();
            } catch (Error e) {
                GLib.warning (e.message);
            }
        }
        return input_file.query_exists () && size == size_file;
    }
    private string contract_dir () {
        string build_path = Path.build_filename (Environment.get_home_dir (), ".local", "share", "contractor");
        if (!File.new_for_path (build_path).query_exists ()) {
            DirUtils.create (build_path, 0700);
        }
        return build_path;
    }
    private File file_contract () {
        return File.new_for_path (Path.build_filename (contract_dir (), Environment.get_application_name () + ".contract"));
    }
    private void create_contract () {
        try {
            File file = file_contract ();
            permanent_delete (file);
            FileOutputStream out_stream = file.create (FileCreateFlags.PRIVATE);
            string str_contract = "[Contractor Entry]\n";
            string str_name = _("Name=%s").printf ("Send Files via Bluetooth\n");
            string str_icon = _("Icon=bluetooth\n");
            string str_desc = _("Description=%s").printf ("Send files to device…\n");
            string str_command = "Exec=io.elementary.bluetooth -f %F \n";
            string mimetype = _("MimeType=!inode;\n");
            out_stream.write (str_contract.data);
            out_stream.write (str_name.data);
            out_stream.write (str_icon.data);
            out_stream.write (str_desc.data);
            out_stream.write (str_command.data);
            out_stream.write (mimetype.data);
        } catch (Error e) {
            warning ("Error: %s\n", e.message);
        }
    }

    private void remove_contract () {
        permanent_delete (file_contract ());
    }
    private void permanent_delete (File file) {
        try {
            if (file.query_exists ()) {
                file.delete ();
            }
        } catch (Error e) {
            warning ("Error: %s\n", e.message);
        }
    }
    public static int main (string[] args) {
        var app = new BluetoothApp ();
        return app.run (args);
    }
}
