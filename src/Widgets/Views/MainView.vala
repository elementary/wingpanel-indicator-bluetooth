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

public class Bluetooth.Widgets.MainView : Gtk.Box {
	public signal void request_close ();
	public signal void device_requested (Bluetooth.Services.Device device);
	public signal void discovery_requested ();
	
	private const string SETTINGS_EXEC = "/usr/bin/switchboard bluetooth";

	private Wingpanel.Widgets.Button show_settings_button;
	private Wingpanel.Widgets.Button discovery_button;
	private Wingpanel.Widgets.Switch main_switch;
	private Gtk.Box devices_box;
	
	public MainView () {
		build_ui ();
		create_devices ();
		connect_signals ();
	}

	private void build_ui () {
		main_switch = new Wingpanel.Widgets.Switch ("Bluetooth", manager.adapter.get_state ());
		show_settings_button = new Wingpanel.Widgets.Button ("Bluetooth Settings…");
		discovery_button = new Wingpanel.Widgets.Button ("Discover Devices…");
		devices_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		
		main_switch.get_style_context ().add_class ("h4");
		devices_box.set_orientation (Gtk.Orientation.VERTICAL);

		update_ui_state (manager.adapter.get_state ());		
		this.set_orientation (Gtk.Orientation.VERTICAL);
		this.add (main_switch);
		this.add (devices_box);
		this.add (new Wingpanel.Widgets.Separator ());
		this.add (discovery_button);
		this.add (show_settings_button);

		this.show_all ();
	}

	private void connect_signals () {
		main_switch.switched.connect (() => {
			manager.adapter.set_state ( main_switch.get_active ());
		});

		show_settings_button.clicked.connect (() => {
			indicator.close ();
			show_settings ();
		});
		
		discovery_button.clicked.connect (() => {
			indicator.close ();
			var cmd = new Granite.Services.SimpleCommand ("/usr/bin", "bluetooth-wizard");
			cmd.run ();
			
			//discovery_requested ();
		});
		
		//Adapter's Connections
		manager.adapter.state_changed.connect ((state) => {
			update_ui_state (state);
		});
	}

	private void update_ui_state (bool state) {
		main_switch.set_active (state);
		devices_box.set_sensitive (state);
		discovery_button.set_sensitive (state);
	}

	private void create_devices () {
		bool first_device = true;		
		foreach (var device_path in manager.adapter.list_devices ()) {
			if (first_device == true) {
				first_device = false;
				devices_box.add (new Wingpanel.Widgets.Separator ());
			}
			var device = new Bluetooth.Widgets.Device (device_path);
			devices_box.add (device);
			
			device.show_device.connect ((device_service) => {
				device_requested (device_service);
			});
		}
	}

	private void show_settings () {
		var cmd = new Granite.Services.SimpleCommand ("/usr/bin", SETTINGS_EXEC);
		cmd.run ();
	}
}
