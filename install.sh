#!/bin/bash

# Update mirrors to nearest ones
sudo pacman-mirrors --fasttrack

# Update the system
sudo pacman -Syyu

# Remove unnecessary KDE applications
sudo pacman -Rns kdeaccessibility kdeadmin kdeedu kdegames kdegraphics kdemultimedia kdenetwork kdepim kdesdk kdeutils kdeconnect kio-extras kinfocenter kscreen kuser kwalletmanager kwrite plasma-browser-integration

# Install konsole, dolphin, and notepad (kate)
sudo pacman -S konsole dolphin kate

# Install drivers for the current device
sudo pacman -S xf86-video-intel    # for Intel graphics

# Tweak system for better performance
sudo pacman -S zram-generator    # for enabling zram
sudo systemctl enable --now zram-generator.service
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-sysctl.conf > /dev/null    # lower swappiness value for better performance

# Clean up the system
sudo pacman -Scc

# Check if everything is okay
sudo pacman -Syu
sudo pacman -S konsole dolphin kate
sudo pacman -S xf86-video-intel xf86-video-amdgpu nvidia
sudo pacman -S zram-generator
