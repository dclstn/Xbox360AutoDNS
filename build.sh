#!/usr/bin/env bash
# Builds AutoDNS.xex with the Xbox 360 XDK's own compiler. No Visual Studio.
#
#   ./build.sh                    # Cloudflare (1.1.1.1, 1.0.0.1)
#   ./build.sh 8.8.8.8 8.8.4.4    # any two resolvers
set -e
cd "$(dirname "$0")"

XEDK="${XEDK:-/c/XDK21256/XDK}"
[ -f "$XEDK/bin/win32/cl.exe" ] || XEDK=/c/XDK21256/XDK   # the XDK installer sets XEDK to a tools-only install
CRT="${CRT_INC:-/c/XDK21256/TP/XDK/TechPreview/Jul12Compiler/include/xbox}"   # plain C headers the XDK keeps here
BIN="$XEDK/bin/win32"
INC="$(cygpath -w "$XEDK/include/xbox")"

# Dotted quad -> 0xAABBCCDD, the form the plugin stores (network order, which
# is also PowerPC's byte order).
hex_ip() {
    [[ "$1" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]] || { echo "not an IPv4 address: $1" >&2; exit 1; }
    for o in "${BASH_REMATCH[@]:1}"; do [ "$o" -le 255 ] || { echo "octet out of range: $1" >&2; exit 1; }; done
    printf '0x%02X%02X%02X%02Xu' "${BASH_REMATCH[@]:1}"
}
DNS1="${1:-1.1.1.1}"
DNS2="${2:-1.0.0.1}"
HEX1=$(hex_ip "$DNS1")   # set -e stops here on a bad address
HEX2=$(hex_ip "$DNS2")
echo "DNS: $DNS1 ($HEX1), $DNS2 ($HEX2)"

mkdir -p build

INCLUDE="$INC;$(cygpath -w "$CRT")" "$BIN/cl.exe" -nologo -c -W4 -WX -Ox -MT -GR- -EHsc -TP \
    -D _XBOX -D NDEBUG -D "GOOD_DNS1=$HEX1" -D "GOOD_DNS2=$HEX2" \
    -FI"$INC\\xbox_intellisense_platform.h" -Fobuild/AutoDNS.obj AutoDNS.cpp

LIB="$(cygpath -w "$XEDK/lib/xbox")" "$BIN/link.exe" -nologo -RELEASE -OPT:REF -DLL -ENTRY:_DllMainCRTStartup \
    -XEX:NO -ALIGN:128,4096 -OUT:build/AutoDNS.exe build/AutoDNS.obj xboxkrnl.lib xapilib.lib

"$BIN/imagexex.exe" -nologo -config:AutoDNS.xex.xml -out:build/AutoDNS.xex build/AutoDNS.exe
echo build/AutoDNS.xex
