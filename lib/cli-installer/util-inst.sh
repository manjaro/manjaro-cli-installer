#!/bin/bash

DIALOG(){
	# parameters: see dialog(1)
	# returns: whatever dialog did
	dialog --backtitle "$TITLE" --aspect 15 --yes-label "$_yes" --no-label "$_no" --cancel-label "$_cancel" "$@"
	return $?
}

printk(){
	case ${1} in
		"on")  echo 4 >/proc/sys/kernel/printk ;;
		"off") echo 0 >/proc/sys/kernel/printk ;;
	esac
}

check_ping(){
	echo $(LC_ALL=C ping -c 1 www.manjaro.org | grep "1 received")
}

set_dm_chroot(){
	local _dm
	# setup lightdm
	if [ -e "/usr/bin/lightdm" ] ; then
		mkdir -p ${DESTDIR}/run/lightdm  &>/dev/null
		chroot ${DESTDIR} getent group lightdm > /dev/null 2>&1 || groupadd -g 620 lightdm
		chroot ${DESTDIR} getent passwd lightdm > /dev/null 2>&1 || useradd -c 'LightDM Display Manager' -u 620 -g lightdm -d /var/run/lightdm -s /usr/bin/nologin lightdm
		chroot ${DESTDIR} passwd -l lightdm > /dev/null
		chown -R lightdm:lightdm ${DESTDIR}/run/lightdm  &>/dev/null
		if [ -e "/usr/bin/startxfce4" ] ; then
			sed -i -e 's/^.*user-session=.*/user-session=xfce/' ${DESTDIR}/etc/lightdm/lightdm.conf
			ln -s /usr/lib/lightdm/lightdm/gdmflexiserver ${DESTDIR}/usr/bin/gdmflexiserver
		fi
		chmod +r ${DESTDIR}/etc/lightdm/lightdm.conf &>/dev/null
		_dm="lightdm"
	fi

	# setup gdm
	if [ -e "/usr/bin/gdm" ] ; then
		chroot ${DESTDIR} getent group gdm >/dev/null 2>&1 || groupadd -g 120 gdm
		chroot ${DESTDIR} getent passwd gdm > /dev/null 2>&1 || usr/bin/useradd -c 'Gnome Display Manager' -u 120 -g gdm -d /var/lib/gdm -s /usr/bin/nologin gdm
		chroot ${DESTDIR} passwd -l gdm > /dev/null
		chroot ${DESTDIR} chown -R gdm:gdm /var/lib/gdm  &>/dev/null
		if [ -d "${DESTDIR}/var/lib/AccountsService/users" ] ; then
			echo "[User]" > ${DESTDIR}/var/lib/AccountsService/users/gdm
			if [ -e "/usr/bin/startxfce4" ] ; then
				echo "XSession=xfce" >> ${DESTDIR}/var/lib/AccountsService/users/gdm
			fi
			if [ -e "/usr/bin/cinnamon-session" ] ; then
				echo "XSession=cinnamon" >> ${DESTDIR}/var/lib/AccountsService/users/gdm
			fi
			if [ -e "/usr/bin/mate-session" ] ; then
				echo "XSession=mate" >> ${DESTDIR}/var/lib/AccountsService/users/gdm
			fi
			if [ -e "/usr/bin/enlightenment_start" ] ; then
				echo "XSession=enlightenment" >> ${DESTDIR}/var/lib/AccountsService/users/gdm
			fi
			if [ -e "/usr/bin/openbox-session" ] ; then
				echo "XSession=openbox" >> ${DESTDIR}/var/lib/AccountsService/users/gdm
			fi
			if [ -e "/usr/bin/startlxde" ] ; then
				echo "XSession=LXDE" >> ${DESTDIR}/var/lib/AccountsService/users/gdm
			fi
			if [ -e "/usr/bin/lxqt-session" ] ; then
				echo "XSession=LXQt" >> ${DESTDIR}/var/lib/AccountsService/users/gdm
			fi
			echo "Icon=" >> ${DESTDIR}/var/lib/AccountsService/users/gdm
		fi
	_	dm="gdm"
	fi

	# setup mdm
	if [ -e "/usr/bin/mdm" ] ; then
		chroot ${DESTDIR} getent group mdm >/dev/null 2>&1 || groupadd -g 128 mdm
		chroot ${DESTDIR} getent passwd mdm >/dev/null 2>&1 || usr/bin/useradd -c 'Linux Mint Display Manager' -u 128 -g mdm -d /var/lib/mdm -s /usr/bin/nologin mdm
		chroot ${DESTDIR} passwd -l mdm > /dev/null
		chroot ${DESTDIR} chown root:mdm /var/lib/mdm > /dev/null
		chroot ${DESTDIR} chmod 1770 /var/lib/mdm > /dev/null
		if [ -e "/usr/bin/startxfce4" ] ; then
			sed -i 's|default.desktop|xfce.desktop|g' ${DESTDIR}/etc/mdm/custom.conf
		fi
		if [ -e "/usr/bin/cinnamon-session" ] ; then
			sed -i 's|default.desktop|cinnamon.desktop|g' ${DESTDIR}/etc/mdm/custom.conf
		fi
		if [ -e "/usr/bin/openbox-session" ] ; then
			sed -i 's|default.desktop|openbox.desktop|g' ${DESTDIR}/etc/mdm/custom.conf
		fi
		if [ -e "/usr/bin/mate-session" ] ; then
			sed -i 's|default.desktop|mate.desktop|g' ${DESTDIR}/etc/mdm/custom.conf
		fi
		if [ -e "/usr/bin/startlxde" ] ; then
			sed -i 's|default.desktop|LXDE.desktop|g' ${DESTDIR}/etc/mdm/custom.conf
		fi
		if [ -e "/usr/bin/lxqt-session" ] ; then
			sed -i 's|default.desktop|lxqt.desktop|g' ${DESTDIR}/etc/mdm/custom.conf
		fi
		if [ -e "/usr/bin/enlightenment_start" ] ; then
			sed -i 's|default.desktop|enlightenment.desktop|g' ${DESTDIR}/etc/mdm/custom.conf
		fi
		_dm="mdm"
	fi

	# setup lxdm
	if [ -e "/usr/bin/lxdm" ] ; then
		if [ -z "`chroot ${DESTDIR} getent group "lxdm" 2> /dev/null`" ]; then
			chroot ${DESTDIR} groupadd --system lxdm  &>/dev/null
		fi
		if [ -e "/usr/bin/startxfce4" ] ; then
			sed -i -e 's|^.*session=.*|session=/usr/bin/startxfce4|' ${DESTDIR}/etc/lxdm/lxdm.conf &>/dev/null
		fi
		if [ -e "/usr/bin/cinnamon-session" ] ; then
			sed -i -e 's|^.*session=.*|session=/usr/bin/cinnamon-session|' ${DESTDIR}/etc/lxdm/lxdm.conf &>/dev/null
		fi
		if [ -e "/usr/bin/mate-session" ] ; then
			sed -i -e 's|^.*session=.*|session=/usr/bin/mate-session|' ${DESTDIR}/etc/lxdm/lxdm.conf &>/dev/null
		fi
		if [ -e "/usr/bin/enlightenment_start" ] ; then
			sed -i -e 's|^.*session=.*|session=/usr/bin/enlightenment_start|' ${DESTDIR}/etc/lxdm/lxdm.conf &>/dev/null
		fi
		if [ -e "/usr/bin/openbox-session" ] ; then
			sed -i -e 's|^.*session=.*|session=/usr/bin/openbox-session|' ${DESTDIR}/etc/lxdm/lxdm.conf &>/dev/null
		fi
		if [ -e "/usr/bin/startlxde" ] ; then
			sed -i -e 's|^.*session=.*|session=/usr/bin/lxsession|' ${DESTDIR}/etc/lxdm/lxdm.conf &>/dev/null
		fi
		if [ -e "/usr/bin/lxqt-session" ] ; then
			sed -i -e 's|^.*session=.*|session=/usr/bin/lxqt-session|' ${DESTDIR}/etc/lxdm/lxdm.conf &>/dev/null
		fi
		if [ -e "/usr/bin/pekwm" ] ; then
			sed -i -e 's|^.*session=.*|session=/usr/bin/pekwm|' ${DESTDIR}/etc/lxdm/lxdm.conf &>/dev/null
		fi
		if [ -e "/usr/bin/i3" ] ; then
			sed -i -e 's|^.*session=.*|session=/usr/bin/i3|' ${DESTDIR}/etc/lxdm/lxdm.conf &>/dev/null
		fi
		chgrp -R lxdm ${DESTDIR}/var/lib/lxdm  &>/dev/null
		chgrp lxdm ${DESTDIR}/etc/lxdm/lxdm.conf  &>/dev/null
		chmod +r ${DESTDIR}/etc/lxdm/lxdm.conf  &>/dev/null
		_dm="lxdm"
	fi

	# setup kdm
	if [ -e "/usr/bin/kdm" ] ; then
		chroot ${DESTDIR} getent group kdm >/dev/null 2>&1 || groupadd -g 135 kdm &>/dev/null
		chroot ${DESTDIR} getent passwd kdm >/dev/null 2>&1 || useradd -u 135 -g kdm -d /var/lib/kdm -s /bin/false -r -M kdm &>/dev/null
		chroot ${DESTDIR} chown -R 135:135 var/lib/kdm &>/dev/null
		chroot ${DESTDIR} xdg-icon-resource forceupdate --theme hicolor &> /dev/null
		chroot ${DESTDIR} update-desktop-database -q
		_dm="kdm"
	fi

	# setup sddm
	if [ -e "/usr/bin/sddm" ] ; then
		chroot ${DESTDIR} getent group sddm > /dev/null 2>&1 || groupadd --system sddm
		chroot ${DESTDIR} getent passwd sddm > /dev/null 2>&1 || usr/bin/useradd -c "Simple Desktop Display Manager" --system -d /var/lib/sddm -s /usr/bin/nologin -g sddm sddm
		chroot ${DESTDIR} passwd -l sddm > /dev/null
		chroot ${DESTDIR} mkdir -p /var/lib/sddm
		chroot ${DESTDIR} chown -R sddm:sddm /var/lib/sddm > /dev/null
		sed -i -e "s|^User=.*|User=${username}|" /etc/sddm.conf
		if [ -e "/usr/bin/startxfce4" ] ; then
			sed -i -e 's|^Session=.*|Session=xfce.desktop|' ${DESTDIR}/etc/sddm.conf
		fi
		if [ -e "/usr/bin/cinnamon-session" ] ; then
			sed -i -e 's|^Session=.*|Session=cinnamon.desktop|' ${DESTDIR}/etc/sddm.conf
		fi
		if [ -e "/usr/bin/openbox-session" ] ; then
			sed -i -e 's|^Session=.*|Session=openbox.desktop|' ${DESTDIR}/etc/sddm.conf
		fi
		if [ -e "/usr/bin/mate-session" ] ; then
			sed -i -e 's|^Session=.*|Session=mate.desktop|' ${DESTDIR}/etc/sddm.conf
		fi
		if [ -e "/usr/bin/lxsession" ] ; then
			sed -i -e 's|^Session=.*|Session=LXDE.desktop|' ${DESTDIR}/etc/sddm.conf
		fi
		if [ -e "/usr/bin/lxqt-session" ] ; then
			sed -i -e 's|^Session=.*|Session=lxqt.desktop|' ${DESTDIR}/etc/sddm.conf
		fi
		if [ -e "/usr/bin/enlightenment_start" ] ; then
			sed -i -e 's|^Session=.*|Session=enlightenment.desktop|' ${DESTDIR}/etc/sddm.conf
		fi
		if [ -e "/usr/bin/startkde" ] ; then
			sed -i -e 's|^Session=.*|Session=plasma.desktop|' ${DESTDIR}/etc/sddm.conf
		fi
		_dm="sddm"
	fi

	if [[ -e /run/openrc ]];then
		local _conf_xdm='DISPLAYMANAGER="'${_dm}'"'
		echo "set ${_conf_xdm}" >> /tmp/livecd.log
		sed -i -e "s|^.*DISPLAYMANAGER=.*|${_conf_xdm}|" ${DESTDIR}/etc/conf.d/xdm
	fi
}

hd_config(){
	# initialize special directories
	rm -v -rf ${DESTDIR}/sys ${DESTDIR}/proc ${DESTDIR}/dev &>/dev/null
	mkdir -p -v -m 1777 ${DESTDIR}/tmp &>/dev/null
	mkdir -p -v -m 1777 ${DESTDIR}/var/tmp &>/dev/null
	mkdir -p -v ${DESTDIR}/var/log/old &>/dev/null
	mkdir -p -v ${DESTDIR}/var/lock/sane &>/dev/null
	mkdir -p -v ${DESTDIR}/var/cache/pacman/pkg &>/dev/null
	mkdir -p -v ${DESTDIR}/boot/grub &>/dev/null
	mkdir -p -v ${DESTDIR}/usr/lib/locale &>/dev/null
	mkdir -p -v ${DESTDIR}/usr/share/icons/default &>/dev/null
	mkdir -p -v ${DESTDIR}/media &>/dev/null
	mkdir -p -v ${DESTDIR}/mnt &>/dev/null
	mkdir -p -v ${DESTDIR}/sys &>/dev/null
	mkdir -p -v ${DESTDIR}/proc &>/dev/null

	# create the basic devices (/dev/{console,null,zero}) on the target
	mkdir -p -v ${DESTDIR}/dev &>/dev/null &>/dev/null
	mknod ${DESTDIR}/dev/console c 5 1 &>/dev/null
	mknod ${DESTDIR}/dev/null c 1 3 &>/dev/null
	mknod ${DESTDIR}/dev/zero c 1 5 &>/dev/null

	# adjust permissions on /tmp and /var/tmp
	chmod -v 777 ${DESTDIR}/var/tmp &>/dev/null
	chmod -v o+t ${DESTDIR}/var/tmp &>/dev/null
	chmod -v 777 ${DESTDIR}/tmp &>/dev/null
	chmod -v o+t ${DESTDIR}/tmp &>/dev/null

	# install /etc/resolv.conf
	cp -vf /etc/resolv.conf ${DESTDIR}/etc/resolv.conf &>/dev/null

	echo "install configs for root" &>/dev/null
	cp -a ${DESTDIR}/etc/skel/. ${DESTDIR}/root/ &>/dev/null

	sed -i 's/^#\(en_US.*\)/\1/' ${DESTDIR}/etc/locale.gen &>/dev/null

	chroot_mount

	# copy generated xorg.xonf to target
	if [ -e "/etc/X11/xorg.conf" ] ; then
		echo "copying generated xorg.conf to target"
		cp /etc/X11/xorg.conf ${DESTDIR}/etc/X11/xorg.conf &>/dev/null
	fi

	#set_alsa

	DIALOG --infobox "${_setupalsa}"  6 40
	sleep 3
	# configure alsa
	#set_alsa
	configure_alsa ${DESTDIR}

	# configure pulse
	chroot ${DESTDIR} pulseaudio-ctl normal
	# save settings
	chroot ${DESTDIR} alsactl -f /etc/asound.state store &>/dev/null

	DIALOG --infobox "${_syncpacmandb}" 0 0
	sleep 3

	# Backup the default mirrorlist
	cp -f ${DESTDIR}/etc/pacman.d/mirrorlist ${DESTDIR}/etc/pacman.d/mirrorlist.backup

	if [ ! -z "$(check_ping)" ] ; then
		# Setup mirrors and sync db
		chroot ${DESTDIR} pacman-mirrors -g &>/dev/null
		chroot ${DESTDIR} pacman -Syy &> /dev/null
	fi

	# copy random generated keys by pacman-init to target
	if [ -e "${DESTDIR}/etc/pacman.d/gnupg" ] ; then
		rm -rf ${DESTDIR}/etc/pacman.d/gnupg &>/dev/null
	fi
	pacman-key --populate archlinux manjaro &>/dev/null
	cp -a /etc/pacman.d/gnupg ${DESTDIR}/etc/pacman.d/

	# Install drivers

	if [ -e "/opt/live/pacman-gfx.conf" ] ; then
		DIALOG --infobox "${_installvideodriver}"  6 40

		mkdir -p ${DESTDIR}/opt/live
		mount -o bind /opt/live ${DESTDIR}/opt/live > /tmp/mount.pkgs.log
		ls ${DESTDIR}/opt/live >> /tmp/mount.pkgs.log

		# Install xf86-video driver
		if  [ "${USENONFREE}" == "yes" ] || [ "${USENONFREE}" == "true" ]; then
			if  [ "${VIDEO}" == "vesa" ]; then
				chroot ${DESTDIR} mhwd --install pci video-vesa --pmconfig "/opt/live/pacman-gfx.conf" &>/dev/null
			else
				chroot ${DESTDIR} mhwd --auto pci nonfree 0300 --pmconfig "/opt/live/pacman-gfx.conf" &>/dev/null
			fi
		else
			if  [ "${VIDEO}" == "vesa" ]; then
				chroot ${DESTDIR} mhwd --install pci video-vesa --pmconfig "/opt/live/pacman-gfx.conf" &>/dev/null
			else
				chroot ${DESTDIR} mhwd --auto pci free 0300 --pmconfig "/opt/live/pacman-gfx.conf" &>/dev/null
			fi
		fi

		# Install network drivers
		chroot ${DESTDIR} mhwd --auto pci free 0200 --pmconfig "/opt/live/pacman-gfx.conf" &>/dev/null
		chroot ${DESTDIR} mhwd --auto pci free 0280 --pmconfig "/opt/live/pacman-gfx.conf" &>/dev/null

		umount ${DESTDIR}/opt/live
		rmdir ${DESTDIR}/opt/live
	fi

	# setup system services
	if [[ -e /run/systemd ]]; then
		DIALOG --infobox "${_setupsystemd}" 6 40
		sleep 3
		for svc in ${start_systemd[@]}; do
			chroot ${DESTDIR} systemctl enable $svc &>/dev/null
		done

# 		chroot ${DESTDIR} systemctl enable org.cups.cupsd.service &>/dev/null
# 		chroot ${DESTDIR} systemctl enable dcron.service &>/dev/null
# 		chroot ${DESTDIR} systemctl enable NetworkManager.service &>/dev/null
# 		chroot ${DESTDIR} systemctl enable remote-fs.target &>/dev/null
	else
		DIALOG --infobox "${_setupopenrc}" 6 40
		sleep 3
		for svc in ${start_openrc[@]}; do
			chroot ${DESTDIR} rc-update add $svc default &>/dev/null
		done
# 		chroot ${DESTDIR} rc-update add cups default &>/dev/null
# 		chroot ${DESTDIR} rc-update add cronie default &>/dev/null
# 		chroot ${DESTDIR} rc-update add metalog default &>/dev/null
	fi
	# for openrc (add comment for mounting /tmp as tmpfs in /etc/fstab)
	if [ -e /run/openrc ]; then
		echo "# Uncomment the line below to setup /tmp as tmpfs" >> ${DESTDIR}/etc/fstab
		echo "# tmpfs    /tmp    tmpfs    nodev,nosuid    0   0" >> ${DESTDIR}/etc/fstab
	fi

	DIALOG --infobox "${_setupdisplaymanager}" 6 40
	sleep 3

	#set_dm_chroot
	set_dm_chroot

	# fix some apps

	DIALOG --infobox "${_fixapps}" 6 40
	sleep 3

	# add BROWSER var
	echo "BROWSER=/usr/bin/xdg-open" >> ${DESTDIR}/etc/environment
	echo "BROWSER=/usr/bin/xdg-open" >> ${DESTDIR}/etc/skel/.bashrc
	echo "BROWSER=/usr/bin/xdg-open" >> ${DESTDIR}/etc/profile
	# add TERM var
	if [ -e "${img_path}/mate-image.sqfs" ] ; then
		echo "TERM=mate-terminal" >> ${DESTDIR}/etc/environment
		echo "TERM=mate-terminal" >> ${DESTDIR}/etc/profile
	fi

	# Adjust Steam-Native when libudev.so.0 is available
	if [ -e "/usr/lib/libudev.so.0" ] || [ -e "/usr/lib32/libudev.so.0" ] ; then
		echo -e "STEAM_RUNTIME=0\nSTEAM_FRAME_FORCE_CLOSE=1" >> ${DESTDIR}/etc/environment
	fi

	# fix_gnome_apps
	chroot ${DESTDIR} glib-compile-schemas /usr/share/glib-2.0/schemas
	chroot ${DESTDIR} gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor
	chroot ${DESTDIR} dconf update

	if [ -e "/usr/bin/gnome-keyring-daemon" ] ; then
		chroot ${DESTDIR} setcap cap_ipc_lock=ep /usr/bin/gnome-keyring-daemon &>/dev/null
	fi

	# fix_ping_installation
	chroot ${DESTDIR} setcap cap_net_raw=ep /usr/bin/ping &>/dev/null
	chroot ${DESTDIR} setcap cap_net_raw=ep /usr/bin/ping6 &>/dev/null

	# remove .manjaro-chroot
	chroot ${DESTDIR} rm /.manjaro-tools &>/dev/null

	if [ -e "/usr/bin/live-installer" ] ; then
		chroot ${DESTDIR} pacman -R --noconfirm live-installer &>/dev/null
	fi

	if [ -e "/usr/bin/thus" ] ; then
		chroot ${DESTDIR} pacman -R --noconfirm thus &>/dev/null
	fi

	# remove virtualbox driver on real hardware
	if [ -z "$(mhwd | grep 0300:80ee:beef)" ] ; then
		chroot ${DESTDIR} pacman -Rsc --noconfirm $(pacman -Qq | grep virtualbox-guest-modules) &>/dev/null
	fi

	# set unique machine-id
	chroot ${DESTDIR} dbus-uuidgen --ensure=/etc/machine-id
	chroot ${DESTDIR} ln -s /etc/machine-id /var/lib/dbus/machine-id

	chroot_umount
}

set_passwd(){
	# trap tmp-file for passwd
	trap "rm -f ${ANSWER}" 0 1 2 5 15

	# get password
	DIALOG --title "$_passwdtitle" \
		--clear \
		--insecure \
		--passwordbox "$_passwddl $PASSWDUSER" 10 30 2> ${ANSWER}
	PASSWD="$(cat ${ANSWER})"
	DIALOG --title "$_passwdtitle" \
		--clear \
		--insecure \
		--passwordbox "$_passwddl2 $PASSWDUSER" 10 30 2> ${ANSWER}
	PASSWD2="$(cat ${ANSWER})"
	if [ "$PASSWD" == "$PASSWD2" ]; then
		PASSWD=$PASSWD
		_passwddl=$_passwddl1
	else
		_passwddl=$_passwddl3
		set_passwd
	fi
}

# run_unsquashfs()
# runs unsquashfs on the target system, displays output
#
run_unsquashfs(){
	# all unsquashfs output goes to /tmp/unsquashfs.log, which we tail
	# into a dialog
	( \
		touch /tmp/setup-unsquashfs-running
		echo "unsquashing $SQF_FILE..." > /tmp/unsquashfs.log; \
		echo >> /tmp/unsquashfs.log; \
		unsquashfs -f -da 32 -fr 32 -d $UNSQUASH_TARGET ${img_path}/$SQF_FILE >> /tmp/unsquashfs.log 2>&1
		rm -f /tmp/setup-unsquashfs-running
	) &

	(
	c="0"
	while [ $c -ne 100 ]
	do
		sleep 2
		value=`cat /tmp/unsquashfs.log | grep -Eo " [0-9]*%" | sed -e "s|[^0-9]||g" | tail -1`
		sleep 2
		c=$value
		echo $c
		echo "###"
		echo "$c %"
		echo "###"
	done
	) | DIALOG --title "$_unsquash_dialog_title" --gauge "$_unsquash_dialog_info1 $SQF_FILE $_unsquash_dialog_info2" 10 60 0

	# save unsquashfs.log
	mv "/tmp/unsquashfs.log" "/tmp/unsquashfs-$SQF_FILE.log"
}

# run_mount_sqf()
# runs mount on SQF_FILE
run_mount_sqf(){
	# mount SQF_FILE to CP_SOURCE
	mount ${img_path}/${SQF_FILE} ${CP_SOURCE} -t squashfs -o loop
}

# run_umount_sqf()
# runs umount on SQF_FILE
run_umount_sqf(){
	# umount SQF_FILE from CP_SOURCE
	umount ${CP_SOURCE}
}

# run_cp()
# runs cp on the target system, displays output
#
run_cp(){
	# all cp output goes to /tmp/cp.log, which we tail
	FILES_TOSYNC=$(unsquashfs -l ${img_path}/${SQF_FILE} | wc -l)
	(cp -av ${CP_SOURCE}/* ${CP_TARGET} | \
	pv -nls ${FILES_TOSYNC} | \
	grep -v ">" | grep "[0-9]*") 2>&1 | \
	DIALOG --title "$_unsquash_dialog_title" --gauge "$_unsquash_dialog_info1 $SQF_FILE $_unsquash_dialog_info2" 10 60 0

	# save cp.log
	#mv "/tmp/cp.log" "/tmp/cp-$SQF_FILE.log"
}

# run_mkinitcpio()
# runs mkinitcpio on the target system, displays output
#
run_mkinitcpio(){
	chroot_mount
	# fix fsck.btrfs issue
	chroot "$DESTDIR" ln -sf /bin/true /usr/bin/fsck.btrfs &> /dev/null

	# fix fsck.nilfs2 issue
	chroot "$DESTDIR" ln -sf /bin/true /usr/bin/fsck.nilfs2 &> /dev/null

	# all mkinitcpio output goes to /tmp/mkinitcpio.log, which we tail
	# into a dialog
	( \
		touch /tmp/setup-mkinitcpio-running
		echo "${_runninginitcpio}" >> /tmp/mkinitcpio.log; \
		chroot "$DESTDIR" /usr/bin/mkinitcpio -p "${kernel}" >>/tmp/mkinitcpio.log 2>&1
		echo >> /tmp/mkinitcpio.log
		rm -f /tmp/setup-mkinitcpio-running
	) &

	sleep 2

	DIALOG --title "${_runninginitcpiotitle}" --no-kill --tailboxbg "/tmp/mkinitcpio.log" 18 70
	while [ -f /tmp/setup-mkinitcpio-running ]; do
		/bin/true
	done

	chroot_umount
}

# installsystem_unsquash()
# installs to the target folder
installsystem_unsquash(){
	#DIALOG --msgbox "${_installationwillstart}" 0 0
	#clear
	mkdir -p ${DESTDIR}
	#unsquashfs -f -d ${DESTDIR} ${img_path}/root-image.sqfs
	UNSQUASH_TARGET=${DESTDIR}
	SQF_FILE=root-image.sqfs
	run_unsquashfs
	echo $? > /tmp/.install-retcode
	if [ $(cat /tmp/.install-retcode) -ne 0 ]; then
		echo -e "\n${_installationfail}" >>/tmp/unsquasherror.log
	else
		echo -e "\n => Root-Image: ${_installationsuccess}" >>/tmp/unsquasherror.log
	fi
	sed -i '/dir_scan: failed to open directory [^ ]*, because File exists/d' /tmp/unsquasherror.log

	#unsquashfs -f -d ${DESTDIR} ${img_path}/de-image.sqfs
	UNSQUASH_TARGET=${DESTDIR}
	SQF_FILE=${DESKTOP_IMG}.sqfs
	run_unsquashfs
	echo $? > /tmp/.install-retcode
	if [ $(cat /tmp/.install-retcode) -ne 0 ]; then
		echo -e "\n${_installationfail}" >>/tmp/unsquasherror.log
	else
		echo -e "\n => ${DESKTOP_IMG}: ${_installationsuccess}" >>/tmp/unsquasherror.log
	fi
	sed -i '/dir_scan: failed to open directory [^ ]*, because File exists/d' /tmp/unsquasherror.log

	# finished, display scrollable output
	local _result=''
	if [ $(cat /tmp/.install-retcode) -ne 0 ]; then
		_result="${_installationfail}"
		BREAK="break"
	else
		_result="${_installationsuccess}"
	fi
	rm /tmp/.install-retcode

	DIALOG --title "$_result" --exit-label "${_continue_label}" \
		--textbox "/tmp/unsquasherror.log" 18 60 || return 1

	# ensure the disk is synced
	sync

	if [ "${BREAK}" = "break" ]; then
		break
	fi

	S_INSTALL=1
	NEXTITEM=4

	# automagic time!
	# any automatic configuration should go here
	DIALOG --infobox "${_configuringsystem}" 6 40
	sleep 3

	hd_config
	auto_fstab
	_system_is_installed=1
}

# installsystem_cp()
# installs to the target folder
installsystem_cp(){
	#DIALOG --msgbox "${_installationwillstart}" 0 0
	#clear
	mkdir -p ${DESTDIR}
	#rsync -av --progress /source/root-image ${DESTDIR}
	CP_SOURCE=/source/root-image
	mkdir -p ${CP_SOURCE}
	CP_TARGET=${DESTDIR}
	SQF_FILE=root-image.sqfs
	run_mount_sqf
	run_cp
	run_umount_sqf
	echo $? > /tmp/.install-retcode
	if [ $(cat /tmp/.install-retcode) -ne 0 ]; then
		echo -e "\n${_installationfail}" >>/tmp/rsyncerror.log
	else
		echo -e "\n => Root-Image: ${_installationsuccess}" >>/tmp/rsyncerror.log
	fi

	#rsync -av --progress /source/de-image ${DESTDIR}
	CP_SOURCE=/source/${DESKTOP_IMG}
	mkdir -p ${CP_SOURCE}
	CP_TARGET=${DESTDIR}
	SQF_FILE=${DESKTOP_IMG}.sqfs
	run_mount_sqf
	run_cp
	run_umount_sqf
	echo $? > /tmp/.install-retcode
	if [ $(cat /tmp/.install-retcode) -ne 0 ]; then
		echo -e "\n${_installationfail}" >>/tmp/rsyncerror.log
	else
		echo -e "\n => ${DESKTOP_IMG}: ${_installationsuccess}" >>/tmp/rsyncerror.log
	fi

	# finished, display scrollable output
	local _result=''
	if [ $(cat /tmp/.install-retcode) -ne 0 ]; then
		_result="${_installationfail}"
		BREAK="break"
	else
		_result="${_installationsuccess}"
	fi
	rm /tmp/.install-retcode

	DIALOG --title "$_result" --exit-label "${_continue_label}" \
		--textbox "/tmp/rsyncerror.log" 18 60 || return 1

	# ensure the disk is synced
	sync

	if [ "${BREAK}" = "break" ]; then
		break
	fi

	S_INSTALL=1
	NEXTITEM=4

	# automagic time!
	# any automatic configuration should go here
	DIALOG --infobox "${_configuringsystem}" 6 40
	sleep 3

	hd_config
	auto_fstab
	_system_is_installed=1
}

installsystem(){
	SQFPARAMETER=""
#    DIALOG --defaultno --yesno "${_installchoice}" 0 0 && SQFPARAMETER="yes"
#    if [[ "${SQFPARAMETER}" == "yes" ]]; then
#       installsystem_unsquash
#    else
	installsystem_cp
#    fi
}

set_language(){
	if [[ -e /usr/bin/lg ]]; then
		/usr/bin/lg --setup
	else
		DIALOG --msgbox "Error:\nlg script not found, aborting language setting" 0 0
	fi
}

set_keyboard(){
	if [[ -e /usr/bin/km ]]; then
		/usr/bin/km --setup
	else
		DIALOG --msgbox "Error:\nkm script not found, aborting keyboard and console setting" 0 0
	fi
}

set_clock(){
	# utc or local?
	DIALOG --menu "${_machinetimezone}" 10 72 2 \
		"UTC" " " \
		"localtime" " " \
		2>${ANSWER} || return 1
	HARDWARECLOCK=$(cat ${ANSWER})

	# timezone?
	REGIONS=""
	for i in $(grep '^[A-Z]' /usr/share/zoneinfo/zone.tab | cut -f 3 | sed -e 's#/.*##g'| sort -u); do
		REGIONS="$REGIONS $i -"
	done
	region=""
	zone=""
	while [ -z "$zone" ];do
		region=""
		while [ -z "$region" ];do
			:>${ANSWER}
			DIALOG --menu "${_selectregion}" 0 0 0 $REGIONS 2>${ANSWER}
			region=$(cat ${ANSWER})
		done
		ZONES=""
		for i in $(grep '^[A-Z]' /usr/share/zoneinfo/zone.tab | grep $region/ | cut -f 3 | sed -e "s#$region/##g"| sort -u); do
			ZONES="$ZONES $i -"
		done
		:>${ANSWER}
		DIALOG --menu "${_selecttimezone}" 0 0 0 $ZONES 2>${ANSWER}
		zone=$(cat ${ANSWER})
	done
	TIMEZONE="$region/$zone"

	# set system clock from hwclock - stolen from rc.sysinit
	local HWCLOCK_PARAMS=""


	if [[ -e /run/openrc ]];then
		local _conf_clock='clock="'${HARDWARECLOCK}'"'
		sed -i -e "s|^.*clcok=.*|${_conf_clock}|" /etc/conf.d/hwclock
		fi
		if [ "$HARDWARECLOCK" = "UTC" ]; then
		HWCLOCK_PARAMS="$HWCLOCK_PARAMS --utc"
	else
	HWCLOCK_PARAMS="$HWCLOCK_PARAMS --localtime"
		if [[ -e /run/systemd ]];then
			echo "0.0 0.0 0.0" > /etc/adjtime &> /dev/null
			echo "0" >> /etc/adjtime &> /dev/null
			echo "LOCAL" >> /etc/adjtime &> /dev/null
		fi
	fi
	if [ "$TIMEZONE" != "" -a -e "/usr/share/zoneinfo/$TIMEZONE" ]; then
		/bin/rm -f /etc/localtime
		#/bin/cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
		ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
	fi
	/usr/bin/hwclock --hctosys $HWCLOCK_PARAMS --noadjfile

	if [[ -e /run/openrc ]];then
		echo "${TIMEZONE}" > /etc/timezone
	fi

	# display and ask to set date/time
	DIALOG --calendar "${_choosedatetime}" 0 0 0 0 0 2> ${ANSWER} || return 1
	local _date="$(cat ${ANSWER})"
	DIALOG --timebox "${_choosehourtime}" 0 0 2> ${ANSWER} || return 1
	local _time="$(cat ${ANSWER})"
	echo "date: $_date time: $_time" >$LOG

	# save the time
	# DD/MM/YYYY hh:mm:ss -> YYYY-MM-DD hh:mm:ss
	local _datetime="$(echo "$_date" "$_time" | sed 's#\(..\)/\(..\)/\(....\) \(..\):\(..\):\(..\)#\3-\2-\1 \4:\5:\6#g')"
	echo "setting date to: $_datetime" >$LOG
	date -s "$_datetime" 2>&1 >$LOG
	/usr/bin/hwclock --systohc $HWCLOCK_PARAMS --noadjfile

	S_CLOCK=1
	NEXTITEM="2"
}

dogrub_mkconfig(){
	chroot_mount

	# prepare grub.cfg
	chroot ${DESTDIR} mkdir -p /boot/grub/locale
	chroot ${DESTDIR} cp /usr/share/locale/en@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

	# remove splash if no plymouth was found
	if [ ! -e ${DESTDIR}/etc/plymouth/plymouthd.conf ] ; then
		sed -i -e "s,GRUB_CMDLINE_LINUX_DEFAULT=.*,GRUB_CMDLINE_LINUX_DEFAULT=\"`cat $DESTDIR/etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT | cut -d'"' -f2 | sed s'/splash//'g | sed s'/quiet//'g`\",g" $DESTDIR/etc/default/grub
	fi

	# generate resume string for suspend to disk
	[ -z "${swap_partition}" -o "${swap_partition}" = "NONE" ] || sed -i -e "s,GRUB_CMDLINE_LINUX_DEFAULT=.*,GRUB_CMDLINE_LINUX_DEFAULT=\"`cat $DESTDIR/etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT | cut -d'"' -f2` resume=UUID=`blkid -s UUID -o value -p ${swap_partition}`\",g" $DESTDIR/etc/default/grub

	# grub.cfg workaround for net-install
	if [ "$DESKTOP_IMG" == "net-image" ];then
		sed -i -e 's|GRUB_SAVEDEFAULT=true|#GRUB_SAVEDEFAULT=true|g' $DESTDIR/etc/default/grub
	fi

	# create grub.cfg
	chroot ${DESTDIR} grub-mkconfig -o "/${GRUB_PREFIX_DIR}/grub.cfg" >> /tmp/grub.log 2>&1

	chroot_umount
}

_setup_user(){
	#addgroups="video,audio,power,disk,storage,optical,network,lp,scanner"
	DIALOG --inputbox "${_enterusername}" 10 65 "${username}" 2>${ANSWER} || return 1
	REPLY="$(cat ${ANSWER})"
	while [ -z "$(echo $REPLY |grep -E '^[a-z_][a-z0-9_-]*[$]?$')" ];do
		DIALOG --inputbox "${_givecorrectname}" 10 65 "${username}" 2>${ANSWER} || return 1
		REPLY="$(cat ${ANSWER})"
	done

	chroot ${DESTDIR} useradd -m -p "" -g users -G $addgroups $REPLY

	PASSWDUSER="$REPLY"

	if [ -d "${DESTDIR}/var/lib/AccountsService/users" ] ; then
		echo "[User]" > ${DESTDIR}/var/lib/AccountsService/users/$PASSWDUSER
		if [ -e "/usr/bin/startxfce4" ] ; then
			echo "XSession=xfce" >> ${DESTDIR}/var/lib/AccountsService/users/$PASSWDUSER
		fi
		if [ -e "/usr/bin/cinnamon-session" ] ; then
			echo "XSession=cinnamon" >> ${DESTDIR}/var/lib/AccountsService/users/$PASSWDUSER
		fi
		if [ -e "/usr/bin/mate-session" ] ; then
			echo "XSession=mate" >> ${DESTDIR}/var/lib/AccountsService/users/$PASSWDUSER
		fi
		if [ -e "/usr/bin/enlightenment_start" ] ; then
			echo "XSession=enlightenment" >> ${DESTDIR}/var/lib/AccountsService/users/$PASSWDUSER
		fi
		if [ -e "/usr/bin/openbox-session" ] ; then
			echo "XSession=openbox" >> ${DESTDIR}/var/lib/AccountsService/users/$PASSWDUSER
		fi
		if [ -e "/usr/bin/startlxde" ] ; then
			echo "XSession=LXDE" >> ${DESTDIR}/var/lib/AccountsService/users/$PASSWDUSER
		fi
		if [ -e "/usr/bin/lxqt-session" ] ; then
			echo "XSession=LXQt" >> ${DESTDIR}/var/lib/AccountsService/users/$PASSWDUSER
		fi
		echo "Icon=" >> ${DESTDIR}/var/lib/AccountsService/users/$PASSWDUSER
	fi

	if DIALOG --yesno "${_addsudouserdl1}${REPLY}${_addsudouserdl2}" 6 40;then
		echo "${PASSWDUSER}     ALL=(ALL) ALL" >> ${DESTDIR}/etc/sudoers
	fi
	sed -i -e 's|# %wheel ALL=(ALL) ALL|%wheel ALL=(ALL) ALL|g' ${DESTDIR}/etc/sudoers
	chmod 0440 ${DESTDIR}/etc/sudoers
	set_passwd
	echo "$PASSWDUSER:$PASSWD" | chroot ${DESTDIR} chpasswd
	NEXTITEM="Setup-User"
	DONE_CONFIG=1
}

_config_system(){
	DONE=0
	NEXTITEM=""
	while [[ "${DONE}" = "0" ]]; do
		if [[ -n "${NEXTITEM}" ]]; then
			DEFAULT="--default-item ${NEXTITEM}"
		else
			DEFAULT=""
		fi
		if [[ -e /run/systemd ]]; then
			DIALOG $DEFAULT --menu "Configuration" 17 78 10 \
				"/etc/fstab"                "${_fstabtext}" \
				"/etc/mkinitcpio.conf"      "${_mkinitcpioconftext}" \
				"/etc/resolv.conf"          "${_resolvconftext}" \
				"/etc/hostname"             "${_hostnametext}" \
				"/etc/hosts"                "${_hoststext}" \
				"/etc/hosts.deny"           "${_hostsdenytext}" \
				"/etc/hosts.allow"          "${_hostsallowtext}" \
				"/etc/locale.gen"           "${_localegentext}" \
				"/etc/locale.conf"          "${_localeconftext}" \
				"/etc/environment"          "${_environmenttext}" \
				"/etc/pacman-mirrors.conf"  "${_mirrorconftext}" \
				"/etc/pacman.d/mirrorlist"  "${_mirrorlisttext}" \
				"/etc/X11/xorg.conf.d/10-evdev.conf"  "${_xorgevdevconftext}" \
				"/etc/vconsole.conf"        "${_vconsoletext}" \
				"${_return_label}"        "${_return_label}" 2>${ANSWER} || NEXTITEM="${_return_label}"
			NEXTITEM="$(cat ${ANSWER})"
		else
			DIALOG $DEFAULT --menu "Configuration" 17 78 10 \
				"/etc/fstab"                "${_fstabtext}" \
				"/etc/mkinitcpio.conf"      "${_mkinitcpioconftext}" \
				"/etc/resolv.conf"          "${_resolvconftext}" \
				"/etc/rc.conf"              "${_rcconfigtext}" \
				"/etc/conf.d/hostname"      "${_hostnametext}" \
				"/etc/conf.d/keymaps"       "${_localeconftext}" \
				"/etc/conf.d/modules"       "${_modulesconftext}" \
				"/etc/conf.d/hwclock"       "${_hwclockconftext}" \
				"/etc/conf.d/xdm"           "${_xdmconftext}" \
				"/etc/hosts"                "${_hoststext}" \
				"/etc/hosts.deny"           "${_hostsdenytext}" \
				"/etc/hosts.allow"          "${_hostsallowtext}" \
				"/etc/locale.gen"           "${_localegentext}" \
				"/etc/environment"          "${_environmenttext}" \
				"/etc/pacman-mirrors.conf"  "${_mirrorconftext}" \
				"/etc/pacman.d/mirrorlist"  "${_mirrorlisttext}" \
				"/etc/X11/xorg.conf.d/10-evdev.conf"  "${_xorgevdevconftext}" \
				"/etc/X11/xorg.conf.d/00-keyboard.conf"  "X11 keyboard configuration" \
				"${_return_label}"        "${_return_label}" 2>${ANSWER} || NEXTITEM="${_return_label}"
			NEXTITEM="$(cat ${ANSWER})"
		fi

		if [ "${NEXTITEM}" = "${_return_label}" -o -z "${NEXTITEM}" ]; then
			DONE=1
		else
			$EDITOR ${DESTDIR}${NEXTITEM}
		fi
	done
}

_post_process(){
	## POSTPROCESSING ##
	# /etc/locale.gen
	#
	DIALOG --infobox "${_localegen}" 0 0
	chroot ${DESTDIR} locale-gen &> /dev/null

	# installing localization packages
	if [ -e "${img_path}/lng-image.sqfs" ] ; then
		configure_translation_pkgs ${DESTDIR}
		${PACMAN_LNG} -Sy
		if [ -e "${img_path}/kde-image.sqfs" ] ; then
			${PACMAN_LNG} -S ${KDE_LNG_INST} &> /dev/null
		fi
		if [ -e "/usr/bin/firefox" ] ; then
			${PACMAN_LNG} -S ${FIREFOX_LNG_INST} &> /dev/null
		fi
		if [ -e "/usr/bin/thunderbird" ] ; then
			${PACMAN_LNG} -S ${THUNDER_LNG_INST} &> /dev/null
		fi
		if [ -e "/usr/bin/libreoffice" ] ; then
			${PACMAN_LNG} -S ${LIBRE_LNG_INST} &> /dev/null
		fi
		if [ -e "/usr/bin/hunspell" ] ; then
			${PACMAN_LNG} -S ${HUNSPELL_LNG_INST} &> /dev/null
		fi
	fi

	# check if we are running inside a virtual machine and unistall kalu
	if [ -e "${DESTDIR}/usr/bin/kalu" ] ; then
		rm_kalu ${DESTDIR}
	fi

	# /etc/localtime
	cp /etc/localtime ${DESTDIR}/etc/localtime &> /dev/null
	if [ -e "/etc/adjtime" ] ; then
		cp /etc/adjtime ${DESTDIR}/etc/adjtime &> /dev/null
	fi

	sleep 3
	# add resume hook for suspend to disk
	[ -z "${swap_partition}" -o "${swap_partition}" = "NONE" ] || \
	if [ "x$(cat $DESTDIR/etc/mkinitcpio.conf | grep '^HOOKS=' | grep -v '^#' | grep resume)" == "x" ]; then
		hooks=""
		for hook in $(cat $DESTDIR/etc/mkinitcpio.conf | grep '^HOOKS=' | grep -v '^#' | cut -d'"' -f2) ; do
			if [ "$hook" == "filesystems" ] && [ "$replaced" == "" ]; then
				hook="resume filesystems"
				replaced="1"
			fi
			hooks="${hooks} ${hook}"
		done
		hooks=$(echo "${hooks}" | sed 's/^ *//;s/ *$//;s/ \{1,\}/ /g')
		if [ "x$(echo \"${hooks}\" | grep resume)" == "x" ]; then
			hooks="${hooks} resume"
		fi
		sed -i -e "s/^HOOKS=.*/HOOKS=\"${hooks}\"/g" $DESTDIR/etc/mkinitcpio.conf
	fi

	# create kernel images
	run_mkinitcpio
	sleep 3

	## END POSTPROCESSING ##
	# TODO add end cleaning

	S_CONFIG=1
	NEXTITEM=5
	_system_is_configured=1
}

# Disable swap and all mounted partitions for the destination system. Unmount
# the destination root partition last!
_umountall(){
	DIALOG --infobox "$_umountingall" 0 0
	swapoff -a >/dev/null 2>&1
	umount $(mount | grep -v "${DESTDIR} " | grep "${DESTDIR}" | sed 's|\ .*||g') >/dev/null 2>&1
	umount $(mount | grep "${DESTDIR} " | sed 's|\ .*||g') >/dev/null 2>&1
}

# Umount all mounted partitions
_umounthdds(){
	for UPART in $(findpartitions); do
		umount $(mount | grep ${UPART} | grep -v /bootmnt | sed 's|\ .*||g') >/dev/null 2>&1
	done
}
