Nový Proxmox tuya-convert Kontajner
Tento skript vytvorí nový LXC kontajner na Proxmox s najnovším Debianom a nastaví tuya-convert. Pre vytvorenie nového LXC kontajnera spustite nasledujúce príkazy v SSH relácii alebo v konzole z rozhrania Proxmox:

```bash
bash -c "$(wget -qLO - https://github.com/FARKIr/moj_tuya_convert/raw/main/create_container.sh)"


V tomto príkaze sme len nahradili odkaz na skript na vytvorenie kontajnera tvojím vlastným odkazom. Uistite sa, že odkaz ukazuje na správny a aktuálny skript pre vytvorenie LXC kontajnera s tuya-convert.





Počas inštalačného procesu vás môže požiadať o výber umiestnenia úložiska alebo bezdrôtovej rozhranie (ak máte viac ako jednu použiteľnú možnosť). Bezdrôtové rozhranie bude priradené k kontajneru. (Poznámka: Keď je kontajner spustený, žiadny iný kontajner alebo virtuálny stroj nemá prístup k rozhraniu.) Po úspešnom dokončení skriptu spustite kontajner identifikovaný skriptom a potom použite prihlasovacie údaje zobrazené na spustenie skriptu tuya-convert. Ak potrebujete zastaviť tuya-convert, stlačte CTRL + C, tuya-convert sa zastaví a vráti sa vás k prihláseniu. Ak sa znovu prihlásite, tuya-convert sa opäť spustí.

Predpoklad
Aby tento skript správne fungoval, musíte mať najprv nainštalované a správne nastavené ovládače pre váš WiFi adaptér v Proxmox. Na začiatku skriptu sa skontroluje, či existujú platné bezdrôtové rozhrania. Ak nie, vygeneruje sa chyba.

Vlastný Firmware
Pre pridanie vlastného firmvéru (nie dodávaného tuya-convert) sa pripojte k samba share vytvorenej kontajnerom (podrobnosti sú uvedené pri prihlásení) a pridajte binárny súbor do priečinka tuya-convert/files/. Váš binárny súbor bude uvedený v ponuke vlastného firmvéru.
