#!/bin/bash
# Kasutajate kodukataloogide varundamine
# Kasutus: sudo ./home_backup.sh
#
# Iga /home all olev kodukataloog arhiveeritakse ja pakitakse (tar + gzip),
# failinimesse lisatakse varundamise kuupäev, nt user.21.10.2026.tar.gz.
# Arhiivid salvestatakse varukoopiate kataloogi /home_bcp.
# Skript töötab sõltumata sellest, kus kaustas see käivitatakse, sest
# tar kasutab võtit -C /home (liigub arhiveerimise ajaks /home kausta).

HOME_KAUST="/home"
BCP_KAUST="/home_bcp"
KUUPAEV=$(date +%d.%m.%Y)

# Kõigi kasutajate kodukataloogide lugemiseks on vaja root õigusi
if [ "$(id -u)" -ne 0 ]; then
    echo "Viga: käivita skript root õigustes (sudo $0)"
    exit 1
fi

# Varukoopiate kataloogi loomine, kui see puudub (ligipääs ainult rootile)
if [ ! -d "$BCP_KAUST" ]; then
    mkdir -p "$BCP_KAUST"
    chmod 700 "$BCP_KAUST"
    echo "Loodud varukoopiate kataloog $BCP_KAUST"
fi

vigu=0
for kaust in "$HOME_KAUST"/*/
do
    kasutaja=$(basename "$kaust")
    arhiiv="$BCP_KAUST/$kasutaja.$KUUPAEV.tar.gz"

    # -c loo arhiiv, -z paki gzip-ga, -f failinimi, -C liigu /home kausta
    if tar -czf "$arhiiv" -C "$HOME_KAUST" "$kasutaja"; then
        echo "OK: $kasutaja -> $arhiiv ($(du -h "$arhiiv" | awk '{print $1}'))"
    else
        echo "VIGA: kasutaja $kasutaja varundamine ebaõnnestus"
        vigu=$((vigu + 1))
    fi
done

echo
echo "Varukoopiad kaustas $BCP_KAUST:"
ls -lh "$BCP_KAUST"

[ $vigu -eq 0 ] && exit 0 || exit 1
