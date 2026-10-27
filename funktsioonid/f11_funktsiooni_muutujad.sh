#!/bin/bash
# Ülesanne 11 - Funktsiooni muutujad
# Vaikimisi on funktsioonis loodud muutuja globaalne.

hello() {
    nimi="Mari"
    echo "Tere, $nimi!"
}
hello

test_muutuja() {
    nimi2="Mari"
}
test_muutuja
# Muutuja jäi alles ka pärast funktsiooni lõppu
echo "Pärast funktsiooni: nimi2 = $nimi2"
