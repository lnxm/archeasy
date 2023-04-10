#!/bin/bash

# Check internet connection
echo "Checking internet connection..."
ping -c 1 google.com > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "Internet connection is OK"
else
  echo "Please connect to the internet before running this script"
  exit 1
fi

# Get mirrorlist and set closest mirror
echo "Getting mirrorlist and setting closest mirror..."
curl -s "https://archlinux.org/mirrorlist/?country=all&protocol=http&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist

# Ask user if they want to install Arch Linux alongside another operating system
echo "Do you want to install Arch Linux alongside another operating system for dual-booting? [y/N]"
read dual_boot_option
if [ "$dual_boot_option" = "y" ] || [ "$dual_boot_option" = "Y" ]; then
  echo "Please use a partition manager to create a new partition for Arch Linux."
  echo "Then run this script again and choose 'Custom partitioning' during installation."
  exit 0
fi

# Prompt user for installation type
echo "Choose your installation type:"
echo "1) Automatic partitioning"
echo "2) Custom partitioning"
read install_type

if [ "$install_type" = "1" ]; then
  echo "Installing Arch Linux with automatic partitioning..."
  # TODO: add code for automatic partitioning
elif [ "$install_type" = "2" ]; then
  echo "Installing Arch Linux with custom partitioning..."
  # TODO: add code for custom partitioning
else
  echo "Invalid option. Please choose 1 or 2."
  exit 1
fi

# Prompt user for username, hostname, timezone, language, and keyboard layout
echo "Enter your desired username:"
read username

echo "Enter your desired hostname (the name for this computer on the network):"
read hostname

echo "Enter your timezone (e.g. America/New_York):"
read timezone

echo "Enter your desired language (e.g. en_US.UTF-8):"
read language

echo "Enter your desired keyboard layout (e.g. us):"
read keyboard_layout

# Install base system and necessary packages
echo "Installing base system and necessary packages..."
pacstrap /mnt base base-devel linux linux-firmware vim networkmanager

# Generate fstab file
echo "Generating fstab file..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into new system
echo "Chrooting into new system..."
arch-chroot /mnt

# Set timezone
echo "Setting timezone..."
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

# Set hostname
echo "Setting hostname..."
echo $hostname > /etc/hostname

# Set language and keyboard layout
echo "Setting language and keyboard layout..."
echo "LANG=$language" > /etc/locale.conf
echo "KEYMAP=$keyboard_layout" > /etc/vconsole.conf
echo "FONT=lat9w-16" >> /etc/vconsole.conf

# Uncomment desired locales in /etc/locale.gen
echo "Uncommenting desired locales in /etc/locale.gen..."
sed -i
