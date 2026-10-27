#!/bin/bash
# Loto mäng funktsioonidega (lottery.sh)
# Varasem järjestikune skript on jagatud loogilisteks funktsioonideks.
# Põhiprogramm (faili lõpus) näitab, MIDA programm teeb.

KAUST="$(cd "$(dirname "$0")" && pwd)"
PLAYER_FILE="$KAUST/player_numbers.txt"
LOTTERY_FILE="$KAUST/lottery_numbers.txt"
RESULTS_FILE="$KAUST/results.txt"

PLAYER=""
MATCHES=0
RESULT=""

# Pealkirja kuvamine
show_header() {
    echo "=============================="
    echo "          LOTO MÄNG"
    echo "=============================="
}

# Mängu failide loomine/tühjendamine (results.txt jääb alles)
clear_files() {
    > "$PLAYER_FILE"
    > "$LOTTERY_FILE"
}

# Mängija nime küsimine, vaikimisi Unknown
read_player() {
    read -p "Sisesta oma nimi: " PLAYER
    if [ -z "$PLAYER" ]; then
        PLAYER="Unknown"
    fi
}

# Kontrollib, kas number on juba failis (olekukood 0 = on olemas)
number_in_file() {
    local number="$1"
    local file="$2"
    grep -qx "$number" "$file"
}

# Ühe sisendi kontroll; tagastab 0 kui korrektne, 1 kui vigane
validate_number() {
    local number="$1"
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
    if number_in_file "$number" "$PLAYER_FILE"; then
        echo "Viga: number $number on juba valitud!"
        return 1
    fi
    return 0
}

# Mängija 5 numbri sisestamine
read_player_numbers() {
    local count=0
    local number
    echo "Sisesta 5 erinevat numbrit vahemikust 1-50."
    while [ $count -lt 5 ]
    do
        read -p "Number $((count + 1)): " number
        if validate_number "$number"; then
            echo "$((10#$number))" >> "$PLAYER_FILE"
            count=$((count + 1))
        fi
    done
}

# Faili sisu kuvamine pealkirjaga
show_numbers() {
    local title="$1"
    local file="$2"
    echo
    echo "$title"
    cat "$file"
}

show_player_numbers() {
    show_numbers "Sinu valitud numbrid:" "$PLAYER_FILE"
}

# 5 erineva võidunumbri loosimine $RANDOM abil
generate_lottery_numbers() {
    local count=0
    local number
    while [ $count -lt 5 ]
    do
        number=$((RANDOM % 50 + 1))
        if ! number_in_file "$number" "$LOTTERY_FILE"; then
            echo "$number" >> "$LOTTERY_FILE"
            count=$((count + 1))
        fi
    done
}

show_lottery_numbers() {
    show_numbers "Võidunumbrid:" "$LOTTERY_FILE"
}

# Mängija numbrite võrdlemine võidunumbritega
check_matches() {
    local number
    MATCHES=0
    echo
    while read -r number
    do
        echo "Kontrollin numbrit $number..."
        if number_in_file "$number" "$LOTTERY_FILE"; then
            echo "TABAMUS!"
            MATCHES=$((MATCHES + 1))
        else
            echo "Ei tabanud."
        fi
        echo
    done < "$PLAYER_FILE"
}

# Hinnang tabamuste arvu järgi (väljastab teksti)
get_rating() {
    case $1 in
        5) echo "JACKPOT!" ;;
        4) echo "Väga hea tulemus!" ;;
        3) echo "Hea tulemus." ;;
        2) echo "Kaks tabamust." ;;
        1) echo "Üks tabamus." ;;
        *) echo "Seekord tabamusi ei olnud." ;;
    esac
}

show_result() {
    RESULT=$(get_rating "$MATCHES")
    echo "Mängija: $PLAYER"
    echo "Tabamusi: $MATCHES / 5"
    echo "$RESULT"
}

# Tulemuse lisamine ajaloo faili
save_result() {
    {
        echo "========================================"
        echo "Date: $(date)"
        echo "Player: $PLAYER"
        echo "Player numbers:"
        cat "$PLAYER_FILE"
        echo "Lottery numbers:"
        cat "$LOTTERY_FILE"
        echo "Matches: $MATCHES"
        echo "Result: $RESULT"
    } >> "$RESULTS_FILE"
    echo
    echo "Tulemus salvestatud faili results.txt"
}

# ===== PÕHIPROGRAMM =====
show_header
clear_files
read_player
read_player_numbers
show_player_numbers
generate_lottery_numbers
show_lottery_numbers
check_matches
show_result
save_result
