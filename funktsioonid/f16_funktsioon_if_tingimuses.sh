#!/bin/bash
# Ülesanne 16 - Funktsiooni kasutamine if-tingimuses
# Funktsiooni olekukood sobib otse if-tingimuseks.

fail_olemas() {
    [ -f "$1" ]
}

for fail in "/etc/passwd" "/puuduv/fail.txt"
do
    if fail_olemas "$fail"; then
        echo "$fail - Fail on olemas."
    else
        echo "$fail - Faili ei leitud."
    fi
done
