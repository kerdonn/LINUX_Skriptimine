#!/bin/bash
# result.sh - tulemuse hindamise, kuvamise ja salvestamisega seotud funktsioonid

# Hinnang tabamuste arvu järgi
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

# Argumendid: mängija nimi, tabamuste arv, hinnang
show_result() {
    echo "Mängija: $1"
    echo "Tabamusi: $2 / 5"
    echo "$3"
}

# Tulemuse lisamine ajaloo faili
# Argumendid: tulemuste fail, nimi, mängija fail, loosi fail, tabamused, hinnang
save_result() {
    local results_file="$1"
    {
        echo "========================================"
        echo "Date: $(date)"
        echo "Player: $2"
        echo "Player numbers:"
        cat "$3"
        echo "Lottery numbers:"
        cat "$4"
        echo "Matches: $5"
        echo "Result: $6"
    } >> "$results_file" || return 1
    echo
    echo "Tulemus salvestatud faili $(basename "$results_file")"
    return 0
}
