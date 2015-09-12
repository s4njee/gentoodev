#!/bin/bash
#startH=$(date '+%-H')
#startM=$(date '+%-M')
#startS=$(date '+%-S')
source /etc/profile
env-update

#ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
#sed -i s/#en/en/g /etc/locale.gen
#locale-gen
#eselect locale set 4

#Download and build kernel. Uses included kernel config file from git.
printf "\n\n[1.] Building kernel\n"
printf "=======================================================================\n"
emerge cpuinfo2cpuflags
cpuinfo2cpuflags-x86 >> /etc/portage/make.conf
printf "=sys-devel/gcc-4.9.3 ~amd64\n" >> /etc/portage/package.accept_keywords
emerge =sys-devel/gcc-4.9.3
gcc-config 2
printf "=sys-kernel/gentoo-sources-4.2.0-r1 ~amd64\n" >> /etc/portage/package.accept_keywords
emerge =sys-kernel/gentoo-sources-4.2.0-r1 linux-firmware
cd /usr/src/linux
cp /.config .
cpucores=$(grep -c ^processor /proc/cpuinfo)
make oldconfig
make -j${cpucores}
#make modules
make modules_install
make install
#cp /usr/src/linux/arch/arm/boot/zImage /boot/kernel7.img

#Selects vanilla systemd profile. Builds systemd, bootloader, some net tools and a world update.
printf "\n\n[2.] Updating world and installing various network utilities\n"
printf "=======================================================================\n"
printf "sys-fs/cryptsetup -gcrypt\n" >> /etc/portage/package.use/cryptsetup
eselect profile set 12
emerge -uDN @world ntp grub wpa_supplicant dhcpcd wireless-tools cryptsetup
mv /wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
#Enables ssh, dhcpcd, and ntp.
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable ntpd
timedatectl set-timezone US/Eastern

#Update config files
etc-update --automode -3


emerge --depclean
grub2-install --target=i386-pc /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg


printf "\n\n[3.] Building xorg-server\n"
printf "=======================================================================\n"
. /buildScripts/xorg.sh
emerge gdm gnome-terminal gnome
emerge --sync
systemctl enable gdm
passwd

#printf "[4.] Building Cinnamon\n"
#printf "=======================================================================\n"
#. /buildScripts/buildCinnamon.sh

printf "\n\n\nGentoo Linux has been installed\n"
printf "wpa_supplicant.conf in /etc/wpa_supplicant may need to be edited if it\n"
printf "wasn't modified prior to installation. dhcpcd may need to be run on first\n"
printf "reboot if ip is not leased on start\n"
#while IFS= read -r line;
#do
#newH=$(date '+%-H')
#newM=$(date '+%-M')
#newS=$(date '+%-S')
#fH=$((newH-startH))
#fM=$((newM-startM))
#fS=$((newS-startS))
#done
