#!/usr/bin/env bash

# Nastavenie skriptu
set -o errexit   # Okamžite ukončiť, ak potrubie vráti nenulový stav
set -o errtrace  # Zachytiť ERR z funkcií shellu, podstitučných príkazov a príkazov zo subshellu
set -o nounset   # Považovať nespravené premenné za chybu
set -o pipefail  # Potrubie skončí posledným nenulovým stavom, ak je to možné

# Prejdite do priečinka tuya-convert
cd /root/tuya-convert

# Odstránenie "sudo" z príkazov v skriptoch
find ./ -name \*.sh -exec sed -i -e "s/sudo \(-\S\+ \)*//" {} \;

# Získanie názvu bezdrôtového rozhrania (WLAN)
WLAN=$(iw dev | sed -n 's/[[:space:]]Interface \(.*\)/\1/p')
sed -i "s/^\(WLAN=\)\(.*\)/\1$WLAN/" config.txt

# # Spustenie skriptu configure_tuya-convert.sh
# ./configure_tuya-convert.sh
