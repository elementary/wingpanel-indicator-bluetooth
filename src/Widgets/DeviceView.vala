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

public class Bluetooth.Widgets.DeviceView : Gtk.Box {

	public Gtk.Button back_button;
	private Gtk.Label name;
	private Gtk.Label paired;
	private Gtk.Image icon;
	
	public DeviceView () {
		
		build_ui ();
	}
	
	public void refresh (Bluetooth.Services.Device device) {
		name.set_label ("<b>" + device.get_name () + "</b>");
		icon.set_from_icon_name (device.get_icon (), Gtk.IconSize.DIALOG);
		paired.set_label ("Paired: " + device.get_paired ().to_string () );
		
	}
		
	private void build_ui () {
		var back_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
		back_button = new Gtk.Button.with_label (_("Bluetooth"));
		back_button.get_style_context ().add_class ("back-button");
		back_button.set_margin_start (8);
		back_button.set_margin_top (8);
		back_button.set_margin_bottom (8);
		back_box.add (back_button);
				
		var device_grid = new Gtk.Grid ();
		icon = new Gtk.Image ();
		name = new Gtk.Label ("");
		paired = new Gtk.Label ("");
		icon.icon_size = (32);
		
		paired.get_style_context ().add_class ("h3");
		name.get_style_context ().add_class ("h3");
		name.use_markup = true;
		icon.margin = (8);
		
		
		device_grid.attach (icon, 0, 0, 2, 2);
		device_grid.attach (name, 2, 0, 1, 1);
		device_grid.attach (paired, 2, 1, 1, 1);		

		this.add (back_box);
		this.add (new Wingpanel.Widgets.Separator ());
		this.add (device_grid);
		this.add (new Wingpanel.Widgets.Separator ());
		this.add (new Wingpanel.Widgets.Switch (_("Connection:")));
		
		this.set_orientation (Gtk.Orientation.VERTICAL);	
	}
}
