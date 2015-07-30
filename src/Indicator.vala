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

public class Bluetooth.Indicator : Wingpanel.Indicator {
	public Bluetooth.Services.Manager manager;
	private Bluetooth.Widgets.PopoverWidget popover_widget;
	private Bluetooth.Widgets.DisplayWidget dynamic_icon;

	public Indicator () {
		Object (code_name: Wingpanel.Indicator.BLUETOOTH,
				display_name: _("bluetooth"),
				description:_("The bluetooth indicator"));
				
		manager = new Bluetooth.Services.Manager ();
	}

	public override Gtk.Widget get_display_widget () {
		if (dynamic_icon == null) { 
			dynamic_icon = new Bluetooth.Widgets.DisplayWidget (manager);		
			
		}
		
		return dynamic_icon;
	}

	public override Gtk.Widget? get_widget () {
		if (popover_widget == null) {
			popover_widget = new Bluetooth.Widgets.PopoverWidget (manager);
		}
		
		this.visible = true;
		return popover_widget;
	}


	public override void opened () {
	}

	public override void closed () {
	}
}

public Wingpanel.Indicator get_indicator (Module module) {
	debug ("Activating Bluetooth Indicator");
	var indicator = new Bluetooth.Indicator ();
	return indicator;
}
