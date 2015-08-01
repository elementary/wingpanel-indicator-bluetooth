[DBus (name = "org.bluez.Manager")]
interface ManagerInterface : Object {
	public signal void AdapterAdded (string object_path);
	public signal void AdapterRemoved (string object_path);
	public signal void DefaultAdapterChanged (string object_path);

	public abstract string DefaultAdapter () throws IOError;
}

public class Bluetooth.Services.Manager : GLib.Object {
	public bool has_adapter = true;

	ManagerInterface manager =  null;

	public Bluetooth.Services.Adapter adapter = null;

	public Manager () {
		try {
			manager = Bus.get_proxy_sync (BusType.SYSTEM, "org.bluez", "/", DBusProxyFlags.NONE);
			var address = manager.DefaultAdapter ();
			
			if (address != null) {
				adapter = new Bluetooth.Services.Adapter (address);
			}else {
				has_adapter = false;
			}
			 		
		} catch (Error e) {
			has_adapter = false;
			stderr.printf ("Connecting to bluetooth manager failed: %s \n", e.message);
		}
	}
}
