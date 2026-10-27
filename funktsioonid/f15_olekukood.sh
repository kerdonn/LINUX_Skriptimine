#!/bin/bash
# Ülesanne 15 - $? ehk funktsiooni olekukood

kontrolli_faili() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

kontrolli_faili "/etc/passwd"
echo "/etc/passwd olekukood: $?"        # 0 - fail on olemas

kontrolli_faili "/puuduv/fail.txt"
echo "/puuduv/fail.txt olekukood: $?"   # 1 - faili pole
