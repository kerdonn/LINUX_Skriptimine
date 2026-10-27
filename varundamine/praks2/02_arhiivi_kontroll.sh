#!/bin/bash
# 2) Arhiivi kontrollimine
# -t näita sisu, -I 'zstd -d' kasuta zstd lahtipakkimist, head -n 5 esimesed 5 rida

BACKUP="$HOME/praks2/backup"
ARHIIV=$(ls -1t "$BACKUP"/src_*.tar.zst 2>/dev/null | head -n1)
if [ -z "$ARHIIV" ]; then
    echo "Arhiivi ei leitud, käivita enne 01_lihtne_varukoopia.sh"
    exit 1
fi

echo "Arhiiv: $ARHIIV"
tar -I 'zstd -d' -tf "$ARHIIV" | head -n 5
