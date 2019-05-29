echo "Pinging the archlinux.org website to check internet connection..."
ping -c 3 archlinux.org
echo "Checking if on efi system..."
ls /sys/firmware/efi/efivars
# echo "Updating the system clock..."
# timedatectl set-ntp true
# date

echo "Listing Disks..."
lsblk
echo "Enter Target Disk: "
read disk
echo "You chose $disk"
cgdisk /dev/$disk
#new partition, size = 600M, GUID/partition type = ef00, name = boot
#new partition, size = recommended size is equal to RAM size, GUID/partition type = 8200, name = swap
#new partition, size = default to use all the free space, GUID/partition type = 8300 (linux file system), name = system
#write to save changes and quit
echo "Listing Disks..."
lsblk
echo "Enter Boot Partition: "
read boot
echo "Formatting $boot as Boot Partition..."
mkfs.fat -F32 /dev/$boot
echo "Enter Swap Partition: "
read swap
echo "Formatting $swap as Swap Partition..."
mkswap /dev/$swap
swapon /dev/$swap
echo "Enter System Partition: "
read system
echo "Formatting $system as System Partition..."
mkfs.ext4 /dev/$system
echo "Mounting System Partition..."
mount /dev/$system /mnt
echo "Creating Boot Directory..."
mkdir /mnt/boot
echo "Mounting Boot Partition..."
mount /dev/$boot /mnt/boot
echo "Reporting File System Disk Space Usage.."
df

echo "Editing Mirror List putting at the top a nearby mirror..."
mirrorlist=$(cat /etc/pacman.d/mirrorlist | grep '\.gr/')
echo $mirrorlist | cat - /etc/pacman.d/mirrorlist > temp && mv temp /etc/pacman.d/mirrorlist

echo "Installing Arch System..."
pacstrap /mnt base base-devel

echo "Generating File Systems Table..."
genfstab -U /mnt >> /mnt/etc/fstab
echo "File Systems Table on /mnt/etc/fstab."
cat /mnt/etc/fstab

echo "Changing Installed Environment..."
script=`basename "$0"`
cp $script /mnt/root
chmod 755 /mnt/root/$script
arch-chroot /mnt /root/$script --chroot
#maybe wont work as intended
rm /mnt/root/$script