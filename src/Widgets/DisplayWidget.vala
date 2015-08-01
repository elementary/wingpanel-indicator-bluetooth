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

public class Bluetooth.Widgets.DisplayWidget : Gtk.Box {
	private const string ACTIVE_ICON = "bluetooth-active-symbolic";
	private const string DISABLED_ICON = "bluetooth-disabled-symbolic";
	
	public Bluetooth.Services.Manager manager;
	private Gtk.Image image;

	public DisplayWidget (Bluetooth.Services.Manager manager) {
		Object (orientation: Gtk.Orientation.HORIZONTAL);
		this.manager = manager;		
		
		build_ui ();
		if (manager.has_adapter) {
		 	connect_signals ();
		}
	}

	private void build_ui () {
		image = new Gtk.Image ();
		
		
		this.pack_start (image);
	}
	
	private void set_icon (bool state) {
		if (state) {
			image.icon_name = ACTIVE_ICON;
		} else {
			image.icon_name = DISABLED_ICON;
		}
	}
	
	private void connect_signals () {
		set_icon (manager.adapter.get_state ());
	
		manager.adapter.state_changed.connect ((state) => {
			set_icon (state);
		});
	}
}
