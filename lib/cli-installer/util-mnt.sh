#!/bin/bash

# chroot_mount()
# prepares target system as a chroot
#
chroot_mount(){
    [[ -e "${DESTDIR}/sys" ]] || mkdir -m 555 "${DESTDIR}/sys"
    [[ -e "${DESTDIR}/proc" ]] || mkdir -m 555 "${DESTDIR}/proc"
    [[ -e "${DESTDIR}/dev" ]] || mkdir "${DESTDIR}/dev"
    mount -t sysfs sysfs "${DESTDIR}/sys"
    mount -t proc proc "${DESTDIR}/proc"
    mount -o bind /dev "${DESTDIR}/dev"
    chmod 555 "${DESTDIR}/sys"
    chmod 555 "${DESTDIR}/proc"
}

# chroot_umount()
# tears down chroot in target system
#
chroot_umount(){
    umount "${DESTDIR}/proc"
    umount "${DESTDIR}/sys"
    umount "${DESTDIR}/dev"
}

# _getdisccapacity()
#
# parameters: device file
# outputs:    disc capacity in bytes
_getdisccapacity(){
 echo $(fdisk -l $1 | grep $1: | cut -d" " -f5)
}

# Get a list of available disks for use in the "Available disks" dialogs. This
# will print the disks as follows, getting size info from _getdisccapacity():
#   /dev/sda: 625000 MiB (610 GiB)
#   /dev/sdb: 476940 MiB (465 GiB)
_getavaildisks(){
    for DISC in $(finddisks); do
        DISC_SIZE=$(_getdisccapacity $DISC)
        echo "$DISC: $((DISC_SIZE / 2**20)) MiB ($((DISC_SIZE / 2**30)) GiB)\n"
    done
}

getfstype(){
    echo "$(${_BLKID} -p -i -s TYPE -o value ${1})"
}

# getfsuuid()
# converts /dev devices to FSUUIDs
#
# parameters: device file
# outputs:    FSUUID on success
#             nothing on failure
# returns:    nothing
getfsuuid(){
    echo "$(${_BLKID} -p -i -s UUID -o value ${1})"
}

# getuuid()
# converts /dev/[hs]d?[0-9] devices to UUIDs
#
# parameters: device file
# outputs:    UUID on success
#             nothing on failure
# returns:    nothing
getuuid(){
    if [ -n "$(echo ${1} |grep -E '[shv]d[a-z]+[0-9]+$|mmcblk[0-9]+p[0-9]+$')" ]; then
        echo "$(blkid -s UUID -o value ${1})"
    fi
}

# parameters: device file
# outputs:    LABEL on success
#             nothing on failure
# returns:    nothing
getfslabel(){
    echo "$(${_BLKID} -p -i -s LABEL -o value ${1})"
}

getpartuuid(){
    echo "$(${_BLKID} -p -i -s PART_ENTRY_UUID -o value ${1})"
}

getpartlabel(){
    echo "$(${_BLKID} -p -i -s PART_ENTRY_NAME -o value ${1})"
}
