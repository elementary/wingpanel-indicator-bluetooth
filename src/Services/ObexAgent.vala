/*-
 * Copyright (c) {2020} torikulhabib (https://github.com/torikulhabib)
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

[DBus (name = "org.bluez.obex.Agent1")]
public class BluetoothIndicator.Services.Obex.Agent : GLib.Object {
    private string receive_n_reject {get; private set; default = ""; }
    public signal void authorize_notify (string address, string objectpath);
    public signal void authorize_cancel ();
    public MainLoop loop;

    public Agent () {
	    Bus.own_name (
            BusType.SESSION,
            "org.bluez.obex.Agent1",
            GLib.BusNameOwnerFlags.NONE,
            (conn)=>{
                try {
                    conn.register_object ("/org/bluez/obex/elementary", this);
                } catch (Error e) {
                    error (e.message);
                }
            }
        );
    }

    public void release () throws GLib.Error {

    }
    public string authorize_push (GLib.ObjectPath objectpath) throws GLib.Error {
        Services.Obex.Transfer transfer = Bus.get_proxy_sync (BusType.SESSION, "org.bluez.obex", objectpath);
        receive_n_reject = transfer.Name;
        Services.Obex.Session session = Bus.get_proxy_sync (BusType.SESSION, "org.bluez.obex", transfer.Session);
        loop = new MainLoop ();
        var time = new TimeoutSource.seconds (60); //time out 60 seconds
        time.set_callback (() => {
            loop.quit ();
            return false;
        });
        var timer = time.attach (loop.get_context ());
        authorize_notify (session.Destination, objectpath);
        loop.run ();
        Source.remove (timer);
        return receive_n_reject;
    }
    public void cancel () throws GLib.Error {
        receive_n_reject = "";
        loop.quit ();
        authorize_cancel ();
    }
}
