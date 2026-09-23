# Xbox360AutoDNS

DashLaunch plugin for an Xbox 360 running BadUpdate or BadAvatar. Until the
exploit runs, the console has no working DNS, so the stock dashboard can't
reach Xbox Live. Once the exploit loads AutoDNS, it switches the console to
Cloudflare's DNS and the console goes online.

## Setup

1. Boot the console normally, without running the exploit. On the stock
dashboard, go to System Settings > Network Settings > your network >
Configure Network > DNS Settings > Manual and set both servers to
`192.0.2.1`. The console saves this setting and uses it on every boot, so you
only do this once.

2. Download `AutoDNS.xex` from the
[latest release](https://github.com/dclstn/Xbox360AutoDNS/releases/latest)
and copy it to the root of the USB stick. Add it to `launch.ini` above any
plugin that needs the network.

```ini
[Plugins]
plugin1 = Usb:\xbdm.xex
plugin2 = Usb:\AutoDNS.xex
plugin3 = Usb:\xbGuard.xex
plugin4 = Usb:\JRPC2.xex
```

3. Run BadUpdate or BadAvatar as usual. When AutoDNS loads, it switches the
DNS and the console goes online.

## How it works

`192.0.2.1` is a documentation address ([RFC 5737](https://www.rfc-editor.org/info/rfc5737/))
with no DNS server behind it. While the exploit isn't running, the console
can't resolve a single Live hostname. After the exploit loads the plugin,
AutoDNS decrypts the stored network settings with `XnpLoadConfigParams`, puts
1.1.1.1 and 1.0.0.1 in place of the dead server, and applies them with
`XnpConfig`. `XnpConfig` only changes the running network stack and never
writes to storage. The next boot starts offline again.

## Build

You need the Xbox 360 XDK. Point `XEDK` at the SDK folder and run
`./build.sh`. The result is `build/AutoDNS.xex`.

The build bakes in the two DNS servers. To use something other than
Cloudflare, pass them as arguments:

```bash
./build.sh 8.8.8.8 8.8.4.4
```

The [release assets](https://github.com/dclstn/Xbox360AutoDNS/releases/latest)
also include prebuilt Google, Quad9 and OpenDNS versions.
