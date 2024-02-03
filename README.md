
Nový Proxmox tuya-convert Kontajner

Tento skript vytvorí nový LXC kontajner na Proxmox s najnovším Debianom a nastaví tuya-convert. Pre vytvorenie nového LXC kontajnera spustite nasledujúce príkazy v SSH relácii alebo v konzole z rozhrania Proxmox:


Počas inštalačného procesu vás môže skript vyzvať, aby ste vybrali miesto uloženia alebo bezdrôtové rozhranie (ak máte viac než jednu použiteľnú možnosť). Bezdrôtové rozhranie bude pridelené kontajneru. (Poznámka: Keď je kontajner spustený, žiadny iný kontajner alebo VM nemá prístup k rozhraniu.) Po úspešnom dokončení skriptu spustite kontajner identifikovaný skriptom a potom použite prihlasovacie údaje zobrazené na spustenie skriptu tuya-convert. Ak potrebujete zastaviť tuya-convert, stlačte CTRL + C, tuya-convert sa zastaví a vrátite sa na prihlasovaciu obrazovku. Ak sa znova prihlásite, tuya-convert sa znovu spustí.

Prerekvizity

Aby tento skript správne fungoval, musíte mať nainštalované a správne nastavené ovládače pre váš WiFi adaptér v Proxmox. Na začiatku skriptu sa otestuje existencia platných WLAN rozhraní. Ak nie je nájdené žiadne, vytvorí sa chybové hlásenie.

Vlastný firmware

Ak chcete pridať vlastný firmware (nie dodaný tuya-convert), pripojte sa na samba zdieľaný priečinok vytvorený kontajnerom (podrobnosti sú uvedené v prihlasovacom prompte) a pridajte binárny súbor do priečinka tuya-convert/files/. Váš binárny súbor bude uvedený v ponuke vlastného firmvéru.

bash -c "$(wget -qLO - https://github.com/whiskerz007/proxmox_tuya-convert_container/raw/master/create_container.sh)"

```bash
bash -c "$(wget -qLO - https://github.com/FARKIr/moj_tuya_convert/raw/mmain/create_container.sh)"
