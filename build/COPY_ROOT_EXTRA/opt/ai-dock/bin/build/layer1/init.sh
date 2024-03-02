#!/bin/bash
set -eo pipefail
# Override this file to add extras to your build
umask 002
# Wine, Winetricks, Lutris, and PlayOnLinux, this process must be consistent with https://wiki.winehq.org/Ubuntu

mkdir -pm755 /etc/apt/keyrings
curl -fsSL -o /etc/apt/keyrings/winehq-archive.key "https://dl.winehq.org/wine-builds/winehq.key"
curl -fsSL -o "/etc/apt/sources.list.d/winehq-$(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '\"').sources" "https://dl.winehq.org/wine-builds/ubuntu/dists/$(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '\"')/winehq-$(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '\"').sources"
apt-get update
apt-get install --install-recommends -y \
        winehq-${WINE_BRANCH}
apt-get install --no-install-recommends -y \
        q4wine \
        playonlinux
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

# Steam
export GE_PROTON_VERSION="$(curl -fsSL "https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest" | jq -r '.tag_name')"
env-store GE_PROTON_VERSION
mkdir -p /opt/proton
wget -c "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${GE_PROTON_VERSION}/${GE_PROTON_VERSION}.tar.gz" -O - | tar xz -C /opt/proton

dpkg-divert --add /usr/games/steam
$APT_INSTALL \
    steam-installer \
    libpipewire-0.3-0:i386 \
    libxcb-res0:i386 \
    libgtk2.0-0:i386
cp -f /opt/ai-dock/share/steam/bin/steam /usr/games/steam
chmod +x /usr/games/steam
cp -f /opt/ai-dock/share/steam/bin/steam-native /usr/bin/steam-native
chmod +x /usr/bin/steam-native
ln -sf /usr/games/steam /usr/bin/steam

# Graphics utils
apt-get update
$APT_INSTALL \
    blender \
    blender-data \
    gimp \
    inkscape

mkdir -p /opt/krita
wget -O /opt/krita/krita.appimage https://download.kde.org/stable/krita/5.2.2/krita-5.2.2-x86_64.appimage
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


rm -rf /tmp/*

fix-permissions -o container