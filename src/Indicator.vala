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

namespace Bluetooth {
    public static Bluetooth.Services.ObjectManager object_manager;
    public static Bluetooth.Indicator indicator;
}

public class Bluetooth.Indicator : Wingpanel.Indicator {
    private bool is_in_session = false;
    private Bluetooth.Widgets.PopoverWidget popover_widget;
    private Bluetooth.Widgets.DisplayWidget dynamic_icon;
    public Indicator (bool is_in_session) {
        Object (code_name: Wingpanel.Indicator.BLUETOOTH,
                display_name: _("bluetooth"),
                description:_("The bluetooth indicator"));
        object_manager = new Services.ObjectManager ();
        this.visible = object_manager.has_object;
        object_manager.adapter_added.connect (() => {
            visible = object_manager.has_object;
        });

        object_manager.adapter_removed.connect (() => {
            visible = object_manager.has_object;
        });

        this.is_in_session = is_in_session;

        debug ("Bluetooth Indicator started");
    }

    public override Gtk.Widget get_display_widget () {
        if (dynamic_icon == null) { 
            dynamic_icon = new Bluetooth.Widgets.DisplayWidget ();
        }

        return dynamic_icon;
    }

    public override Gtk.Widget? get_widget () {
        if (object_manager.has_object == false) {
            return null;
        }

        if (popover_widget == null) {
            popover_widget = new Bluetooth.Widgets.PopoverWidget (is_in_session);
            popover_widget.request_close.connect (() => {
                close ();
            });
        }

        return popover_widget;
    }


    public override void opened () {
    }

    public override void closed () {
    }
}

public Wingpanel.Indicator get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Bluetooth Indicator");
    if (Bluetooth.indicator == null) {
        Bluetooth.indicator = new Bluetooth.Indicator (server_type == Wingpanel.IndicatorManager.ServerType.SESSION);
    }

    return Bluetooth.indicator;
}
