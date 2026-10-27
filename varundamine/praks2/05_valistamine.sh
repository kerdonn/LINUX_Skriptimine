#!/bin/bash
# 5) Failide välistamine
# --exclude='*.jpg' jätab JPG pildid vahele, --exclude='bin' jätab bin kausta vahele

SRC="$HOME/praks2/src"
BACKUP="$HOME/praks2/backup"
ARHIIV="$BACKUP/src_valistusega_$(date +%Y-%m-%d_%H-%M-%S).tar.zst"

if ! tar -I 'zstd -19 -T0' --exclude='*.jpg' --exclude='bin' -cf "$ARHIIV" -C "$(dirname "$SRC")" "$(basename "$SRC")"; then
    echo "VIGA: arhiivi loomine ebaõnnestus"; rm -f "$ARHIIV"; exit 1
fi

echo "Arhiivi sisu:"
tar -I 'zstd -d' -tf "$ARHIIV"
echo
# Kontroll: b.jpg ja run.sh ei tohi arhiivis olla
if tar -I 'zstd -d' -tf "$ARHIIV" | grep -qE 'b\.jpg|run\.sh'; then
    echo "VIGA: välistatud failid on arhiivis!"
else
    echo "OK: b.jpg ja bin/run.sh puuduvad arhiivist"
fi
