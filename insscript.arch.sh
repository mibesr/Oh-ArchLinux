#!/bin/bash
# Arch iScript
# Author: Tsujidou Akari (chiey.qs@gmail.com)
# Date: 2012-10-06
# Version: 0.1

read -p ": Is LVM used [yn]: " f_lvm
read -p ": Enter full path of Root partition: " p_root
read -p ": Enter full path of Home partition: " p_home
read -p ": Is swap partition used [yn]: " f_swap
[[ 'y' == $f_swap ]] && \
	read -p ": Enter full path of swap partition: " p_swap
read -p ": Enter full partition path(root/home/etc., SPACE to split, NOTHING to skip) you want to format: " p_fmt
if [ 'y' == $f_lvm ]; then
	modprobe dm_mod
	vgscan
	vgchange -ay
	if [ $p_fmt ]; then
		for fmt_pt in $p_fmt; do
			mkfs.ext4 $fmt_pt
		done
	fi
	mount $p_root /mnt
	mkdir -p /mnt/home
	mount $p_home /mnt/home
fi
echo ": Generate fstab file..."
genfstab -p /mnt >/mnt/etc/fstab
read -p ": Enter mirror site here (SPACE to split): " mirror
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.pacbak
for mirrorst in $mirror; do
	echo $mirrorst >>/etc/pacman.d/mirrorlist
done
echo "ftp://ftp.archlinux.org/\$repo/os/\$arch" >>/etc/pacman.d/mirrorlist
echo ": Download base package group..."
pacstrap /mnt base base-devel grub-bios systemd systemd-arch-units systemd-sysvcompat
echo ": Generate base locale for the setup script..."
mv /mnt/etc/locale.gen /mnt/etc/locale.gen.pacbak
echo en_US.UTF-8 >/mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c "locale-gen"
echo LANG=en_US.UTF-8 >/etc/locale.conf
echo ": Setting timezone..."
read -p ": Your area is " my_area
read -p ": Your country is " my_country
arch-chroot /mnt /bin/bash -c "ln -s /usr/share/zoneinfo/$my_area/$my_country /etc/localtime"
echo "$my_area/$my_country" >/mnt/etc/timezone
read -p ": Set hwclock to utc or localtime " tzflg
arch-chroot /mnt /bin/bash -c "hwlock --systohc --$tzflg"
read -p ": Enter your hostname here: " hostnm
echo $hostnm >/mnt/etc/hostname
sed -n "6,7s/archiso/$hostnm/g" /etc/hosts >/mnt/etc/hosts
echo ": Create an initial ramdisk..."
if [ 'y' == $f_lvm ]; then
	sed -in '59s/filesystem/lvm2 filesystem/g' /mnt/etc/mkinitcpio.conf
fi
arch-chroot /mnt /bin/bash -c "cd /boot && mkinitcpio -p linux"
echo ": Install grub boot loader..."
arch-chroot /mnt /bin/bash -c "grub-install /dev/sda && grub-mkconfig -p /boot/grub/grub.cfg"
echo ": Unmount all mounted filesystem..."
umount /mnt/home
umount /mnt
echo ": All finished, rebooting..."
reboot
