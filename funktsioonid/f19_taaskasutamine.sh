#!/bin/bash
# Ülesanne 19 - Funktsioonide taaskasutamine eraldi failist
# Funktsioonid asuvad failis functions.sh ja laaditakse source käsuga.

# Skripti kaust, et functions.sh leitaks sõltumata käivitamise kohast
SKRIPTI_KAUST="$(cd "$(dirname "$0")" && pwd)"

source "$SKRIPTI_KAUST/functions.sh"
# või lühemalt: . "$SKRIPTI_KAUST/functions.sh"

echo "Kasutaja: $(show_user)"
echo "Arvuti:   $(show_host)"
