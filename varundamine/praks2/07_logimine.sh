#!/bin/bash
# 7) Logimine - varundamise algus ja lõpp kirjutatakse logifaili
# date '+%F %T' annab ajatempli, >> lisab faili lõppu, printf vormindab rea

SRC="$HOME/praks2/src"
BACKUP="$HOME/praks2/backup"
LOG="$HOME/praks2/logs/backup.log"
mkdir -p "$BACKUP" "$(dirname "$LOG")"

log() {
    printf '[ %s ] %s\n' "$(date '+%F %T')" "$1" >> "$LOG"
}

log "BACKUP START"
ARHIIV="$BACKUP/src_$(date +%Y-%m-%d_%H-%M-%S).tar.zst"
if tar -I 'zstd -19 -T0' -cf "$ARHIIV" -C "$(dirname "$SRC")" "$(basename "$SRC")"; then
    log "OK $ARHIIV"
else
    log "ERROR tar ebaõnnestus"
fi
log "BACKUP END"

echo "Logifaili viimased read:"
tail -n 5 "$LOG"
