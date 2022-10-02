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

public class BluetoothIndicator.Services.ObexManager : Object {
    public signal void transfer_added (string address, BluetoothIndicator.Services.Obex.Transfer transfer);
    public signal void transfer_removed (BluetoothIndicator.Services.Obex.Transfer transfer);
    public signal void transfer_active (string address);
    private GLib.DBusObjectManagerClient object_manager;

    construct {
        create_manager.begin ();
    }

    private async void create_manager () {
        try {
            object_manager = yield new GLib.DBusObjectManagerClient.for_bus.begin (
                BusType.SESSION,
                GLib.DBusObjectManagerClientFlags.NONE,
                "org.bluez.obex",
                "/",
                object_manager_proxy_get_type
            );
            object_manager.get_objects ().foreach ((object) => {
                object.get_interfaces ().foreach ((iface) => on_interface_added (object, iface));
            });
            object_manager.interface_added.connect (on_interface_added);
            object_manager.interface_removed.connect (on_interface_removed);
            object_manager.object_added.connect ((object) => {
                object.get_interfaces ().foreach ((iface) => on_interface_added (object, iface));
            });
            object_manager.object_removed.connect ((object) => {
                object.get_interfaces ().foreach ((iface) => on_interface_removed (object, iface));
            });
        } catch (Error e) {
            critical (e.message);
        }
    }

    //TODO: Do not rely on this when it is possible to do it natively in Vala
    [CCode (cname="bluetooth_indicator_services_obex_transfer_proxy_get_type")]
    extern static GLib.Type get_obex_transfer_proxy_type ();

    private GLib.Type object_manager_proxy_get_type (DBusObjectManagerClient manager, string object_path, string? interface_name) {
        if (interface_name == null)
            return typeof (GLib.DBusObjectProxy);

        switch (interface_name) {
            case "org.bluez.obex.Transfer1":
                return get_obex_transfer_proxy_type ();
            default:
                return typeof (GLib.DBusProxy);
        }
    }

    private void on_interface_added (GLib.DBusObject object, GLib.DBusInterface iface) {
        if (iface is BluetoothIndicator.Services.Obex.Transfer) {
            unowned BluetoothIndicator.Services.Obex.Transfer transfer = (BluetoothIndicator.Services.Obex.Transfer) iface;
            BluetoothIndicator.Services.Obex.Session session = null;
            try {
                session = Bus.get_proxy_sync (BusType.SESSION, "org.bluez.obex", transfer.session);
            } catch (Error e) {
                critical (e.message);
            }

            transfer_added (session.destination, transfer);
            ((DBusProxy) transfer).g_properties_changed.connect ((changed, invalid) => {
                transfer_active (session.destination);
            });
        }
    }

    private void on_interface_removed (GLib.DBusObject object, GLib.DBusInterface iface) {
         if (iface is BluetoothIndicator.Services.Obex.Transfer) {
            transfer_removed ((BluetoothIndicator.Services.Obex.Transfer) iface);
        }
    }
}
