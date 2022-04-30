#!/bin/bash

cd $HOME

echo "Making apps Directory"
mkdir apps

cd $HOME/apps

echo
echo "Download pCloud AppImage Zip"
curl -s https://www.pcloud.com/how-to-install-pcloud-drive-linux.html?download=electron-64 \
| grep "'Electron':" \
| cut -d : -f 2,3 \
| tr -d \" \
| sed "s/[,']//g" \
| sed "s/[[:blank:]]//g" \
| xargs echo "https://api.pcloud.com/getpubzip?code=" \
| sed "s/[[:blank:]]//g" \
| wget -O pcloud.zip -qi -

echo
echo "Extract pCloud AppImage Zip"
unzip pcloud.zip && rm pcloud.zip && chmod +x pcloud && mv pcloud pcloud.AppImage

echo
echo "Download Standard Notes AppImage"
curl -s https://api.github.com/repos/standardnotes/desktop/releases/latest \
| grep "standard-notes-*.*linux-x86_64*.*AppImage" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -

echo
echo "Make Standard Notes AppImage Executable"
chmod +x standard-notes*AppImage

echo
echo "Download Bitwarden AppImage"
curl -s https://api.github.com/repos/bitwarden/desktop/releases/latest \
| grep "Bitwarden-*.*-x86_64*.*AppImage" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -

echo
echo "Make Bitwarden AppImage Executable"
chmod +x Bitwarden*AppImage

echo
echo "Download Bitwarden CLI"
curl -s https://api.github.com/repos/bitwarden/cli/releases/latest \
| grep "bw-linux*.*zip" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -O bw.zip -qi -

echo
echo "Extract Bitwarden CLI"
unzip bw.zip && rm bw.zip && chmod +x bw
