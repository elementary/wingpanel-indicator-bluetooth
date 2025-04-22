/*-
 * Copyright (c) 2015-2021 elementary LLC. (https://elementary.io)
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

public class BluetoothIndicator.Widgets.DisplayWidget : Gtk.Spinner {
    public BluetoothIndicator.Services.ObjectManager object_manager { get; construct; }

    private unowned Gtk.StyleContext style_context;

    public DisplayWidget (BluetoothIndicator.Services.ObjectManager object_manager) {
        Object (object_manager: object_manager);
    }

    construct {
        // Prevent a race that skips automatic resource loading
        // https://github.com/elementary/wingpanel-indicator-bluetooth/issues/203
        Gtk.IconTheme.get_for_display (Gdk.Display.get_default ()).add_resource_path ("/org/elementary/wingpanel/icons");

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("io/elementary/wingpanel/bluetooth/indicator.css");

        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        add_css_class ("bluetooth-icon");
        add_css_class ("disabled");

        object_manager.global_state_changed.connect ((state, connected) => {
            set_icon ();
        });

        if (object_manager.has_object && object_manager.retrieve_finished) {
            set_icon ();
        } else {
            object_manager.notify["retrieve-finished"].connect (set_icon);
        }

        var gesture_click = new Gtk.GestureClick () {
            button = Gdk.BUTTON_MIDDLE
        };
        gesture_click.pressed.connect (() => {
            object_manager.settings.set_boolean (
                "bluetooth-enabled",
                !object_manager.settings.get_boolean ("bluetooth-enabled")
            );
        });

        add_controller (gesture_click);
    }

    private void set_icon () {
        if (get_realized ()) {
            update_icon ();
        } else {
            /* When called from constructor usually not realized */
            realize.connect_after (update_icon);
        }
    }

    private void update_icon () {
        var state = object_manager.is_powered;
        var connected = object_manager.is_connected;
        string description;
        string context;

        if (state) {
            style_context.remove_class ("disabled");
            context = _("Middle-click to turn Bluetooth off");
            if (connected) {
                add_css_class ("paired");
                description = _("Bluetooth connected");
            } else {
                style_context.remove_class ("paired");
                description = _("Bluetooth is on");
            }
        } else {
            style_context.remove_class ("paired");
            add_css_class ("disabled");
            description = _("Bluetooth is off");
            context = _("Middle-click to turn Bluetooth on");
        }

        tooltip_markup = "%s\n%s".printf (
            description, Granite.TOOLTIP_SECONDARY_TEXT_MARKUP.printf (context)
        );
    }
}
