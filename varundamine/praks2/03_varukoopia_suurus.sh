#!/bin/bash
# 3) Varukoopia suurus
# du -h näitab suurust inimloetaval kujul, awk '{print $1}' võtab ainult suuruse

BACKUP="$HOME/praks2/backup"
ARHIIV=$(ls -1t "$BACKUP"/src_*.tar.zst 2>/dev/null | head -n1)
[ -z "$ARHIIV" ] && { echo "Arhiivi ei leitud"; exit 1; }

SUURUS=$(du -h "$ARHIIV" | awk '{print $1}')
echo "$(basename "$ARHIIV") suurus: $SUURUS"
echo "Kõik zst arhiivid:"
du -h "$BACKUP"/src_*.tar.zst
