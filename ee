#!/usr/bin/env bash

# Nastavenie skriptu
set -o errexit  # Okamžité ukončenie pri návrate potrubia s nenulovým stavom
set -o errtrace # Zachytiť ERR zo shell funkcií, podstitučných príkazov a príkazov zo subshell
set -o nounset  # Považovať nespravené premenné za chybu
set -o pipefail # Potrubie ukončí posledným nenulovým stavom, ak je to možné
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
trap cleanup EXIT

function error_exit() {
  trap - ERR
  local DEFAULT='Neznáma chyba.'
  local REASON="\e[97m${1:-$DEFAULT}\e[39m"
  local FLAG="\e[91m[CHYBA] \e[93m$EXIT@$LINE"
  msg "$FLAG $REASON"
  [ ! -z ${CTID-} ] && cleanup_failed
  exit $EXIT
}
function warn() {
  local REASON="\e[97m$1\e[39m"
  local FLAG="\e[93m[VARNUNG]\e[39m"
  msg "$FLAG $REASON"
}
function info() {
  local REASON="$1"
  local FLAG="\e[36m[INFORMÁCIA]\e[39m"
  msg "$FLAG $REASON"
}
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}
function cleanup_failed() {
  if [ ! -z ${MOUNT+x} ]; then
    pct unmount $CTID
  fi
  if $(pct status $CTID &>/dev/null); then
    if [ "$(pct status $CTID | awk '{print $2}')" == "running" ]; then
      pct stop $CTID
    fi
    pct destroy $CTID
  elif [ "$(pvesm list $STORAGE --vmid $CTID)" != "" ]; then
    pvesm free $ROOTFS
  fi
}
function cleanup() {
  popd >/dev/null
  rm -rf $TEMP_DIR
}
TEMP_DIR=$(mktemp -d)
pushd $TEMP_DIR >/dev/null

# Stiahnuť setup a login skripty
GITHUB=https://github.com/
GITHUB_REPO=FARKIr/moj_tuya_convert
GITHUB_REPO_BRANCH=master
URL=${GITHUB}${GITHUB_REPO}/raw/${GITHUB_REPO_BRANCH}
wget -qL ${URL}/{commit_switcher,configure_tuya-convert,install_tuya-convert,login}.sh

# Kontrola závislostí
which iw >/dev/null || (
  apt-get update >/dev/null
  apt-get -qqy install iw &>/dev/null ||
    die "Nie je možné nainštalovať potrebné balíky."
)

# Generovanie grafického menu pre umiestnenie úložiska
while read -r line; do
  TAG=$(echo $line | awk '{print $1}')
  TYPE=$(echo $line | awk '{printf "%-10s", $2}')
  FREE=$(
    echo $line | \
    numfmt --field 4-6 --from-unit=K --to=iec --format %.2f | \
    awk '{printf( "%9sB", $6)}'
  )
  ITEM="  Typ: $TYPE Voľné: $FREE "
  OFFSET=2
  if [[ $((${#ITEM} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
    MSG_MAX_LENGTH=$((${#ITEM} + $OFFSET))
  fi
  STORAGE_MENU+=( "$TAG" "$ITEM" "OFF" )
done < <(pvesm status -content rootdir | awk 'NR>1')
if [ $((${#STORAGE_MENU[@]}/3)) -eq 0 ]; then
  warn "'Container' musí byť vybraný pre aspoň jedno úložisko."
  die "Nie je možné identifikovať platné umiestnenie úložiska."
elif [ $((${#STORAGE_MENU[@]}/3)) -eq 1 ]; then
  STORAGE=${STORAGE_MENU[0]}
else
  while [ -z "${STORAGE:+x}" ]; do
    STORAGE=$(
      whiptail --title "Úložiská" --radiolist \
      "Ktoré úložisko chcete použiť?\n\n" \
      15 $(($MSG_MAX_LENGTH + 23)) 6 "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3
    ) || exit
  done
fi
info "Používa sa úložisko '$STORAGE'."

# Získanie rozhraní WLAN schopných byť predaných do LXC
FAILED_SUPPORT=false
mapfile -t WLANS < <(
  iw dev | \
  sed -n 's/phy#\([0-9]\)*/\1/p; s/[[:space:]]Interface \(.*\)/\1/p'
)
for i in $(seq 0 2 $((${#WLANS[@]}-1)));do
  FEATURES=( $(
    iw phy${WLANS[i]} info | \
    sed -n '/\bSupported interface modes:/,/\bBand/{/Supported/d;/Band/d;s/\( \)*\* //;p;}'
  ) )
  SUPPORTED=false
  for feature in "${FEATURES[@]}"; do
    if [ "AP" == $feature ]; then
      SUPPORTED=true
      WLANS_READY+=(${WLANS[i+1]})
    fi
  done
  if ! $SUPPORTED; then
    FAILED_SUPPORT=true
  fi
done
if [ -z ${WLANS_READY+x} ] && $FAILED_SUPPORT; then
  die "Jedno alebo viac detegovaných adaptérov WiFi nepodporuje 'AP režim'. Skúste iný adaptér."
elif [ -z ${WLANS_READY+x} ]; then
  die "Nie je možné identifikovať použiteľné adaptéry WiFi. Ak je adaptér aktuálne pripojený, skontrolujte ovládače."
elif [ ${#WLANS_READY[@]} -eq 1 ]; then
  WLAN=${WLANS_READY[0]}
else
  for interface in "${WLANS_READY[@]}"; do
    CMD="udevadm info --query=property /sys/class/net/$interface"
    MAKE=$($CMD | sed -n -e 's/ID_VENDOR_FROM_DATABASE=//p')
    MODEL=$($CMD | sed -n -e 's/ID_MODEL_FROM_DATABASE=//p')
    OFFSET=2
    if [[ $((${#MAKE} + ${#MODEL} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
      MSG_MAX_LENGTH=$((${#MAKE} + ${#MODEL} + $OFFSET))
    fi
    WLAN_MENU+=( $interface "$MAKE $MODEL " "off")
  done
  while [ -z "${WLAN:+x}" ]; do
    WLAN=$(
      whiptail --title "WLAN Rozhrania" --radiolist --notags \
      "Ktoré WLAN rozhranie chcete použiť pre kontajner?\n\n" \
      15 $(($MSG_MAX_LENGTH + 14)) 6 "${WLAN_MENU[@]}" 3>&1 1>&2 2>&3
    ) || exit
  done
fi
info "Používa sa WLAN rozhranie '$WLAN'."

# Získať ďalší voľný VM/LXC ID
CTID=$(pvesh get /cluster/nextid)
info "ID kontajnera je $CTID."

# Stiahnuť najnovší Debian LXC šablónu
msg "Aktualizácia zoznamu LXC šablón..."
pveam update >/dev/null
msg "Stiahnutie LXC šablóny..."
OSTYPE=debian
OSVERSION=${OSTYPE}-10
mapfile -t TEMPLATES < <(
  pveam available -section system | \
  sed -n "s/.*\($OSVERSION.*\)/\1/p" | \
  sort -t - -k 2 -V
)
TEMPLATE="${TEMPLATES[-1]}"
pveam download local $TEMPLATE >/dev/null ||
  die "Pri stahovaní LXC šablóny došlo k problému."

# Vytvorenie premenných pre disk kontajnera
STORAGE_TYPE=$(pvesm status -storage $STORAGE | awk 'NR>1 {print $2}')
case $STORAGE_TYPE in
  dir|nfs)
    DISK_EXT=".raw"
    DISK_REF="$CTID/"
    ;;
  zfspool)
    DISK_PREFIX="subvol"
    DISK_FORMAT="subvol"
    ;;
esac
DISK=${DISK_PREFIX:-vm}-${CTID}-disk-0${DISK_EXT-}
ROOTFS=${STORAGE}:${DISK_REF-}${DISK}

# Vytvorenie LXC
msg "Vytváranie LXC kontajnera..."
pvesm alloc $STORAGE $CTID $DISK 2G --format ${DISK_FORMAT:-raw} >/dev/null
if [ "$STORAGE_TYPE" != "zfspool" ]; then
  mkfs.ext4 $(pvesm path $ROOTFS) &>/dev/null
fi
ARCH=$(dpkg --print-architecture)
HOSTNAME=tuya-convert
TEMPLATE_STRING="local:vztmpl/${TEMPLATE}"
pct create $CTID $TEMPLATE_STRING -arch $ARCH -cores 1 -hostname $HOSTNAME \
  -net0 name=eth0,bridge=vmbr0,ip=dhcp -ostype $OSTYPE \
  -rootfs $ROOTFS -storage $STORAGE >/dev/null

# Preniesť sieťové rozhranie do LXC
cat <<EOF >> /etc/pve/lxc/${CTID}.conf
lxc.net.1.type: phys
lxc.net.1.name: ${WLAN}
lxc.net.1.link: ${WLAN}
lxc.net.1.flags: up
EOF

# Nastavenie časového pásma kontajnera tak, aby zodpovedalo hostovi
MOUNT=$(pct mount $CTID | cut -d"'" -f 2)
ln -fs $(readlink /etc/localtime) ${MOUNT}/etc/localtime
pct unmount $CTID && unset MOUNT

# Nastavenie kontajnera pre tuya-convert
msg "Spúšťanie LXC kontajnera..."
pct start $CTID
pct push $CTID commit_switcher.sh /root/commit_switcher.sh -perms 755
pct push $CTID configure_tuya-convert.sh /root/configure_tuya-convert.sh -perms 755
pct push $CTID install_tuya-convert.sh /root/install_tuya-convert.sh -perms 755
pct push $CTID login.sh /root/login.sh -perms 755
pct exec $CTID /root/install_tuya-convert.sh $LANG
pct stop $CTID

info "Úspešne vytvorený tuya-convert LXC s ID $CTID."
