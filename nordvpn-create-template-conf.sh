#!/usr/bin/env bash
set -e
# the directory of the script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# the temp directory used, within $DIR
# omit the -p parameter to create a temporal directory in the default location
WORK_DIR=$(mktemp -d)
PROTO=tcp


# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

# deletes the temp directory
function cleanup() {
  rm -rf "$WORK_DIR"
  echo "Deleted temp working directory $WORK_DIR"
}

# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

curl -sSL https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip >"$WORK_DIR/ovpn.zip"
pushd "$WORK_DIR" || {
  echo "Can't change to $WORK_DIR"
  exit 1
}
echo "Working... please wait..."
unzip -q ovpn.zip
TEMPLATE=$(ls ovpn_$PROTO | cut -f1 -d ' ' | grep de | tail -1)
cp -f "./ovpn_$PROTO/$TEMPLATE" "$DIR/nord-template.conf"
echo "Done."
popd || exit
