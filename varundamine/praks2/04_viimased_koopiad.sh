#!/bin/bash
# 4) Ainult viimased koopiad - hoitakse alles 3 kõige uuemat
# ls -1t uuemad ees, tail -n +4 jätab 3 esimest vahele, xargs -r rm -f kustutab

SRC="$HOME/praks2/src"
BACKUP="$HOME/praks2/backup"
HOIA=3
mkdir -p "$BACKUP"

# Kontrolliks teeme 5 järjestikust varukoopiat (1 s vahega, et nimed erineks)
for i in 1 2 3 4 5
do
    tar -I 'zstd -19 -T0' -cf "$BACKUP/src_$(date +%Y-%m-%d_%H-%M-%S).tar.zst" -C "$(dirname "$SRC")" "$(basename "$SRC")"
    sleep 1
done
echo "Enne puhastust: $(ls -1 "$BACKUP"/src_*.tar.zst | wc -l) arhiivi"

cd "$BACKUP" || exit 1
ls -1t src_*.tar.zst | tail -n +$((HOIA + 1)) | xargs -r rm -f

echo "Pärast puhastust: $(ls -1 src_*.tar.zst | wc -l) arhiivi"
ls -1t src_*.tar.zst
