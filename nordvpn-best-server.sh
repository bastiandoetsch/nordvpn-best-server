#!/bin/bash
set -e
# the directory of the script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEST_CONFIG=/etc/openvpn/nord.conf

if [[ ! -d $(dirname $DEST_CONFIG) ]]; then
  echo "Destination directory not found."
  exit 1
fi

# you can call the script like LOC=ch nordvpn-best-server.sh or just without any env variables set.
# if no location environment variable is set, it automatically takes the recommended server

LOC=$(echo $LOC | sed 's/.*/\U&/g')
ID=$(curl -s 'https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_countries' \
  -H 'Host: nordvpn.com' \
  -H 'Referer: https://nordvpn.com/de/servers/tools/' \
  -H 'X-Requested-With: XMLHttpRequest' | jq -r ".[] | select (.code == \"$LOC\") | .id")

CONFIG=$(curl -s "https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations&filters=\{%22country_id%22:$ID,%22servers_groups%22:\[11\],%22servers_technologies%22:\[3\]\}" \
  -H 'Host: nordvpn.com' \
  -H 'Referer: https://nordvpn.com/de/servers/tools/' \
  -H 'X-Requested-With: XMLHttpRequest' | jq -r '.[0].hostname')

DEFAULT=ch250.nordvpn.com

if [[ "" == "$CONFIG" ]]; then
  echo "No config found, using $DEFAULT"
  CONFIG=$DEFAULT
fi

echo "Using config: $CONFIG."

# use any nordvpn config as a template
BEST_CONFIG="$DIR/nord-template.conf"

if [[ ! -f "$BEST_CONFIG" ]]; then
  echo "No template found, creating one."
  bash -c "$DIR/nordvpn-create-template-conf.sh"
fi

rm $DEST_CONFIG
cat "$BEST_CONFIG" | grep -v "auth-user-pass" | grep -v "remote" >>$DEST_CONFIG

echo "cipher AES-256-GCM" >>$DEST_CONFIG

# put your post-initializiation stuff like firewalling in this script
echo "up /etc/openvpn/up.sh" >>$DEST_CONFIG

# necessary for non-interactive
echo "script-security 2" >>$DEST_CONFIG
echo "auth-user-pass openvpn.nordvpn.pass" >>$DEST_CONFIG

# add numerical IPs
echo "Adding numerical IP addresses..."
echo "Trying to get normal remote VPN endpoint..."
echo "Detected: $CONFIG"
echo "Corresponding IPs:"
IP_LIST=$(dig +short $CONFIG) || exit 0
for ip in $IP_LIST; do
  echo "Found IP $ip"
  if [ "$(grep -c $ip $DEST_CONFIG)" -eq 0 ]; then
    echo "remote $ip 1194" >>$DEST_CONFIG
    echo "Added $ip to $DEST_CONFIG"
  else
    echo "Found $ip in $DEST_CONFIG, skipping"
  fi
done

# add dns name of config
echo "remote $CONFIG 1194" >>$DEST_CONFIG
echo "remote-random" >>$DEST_CONFIG
