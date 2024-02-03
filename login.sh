#!/usr/bin/env bash

# Nastavenie skriptu
set -o errexit  # Ukončiť okamžite, ak potrubie vráti nenulový status
set -o errtrace # Chyba z funkcií shell, náhrady príkazov a príkazov zo subshell
set -o nounset  # Nastaviť nedefinované premenné ako chybu
set -o pipefail # Potrubie skončí s posledným nenulovým statusom, ak je to možné
trap "{ echo -e '\nUkončenie'; exit 1; }" SIGINT SIGTERM

cd /root/tuya-convert/
git fetch origin >/dev/null
WORKING_COMMIT=$(git show -s --format='%h')
LATEST_COMMIT=$(git show-ref --hash=7 origin/master)
if [ "$WORKING_COMMIT" != "$LATEST_COMMIT" ]; then
  RESPONSE=$(
    whiptail --title "tuya-convert je zastaraný" --yesno --defaultno \
    "Chcete zmeniť aktuálnu verziu?" \
    9 40 \
    3>&1 1>&2 2>&3
  ) && /root/commit_switcher.sh
fi
./start_flash.sh
echo "tuya-convert skončil so stavom kódu: $?"
