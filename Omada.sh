
echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "TP-Link Omada Software Controller - Installer"
echo "Customizzato da Matteo Giustini per Ubuntu Server"
echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

echo "[+] Verifica se OS supportato"
OS=$(hostnamectl status | grep "Operating System" | sed 's/^[ \t]*//')
echo "[~] $OS"

if [[ $OS = *"Ubuntu 16.04"* ]]; then
    OsVer=xenial
elif [[ $OS = *"Ubuntu 18.04"* ]]; then
    OsVer=bionic
elif [[ $OS = *"Ubuntu 20.04"* ]]; then
    OsVer=focal
elif [[ $OS = *"Ubuntu 22.04"* ]]; then
    # $OsVer is also set to 'focal' as MongoDB 4.4 is not offically supported on 22.04
    OsVer=focal
    # Install libssl 1.1 as required by MongoDB 4.4 on Ubuntu 22.04
    echo "[+] Installazione libssl 1.1 per Ubuntu 22.04"
    wget -qP /tmp/ http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
    dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb &> /dev/null
else
    echo -e "\e[1;31m[!] Questo script supporta solo Ubuntu 16.04, 18.04, 20.04 or 22.04! Usa Ubuntu cialtrone \e[0m"
    exit
fi

echo "[+] Installazione prerequisiti"
apt-get -qq update
apt-get -qq install gnupg curl &> /dev/null

echo "[+] Importazione MongoDB 4.4 PGP e creazione repo APT"
curl -fsSL https://pgp.mongodb.com/server-4.4.asc | gpg -o /usr/share/keyrings/mongodb-server-4.4.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-4.4.gpg ] https://repo.mongodb.org/apt/ubuntu $OsVer/mongodb-org/4.4 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.4.list

# Package dependencies
echo "[+] Installazione MongoDB 4.4"
apt-get -qq update
apt-get -qq install mongodb-org &> /dev/null
echo "[+] Installazione OpenJDK 8 JRE"
apt-get -qq install openjdk-8-jre-headless &> /dev/null
echo "[+] Installazione JSVC"
apt-get -qq install jsvc &> /dev/null

echo "[+] Download ultima versione Omada Software Controller da sito TP-Link"
OmadaPackageUrl=$(curl -fsSL https://www.tp-link.com/us/support/download/omada-software-controller/ | grep -oP '<a[^>]*href="\K[^"]*Linux_x64.deb[^"]*' | head -n 1)
wget -qP /tmp/ $OmadaPackageUrl
echo "[+] Installazione Omada Software Controller"
dpkg -i /tmp/$(basename $OmadaPackageUrl) &> /dev/null

hostIP=$(hostname -I | cut -f1 -d' ')
echo -e "\e[0;32m[~] L'Omada Software Controller è pronto! :)\e[0m"
echo -e "\e[0;32m[~] Vai su https://${hostIP}:8043 per completare il setup iniziale.\e[0m\n"
