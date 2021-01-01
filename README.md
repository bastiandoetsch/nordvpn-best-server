# NordVPN best server search script

This script determines the recommended server for the given country based on load and creates an OpenVPN config at `/etc/openvpn/nord.conf` based on that.

## Prerequisites
1. curl, dig, bash, unzip and jq must be installed
2. A post-initialization script that is located at `/etc/openvpn/up.sh` 
3. For non-interactive login, you need the credentials in `/etc/openvpn/openvpn.nordvpn.pass`
4. If you want to automatically use the config on startup of openvpn, make sure to put `AUTOSTART=nord` in `/etc/default/openvpn`

## Usage
```shell script
LOC=de ./nordvpn-best-server.sh # Germany
LOC=ch ./nordvpn-best-server.sh # Switzerland
./nordvpn-best-server.sh # Best overall server for you 
```
