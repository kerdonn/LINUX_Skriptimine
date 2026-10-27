#!/bin/bash
# 1) Lihtne varukoopia .tar.zst
# -I 'zstd -19 -T0' -> paki zstd-ga (19 = tugev pakkimine, T0 = kõik tuumad)
# -c loo arhiiv, -f failinimi, -C liigu enne pakkimist kausta ~/praks2

SRC="$HOME/praks2/src"
BACKUP="$HOME/praks2/backup"
mkdir -p "$BACKUP"

# dirname ja basename annavad lähtekausta asukoha ja nime
ALUS=$(dirname "$SRC")       # ~/praks2
NIMI=$(basename "$SRC")      # src
ARHIIV="$BACKUP/${NIMI}_$(date +%Y-%m-%d_%H-%M-%S).tar.zst"

if tar -I 'zstd -19 -T0' -cf "$ARHIIV" -C "$ALUS" "$NIMI"; then
    echo "Loodud: $ARHIIV"
else
    echo "VIGA: arhiivi loomine ebaõnnestus (kas zstd on paigaldatud?)"
    rm -f "$ARHIIV"
    exit 1
fi
ls -l "$BACKUP"
