/*-
 * Copyright (c) 2015-2018 elementary LLC. (https://elementary.io)
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

public class BluetoothIndicator.Indicator : Wingpanel.Indicator {
    public bool is_in_session { get; construct; default = false; }

    private Widgets.PopoverWidget popover_widget;
    private Widgets.DisplayWidget dynamic_icon;
    private Services.ObjectManager object_manager;

    public Indicator (bool is_in_session) {
        Object (
            code_name: Wingpanel.Indicator.BLUETOOTH,
            display_name: _("bluetooth"),
            description:_("The bluetooth indicator"),
            is_in_session: is_in_session
        );
    }

    construct {
        object_manager = new BluetoothIndicator.Services.ObjectManager ();
        object_manager.bind_property ("has-object", this, "visible", GLib.BindingFlags.SYNC_CREATE);

        if (object_manager.has_object) {
            object_manager.set_last_state.begin ();
        }

        object_manager.notify["has-object"].connect (() => {
            if (object_manager.has_object) {
                object_manager.set_last_state.begin ();
            }
        });
    }

    public override Gtk.Widget get_display_widget () {
        if (dynamic_icon == null) {
            dynamic_icon = new Widgets.DisplayWidget (object_manager);
        }

        return dynamic_icon;
    }

    public override Gtk.Widget? get_widget () {
        if (popover_widget == null) {
            popover_widget = new Widgets.PopoverWidget (object_manager, is_in_session);
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
    var indicator = new BluetoothIndicator.Indicator (server_type == Wingpanel.IndicatorManager.ServerType.SESSION);

    return indicator;
}
