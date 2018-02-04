#!/bin/bash

# By Kostia Fursenko

version='1.0'

die() {
	echo "$@"
	exit 1
}

[[ "$(id -u)" -ne 0 ]] && die "Run me as root"

echo "EFI BOOT FIXER V$version"

[[ ! -d /sys/firmware/efi ]] && die 'Not a EFI boot, exiting...'

echo
echo '### Fixing partitions ###'

installer_partition="$(df -Th | grep /cdrom | grep -o '/dev/sd[a-z][0-9]')"
installer_device="${installer_partition%[0-9]*}"

echo "Installer is on $installer_device"

efi_partition=''
for dev in /dev/sd*; do
	if [[ ! "$dev" =~ $installer_device ]]; then
		if blkid "$dev" | grep -q 'EFI System Partition'; then
			efi_partition="$dev"
			break
		fi
	fi
done

if [[ -z "$efi_partition" ]]; then
	echo 'Can not determine the EFI System Partition'
	echo -n 'Manual input: '
	read -r efi_partition
	[[ ! -e "$efi_partition" ]] && die 'Wrong EFI System Partition'
fi

echo "EFI System Partition is on $efi_partition"
efi_device="${efi_partition%[0-9]*}"

# NEEDFIX: remove hardcoded 2
root_partition="${efi_device}2"

if ! blkid "$root_partition" | grep -q 'TYPE="ext4"'; then
	echo 'Can not determine the root partition'
	echo -n 'Manual input: '
	read -r root_partition
	[[ ! -e "$root_partition" ]] && die 'Wrong root partition'
fi

echo "Root partition is on $root_partition"

echo 'Trying to fix the root partition'
fsck -yf "$root_partition" || die 'Failed'

echo 'Recreating the EFI System Partition'
mkfs -t vfat "$efi_partition" || die 'Failed'

echo 'Mounting...'
mount "$root_partition" '/mnt' || die 'Failed'
mount "$efi_partition" '/mnt/boot/efi' || die 'Failed'
for i in /dev /dev/pts /proc /sys /run; do
	mount -B $i /mnt$i
done

# CHROOT
export efi_partition
export efi_device

# NEEDFIX: add die() call except of exit()
cat << 'EOF' | chroot /mnt

echo
echo '### Fixing GRUB ###'

apt-get install --reinstall grub-efi || exit 1
echo "@@@ $efi_device @@@"
grub-install "$efi_device" || exit 1
update-grub || exit 1

echo
echo '### Fixing fstab table ###'

current_efi_uuid="$(grep -v '^#' '/etc/fstab' | grep '/boot/efi' | grep -shoP '\bUUID=.*?[[:space:]]' | sed -e 's/.*=//')"
current_efi_uuid="${current_efi_uuid%%[[:space:]]}"
current_efi_uuid="${current_efi_uuid##[[:space:]]}"

if [[ ! -z "$current_efi_uuid" ]]; then
echo "Current EFI UUID is \"$current_efi_uuid\""
else
echo "Can not get current UUID"
cat '/etc/fstab'
exit 1
fi

actual_efi_uuid="$(blkid "$efi_partition" | grep -shoP '\bUUID=".*?"' | sed -e 's/"//g' -e 's/.*=//')"
actual_efi_uuid="${actual_efi_uuid%%[[:space:]]}"
actual_efi_uuid="${actual_efi_uuid##[[:space:]]}"

if [[ ! -z "$actual_efi_uuid" ]]; then
echo "Actual EFI UUID is \"$actual_efi_uuid\""
else
echo "Can not get actual UUID"
blkid "$efi_partition"
exit 1
fi

if [[ "$actual_efi_uuid" == "$current_efi_uuid" ]]; then
echo "EFI UUID is ok"
else
sed -i "s/$current_efi_uuid/$actual_efi_uuid/" '/etc/fstab'
if [[ $? -ne 0 ]]; then
echo 'Failed to fix the /etc/fstab'
else
current_efi_uuid="$(grep -v '^#' '/etc/fstab' | grep '/boot/efi' | grep -shoP '\bUUID=.*?[[:space:]]' | sed -e 's/.*=//')"
echo "Now UUID is $current_efi_uuid"
fi
fi

EOF
# END OF CHROOT

echo
echo '### Unmounting ###'
umount -Rv /mnt

echo
echo '### Finished ###'
