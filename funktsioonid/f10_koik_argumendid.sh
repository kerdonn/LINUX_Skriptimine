#!/bin/bash
# Ülesanne 10 - Kõik argumendid "$@"
# "$@" on kasulik siis, kui ei tea ette, mitu argumenti antakse.

naita() {
    echo "Funktsioonile anti:"
    for argument in "$@"
    do
        echo "$argument"
    done
}
naita "üks" "kaks" "kolm"
naita "ainult üks argument tühikutega"
