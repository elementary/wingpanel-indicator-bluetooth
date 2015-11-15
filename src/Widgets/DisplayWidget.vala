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

public class Bluetooth.Widgets.DisplayWidget : Gtk.Image {
    public DisplayWidget () {
        icon_size = Gtk.IconSize.LARGE_TOOLBAR;
        set_icon (object_manager.get_global_state (), object_manager.get_connected ());

        object_manager.global_state_changed.connect ((state, connected) => {
            set_icon (state, connected);
        });

        button_press_event.connect ((e) => {
            if (e.button == Gdk.BUTTON_MIDDLE) {
                object_manager.set_global_state (!object_manager.get_global_state ());
                return Gdk.EVENT_STOP;
            }

            return Gdk.EVENT_PROPAGATE;
        });
    }

    private void set_icon (bool state, bool connected) {
        if (state) {
            if (connected) {
                icon_name = "bluetooth-paired-symbolic";
            } else {
                icon_name = "bluetooth-active-symbolic";
            }
        } else {
            icon_name = "bluetooth-disabled-symbolic";
        }
    }
}
