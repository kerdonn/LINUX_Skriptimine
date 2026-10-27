#!/bin/bash
# SHA-256 kontrollsumma mini-praktikum
# 1) loob faili ja arvutab kontrollsumma
# 2) kontrollib (OK)
# 3) "rikub" faili ja kontrollib uuesti (FAILED)
# 4) mitme faili korraga kontroll checksums.txt abil

TOO_KAUST=$(mktemp -d)
# Ajutine kaust kustutatakse skripti lõpus automaatselt
trap 'rm -rf "$TOO_KAUST"' EXIT
cd "$TOO_KAUST" || exit 1

echo "== 1) Summa arvutamine =="
echo "hello" > demo.txt
sha256sum demo.txt > demo.txt.sha256
cat demo.txt.sha256

echo
echo "== 2) Summa kontrollimine =="
sha256sum -c demo.txt.sha256

echo
echo "== 3) Fail muudetakse (lisatakse 1 rida) ja kontrollitakse uuesti =="
echo "x" >> demo.txt
sha256sum -c demo.txt.sha256
echo "sha256sum väljumiskood: $? (0 = OK, 1 = FAILED)"

echo
echo "== 4) Mitme arhiivi korraga kontroll =="
mkdir src && echo "andmed" > src/fail.txt
tar -czf src_1.tar.gz src
tar -cJf src_2.tar.xz src
# -print0 ja -0 töötlevad õigesti ka tühikutega failinimesid
find . -maxdepth 1 -type f -name '*.tar.*' -print0 | xargs -0 sha256sum > checksums.txt
cat checksums.txt
sha256sum -c checksums.txt
