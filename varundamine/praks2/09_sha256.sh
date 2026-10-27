#!/bin/bash
# 9) SHA-256 kontrollsumma - arvutamine ja kontrollimine
# sha256sum fail > fail.sha256 ; sha256sum -c fail.sha256

BACKUP="$HOME/praks2/backup"
ARHIIV=$(ls -1t "$BACKUP"/src_*.tar.zst 2>/dev/null | head -n1)
[ -z "$ARHIIV" ] && { echo "Arhiivi ei leitud"; exit 1; }

cd "$BACKUP" || exit 1
NIMI=$(basename "$ARHIIV")
sha256sum "$NIMI" > "$NIMI.sha256"
echo "Kontrollsumma fail: $NIMI.sha256"
cat "$NIMI.sha256"
sha256sum -c "$NIMI.sha256"
