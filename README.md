# android-backup
Rsync script to backup my phone
How it works

    Discovery. Any directory matching
    /run/user/<UID>/gvfs/mtp:host=*/{Internal shared storage, SD Card, …}
    is treated as a source. GNOME/KDE auto‑mount MTP phones here when you plug them in and pick “File Transfer (MTP)”.

    Device naming. The text after host= is pulled out (e.g., OnePlus_OnePlus_8T_040b79b2). Spaces are swapped for underscores so it’s a safe folder name.

    Destination layout.

~/phone_backups/

   ├-- [name of phone a]/
 
   │ ├─ Internal shared storage/[YYYY]-[MM]-[DD]/…

   │ └─ SD Card/[YYYY]-[MM]-[DD]/…

   └── [name of phone b]/

         └─ Internal shared storage/[YYYY]-[MM]-[DD]/…

    Exclusions are identical to the previous answer, keeping the backup lean.

    Safety flags. --size-only + --modify-window=2 keep rsync from re‑sending unchanged files despite MTP’s limited metadata. --delete-after only prunes local files when the entire run finishes without errors.

Automating

    systemd timer (desktop):
    Create ~/.config/systemd/user/backup-mtp.timer & backup-mtp.service that run this script daily or weekly.

    Cron:
    0 20 * * 0 /home/<user>/bin/backup_mtp_devices.sh >> /home/<user>/backup_mtp.log 2>&1

Test interactively once—watch for any unexpected excludes—then schedule. Enjoy worry‑free phone backups!
