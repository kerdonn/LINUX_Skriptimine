#!/bin/bash
# lottery.sh - Loto mängu ainus käivitusfail
# Laeb funktsioonide failid ja kutsub funktsioone õiges järjekorras.
# Käivitamine: ./lottery.sh

KAUST="$(cd "$(dirname "$0")" && pwd)"

# Funktsioonide failide laadimine
source "$KAUST/files.sh"
source "$KAUST/input.sh"
source "$KAUST/lottery_functions.sh"
source "$KAUST/result.sh"

PLAYER_FILE="$KAUST/player_numbers.txt"
LOTTERY_FILE="$KAUST/lottery_numbers.txt"
RESULTS_FILE="$KAUST/results.txt"
AMOUNT=5

show_header() {
    echo "=============================="
    echo "          LOTO MÄNG"
    echo "=============================="
}

# ===== PÕHIPROGRAMM =====
show_header
clear_files "$PLAYER_FILE" "$LOTTERY_FILE" || { echo "Viga: faile ei saa luua!"; exit 1; }
PLAYER=$(read_player)
read_player_numbers "$AMOUNT" "$PLAYER_FILE"
show_numbers "Sinu valitud numbrid:" "$PLAYER_FILE"
generate_lottery_numbers "$AMOUNT" "$LOTTERY_FILE"
show_numbers "Võidunumbrid:" "$LOTTERY_FILE"
check_matches "$PLAYER_FILE" "$LOTTERY_FILE"
RATING=$(get_rating "$MATCHES")
show_result "$PLAYER" "$MATCHES" "$RATING"
save_result "$RESULTS_FILE" "$PLAYER" "$PLAYER_FILE" "$LOTTERY_FILE" "$MATCHES" "$RATING" || echo "Viga: tulemust ei saanud salvestada!"
