#!/bin/bash
# input.sh - kasutaja sisendiga seotud funktsioonid

# Mängija nime küsimine; nimi väljastatakse (vaikimisi Unknown)
read_player() {
    local name
    read -p "Sisesta oma nimi: " name
    if [ -z "$name" ]; then
        name="Unknown"
    fi
    echo "$name"
}

# Ühe sisendi kontroll; 0 = korrektne, 1 = vigane
# Argumendid: sisestatud väärtus, mängija numbrite fail
validate_number() {
    local number="$1"
    local file="$2"
    if [ -z "$number" ]; then
        echo "Viga: midagi tuleb sisestada!"
        return 1
    fi
    if ! [[ "$number" =~ ^[0-9]+$ ]]; then
        echo "Viga: sisesta täisarv!"
        return 1
    fi
    number=$((10#$number))
    if [ "$number" -lt 1 ] || [ "$number" -gt 50 ]; then
        echo "Viga: number peab olema vahemikus 1-50!"
        return 1
    fi
    if number_in_file "$number" "$file"; then
        echo "Viga: number $number on juba valitud!"
        return 1
    fi
    return 0
}

# Mängija numbrite sisestamine
# Argumendid: numbrite arv, mängija numbrite fail
read_player_numbers() {
    local amount="$1"
    local file="$2"
    local count=0
    local number
    echo "Sisesta $amount erinevat numbrit vahemikust 1-50."
    while [ $count -lt "$amount" ]
    do
        read -p "Number $((count + 1)): " number
        if validate_number "$number" "$file"; then
            add_number "$((10#$number))" "$file"
            count=$((count + 1))
        fi
    done
}
