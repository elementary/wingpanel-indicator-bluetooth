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

[DBus (name = "org.bluez.Adapter1")]
public interface Bluetooth.Adapter : Object {
    public abstract void remove_device (ObjectPath device) throws Error;
    public abstract void set_discovery_filter (HashTable<string, Variant> properties) throws Error;
    public abstract async void start_discovery () throws Error;
    public abstract async void stop_discovery () throws Error;

    public abstract string[] UUIDs { owned get; }
    public abstract bool discoverable { get; set; }
    public abstract bool discovering { get; }
    public abstract bool pairable { get; set; }
    public abstract bool powered { get; set; }
    public abstract string address { owned get; }
    public abstract string alias { owned get; set; }
    public abstract string modalias { owned get; }
    public abstract string name { owned get; }
    public abstract uint @class { get; }
    public abstract uint discoverable_timeout { get; }
    public abstract uint pairable_timeout { get; }
}
