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
 
[DBus (name = "org.bluez.Adapter")]
interface AdapterInterface : Object {
	public signal void DeviceDisappeared (string object_path);
	public signal void DeviceFound (string object_path, HashTable<string,GLib.Variant> table);
	public signal void PropertyChanged (string property, GLib.Variant value);

	public abstract HashTable<string,GLib.Variant> GetProperties () throws IOError;
	public abstract string[] ListDevices () throws IOError;
	public abstract void SetProperty (string name, GLib.Variant value) throws IOError;
	public abstract void StartDiscovery () throws IOError;
	public abstract void StopDiscovery () throws IOError;
}

public class Bluetooth.Services.Adapter : GLib.Object {
	public signal void device_found (string object_path);   //External device's Adreess
	public signal void device_disapeared ();
	public signal void device_removed ();
	public signal void name_changed (string name);  		// Triggered when the current adapter's name changes
	public signal void state_changed (bool state);  		// Triggered when the adapter's state changes
	public signal void discovery_changed (bool state);		// Triggered when searchinng for devices
	public signal void discoverable_changed (bool state);	// Triggered when the adapter's discoverablility changes
	public signal void devices_changed ();

	private const string INTERFACE = "org.bluez";
	
	private AdapterInterface? adapter = null;
	private HashTable<string,GLib.Variant> properties;

	public Adapter (string adapter_address) {
		try {
			adapter = Bus.get_proxy_sync (BusType.SYSTEM, INTERFACE, adapter_address, DBusProxyFlags.NONE);
			properties = adapter.GetProperties ();

			debug ("Connection to bluetooth adapter established: %s\n", adapter_address);

		} catch (Error e) {
			debug ("Connecting to bluetooth adapter failed: %s \n", e.message);
		}

		connections ();
	}

	private void connections () {
		adapter.PropertyChanged.connect ((property, value) => {
			try {
				properties = adapter.GetProperties ();
			} catch (Error e) {

			}

			debug (@"Bluetooth property $property changed\n");
			switch (property) {
				case "Name": // Adapter's name
					name_changed (value.get_string ());
					break;
				case "Powered": // Adapter's state
					state_changed (value.get_boolean ());
					break;
				case "Devices": // Registered Devices
					devices_changed ();
					break;
				case "Discoverable":
					discoverable_changed (value.get_boolean ());
					break;
			}
		});

		adapter.DeviceFound.connect ((name, table) => {
			debug (@"Bluetooth Device found $name\n");
			device_found (name);
		});

		adapter.DeviceDisappeared.connect (() => {});
	}

	private new void set_property (string name, GLib.Variant value) {
		try {
			adapter.SetProperty (name, value);
		} catch (Error e) {
			critical ("Setting %s failed: %s", name, e.message);
		}
	}

	public void set_name (string value) {
		set_property ("Name", value);
	}

	public string get_name () {
		return properties.get ("Name").get_string ();
	}

	public void set_state (bool value) {
		set_property ("Powered", new Variant.boolean (value));
	}

	public bool get_state () {
		return properties.get ("Powered").get_boolean ();
	}

	public void set_discoverable (bool value) {
		set_property ("Discoverable", value);
	}

	public bool get_discoverable () {
		return properties.get ("Discoverable").get_boolean ();
	}

	public string[] list_devices () {
		return adapter.ListDevices ();
	}
		
	public void stop_discovery () {
		try {
			adapter.StopDiscovery ();
		} catch (Error e) {
			
		}
	}

	public void start_discovery () {
		try {
			adapter.StartDiscovery ();
			debug ("Discovery started\n");
		} catch (Error e) {
			stderr.printf ("Discovery Failed: %s\n", e.message);
		}
	}
}
