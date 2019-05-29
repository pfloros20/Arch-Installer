echo "Setting up Time Zone..."
ln -sf /usr/share/zoneinfo/Europe/Athens /etc/localtime
echo "Setting System to Hardware Clock..."
hwclock --systohc

#el_GR.UTF-8 UTF-8
#en_US.UTF-8 UTF-8
echo "Setting up Locale..."
sed -i 's/#el_GR\.UTF-8 UTF-8/el_GR\.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#en_US\.UTF-8 UTF-8/en_US\.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "Enter Hostname: "
read hostname
echo "Setting Hostname..."
echo $hostname > /etc/hostname

echo "Set Root Password:"
passwd

echo "Enter Username: "
read username
echo "Setting up User..."
useradd -g users -G wheel, storage, power -m $username
echo "Setting up User Password..."
passwd $username

echo "Installing Grub..."
pacman -Syu grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "Exiting Installed Environment..."
echo "Type the reboot command to reboot the system and boot into existing os."
exit

