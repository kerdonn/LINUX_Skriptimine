#!/bin/bash
# lottery_functions.sh - loosimise ja võrdlemisega seotud funktsioonid

# Erinevate võidunumbrite loosimine $RANDOM abil
# Argumendid: numbrite arv, võidunumbrite fail
generate_lottery_numbers() {
    local amount="$1"
    local file="$2"
    local count=0
    local number
    while [ $count -lt "$amount" ]
    do
        number=$((RANDOM % 50 + 1))
        # duplikaadi korral genereeritakse uus number
        if ! number_in_file "$number" "$file"; then
            add_number "$number" "$file"
            count=$((count + 1))
        fi
    done
}

# Mängija numbrite võrdlemine; tabamuste arv salvestatakse muutujasse MATCHES
# Argumendid: mängija fail, võidunumbrite fail
check_matches() {
    local player_file="$1"
    local lottery_file="$2"
    local matches=0
    local number
    echo
    while read -r number
    do
        echo "Kontrollin numbrit $number..."
        if number_in_file "$number" "$lottery_file"; then
            echo "TABAMUS!"
            matches=$((matches + 1))
        else
            echo "Ei tabanud."
        fi
        echo
    done < "$player_file"
    MATCHES=$matches
}
