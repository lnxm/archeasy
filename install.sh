#!/bin/bash

# Ensure system clock is accurate
timedatectl set-ntp true

# Partition the disk with EFI and root partitions
parted -s /dev/sda mklabel gpt mkpart primary fat32 1MiB 261MiB set 1 esp on mkpart primary ext4 261MiB 100%

# Format the partitions
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# Mount the partitions
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Set up the mirrorlist for fastest download speed
pacman -Sy reflector
reflector --verbose --latest 20 --sort rate --save /etc/pacman.d/mirrorlist

# Install the base system and necessary packages
pacstrap /mnt base base-devel linux-lowlatency linux-firmware intel-ucode grub efibootmgr networkmanager neofetch

# Generate the fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Copy the script to the new system for post-installation tasks
cp $0 /mnt/root/post-install.sh

# Chroot into the new system
arch-chroot /mnt /bin/bash <<EOF

# Set the timezone and clock
ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localtime
hwclock --systohc

# Set the language and keyboard layout
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
sed -i 's/#cs_CZ.UTF-8/cs_CZ.UTF-8/g' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'KEYMAP=cz-qwertz' > /etc/vconsole.conf

# Set the hostname and add the user
echo 'e7440' > /etc/hostname
echo '127.0.0.1  e7440.localdomain  e7440' >> /etc/hosts
useradd -m -G wheel lnxm
echo 'lnxm:1' | chpasswd

# Install and configure GRUB bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg

# Install and configure KDE
pacman -S plasma kde-applications-meta
pacman -S konsole dolphin kate kwrite spectacle ksysguard yakuake kwalletmanager

# Install the Brave browser
pacman -S brave

# Install additional software
pacman -S pamac vlc discord-devel

# Install drivers for the Latitude E7440
pacman -S xf86-input-synaptics xf86-video-intel

# Install Intel QuickSync Video encoder
pacman -S intel-media-driver libva-utils

# Enable NetworkManager service
systemctl enable NetworkManager

# Add neofetch to the terminal config
echo 'neofetch' >> /etc/profile.d/neofetch.sh

EOF

# Reboot the system
umount -R /mnt
reboot
