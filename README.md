# NordVPN best server search script

This script determines the recommended server for the given country based on load and creates an OpenVPN config at `/etc/openvpn/nord.conf` based on that.

## Prerequisties
1. A template OpenVPN config, the script assumes it's at `/etc/openvpn/nord-template.conf`. This can be any NordVPN config that contains the certificates.
2. curl, dig, bash and jq must be installed
3. A post-initialization script that is located at `/etc/openvpn/up.sh` 
4. For non-interactive login, you need the credentials in `/etc/openvpn/openvpn.nordvpn.pass`
5. If you want to automatically use the config on startup of openvpn, make sure to put `AUTOSTART=nord` in `/etc/default/openvpn`

## Usage
```shell script
LOC=de ./nordvpn-best-server.sh # Germany
LOC=ch ./nordvpn-best-server.sh # Switzerland
./nordvpn-best-server.sh # Best overall server for you 
```