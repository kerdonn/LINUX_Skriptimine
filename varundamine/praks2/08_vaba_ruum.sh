#!/bin/bash
# 8) Vaba ruumi kontroll enne varundamist
# du -sb kausta suurus baitides, df -B1 vaba ruum baitides,
# awk 'NR==2{print $4}' võtab df väljundist vaba ruumi

SRC="$HOME/praks2/src"
BACKUP="$HOME/praks2/backup"
mkdir -p "$BACKUP"

VAJA=$(du -sb "$SRC" | awk '{print $1}')
VABA=$(df -B1 "$BACKUP" | awk 'NR==2{print $4}')

echo "Lähtekausta suurus: $VAJA baiti"
echo "Vaba ruum sihtkohas: $VABA baiti"

# Ohutusvaru: nõuame vähemalt 2x lähtekausta suurust
if [ "$VABA" -lt $((VAJA * 2)) ]; then
    echo "VIGA: vaba ruumi on liiga vähe, varundust ei käivitata!"
    exit 1
fi
echo "Ruumi piisab, varundan..."
tar -I 'zstd -19 -T0' -cf "$BACKUP/src_$(date +%Y-%m-%d_%H-%M-%S).tar.zst" -C "$(dirname "$SRC")" "$(basename "$SRC")" && echo "Valmis"
