#!/usr/bin/env bash
# ------------------------------------------------------------
# backup_mtp_devices.sh  –  Incremental backups of all GVFS‑mounted
#                           MTP devices on Debian/Ubuntu desktops
# ------------------------------------------------------------

set -euo pipefail
shopt -s nullglob                           # ignore empty globs
RUN_MOUNT="/run/user/$(id -u)/gvfs"         # GVFS mount root
TODAY=$(date +%F)                           # e.g. 2025-06-06
DEST_ROOT="$HOME/phone_backups"             # master backup dir

#------- rsync settings & ignore rules ----------------------------------------
RSYNC_OPTS=(
  -avh --progress --size-only --modify-window=2
  --delete-after
  --exclude='.thumbnails/**'
  --exclude='Android/data/*/cache/**'
  --exclude='Android/data/*/files/Cache*/**'
  --exclude='Android/data/*/files/*cached*'
  --exclude='Android/obb/**'
  --exclude='**/*.tmp'
)

echo -e "\n>>> Scanning for GVFS MTP mounts under $RUN_MOUNT …"

#------- loop through every “Internal shared storage” & “SD Card” -------------
STORAGES=( "$RUN_MOUNT"/mtp:host=*/{Internal\ shared\ storage,SD\ Card,SD\ card,Card} )
if [[ ${#STORAGES[@]} -eq 0 ]]; then
  echo "No MTP devices detected. Make sure your phone is unlocked and MTP mode is selected."
  exit 0
fi

for STORAGE in "${STORAGES[@]}"; do
  [[ -d "$STORAGE" ]] || continue

  HOSTPATH=$(dirname "$STORAGE")            # e.g. /run/…/mtp:host=OnePlus_OnePlus_8T_040b79b2
  HOSTTAG=$(basename "$HOSTPATH")           #   -> mtp:host=OnePlus_OnePlus_8T_040b79b2
  DEVNAME=${HOSTTAG#mtp:host=}              #   -> OnePlus_OnePlus_8T_040b79b2
  SAFEDEV=${DEVNAME// /_}                   # replace spaces just in case
  SUBDIR=$(basename "$STORAGE")             # “Internal shared storage” or “SD Card”

  DEST="$DEST_ROOT/$SAFEDEV/$SUBDIR/$TODAY"
  mkdir -p "$DEST"

  echo -e "\n>>> Backing up \"$SUBDIR\" of $DEVNAME → $DEST …"
  rsync "${RSYNC_OPTS[@]}"  "$STORAGE"/  "$DEST"/
done

echo -e "\n✓ All connected MTP devices have been backed up.\n"
