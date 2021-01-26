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

    public signal void device_requested (BluetoothIndicator.Services.Device device);
    private BluetoothIndicator.Services.Device paired_device;
    BluetoothIndicator.Widgets.PopoverWidget popover_widget;
    Widgets.DisplayWidget? display_widget;
    private Services.ObjectManager object_manager;

    public Indicator (bool is_in_session) {
        Object (
            code_name: Wingpanel.Indicator.BLUETOOTH,
            is_in_session: is_in_session
        );

        var settings = new Settings ("io.elementary.desktop.wingpanel.bluetooth");
        display_widget = new Widgets.DisplayWidget (object_manager);

        var state = settings.get_boolean ("bluetooth-enabled");
        update_tooltip (state, false);

        object_manager.global_state_changed.connect ((state, paired) => {
            update_tooltip (state, paired);
        });

        object_manager.device_added.connect ((device) => {
            paired_device = device;
        });
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
        return display_widget;
    }

    public override Gtk.Widget? get_widget () {
        if (popover_widget == null) {
            popover_widget = new Widgets.PopoverWidget (object_manager, is_in_session);
        }

        return popover_widget;
    }


    public override void opened () {
    }

    public override void closed () {
    }

    private void update_tooltip (bool state, bool paired) {
        string description = _("Bluetooth is off");
        string context = _("Middle-click to disable bluetooth");

        if (state && paired) {
            description = _("Bluetooth connected");
        } else if (state) {
            description = _("Bluetooth is on");
        } else {
            /* Blutetooth adapter Off */
            context = _("Middle-click to enable bluetooth");
        }

        display_widget.tooltip_markup = "%s\n%s".printf (
            description, Granite.TOOLTIP_SECONDARY_TEXT_MARKUP.printf (context)
        );
    }
}

public Wingpanel.Indicator get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Bluetooth Indicator");
    var indicator = new BluetoothIndicator.Indicator (server_type == Wingpanel.IndicatorManager.ServerType.SESSION);
    return indicator;
}
