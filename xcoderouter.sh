#!/bin/bash
#Progammer : Kurniawan. trainingxcode@gmail.com. xcode.or.id.
again='y'
while [ $again == 'Y' ] || [ $again == 'y' ];
do
clear
echo "=====================================================================";
echo " X-code Pandawa Router for Ubuntu 18.04 Server                       ";
echo " Progammer : Kurniawan. xcode.or.id                                  ";
echo " Version 1.0 Beta 5 (12/05/2018)                                     ";
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=";
echo " Router & Server pendukung router                                    ";
echo " [1]  Install X-code Pandawa (Untuk ganti nama ke eth0 dan eth1)     ";
echo " [2]  Setting IP Address untuk eth0 dan eth1                         ";
echo " [3]  Install NAT, DHCP Server & Bandwidth monitoring                ";
echo " [4]  Install Squid untuk log dan cache pada client                  ";
echo " [5]  Setting DHCP Server                                            ";
echo " [6]  Port Forwarding                                                ";
echo " [7]  Pasang Squid + Log (transparent)                               ";
echo " [8]  Pasang Squid + Log + Cache (transparent)                       ";
echo " [10] Install VPN Server PPTP                                        ";
echo " [11] Setting ip client VPN Server                                   ";
echo " [12] Setting Password VPN Server                                    ";
echo " [13] Setting ms-dns pada VPN Server                                 ";
echo " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-";
echo " Log dan lainnya                                                     ";
echo " [14] Lihat user yang mendapatkan akses dari DHCP Server             ";
echo " [15] Lihat log semua log yang tersimpan                             ";
echo " [16] Lihat ukuran cache squid                                       ";
echo " [17] Edit squid.conf                                                ";
echo " [18] Aktifkan rc.local untuk NAT                                    ";
echo " [19] Edit rc.local                                                  ";
echo " [20] Reboot                                                         ";
echo " [21] Exit                                                           ";
echo "=====================================================================";
read -p " Masukkan Nomor Pilihan Anda [1 - 21] : " choice;
echo "";
case $choice in
1)  if [ -z "$(sudo ls -A /etc/default/grub)" ]; then
    echo "Tidak terdeteksi grub, anda yakin pakai Ubuntu 18.04 ?"
    else
    sudo apt-get install ifupdown
    cp support/grub /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    cp support/resolved.conf /etc/systemd/
    sudo systemctl restart systemd-resolved
    cp support/interfaces /etc/network/
    sudo nano /etc/network/interfaces
    read -p "Tekan enter untuk restart"
    reboot
    fi
    ;;
2)  if [ -z "$(ls -l /etc/network/interfaces)" ]; then
    echo "Tidak terdeteksi ada /etc/network/interfaces"
    else
    cp support/interfaces /etc/network/
    sudo nano /etc/network/interfaces
    read -p "Apakah anda mau restart koneksi eth0 & eth1 sekarang? y/n :" -n 1 -r
    echo 
        if [[ ! $REPLY =~ ^[Nn]$ ]]
        then
        ip addr flush eth0 && sudo systemctl restart networking.service
        ip addr flush eth1 && sudo systemctl restart networking.service
        sudo ifconfig
        fi
    fi
    ;;
3)  read -p "Apakah anda mau yakin mau install NAT, DHCP Server, dan iptraf ? y/n :" -n 1 -r
    echo  ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]
    then
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo /sbin/iptables -P FORWARD ACCEPT
    sudo /sbin/iptables --table nat -A POSTROUTING -o eth0 -j MASQUERADE
    echo "NAT sudah diinstall"
    sudo apt-get install isc-dhcp-server
    sudo mv /etc/dhcp/dhcp.conf /tmp
    sudo cp support/dhcpd.conf /etc/dhcp
    sudo nano /etc/dhcp/dhcpd.conf
    sudo service isc-dhcp-server restart
    echo "DHCP Server sudah diinstall"
    sudo apt-get install iptraf
    echo "iptraff sudah diinstall"
    fi
    ;;

4)  read -p "Apakah anda yakin install Squid  ? y/n :" -n 1 -r
    echo  ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]
    then
    sudo apt-get install squid3
    fi
    ;;

5)  if [ -z "$(ls -A /etc/dhcp/dhcpd.conf)" ]; then
    echo "Tidak terdeteksi DHCP Server"
    else
    echo "Setting DHCP Server"
    sudo nano /etc/dhcp/dhcpd.conf
    service isc-dhcp-server restart
    fi
    ;;   

6) sudo iptraf-ng
    ;;


7) echo -n "Masukkan ip WAN: "
    read ipwan
    echo -n "Masukkan ip LAN: "
    read iplan
    echo -n "Masukkan port: "
    read portip
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo iptables -t nat -A PREROUTING -j DNAT -d $ipwan -p tcp --dport $portip --to $iplan
    echo "Port forwading telah dilakukan"
    echo "Jika ingin tetap jalan setelah restart pastikan edit pada rc.local lalu aktifkan untuk port forwarding dengan menghilangkan tanda # lalu ganti ip address WAN, Port yang mau diarahkan dan IP address komputer LAN yang akan dituju."
    echo "Sebelum edit rc.local, tambahkan dulu NAT ke rc.local yang ada pada menu"
    ;;

8) echo -n "Masukkan ip  LAN: "
    read iplan2
    if [ -z "$(ls -A /etc/squid/squid.conf)" ]; then
    echo "Squid tidak terdeteksi"
    else
    rm /etc/squid/squid.conf
    sudo cp support/squid1/squid.conf /etc/squid/
    sudo iptables -t nat -A PREROUTING -i eth1 -p tcp -m tcp --dport 80 -j DNAT --to-destination $iplan2:3127
    echo "Jika ingin tetap jalan setelah restart pastikan edit pada rc.local lalu aktifkan iptables untuk mengarahkan port 80 ke port squid 3127 dengan menghilangkan tanda #. Jangan lupa diganti ip address LAN-nya."
    echo "Sebelum edit rc.local, tambahkan dulu NAT ke rc.local yang ada pada menu"
    read -p "Log akan aktif jika linux sudah dilakukan restart"
    fi
    ;;

9) echo -n "Masukkan ip  LAN: "
    read iplan3
    if [ -z "$(ls -l /etc/squid/squid.conf)" ]; then
    echo "Squid tidak terdeteksi"
    else
    rm /etc/squid/squid.conf
    sudo cp support/squid2/squid.conf /etc/squid/
    sudo iptables -t nat -A PREROUTING -i eth1 -p tcp -m tcp --dport 80 -j DNAT --to-destination $iplan3:3127
    echo "Jika ingin tetap jalan setelah restart pastikan edit pada rc.local lalu aktifkan iptables untuk mengarahkan port 80 ke port squid 3127 dengan menghilangkan tanda #. Jangan lupa diganti ip address lan-nya."
    echo "Sebelum edit rc.local, tambahkan dulu NAT ke rc.local yang ada pada menu"
    read -p "Log akan aktif jika linux sudah dilakukan restart"
    fi
    ;;

10) read -p "Apakah anda yakin install VPN Server PPTP  ? y/n :" -n 1 -r
    echo  ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]
    then
    if [ -z "$(ls -l /etc/pptpd.conf)" ]; then
    echo "Install PPTP Server" 
    sudo apt-get install pptpd
    sudo cp support/etc/pptpd.conf /etc
    sudo cp support/chap-secrets /etc/ppp
    sudo cp support/ppptpd-options /etc/ppp
    sudo nano /etc/pptpd.conf
    sudo nano /etc/ppp/chap-secrets
    sudo nano /etc/ppp/pptpd-options
    service pptpd restart
    else
    echo "Sudah ada PPTP Server"
    fi
    fi
    ;;

11) if [ -z "$(ls -l /etc/pptpd.conf)" ]; then
    echo "Tidak terdeteksi file pptpd.conf pada VPN Server"
    else
    echo "Edit pptpd.conf" 
    sudo nano /etc/pptpd.conf
    service pptpd restart
    fi
    ;;

12) if [ -z "$(ls -l /etc/ppp/chap-secrets)" ]; then
    echo "Tidak terdeteksi file chap-secrets pada VPN Server"
    else
    echo "Edit file chap-secrets" 
    sudo nano /etc/ppp/chap-secrets
    service pptpd restart
    fi
    ;;

13) if [ -z "$(ls -l /etc/pptpd.conf)" ]; then
    echo "Tidak terdeteksi file pptpd-options pada VPN Server"
    else
    echo "Edit file pptpd-options" 
    sudo nano /etc/ppp/pptpd-options
    service pptpd restart
    fi
    ;;

14) if [ -z "$(ls -l /var/lib/dhcp/dhcpd.leases)" ]; then
    echo "Tidak terdeteksi DHCP Server"
    else
    python support/leases.py
    fi
    ;;

15) if [ -z "$(ls -l /var/log/squid/access.log)" ]; then
    echo "Tidak terdeteksi log access pada squid"
    else
    sudo nano /var/log/squid/access.log
    fi
    ;;

16) du -s /var/spool/squid
    read -p "Tekan enter untuk melanjutkan"
    ;;

17) if [ -z "$(ls -l /etc/squid/squid.conf)" ]; then
    echo "Tidak terdeteksi squid"
    else
    sudo nano /etc/squid/squid.conf
    fi
    ;;

18) cp support/rc.local /etc/
    chmod 777 rc.local
    sudo sysmctl enable rc-local.service
    ;; 

19) sudo nano /etc/rc.local
    ;;

20) read -p "Apakah anda yakin akan restart? y/n :" -n 1 -r
    echo 
    if [[ ! $REPLY =~ ^[Nn]$ ]]
    then
    reboot
    fi
    ;;

21) exit
    ;;
*)    echo "Maaf, menu tidak ada"
esac
echo ""
echo "X-code Pandawa"
echo "Oleh Kurniawan - trainingxcode@gmail.com. xcode.or.id"
echo ""
echo -n "Kembali ke menu? [y/n]: ";
read again;
while [ $again != 'Y' ] && [ $again != 'y' ] && [ $again != 'N' ] && [ $again != 'n' ];
do
echo "Masukkan yang anda pilih tidak ada di menu";
echo -n "Kembali ke menu? [y/n]: ";
read again;
done
done
