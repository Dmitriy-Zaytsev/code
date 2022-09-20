#!/bin/bash -x
[ "$UID" != "0" ] && { echo "NO ROOT."; exit 2;}
test -b /dev/sda || exit 1
test -b /dev/sdb || exit 1


fun1 () {
hostname=$1
echo -e "d\n5\nd\nd\n4\nd\n3\nd\n2\nd\n1\np\nw\n" | fdisk /dev/sda
sgdisk -l /root/data_OS/sgdisk_gpt.gpt /dev/sda
dd if=/root/data_OS/sda1_efi.img of=/dev/sda1 bs=4M
sync
mkfs.ext2 /dev/sda2 -q || return 1
mkswap /dev/sda3 2>/dev/null
mount /dev/sda2 /mnt/disk_in/ | return 1

mkdir /mnt/disk_in/ -p
cd /mnt/disk_in/
tar -xvzpf /root/data_OS/techn_backup.tar.gz || return 1
cd ~

mount --bind /proc /mnt/disk_in/proc || return 1
mount --bind /dev /mnt/disk_in/dev || return 1
mount --bind /sys /mnt/disk_in/sys || return 1
mount /dev/sda1 /mnt/disk_in/boot/efi/ || return 1

uuid_uefi=`(blkid /dev/sda1 | sed 's/.*UUID="\(\S*\)".*/\1/g')`
uuid_os=`(blkid /dev/sda2 | sed 's/.*UUID="\(\S*\)".*/\1/g')`
uuid_swap=`(blkid /dev/sda3 | sed 's/.*UUID="\(\S*\)".*/\1/g')`
sed "/^[^#].*efi/s/\(UUID=\)\S* \(.*\)/\1$uuid_uefi \2/g" /mnt/disk_in/etc/fstab -i
sed "/^[^#].* \/ /s/\(UUID=\)\S* \(.*\)/\1$uuid_os \2/g" /mnt/disk_in/etc/fstab -i
sed "/^[^#].*swap/s/\(UUID=\)\S* \(.*\)/\1$uuid_swap \2/g" /mnt/disk_in/etc/fstab -i

> /mnt/disk_in/etc/udev/rules.d/70-persistent-net.rules

echo $hostname > /mnt/disk_in/etc/hostname
cp /usr/bin/transfer_os_tech.sh /mnt/disk_in/usr/bin/
chroot /mnt/disk_in/ '/usr/bin/transfer_os_tech.sh' && return 0 || return 1
}

fun2 () {
echo -e "\n\n\nSUCCESS\n"
ip link show eth0 | grep link | sed 's/.*ether \(\S*\).*/\1/g' &&  cat /mnt/disk_in/etc/hostname
echo -e "\nREBOOT?(Y/n)"
read -sn 1 key
[ "$key" = "n" ] && return 1
shutdown -r now
}


[ "x$2" = "xstart" ] && { fun1 $1 && fun2 || exit 1;}

[ ! "x$2" = "xstart" ] && { \
grub-install /dev/sda || exit 1
update-grub2 || exit 1
rm /boot/efi/EFI/ubuntu/ -r || echo -e "\n\n\n\nNO UBUNTU\n\n\n\n"
exit;}
