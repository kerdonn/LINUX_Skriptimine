#!/bin/bash
# 6) "Kuiv jooks" - näeme, mis failid arhiivi läheks, aga arhiivi ei teki
# tar -cf - kirjutab arhiivi standardväljundisse, tar -tvf - loeb selle kohe tagasi

SRC="$HOME/praks2/src"
BACKUP="$HOME/praks2/backup"

ENNE=$(ls -1 "$BACKUP" 2>/dev/null | wc -l)

echo "find järgi arhiveeritavad failid:"
find "$SRC" -type f | sort
echo
echo "tar kuiv jooks:"
tar -cf - -C "$(dirname "$SRC")" "$(basename "$SRC")" | tar -tvf -

PARAST=$(ls -1 "$BACKUP" 2>/dev/null | wc -l)
echo
echo "Faile kaustas backup enne: $ENNE, pärast: $PARAST (uut arhiivi ei tekkinud)"
