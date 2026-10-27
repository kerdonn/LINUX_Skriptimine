#!/bin/bash
# Ülesanne 14 - return
# return lõpetab funktsiooni; return 0 = õnnestus, return 1 = probleem

kontrolli_faili() {
    if [ ! -f "$1" ]; then
        echo "Faili ei leitud!"
        return 1
    fi
    echo "Fail on olemas."
    return 0
}

kontrolli_faili "/etc/passwd"
kontrolli_faili "/puuduv/fail.txt"
echo "Skript jätkab pärast funktsiooni tööd."
