import std.stdio;
import std.format;
import std.socket : InternetAddress, Socket, SocketException, SocketSet, 
       ProtocolType, SocketType, AddressFamily, SocketOption, SocketOptionLevel, getAddress;
import std.array : join, split;
import std.datetime;
import std.typecons;
import std.conv : to;
import std.regex;


string SSDP_ALL = "ssdp:all";
string UPNP_ROOT = "upnp:rootdevice";

string DIAL = "urn:dial-multiscreen-org:service:dial:1";


string [] discover(string st, int timeout=1, int retries=1) {

    string ip = "239.255.255.250";
    ushort port = 1900;
    
    string [] udnp_res;

    string message = [
        "M-SEARCH * HTTP/1.1",
        format("HOST: %s:%s", ip, port),
        "MAN: \"ssdp:discover\"",
        "MX: 3",
        format("ST: %s", st),
        "",""].join("\r\n");

    for (int i=0; i<retries; i++) {
        Socket sock = new Socket(AddressFamily.INET, SocketType.DGRAM, ProtocolType.UDP);
        scope(exit) sock.close();

        sock.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, 1);
        //sock.setOption(SocketOptionLevel.IPV6, SocketOption.IPV6_MULTICAST_HOPS, 2);
        sock.setOption(SocketOptionLevel.SOCKET, SocketOption.RCVTIMEO, dur!"seconds"(timeout));
        writeln(message);
        sock.sendTo(message, getAddress(ip, port)[0]);

        writeln("Waiting for response...");
        
        char [512] buf = "";

        while (true) {
            if (sock.receive(buf) == Socket.ERROR)
                break;
            udnp_res ~= buf.idup;
        }
    }
    
    return udnp_res;
}

struct Device {
    string location;
    string name;
}

Device [] get_devices(string [] udnp_res) {
    Device [] devices = [];

    foreach (res; udnp_res) {
        auto lines =  res.split("\r\n");
        Device cur;
        debug {
            writeln(lines);
        }
        foreach (line; lines) {
            if (canFind(line, ""
        }
    }

    return devices;
}

void main() {
    auto udnp_res = discover(DIAL, 3);
    debug {
        writeln(udnp_res);
    }
    get_devices(udnp_res);
}
