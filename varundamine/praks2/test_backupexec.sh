#!/bin/bash
# Mini-test backupexec.sh skriptile (punkt 12)
# Iga test käivitab backupexec.sh ajutises keskkonnas ja kontrollib tulemust.
# Lõpus kuvatakse kokkuvõte: mitu testi läbis / kukkus.

SKRIPT="$(cd "$(dirname "$0")" && pwd)/backupexec.sh"
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

SRC="$T/src"
DEST="$T/backup"
export HOME="$T"            # logi läheb ajutisse kausta $T/praks2/logs
PASS=0; FAIL=0

# testandmed
mkdir -p "$SRC"/{docs,imgs,bin,data}
echo "dok" > "$SRC/docs/a.txt"
head -c 5000 /dev/urandom > "$SRC/imgs/b.jpg"
echo 'echo run' > "$SRC/bin/run.sh"
seq 1 5000 > "$SRC/data/n.txt"

check() {   # check "kirjeldus" tingimus...
    local desc="$1"; shift
    if "$@"; then echo "PASS: $desc"; PASS=$((PASS+1)); else echo "FAIL: $desc"; FAIL=$((FAIL+1)); fi
}
run() { "$SKRIPT" -s "$SRC" -d "$DEST" "$@" > "$T/out.txt" 2>&1; echo $?; }
count() { ls -1 "$DEST"/src_*.tar.* 2>/dev/null | grep -vc '\.sha256$'; }

echo "=== 1. Tavaline varundus zstd-ga"
rc=$(run -c zstd)
check "väljumiskood 0" [ "$rc" -eq 0 ]
check "arhiiv ja .sha256 on olemas" [ "$(ls "$DEST"/*.tar.zst.sha256 2>/dev/null | wc -l)" -eq 1 ]
check "sha256sum -c on OK" bash -c "cd '$DEST' && sha256sum -c --quiet *.sha256"
check "välistatud b.jpg ja bin puuduvad" bash -c "! tar -I 'zstd -d' -tf $DEST/*.tar.zst | grep -qE 'b.jpg|bin/'"

echo "=== 2. Kuiv jooks ei loo faile"
before=$(ls -1 "$DEST" | wc -l); sleep 1
rc=$(run -n)
check "väljumiskood 0" [ "$rc" -eq 0 ]
check "uusi faile ei tekkinud" [ "$(ls -1 "$DEST" | wc -l)" -eq "$before" ]

echo "=== 3. Puuduv lähtekaust"
rc=$("$SKRIPT" -s "$T/puudub" -d "$DEST" > /dev/null 2>&1; echo $?)
check "väljumiskood 2" [ "$rc" -eq 2 ]

echo "=== 4. Liiga vähe vaba ruumi (simuleeritud suure varuga)"
rc=$(run -m 99999999)
check "väljumiskood 3" [ "$rc" -eq 3 ]

echo "=== 5. Vale kompressor"
rc=$(run -c rar)
check "väljumiskood 1" [ "$rc" -eq 1 ]

echo "=== 6. Auto valib väikseima kompressori"
sleep 1; rc=$(run -c auto)
check "väljumiskood 0" [ "$rc" -eq 0 ]
check "logis on valitud kompressor" grep -q "Valitud kompressor" "$T/out.txt"

echo "=== 7. .backupignore"
printf 'docs/\n' > "$SRC/.backupignore"
sleep 1; rc=$(run -c gzip)
newest=$(ls -1t "$DEST"/*.tar.gz | head -n1)
check "docs puudub arhiivist" bash -c "! tar -tzf '$newest' | grep -q 'docs'"
rm -f "$SRC/.backupignore"

echo "=== 8. Alles jääb ainult 3 uuemat koopiat"
for i in 1 2 3 4 5; do sleep 1; run -c gzip -k 3 > /dev/null; done
check "arhiive on 3" [ "$(count)" -eq 3 ]
check "sha256 faile on 3" [ "$(ls -1 "$DEST"/*.sha256 | wc -l)" -eq 3 ]

echo "=== 9. Ajutised failid ja lukk on koristatud"
check "ajutist kausta pole" [ -z "$(ls -A "$DEST" | grep -E '^\.tmp_backup|\.lock')" ]

echo "=== 10. Rikutud arhiivi tuvastab SHA-256"
a=$(ls -1t "$DEST"/*.tar.gz | head -n1)
echo "rikutud" >> "$a"
check "sha256sum -c annab vea" bash -c "cd '$DEST' && ! sha256sum -c --quiet '$(basename "$a").sha256' 2>/dev/null"

echo "=== 11. Lukk takistab samaaegset käivitust"
mkdir "$DEST/.backupexec.lock"
rc=$(run -c gzip)
check "väljumiskood 8" [ "$rc" -eq 8 ]
rmdir "$DEST/.backupexec.lock"

echo
echo "Kokkuvõte: läbis $PASS, kukkus $FAIL"
[ "$FAIL" -eq 0 ]
