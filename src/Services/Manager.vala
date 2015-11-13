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

[DBus (name = "org.freedesktop.DBus.ObjectManager")]
public interface Bluetooth.Services.DBusInterface : Object {
    public signal void interfaces_added (ObjectPath object_path, HashTable<string, HashTable<string, Variant>> param);
    public signal void interfaces_removed (ObjectPath object_path, string[] string_array);

    public abstract HashTable<ObjectPath, HashTable<string, HashTable<string, Variant>>> get_managed_objects () throws IOError;
}

public class Bluetooth.Services.ObjectManager : Object {
    public signal void global_state_changed (bool enabled);
    public signal void adapter_added (Bluetooth.Services.Adapter adapter);
    public signal void adapter_removed (Bluetooth.Services.Adapter adapter);
    public signal void device_added (Bluetooth.Services.Device adapter);
    public signal void device_removed (Bluetooth.Services.Device adapter);

    public bool has_object {
        get {
            return !adapters.is_empty;
        }
    }

    private Bluetooth.Services.DBusInterface object_interface;
    private Gee.HashMap<string, Bluetooth.Services.Adapter> adapters;
    private Gee.LinkedList<Bluetooth.Services.Device> devices;
    public ObjectManager () {
        adapters = new Gee.HashMap<string, Bluetooth.Services.Adapter> (null, null);
        devices = new Gee.LinkedList<Bluetooth.Services.Device> ();
        try {
            object_interface = Bus.get_proxy_sync (BusType.SYSTEM, "org.bluez", "/", DBusProxyFlags.NONE);
            var objects = object_interface.get_managed_objects ();
            objects.foreach ((path, param) => {add_path (path, param);});
            object_interface.interfaces_added.connect ((path, param) => {add_path (path, param);});
            object_interface.interfaces_removed.connect ((path, array) => {});
        } catch (Error e) {
            critical (e.message);
        }
    }

    private void add_path (ObjectPath path, HashTable<string, HashTable<string, Variant>> param) {
        if ("org.bluez.Adapter1" in param) {
            try {
                Bluetooth.Services.Adapter adapter = Bus.get_proxy_sync (BusType.SYSTEM, "org.bluez", path, DBusProxyFlags.NONE);
                adapters.set (path, adapter);
                adapter_added (adapter);
            } catch (Error e) {
                debug ("Connecting to bluetooth adapter failed: %s", e.message);
            }
        } else if ("org.bluez.Device1" in param) {
            try {
                Bluetooth.Services.Device device = Bus.get_proxy_sync (BusType.SYSTEM, "org.bluez", path, DBusProxyFlags.NONE);
                devices.add (device);
                device_added (device);
            } catch (Error e) {
                debug ("Connecting to bluetooth device failed: %s", e.message);
            }
        }
    }

    public Gee.Collection<Bluetooth.Services.Adapter> get_adapters () {
        return adapters.values;
    }

    public Gee.Collection<Bluetooth.Services.Device> get_devices () {
        return devices.read_only_view;
    }

    public Bluetooth.Services.Adapter? get_adapter_from_path (string path) {
        return adapters.get (path);
    }

    public bool get_global_state () {
        foreach (var adapter in adapters.values) {
            if (adapter.powered) {
                return true;
            }
        }

        return false;
    }

    public void set_global_state (bool state) {
        foreach (var adapter in adapters.values) {
            adapter.powered = state;
        }
    }
}
