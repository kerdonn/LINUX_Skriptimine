#!/bin/bash
# Ülesanne 12 - local: funktsiooni lokaalne muutuja

test_local() {
    local nimi="Mari"
    echo "Funktsiooni sees: $nimi"
}
test_local
# Lokaalne muutuja ei ole väljaspool funktsiooni nähtav
echo "Väljaspool funktsiooni: '${nimi}' (tühi)"

# Hea tava: argumentidest kohe lokaalsed muutujad
tervita() {
    local nimi="$1"
    echo "Tere, $nimi!"
}
tervita "Mari"

kasutaja_info() {
    local nimi="$1"
    local vanus="$2"
    echo "Nimi: $nimi"
    echo "Vanus: $vanus"
}
kasutaja_info "Jüri" 20
