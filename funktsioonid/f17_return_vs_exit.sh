#!/bin/bash
# Ülesanne 17 - return ja exit ei ole sama asi
#  return - lõpetab funktsiooni, skript võib jätkata
#  exit   - lõpetab kogu skripti

kontroll() {
    if [ ! -f "$1" ]; then
        echo "Faili pole."
        return 1
    fi
    echo "Fail leitud."
}

kontroll "/tmp/test.txt"
echo "Skript jätkab tööd (return ei lõpetanud skripti)."

lopeta() {
    echo "Kutsun exit 0 - skript lõpeb kohe."
    exit 0
}
lopeta
echo "Seda rida ei kuvata kunagi."
