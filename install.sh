#!/bin/bash

echo "Welcome to Arch Linux Installation Script!"

# Partitioning the disk
echo "Partitioning the disk..."
parted --script /dev/sda \
  mklabel gpt \
  mkpart ESP fat32 1MiB 513MiB \
  set 1 boot on \
  mkpart primary ext4 513MiB 100%

# Formatting the partitions
echo "Formatting the partitions..."
mkfs.fat -F32 /dev/sda1 >/dev/null
mkfs.ext4 /dev/sda2 >/dev/null

# Mounting the partitions
echo "Mounting the partitions..."
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Installing the base system
echo "Installing the base system..."
pacstrap /mnt base linux-lts linux-firmware intel-ucode >/dev/null

# Generating fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Setting the timezone
echo "Setting the timezone..."
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localtime

# Generating the /etc/adjtime file
echo "Generating the /etc/adjtime file..."
arch-chroot /mnt hwclock --systohc

# Setting the locale
echo "Setting the locale..."
echo "en_US.UTF-8 UTF-8" > /mnt/etc/locale.gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
arch-chroot /mnt locale-gen

# Setting the keyboard layout
echo "Setting the keyboard layout..."
echo "KEYMAP=cz-qwertz" > /mnt/etc/vconsole.conf

# Setting the hostname
echo "Setting the hostname..."
echo "arch-laptop" > /mnt/etc/hostname

# Adding matching entries to hosts
echo "Adding matching entries to hosts..."
echo "127.0.0.1	localhost" > /mnt/etc/hosts
echo "::1		localhost" >> /mnt/etc/hosts
echo "127.0.1.1	arch-laptop.localdomain	arch-laptop" >> /mnt/etc/hosts

# Installing GRUB
echo "Installing GRUB..."
pacstrap /mnt grub efibootmgr dosfstools os-prober mtools >/dev/null
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB >/dev/null
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg >/dev/null

# Installing drivers for the Latitude E7440
echo "Installing drivers for the Latitude E7440..."
pacstrap /mnt xf86-input-synaptics xf86-video-intel >/dev/null

# Installing KDE and necessary applications
echo "Installing KDE and necessary applications..."
pacstrap /mnt xorg plasma-desktop konsole dolphin kate pamac vlc brave discord-development >/dev/null

# Enabling NetworkManager
echo "Enabling NetworkManager..."
arch-chroot /mnt systemctl enable NetworkManager

# Configuring additional boot tweaks
echo "Configuring additional boot tweaks..."
echo "vm.swappiness=10" > /mnt/etc/sysctl.d/99-swappiness.conf

# Installing neofetch
echo "Installing neofetch..."
pacstrap /mnt neofetch >/dev/null

echo "Installation complete!"
