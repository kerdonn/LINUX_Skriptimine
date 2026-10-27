#!/bin/bash
# files.sh - failidega seotud funktsioonid

# Mängu failide loomine/tühjendamine (results.txt jääb alles)
# Argumendid: failid, mida tühjendada
clear_files() {
    local file
    for file in "$@"
    do
        > "$file" || return 1
    done
    return 0
}

# Kontrollib, kas number on failis (0 = on olemas, 1 = ei ole)
number_in_file() {
    local number="$1"
    local file="$2"
    grep -qx "$number" "$file"
}

# Numbri lisamine faili lõppu
add_number() {
    local number="$1"
    local file="$2"
    echo "$number" >> "$file"
}

# Faili sisu kuvamine pealkirjaga
show_numbers() {
    local title="$1"
    local file="$2"
    echo
    echo "$title"
    cat "$file"
}
