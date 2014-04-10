#!/bin/bash

# Kali Linux ISO recipe for 	: Top 10 Mate
#########################################################################################
# Desktop 	: Mate 1.8
# Metapackages	: kali-linux-top10
# Total size 	: xxx Mb
# Special notes	: Non root user installation enabled through preseed.cfg
# Look and Feel	: Custom wallpaper and terminal configs through post install hooks.
#########################################################################################

git clone git://git.kali.org/live-build-config.git
apt-get source debian-installer
cd live-build-config

cat > config/package-lists/kali.list.chroot << EOF
kali-root-login
kali-defaults
kali-menu
kali-debtags
kali-archive-keyring
debian-installer-launcher
alsa-tools
locales-all
xorg
#kali-linux-top10
EOF

mkdir -p config/archives/
echo "deb http://repo.mate-desktop.org/archive/1.8/debian/ wheezy main" > config/archives/mate.list.chroot
wget http://mirror1.mate-desktop.org/debian/mate-archive-keyring.gpg -O config/archives/mate.key.chroot

mkdir -p config/includes.chroot/usr/share/wallpapers/kali/contents/images
wget http://1hdwallpapers.com/wallpapers/kali_linux.jpg
mv kali_linux.jpg config/includes.chroot/usr/share/wallpapers/kali/contents/images

cat > config/hooks/mate.chroot<< EOF
#!/bin/bash
# useradd -m kali -G sudo -s /bin/bash
# usermod -p 'X014elvznJq7E' kali
wget http://mirror1.mate-desktop.org/debian/mate-archive-keyring.gpg
apt-key add mate-archive-keyring.gpg
rm -rf mate-archive-keyring.gpg

apt-get --yes --force-yes --quiet --allow-unauthenticated install mate-core mate-desktop-environment-extra

dbus-launch --exit-with-session gsettings set org.mate.background picture-filename '/usr/share/wallpapers/kali/contents/images/kali_linux.jpg'
dbus-launch --exit-with-session gsettings set org.mate.interface gtk-theme 'BlackMATE'
dbus-launch --exit-with-session gsettings set org.mate.interface icon-theme 'mate'
dbus-launch --exit-with-session gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ background-darkness 0.86
dbus-launch --exit-with-session gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ background-type 'transparent'
dbus-launch --exit-with-session gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ background-color '#FFFFFFFFDDDD'
dbus-launch --exit-with-session gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ scrollback-unlimited true

cp -rf /root/.config /etc/skel/

EOF

mkdir -p config/debian-installer
cp ../debian-installer-*/build/preseed.cfg config/debian-installer/
sed -i 's/make-user boolean false/make-user boolean true/' config/debian-installer/preseed.cfg
echo "d-i passwd/root-login boolean false" >> config/debian-installer/preseed.cfg
lb build

