#!/bin/bash
# Ülesanne 3 - Funktsiooni süntaks
# Kursusel kasutatav kuju: nimi() { käsud }

hello() {
    echo "Hello!"
}

# Bashis töötab ka teine kuju märksõnaga function
function hello2 {
    echo "Hello! (function märksõnaga)"
}

hello
hello2
