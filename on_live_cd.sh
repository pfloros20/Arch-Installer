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
bprint "Pinging the archlinux.org website to check internet connection..."
ping -c 3 archlinux.org
wait_for_keypress
bprint "Checking if on efi system..."
ls /sys/firmware/efi/efivars
# bprint "Updating the system clock..."
# timedatectl set-ntp true
# date
wait_for_keypress

bprint "Listing Disks..."
lsblk
bprint "Enter Target Disk: "
read disk
bprint "You chose $disk"
bprint "Recommended:"
echo -e "\tboot partition"
echo -e "\t\tsize = 600M"
echo -e "\t\tGUID/partition type = ef00"
echo -e "\t\tname = boot\n"

echo -e "\tswap partition"
echo -e "\t\tsize = recommended size is equal to RAM size"
echo -e "\t\tGUID/partition type = 8200"
echo -e "\t\tname = swap\n"

echo -e "\tsystem partition"
echo -e "\t\tsize = default to use all the free space"
echo -e "\t\tGUID/partition type = 8300 (linux file system)"
echo -e "\t\tname = system\n"
echo -e "\twrite to save changes and quit"
wait_for_keypress
cgdisk /dev/$disk

clear
bprint "Listing Disks..."
lsblk
bprint "Enter Boot Partition: "
read boot
bprint "Formatting $boot as Boot Partition..."
mkfs.fat -F32 /dev/$boot
bprint "Enter Swap Partition: "
read swap
bprint "Formatting $swap as Swap Partition..."
mkswap /dev/$swap
swapon /dev/$swap
bprint "Enter System Partition: "
read system
bprint "Formatting $system as System Partition..."
mkfs.ext4 /dev/$system
bprint "Mounting System Partition..."
mount /dev/$system /mnt
bprint "Creating Boot Directory..."
mkdir /mnt/boot
bprint "Mounting Boot Partition..."
mount /dev/$boot /mnt/boot
wait_for_keypress
bprint "Reporting File System Disk Space Usage.."
df
wait_for_keypress

bprint "Editing Mirror List putting at the top a nearby mirror..."
mirrorlist=$(cat /etc/pacman.d/mirrorlist | grep '\.gr/')
echo $mirrorlist | cat - /etc/pacman.d/mirrorlist > temp && mv temp /etc/pacman.d/mirrorlist

wait_for_keypress
bprint "Installing Arch System..."
pacstrap /mnt base base-devel
wait_for_keypress

bprint "Generating File Systems Table..."
genfstab -U /mnt >> /mnt/etc/fstab
bprint "File Systems Table on /mnt/etc/fstab."
cat /mnt/etc/fstab

bprint "Changing Installed Environment..."

mv ../Arch-Installer /mnt/root/Arch-Installer
chmod 755 /mnt/root/Arch-Installer

arch-chroot /mnt

reboot