#!/bin/bash
# apache_paigaldus.sh - veebiserveri (apache2) paigaldamine
# Kasutus: sudo ./apache_paigaldus.sh
#
# Skript kontrollib, kas teenus apache2 on paigaldatud:
#  - kui EI ole, siis paigaldab selle (apt) ja käivitab teenuse;
#  - kui ON, siis annab sellest teada ja näitab teenuse staatust.
#
# Kontroll käib käsuga dpkg-query -W -f='${Status}' apache2, mille väljundist
# otsitakse grep -c abil lauset "ok installed" (1 = paigaldatud, 0 = ei ole).

TEENUS="apache2"

# Paigaldamiseks on vaja root õigusi
if [ "$(id -u)" -ne 0 ]; then
    echo "Viga: käivita skript root õigustes (sudo $0)"
    exit 1
fi

# Mitu rida "ok installed" leiti (2>/dev/null peidab vea, kui paketti pole üldse)
PAIGALDATUD=$(dpkg-query -W -f='${Status}' "$TEENUS" 2>/dev/null | grep -c "ok installed")

if [ "$PAIGALDATUD" -eq 0 ]; then
    echo "$TEENUS ei ole paigaldatud. Paigaldan..."
    apt-get update -q
    apt-get install -y "$TEENUS"
    # apt-get väljumiskood: 0 = õnnestus
    if [ $? -ne 0 ]; then
        echo "Viga: $TEENUS paigaldamine ebaõnnestus!"
        exit 2
    fi
    # teenus käivitub automaatselt ka pärast taaskäivitust
    systemctl enable --now "$TEENUS"
    echo "$TEENUS on paigaldatud ja käivitatud."
else
    echo "$TEENUS on juba paigaldatud."
fi

echo
echo "Teenuse staatus:"
systemctl status "$TEENUS" --no-pager | head -n 5

# Lisakontroll: kas veebiserver vastab
echo
if command -v curl >/dev/null 2>&1; then
    KOOD=$(curl -s -o /dev/null -w '%{http_code}' http://localhost/)
    echo "http://localhost/ vastus: HTTP $KOOD"
fi
echo "Veebileht: http://$(hostname -I | awk '{print $1}')/"
