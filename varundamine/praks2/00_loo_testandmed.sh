#!/bin/bash
# Testandmete loomine varundusülesannete jaoks
# Loob kausta ~/praks2/src alamkaustadega docs, imgs, bin ja data
# ning kaustad ~/praks2/backup (varukoopiad) ja ~/praks2/logs (logid).

PRAKS="$HOME/praks2"
SRC="$PRAKS/src"

mkdir -p "$SRC"/{docs,imgs,bin,data} "$PRAKS/backup" "$PRAKS/logs"

echo "Projekti dokumentatsioon" > "$SRC/docs/a.txt"
echo "# Märkmed" > "$SRC/docs/notes.md"
# "pildid" - suvaline binaarne sisu
head -c 20000 /dev/urandom > "$SRC/imgs/b.jpg"
head -c 10000 /dev/urandom > "$SRC/imgs/c.png"
printf '#!/bin/bash\necho "run"\n' > "$SRC/bin/run.sh"
chmod +x "$SRC/bin/run.sh"
# hästi pakitav tekstiandmestik
seq 1 20000 > "$SRC/data/numbrid.txt"
# .backupignore - välistusreeglid (ül 11)
printf 'imgs/\n*.tmp\n' > "$SRC/.backupignore"
echo "ajutine" > "$SRC/data/vahemalu.tmp"

echo "Testandmed loodud:"
find "$SRC" | sort
