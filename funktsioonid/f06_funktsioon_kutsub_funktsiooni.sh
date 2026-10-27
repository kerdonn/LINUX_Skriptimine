#!/bin/bash
# Ülesanne 6 - Funktsioonid võivad kutsuda teisi funktsioone
#
# show_system
#    |
#    +-- show_user
#    |
#    +-- show_host

show_user() {
    echo "Kasutaja:"
    whoami
}

show_host() {
    echo "Arvuti:"
    hostname
}

# Suurem funktsioon koosneb väiksematest
show_system() {
    show_user
    show_host
}

show_system
