#!/bin/bash
set -eo pipefail
umask 002
# Override this file to add extras to your build
# Wine, Winetricks, Lutris, this process must be consistent with https://wiki.winehq.org/Ubuntu

mkdir -pm755 /etc/apt/keyrings
curl -fsSL -o /etc/apt/keyrings/winehq-archive.key "https://dl.winehq.org/wine-builds/winehq.key"
curl -fsSL -o "/etc/apt/sources.list.d/winehq-$(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '\"').sources" "https://dl.winehq.org/wine-builds/ubuntu/dists/$(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '\"')/winehq-$(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '\"').sources"
apt-get update
apt-get install --install-recommends -y \
        winehq-${WINE_BRANCH}

export LUTRIS_VERSION="$(curl -fsSL "https://api.github.com/repos/lutris/lutris/releases/latest" | jq -r '.tag_name' | sed 's/[^0-9\.\-]*//g')"
env-store LUTRIS_VERSION
curl -fsSL -O "https://github.com/lutris/lutris/releases/download/v${LUTRIS_VERSION}/lutris_${LUTRIS_VERSION}_all.deb"
apt-get install --no-install-recommends -y ./lutris_${LUTRIS_VERSION}_all.deb && rm -f "./lutris_${LUTRIS_VERSION}_all.deb"
curl -fsSL -o /usr/bin/winetricks "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"
chmod 755 /usr/bin/winetricks
curl -fsSL -o /usr/share/bash-completion/completions/winetricks "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.bash-completion"
ln -sf /usr/games/lutris /usr/bin/lutris
# Libre Office

apt-get install --install-recommends -y \
        libreoffice \
        libreoffice-kf5 \
        libreoffice-plasma \
        libreoffice-style-breeze

# Graphics utils
apt-get update
$APT_INSTALL \
    gimp \
    inkscape

cd /opt
wget https://ftp.halifax.rwth-aachen.de/blender/release/Blender4.2/blender-4.2.0-linux-x64.tar.xz
tar xvf blender-4.2.0-linux-x64.tar.xz
rm blender-4.2.0-linux-x64.tar.xz
ln -s /opt/blender-4.2.0-linux-x64/blender /opt/ai-dock/bin/blender
cp /opt/blender-4.2.0-linux-x64/blender.desktop /usr/share/applications
cp /opt/blender-4.2.0-linux-x64/blender.svg /usr/share/icons/hicolor/scalable/apps/


mkdir -p /opt/krita
wget -O /opt/krita/krita.appimage https://download.kde.org/stable/krita/5.2.3/krita-5.2.3-x86_64.appimage
chmod +x /opt/krita/krita.appimage
(cd /opt/krita && /opt/krita/krita.appimage --appimage-extract)
rm -f /opt/krita/krita.appimage
cp -rf /opt/krita/squashfs-root/usr/share/{applications,icons} /usr/share/
chmod +x /opt/ai-dock/bin/krita

# Chrome
wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
$APT_INSTALL /tmp/chrome.deb
dpkg-divert --add /opt/google/chrome/google-chrome
cp -f /opt/google/chrome/google-chrome /opt/google/chrome/google-chrome.distrib
cp -f /opt/ai-dock/share/google-chrome/bin/google-chrome /opt/google/chrome/google-chrome

apt-get clean -y

fix-permissions.sh -o container

rm -rf /tmp/*

rm /etc/ld.so.cache
ldconfig

cd /root
sudo wget https://github.com/pinokiocomputer/pinokio/releases/download/2.14.3/Pinokio-2.14.3.AppImage --output-document=/root/Pinokio-2.14.3.AppImage
sudo chmod a+x /root/Pinokio-2.14.3.AppImage
cd /root/
sudo ./Pinokio-2.14.3.AppImage --no-sandbox
