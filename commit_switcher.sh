#!/usr/bin/env bash

# Nastavenie skriptu
set -o errexit   # Okamžite ukončiť, ak potrubie vráti nenulový stav
set -o errtrace  # Zachytiť ERR z funkcií shellu, podstitučných príkazov a príkazov zo subshellu
set -o nounset   # Považovať nespravené premenné za chybu
set -o pipefail  # Potrubie skončí posledným nenulovým stavom, ak je to možné

# Prejdite do priečinka tuya-convert
cd /root/tuya-convert

# Nastavenie premenných
TITLE="tuya-convert Commit Switcher"
WORKING_COMMIT=$(git show -s --format="%h")
COMMIT_MESSAGE_LENGTH=50

# Získanie zoznamu commitov
git fetch origin
for i in $(git log --format="%h" origin/master); do
  TAG=$i
  LINE=$(git log --format='(%ar) %s' -n 1 $i)
  if [ ${#LINE} -gt $COMMIT_MESSAGE_LENGTH ]; then
    LINE=$(
      echo $LINE | \
      cut -c 1-$(($COMMIT_MESSAGE_LENGTH - 3)) | \
      sed 's/\(.*\)$/\1.../'
    )
  fi
  MENU+=( "$TAG" "$LINE" )
done

# Používateľské rozhranie na výber commitu
COMMIT=$(
  whiptail --title "$TITLE" --menu --default-item $WORKING_COMMIT \
  "\nVyberte commit, na ktorý chcete prepnúť." \
  19 66 10 "${MENU[@]}" 3>&1 1>&2 2>&3
) || exit $?

# Overenie, či sa vybraný commit líši od aktuálneho pracovného commitu
if [ "$WORKING_COMMIT" == "$COMMIT" ]; then
  whiptail --title "$TITLE" --msgbox \
    "Vybrali ste rovnaký commit, ktorý je v súčasnosti spustený.
    \nNebude vykonaná žiadna zmena." \
    11 40
  exit
fi

# Potvrdenie zmeny commitu
RESPONSE=$(
  whiptail --title "$TITLE" --yesno \
  "Chcete prepnúť na nasledujúci commit?\n
  \n$(git log --no-decorate -n 1 $COMMIT)" \
  20 60 3>&1 1>&2 2>&3
) || exit $?

# Prepnutie na vybraný commit a spustenie configure_tuya-convert.sh
git checkout -f $COMMIT
/root/configure_tuya-convert.sh
