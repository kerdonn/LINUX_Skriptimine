# LINUX_Skriptimine

Kursuse **Skriptimisvahendid** BASH skriptide ülesanded.
Autor: Kerdon Laubert. Masin: Ubuntu Server 24.04 LTS, `ls-kerdon`.

## Struktuur

| Kaust | Sisu |
|---|---|
| `funktsioonid/` | Funktsioonide teooria 19 näidet/harjutust (`f01`…`f19`, `functions.sh`) |
| `loto/1_loto_mang/` | Ülesanne: Loto mäng (`lottery.sh`) |
| `loto/2_loto_funktsioonidega/` | Ülesanne: funktsioonide kasutamine |
| `loto/3_loto_failidesse/` | Ülesanne: funktsioonide jagamine failidesse (`./lottery.sh` + `input.sh`, `lottery_functions.sh`, `result.sh`, `files.sh`) |
| `kasutajate_haldus/` | Kasutajate halduse ülesanded 1–6 |
| `sha256/` | SHA-256 kontrollsumma mini-praktikum |
| `varundamine/` | Kodukataloogide varundamine `/home_bcp` kausta (`home_backup.sh`) |
| `varundamine/praks2/` | „Varukoopia kuupäevaga ja kontrolliga“ punktid 1–11 ja `backupexec.sh` (punkt 12) + `test_backupexec.sh` |
| `teenused/` | Veebiserveri paigaldamine (`apache_paigaldus.sh`) |

## Kasutajate haldus

| Ülesanne | Skript | Näide |
|---|---|---|
| 1 | `lisa_kasutaja` | `sudo sh lisa_kasutaja kasutajanimi` |
| 2 | `kasutajad_failist` | `sudo sh kasutajad_failist kasutajad` |
| 3 | `kasutajad_failist_parooliga` | `sudo sh kasutajad_failist_parooliga kasutajad_paroolid` |
| 4 | `kasutajad_ja_paroolid` | `sudo sh kasutajad_ja_paroolid kasutajad_nimed paroolid` |
| 5 | `kasutajad_genereeritud_paroolidega` | `sudo sh kasutajad_genereeritud_paroolidega uued_kasutajad` |
| 6 | `kasutajad_ainult_root` | root kasutajana: `sh kasutajad_ainult_root uued_kasutajad2` |
| abi | `kustuta_kasutajad` | `sudo sh kustuta_kasutajad kasutajad` |

## Varundamine (backupexec.sh)

```bash
cd varundamine/praks2
./00_loo_testandmed.sh          # testandmed ~/praks2/src
./backupexec.sh                 # auto kompressor, alles 3 koopiat
./backupexec.sh -c zstd -k 5    # zstd, alles 5 koopiat
./backupexec.sh -n              # kuiv jooks
./backupexec.sh -h              # abi
./test_backupexec.sh            # mini-test
```

Skript kontrollib vaba ruumi, olemasolevaid arhiive, arhiivi avanemist ja
alamkaustade olemasolu, SHA-256 kontrollsummat, välistab failid
(`*.jpg`, `bin`, `.backupignore`), logib faili `~/praks2/logs/backup.log`,
kustutab ajutised failid (`mktemp -d` + `trap`) ja vanad varukoopiad.

## Veebiserver

```bash
sudo ./teenused/apache_paigaldus.sh
```
