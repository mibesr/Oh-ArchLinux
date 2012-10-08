#!/bin/bash
# Description: A simple Archlinux installation script
# Author: Tsujidou Akari (chiey.qs@gmail.com)
# Date: 2012-10-06
# Version: 0.1.2

function enable_pure_systemd()
{
	read -p ": Do you want enable system boot with pure systemd [yn]: " f_sysd
	if [ 'y' == $f_sysd ]; then
		arch-chroot /mnt /bin/bash -c "systemctl enable syslog-ng.service"
		arch-chroot /mnt /bin/bash -c "sed -i 's/.*quiet$/&\ init\=\/sbin\/init/g' /boot/grub/grub.cfg"
		arch-chroot /mnt /bin/bash -c "sed -i 's/^DAEMON\)$/DAEMONS\=\(\)/g' /etc/rc.conf"
	else
		echo ": Mixed systemd/initscript booting, skip."
	fi
}

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
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.pacbak
until [[ '' == $mirror ]]; do
	read -p ": Enter a mirror url, NOTHING to exit: " mirror
	echo $mirror >>/etc/pacman.d/mirrorlist
done
echo "ftp://ftp.archlinux.org/\$repo/os/\$arch" >>/etc/pacman.d/mirrorlist
echo ": Download base package group..."
pacstrap /mnt base base-devel grub-bios systemd systemd-arch-units 
echo ": Generate base locale for the setup script..."
mv /mnt/etc/locale.gen /mnt/etc/locale.gen.pacbak
echo en_US.UTF-8 >/mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c "locale-gen"
echo LANG=en_US.UTF-8 >/etc/locale.conf
echo ": Setting timezone..."
my_area=Asia
my_country=Shanghai
read -p ": Your area is (default to Asia): " my_area
read -p ": Your country is (default to Shanghai): " my_country
arch-chroot /mnt /bin/bash -c "ln -s /usr/share/zoneinfo/$my_area/$my_country /etc/localtime"
echo "$my_area/$my_country" >/mnt/etc/timezone
tzflg=utc
read -p ": Set hwclock to utc or localtime (default to utc): " tzflg
arch-chroot /mnt /bin/bash -c "hwlock --systohc --$tzflg"
read -p ": Enter your hostname here: " hostnm
echo $hostnm >/mnt/etc/hostname
sed -i 's/.*localhost$/&\ $hostnm/g' /mnt/etc/hosts
echo ": Create an initial ramdisk..."
if [ 'y' == $f_lvm ]; then
	#sed -i -n '59s/filesystem/lvm2 filesystem/g' /mnt/etc/mkinitcpio.conf
	sed -i 's/^HOOKS=.*sata/&\ lvm2/g' /mnt/etc/mkinitcpio.conf
fi
arch-chroot /mnt /bin/bash -c "cd /boot && mkinitcpio -p linux"
echo ": Install grub boot loader..."
arch-chroot /mnt /bin/bash -c "grub-install /dev/sda && grub-mkconfig -p /boot/grub/grub.cfg"
# Change to systemd...
enable_pure_systemd()
echo ": Unmount all mounted filesystem..."
umount /mnt/home
umount /mnt
echo ": All finished, rebooting..."
reboot
