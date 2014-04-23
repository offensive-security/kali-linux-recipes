#!/bin/bash

# Kali Linux ISO recipe for 	: Top 10 Mate non-root
#########################################################################################
# Desktop 	: Mate 1.8
# Metapackages	: kali-linux-top10
# Total size 	: xxx Mb
# Special notes	: Non root user installation enabled through preseed.cfg. 
#		: This script is not meant to run unattended.
# Look and Feel	: Custom wallpaper and terminal configs through post install hooks.
# Background	: http://www.offensive-security.com/?p=9739
#########################################################################################

# Install dependencies
apt-get update
apt-get install git live-build cdebootstrap devscripts -y

# Clone the default Kali live-build config.
git clone git://git.kali.org/live-build-config.git
apt-get source debian-installer
cd live-build-config

# The user doesn't need the kali-linux-full metapackage, we overwrite with our own basic packages.
# This includes the debian-installer and the kali-linux-top10 metapackage (commented out for brevity of build, uncomment if needed).

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

# Add the new Mate 1.8 as a Windows Manager.
# We instruct live-build to add external MATE repositories and add relevant keys.
# Taken from http://wiki.mate-desktop.org/download

mkdir -p config/archives/
echo "deb http://repo.mate-desktop.org/archive/1.8/debian/ wheezy main" > config/archives/mate.list.chroot
wget http://mirror1.mate-desktop.org/debian/mate-archive-keyring.gpg -O config/archives/mate.key.chroot

# We download a wallpaper and overlay it.

mkdir -p config/includes.chroot/usr/share/wallpapers/kali/contents/images
wget http://1hdwallpapers.com/wallpapers/kali_linux.jpg
mv kali_linux.jpg config/includes.chroot/usr/share/wallpapers/kali/contents/images

# We add a chroot hook to add the MATE archive-keyring, and install MATE. 
# We even configure some of the terminal settings and wallpaper.

cat > config/hooks/mate.chroot<< EOF
#!/bin/bash
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

# We modify the default Kali preseed which disables normal user creation. 
# We copied this from the debian installer package we initially downloaded.

mkdir -p config/debian-installer
cp ../debian-installer-*/build/preseed.cfg config/debian-installer/
sed -i 's/make-user boolean false/make-user boolean true/' config/debian-installer/preseed.cfg
echo "d-i passwd/root-login boolean false" >> config/debian-installer/preseed.cfg

# Go ahead and run the build!
lb build


