#!/bin/bash
# Ülesanne 13 - Funktsiooni tulemus
# Arvutatud väärtus väljastatakse echo-ga ja püütakse kinni $( ) abil.

liida() {
    local a="$1"
    local b="$2"
    echo "$((a + b))"
}

tulemus=$(liida 10 20)
echo "Tulemus: $tulemus"
