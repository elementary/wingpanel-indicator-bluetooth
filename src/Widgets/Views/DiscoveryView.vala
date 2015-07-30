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

public class Bluetooth.Widgets.DiscoveryView : Gtk.Box {
// BOSE Address FF:E8:16:50:EB:0C

	public Gtk.Button back_button;
	private Gtk.Grid device_grid;
	private Bluetooth.Services.Adapter adapter;
	
	public DiscoveryView (Bluetooth.Services.Adapter adapter) {
		this.adapter = adapter;
		build_ui ();
		connections ();
	}
	
	public void start_discovery () {
		foreach (var widget in device_grid.get_children ()) {
			device_grid.remove (widget);
			widget.destroy ();
		}
		adapter.start_discovery ();
	}	
		
	private void connections () {
		adapter.device_found.connect ((address) => {
			device_grid.add (new Gtk.Label (@"Device $address"));
			device_grid.show_all ();
		});
		
		back_button.clicked.connect (() => {
			adapter.stop_discovery ();
		});
	}
	
	private void build_ui () {
		var back_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
		back_button = new Gtk.Button.with_label (_("Bluetooth"));
		back_button.get_style_context ().add_class ("back-button");
		back_button.set_margin_start (8);
		back_button.set_margin_top (8);
		back_button.set_margin_bottom (8);
		back_box.add (back_button);
				
		device_grid = new Gtk.Grid ();
		device_grid.set_orientation (Gtk.Orientation.VERTICAL);
	
		this.add (back_box);
		this.add (new Wingpanel.Widgets.Separator ());
		this.add (device_grid);
		
		this.set_orientation (Gtk.Orientation.VERTICAL);	
	}
}
