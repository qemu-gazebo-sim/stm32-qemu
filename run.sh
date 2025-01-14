#!/bin/sh

STM32_QEMU_PATH=$(pwd)
BLUEPILL_PURSUER_PATH=$(pwd)/../bluepill_pursuer
QEMU_REL=build/arm-softmmu/qemu-system-arm
QEMU=$STM32_QEMU_PATH/$QEMU_REL

# Enable or disable GPIO management
ENABLEQTEST=true #ENABLEQTEST=false
QTESTSOCKET="/tmp/tmp-gpio.sock"

MACHINE_NAME=stm32-f103c8

get_qemu_version() {
	"$QEMU" --version | perl -ne 'print $1 if /version (\S+)/'
}

check_version_at_least() {
	V="$( (echo "$1" ; get_qemu_version) | sort -V | head -1 )"
	test "$V" = "$1"
	return $?
}

cd "$HOME"

echo "[ ] root machine: $MACHINE_NAME"

NETPARAMS=""
# From qemu 5.1.0 usb-net was implemented
if check_version_at_least "5.1.0"; then
	NETPARAMS="$NETPARAMS -device usb-net,netdev=net0"
	NETPARAMS="$NETPARAMS -netdev user,id=net0,hostfwd=tcp:127.0.0.1:11311-:11311"
fi


LOGPARAMS=""
if $LOGPARAMS; then
	LOGPARAMS="$LOGPARAMS -D /tmp/qemu.log"
	LOGPARAMS="$LOGPARAMS -d guest_errors"
fi

cd $STM32_QEMU_PATH/build
make -j
cd $STM32_QEMU_PATH

# -s shorthand for -gdb tcp::1234
# -S freeze CPU at startup (use 'c' to start execution)
"$QEMU"                                                   \
	-machine $MACHINE_NAME                                  \
	-kernel $BLUEPILL_PURSUER_PATH/build/bluepill_gpio_sim_v1.bin \
	$NETPARAMS \
	$LOGPARAMS \
	# -s \
	# -S \