#!/bin/bash
# Ülesanne 2 - Miks funktsioone kasutada?
# Sama tegevus kirjutatakse üks kord funktsiooni ja kutsutakse välja mitu korda.

# Süsteemi info kuvamine funktsioonina
system_info() {
    echo "===================="
    echo "SÜSTEEMI INFO"
    echo "===================="
    hostname
    uname -r
    whoami
}

# Kutsume sama funktsiooni kaks korda - koodi ei pea kordama
system_info
system_info
