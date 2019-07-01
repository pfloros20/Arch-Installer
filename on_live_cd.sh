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
}

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
wait_for_keypress
bprint "Enter Target Disk: "
read disk
bprint "You chose $disk"
wait_for_keypress
cgdisk /dev/$disk
#new partition, size = 600M, GUID/partition type = ef00, name = boot
#new partition, size = recommended size is equal to RAM size, GUID/partition type = 8200, name = swap
#new partition, size = default to use all the free space, GUID/partition type = 8300 (linux file system), name = system
#write to save changes and quit
bprint "Listing Disks..."
lsblk
wait_for_keypress
bprint "Enter Boot Partition: "
read boot
bprint "Formatting $boot as Boot Partition..."
mkfs.fat -F32 /dev/$boot
wait_for_keypress
bprint "Enter Swap Partition: "
read swap
bprint "Formatting $swap as Swap Partition..."
mkswap /dev/$swap
swapon /dev/$swap
wait_for_keypress
bprint "Enter System Partition: "
read system
bprint "Formatting $system as System Partition..."
mkfs.ext4 /dev/$system
wait_for_keypress
bprint "Mounting System Partition..."
mount /dev/$system /mnt
wait_for_keypress
bprint "Creating Boot Directory..."
mkdir /mnt/boot
wait_for_keypress
bprint "Mounting Boot Partition..."
mount /dev/$boot /mnt/boot
wait_for_keypress
bprint "Reporting File System Disk Space Usage.."
df
wait_for_keypress

bprint "Editing Mirror List putting at the top a nearby mirror..."
mirrorlist=$(cat /etc/pacman.d/mirrorlist | grep '\.gr/')
bprint $mirrorlist | cat - /etc/pacman.d/mirrorlist > temp && mv temp /etc/pacman.d/mirrorlist

wait_for_keypress
bprint "Installing Arch System..."
pacstrap /mnt base base-devel
wait_for_keypress

bprint "Generating File Systems Table..."
genfstab -U /mnt >> /mnt/etc/fstab
wait_for_keypress
bprint "File Systems Table on /mnt/etc/fstab."
cat /mnt/etc/fstab
wait_for_keypress

bprint "Changing Installed Environment..."

mv ../Arch-Installer /mnt/root/Arch-Installer
chmod 755 /mnt/root/Arch-Installer

arch-chroot /mnt