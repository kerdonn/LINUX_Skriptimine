#!/bin/bash
# Ülesanne 9 - Argumentide arv $#

kontrolli() {
    echo "Argumentide arv: $#"
}
kontrolli üks kaks kolm

# $# abil saab sisendit kontrollida
liida() {
    if [ $# -ne 2 ]; then
        echo "Viga: sisesta kaks arvu!"
        return 1
    fi
    echo "$(( $1 + $2 ))"
}
liida 10 20     # korrektne
liida 10        # vigane - ainult üks argument
