#!/bin/bash
# 11) .backupignore kasutamine
# --exclude-from loeb välistusreeglid failist src/.backupignore

SRC="$HOME/praks2/src"
BACKUP="$HOME/praks2/backup"
IGNORE="$SRC/.backupignore"

if [ ! -f "$IGNORE" ]; then
    printf 'imgs/\n*.tmp\n' > "$IGNORE"
fi
echo "Välistusreeglid ($IGNORE):"
cat "$IGNORE"

# tar mustrid käivad failinimede kohta, kaldkriips lõpust eemaldatakse
REEGLID=$(mktemp)
trap 'rm -f "$REEGLID"' EXIT
sed -e 's#/$##' -e '/^\s*#/d' -e '/^\s*$/d' "$IGNORE" > "$REEGLID"

ARHIIV="$BACKUP/src_ignore_$(date +%Y-%m-%d_%H-%M-%S).tar.zst"
if ! tar -I 'zstd -19 -T0' --exclude-from="$REEGLID" -cf "$ARHIIV" -C "$(dirname "$SRC")" "$(basename "$SRC")"; then
    echo "VIGA: arhiivi loomine ebaõnnestus"; rm -f "$ARHIIV"; exit 1
fi

echo
echo "Arhiivi sisu:"
tar -I 'zstd -d' -tf "$ARHIIV"
if tar -I 'zstd -d' -tf "$ARHIIV" | grep -qE 'imgs|\.tmp$'; then
    echo "VIGA: välistatud failid on arhiivis!"
else
    echo "OK: imgs/ ja *.tmp failid puuduvad arhiivist"
fi
