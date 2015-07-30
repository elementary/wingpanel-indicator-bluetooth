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

[DBus (name = "org.bluez.Device")]
interface DeviceInterface : Object {
	public signal void DisconnectRequested ();
	public signal void PropertyChanged (string property, GLib.Variant value);

	public abstract HashTable<string,GLib.Variant> GetProperties () throws IOError;
	public abstract void CancelDiscovery () throws IOError;
	public abstract void Disconnect () throws IOError;
}

[DBus (name = "org.bluez.Audio")]
interface AudioInterface : Object {
	public signal void PropertyChanged (string property, GLib.Variant value);
	
	public abstract void Connect () throws IOError;
	public abstract void Disconnect () throws IOError;
	public abstract HashTable<string,GLib.Variant> GetProperties () throws IOError;
}



public class Bluetooth.Services.Device : GLib.Object {
	private const string INTERFACE = "org.bluez";
	
	private DeviceInterface device;
	private AudioInterface audio;
	
	private HashTable<string,GLib.Variant> properties;
	
	public Device (string device_path) { //Ex:  /org/bluez/1007/hci0/dev_00_0C_8A_7C_F4_8A
		try {
			device = Bus.get_proxy_sync (BusType.SYSTEM, INTERFACE, device_path, DBusProxyFlags.NONE);
			properties = device.GetProperties ();


			debug ("Connection to bluetooth device established: %s\n", device_path);

		} catch (Error e) {
			debug ("Connecting to bluetooth adapter failed: %s \n", e.message);
		}
		
		connections ();
	}
	
	private void connections () {
		device.PropertyChanged.connect ((property, value) => {
			try {
				properties = device.GetProperties ();
			} catch (Error e) {

			}

			debug (@"Bluetooth property $property changed\n");
		});
	}
	
	public string get_name () {
		return properties.get ("Name").get_string ();
	}
	
	public bool get_paired () {
		return properties.get ("Paired").get_boolean ();
	}
	
	public string get_icon () {
		return properties.get ("Icon").get_string ();
	}
}
