#!/bin/bash
# Ülesanne 8 - Mitu argumenti

kasutaja_info() {
    echo "Nimi: $1"     # $1 -> Mari
    echo "Vanus: $2"    # $2 -> 18
}
kasutaja_info "Mari" 18

# Kahe arvu liitmine argumentidest
liida() {
    echo "$(( $1 + $2 ))"
}
echo -n "10 + 5 = "
liida 10 5
