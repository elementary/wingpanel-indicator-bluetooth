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

[DBus (name = "io.elementary.bluetooth.rfkill")]
public class BluetoothIndicator.Services.Rfkill : GLib.Object {
    public RFKillManager rfkill;
    public bool software_locked {get; private set; default = false; }
    public bool hardware_locked {get; private set; default = false; }

    public Rfkill () {
        rfkill = new RFKillManager ();
        rfkill.open ();
        rfkill.device_added.connect (()=>{ try { load_rfkill (); } catch (Error e) { error (e.message); } });
        rfkill.device_deleted.connect (()=>{ try { load_rfkill (); } catch (Error e) { error (e.message); } });
        rfkill.device_changed.connect (()=>{ try { load_rfkill (); } catch (Error e) { error (e.message); } });

	    Bus.own_name (
            BusType.SESSION,
            "io.elementary.bluetooth.rfkill",
            GLib.BusNameOwnerFlags.NONE,
            (conn)=>{
                try {
                    conn.register_object ("/io/elementary/bluetooth/rfkill", this);
                } catch (Error e) {
                    error (e.message);
                }
            }
        );
    }

    public void load_rfkill () throws GLib.Error {
        foreach (var device in rfkill.get_devices ()) {
            if (device.device_type != RFKillDeviceType.BLUETOOTH) {
                continue;
            }
            software_locked = device.software_lock;
            hardware_locked = device.hardware_lock;
        }
    }

    public void bluetooth_airplane_mode (bool state) throws GLib.Error {
        load_rfkill ();
        if (software_locked == state) {
            rfkill.set_software_lock (RFKillDeviceType.BLUETOOTH, !state);
        }
    }
}
