#!/bin/bash
# Ülesanne 5 - Funktsiooni võib kutsuda mitu korda

hello() {
    echo "Tere tulemast!"
}

# Kolm väljakutset järjest
hello
hello
hello

# Funktsiooni kutsumine tsüklist
tere() {
    echo "Tere!"
}
for i in {1..5}
do
    tere
done
