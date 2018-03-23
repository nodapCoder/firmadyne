#!/bin/bash

set -e
set -u

if [ -e ./firmadyne.config ]; then
    source ./firmadyne.config
elif [ -e ../firmadyne.config ]; then
    source ../firmadyne.config
else
    echo "Error: Could not find 'firmadyne.config'!"
    exit 1
fi

if check_number $1; then
    echo "Usage: run.ppceb.sh <image ID>"
    exit 1
fi
IID=${1}

WORK_DIR=`get_scratch ${IID}`
IMAGE=`get_fs ${IID}`
KERNEL=`get_kernel "ppceb"`

qemu-system-ppc -m 256 \
				-kernel ${KERNEL} \
				-drive if=ide,file=${IMAGE},format=raw \
				-append "firmadyne.syscall=1 root=/dev/core console=ttyS0 nandsim.parts=64,64,64,64,64,64,64,64,64,64 rdinit=/firmadyne/preInit.sh rw debug ignore_loglevel print-fatal-signals=1" \
				-serial file:${WORK_DIR}/qemu.initial.serial.log \
				-serial unix:/tmp/qemu.${IID}.S1,server,nowait \
				-monitor unix:/tmp/qemu.${IID},server,nowait 