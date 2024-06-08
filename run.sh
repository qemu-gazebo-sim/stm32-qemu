#!/bin/sh

# QEMU=/home/vanderson/Desktop/codes/tcc/stm32-qemu/build/arm-softmmu/qemu-system-arm
STM32_QEMU_PATH=$(pwd)
BLUEPILL_PURSUER_PATH=$(pwd)/../bluepill_pursuer
QEMU_REL=build/arm-softmmu/qemu-system-arm
QEMU=$STM32_QEMU_PATH/$QEMU_REL

get_qemu_version() {
	"$QEMU" --version | perl -ne 'print $1 if /version (\S+)/'
}

check_version_at_least() {
	V="$( (echo "$1" ; get_qemu_version) | sort -V | head -1 )"
	test "$V" = "$1"
	return $?
}

cd "$HOME"

# Target root with kernel and dtbs
ROOTFS=rootfs
# Target downloaded zip
# TARGET=raspios_lite_armhf_latest.zip
# Port to forward ssh to
SSHPORT=50022
# Enable or disable GPIO management
ENABLEQTEST=true
#ENABLEQTEST=false
QTESTSOCKET="/tmp/tmp-gpio.sock"

IMGNAME="$(7z l "$TARGET" | awk '/\.img/{print $NF}')"
echo "[ ] root image: $IMGNAME"

BOOTPARAMS=""
# Console and system prints
BOOTPARAMS="$BOOTPARAMS console=ttyAMA0,115200"
BOOTPARAMS="$BOOTPARAMS earlyprintk"
BOOTPARAMS="$BOOTPARAMS loglevel=8"
# Root and fs
BOOTPARAMS="$BOOTPARAMS rw"
BOOTPARAMS="$BOOTPARAMS root=/dev/mmcblk0p2"
BOOTPARAMS="$BOOTPARAMS rootwait"
BOOTPARAMS="$BOOTPARAMS rootfstype=ext4"

NETPARAMS=""

# From qemu 5.1.0 usb-net was implemented
if check_version_at_least "5.1.0"; then
	NETPARAMS="$NETPARAMS -device usb-net,netdev=net0"
	NETPARAMS="$NETPARAMS -netdev user,id=net0,hostfwd=tcp:127.0.0.1:11311-:11311"
fi

QTESTPARAMS=""
if $ENABLEQTEST; then
	QTESTPARAMS="$QTESTPARAMS -qtest unix:$QTESTSOCKET"
fi


LOGPARAMS=""
if $LOGPARAMS; then
	LOGPARAMS="$LOGPARAMS -D /tmp/qemu.log"
	LOGPARAMS="$LOGPARAMS -d guest_errors"
fi

SERIAL=""
SERIAL="$SERIAL -curses"
SERIAL="$SERIAL -serial stdio"
#SERIAL="$SERIAL -monitor stdio"

# cd /home/vanderson/Desktop/codes/tcc/stm32-qemu/build
cd $STM32_QEMU_PATH/build
make -j
cd $STM32_QEMU_PATH
# cd /home/vanderson/Desktop/codes/tcc/stm32-qemu
"$QEMU"                                                   \
	-machine stm32-f103c8                                   \
	-kernel $BLUEPILL_PURSUER_PATH/build/bluepill_gpio_sim_v1.bin \
	-d guest_errors \
	$NETPARAMS \
	# -kernel /home/vanderson/Desktop/codes/tcc/bluepill_gpio_sim/build/bluepill_gpio_sim_v1.bin \
	# $LOGPARAMS \
	# $QTESTPARAMS \
	# -s \
	# -S \
	# -net nic \
	# -net user,id=net0,hostfwd=tcp:127.0.0.1:22-:22 \
	# $NETPARAMS                                        \
	# $QTESTPARAMS                                      \
	# $LOGPARAMS                                        \
	# -nographic \
	# -curses                                           \
	# $SERIAL                                           \
	# -board BluePill \
	# -mcu STM32F103C8 \
	# -dtb     "$ROOTFS/bcm2710-rpi-3-b-plus.dtb"       \
	# -kernel  "$ROOTFS/kernel8.img"                    \
	# -append  "$BOOTPARAMS"                            \
	# -drive   "file=$IMGNAME,if=sd,format=raw,index=0" \