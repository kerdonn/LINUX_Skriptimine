#!/bin/bash
# =============================================================================
# backupexec.sh - varukoopia kuupäevaga ja kontrolliga (ülesanne, punkt 12)
#
# Ühendab punktide 1-11 tegevused üheks automaatseks skriptiks:
#   1) kuupäeva ja kellaajaga varukoopia (tar)          7) logimine
#   2) arhiivi kontroll: avaneb + sisaldab alamkaustu    8) vaba ruumi kontroll
#   3) arhiivi suuruse näitamine                         9) SHA-256 kontrollsumma
#   4) vanade koopiate kustutamine (alles N uuemat)     10) kompressori valik
#   5) failide välistamine (--exclude)                  11) .backupignore
#   6) kuiv jooks (-n)                                  + ajutised failid ja trap
#
# Kasutus:
#   ./backupexec.sh [-s lähtekaust] [-d sihtkaust] [-c zstd|gzip|xz|auto]
#                   [-k arv] [-x muster] [-m MB] [-n] [-h]
#
#   -s  varundatav kaust            (vaikimisi ~/praks2/src)
#   -d  varukoopiate kaust          (vaikimisi ~/praks2/backup)
#   -c  kompressor; auto = proovib kõiki ja valib väikseima (vaikimisi auto)
#   -k  mitu uuemat varukoopiat alles hoida (vaikimisi 3)
#   -x  lisaks välistatav muster, võib korrata (nt -x '*.log')
#   -m  nõutav vaba ruumi varu megabaitides lisaks arhiivile (vaikimisi 10)
#   -n  kuiv jooks: näitab, mis arhiivi läheks, midagi ei looda
#   -h  abi
#
# Väljumiskoodid:
#   0 korras | 1 vale kasutus / tööriist puudub | 2 lähtekausta viga
#   3 vaba ruumi pole piisavalt | 4 sama nimega arhiiv on juba olemas
#   5 arhiveerimine ebaõnnestus | 6 arhiivi sisu kontroll ebaõnnestus
#   7 SHA-256 kontroll ebaõnnestus | 8 teine varundus juba käib
# =============================================================================

# ---------- vaikeseaded ----------
SRC="$HOME/praks2/src"
DEST="$HOME/praks2/backup"
LOG_FILE="$HOME/praks2/logs/backup.log"
COMPRESSOR="auto"
KEEP=3
MARGIN_MB=10
DRY_RUN=0
EXTRA_EXCLUDES=()
# punkt 5: alati välistatavad (pildid ja bin kaust)
DEFAULT_EXCLUDES=('*.jpg' 'bin')

TMP_DIR=""
LOCK_DIR=""

# ---------- abifunktsioonid ----------

# Logimine: rida ekraanile ja logifaili (punkt 7)
log() {
    local level="$1"; shift
    local line
    line=$(printf '[ %s ] %-5s %s' "$(date '+%F %T')" "$level" "$*")
    echo "$line"
    [ -n "$LOG_FILE" ] && echo "$line" >> "$LOG_FILE" 2>/dev/null
}

# Veaga lõpetamine: logib teate ja väljub antud koodiga
die() {
    local code="$1"; shift
    log "ERROR" "$* (väljumiskood $code)"
    exit "$code"
}

usage() {
    sed -n '13,30p' "$0" | sed 's/^# \{0,1\}//'
}

# Koristus skripti lõpus - käivitub alati (trap EXIT)
cleanup() {
    local code=$?
    if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
        log "INFO" "Ajutine kaust kustutatud: $TMP_DIR"
    fi
    [ -n "$LOCK_DIR" ] && rmdir "$LOCK_DIR" 2>/dev/null
    if [ "$code" -eq 0 ]; then
        log "INFO" "BACKUP END - edukalt"
    else
        log "INFO" "BACKUP END - lõppes veaga (kood $code)"
    fi
}

# Kompressori andmed: tar -I programm, lahtipakkija ja faililaiend (punkt 10)
compress_cmd() {
    case "$1" in
        zstd) echo "zstd -19 -T0" ;;
        gzip) echo "gzip -9" ;;
        xz)   echo "xz -9" ;;   # ühe lõimega, et mälu piisaks
    esac
}
decompress_cmd() {
    case "$1" in
        zstd) echo "zstd -d" ;;
        gzip) echo "gzip -d" ;;
        xz)   echo "xz -d" ;;
    esac
}
extension() {
    case "$1" in
        zstd) echo "tar.zst" ;;
        gzip) echo "tar.gz" ;;
        xz)   echo "tar.xz" ;;
    esac
}
ext_to_compressor() {
    case "$1" in
        *.tar.zst) echo "zstd" ;;
        *.tar.gz)  echo "gzip" ;;
        *.tar.xz)  echo "xz" ;;
    esac
}

# Välistuste faili koostamine: vaikimisi + -x + .backupignore (punktid 5 ja 11)
build_excludes() {
    local file="$1"
    local p
    : > "$file"
    for p in "${DEFAULT_EXCLUDES[@]}" "${EXTRA_EXCLUDES[@]}"; do
        echo "$p" >> "$file"
    done
    if [ -f "$SRC/.backupignore" ]; then
        # kaldkriips lõpust maha, kommentaarid ja tühjad read välja
        sed -e 's#/$##' -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$SRC/.backupignore" >> "$file"
        log "INFO" ".backupignore leitud, reegleid: $(grep -c '' "$SRC/.backupignore")"
    fi
}

# Arhiivi loomine: $1 = kompressor, $2 = väljundfail
make_archive() {
    tar -I "$(compress_cmd "$1")" --sort=name \
        --exclude-from="$EXCLUDE_FILE" \
        -cf "$2" -C "$SRC_PARENT" "$SRC_NAME"
}

# ---------- 0. parameetrid ----------
while getopts ":s:d:c:k:x:m:nh" opt; do
    case "$opt" in
        s) SRC="$OPTARG" ;;
        d) DEST="$OPTARG" ;;
        c) COMPRESSOR="$OPTARG" ;;
        k) KEEP="$OPTARG" ;;
        x) EXTRA_EXCLUDES+=("$OPTARG") ;;
        m) MARGIN_MB="$OPTARG" ;;
        n) DRY_RUN=1 ;;
        h) usage; exit 0 ;;
        :) echo "Võtmele -$OPTARG on vaja väärtust"; usage; exit 1 ;;
        *) echo "Tundmatu võti -$OPTARG"; usage; exit 1 ;;
    esac
done

mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || LOG_FILE=""
log "INFO" "BACKUP START (src=$SRC, dest=$DEST, kompressor=$COMPRESSOR, hoia=$KEEP)"
trap cleanup EXIT
trap 'log "WARN" "Katkestatud"; exit 130' INT TERM

# ---------- 1. eeltingimused ----------
case "$COMPRESSOR" in
    zstd|gzip|xz|auto) ;;
    *) die 1 "Tundmatu kompressor '$COMPRESSOR' (lubatud: zstd, gzip, xz, auto)" ;;
esac
[[ "$KEEP" =~ ^[1-9][0-9]*$ ]] || die 1 "Hoitavate koopiate arv peab olema positiivne täisarv"
[[ "$MARGIN_MB" =~ ^[0-9]+$ ]] || die 1 "Vaba ruumi varu peab olema täisarv (MB)"

for cmd in tar sha256sum du df find; do
    command -v "$cmd" >/dev/null 2>&1 || die 1 "Vajalik käsk puudub: $cmd"
done

# saadaolevad kompressorid
AVAILABLE=()
for c in zstd gzip xz; do
    command -v "$c" >/dev/null 2>&1 && AVAILABLE+=("$c")
done
if [ "$COMPRESSOR" != "auto" ] && ! command -v "$COMPRESSOR" >/dev/null 2>&1; then
    die 1 "Kompressor $COMPRESSOR ei ole paigaldatud (sudo apt install $COMPRESSOR)"
fi
[ ${#AVAILABLE[@]} -gt 0 ] || die 1 "Ühtegi kompressorit (zstd, gzip, xz) ei leitud"

# lähtekaust
[ -d "$SRC" ] || die 2 "Lähtekausta ei ole: $SRC"
[ -r "$SRC" ] || die 2 "Lähtekaust ei ole loetav: $SRC"
[ -n "$(ls -A "$SRC")" ] || die 2 "Lähtekaust on tühi: $SRC"
SRC=$(cd "$SRC" && pwd)
SRC_PARENT=$(dirname "$SRC")
SRC_NAME=$(basename "$SRC")

# sihtkaust
mkdir -p "$DEST" 2>/dev/null || die 2 "Sihtkausta ei saa luua: $DEST"
[ -w "$DEST" ] || die 2 "Sihtkaust ei ole kirjutatav: $DEST"
DEST=$(cd "$DEST" && pwd)

# lukk - kaks varundust korraga ei tohi käia
LOCK_DIR="$DEST/.backupexec.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    LOCK_DIR=""
    die 8 "Teine varundus juba käib (lukk $DEST/.backupexec.lock). Kui see pole nii, kustuta lukk."
fi

# ajutine kaust sihtkaustas (sama failisüsteem -> mv on kiire ja turvaline)
TMP_DIR=$(mktemp -d "$DEST/.tmp_backup.XXXXXX") || die 1 "Ajutist kausta ei saa luua"
log "INFO" "Ajutine kaust: $TMP_DIR"

EXCLUDE_FILE="$TMP_DIR/excludes.txt"
build_excludes "$EXCLUDE_FILE"
log "INFO" "Välistused: $(tr '\n' ' ' < "$EXCLUDE_FILE")"

# ---------- 2. kuiv jooks (punkt 6) ----------
if [ "$DRY_RUN" -eq 1 ]; then
    log "INFO" "KUIV JOOKS - arhiivi ei looda. Arhiveeritakse:"
    tar --sort=name --exclude-from="$EXCLUDE_FILE" -cf - -C "$SRC_PARENT" "$SRC_NAME" | tar -tvf -
    FILES=$(tar --exclude-from="$EXCLUDE_FILE" -cf - -C "$SRC_PARENT" "$SRC_NAME" | tar -tf - | grep -vc '/$')
    log "INFO" "Kokku faile: $FILES. Kaustas $DEST uusi faile ei tekkinud."
    exit 0
fi

# ---------- 3. vaba ruumi kontroll (punkt 8) ----------
NEED=$(du -sb "$SRC" | awk '{print $1}')
FREE=$(df -B1 "$DEST" | awk 'NR==2{print $4}')
# auto režiimis tehakse ajutiselt kuni 3 arhiivi
COPIES=1
[ "$COMPRESSOR" = "auto" ] && COPIES=${#AVAILABLE[@]}
REQUIRED=$(( NEED * COPIES + MARGIN_MB * 1024 * 1024 ))
log "INFO" "Lähteandmed: $NEED B, vaba ruum: $FREE B, nõutav: $REQUIRED B"
if [ "$FREE" -lt "$REQUIRED" ]; then
    die 3 "Vaba ruumi on liiga vähe - varundust ei alustata"
fi
log "OK" "Vaba ruumi piisab"

# ---------- 4. arhiivi loomine ja kompressori valik (punktid 1, 10) ----------
STAMP=$(date '+%Y-%m-%d_%H-%M-%S')
if [ "$COMPRESSOR" = "auto" ]; then
    CANDIDATES=("${AVAILABLE[@]}")
else
    CANDIDATES=("$COMPRESSOR")
fi

BEST=""
BEST_SIZE=0
for c in "${CANDIDATES[@]}"; do
    out="$TMP_DIR/${SRC_NAME}_${STAMP}.$(extension "$c")"
    if make_archive "$c" "$out"; then
        size=$(stat -c %s "$out")
        log "INFO" "  $c: $size B"
        if [ -z "$BEST" ] || [ "$size" -lt "$BEST_SIZE" ]; then
            BEST="$c"; BEST_SIZE="$size"
        fi
    else
        log "WARN" "  $c: arhiveerimine ebaõnnestus"
        rm -f "$out"
    fi
done
[ -n "$BEST" ] || die 5 "Arhiveerimine ebaõnnestus kõigi kompressoritega"
[ "$COMPRESSOR" = "auto" ] && log "OK" "Valitud kompressor: $BEST (väikseim arhiiv)"

ARCHIVE_NAME="${SRC_NAME}_${STAMP}.$(extension "$BEST")"
TMP_ARCHIVE="$TMP_DIR/$ARCHIVE_NAME"
FINAL_ARCHIVE="$DEST/$ARCHIVE_NAME"

# kas sama nimega arhiiv on juba olemas?
if [ -e "$FINAL_ARCHIVE" ]; then
    die 4 "Arhiiv on juba olemas: $FINAL_ARCHIVE"
fi

# info olemasolevate arhiivide kohta + kas andmed on viimasest koopiast muutunud
LAST=$(ls -1t "$DEST/${SRC_NAME}"_*.tar.* 2>/dev/null | grep -v '\.sha256$' | head -n1)
EXISTING=$(ls -1 "$DEST/${SRC_NAME}"_*.tar.* 2>/dev/null | grep -vc '\.sha256$')
log "INFO" "Olemasolevaid varukoopiaid: $EXISTING"
if [ -n "$LAST" ]; then
    NEW_SUM=$(tar -I "$(decompress_cmd "$BEST")" -xOf "$TMP_ARCHIVE" 2>/dev/null | sha256sum | awk '{print $1}')
    OLD_SUM=$(tar -I "$(decompress_cmd "$(ext_to_compressor "$LAST")")" -xOf "$LAST" 2>/dev/null | sha256sum | awk '{print $1}')
    if [ "$NEW_SUM" = "$OLD_SUM" ]; then
        log "WARN" "Failide sisu on sama mis viimases koopias ($(basename "$LAST"))"
    else
        log "INFO" "Andmed on viimasest koopiast ($(basename "$LAST")) muutunud"
    fi
fi

# ---------- 5. arhiivi kontroll (punkt 2) ----------
LIST="$TMP_DIR/list.txt"
if ! tar -I "$(decompress_cmd "$BEST")" -tf "$TMP_ARCHIVE" > "$LIST" 2>/dev/null; then
    die 6 "Arhiiv ei avane: $ARCHIVE_NAME"
fi
SUBDIRS=$(grep -cE "^${SRC_NAME}/[^/]+/$" "$LIST")
if [ "$SUBDIRS" -lt 1 ]; then
    die 6 "Arhiivis pole ühtegi alamkausta"
fi
log "OK" "Arhiiv avaneb, kirjeid: $(grep -c '' "$LIST"), alamkaustu: $SUBDIRS"
head -n 5 "$LIST" | sed 's/^/        /'

# välistatud failid ei tohi arhiivis olla
if grep -qE '\.jpg$|/bin/' "$LIST"; then
    die 6 "Arhiivis on välistatud faile"
fi

# ---------- 6. teisaldamine ja SHA-256 (punkt 9) ----------
mv "$TMP_ARCHIVE" "$FINAL_ARCHIVE" || die 5 "Arhiivi ei saa teisaldada sihtkausta"
(
    cd "$DEST" || exit 1
    sha256sum "$ARCHIVE_NAME" > "$ARCHIVE_NAME.sha256" &&
    sha256sum -c --quiet "$ARCHIVE_NAME.sha256"
)
if [ $? -ne 0 ]; then
    rm -f "$FINAL_ARCHIVE" "$FINAL_ARCHIVE.sha256"
    die 7 "SHA-256 kontroll ebaõnnestus, arhiiv eemaldati"
fi
log "OK" "SHA-256: $(cut -d' ' -f1 "$FINAL_ARCHIVE.sha256")  OK"

# ---------- 7. suurus (punkt 3) ----------
log "OK" "Varukoopia: $FINAL_ARCHIVE ($(du -h "$FINAL_ARCHIVE" | awk '{print $1}'))"

# ---------- 8. vanade koopiate kustutamine (punkt 4) ----------
ls -1t "$DEST/${SRC_NAME}"_*.tar.* 2>/dev/null | grep -v '\.sha256$' | tail -n +$((KEEP + 1)) |
while read -r old; do
    rm -f "$old" "$old.sha256"
    log "INFO" "Kustutatud vana koopia: $(basename "$old")"
done
log "INFO" "Alles varukoopiaid: $(ls -1 "$DEST/${SRC_NAME}"_*.tar.* 2>/dev/null | grep -vc '\.sha256$') (max $KEEP)"

exit 0
