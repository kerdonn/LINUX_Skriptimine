#!/bin/bash
# Ülesanne 18 - Praktiline näide: süsteemi info funktsioonidega
# Põhiprogramm ütleb MIDA tehakse, funktsioonid KUIDAS.

show_header() {
    echo "======================"
    echo "     SYSTEM INFO"
    echo "======================"
}

show_user() {
    echo "Kasutaja: $(whoami)"
}

show_host() {
    echo "Arvuti: $(hostname)"
}

show_kernel() {
    echo "Kernel: $(uname -r)"
}

show_disk() {
    echo
    echo "Kettakasutus:"
    df -h /
}

# Põhiprogramm
show_header
show_user
show_host
show_kernel
show_disk
