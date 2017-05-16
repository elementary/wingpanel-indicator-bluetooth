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

public class Bluetooth.Widgets.PopoverWidget : Gtk.Stack {
    public signal void request_close ();
    private Bluetooth.Widgets.MainView main_view;
    private Bluetooth.Widgets.DiscoveryView discovery_view;

    public PopoverWidget (BluetoothIndicator.Services.ObjectManager object_manager, bool is_in_session) {
        transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        main_view = new Bluetooth.Widgets.MainView (object_manager, is_in_session);
        discovery_view = new Bluetooth.Widgets.DiscoveryView (object_manager);

        add (main_view);
        add (discovery_view);

        main_view.discovery_requested.connect (() => {
            discovery_view.start_discovery ();
            set_visible_child (discovery_view);
        });

        main_view.request_close.connect (() => {
            request_close ();
        });

        discovery_view.back_button.clicked.connect (() => {
            set_visible_child (main_view);
        });
    }
}
