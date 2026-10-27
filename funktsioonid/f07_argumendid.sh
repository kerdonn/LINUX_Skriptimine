#!/bin/bash
# Ülesanne 7 - Funktsioonile argumentide andmine
# Funktsiooni sees on $1, $2, ... funktsioonile antud argumendid.

tervita() {
    echo "Tere, $1!"
}

# Sama funktsioon töötab erinevate andmetega
tervita "Mari"
tervita "Jüri"
tervita "Anna"
