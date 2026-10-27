#!/bin/bash
# Ülesanne 4 - Funktsioon tuleb enne defineerida
# Bash loeb skripti ülevalt alla, seega funktsioon peab olema defineeritud enne kasutamist.

echo "--- Probleemne variant (kutse enne defineerimist) ---"
# Käivitame vale järjekorraga koodi eraldi bash protsessis, et näha veateadet
bash -c 'hello; hello() { echo "Hello!"; }' 2>&1

echo "--- Õige variant ---"
hello() {
    echo "Hello!"
}
hello
