/*
 * Copyright 2021 elementary, Inc. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Torikulhabib <torik.habib@gamail.com>
 *
 */

[DBus (name = "org.bluez.obex.Error")]
public errordomain BluezObexError {
    REJECTED,
    CANCELED
}

[DBus (name = "org.bluez.obex.Agent1")]
public class Bluetooth.Obex.Agent : GLib.Object {
    public signal void response_notify (string address, GLib.ObjectPath objectpath);
    public signal void response_accepted (string address, GLib.ObjectPath objectpath);
    public signal void response_canceled ();
    /*one confirmation for many files in one session */
    private GLib.ObjectPath many_files;

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

    public void release () throws GLib.Error {}

    public async string authorize_push (GLib.ObjectPath objectpath) throws Error {
        SourceFunc callback = authorize_push.callback;
        BluezObexError? btobexerror = null;
        Bluetooth.Obex.Transfer transfer = Bus.get_proxy_sync (BusType.SESSION, "org.bluez.obex", objectpath);
        if (transfer.name == null) {
            throw new BluezObexError.REJECTED ("Authorize Reject");
        }
        Bluetooth.Obex.Session session = Bus.get_proxy_sync (BusType.SESSION, "org.bluez.obex", transfer.session);
        var accept_action = new SimpleAction ("btaccept", VariantType.STRING);
        GLib.Application.get_default ().add_action (accept_action);
        accept_action.activate.connect ((parameter) => {
            response_accepted (session.destination, objectpath);
            if (callback != null) {
                Idle.add ((owned)callback);
            }
        });
        var cancel_action = new SimpleAction ("btcancel", VariantType.STRING);
        GLib.Application.get_default ().add_action (cancel_action);
        cancel_action.activate.connect ((parameter) => {
            btobexerror = new BluezObexError.CANCELED ("Authorize Cancel");
            response_canceled ();
            if (callback != null) {
                Idle.add ((owned)callback);
            }
        });
        if (many_files == objectpath) {
            Idle.add (()=>{
                response_accepted (session.destination, objectpath);
                if (callback != null) {
                    Idle.add ((owned)callback);
                }
                return false;
            });
        } else {
            response_notify (session.destination, objectpath);
        }
        yield;
        if (btobexerror != null) {
            throw btobexerror;
        }
        many_files = objectpath;
        return transfer.name;
    }

    public void cancel () throws GLib.Error {
        response_canceled ();
    }
}
