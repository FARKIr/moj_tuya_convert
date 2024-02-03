#!/usr/bin/env bash

# Nastavenie skriptu
set -o errexit   # Okamžite ukončiť, ak potrubie vráti nenulový stav
set -o errtrace  # Zachytiť ERR z funkcií shellu, podstitučných príkazov a príkazov zo subshellu
set -o nounset   # Považovať nespravené premenné za chybu
set -o pipefail  # Potrubie skončí posledným nenulovým stavom, ak je to možné
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR

function error_exit() {
  trap - ERR
  local DEFAULT='Vyskytla sa neznáma chyba.'
  local REASON="\e[97m${1:-$DEFAULT}\e[39m"
  local FLAG="\e[91m[CHYBA:LXC] \e[93m$EXIT@$LINE"
  msg "$FLAG $REASON"
  exit $EXIT
}

function warn() {
  local REASON="\e[97m$1\e[39m"
  local FLAG="\e[93m[VÝSTR] \e[39m"
  msg "$FLAG $REASON"
}

function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}

# Predvolené premenné
LOCALE=${1:-sk_SK.UTF-8}
USERNAME="roman"
INSTALL_LOCATION="local"

# Príprava operačného systému kontajnera
msg "Prispôsobuje sa operačný systém kontajnera..."
echo "root:tuya" | chpasswd
sed -i "s/\(# \)\($LOCALE.*\)/\2/" /etc/locale.gen
export LANGUAGE=$LOCALE LANG=$LOCALE
locale-gen >/dev/null
cd /root

# Detekcia DHCP adresy
while [ "$(hostname -I)" = "" ]; do
  COUNT=$((${COUNT-} + 1))
  warn "Nepodarilo sa získať IP adresu, čaká sa...$COUNT"
  if [ $COUNT -eq 10 ]; then
    die "Nepodarilo sa overiť pridelenú IP adresu."
  fi
  sleep 1
done

# Aktualizácia operačného systému kontajnera
msg "Aktualizuje sa operačný systém kontajnera..."
apt-get update >/dev/null
apt-get -qqy upgrade &>/dev/null

# Inštalácia závislostí
msg "Inštalujú sa závislosti..."
echo "samba-common samba-common/dhcp boolean false" | debconf-set-selections
apt-get -qqy install \
  git curl network-manager net-tools samba &>/dev/null

# Klonovanie tuya-convert
msg "Klonuje sa tuya-convert..."
git clone --quiet https://github.com/ct-Open-Source/tuya-convert

# Konfigurácia tuya-convert
msg "Konfiguruje sa tuya-convert..."
./configure_tuya-convert.sh

# Inštalácia tuya-convert
msg "Spúšťa sa tuya-convert/install_prereq.sh..."
cd tuya-convert
./install_prereq.sh &>/dev/null
systemctl disable dnsmasq &>/dev/null
systemctl disable mosquitto &>/dev/null

# Prispôsobenie OS
msg "Prispôsobuje sa OS..."
cat <<EOL >> /etc/samba/smb.conf
[tuya-convert]
  path = /root/tuya-convert
  browseable = yes
  writable = yes
  public = yes
  force user = root
EOL
cat <<EOL >> /etc/issue
  ******************************
    Súbory tuya-convert sú
    zdieľané pomocou samba na
    \4{eth0}
  ******************************

  Prihlásiť sa môžete pomocou nasledujúcich prihlasovacích údajov
    užívateľ: root
    heslo: tuya

EOL
sed -i "s/^\(root\)\(.*\)\(\/bin\/bash\)$/\1\2\/root\/login.sh/" /etc/passwd

# Úklid
msg "Úklid..."
rm -rf /root/install_tuya-convert.sh /var/{cache,log}/* /var/lib/apt/lists/*
