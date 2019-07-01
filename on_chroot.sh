bold=$(tput bold)
normal=$(tput sgr0)

bprint (){
	echo "$bold $1 $normal"
}

wait_for_keypress (){
	echo "Press any key to continue..."
	stty -echo
	read -n 1
	stty echo
	clear
}

clear
bprint "Setting up Time Zone..."
ln -sf /usr/share/zoneinfo/Europe/Athens /etc/localtime
bprint "Setting System to Hardware Clock..."
hwclock --systohc

#el_GR.UTF-8 UTF-8
#en_US.UTF-8 UTF-8
bprint "Setting up Locale..."
sed -i 's/#el_GR\.UTF-8 UTF-8/el_GR\.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#en_US\.UTF-8 UTF-8/en_US\.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

wait_for_keypress
bprint "Enter Hostname: "
read hostname
bprint "Setting Hostname..."
echo $hostname > /etc/hostname

wait_for_keypress
bprint "Set Root Password:"
passwd

wait_for_keypress
bprint "Enter Username: "
read username
bprint "Setting up User..."
useradd -g users -G wheel, storage, power -m $username
bprint "Setting up User Password..."
passwd $username

wait_for_keypress
bprint "Installing Grub..."
pacman -Syu grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

bprint "Enable dhcpcd service..."
systemctl enable dhcpcd
systemctl start dhcpcd

wait_for_keypress

bprint "visudo and uncomment # %wheel ALL = (ALL) ALL"

bprint "Exiting Installed Environment..."
bprint "Type the reboot command to reboot the system and boot into existing os."
exit

