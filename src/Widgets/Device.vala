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
 
public class Bluetooth.Widgets.Device : Wingpanel.Widgets.Container {
	public signal void show_device (Bluetooth.Services.Device device);

	public Bluetooth.Services.Device device;
	private Gtk.Button state_button;

	public Device (string device_path) {
		device = new Bluetooth.Services.Device (device_path);
		
		build_ui ();
		connect_signals ();
	}
	
	private void build_ui () {
		var label = new Gtk.Label (device.get_name () + "Test");
		get_content_widget ().add (label);
	}
	
	private void connect_signals () {
		this.clicked.connect (() => {
			debug ("device cliked");
			show_device (this.device);
		});
	}
}
