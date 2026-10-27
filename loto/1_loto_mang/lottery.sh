#!/bin/bash
# Loto mäng (lottery.sh)
# Mängija valib 5 erinevat numbrit vahemikust 1-50, programm loosib 5 erinevat
# võidunumbrit ja võrdleb neid. Tulemus lisatakse faili results.txt.

# Failid asuvad skriptiga samas kaustas
KAUST="$(cd "$(dirname "$0")" && pwd)"
PLAYER_FILE="$KAUST/player_numbers.txt"
LOTTERY_FILE="$KAUST/lottery_numbers.txt"
RESULTS_FILE="$KAUST/results.txt"

echo "=============================="
echo "          LOTO MÄNG"
echo "=============================="

# 1. Loome või tühjendame mängu failid (results.txt jääb puutumata)
> "$PLAYER_FILE"
> "$LOTTERY_FILE"

# 2. Mängija nimi, tühja sisendi korral Unknown
read -p "Sisesta oma nimi: " player
if [ -z "$player" ]; then
    player="Unknown"
fi

# 3. Mängija numbrite sisestamine koos kontrollidega
echo "Sisesta 5 erinevat numbrit vahemikust 1-50."
count=0
while [ $count -lt 5 ]
do
    read -p "Number $((count + 1)): " number

    # midagi peab olema sisestatud
    if [ -z "$number" ]; then
        echo "Viga: midagi tuleb sisestada!"
        continue
    fi
    # väärtus peab olema täisarv
    if ! [[ "$number" =~ ^[0-9]+$ ]]; then
        echo "Viga: sisesta täisarv!"
        continue
    fi
    # eemaldame eesolevad nullid (nt 07 -> 7)
    number=$((10#$number))
    # number peab olema vahemikus 1-50
    if [ "$number" -lt 1 ] || [ "$number" -gt 50 ]; then
        echo "Viga: number peab olema vahemikus 1-50!"
        continue
    fi
    # sama numbrit ei tohi olla juba valitud
    if grep -qx "$number" "$PLAYER_FILE"; then
        echo "Viga: number $number on juba valitud!"
        continue
    fi

    echo "$number" >> "$PLAYER_FILE"
    count=$((count + 1))
done

echo
echo "Sinu valitud numbrid:"
cat "$PLAYER_FILE"

# 4. Loosimine $RANDOM abil, duplikaadi korral genereeritakse uus number
echo
echo "Loosin võidunumbrid..."
count=0
while [ $count -lt 5 ]
do
    number=$((RANDOM % 50 + 1))
    if grep -qx "$number" "$LOTTERY_FILE"; then
        continue        # duplikaat - genereerime uue
    fi
    echo "$number" >> "$LOTTERY_FILE"
    count=$((count + 1))
done

echo "Võidunumbrid:"
cat "$LOTTERY_FILE"

# 5. Tulemuse kontrollimine
echo
matches=0
while read -r number
do
    echo "Kontrollin numbrit $number..."
    if grep -qx "$number" "$LOTTERY_FILE"; then
        echo "TABAMUS!"
        matches=$((matches + 1))
    else
        echo "Ei tabanud."
    fi
    echo
done < "$PLAYER_FILE"

# 6. Hinnang vastavalt tabamuste arvule
case $matches in
    5) result="JACKPOT!" ;;
    4) result="Väga hea tulemus!" ;;
    3) result="Hea tulemus." ;;
    2) result="Kaks tabamust." ;;
    1) result="Üks tabamus." ;;
    *) result="Seekord tabamusi ei olnud." ;;
esac

echo "Mängija: $player"
echo "Tabamusi: $matches / 5"
echo "$result"

# 7. Tulemus lisatakse ajaloo faili (faili ei tühjendata)
{
    echo "========================================"
    echo "Date: $(date)"
    echo "Player: $player"
    echo "Player numbers:"
    cat "$PLAYER_FILE"
    echo "Lottery numbers:"
    cat "$LOTTERY_FILE"
    echo "Matches: $matches"
    echo "Result: $result"
} >> "$RESULTS_FILE"

echo
echo "Tulemus salvestatud faili results.txt"
