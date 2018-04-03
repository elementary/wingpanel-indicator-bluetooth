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

public class BluetoothIndicator.Widgets.DisplayWidget : Gtk.Spinner {
    private Gtk.StyleContext style_context;

    public BluetoothIndicator.Services.ObjectManager object_manager { get; construct; }

    public DisplayWidget (BluetoothIndicator.Services.ObjectManager object_manager) {
        Object (object_manager: object_manager);
    }

    construct {
        set_icon (object_manager.get_global_state (), object_manager.get_connected ());

        object_manager.global_state_changed.connect ((state, connected) => {
            set_icon (state, connected);
        });

        button_press_event.connect ((e) => {
            if (e.button == Gdk.BUTTON_MIDDLE) {
                object_manager.set_global_state.begin (!object_manager.get_global_state ());
                return Gdk.EVENT_STOP;
            }

            return Gdk.EVENT_PROPAGATE;
        });

        style_context = get_style_context ();
        style_context.add_class ("bluetooth-icon");

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("io/elementary/wingpanel/bluetooth/indicator.css");
        style_context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    private void set_icon (bool state, bool connected) {
        if (state) {
            style_context.remove_class ("disabled");
            if (connected) {
                style_context.add_class ("paired");
            } else {
                style_context.remove_class ("paired");
            }
        } else {
            style_context.remove_class ("paired");
            style_context.add_class ("disabled");
        }
    }
}
