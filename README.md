Nový Proxmox tuya-convert Kontajner
Tento skript vytvorí nový LXC kontajner na Proxmox s najnovším Debianom a nastaví tuya-convert. Pre vytvorenie nového LXC kontajnera spustite nasledujúce príkazy v SSH relácii alebo v konzole z rozhrania Proxmox:


V tomto príkaze sme len nahradili odkaz na skript na vytvorenie kontajnera tvojím vlastným odkazom. Uistite sa, že odkaz ukazuje na správny a aktuálny skript pre vytvorenie LXC kontajnera s tuya-convert.

Počas inštalačného procesu vás môže požiadať o výber umiestnenia úložiska alebo bezdrôtovej rozhranie (ak máte viac ako jednu použiteľnú možnosť). Bezdrôtové rozhranie bude priradené k kontajneru. (Poznámka: Keď je kontajner spustený, žiadny iný kontajner alebo virtuálny stroj nemá prístup k rozhraniu.) Po úspešnom dokončení skriptu spustite kontajner identifikovaný skriptom a potom použite prihlasovacie údaje zobrazené na spustenie skriptu tuya-convert. Ak potrebujete zastaviť tuya-convert, stlačte CTRL + C, tuya-convert sa zastaví a vráti sa vás k prihláseniu. Ak sa znovu prihlásite, tuya-convert sa opäť spustí.

Predpoklad
Aby tento skript správne fungoval, musíte mať najprv nainštalované a správne nastavené ovládače pre váš WiFi adaptér v Proxmox. Na začiatku skriptu sa skontroluje, či existujú platné bezdrôtové rozhrania. Ak nie, vygeneruje sa chyba.

Vlastný Firmware
Pre pridanie vlastného firmvéru (nie dodávaného tuya-convert) sa pripojte k samba share vytvorenej kontajnerom (podrobnosti sú uvedené pri prihlásení) a pridajte binárny súbor do priečinka tuya-convert/files/. Váš binárny súbor bude uvedený v ponuke vlastného firmvéru.

Nový Proxmox tuya-convert kontajner
Tento skript vytvorí nový Proxmox LXC kontajner s najnovším Debianom a nastaví tuya-convert. Na vytvorenie nového LXC kontajnera spustite nasledovné v SSH relácii alebo konzole z Proxmox rozhrania:

bash
Copy code
bash -c "$(wget -qLO - https://github.com/FARKIr/moj_tuya_convert/raw/master/create_container.sh)"
Počas inštalačného procesu vás môže skript vyzvať, aby ste vybrali miesto uloženia alebo bezdrôtové rozhranie (ak máte viac než jednu použiteľnú možnosť). Bezdrôtové rozhranie bude pridelené kontajneru. (Poznámka: Keď je kontajner spustený, žiadny iný kontajner alebo VM nemá prístup k rozhraniu.) Po úspešnom dokončení skriptu spustite kontajner identifikovaný skriptom a potom použite prihlasovacie údaje zobrazené na spustenie skriptu tuya-convert. Ak potrebujete zastaviť tuya-convert, stlačte CTRL + C, tuya-convert sa zastaví a vrátite sa na prihlasovaciu obrazovku. Ak sa znova prihlásite, tuya-convert sa znovu spustí.

Prerekvizity
Aby tento skript správne fungoval, musíte mať nainštalované a správne nastavené ovládače pre váš WiFi adaptér v Proxmox. Na začiatku skriptu sa otestuje existencia platných WLAN rozhraní. Ak nie je nájdené žiadne, vytvorí sa chybové hlásenie.

Vlastný firmware
Ak chcete pridať vlastný firmware (nie dodaný tuya-convert), pripojte sa na samba zdieľaný priečinok vytvorený kontajnerom (podrobnosti sú uvedené v prihlasovacom prompte) a pridajte binárny súbor do priečinka tuya-convert/files/. Váš binárny súbor bude uvedený v ponuke vlastného firmvéru.




 
```bash
bash -c "$(wget -qLO - https://github.com/FARKIr/moj_tuya_convert/raw/main/create_container.sh)"
