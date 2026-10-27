#!/bin/bash
# 10) Erinevate kompressorite valik
# -I 'zstd' -> .tar.zst, -z -> gzip .tar.gz, -J -> xz .tar.xz

SRC="$HOME/praks2/src"
BACKUP="$HOME/praks2/backup"
AEG=$(date +%Y-%m-%d_%H-%M-%S)
ALUS=$(dirname "$SRC"); NIMI=$(basename "$SRC")

tar -I 'zstd -19 -T0' -cf "$BACKUP/${NIMI}_$AEG.tar.zst" -C "$ALUS" "$NIMI"
tar -z -cf "$BACKUP/${NIMI}_$AEG.tar.gz" -C "$ALUS" "$NIMI"
tar -J -cf "$BACKUP/${NIMI}_$AEG.tar.xz" -C "$ALUS" "$NIMI"

echo "Kolm arhiivi eri kompressoritega (suurused baitides):"
ls -l "$BACKUP"/${NIMI}_$AEG.tar.* | awk '{print $5, $9}'
